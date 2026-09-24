#!/usr/bin/env python3
"""
Write the generated tables in C-11 (repository map) and C-44 (environment variables)
from the code repos — remediation step 8 (audit F6, F7).

Both documents had been written by hand and had drifted: C-11 listed 9 of 30 repos with
ports from an older scheme; C-44 documented 24 variables while the code reads well over
150, and named three that nothing reads. A hand-kept inventory of a 30-repo platform is
out of date the week it is written, so these tables are now derived from the code.

Only the block between the GENERATED markers is written. The prose around it (roles,
rules, why) stays hand-written. The weekly drift job regenerates the blocks in memory and
fails if they differ from what is committed — so a new variable or repo shows up there
within a week, whoever forgets to run this.

Usage:
  python3 scripts/generate-code-docs.py --repos-dir /home/user --ref origin/main          # write
  python3 scripts/generate-code-docs.py --repos-dir /home/user --ref origin/main --check  # compare only
"""
import argparse
import difflib
import os
import sys

import yaml

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from code_facts import (MissingRepo, extract_block, open_repos,  # noqa: E402
                        render_c11, render_c44, splice_block)

KB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS = {
    'knowledge-base/C-11___REPOSITORY_MAP.md': render_c11,
    'knowledge-base/C-44_Environment_Variables.md': render_c44,
}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--repos-dir', required=True)
    ap.add_argument('--ref', default='HEAD')
    ap.add_argument('--check', action='store_true', help='compare only; exit 1 if a block is stale')
    args = ap.parse_args()

    fleet = yaml.safe_load(open(os.path.join(KB, 'architecture/app-fleet.yaml'), encoding='utf-8'))
    get = open_repos(args.repos_dir, args.ref)
    stale = 0
    for rel, render in DOCS.items():
        path = os.path.join(KB, rel)
        text = open(path, encoding='utf-8').read()
        try:
            block = render(get, fleet)
        except MissingRepo as e:
            print(f'❌ {rel}: repo {e} not available under {args.repos_dir} — cannot generate')
            return 1
        current = extract_block(text)
        if current == block.strip('\n'):
            print(f'✅ {rel}: generated block is current')
            continue
        if args.check:
            stale += 1
            print(f'❌ {rel}: generated block is stale')
            diff = difflib.unified_diff((current or '').splitlines(), block.splitlines(),
                                        'committed', 'from code', lineterm='', n=0)
            print('\n'.join(list(diff)[:40]))
        else:
            open(path, 'w', encoding='utf-8').write(splice_block(text, block))
            print(f'✍️  {rel}: generated block written')
    return 1 if stale else 0


if __name__ == '__main__':
    sys.exit(main())
