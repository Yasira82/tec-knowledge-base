#!/usr/bin/env python3
"""
TEC — cross-repo drift check: KB facts vs the code they describe.

Every in-repo gate checks the KB against ITSELF (headers, links, registry). None of them
can see that C-20 says a port the service no longer listens on, or that C-14 names a
version nobody published. That is audit finding F1 — the KB's facts drifted from the code
for months with every gate green (audits/KB_ENGINEERING_AUDIT_2026-09-24.md).

This script closes that gap. It reads the code repos at a git ref and compares:

  versions   C-14 + memory/platform-snapshot.md   ↔ package.json (tec-ui · tec-auth · tec-sdk · tec-shared)
  ports      C-20 + snapshot + app-fleet + tec-core-backend CLAUDE.md ↔ each service's main.ts default
  events     manifests/events-catalog.yaml         ↔ event names in tec-core-backend source (both directions)
  cookies    C-13 / C-123 (None + Partitioned)     ↔ every cookie setter in the Hub, template and apps
  fleet      architecture/app-fleet.yaml           ↔ Hub registry + SSO allowlist + each app's APP_SOURCE
  slo        C-78 §2                               ↔ manifests/slo-definitions.yaml (same numbers, one authority)

Each result is PASS, FAIL or SKIP (a repo that is not available). Exit 1 on any FAIL, or on
any SKIP with --strict.

Usage:
  python3 scripts/check-drift.py --repos-dir /home/user --ref origin/main    # local clones
  python3 scripts/check-drift.py --repos-dir repos --strict --summary out.md # the weekly job
"""
import argparse
import json
import os
import re
import subprocess
import sys

import yaml

KB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

PASS, FAIL, SKIP = 'PASS', 'FAIL', 'SKIP'
results = []  # (status, check, detail)


def record(status, check, detail):
    results.append((status, check, detail))


# ── repo access (read at a git ref, never the working tree — a checkout on another branch
#    must not make main look drifted) ─────────────────────────────────────────────────────

class Repo:
    def __init__(self, name, path, ref):
        self.name, self.path, self.ref = name, path, ref

    def _git(self, *args):
        r = subprocess.run(['git', '-C', self.path, *args], capture_output=True, text=True)
        return r.stdout if r.returncode == 0 else None

    def read(self, rel):
        return self._git('show', f'{self.ref}:{rel}')

    def files(self, *pathspecs):
        out = self._git('ls-tree', '-r', '--name-only', self.ref, '--', *pathspecs)
        return out.split('\n') if out else []

    def grep(self, pattern, *pathspecs):
        """[(file, line_text)] for an extended regex, source files only (tests excluded)."""
        specs = list(pathspecs) or ['.']
        specs += [':!*.test.ts', ':!*.test.tsx', ':!*.spec.ts', ':!**/__tests__/**', ':!**/node_modules/**']
        out = self._git('grep', '-I', '-E', pattern, self.ref, '--', *specs)
        hits = []
        for line in (out or '').splitlines():
            # "<ref>:<file>:<text>"
            rest = line[len(self.ref) + 1:]
            f, _, text = rest.partition(':')
            hits.append((f, text))
        return hits


def open_repos(repos_dir, ref):
    by_lower = {}
    if os.path.isdir(repos_dir):
        for d in os.listdir(repos_dir):
            if os.path.isdir(os.path.join(repos_dir, d, '.git')):
                by_lower[d.lower()] = d

    def get(name):
        d = by_lower.get(name.lower())
        if not d:
            return None
        repo = Repo(name, os.path.join(repos_dir, d), ref)
        if repo._git('rev-parse', '--verify', '--quiet', ref) is None:
            return None
        return repo
    return get


def kb_read(rel):
    with open(os.path.join(KB, rel), encoding='utf-8') as f:
        return f.read()


