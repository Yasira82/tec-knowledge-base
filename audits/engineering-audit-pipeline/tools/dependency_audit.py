#!/usr/bin/env python3
"""P3 — known vulnerabilities in production dependencies, from each lock file on `origin/<ref>`.

    python3 dependency_audit.py --repos-dir /path/with/clones --ref origin/main > dependency-audit.json

Each package-lock.json is read from the ref with `git show` into a scratch folder and checked
with `npm audit --package-lock-only --omit=dev` — nothing is installed, no working tree is
read. A lock file npm cannot audit is recorded with its error (BLOCKED), never skipped.
"""
import argparse, json, subprocess, sys, tempfile
from pathlib import Path

SEV = ['critical', 'high', 'moderate', 'low']


def git(repo, *args):
    return subprocess.run(['git', '-C', str(repo), *args], capture_output=True, text=True)


def audit(repo, ref, lock):
    folder = lock.rsplit('/', 1)[0] if '/' in lock else ''
    with tempfile.TemporaryDirectory() as tmp:
        for name in ('package.json', 'package-lock.json'):
            src = f'{folder}/{name}' if folder else name
            r = git(repo, 'show', f'{ref}:{src}')
            if r.returncode:
                return {'lock': lock, 'error': f'cannot read {src}'}
            Path(tmp, name).write_text(r.stdout)
        p = subprocess.run(['npm', 'audit', '--package-lock-only', '--omit=dev', '--json'],
                           cwd=tmp, capture_output=True, text=True, timeout=180)
        try:
            data = json.loads(p.stdout)
        except json.JSONDecodeError:
            return {'lock': lock, 'error': (p.stderr or p.stdout).strip()[:300]}
        if 'error' in data:
            return {'lock': lock, 'error': str(data['error'])[:300]}
        counts = data.get('metadata', {}).get('vulnerabilities', {})
        top = []
        for name, v in sorted(data.get('vulnerabilities', {}).items()):
            if v.get('severity') in ('critical', 'high'):
                via = [x.get('title', '') if isinstance(x, dict) else f'via {x}' for x in v.get('via', [])]
                fix = v.get('fixAvailable')
                top.append({'package': name, 'severity': v['severity'], 'direct': v.get('isDirect', False),
                            'range': v.get('range', ''), 'via': via[:3],
                            'fix': fix if isinstance(fix, bool) else {'name': fix.get('name'), 'version': fix.get('version'),
                                                                      'major': fix.get('isSemVerMajor')}})
        return {'lock': lock, **{s: counts.get(s, 0) for s in SEV}, 'critical_high': top}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repos-dir', required=True)
    ap.add_argument('--ref', default='origin/main')
    a = ap.parse_args()
    out = []
    for repo in sorted(p for p in Path(a.repos_dir).iterdir() if (p / '.git').exists()):
        files = git(repo, 'ls-tree', '-r', '--name-only', a.ref).stdout.split('\n')
        locks = sorted(f for f in files if f.endswith('package-lock.json') and 'node_modules' not in f)
        for lock in locks:
            out.append({'repository': repo.name, **audit(repo, a.ref, lock)})
            print(f"{repo.name} {lock}: {out[-1].get('error') or {s: out[-1][s] for s in SEV}}", file=sys.stderr)
    json.dump({'ref': a.ref, 'results': out}, sys.stdout, indent=2)
    print()


if __name__ == '__main__':
    main()
