#!/bin/bash
# =============================================================================
# TEC Runtime Evidence Engine v1.0
# =============================================================================
# Validates every runtime evidence record in runtime-evidence/**/*.yaml against
# manifests/runtime-evidence-schema.yaml.
#
# This is the Reality→Evidence→Governance half of the Runtime Governance Layer:
# Drift Detection asserts code matches the documented claims; Runtime Evidence
# binds live behavior back to the same claims (C-96 Runtime Evidence obligation).
#
# Checks (binding_rules RE-1..RE-7):
#   RE-1  all required_fields_all present
#   RE-2  kind ∈ {metric, health_snapshot, incident, slo_breach}
#   RE-3  kind-specific required fields present
#   RE-4  source non-empty (attributable — C-96 Incident Evidence Principle)
#   RE-5  every binds_to id resolves to an existing C-doc
#   RE-6  evidence_id unique across runtime-evidence/
#   RE-7  coverage requirements bind broad current-state claims to evidence
#
# If there are no records yet (Portal stage), the gate passes — the schema is the
# ready contract; records begin when the Observability stack emits them.
#
# Authority: C-96 · manifests/runtime-evidence-schema.yaml
# Usage: bash evals/check-runtime-evidence.sh   (exit 0 = pass, 1 = violations)
# =============================================================================

set -e

echo "🧾 TEC — Runtime Evidence Engine"
echo "================================"

if ! command -v python3 >/dev/null 2>&1; then
  echo "⚠️  python3 not available — skipping runtime evidence check."
  exit 0
fi

python3 - <<'PY'
import os, re, sys, glob

EV_DIR = "runtime-evidence"
KB_DIR = "knowledge-base"
COVERAGE = "manifests/runtime-evidence-coverage.yaml"
FLEET = "architecture/app-fleet.yaml"

if not os.path.isdir(EV_DIR):
    print("  No runtime-evidence/ directory — nothing to validate.")
    print("\n✅ Runtime Evidence check complete.")
    sys.exit(0)

# Build the set of existing C-doc ids from the knowledge-base filenames.
cdoc_ids = set()
for f in glob.glob(os.path.join(KB_DIR, "C-*.md")):
    m = re.match(r"(C-\d+)", os.path.basename(f))
    if m:
        cdoc_ids.add(m.group(1).upper())

KINDS = {"metric", "health_snapshot", "incident", "slo_breach"}
REQUIRED_ALL = ["evidence_id", "kind", "timestamp", "source", "binds_to"]
KIND_REQUIRED = {
    "metric": ["name", "value", "unit"],
    "health_snapshot": ["phs", "dimensions"],
    "incident": ["severity", "summary", "status"],
    "slo_breach": ["slo", "observed", "threshold"],
}
SEVERITY = {"P0", "P1", "P2", "P3"}
INC_STATUS = {"open", "mitigated", "resolved"}
EVID_RE = re.compile(r"^ev-\d{4}-\d{2}-\d{2}-\d{3,}$")
ISO_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")

# Prefer PyYAML; fall back to a tiny parser sufficient for these flat records.
def load_yaml(path):
    try:
        import yaml
        with open(path, encoding="utf-8") as fh:
            return yaml.safe_load(fh) or {}
    except ImportError:
        data, cur_list, cur_key = {}, None, None
        with open(path, encoding="utf-8") as fh:
            for raw in fh:
                line = raw.rstrip("\n")
                if not line.strip() or line.strip().startswith("#"):
                    continue
                if re.match(r"^\s+-\s", line) and cur_key:
                    data.setdefault(cur_key, [])
                    if isinstance(data[cur_key], list):
                        data[cur_key].append(line.strip()[1:].strip())
                    continue
                m = re.match(r"^([A-Za-z0-9_]+):\s*(.*)$", line)
                if m:
                    k, v = m.group(1), m.group(2).strip()
                    cur_key = k
                    if v == "" or v == ">" or v == "|":
                        data[k] = ""  # block scalar / nested — treated as present
                    elif v.startswith("["):
                        inner = v.strip("[]").strip()
                        data[k] = [x.strip().strip('"').strip("'") for x in inner.split(",") if x.strip()] if inner else []
                    else:
                        data[k] = v.strip().strip('"').strip("'")
        return data

records = sorted(glob.glob(os.path.join(EV_DIR, "**", "*.yaml"), recursive=True))
records = [r for r in records if os.path.basename(r).lower() != "readme.md"]

if not records:
    print("  No evidence records yet — schema is the ready contract (Portal stage).")
    print("\n✅ Runtime Evidence check complete.")
    sys.exit(0)

errors = []
seen_ids = {}
parsed_records = []