def kb_glob_one(prefix):
    d = os.path.join(KB, 'knowledge-base')
    for f in sorted(os.listdir(d)):
        # exact number: 'C-13' must not match C-135
        if f.startswith(prefix) and not f[len(prefix):len(prefix) + 1].isdigit():
            return os.path.join('knowledge-base', f)
    raise SystemExit(f'KB file {prefix}* not found')


# ── versions ─────────────────────────────────────────────────────────────────────────────

PACKAGES = {  # short name → (repo, package.json path)
    'tec-ui': ('Tec-ui', 'package.json'),
    'tec-auth': ('tec-auth', 'package.json'),
    'tec-sdk': ('TEC-SDK', 'package.json'),
    'tec-shared': ('Tec-core-backend', 'shared/package.json'),
}


def check_versions(get):
    c14_path = kb_glob_one('C-14')
    claims = {}
    for m in re.finditer(r'^\|\s*(tec-ui|tec-auth|tec-sdk|tec-shared)\s*\|\s*\**v?(\d+\.\d+\.\d+)', kb_read(c14_path), re.M):
        claims.setdefault(m.group(1), []).append((c14_path, m.group(2)))
    for m in re.finditer(r'^\|\s*@yasser172/(tec-\w+)\s*\|\s*(\d+\.\d+\.\d+)', kb_read('memory/platform-snapshot.md'), re.M):
        claims.setdefault(m.group(1), []).append(('memory/platform-snapshot.md', m.group(2)))

    for pkg, (repo_name, pj) in PACKAGES.items():
        repo = get(repo_name)
        if not repo:
            record(SKIP, 'versions', f'{pkg}: repo {repo_name} not available')
            continue
        raw = repo.read(pj)
        if raw is None:
            record(FAIL, 'versions', f'{pkg}: {repo_name}/{pj} not found')
            continue
        actual = json.loads(raw)['version']
        if pkg not in claims:
            record(FAIL, 'versions', f'{pkg}: code is {actual} but no KB doc states a version')
        for where, said in claims.get(pkg, []):
            if said == actual:
                record(PASS, 'versions', f'{pkg} {actual} — {where}')
            else:
                record(FAIL, 'versions', f'{pkg}: {where} says {said}, {repo_name}/{pj} is {actual}')


# ── ports ────────────────────────────────────────────────────────────────────────────────

SERVICES = ['api-gateway', 'auth', 'wallet', 'payment', 'asset', 'identity',
            'notification', 'storage', 'kyc', 'commerce', 'realtime', 'analytics']
SNAPSHOT_NAMES = {'Gateway': 'api-gateway', 'Auth': 'auth', 'Wallet': 'wallet', 'Payment': 'payment',
                  'Asset': 'asset', 'Identity': 'identity', 'Notify': 'notification', 'Storage': 'storage',
                  'KYC': 'kyc', 'Commerce': 'commerce', 'Realtime': 'realtime', 'Analytics': 'analytics'}


def service_dir(svc):
    return 'tec-api-gateway' if svc == 'api-gateway' else f'tec-{svc}-service'


def code_ports(backend):
    ports = {}
    for svc in SERVICES:
        d = service_dir(svc)
        main = backend.read(f'{d}/src/main.ts') or ''
        m = re.search(r"process\.env\.PORT\s*(?:\?\?|\|\|)\s*['\"]?(\d{4})", main)
        if m:
            ports[svc] = (int(m.group(1)), 'main.ts')
            continue
        # no code default (payment: PORT is required by its env schema) → the documented default
        env = backend.read(f'{d}/.env.example') or ''
        m = re.search(r'^PORT=(\d{4})', env, re.M)
        if m:
            ports[svc] = (int(m.group(1)), '.env.example — no code default')
    return ports


