#!/bin/bash
# TEC Knowledge Base — Canonical Numbering Enforcement (P0 — Single Source of Truth)
# =============================================================================
# Enforces the canonical-numbering law: the C-NN.md files in knowledge-base/ are
# the CANONICAL source of constitutional IDs. Every other artifact (the
# auto-generated asset-registry.yaml and the C-57 Master Contents Index) MUST
# agree with the files EXACTLY — no invented, renumbered, reused, duplicated, or
# orphaned constitutional IDs.
#
#   files (canonical)  →  asset-registry.yaml (generated)  →  C-57 index
#   every ID must exist in all three, and nowhere else.
#
# This complements two neighbouring gates without overlapping them:
#   • check-registry-integrity.sh — validates the registry against R-* rules.
#   • check-c57-index.sh          — validates C-57 DESCRIPTIONS match file titles.
# This gate validates ID PRESENCE + UNIQUENESS across all three surfaces, which
# is what catches numbering drift (a duplicate/invented/renumbered C-number).
#
# Checks (all blocking except INFO):
#   1. No two files share the same C-number (duplicate ID).
#   2. Every file ID is present in asset-registry.yaml.
#   3. Every registry ID is backed by a file (no orphan/phantom registry entry).
#   4. Every file ID appears in the C-57 Master Contents Index.
#   5. Every C-57-referenced ID is backed by a file (no invented/renumbered ID).
#   6. INFO: report reserved-range gaps (legitimate — not a failure).
#
# Authority: C-117 Registry Integrity Constitution + .cursorrules RULE 6
#            (AI Constitutional Guard — no invent/renumber/reuse/replace of IDs)
#
# Usage: bash evals/check-canonical-numbering.sh
# Exit:   0 = pass, 1 = numbering drift detected

set -euo pipefail

KB_DIR="knowledge-base"
REGISTRY="architecture/asset-registry.yaml"
C57_FILE="$KB_DIR/C-57___MASTER_CONTENTS_INDEX.md"
ERRORS=0

echo "🔢 TEC Knowledge Base — Canonical Numbering Enforcement"
echo "======================================================="

if [ ! -d "$KB_DIR" ]; then
  echo "❌ CRITICAL: $KB_DIR not found"
  exit 1
fi

# ─── Collect the three ID surfaces ───────────────────────────────────────────
# 1) Canonical file IDs (one per C-NN.md). Zero-padding is normalised away so
#    C-00 and C-0 compare equal, matching how the registry/index reference them.
FILE_IDS=$(ls "$KB_DIR"/C-*.md 2>/dev/null \
  | grep -oE 'C-[0-9]+' \
  | sed 's/^C-0*/C-/; s/^C-$/C-0/' \
  | sort -u)

# Raw (un-normalised) file IDs, for duplicate detection on the actual numbers.
RAW_NUMS=$(ls "$KB_DIR"/C-*.md 2>/dev/null | grep -oE 'C-[0-9]+' | sed 's/^C-0*//; s/^$/0/')

REGISTRY_IDS=$(grep -E '^  - id: C-' "$REGISTRY" 2>/dev/null \
  | grep -oE 'C-[0-9]+' \
  | sed 's/^C-0*/C-/; s/^C-$/C-0/' \
  | sort -u)

# C-57 references IDs as **C-NN** in its tables.
C57_IDS=$(grep -oE '\*\*C-[0-9]+\*\*' "$C57_FILE" 2>/dev/null \
  | grep -oE 'C-[0-9]+' \
  | sed 's/^C-0*/C-/; s/^C-$/C-0/' \
  | sort -u)

FILE_COUNT=$(echo "$FILE_IDS" | grep -c '^C-' || true)
echo "  📁 Canonical C-doc files : $FILE_COUNT"
  echo "  📗 Registry entries       : $(echo "$REGISTRY_IDS" | grep -c '^C-' || true)"
echo "  📑 C-57 index references  : $(echo "$C57_IDS" | grep -c '^C-' || true)"
echo ""

