#!/bin/bash
# TEC Knowledge Base — Skill Validator
# Validates all SKILL.md files for required structure

set -e

PASS=0
FAIL=0
ERRORS=()

echo "🔍 TEC Knowledge Base — Skill Validation"
echo "=========================================="

# Find all SKILL.md files
SKILL_FILES=$(find skills/ -name "SKILL.md" 2>/dev/null)

if [ -z "$SKILL_FILES" ]; then
  echo "⚠️  No SKILL.md files found in skills/"
  exit 0
fi

for FILE in $SKILL_FILES; do
  ERRORS_IN_FILE=()

  # Check frontmatter exists (must start on line 1)
  if ! head -1 "$FILE" | grep -q "^---"; then
    ERRORS_IN_FILE+=("Missing YAML frontmatter")
    FRONTMATTER=""
  else
    # Extract only the YAML frontmatter block (between the first two '---' lines)
    # so field checks cannot be satisfied by prose in the skill body.
    FRONTMATTER=$(awk 'NR==1 && /^---[[:space:]]*$/ {infm=1; next} infm && /^---[[:space:]]*$/ {exit} infm {print}' "$FILE")
  fi

  # Check required frontmatter fields (scoped to the frontmatter block).
  # 'version:' may be nested under 'metadata:' so we allow leading whitespace.
  for FIELD in "name:" "description:" "version:"; do
    if ! printf '%s\n' "$FRONTMATTER" | grep -Eq "^[[:space:]]*$FIELD"; then
      ERRORS_IN_FILE+=("Missing frontmatter field: $FIELD")
    fi
  done

  # Check description is not empty
  DESC=$(printf '%s\n' "$FRONTMATTER" | grep -E "^[[:space:]]*description:" | head -1 | sed 's/.*description:[[:space:]]*//;s/"//g')
  if [ -z "$DESC" ]; then
    ERRORS_IN_FILE+=("Empty description")
  fi

  # Check file is not empty (> 200 chars)
  SIZE=$(wc -c < "$FILE")
  if [ "$SIZE" -lt 200 ]; then
    ERRORS_IN_FILE+=("Skill file too small (${SIZE} bytes — minimum 200)")
  fi

  # Report
  if [ ${#ERRORS_IN_FILE[@]} -eq 0 ]; then
    echo "  ✅ $FILE"
    PASS=$((PASS+1))
  else
    echo "  ❌ $FILE"
    for ERR in "${ERRORS_IN_FILE[@]}"; do
      echo "     → $ERR"
      ERRORS+=("$FILE: $ERR")
    done
    FAIL=$((FAIL+1))
  fi
done

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ $FAIL -gt 0 ]; then
  echo ""
  echo "❌ Validation failed — fix the errors above before merging."
  exit 1
fi

echo "✅ All skills valid!"
