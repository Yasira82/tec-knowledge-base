#!/bin/bash
# =============================================================================
# TEC KB v9 — Pre-Submission Documentation Fix Patch
# =============================================================================
# Fixes 2 blocking inconsistencies found in Pre-Submission Review:
#   1. Commerce domain mismatch (C-01 vs PORTAL_RUNBOOK)
#   2. Assets Pi App ID placeholder in PORTAL_RUNBOOK
#
# Run from repo root: bash patches/doc-inconsistency-fix.sh
# Total time: ~10 minutes
# =============================================================================

set -euo pipefail

echo "🔧 TEC KB v9 — Pre-Submission Documentation Fix"
echo "================================================"
echo ""

# ─── Preflight ────────────────────────────────────────────────────────
if [ ! -f "knowledge-base/C-01_Project_Identity.md" ]; then
  echo "❌ ERROR: Run from repo root (knowledge-base/ not found)"
  exit 1
fi

if [ ! -f "audits/PORTAL_SUBMISSION_RUNBOOK_2026-06-21.md" ]; then
  echo "❌ ERROR: PORTAL_SUBMISSION_RUNBOOK not found"
  exit 1
fi

echo "✓ Repo structure verified"
echo ""

# ─── FIX 1: Assets Pi App ID placeholder ──────────────────────────────
echo "─── Fix 1: Assets Pi App ID placeholder ────"
echo "C-01 has:        assets-app-af2fb490e7b03db7"
echo "PORTAL_RUNBOOK:  *(confirm in Pi Portal)*  ← placeholder"
echo ""

RUNBOOK="audits/PORTAL_SUBMISSION_RUNBOOK_2026-06-21.md"

# Replace the placeholder with the actual ID from C-01
sed -i 's/| Assets | \*(confirm in Pi Portal)\*/| Assets | `assets-app-af2fb490e7b03db7`/' "$RUNBOOK"

# Verify the fix
if grep -q "assets-app-af2fb490e7b03db7" "$RUNBOOK"; then
  echo "✅ Fixed: Assets Pi App ID now in PORTAL_RUNBOOK"
else
  echo "❌ FAILED: sed replacement did not work"
  exit 1
fi
echo ""

# ─── FIX 2: Commerce domain mismatch ──────────────────────────────────
echo "─── Fix 2: Commerce domain mismatch ────"
echo "C-01 says:           tec-commerce-app.vercel.app"
echo "PORTAL_RUNBOOK says: commerce.tecosystem.app"
echo "C-101 says:          current=vercel.app, target=tecosystem.app"
echo ""
echo "⚠️  DECISION REQUIRED:"
echo "   Which domain is registered in Pi Developer Portal?"
echo "   [1] tec-commerce-app.vercel.app  (old — matches C-01 + C-101 current)"
echo "   [2] commerce.tecosystem.app       (new — matches PORTAL_RUNBOOK + C-101 target)"
echo ""

read -p "   Enter 1 or 2 (check Pi Portal first!): " choice

case "$choice" in
  1)
    COMMERCE_DOMAIN="tec-commerce-app.vercel.app"
    echo ""
    echo "   → Using OLD domain (vercel.app)"
    echo "   → Update PORTAL_RUNBOOK to match C-01"
    ;;
  2)
    COMMERCE_DOMAIN="commerce.tecosystem.app"
    echo ""
    echo "   → Using NEW domain (tecosystem.app)"
    echo "   → Update C-01 + C-101 to match PORTAL_RUNBOOK"
    ;;
  *)
    echo "❌ Invalid choice. Aborting."
    exit 1
    ;;
esac

echo ""

# Apply the domain fix based on choice
if [ "$choice" = "1" ]; then
  # Fix PORTAL_RUNBOOK to use vercel.app domain
  sed -i "s|commerce.tecosystem.app|tec-commerce-app.vercel.app|g" "$RUNBOOK"
  echo "✅ Fixed: PORTAL_RUNBOOK now uses tec-commerce-app.vercel.app"
else
  # Fix C-01 to use tecosystem.app domain
  C01="knowledge-base/C-01_Project_Identity.md"
  sed -i "s|tec-commerce-app.vercel.app|commerce.tecosystem.app|g" "$C01"
  echo "✅ Fixed: C-01 now uses commerce.tecosystem.app"

  # Fix C-101 to use tecosystem.app domain (update "current" to match)
  C101="knowledge-base/C-101___COMMERCE_INSTITUTIONAL_CHARTER.md"
  sed -i "s|tec-commerce-app.vercel.app|commerce.tecosystem.app|g" "$C101"
  sed -i "s|Current domain: commerce.tecosystem.app|Current domain: commerce.tecosystem.app|" "$C101"
  sed -i "s|Target: commerce.tecosystem.app (align with ecosystem)|Domain aligned with ecosystem ✅|" "$C101"
  echo "✅ Fixed: C-101 now uses commerce.tecosystem.app"
fi

echo ""

# ─── Update C-02 with Session 14.5 entry ──────────────────────────────
echo "─── Fix 3: Add Session 14.5 entry to C-02 ────"
C02="knowledge-base/C-02___CURRENT_STATE_.md"

# Add the doc-reconciliation entry after the Session 14 entry
SESSION14_5_ENTRY='| **Session 14.5 — Pre-Submission Doc Reconciliation** | **✅** — Fixed Assets Pi App ID placeholder in PORTAL_RUNBOOK + resolved Commerce domain mismatch across C-01/C-101/RUNBOOK |'

# Find the Session 14 row and insert after it
if grep -q "Session 14 — Payment Unification" "$C02"; then
  # Use sed to insert after the Session 14 line
  sed -i "/Session 14 — Payment Unification/a\\
${SESSION14_5_ENTRY}" "$C02"
  echo "✅ Fixed: C-02 updated with Session 14.5 entry"
else
  echo "⚠️  Warning: Could not find Session 14 entry in C-02 — manual update needed"
fi

echo ""

# ─── Verify CI still passes ───────────────────────────────────────────
echo "─── Verify: Run CI checks ────"
echo "Running check-c57-index.sh..."
if bash evals/check-c57-index.sh 2>&1 | tail -3; then
  echo "✅ C-57 index check passed"
else
  echo "⚠️  C-57 index check failed — review the changes"
fi

echo ""
echo "Running check-truth-framework.sh..."
if bash evals/check-truth-framework.sh 2>&1 | tail -3; then
  echo "✅ Truth Framework check passed"
else
  echo "⚠️  Truth Framework check failed"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  ✅ Documentation fix complete"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff"
echo "  2. Commit: git add -A && git commit -m 'docs: fix Commerce domain + Assets Pi App ID (pre-submission)'"
echo "  3. Push: git push"
echo "  4. Run 30-min smoke test"
echo "  5. Submit to Pi Developer Portal"
echo ""
