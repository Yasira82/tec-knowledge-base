#!/bin/bash
# TEC Knowledge Base — Authority Hierarchy Consistency CI Gate
# Wrapper around scripts/ahv_engine.py that runs as a CI check.
#
# Authority: C-116 Authority Automation Constitution § 4 (Runtime Enforcement)
# Source:    C-67 Source of Truth Matrix
#
# Usage: bash evals/check-authority-consistency.sh
# Exit:   0 = pass, 1 = violations found

set -e

MANIFEST="manifests/dependency-graph.yaml"

echo "⚖️  TEC Knowledge Base — Authority Hierarchy Consistency"
echo "========================================================"

if [ ! -f "$MANIFEST" ]; then
  echo "⚠️  CDG manifest not found at $MANIFEST — skipping."
  echo "    Generate with: python3 scripts/07_build_cdg.py"
  exit 0
fi

# Run AHV engine; --strict treats warnings as errors
python3 scripts/ahv_engine.py \
  --manifest "$MANIFEST" \
  --format text \
  --severity error \
  --strict

# ahv_engine.py exits 0 (pass) or 1 (fail); we just propagate
