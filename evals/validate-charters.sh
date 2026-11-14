#!/bin/bash
# TEC Knowledge Base — App Institutional Charter Validator
# Validates every app charter (C-100→C-115 + the fleet's) for required structure

set -e

PASS=0
FAIL=0
ERRORS=()

echo "🏛️  TEC Knowledge Base — Charter Validation (C-100→C-115 + architecture/app-fleet.yaml)"
echo "============================================================"

KB_DIR="knowledge-base"

# Which documents are app charters is not a list kept here. It was (C-100→C-115), and
# the eight written after it — C-124→C-131 — were never checked (KB review, 14 Nov 2026).
# The set is: the institutional charters C-100→C-115, plus every charter an app in
# architecture/app-fleet.yaml (the one list of apps) names at C-100 or above.
FLEET="architecture/app-fleet.yaml"
[ -f "$FLEET" ] || { echo "❌ $FLEET not found — cannot know which charters to check"; exit 1; }
NUMS=$( { seq 100 115; grep -oE 'charter: C-[0-9]+' "$FLEET" | grep -oE '[0-9]+' | awk '$1>=100'; } | sort -nu )
CHARTERS=()
for n in $NUMS; do
  f=$(ls "$KB_DIR"/C-"$n"___*.md 2>/dev/null | head -1)
  if [ -z "$f" ]; then CHARTERS+=("C-$n (no file)"); else CHARTERS+=("$(basename "$f")"); fi
done
# Known gaps — sections a charter does not have yet, each with why it is not invented here.
# Remove an entry when the section is written.
declare -A KNOWN_GAPS=(
  # Zone's charter (C-120) is the constitutional runtime format: a PREAMBLE, not a Mission
  # section, and no Technical Architecture section (its backend moved from identity-service
  # to trust-service on 2026-10-16; the section must be written from that code, by its owner).
  ["C-120___ZONE_CONSTITUTIONAL_RUNTIME_CHARTER.md"]="Missing Mission section|Missing Technical Architecture section"
)

# Self-check: the list must reach past C-115, or this gate has fallen back to the old one.
[ "${#CHARTERS[@]}" -gt 16 ] || { echo "❌ self-check: only ${#CHARTERS[@]} charters found — the fleet list was not read"; exit 2; }


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
  # The runtime charters (C-120 on) name it "What <App> owns / does not own".
  if ! grep -qi "Authority Boundary\|## Authority\|^## .*WHAT .* OWNS" "$FILE"; then
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
  # The runtime charters track it as "Implementation Status" (or "Deployment Status") + "Build Protocol" / "Build Sequence".
  if ! grep -qi "Engineering\|## Updates Required\|^## Implementation Status\|^## Deployment Status\|^## Build Protocol\|BUILD SEQUENCE" "$FILE"; then
    ERRORS_IN_FILE+=("Missing Engineering Updates / gap tracking")
  fi

  # A known gap is recorded with its reason instead of hidden — and only the sections
  # named for it are forgiven; anything else missing still fails.
  KNOWN="${KNOWN_GAPS[$CHARTER]:-}"
  if [ -n "$KNOWN" ] && [ ${#ERRORS_IN_FILE[@]} -gt 0 ]; then
    REMAINING=()
    for ERR in "${ERRORS_IN_FILE[@]}"; do
      case "|$KNOWN|" in *"|$ERR|"*) echo "  ⚠️  $CHARTER — known gap: $ERR";; *) REMAINING+=("$ERR");; esac
    done
    ERRORS_IN_FILE=("${REMAINING[@]}")
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

echo "✅ All ${#CHARTERS[@]} app charters valid!"
