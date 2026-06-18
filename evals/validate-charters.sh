#!/bin/bash
# TEC Knowledge Base — App Institutional Charter Validator
# Validates C-100→C-115 charter files for required structure

set -e

PASS=0
FAIL=0
ERRORS=()

echo "🏛️  TEC Knowledge Base — Charter Validation (C-100→C-115)"
echo "============================================================"

# Expected charters
CHARTERS=(
  "C-100___HUB_INSTITUTIONAL_CHARTER.md"
  "C-101___COMMERCE_INSTITUTIONAL_CHARTER.md"
  "C-102___ASSETS_INSTITUTIONAL_CHARTER.md"
  "C-103___ECOMMERCE_INSTITUTIONAL_CHARTER.md"
  "C-104___TEC_AI_INSTITUTIONAL_CHARTER.md"
  "C-105___ANALYTICS_INSTITUTIONAL_CHARTER.md"
  "C-106___LIFE_INSTITUTIONAL_CHARTER.md"
  "C-107___CONNECTION_INSTITUTIONAL_CHARTER.md"
  "C-108___EXPLORER_INSTITUTIONAL_CHARTER.md"
  "C-109___NEXUS_INSTITUTIONAL_CHARTER.md"
  "C-110___SYSTEM_INSTITUTIONAL_CHARTER.md"
  "C-111___ALERT_INSTITUTIONAL_CHARTER.md"
  "C-112___NX_INSTITUTIONAL_CHARTER.md"
  "C-113___FUNDX_INSTITUTIONAL_CHARTER.md"
  "C-114___ESTATE_INSTITUTIONAL_CHARTER.md"
  "C-115___DX_INSTITUTIONAL_CHARTER.md"
)

KB_DIR="knowledge-base"

if [ ! -d "$KB_DIR" ]; then
  echo "❌ knowledge-base/ directory not found"
  exit 1
fi

for CHARTER in "${CHARTERS[@]}"; do
  FILE="$KB_DIR/$CHARTER"
  ERRORS_IN_FILE=()

  # Check file exists
  if [ ! -f "$FILE" ]; then
    echo "  ❌ MISSING: $CHARTER"
    ERRORS+=("$CHARTER: File not found")
    FAIL=$((FAIL+1))
    continue
  fi

  # Check file is not empty (> 500 chars — charters are substantial)
  SIZE=$(wc -c < "$FILE")
  if [ "$SIZE" -lt 500 ]; then
    ERRORS_IN_FILE+=("Charter too small (${SIZE} bytes — minimum 500)")
  fi

  # Check Truth State declared
  if ! grep -q "\[Current State\]\|\[Planned State\]\|\[Future Vision\]\|\[Speculation\]" "$FILE"; then
    ERRORS_IN_FILE+=("Missing Truth State declaration")
  fi

  # Check Mission section present
  if ! grep -qi "## Mission\|## 1\. Mission\|## Mission Statement" "$FILE"; then
    ERRORS_IN_FILE+=("Missing Mission section")
  fi

  # Check Authority Boundary section present
  if ! grep -qi "Authority Boundary\|## Authority" "$FILE"; then
    ERRORS_IN_FILE+=("Missing Authority Boundary section")
  fi

  # Check Technical Architecture section present
  if ! grep -qi "Technical Architecture\|## Architecture" "$FILE"; then
    ERRORS_IN_FILE+=("Missing Technical Architecture section")
  fi

  # Check Security Model present
  if ! grep -qi "Security Model\|## Security\|Auth Pattern\|Authentication" "$FILE"; then
    ERRORS_IN_FILE+=("Missing Security Model section")
  fi

  # Check Engineering Updates present (gap tracking)
  if ! grep -qi "Engineering\|## Updates Required" "$FILE"; then
    ERRORS_IN_FILE+=("Missing Engineering Updates / gap tracking")
  fi

  # Report
  if [ ${#ERRORS_IN_FILE[@]} -eq 0 ]; then
    echo "  ✅ $CHARTER"
    PASS=$((PASS+1))
  else
    echo "  ❌ $CHARTER"
    for ERR in "${ERRORS_IN_FILE[@]}"; do
      echo "     → $ERR"
      ERRORS+=("$CHARTER: $ERR")
    done
    FAIL=$((FAIL+1))
  fi
done

echo ""
echo "Results: $PASS passed, $FAIL failed (out of ${#CHARTERS[@]} expected charters)"

if [ $FAIL -gt 0 ]; then
  echo ""
  echo "❌ Charter validation failed — fix the errors above before merging."
  echo ""
  echo "Charter requirements:"
  echo "  • Truth State declared: [Current State] | [Planned State] | [Future Vision] | [Speculation]"
  echo "  • Mission section: what is this app's economic function?"
  echo "  • Authority Boundary: what does this app own vs consume from platform?"
  echo "  • Technical Architecture: stack, services, integration map"
  echo "  • Security Model: auth pattern + Pi payment mode"
  echo "  • Engineering Updates: P0/P1/P2 gaps with status"
  exit 1
fi

echo "✅ All 16 App Institutional Charters valid!"
