#!/bin/bash
# TEC Knowledge Base — C-57 Index Drift Prevention
# Compares each C-57 entry's description against the actual file's first H1 heading.
# FAILS the build if any description does not contain a meaningful overlap with the file title.
#
# Authority: C-116 Authority Automation Constitution § 3 (Drift Prevention)
# Source:    C-57 Master Contents Index
#
# Usage: bash evals/check-c57-index.sh
# Exit:   0 = pass, 1 = drift detected

set -e

KB_DIR="knowledge-base"
C57_FILE="$KB_DIR/C-57___MASTER_CONTENTS_INDEX.md"
DRIFT_COUNT=0
NOT_FOUND=0
TOTAL=0

echo "🔍 TEC Knowledge Base — C-57 Index Drift Check"
echo "================================================"

if [ ! -f "$C57_FILE" ]; then
  echo "❌ C-57 Master Contents Index not found at $C57_FILE"
  exit 1
fi

# For each C-NN file, find its row in C-57 (any table format) and verify description overlap
for FILE in "$KB_DIR"/C-*.md; do
  [ -f "$FILE" ] || continue
  BASENAME=$(basename "$FILE")
  CID=$(echo "$BASENAME" | grep -oE '^C-[0-9]+' | head -1)
  [ -z "$CID" ] && continue
  # Skip C-57 itself
  [ "$CID" = "C-57" ] && continue

  TOTAL=$((TOTAL+1))

  # Find the row in C-57 that mentions this CID — extract the description as the LAST cell before trailing |
  # Match: | **C-NN** | cell1 | cell2 | ... | description | (any column count)
  ROW=$(grep -E "\*\*$CID\*\*" "$C57_FILE" | grep -E '^\|' | head -1)
  if [ -z "$ROW" ]; then
    echo "  ⚠️  $CID not found in C-57 index"
    NOT_FOUND=$((NOT_FOUND+1))
    DRIFT_COUNT=$((DRIFT_COUNT+1))
    continue
  fi

  # Extract all cells after the CID cell — description is the LAST non-empty cell
  # Strip leading/trailing |, then split by |, take cells from index 2 onwards
  C57_DESC=$(echo "$ROW" | sed 's/^|//; s/|$//' | awk -F'|' '{
    desc=""
    for (i=3; i<=NF; i++) {
      cell = $i
      gsub(/^ +| +$/, "", cell)
      if (cell != "") desc = cell
    }
    print desc
  }')

  if [ -z "$C57_DESC" ]; then
    echo "  ⚠️  $CID found in C-57 but description cell is empty"
    DRIFT_COUNT=$((DRIFT_COUNT+1))
    continue
  fi

  # Get the actual file's first H1 (strip leading "# ")
  ACTUAL_TITLE=$(grep -m1 '^# ' "$FILE" | sed 's/^# //' | sed 's/^C-[0-9]*\s*[—–-]\s*//')

  # Normalize: lowercase + strip punctuation for fuzzy match
  C57_NORM=$(echo "$C57_DESC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | tr -s ' ')
  ACTUAL_NORM=$(echo "$ACTUAL_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | tr -s ' ')

  if [ -z "$ACTUAL_NORM" ]; then
    echo "  ⚠️  $CID has no H1 in file"
    DRIFT_COUNT=$((DRIFT_COUNT+1))
    continue
  fi

  # Take first 3 significant words from actual title
  WORD1=$(echo "$ACTUAL_NORM" | awk '{print $1}')
  WORD2=$(echo "$ACTUAL_NORM" | awk '{print $2}')
  WORD3=$(echo "$ACTUAL_NORM" | awk '{print $3}')

  # Skip common stop-words
  MATCH_FOUND=0
  for W in "$WORD1" "$WORD2" "$WORD3"; do
    [ -z "$W" ] && continue
    case "$W" in
      the|a|an|of|and|or|to|in|for|on|with|tec|c-|platform) continue ;;
    esac
    if echo "$C57_NORM" | grep -qw "$W"; then
      MATCH_FOUND=1
      break
    fi
  done

  if [ "$MATCH_FOUND" -eq 0 ]; then
    echo "  ❌ $CID: C-57 says \"$C57_DESC\""
    echo "      File says:  \"$ACTUAL_TITLE\""
    DRIFT_COUNT=$((DRIFT_COUNT+1))
  fi
done

echo ""
echo "📊 C-57 entries scanned: $TOTAL"
echo "📊 Not found in index:   $NOT_FOUND"
echo "📊 Drift detected:       $DRIFT_COUNT"

if [ "$DRIFT_COUNT" -gt 0 ]; then
  echo ""
  echo "❌ FAIL: C-57 index drift detected. Update C-57 descriptions to match file titles."
  echo "   Use: python3 scripts/06_fix_c57.py  (auto-correct from file headers)"
  exit 1
fi

echo "✅ C-57 index is consistent with file contents."
exit 0
