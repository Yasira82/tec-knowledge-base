#!/bin/bash
# =============================================================================
# TEC Language Policy Engine v1.0
# =============================================================================
# governance/LANGUAGE_POLICY.md §6 promised this gate in June 2026 ("Phase 2"). By the
# 2026-09-24 audit (F18) ~40 documents classified English-only carried 522 lines of Arabic
# prose, and the repository had become public. Those lines were translated; this gate keeps
# it that way.
#
# External documents (English only) = every C-doc EXCEPT the internal ones named below,
# plus README / CONTRIBUTING / SECURITY / CODE_OF_CONDUCT, governance/, architecture/,
# docs/, skills/, agents/, commands/, templates/.
# Internal (Arabic + English mixed allowed): C-02 · C-40 · C-50 · C-55 · C-80 · C-81,
# memory/, audits/. marketing/ is written in the language of its audience.
#
#   LP-1  Arabic in the PROSE of an external document (outside ``` fences) → FAIL.
#         Allowed: the bilingual H2 of §5 — line 2, directly under the English H1.
#   LP-2  Arabic INSIDE code blocks of external documents is a baseline that may only go
#         down (manifests/language-baseline.yaml): a file above its baseline, or a file
#         not in it → FAIL. Below it → pass, with a note to lower the baseline.
#
# Update the baseline after translating code-block text:
#   UPDATE_BASELINE=1 bash evals/check-language-policy.sh
#
# Authority: governance/LANGUAGE_POLICY.md (v1.1)
# Usage: bash evals/check-language-policy.sh   (exit 0 = pass, 1 = violations)
# =============================================================================

set -e

echo "🔤 TEC — Language Policy Engine"
echo "==============================="

if ! command -v python3 >/dev/null 2>&1; then
  echo "⚠️  python3 not available — skipping language policy check."
  exit 0
fi

UPDATE_BASELINE="${UPDATE_BASELINE:-}" python3 - <<'PY'
import glob, os, re, sys

AR = re.compile(r'[؀-ۿ]')
INTERNAL_CDOCS = {2, 40, 50, 55, 80, 81}
BASELINE = 'manifests/language-baseline.yaml'

def external_files():
    out = []
    for f in sorted(glob.glob('knowledge-base/C-*.md')):
        n = int(re.match(r'knowledge-base/C-0*(\d+)', f).group(1))
        if n not in INTERNAL_CDOCS:
            out.append(f)
    out += [f for f in ('README.md', 'CONTRIBUTING.md', 'SECURITY.md', 'CODE_OF_CONDUCT.md') if os.path.exists(f)]
    for d in ('governance', 'architecture', 'docs', 'skills', 'agents', 'commands', 'templates'):
        out += sorted(glob.glob(f'{d}/**/*.md', recursive=True))
    return out

def scan(path):
    prose, code, fence = [], 0, False
    lines = open(path, encoding='utf-8').read().split('\n')
    for i, line in enumerate(lines):
        if line.lstrip().startswith('```'):
            fence = not fence
            continue
        if not AR.search(line):
            continue
        if fence:
            code += 1
        elif i == 1 and line.startswith('## ') and lines[0].startswith('# '):
            continue  # §5 bilingual header
        else:
            prose.append((i + 1, line.strip()[:90]))
    return prose, code

def load_baseline():
    base = {}
    if os.path.exists(BASELINE):
        for line in open(BASELINE, encoding='utf-8'):
            m = re.match(r'^\s*"?([^":#]+?)"?\s*:\s*(\d+)\s*$', line)
            if m:
                base[m.group(1).strip()] = int(m.group(2))
    return base

files = external_files()
results = {f: scan(f) for f in files}

if os.environ.get('UPDATE_BASELINE'):
    with open(BASELINE, 'w', encoding='utf-8') as fh:
        fh.write('# Arabic lines INSIDE code blocks of English-only documents, per file.\n')
        fh.write('# A ratchet: evals/check-language-policy.sh fails if a file goes above its count\n')
        fh.write('# or a file not listed here gains one. Lower it after translating:\n')
        fh.write('#   UPDATE_BASELINE=1 bash evals/check-language-policy.sh\n')
        fh.write('# Authority: governance/LANGUAGE_POLICY.md v1.1 §6 (LP-2)\n')
        for f, (_, code) in results.items():
            if code:
                fh.write(f'"{f}": {code}\n')
    print(f'  ✍️  baseline written: {BASELINE}')

base = load_baseline()
errors, lower = [], []
for f, (prose, code) in results.items():
    for n, text in prose:
        errors.append(f'LP-1 {f}:{n} — Arabic in English-only prose: {text}')
    allowed = base.get(f, 0)
    if code > allowed:
        errors.append(f'LP-2 {f} — {code} Arabic lines in code blocks (baseline {allowed}); translate them, do not add')
    elif code < allowed:
        lower.append(f'{f} ({allowed} → {code})')

total_code = sum(c for _, c in results.values())
print(f'  📄 English-only documents checked: {len(files)}')
print(f'  ✅ Arabic in their prose: {sum(len(p) for p, _ in results.values())}')
print(f'  📉 Arabic inside their code blocks: {total_code} (baseline {sum(base.values())}, may only go down)')
for l in lower:
    print(f'  ℹ️  below baseline — lower it: {l}')
for e in errors:
    print(f'  ❌ {e}')
if errors:
    print(f'\n❌ {len(errors)} language-policy violation(s) — see governance/LANGUAGE_POLICY.md')
    sys.exit(1)
print('\n✅ Language policy holds')
PY
