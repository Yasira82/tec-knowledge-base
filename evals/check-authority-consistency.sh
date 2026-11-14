#!/bin/bash
# TEC Knowledge Base — Authority Hierarchy Consistency CI Gate
# Wrapper around scripts/ahv_engine.py that runs as a CI check.
#
# Authority: C-116 Authority Automation Constitution § 4 (Runtime Enforcement)
# Source:    C-67 Source of Truth Matrix
#
# Usage: bash evals/check-authority-consistency.sh
# Exit:   0 = pass, 1 = violations found

set -e

MANIFEST="manifests/dependency-graph.yaml"

echo "⚖️  TEC Knowledge Base — Authority Hierarchy Consistency"
echo "========================================================"

if [ ! -f "$MANIFEST" ]; then
  echo "❌ CDG manifest not found at $MANIFEST — this check cannot run, so it fails."
  echo "    Generate with: python3 scripts/07_build_cdg.py"
  exit 1
fi

# Run AHV engine; --strict treats warnings as errors
python3 scripts/ahv_engine.py \
  --manifest "$MANIFEST" \
  --format text \
  --severity error \
  --strict

# ahv_engine.py exits 0 (pass) or 1 (fail); we just propagate

# ── One order of authority, written the same way everywhere (KB review, 14 Nov 2026) ──
# Before: CLAUDE.md said C-00 → C-67 → ADRs; C-57 said C-00 → C-47 → C-67 → ADRs in one
# place and C-00 → C-47 → C-64 → C-67 in another; C-67 said C-00 → C-47 → C-64. An agent
# resolving a conflict picked whichever it read first. The order is C-00 → C-47 → ADRs
# (C-64) → C-67; every authority line in these files must keep C-00, C-47, C-64, C-67 in
# that relative order.
python3 - <<'PY'
import re, sys
FILES = ["CLAUDE.md", "CONTRIBUTING.md", "knowledge-base/C-57___MASTER_CONTENTS_INDEX.md",
         "knowledge-base/C-67___SOURCE_OF_TRUTH_MATRIX.md", "architecture/PLATFORM_ARCHITECTURE.md"]
ORDER = ["C-00", "C-47", "C-64", "C-67"]
bad = []
for f in FILES:
    lines = open(f, encoding="utf-8").read().split("\n")
    for i, line in enumerate(lines, 1):
        # An authority chain: starts at C-00 and goes on with arrows to more C-docs/ADRs.
        # A chain of authority names C-67 or the ADRs; a range of document numbers does not.
        if not re.search(r"C-00\s*→", line) or not re.search(r"C-67|ADRs", line):
            continue
        chain = line[line.index("C-00"):]   # the chain itself, not what the line says before it
        seen = [t if t != "ADRs" else "C-64" for t in re.findall(r"C-\d\d(?!\d)|ADRs", chain)]
        seq = []
        for t in seen:
            if t in ORDER and (not seq or seq[-1] != t):
                seq.append(t)
        expect = [t for t in ORDER if t in seq]
        if seq != expect or "C-47" not in seq:
            bad.append(f"{f}:{i}: {line.strip()[:110]}")
if bad:
    print("  ❌ Authority order differs from C-00 → C-47 → ADRs (C-64) → C-67:")
    for b in bad: print("     " + b)
    sys.exit(1)
print(f"  ✅ One authority order across {len(FILES)} files")
PY
