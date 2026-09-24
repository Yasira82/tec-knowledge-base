#!/bin/bash
# TEC Knowledge Base — Knowledge Gap Detector
# Checks for missing cross-references between C-documents

set -e

echo "🔍 TEC Knowledge Gap Analysis"
echo "=============================="

KB_DIR="knowledge-base"
GAPS=0

if [ ! -d "$KB_DIR" ]; then
  echo "⚠️  knowledge-base/ directory not found"
  exit 0
fi

# Check that C-57 master index exists
if ! ls "$KB_DIR"/C-57* &>/dev/null; then
  echo "❌ CRITICAL: C-57 Master Contents Index missing!"
  GAPS=$((GAPS+1))
else
  echo "  ✅ C-57 Master Contents Index present"
fi

# Check that C-47 Kernel Spec exists
if ! ls "$KB_DIR"/C-47* &>/dev/null; then
  echo "❌ CRITICAL: C-47 Kernel Spec (Architecture Binding) missing!"
  GAPS=$((GAPS+1))
else
  echo "  ✅ C-47 Kernel Spec present"
fi

# Check that C-00 Platform Constitution exists
if ! ls "$KB_DIR"/C-00* &>/dev/null; then
  echo "❌ CRITICAL: C-00 Platform Constitution missing!"
  GAPS=$((GAPS+1))
else
  echo "  ✅ C-00 Platform Constitution present"
fi

# Check that C-02 Current State exists
if ! ls "$KB_DIR"/C-02* &>/dev/null; then
  echo "❌ CRITICAL: C-02 Current State missing!"
  GAPS=$((GAPS+1))
else
  echo "  ✅ C-02 Current State present"
  # C-02 is current state only, edited in place. It once grew to 5,929 lines because every
  # session appended to it, and stopped answering "where do we stand?" (audit F12). Session
  # narratives go to memory/sessions/. Unlike the gaps above, this one FAILS the gate.
  C02_MAX=150
  C02_LINES=$(wc -l < "$(ls "$KB_DIR"/C-02* | head -1)")
  if [ "$C02_LINES" -gt "$C02_MAX" ]; then
    echo "❌ C-02 is $C02_LINES lines (max $C02_MAX). Move the session narrative to"
    echo "   memory/sessions/session-<id>.md and edit C-02 §1–§3 in place."
    exit 1
  fi
  echo "  ✅ C-02 is $C02_LINES lines (max $C02_MAX)"
fi

# CLAUDE.md is loaded into every session. It grew to 722 lines as an append-only log of
# 18 sessions whose counts were each true only on their own day (audit F16). It is
# navigation + rules now; what a session did goes to memory/sessions/. Also FAILS.
if [ -f CLAUDE.md ]; then
  CLAUDE_LINES=$(wc -l < CLAUDE.md)
  if [ "$CLAUDE_LINES" -gt 150 ]; then
    echo "❌ CLAUDE.md is $CLAUDE_LINES lines (max 150). A session log belongs in"
    echo "   memory/sessions/session-<id>.md; keep CLAUDE.md to navigation and rules."
    exit 1
  fi
  echo "  ✅ CLAUDE.md is $CLAUDE_LINES lines (max 150)"
fi

# Check ADR system
if ! ls "$KB_DIR"/C-64* &>/dev/null; then
  echo "❌ MISSING: C-64 ADR System"
  GAPS=$((GAPS+1))
else
  echo "  ✅ C-64 ADR System present"
fi

# Check domain ownership
if ! ls "$KB_DIR"/C-68* &>/dev/null; then
  echo "⚠️  MISSING: C-68 Domain Ownership Matrix"
  GAPS=$((GAPS+1))
fi

# Count total documents
TOTAL=$(ls "$KB_DIR"/*.md 2>/dev/null | wc -l)
echo ""
echo "📊 Total C-documents: $TOTAL"
echo "📊 Gap count: $GAPS"

if [ $GAPS -gt 0 ]; then
  echo ""
  echo "⚠️  $GAPS knowledge gaps detected. Create missing documents."
  echo "    Use: templates/new-c-document/C-XX-TEMPLATE.md"
fi

echo ""
echo "✅ Knowledge gap check complete."
