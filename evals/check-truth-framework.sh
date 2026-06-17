#!/bin/bash
# TEC Knowledge Base — Truth Framework Adoption Check
# Reports C-documents missing a Truth State and/or Governance State declaration.
#
# NOTE: This check is INFORMATIONAL by design (always exits 0). Truth State /
# Governance State values require per-document governance judgement, so missing
# declarations are surfaced as warnings rather than injected with a default.

set -e

KB_DIR="knowledge-base"
MISSING_TRUTH=0
MISSING_GOV=0
TOTAL=0

echo "🧭 TEC Knowledge Base — Truth Framework Adoption"
echo "================================================"

if [ ! -d "$KB_DIR" ]; then
  echo "⚠️  knowledge-base/ directory not found — skipping."
  exit 0
fi

for FILE in "$KB_DIR"/C-*.md; do
  [ -f "$FILE" ] || continue
  TOTAL=$((TOTAL+1))

  if ! grep -q "Truth State" "$FILE"; then
    echo "  ⚠️  Missing Truth State:      $FILE"
    MISSING_TRUTH=$((MISSING_TRUTH+1))
  fi

  if ! grep -qi "Governance State" "$FILE"; then
    echo "  ⚠️  Missing Governance State: $FILE"
    MISSING_GOV=$((MISSING_GOV+1))
  fi
done

echo ""
echo "📊 C-documents scanned:        $TOTAL"
echo "📊 Missing Truth State:        $MISSING_TRUTH"
echo "📊 Missing Governance State:   $MISSING_GOV"

if [ "$MISSING_TRUTH" -gt 0 ] || [ "$MISSING_GOV" -gt 0 ]; then
  echo ""
  echo "ℹ️  Add to the document header where appropriate:"
  echo "    > **Truth State:** [Current State] | [Planned State] | [Future Vision] | [Speculation]"
  echo "    > **Governance State:** [ADR Approved] | [Governance Approved] | [Draft] | [Rejected]"
fi

echo ""
echo "✅ Truth Framework check complete (informational)."
