#!/bin/bash
# TEC Knowledge Base — RULE 2 header token validity
#
# Thin wrapper so this sits alongside the other gates and is picked up by CI
# and by scripts/preflight.sh. The logic is in Python: parsing "the token that
# follows THIS label" needs a real regex, and the bash attempt produced false
# positives on the documents that declare all three fields on one line.
#
# Authority: .cursorrules RULE 2
# Exit: 0 = pass, 1 = invalid token(s), 2 = could not run

set -e
cd "$(dirname "$0")/.."
exec python3 scripts/check_header_tokens.py
