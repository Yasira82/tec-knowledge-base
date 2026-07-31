#!/bin/bash
# =============================================================================
# TEC Event Catalog Engine v1.0
# =============================================================================
# Validates manifests/events-catalog.yaml — the canonical machine-readable registry
# of platform events. C-70 GOVERNS events (naming/delivery law); this catalog lists
# the INSTANCES, and this gate keeps the catalog honest.
#
# Checks:
#   EV-1  each event has required fields (name, owner, status, verified, binds_to)
#   EV-2  every binds_to id resolves to an existing C-doc
#   EV-3  event names are unique
#   EV-4  status ∈ {live, planned, deprecated}
#   EV-5  versioned names match domain.action.vN (unversioned allowed only if the
#         note flags it as legacy naming-debt — never silently)
#
# Authority: C-70 Event Governance Spec · manifests/events-catalog.yaml
# Usage: bash evals/check-events-catalog.sh   (exit 0 = pass, 1 = violations)
# =============================================================================

set -e

echo "📡 TEC — Event Catalog Engine"
echo "============================="

if ! command -v python3 >/dev/null 2>&1; then
  echo "⚠️  python3 not available — skipping event catalog check."
  exit 0
fi

python3 - <<'PY'
import os, re, sys, glob
try:
    import yaml
except Exception:
    print("⚠️  pyyaml not available — skipping.")
    sys.exit(0)

CAT = "manifests/events-catalog.yaml"
KB_DIR = "knowledge-base"

if not os.path.exists(CAT):
    print(f"  ❌ {CAT} not found")
    sys.exit(1)

cdoc_ids = set()
for f in glob.glob(os.path.join(KB_DIR, "C-*.md")):
    m = re.match(r"(C-\d+)", os.path.basename(f))
    if m:
        cdoc_ids.add(m.group(1).upper())

data = yaml.safe_load(open(CAT, encoding="utf-8")) or {}
events = data.get("events", []) or []
errors = []
seen = set()
REQUIRED = ["name", "owner", "status", "verified", "binds_to"]
VALID_STATUS = {"live", "planned", "deprecated"}
ver_re = re.compile(r"^[a-z]+(\.[a-z_]+)+\.v[0-9]+$")

for e in events:
    name = e.get("name", "<no-name>")
    # EV-1 required fields
    for k in REQUIRED:
        if k not in e:
            errors.append(f"{name}: missing required field '{k}'")
    # EV-3 unique
    if name in seen:
        errors.append(f"{name}: duplicate event name")
    seen.add(name)
    # EV-4 status
    st = e.get("status")
    if st not in VALID_STATUS:
        errors.append(f"{name}: status '{st}' not in {sorted(VALID_STATUS)}")
    # EV-2 binds_to resolves
    for b in (e.get("binds_to") or []):
        if str(b).upper() not in cdoc_ids:
            errors.append(f"{name}: binds_to '{b}' does not resolve to a C-doc")
    if not (e.get("binds_to") or []):
        errors.append(f"{name}: binds_to must reference at least one C-doc")
    # EV-5 naming (unversioned only if note flags legacy/naming-debt)
    if not ver_re.match(name):
        note = (e.get("note") or "").lower()
        if "legacy" not in note and "naming-debt" not in note:
            errors.append(f"{name}: not domain.action.vN and note does not flag it as legacy naming-debt")

if errors:
    print(f"  Events: {len(events)} | Errors: {len(errors)}\n")
    for er in errors:
        print(f"  ❌ {er}")
    print("\n❌ Event catalog check FAILED.")
    sys.exit(1)

live = sum(1 for e in events if e.get("status") == "live")
planned = sum(1 for e in events if e.get("status") == "planned")
print(f"  Events: {len(events)} ({live} live · {planned} planned) | Errors: 0")
print("✅ Event catalog check complete.")
PY
