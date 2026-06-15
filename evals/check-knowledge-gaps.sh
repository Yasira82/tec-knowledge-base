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
  ((GAPS++))
else
  echo "  ✅ C-57 Master Contents Index present"
fi

# Check that C-47 Kernel Spec exists
if ! ls "$KB_DIR"/C-47* &>/dev/null; then
  echo "❌ CRITICAL: C-47 Kernel Spec (Platform Constitution) missing!"
  ((GAPS++))
else
  echo "  ✅ C-47 Platform Constitution present"
fi

# Check that C-02 Current State exists
if ! ls "$KB_DIR"/C-02* &>/dev/null; then
  echo "❌ CRITICAL: C-02 Current State missing!"
  ((GAPS++))
else
  echo "  ✅ C-02 Current State present"
fi

# Check ADR system
if ! ls "$KB_DIR"/C-64* &>/dev/null; then
  echo "❌ MISSING: C-64 ADR System"
  ((GAPS++))
else
  echo "  ✅ C-64 ADR System present"
fi

# Check domain ownership
if ! ls "$KB_DIR"/C-68* &>/dev/null; then
  echo "⚠️  MISSING: C-68 Domain Ownership Matrix"
  ((GAPS++))
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