def check_ports(get):
    backend = get('Tec-core-backend')
    if not backend:
        record(SKIP, 'ports', 'repo Tec-core-backend not available')
        return
    actual = code_ports(backend)
    for svc in SERVICES:
        if svc not in actual:
            record(FAIL, 'ports', f'{svc}: no port found in {service_dir(svc)}/src/main.ts or .env.example')

    claims = []  # (where, svc, port)
    c20 = kb_glob_one('C-20')
    for m in re.finditer(r'^\|\s*(' + '|'.join(SERVICES) + r')\s*\|\s*(\d{4})\s*\|', kb_read(c20), re.M):
        claims.append((c20, m.group(1), int(m.group(2))))
    for m in re.finditer(r'\b(' + '|'.join(SNAPSHOT_NAMES) + r')\s*:(\d{4})\b', kb_read('memory/platform-snapshot.md')):
        claims.append(('memory/platform-snapshot.md', SNAPSHOT_NAMES[m.group(1)], int(m.group(2))))
    for m in re.finditer(r'Gateway\s*:(\d{4})', kb_read('architecture/app-fleet.yaml')):
        claims.append(('architecture/app-fleet.yaml', 'api-gateway', int(m.group(1))))
    claude = backend.read('CLAUDE.md') or ''
    for m in re.finditer(r'^\|\s*(tec-[\w-]+?)\s*\|\s*(\d{4})\s*\|', claude, re.M):
        svc = 'api-gateway' if m.group(1) == 'tec-api-gateway' else m.group(1)[4:-8]
        claims.append(('Tec-core-backend/CLAUDE.md', svc, int(m.group(2))))

    documented = {svc for w, svc, _ in claims if w == c20}
    for svc in SERVICES:
        if svc not in documented:
            record(FAIL, 'ports', f'{svc}: missing from the {c20} registry table')

    bad = [(w, s, p) for w, s, p in claims if s in actual and actual[s][0] != p]
    for w, s, p in bad:
        record(FAIL, 'ports', f'{s}: {w} says :{p}, code listens on :{actual[s][0]} ({actual[s][1]})')
    if not bad:
        sources = sorted({w for w, _, _ in claims})
        record(PASS, 'ports', f'{len(actual)} services, {len(claims)} claims in {len(sources)} files all match code')


# ── events ───────────────────────────────────────────────────────────────────────────────

VERSIONED_EVENT = r"['\"`]([a-z_]+\.[a-z_]+(\.[a-z_]+)?\.v[0-9]+)['\"`]"


def check_events(get):
    backend = get('Tec-core-backend')
    if not backend:
        record(SKIP, 'events', 'repo Tec-core-backend not available')
        return
    catalog = yaml.safe_load(kb_read('manifests/events-catalog.yaml'))['events']
    names = {e['name'] for e in catalog}
    for e in catalog:
        if e.get('status') != 'live':
            continue
        owner_dir = e['owner'].split('/')[0]
        literal = r"['\"`]" + re.escape(e['name']) + r"['\"`]"
        if backend.grep(literal, f'{owner_dir}/src'):
            record(PASS, 'events', f"{e['name']} — named in {owner_dir}")
        elif backend.grep(literal, 'shared/src'):
            # the stream name is a shared constant (EVENTS.*) the owner imports
            record(PASS, 'events', f"{e['name']} — shared constant (shared/src), owner {owner_dir}")
        else:
            record(FAIL, 'events', f"{e['name']} is `live` in the catalog but neither its owner {owner_dir} nor shared/ names it")

    in_code = {}
    for f, text in backend.grep(VERSIONED_EVENT, '*.ts'):
        for m in re.finditer(VERSIONED_EVENT, text):
            in_code.setdefault(m.group(1), f)
    for name, f in sorted(in_code.items()):
        if name not in names:
            record(FAIL, 'events', f'{name} is in code ({f}) but not in manifests/events-catalog.yaml')


# ── cookies ──────────────────────────────────────────────────────────────────────────────

LAX = re.compile(r"sameSite\s*:\s*['\"]lax['\"]", re.I)
NONE = re.compile(r"sameSite\s*:\s*['\"]none['\"]", re.I)
PARTITIONED = re.compile(r'partitioned\s*:\s*true')


