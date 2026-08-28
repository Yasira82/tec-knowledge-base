#!/usr/bin/env python3
"""
RULE 2 enforcement — every C-doc header token must be one .cursorrules defines.

Why this exists
---------------
`check-truth-framework.sh` asks whether Truth State / Governance State /
Verification are PRESENT. It never looked at their values. So `[Unverified]` —
a token RULE 2 does not define — sat in 23 documents for six weeks, was carried
into `architecture/asset-registry.yaml` as `verification_state: unverified`, and
every one of the 18 gates stayed green. Two PRs were opened to fix it in July
and neither was merged; nothing noticed, because nothing was looking.

A rule with no enforcement is a suggestion. This is the enforcement.

Why Python rather than a line in the bash gate
----------------------------------------------
The first attempt was bash. It reported 16 failures across 6 documents that were
all correct: several docs declare the three fields on ONE line —

    > Truth State: [Planned State] | Governance State: [Draft] | Verification: [Assumed]

— and the checker validated every bracketed token on the matched line against
each field's own set. A gate that cries wolf gets ignored, and an ignored gate
is worth no more than the missing one it replaced. Parsing "the token that
follows THIS label" wants a real regex with named groups, not escaped ERE
threaded through two layers of quoting.

Scope
-----
Only the header window (first 40 lines) is read — the same window
`build-asset-registry.py` parses. Prose further down that quotes a token while
describing a past fix is not a violation: C-02 records "all three [Unverified] →
[Assumed]" as history, and rewriting history would be its own kind of drift.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

HEADER_LINES = 40

VALID = {
    'Truth State': {
        'Current State', 'Planned State', 'Future Vision', 'Speculation',
    },
    'Governance State': {
        'Governance Approved', 'ADR Approved', 'Draft', 'Rejected',
    },
    'Verification': {
        'Documentation Verified', 'Code Verified', 'Runtime Verified', 'Assumed',
    },
}

# Label, then optional markdown bold / backticks / whitespace, then the token.
# `Verification` also accepts the older `Verification State:` spelling and
# `Verified:` — build-asset-registry.py accepts all three, so the gate must not
# be stricter than the parser or it would fail documents the registry reads fine.
PATTERNS = {
    'Truth State':      re.compile(r'Truth\s+State\s*:?\**\s*`?\[([^\]]+)\]', re.I),
    'Governance State': re.compile(r'Governance\s+State\s*:?\**\s*`?\[([^\]]+)\]', re.I),
    'Verification':     re.compile(r'Verif(?:ication|ied)(?:\s+State)?\s*:?\**\s*`?\[([^\]]+)\]', re.I),
}


def check(path: Path) -> list[str]:
    problems: list[str] = []
    try:
        lines = path.read_text(encoding='utf-8').split('\n')[:HEADER_LINES]
    except (OSError, UnicodeDecodeError) as exc:
        return [f'{path.name}: unreadable ({exc})']

    header = '\n'.join(lines)
    cid = re.match(r'(C-\d+)', path.name)
    label = cid.group(1) if cid else path.name

    for field, pattern in PATTERNS.items():
        for token in pattern.findall(header):
            token = token.strip()
            # A compound declaration pairs two tokens under one label, e.g. C-90:
            #   [Code Verified] — controls in codebase | [Assumed] — threat classes
            # findall catches only the first per match, and the second is picked
            # up by the next match on the same line, so both get validated.
            if token not in VALID[field]:
                valid = ' | '.join(sorted(VALID[field]))
                problems.append(
                    f'{label} — invalid {field} token [{token}]\n'
                    f'          valid: {valid}'
                )
    return problems


def main() -> int:
    kb = Path('knowledge-base')
    if not kb.is_dir():
        print('❌ knowledge-base/ not found — run from the repo root.')
        return 2

    docs = sorted(kb.glob('C-*.md'))
    if not docs:
        # Finding nothing to check is a failure, not a pass. A checker that
        # examines zero files and exits 0 is the shape of bug this repo keeps
        # finding elsewhere.
        print('❌ No C-*.md documents found — refusing to report success.')
        return 2

    print('🔎 RULE 2 — header token validity')
    print('==================================')

    problems = [p for doc in docs for p in check(doc)]

    print(f'📊 Documents scanned:      {len(docs)}')
    print(f'📊 Invalid header tokens:  {len(problems)}')

    if problems:
        print('')
        for p in problems:
            print(f'  ❌ {p}')
        print('')
        print('❌ FAIL: see .cursorrules RULE 2 for the defined tokens.')
        return 1

    print('')
    print('✅ Every declared token is one RULE 2 defines.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
