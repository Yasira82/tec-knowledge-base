#!/bin/bash
# TEC Knowledge Base — Truth Framework Adoption Check
# Reports C-documents missing a Truth State and/or Governance State declaration.
#
# BLOCKING for core constitutional documents (C-00 → C-23, C-47, C-64, C-67).
# INFORMATIONAL for other documents.
#
# Authority: C-116 Authority Automation Constitution § 2 (Mandatory Truth State)
# Source:    TEC_GOVERNANCE_CHARTER_v1.2 § Truth Framework
#
# Usage: bash evals/check-truth-framework.sh
# Exit:   0 = pass, 1 = blocking violations (missing Truth State in core docs)

set -e

KB_DIR="knowledge-base"
MISSING_TRUTH=0
MISSING_GOV=0
BLOCKING_VIOLATIONS=0
TOTAL=0

# Core constitutional documents where Truth State is MANDATORY (blocking)
# Per C-80 § 5.2: C-00, C-01, C-10→C-16, C-20→C-23, C-47, C-64, C-67
is_core_doc() {
  local cid="$1"
  local num=$(echo "$cid" | grep -oE '[0-9]+' | head -1)
  # Base 10, leading zeros dropped: "02" must match 2. Compared as text it did not —
  # C-00, C-01 and C-02 were never checked, and C-02 passed missing its Truth State.
  [ -n "$num" ] || return 1
  num=$((10#$num))
  case "$num" in
    0|1|2)        return 0 ;;   # Constitution + Identity + Current State
    10|11|12|13|14|15|16) return 0 ;;  # Architecture + Rules
    17|18|19)     return 0 ;;   # Compliance + DR + Fraud
    20|21|22|23)  return 0 ;;   # Backend + Apps + SDK
    47)           return 0 ;;   # Kernel Spec
    64)           return 0 ;;   # ADRs
    67)           return 0 ;;   # Source of Truth Matrix
    *)            return 1 ;;
  esac
}

# Self-check: a gate that cannot see its own list passes everything. Fails loudly if
# the numbers with a leading zero — or any core number — stop being recognised.
for must in C-00 C-01 C-02 C-10 C-23 C-47 C-64 C-67; do
  is_core_doc "$must" || { echo "❌ self-check: is_core_doc does not recognise $must — this gate is broken"; exit 2; }
done
for mustnot in C-03 C-24 C-100; do
  ! is_core_doc "$mustnot" || { echo "❌ self-check: is_core_doc wrongly treats $mustnot as core"; exit 2; }
done

echo "🧭 TEC Knowledge Base — Truth Framework Adoption Check"
echo "======================================================"
echo "  Mode: BLOCKING for C-00→C-23, C-47, C-64, C-67"
echo "        INFORMATIONAL for all other documents"
echo ""

if [ ! -d "$KB_DIR" ]; then
  echo "❌ knowledge-base/ directory not found — nothing to check is a failure, not a pass."
  exit 1
fi

for FILE in "$KB_DIR"/C-*.md; do
  [ -f "$FILE" ] || continue
  TOTAL=$((TOTAL+1))

  BASENAME=$(basename "$FILE")
  CID=$(echo "$BASENAME" | grep -oE '^C-[0-9]+' | head -1)
  [ -z "$CID" ] && continue

  HAS_TRUTH=0
  HAS_GOV=0

  if grep -q "Truth State" "$FILE"; then
    HAS_TRUTH=1
  else
    MISSING_TRUTH=$((MISSING_TRUTH+1))
  fi

  if grep -qi "Governance State" "$FILE"; then
    HAS_GOV=1
  else
    MISSING_GOV=$((MISSING_GOV+1))
  fi

  # Blocking check: core docs MUST have Truth State
  if is_core_doc "$CID"; then
    if [ "$HAS_TRUTH" -eq 0 ]; then
      echo "  ❌ BLOCKING: $CID is a core constitutional document but missing Truth State"
      BLOCKING_VIOLATIONS=$((BLOCKING_VIOLATIONS+1))
    elif [ "$HAS_GOV" -eq 0 ]; then
      echo "  ❌ BLOCKING: $CID is a core constitutional document but missing Governance State"
      BLOCKING_VIOLATIONS=$((BLOCKING_VIOLATIONS+1))
    fi
  else
    # Informational for non-core docs
    if [ "$HAS_TRUTH" -eq 0 ]; then
      echo "  ⚠️  Missing Truth State:      $CID"
    fi
    if [ "$HAS_GOV" -eq 0 ]; then
      echo "  ⚠️  Missing Governance State: $CID"
    fi
  fi
done

echo ""
echo "📊 C-documents scanned:        $TOTAL"
echo "📊 Missing Truth State:        $MISSING_TRUTH"
echo "📊 Missing Governance State:   $MISSING_GOV"
echo "📊 Blocking violations:        $BLOCKING_VIOLATIONS"

if [ "$BLOCKING_VIOLATIONS" -gt 0 ]; then
  echo ""
  echo "❌ FAIL: $BLOCKING_VIOLATIONS core document(s) missing Truth State / Governance State."
  echo "   Add the following header to each blocking document:"
  echo "     > **Truth State:** \`[Current State]\`"
  echo "     > **Governance State:** \`[Governance Approved]\`"
  echo "     > **Verification:** \`[Documentation Verified]\`"
  exit 1
fi

echo ""
echo "✅ Truth Framework check passed (core docs OK; informational warnings may exist above)."
exit 0
