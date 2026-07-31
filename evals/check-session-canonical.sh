#!/bin/bash
# TEC Knowledge Base — Session ⟶ Canonical Reference Check (P0 — "Sessions Must Follow")
# =============================================================================
# The last link of the canonical chain:
#
#   PDF → Canonical → Files → Registry (generated) → Sessions/memory/audits (MUST follow)
#
# Session narrative — the working memory (`memory/`) and the audit ledger (`audits/`) —
# is where numbering drift silently leaks in: an agent or human cites a C-number that was
# renumbered, invented, or never created. This gate compares every `C-NN` reference in
# those two surfaces against the CANONICAL C-doc files in knowledge-base/ and fails on any
# reference that does not resolve to a real file.
#
# It is the behavioural complement to check-canonical-numbering.sh (which validates the
# files ⟺ registry ⟺ C-57 index triangle). Together they close the P0 "Single Source of
# Truth" finding from the Engineering Audit.
#
# Every WRITTEN `C-NN` token is validated — including the endpoints of a range such as
# `C-100→C-115` or `C-00 → C-135`. Interior numbers of a range are NOT asserted (a range
# spanning a reserved gap like `C-00 → C-115` does not claim C-3…C-9 exist), so a normal
# range passes while an invented endpoint (`C-100 → C-140`) is correctly flagged.
#
# Authority: C-117 Registry Integrity Constitution + .cursorrules RULE 6
#
# Usage: bash evals/check-session-canonical.sh
# Exit:   0 = pass, 1 = a session/audit reference points at a non-existent C-doc

# NOTE: no `set -e` — this script is arithmetic-heavy (range expansion) and drives
# its own exit status from the ERRORS counter. `set -e` would abort on a benign
# `(( ))` returning non-zero. `set -u` is safe and catches unset-variable typos.
set -uo pipefail

KB_DIR="knowledge-base"
SCAN_DIRS=("memory" "audits")
ERRORS=0
SCANNED=0

echo "🧭 TEC Knowledge Base — Session ⟶ Canonical Reference Check"
echo "==========================================================="

if [ ! -d "$KB_DIR" ]; then
  echo "❌ CRITICAL: $KB_DIR not found"
  exit 1
fi

# ─── Build the canonical ID set (normalised: C-00 == C-0) ────────────────────
CANON=$(ls "$KB_DIR"/C-*.md 2>/dev/null \
  | grep -oE 'C-[0-9]+' \
  | sed 's/^C-0*/C-/; s/^C-$/C-0/' \
  | sort -u)
is_canon() { echo "$CANON" | grep -qx "$1"; }

# ─── Walk each scan surface ──────────────────────────────────────────────────
for dir in "${SCAN_DIRS[@]}"; do
  [ -d "$dir" ] || continue
  while IFS= read -r file; do
    [ -f "$file" ] || continue
    SCANNED=$((SCANNED+1))
    # Line-by-line so we can (a) skip fenced/inline range notation cleanly and
    # (b) report a precise line number for any dangling reference.
    lineno=0
    while IFS= read -r line || [ -n "$line" ]; do
      lineno=$((lineno+1))

      # Validate every C-NN token written on the line (range endpoints included).
      tokens=$(echo "$line" | grep -oE 'C-[0-9]{1,3}' 2>/dev/null \
        | sed 's/^C-0*/C-/; s/^C-$/C-0/' | sort -u)

      for tok in $tokens; do
        [ -z "$tok" ] && continue
        if ! is_canon "$tok"; then
          echo "  ❌ $file:$lineno cites $tok — no such canonical C-doc"
          ERRORS=$((ERRORS+1))
        fi
      done
    done < "$file"
  done < <(find "$dir" -type f -name '*.md' 2>/dev/null | sort)
done

echo ""
echo "📊 Files scanned (memory/ + audits/): $SCANNED"
echo "📊 Dangling references:               $ERRORS"

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "❌ FAIL: a session/audit document cites a C-number with no backing file."
  echo "   Sessions must FOLLOW the canonical files — correct the reference to a real"
  echo "   C-doc, or create the missing document first (see .cursorrules RULE 6)."
  exit 1
fi

echo "✅ Every C-reference in memory/ and audits/ resolves to a canonical C-doc."
exit 0
