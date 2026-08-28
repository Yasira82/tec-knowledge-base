#!/usr/bin/env bash
#
# Run locally EXACTLY what CI runs, before pushing.
#
#     bash scripts/preflight.sh
#
# ── Why this exists ──────────────────────────────────────────────────────────
# A session ran every script in evals/, saw 18 green, pushed — and CI failed.
# The Registry Integrity job does something no eval does: it REGENERATES
# architecture/asset-registry.yaml and diffs it against what was committed
# (C-117 — the registry is auto-generated; editing a C-doc without rebuilding
# it is drift). There was no local command that did this, so a full local run
# reported success without having performed the check that failed.
#
# That is the same defect this repo keeps finding in production systems: a
# check that reports success without having looked. It should not survive in
# our own tooling.
#
# ── The design point ─────────────────────────────────────────────────────────
# The list of checks is PARSED OUT OF THE WORKFLOW, never hardcoded here.
# A hardcoded copy would drift the moment someone adds a gate to CI — and a
# preflight that silently omits a gate is worse than no preflight, because it
# is trusted. If this file and CI ever disagree about what to run, that is a
# bug in this file, so it does not get to hold its own opinion.

set -uo pipefail

cd "$(dirname "$0")/.."

WORKFLOW=".github/workflows/knowledge-ci.yml"
REGISTRY="architecture/asset-registry.yaml"

if [ ! -f "$WORKFLOW" ]; then
  echo "❌ $WORKFLOW not found — cannot mirror CI without it."
  exit 2
fi

failed=()
passed=0

echo "Mirroring $WORKFLOW"
echo

# ── 1. The step that is not an eval ──────────────────────────────────────────
# Regenerate, then compare against HEAD. `-I '^# Generated:'` matches CI: the
# timestamp changes on every run and is not drift.
echo "── Registry rebuild (C-117) ─────────────────────────────"
if python3 scripts/build-asset-registry.py >/dev/null 2>&1; then
  if git diff --quiet -I '^# Generated:' HEAD -- "$REGISTRY"; then
    echo "✅ registry matches the generator"
    passed=$((passed + 1))
  else
    echo "❌ registry is STALE — a C-doc changed and the registry was not rebuilt."
    echo "   It has just been regenerated for you. Commit it alongside the doc:"
    echo
    git diff --stat -I '^# Generated:' HEAD -- "$REGISTRY" | sed 's/^/   /'
    echo
    failed+=("registry-rebuild")
  fi
else
  echo "❌ build-asset-registry.py failed to run (is PyYAML installed?)"
  failed+=("registry-rebuild")
fi
echo

# ── 2. Every eval CI invokes, in workflow order ──────────────────────────────
mapfile -t CHECKS < <(grep -oE 'bash evals/[a-z0-9.-]+\.sh' "$WORKFLOW" | awk '{print $2}' | awk '!seen[$0]++')

if [ ${#CHECKS[@]} -eq 0 ]; then
  echo "❌ Parsed ZERO checks out of the workflow. Refusing to report success —"
  echo "   that would be exactly the failure this script exists to prevent."
  exit 2
fi

echo "── ${#CHECKS[@]} gates ───────────────────────────────────────────"
for check in "${CHECKS[@]}"; do
  name=$(basename "$check" .sh)
  if bash "$check" >/dev/null 2>&1; then
    printf '✅ %s\n' "$name"
    passed=$((passed + 1))
  else
    printf '❌ %s\n' "$name"
    failed+=("$name")
  fi
done

# An eval present in the repo but absent from CI is worth knowing about: it is
# either a gate nobody runs, or a leftover. Reported, never fatal.
for f in evals/*.sh; do
  case " ${CHECKS[*]} " in
    *" $f "*) ;;
    *) echo "⚠️  $(basename "$f" .sh) exists but CI does not run it" ;;
  esac
done

echo
echo "═════════════════════════════════════════════════════════"
if [ ${#failed[@]} -eq 0 ]; then
  echo "✅ $passed/$passed passed — this is what CI will see."
  exit 0
fi
echo "❌ ${#failed[@]} failed: ${failed[*]}"
echo "   ($passed passed)"
exit 1