def check_cookies(get, fleet):
    kb_c13 = kb_read(kb_glob_one('C-13'))
    if 'Partitioned' in kb_c13 and 'SameSite=None' in kb_c13:
        record(PASS, 'cookies', 'C-13 states SameSite=None + Partitioned')
    else:
        record(FAIL, 'cookies', 'C-13 no longer states SameSite=None + Partitioned (C-123 §2)')

    repos = [a['repo'] for a in fleet] + ['tec-template-base']
    checked, missing = 0, []
    for name in repos:
        repo = get(name)
        if not repo:
            missing.append(name)
            continue
        checked += 1
        setters = {}
        for f, text in repo.grep(r'sameSite', '*.ts', '*.tsx'):
            setters.setdefault(f, []).append(text)
        for f, lines in setters.items():
            body = repo.read(f) or ''
            code = '\n'.join(l for l in body.splitlines() if not l.strip().startswith(('//', '*')))
            if LAX.search(code):
                record(FAIL, 'cookies', f"{name}/{f}: sameSite 'lax' — forbidden for session cookies (C-123 LAW 3)")
            elif NONE.search(code) and not PARTITIONED.search(code):
                record(FAIL, 'cookies', f"{name}/{f}: sameSite 'none' without partitioned: true (C-123 §2)")
    if missing:
        record(SKIP, 'cookies', f'not available: {", ".join(missing)}')
    if checked and not any(s == FAIL and c == 'cookies' for s, c, _ in results):
        record(PASS, 'cookies', f'{checked} repos: every sameSite setter is None + Partitioned, none lax')


# ── fleet ────────────────────────────────────────────────────────────────────────────────

APP_SOURCE = re.compile(r"APP_SOURCE\b[^=\n]*=\s*['\"]([a-z0-9-]+)['\"]")


def check_fleet(get, fleet):
    hub = get('Tec-App')
    if not hub:
        record(SKIP, 'fleet', 'repo Tec-App not available')
    else:
        registry = hub.read('tec-frontend/src/domains/_registry.ts') or ''
        allow = hub.read('tec-frontend/src/domains/allowed-origins.ts') or ''
        reg_hosts = set(re.findall(r'https://([a-z0-9-]+\.tecosystem\.app)', registry))
        allow_hosts = set(re.findall(r"'https://([a-z0-9.-]+)'", allow))
        fleet_hosts = {a['domain'] for a in fleet}
        for a in fleet:
            d = a['domain']
            if a['app'] != 'Hub' and d not in reg_hosts:
                record(FAIL, 'fleet', f"{a['app']}: {d} is in app-fleet.yaml but not in the Hub registry (_registry.ts)")
            if d not in allow_hosts:
                record(FAIL, 'fleet', f"{a['app']}: {d} is in app-fleet.yaml but not in the SSO allowlist")
        for d in sorted(reg_hosts - fleet_hosts):
            record(FAIL, 'fleet', f'{d} is in the Hub registry but not in app-fleet.yaml')
        if not any(s == FAIL and c == 'fleet' for s, c, _ in results):
            record(PASS, 'fleet', f'{len(fleet)} apps agree with the Hub registry and the SSO allowlist')

    missing, ok = [], 0
    for a in fleet:
        if a['app'] == 'Hub':
            continue  # the Hub is the payment surface itself — no per-app APP_SOURCE constant
        repo = get(a['repo'])
        if not repo:
            missing.append(a['repo'])
            continue
        # src/lib/app-source.ts is the ONE place the slug is set (tec-template-base checklist)
        m = APP_SOURCE.search(repo.read('src/lib/app-source.ts') or '')
        if not m:
            record(FAIL, 'fleet', f"{a['repo']}: no APP_SOURCE in src/lib/app-source.ts (fleet says '{a['app_source']}')")
        elif m.group(1) == a['app_source']:
            ok += 1
        else:
            record(FAIL, 'fleet', f"{a['repo']}: APP_SOURCE is '{m.group(1)}', app-fleet.yaml says '{a['app_source']}'")
    if missing:
        record(SKIP, 'fleet', f'APP_SOURCE not checked, not available: {", ".join(missing)}')
    if ok:
        record(PASS, 'fleet', f'{ok} apps: APP_SOURCE matches app-fleet.yaml')


