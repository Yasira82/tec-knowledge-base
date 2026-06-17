#!/bin/bash
# TEC Knowledge Base — Repository Structure & Manifest Validator
# Ensures plugin.json declarations match what exists on disk and that the
# agents/, commands/, and templates/ directories are present and non-empty.

set -e

PASS=0
FAIL=0

echo "🧱 TEC Knowledge Base — Structure & Manifest Validation"
echo "======================================================="

fail() { echo "  ❌ $1"; FAIL=$((FAIL+1)); }
ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }

# 1) Required directories exist and are non-empty
for DIR in skills agents commands templates knowledge-base evals; do
  if [ -d "$DIR" ] && [ -n "$(ls -A "$DIR" 2>/dev/null)" ]; then
    ok "directory present: $DIR/"
  else
    fail "directory missing or empty: $DIR/"
  fi
done

# 2) plugin.json present and valid JSON
PLUGIN=".claude-plugin/plugin.json"
if [ ! -f "$PLUGIN" ]; then
  fail "$PLUGIN not found"
else
  if command -v python3 >/dev/null 2>&1; then
    if python3 -c "import json,sys; json.load(open('$PLUGIN'))" 2>/dev/null; then
      ok "$PLUGIN is valid JSON"
    else
      fail "$PLUGIN is not valid JSON"
    fi
  fi

  # 3) Declared skills / agents / commands exist on disk
  if command -v python3 >/dev/null 2>&1; then
    MISSING=$(python3 - "$PLUGIN" <<'PY'
import json, os, sys
p = json.load(open(sys.argv[1]))
missing = []

skills = p.get("skills", {})
for group, names in skills.items():
    for name in names:
        # skills are nested by domain group: skills/<group>/<name>/SKILL.md
        path = os.path.join("skills", group, name, "SKILL.md")
        if not os.path.exists(path):
            missing.append("skill:" + path)

for agent in p.get("agents", []):
    if not (os.path.exists(os.path.join("agents", agent + ".md"))
            or os.path.isdir(os.path.join("agents", agent))):
        missing.append("agent:" + agent)

for cmd in p.get("commands", []):
    if not (os.path.exists(os.path.join("commands", cmd + ".md"))
            or os.path.isdir(os.path.join("commands", cmd))):
        missing.append("command:" + cmd)

print("\n".join(missing))
PY
)
    if [ -z "$MISSING" ]; then
      ok "all plugin.json skills/agents/commands resolve on disk"
    else
      while IFS= read -r m; do
        [ -n "$m" ] && fail "declared but missing → $m"
      done <<< "$MISSING"
    fi
  fi
fi

# 4) Every templates/* scaffold directory has at least one file
for T in templates/*/; do
  [ -d "$T" ] || continue
  if [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
    ok "template scaffold present: $T"
  else
    fail "empty template scaffold: $T"
  fi
done

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "❌ Structure validation failed — fix the errors above before merging."
  exit 1
fi

echo "✅ Repository structure & manifest valid!"
