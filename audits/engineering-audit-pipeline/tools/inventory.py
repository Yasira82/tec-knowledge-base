#!/usr/bin/env python3
"""P0 — Discovery: an inventory of every TEC repository, read from `origin/<ref>` only.

    python3 inventory.py --repos-dir /path/with/clones --ref origin/main > repository-inventory.json

Reads nothing from a working tree (a checked-out branch is not the state of the code) and
writes nothing anywhere but stdout. Every number in the output is counted from git, so a
later run can be compared with this one. A repository that cannot be read is listed with
`"error"` — never dropped (pipeline rule: a failed check is BLOCKED, not PASSED).
"""
import argparse, json, re, subprocess, sys
from pathlib import Path

CODE = re.compile(r'\.(ts|tsx|js|mjs|cjs|py)$')
TEST = re.compile(r'(__tests__/|\.test\.|\.spec\.|/test/|/e2e/)')
SKIP = re.compile(r'(^|/)(node_modules|dist|\.next|coverage)/|package-lock\.json$|\.d\.ts$')
DEPS = ['next', 'react', '@nestjs/core', 'fastify', 'express', '@prisma/client', 'prisma', 'zod',
        'typescript', 'vitest', 'jest', '@playwright/test', 'ioredis', 'redis', 'socket.io',
        'socket.io-client', 'jose', 'jsonwebtoken', '@sentry/nextjs', '@stellar/stellar-sdk',
        '@yasser172/tec-sdk', '@yasser172/tec-auth', '@yasser172/tec-ui', '@yasser172/tec-shared']


def git(repo, *args):
    return subprocess.run(['git', '-C', str(repo), *args], capture_output=True, text=True, check=True).stdout


def show(repo, ref, path):
    try:
        return git(repo, 'show', f'{ref}:{path}')
    except subprocess.CalledProcessError:
        return None


def deps_of(pkg_text):
    if not pkg_text:
        return {}
    pkg = json.loads(pkg_text)
    all_deps = {**pkg.get('devDependencies', {}), **pkg.get('dependencies', {})}
    return {d: all_deps[d] for d in DEPS if d in all_deps}


def count(repo, ref, files):
    code = [f for f in files if CODE.search(f) and not SKIP.search(f)]
    tests = [f for f in code if TEST.search(f)]
    lines = 0
    if code:
        # one `git cat-file --batch` for every file: fast, and still read from the ref
        p = subprocess.run(['git', '-C', str(repo), 'cat-file', '--batch'],
                           input=''.join(f'{ref}:{f}\n' for f in code).encode(), capture_output=True)
        # each object comes back as a header line + its content + a separator newline
        lines = p.stdout.count(b'\n') - 2 * len(code)
    return {'code_files': len(code), 'test_files': len(tests), 'lines': lines}


def service_entry(repo, ref, name, files):
    pkg = show(repo, ref, f'{name}/package.json')
    d = deps_of(pkg)
    main = show(repo, ref, f'{name}/src/main.ts') or ''
    m = re.search(r'process\.env\.PORT\s*(?:\?\?|\|\|)\s*(\d+)', main)
    mine = [f[len(name) + 1:] for f in files if f.startswith(name + '/')]
    return {
        'name': name,
        'framework': 'nest-fastify' if '@nestjs/platform-fastify' in (pkg or '') else
                     'nest-express' if '@nestjs/core' in d else 'node',
        'default_port': int(m.group(1)) if m else None,
        'port_required': bool(main) and not m and 'PORT' in main,
        'prisma_schema': f'{name}/prisma/schema.prisma' in files,
        'migrations': len({f.split('/')[2] for f in mine if f.startswith('prisma/migrations/') and f.count('/') >= 3}),
        'dockerfile': f'{name}/Dockerfile' in files,
        'migrate_script': f'{name}/scripts/migrate.cjs' in files,
        'dependencies': d,
        **count(repo, ref, [f for f in files if f.startswith(name + '/')]),
    }


def fleet(kb, ref):
    text = show(kb, ref, 'architecture/app-fleet.yaml') or ''
    apps = {m.group(2): {'app': m.group(1), 'domain': m.group(3), 'status': m.group(4)}
            for m in re.finditer(r'app:\s*([\w ]+?),\s*repo:\s*([\w.-]+),\s*domain:\s*([\w.-]+).*?status:\s*([\w-]+)', text)}
    platform = {m.group(2): {'name': m.group(1).strip('"'), 'deploy': m.group(3).strip('"')}
                for m in re.finditer(r'name:\s*("?[^,]+?"?),\s*repo:\s*([\w.-]+),.*?deploy:\s*([^}]+?)\s*}', text)}
    return apps, platform


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repos-dir', required=True)
    ap.add_argument('--ref', default='origin/main')
    a = ap.parse_args()
    root = Path(a.repos_dir)
    kb = next(p for p in root.iterdir() if p.name.lower() == 'tec-knowledge-base')
    apps, platform = fleet(kb, a.ref)
    out = []
    for repo in sorted(p for p in root.iterdir() if (p / '.git').exists()):
        entry = {'repository': repo.name}
        try:
            files = git(repo, 'ls-tree', '-r', '--name-only', a.ref).split('\n')
            files = [f for f in files if f]
            head = git(repo, 'log', '-1', '--format=%H %cs', a.ref).split()
            key = next((k for k in [*apps, *platform] if k.lower() == repo.name.lower()), None)
            entry.update({
                'head': head[0][:12], 'head_date': head[1],
                'role': ('app' if key in apps else 'platform' if key in platform else
                         'knowledge-base' if repo.name.lower() == 'tec-knowledge-base' else 'unlisted'),
                **(apps.get(key) or platform.get(key) or {}),
                'workflows': sorted(f.split('/')[-1] for f in files if f.startswith('.github/workflows/')),
                **count(repo, a.ref, files),
            })
            pkg_path = 'tec-frontend/package.json' if 'tec-frontend/package.json' in files else 'package.json'
            entry['dependencies'] = deps_of(show(repo, a.ref, pkg_path))
            if repo.name.lower() == 'tec-core-backend':
                names = sorted({f.split('/')[0] for f in files if f.count('/') == 1 and f.endswith('/package.json')})
                entry['services'] = [service_entry(repo, a.ref, n, files) for n in names]
        except Exception as e:  # recorded, never dropped
            entry['error'] = str(e).strip()[:300]
        out.append(entry)
    cloned = {e['repository'].lower() for e in out}
    unlisted_fleet = sorted((k for k in [*apps, *platform] if k.lower() not in cloned), key=str.lower)
    json.dump({'ref': a.ref, 'repositories': out,
               'fleet_entries_without_a_clone': unlisted_fleet}, sys.stdout, indent=2)
    print()


if __name__ == '__main__':
    main()