# ─── Check 1: no duplicate C-numbers among files ─────────────────────────────
DUPES=$(echo "$RAW_NUMS" | sort -n | uniq -d)
if [ -n "$DUPES" ]; then
  echo "❌ DUPLICATE C-numbers detected (a number is used by >1 file):"
  echo "$DUPES" | while read -r n; do
    [ -z "$n" ] && continue
    echo "     C-$n →"
    ls "$KB_DIR"/C-*.md | grep -E "/C-0*$n[^0-9]" | sed 's/^/         /'
  done
  echo "   → An ID must never be reused. Renumber the newer document to the next"
  echo "     unused integer (see .cursorrules RULE 6)."
  ERRORS=$((ERRORS+1))
else
  echo "  ✅ No duplicate C-numbers among files."
fi

# ─── Check 2: every file ID present in the registry ──────────────────────────
MISSING_IN_REG=$(comm -23 <(echo "$FILE_IDS") <(echo "$REGISTRY_IDS"))
if [ -n "$MISSING_IN_REG" ]; then
  echo "❌ Files missing from $REGISTRY:"
  echo "$MISSING_IN_REG" | sed 's/^/     /'
  echo "   → Run: python3 scripts/build-asset-registry.py"
  ERRORS=$((ERRORS+1))
else
  echo "  ✅ Every C-doc file is registered."
fi

# ─── Check 3: every registry ID backed by a file (no orphan/phantom) ─────────
ORPHAN_REG=$(comm -13 <(echo "$FILE_IDS") <(echo "$REGISTRY_IDS"))
if [ -n "$ORPHAN_REG" ]; then
  echo "❌ Registry entries with NO backing file (orphan / phantom ID):"
  echo "$ORPHAN_REG" | sed 's/^/     /'
  echo "   → Delete the stale entry (rebuild the registry) or restore the file."
  ERRORS=$((ERRORS+1))
else
  echo "  ✅ Every registry entry is backed by a file."
fi

# ─── Check 4: every file ID present in the C-57 index ────────────────────────
MISSING_IN_C57=$(comm -23 <(echo "$FILE_IDS") <(echo "$C57_IDS"))
if [ -n "$MISSING_IN_C57" ]; then
  echo "❌ Files missing from the C-57 Master Contents Index:"
  echo "$MISSING_IN_C57" | sed 's/^/     /'
  echo "   → Add each to $C57_FILE under the correct TIER (see .cursorrules RULE 4)."
  ERRORS=$((ERRORS+1))
else
  echo "  ✅ Every C-doc file appears in the C-57 index."
fi

# ─── Check 5: every C-57 reference backed by a file (no invented/renumbered) ─
PHANTOM_C57=$(comm -13 <(echo "$FILE_IDS") <(echo "$C57_IDS"))
if [ -n "$PHANTOM_C57" ]; then
  echo "❌ C-57 index references IDs with NO backing file (invented / renumbered):"
  echo "$PHANTOM_C57" | sed 's/^/     /'
  echo "   → Remove or correct the stale index reference."
  ERRORS=$((ERRORS+1))
else
  echo "  ✅ Every C-57 index reference is backed by a file."
fi

# ─── Check 6 (INFO): reserved-range gaps ─────────────────────────────────────
# Gaps are legitimate — C-numbers are grouped into reserved domain ranges
# (see CLAUDE.md). Reported for visibility only; NEVER fails the build.
GAPS=$(echo "$RAW_NUMS" | sort -n | uniq | awk '
  NR>1 && $1!=prev+1 { for(i=prev+1;i<$1;i++) printf "C-%s ", i }
  { prev=$1 }')
if [ -n "$GAPS" ]; then
  echo ""
  echo "  ℹ️  Reserved/unused numbers (informational, not drift): $GAPS"
fi

echo ""
echo "📊 Numbering drift errors: $ERRORS"
if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "❌ FAIL: canonical numbering drift detected."
  echo "   The files in knowledge-base/ are the single source of truth for"
  echo "   constitutional IDs. The registry and C-57 index MUST match them exactly."
  exit 1
fi

echo "✅ Canonical numbering is consistent (files ⟺ registry ⟺ C-57 index)."
exit 0
