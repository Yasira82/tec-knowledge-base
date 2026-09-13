#!/bin/bash
# =============================================================================
# TEC Capability Registry Engine v1.0
# =============================================================================
# Validates manifests/capability-registry.yaml — the canonical machine-readable
# registry of governed capabilities. C-94 GOVERNS capabilities (the lifecycle and
# the certification law); this catalog lists the INSTANCES, and this gate keeps it
# honest. Same split as C-70 ↔ evals/check-events-catalog.sh.
#
# Checks:
#   CAP-1  each capability has required fields
#   CAP-2  every binds_to id resolves to an existing C-doc
#   CAP-3  cap_id values are unique
#   CAP-4  governance_status ∈ meta.lifecycle (the C-94 stages / Prisma enum)
#   CAP-5  owner is a real owning service name (tec-<name>-service) — Invariant #8
#   CAP-6  SINGLE AUTHORITY — every entry's status_source == meta.status_authority,
#          and no entry carries a bare `status` field of its own. This is the check
#          that exists: DX once kept a second `status` beside SYSTEM's and the two
#          diverged in production (tec-core-backend #309).
#   CAP-7  a declared consumer must not store its own status (stores_status: false)
#   CAP-8  rank is unique and contiguous from 0 (display order is deterministic)
#
# Authority: C-94 Governed Capability Constitution · C-110 SYSTEM · C-115 DX
# Usage: bash evals/check-capability-registry.sh   (exit 0 = pass, 1 = violations)
# =============================================================================

set -e

echo "🧩 TEC — Capability Registry Engine"
echo "==================================="

if ! command -v python3 >/dev/null 2>&1; then
  echo "⚠️  python3 not available — skipping capability registry check."
  exit 0
fi

python3 - <<'PY'
import os, re, sys, glob
try:
    import yaml
except Exception:
    print("⚠️  pyyaml not available — skipping.")
    sys.exit(0)

REG    = "manifests/capability-registry.yaml"
KB_DIR = "knowledge-base"

if not os.path.exists(REG):
    print(f"  ❌ {REG} not found")
    sys.exit(1)

cdoc_ids = set()
for f in glob.glob(os.path.join(KB_DIR, "C-*.md")):
    m = re.match(r"(C-\d+)", os.path.basename(f))
    if m:
        cdoc_ids.add(m.group(1).upper())

data = yaml.safe_load(open(REG, encoding="utf-8")) or {}
meta = data.get("meta", {}) or {}
caps = data.get("capabilities", []) or []
consumers = data.get("consumers", []) or []

errors = []

authority = meta.get("status_authority")
lifecycle = set(meta.get("lifecycle") or [])
if not authority:
    errors.append("meta.status_authority is missing — the registry has no single source of truth")
if not lifecycle:
    errors.append("meta.lifecycle is missing — governance_status cannot be validated")

REQUIRED = ["cap_id", "owner", "governance_status", "note",
            "builder_use", "rank", "status_source", "binds_to"]
owner_re = re.compile(r"^tec-[a-z0-9-]+-service$")

seen_ids, ranks = set(), []

for c in caps:
    cid = c.get("cap_id", "<no-cap_id>")

    # CAP-1 required fields
    for k in REQUIRED:
        if k not in c:
            errors.append(f"{cid}: missing required field '{k}'")

    # CAP-3 unique
    if cid in seen_ids:
        errors.append(f"{cid}: duplicate cap_id")
    seen_ids.add(cid)

    # CAP-4 lifecycle stage
    st = c.get("governance_status")
    if lifecycle and st not in lifecycle:
        errors.append(f"{cid}: governance_status '{st}' not in meta.lifecycle {sorted(lifecycle)}")

    # CAP-5 one owning service (C-47 Invariant #8)
    owner = c.get("owner")
    if not (isinstance(owner, str) and owner_re.match(owner)):
        errors.append(f"{cid}: owner '{owner}' is not a tec-<name>-service")

    # CAP-2 binds_to resolves
    binds = c.get("binds_to") or []
    if not binds:
        errors.append(f"{cid}: binds_to must reference at least one C-doc")
    for b in binds:
        if str(b).upper() not in cdoc_ids:
            errors.append(f"{cid}: binds_to '{b}' does not resolve to a C-doc")

    # CAP-6 single authority — the whole point of this gate
    src = c.get("status_source")
    if authority and src != authority:
        errors.append(
            f"{cid}: status_source '{src}' != meta.status_authority '{authority}' "
            f"— a second source of truth for capability status (P2)")
    if "status" in c:
        errors.append(
            f"{cid}: carries a bare 'status' field. Capability status has ONE name, "
            f"'governance_status', and ONE source (meta.status_authority)")

    ranks.append(c.get("rank"))

# CAP-7 consumers present, never store
for con in consumers:
    rt = con.get("runtime", "<no-runtime>")
    if con.get("stores_status") is not False:
        errors.append(
            f"consumer {rt}: stores_status must be false — a consumer PRESENTS the "
            f"registry, it never keeps a copy (C-115 §4)")
    for b in (con.get("binds_to") or []):
        if str(b).upper() not in cdoc_ids:
            errors.append(f"consumer {rt}: binds_to '{b}' does not resolve to a C-doc")

# CAP-8 deterministic display order
if caps:
    if len(set(ranks)) != len(ranks):
        errors.append("rank values are not unique — display order is ambiguous")
    elif sorted(r for r in ranks if isinstance(r, int)) != list(range(len(ranks))):
        errors.append(f"rank values must be contiguous from 0 — got {sorted(ranks, key=str)}")

if errors:
    print(f"  Capabilities: {len(caps)} | Errors: {len(errors)}\n")
    for er in errors:
        print(f"  ❌ {er}")
    print("\n❌ Capability registry check FAILED.")
    sys.exit(1)

certified = sum(1 for c in caps if c.get("governance_status") == "CERTIFIED")
print(f"  Capabilities: {len(caps)} ({certified} certified) | "
      f"Consumers: {len(consumers)} | Errors: 0")
print(f"  Single authority: {authority}")
print("✅ Capability registry check complete.")
PY