# ── SLO (in-KB, but the same failure class: two copies of one number) ────────────────────

SLO_ROWS = {'Auth': 'auth_availability', 'Payments': 'payment_availability', 'Gateway': 'gateway_availability',
            'PAL': 'pal_availability', 'Hub': 'hub_availability'}


def check_slo():
    c78 = kb_glob_one('C-78')
    table = dict(re.findall(r'^\|\s*(Auth|Payments|Gateway|PAL|Hub)\s*\|\s*([\d.]+)%', kb_read(c78), re.M))
    # the manifest is Markdown with the YAML inside a ```yaml fence (audit F15)
    text = kb_read('manifests/slo-definitions.yaml')
    fence = re.search(r'^```yaml\n(.*?)^```', text, re.M | re.S)
    doc = yaml.safe_load(fence.group(1) if fence else text) or {}
    manifest = {s['id']: s['objective'] for s in doc.get('slos', [])}
    for row, sid in SLO_ROWS.items():
        said = table.get(row)
        obj = manifest.get(sid)
        m = re.search(r'([\d.]+)%', str(obj or ''))
        if said is None or m is None:
            record(FAIL, 'slo', f'{row}: missing from {c78} §2 or {sid} missing from slo-definitions.yaml')
        elif float(said) != float(m.group(1)):
            record(FAIL, 'slo', f'{row}: {c78} §2 says {said}%, slo-definitions.yaml {sid} says {obj}')
        else:
            record(PASS, 'slo', f'{row} {said}% — C-78 §2 = manifest')


# ── main ─────────────────────────────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--repos-dir', required=True, help='directory holding clones of the code repos')
    ap.add_argument('--ref', default='HEAD', help='git ref to read in every clone (default HEAD)')
    ap.add_argument('--strict', action='store_true', help='a SKIP (repo not available) also fails')
    ap.add_argument('--summary', help='also write a Markdown report here (e.g. $GITHUB_STEP_SUMMARY)')
    args = ap.parse_args()

    get = open_repos(args.repos_dir, args.ref)
    fleet = yaml.safe_load(kb_read('architecture/app-fleet.yaml'))['apps']

    check_versions(get)
    check_ports(get)
    check_events(get)
    check_cookies(get, fleet)
    check_fleet(get, fleet)
    check_slo()

    icon = {PASS: '✅', FAIL: '❌', SKIP: '⚠️ '}
    print('🔎 TEC — cross-repo drift check (KB ↔ code)')
    print('=' * 44)
    for status, check, detail in results:
        if status != PASS:
            print(f'  {icon[status]} [{check}] {detail}')
    n = {s: sum(1 for r in results if r[0] == s) for s in (PASS, FAIL, SKIP)}
    print(f'\n  {n[PASS]} pass · {n[FAIL]} fail · {n[SKIP]} skip')

    if args.summary:
        with open(args.summary, 'a', encoding='utf-8') as f:
            f.write('## KB ↔ code drift\n\n')
            f.write(f'**{n[PASS]} pass · {n[FAIL]} fail · {n[SKIP]} skip** (ref `{args.ref}`)\n\n')
            f.write('| | Check | Detail |\n|---|---|---|\n')
            order = {FAIL: 0, SKIP: 1, PASS: 2}
            for status, check, detail in sorted(results, key=lambda r: order[r[0]]):
                f.write(f'| {icon[status].strip()} | {check} | {detail.replace("|", "/")} |\n')

    failed = n[FAIL] > 0 or (args.strict and n[SKIP] > 0)
    if failed:
        print('\n  A KB fact no longer matches the code. Fix whichever side is wrong —')
        print('  the code is the evidence, the KB is the claim (C-67).')
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
