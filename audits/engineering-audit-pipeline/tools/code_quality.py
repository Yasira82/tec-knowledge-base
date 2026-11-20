#!/usr/bin/env python3
"""P2 — code quality measured on `origin/<ref>`: counts, never impressions.

    python3 code_quality.py --repos-dir /path/with/clones --ref origin/main > code-quality.json

Per repository (and per backend service): silent catch blocks, type escapes (`any`,
`@ts-ignore`, `eslint-disable`), console output left in source, TODO/FIXME markers, files
over 600 lines, and — for backend services — whether request input is validated by a schema
library. Test files are excluded. Each number is reproducible from the ref.
"""
import argparse, json, re, subprocess, sys
from pathlib import Path

SRC = re.compile(r'\.(ts|tsx|js|mjs|cjs)$')
SKIP = re.compile(r'(__tests__/|\.test\.|\.spec\.|/test/|/e2e/|node_modules/|\.d\.ts$|/dist/|\.next/|coverage/|'
                  r'(^|/)(next|vitest|playwright|eslint|jest|postcss|tailwind)\.config\.|/migrations/|k6/)')
PATTERNS = {
    # a catch whose body is empty or only a comment: the failure leaves no trace (C-96)
    'silent_catch': re.compile(r'catch\s*(\([^)]*\))?\s*\{\s*(/\*[^*]*\*/|//[^\n]*)?\s*\}'),
    'any':          re.compile(r':\s*any\b|\bas any\b|<any>'),
    'ts_ignore':    re.compile(r'@ts-(ignore|nocheck|expect-error)'),
    'eslint_off':   re.compile(r'eslint-disable'),
    'console_log':  re.compile(r'\bconsole\.(log|debug)\('),
    'todo':         re.compile(r'\b(TODO|FIXME|HACK|XXX)\b'),
}
VALIDATION = re.compile(r"from ['\"](zod|class-validator)['\"]|ValidationPipe|express-validator|\bz\.object\(")


def files_of(repo, ref):
    out = subprocess.run(['git', '-C', str(repo), 'ls-tree', '-r', '--name-only', ref], capture_output=True, text=True).stdout
    return [f for f in out.split('\n') if SRC.search(f) and not SKIP.search(f)]


def read_all(repo, ref, files):
    p = subprocess.run(['git', '-C', str(repo), 'cat-file', '--batch'],
                       input=''.join(f'{ref}:{f}\n' for f in files).encode(), capture_output=True)
    data, out, i = p.stdout, {}, 0
    for f in files:
        nl = data.index(b'\n', i)
        header = data[i:nl].split()
        size = int(header[2]) if len(header) == 3 else 0
        out[f] = data[nl + 1: nl + 1 + size].decode('utf-8', 'replace')
        i = nl + 1 + size + 1
    return out


def measure(texts):
    m = {k: 0 for k in PATTERNS}
    where = {'silent_catch': []}
    big = []
    for f, t in texts.items():
        for k, rx in PATTERNS.items():
            hits = rx.findall(t)
            m[k] += len(hits)
            if k == 'silent_catch' and hits:
                where['silent_catch'].append(f'{f} ({len(hits)})')
        n = t.count('\n')
        if n > 600:
            big.append({'path': f, 'lines': n})
    m['files'] = len(texts)
    m['lines'] = sum(t.count('\n') for t in texts.values())
    m['files_over_600'] = sorted(big, key=lambda x: -x['lines'])
    m['silent_catch_files'] = where['silent_catch']
    return m


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repos-dir', required=True)
    ap.add_argument('--ref', default='origin/main')
    a = ap.parse_args()
    res = []
    for repo in sorted(p for p in Path(a.repos_dir).iterdir() if (p / '.git').exists()):
        if repo.name.lower() == 'tec-knowledge-base':
            continue
        files = files_of(repo, a.ref)
        texts = read_all(repo, a.ref, files)
        entry = {'repository': repo.name, **measure(texts)}
        if repo.name.lower() == 'tec-core-backend':
            services = sorted({f.split('/')[0] for f in texts if f.startswith('tec-') and '/src/' in f})
            entry['services'] = []
            for s in services:
                st = {f: t for f, t in texts.items() if f.startswith(s + '/src/')}
                v = sorted({m.group(0) for t in st.values() for m in VALIDATION.finditer(t)})
                entry['services'].append({'service': s, **measure(st), 'validation': v})
        res.append(entry)
        print(f"{repo.name}: {entry['files']} files, silent_catch {entry['silent_catch']}, any {entry['any']}", file=sys.stderr)
    json.dump({'ref': a.ref, 'repositories': res}, sys.stdout, indent=2)
    print()


if __name__ == '__main__':
    main()