for path in records:
    rel = path
    try:
        rec = load_yaml(path)
    except Exception as e:
        errors.append(f"{rel}: cannot parse YAML ({e})")
        continue
    if not isinstance(rec, dict):
        errors.append(f"{rel}: not a mapping")
        continue
    parsed_records.append((rel, rec))

    # RE-1 required fields
    for k in REQUIRED_ALL:
        if k not in rec or rec[k] in (None, "", []):
            errors.append(f"{rel}: missing required field '{k}' (RE-1)")

    # RE-6 unique id
    eid = rec.get("evidence_id")
    if eid:
        if not EVID_RE.match(str(eid)):
            errors.append(f"{rel}: evidence_id '{eid}' bad format (expect ev-YYYY-MM-DD-NNN)")
        if eid in seen_ids:
            errors.append(f"{rel}: duplicate evidence_id '{eid}' (also in {seen_ids[eid]}) (RE-6)")
        else:
            seen_ids[eid] = rel

    # timestamp format
    ts = rec.get("timestamp")
    if ts and not ISO_RE.match(str(ts)):
        errors.append(f"{rel}: timestamp '{ts}' not ISO-8601 UTC (e.g. 2026-06-21T18:37:21Z)")

    # RE-4 source attributable
    if not str(rec.get("source", "")).strip():
        errors.append(f"{rel}: source empty — evidence must be attributable (RE-4 / C-96)")

    # RE-2 kind
    kind = rec.get("kind")
    if kind not in KINDS:
        errors.append(f"{rel}: kind '{kind}' not one of {sorted(KINDS)} (RE-2)")
    else:
        # RE-3 kind-specific
        for k in KIND_REQUIRED[kind]:
            if k not in rec or rec[k] in (None, "", []):
                errors.append(f"{rel}: kind '{kind}' missing field '{k}' (RE-3)")
        if kind == "incident":
            if str(rec.get("severity")) not in SEVERITY:
                errors.append(f"{rel}: incident severity must be one of {sorted(SEVERITY)}")
            if str(rec.get("status")) not in INC_STATUS:
                errors.append(f"{rel}: incident status must be one of {sorted(INC_STATUS)}")

    # RE-5 binds_to resolves
    binds = rec.get("binds_to")
    if isinstance(binds, str):
        binds = [binds]
    if binds:
        for cid in binds:
            cid_u = str(cid).strip().upper()
            if cid_u not in cdoc_ids:
                errors.append(f"{rel}: binds_to '{cid}' does not resolve to an existing C-doc (RE-5)")

# RE-7: coverage requirements are intentionally separate from per-record schema
# validation. They prevent broad current-state claims from being runtime-labelled
# without at least one attributable, non-example record.
if os.path.exists(COVERAGE):
    try:
        import yaml
        with open(COVERAGE, encoding="utf-8") as fh:
            coverage = yaml.safe_load(fh) or {}
        with open(FLEET, encoding="utf-8") as fh:
            fleet = yaml.safe_load(fh) or {}
    except Exception as exc:
        errors.append(f"{COVERAGE}: cannot load coverage/fleet data ({exc}) (RE-7)")
        coverage, fleet = {}, {}

    fleet_apps = fleet.get("apps", []) if isinstance(fleet, dict) else []
    fleet_by_name = {item.get("app"): item for item in fleet_apps if item.get("app")}
    for requirement in coverage.get("requirements", []):
        req_id = requirement.get("id", "RE-COV-UNKNOWN")
        binding = requirement.get("binds_to_required")
        allowed_kinds = set(requirement.get("allowed_kinds", []))
        candidates = [
            (path, rec) for path, rec in parsed_records
            if not path.startswith(os.path.join(EV_DIR, "examples"))
            and binding in ([rec.get("binds_to")] if isinstance(rec.get("binds_to"), str)
                            else rec.get("binds_to", []))
            and rec.get("kind") in allowed_kinds
        ]
        required_count = int(requirement.get("min_non_example_records", 1))
        if len(candidates) < required_count:
            errors.append(f"{req_id}: requires {required_count} non-example {allowed_kinds} "
                          f"record(s) bound to {binding}; found {len(candidates)}")
            continue
        fleet_binding = requirement.get("fleet_binding")
        if fleet_binding:
            expected_count = int(fleet_binding.get("required_count", 0))
            if len(fleet_by_name) != expected_count:
                errors.append(f"{req_id}: fleet source expected {expected_count} apps, "
                              f"found {len(fleet_by_name)}")
                continue
            evidence_apps = candidates[0][1].get("dimensions", {}).get("apps", [])
            reported_count = candidates[0][1].get("dimensions", {}).get("apps_verified")
            if reported_count != expected_count:
                errors.append(f"{req_id}: apps_verified is {reported_count!r}, "
                              f"expected {expected_count}")
            if len(evidence_apps) != expected_count:
                errors.append(f"{req_id}: evidence lists {len(evidence_apps)} apps, "
                              f"expected {expected_count}")
                continue
            evidence_names = {app.get("app") for app in evidence_apps}
            if evidence_names != set(fleet_by_name):
                errors.append(f"{req_id}: evidence app names do not exactly match fleet")
                continue
            for app in evidence_apps:
                canonical = fleet_by_name.get(app.get("app"))
                if not canonical:
                    errors.append(f"{req_id}: evidence app {app.get('app')!r} is not in fleet")
                    continue
                for field in fleet_binding.get("match_fields", []):
                    if app.get(field) != canonical.get(field):
                        errors.append(f"{req_id}: {app.get('app')} {field} mismatch "
                                      f"({app.get(field)!r} != {canonical.get(field)!r})")

print(f"  Records validated: {len(records)}")
print(f"  C-docs available for binding: {len(cdoc_ids)}")

if errors:
    print(f"\n  ❌ Runtime evidence violations: {len(errors)}")
    for e in errors:
        print(f"     {e}")
    print("\n  → Fix every record against manifests/runtime-evidence-schema.yaml.")
    sys.exit(1)

print("\n  ✅ All runtime evidence records valid (attributable + bound to real C-docs).")
PY

echo ""
echo "✅ Runtime Evidence check complete."
