#!/bin/bash
# =============================================================================
# TEC SLO Definitions Engine v1.0
# =============================================================================
# Validates manifests/slo-definitions.yaml and closes the SLO-defs ↔ evidence loop.
#
# This is engineering's half of the Observability handoff (EXECUTION_PLAN): the
# SLO targets in C-78 §2, made machine-readable so ops can wire alerts and every
# slo_breach runtime-evidence record references a DEFINED SLO.
#
# Checks:
#   SLO-1  each SLO has required fields (id, title, service, objective, window, binds_to)
#   SLO-2  every binds_to id resolves to an existing C-doc
#   SLO-3  SLO ids are unique
#   SLO-4  every slo_breach runtime-evidence record's `slo` references a defined SLO id
#
# Authority: C-78 · C-96 · manifests/slo-definitions.yaml
# Usage: bash evals/check-slo-definitions.sh   (exit 0 = pass, 1 = violations)
# =============================================================================

set -e

echo "🎯 TEC — SLO Definitions Engine"
echo "==============================="

if ! command -v python3 >/dev/null 2>&1; then
  echo "⚠️  python3 not available — skipping SLO definitions check."
  exit 0
fi

python3 - <<'PY'
import os, re, sys, glob

SLO_FILE = "manifests/slo-definitions.yaml"
KB_DIR = "knowledge-base"
EV_DIR = "runtime-evidence"

if not os.path.exists(SLO_FILE):
    print(f"  ❌ {SLO_FILE} not found")
    sys.exit(1)

# Existing C-doc ids
cdoc_ids = set()
for f in glob.glob(os.path.join(KB_DIR, "C-*.md")):
    m = re.match(r"(C-\d+)", os.path.basename(f))
    if m:
        cdoc_ids.add(m.group(1).upper())

errors = []

# ── Parse the slos: block from the fenced yaml in the manifest ──────────────
# The schema lives inside a ```yaml fence; extract SLO entries robustly.
text = open(SLO_FILE, encoding="utf-8").read()

slos = []          # list of dicts: {id, title, service, objective, window, binds_to:[...]}
cur = None
in_slos = False
for raw in text.splitlines():
    line = raw.rstrip()
    if re.match(r"^\s*slos:\s*$", line):
        in_slos = True
        continue
    if in_slos:
        # a top-level key (no leading space) ends the slos block
        if re.match(r"^[a-zA-Z_]", line):
            in_slos = False
            if cur: slos.append(cur); cur = None
            continue
        m = re.match(r"^\s*-\s*id:\s*(.+)$", line)
        if m:
            if cur: slos.append(cur)
            cur = {"id": m.group(1).strip()}
            continue
        if cur is not None:
            m = re.match(r"^\s*([a-zA-Z_]+):\s*(.+)$", line)
            if m:
                k, v = m.group(1), m.group(2).strip()
                v = re.sub(r'\s+#.*$', '', v).strip()   # strip inline YAML comments
                if k == "binds_to":
                    inner = v.strip("[]").strip()
                    cur[k] = [x.strip().strip('"').strip("'") for x in inner.split(",") if x.strip()]
                else:
                    cur[k] = v.strip().strip('"').strip("'")
if cur: slos.append(cur)

if not slos:
    errors.append(f"{SLO_FILE}: no SLO entries parsed under slos:")

REQUIRED = ["id", "title", "service", "objective", "window", "binds_to"]
seen_ids = {}
defined_ids = set()

for s in slos:
    sid = s.get("id", "<no-id>")
    defined_ids.add(sid)
    # SLO-1 required fields
    for k in REQUIRED:
        if k not in s or s[k] in (None, "", []):
            errors.append(f"SLO '{sid}': missing required field '{k}' (SLO-1)")
    # SLO-3 unique id
    if sid in seen_ids:
        errors.append(f"SLO '{sid}': duplicate id (SLO-3)")
    else:
        seen_ids[sid] = True
    # SLO-2 binds_to resolves
    for cid in s.get("binds_to", []):
        if cid.upper() not in cdoc_ids:
            errors.append(f"SLO '{sid}': binds_to '{cid}' does not resolve to an existing C-doc (SLO-2)")

# ── SLO-4: every slo_breach evidence record references a defined SLO ─────────
breach_checked = 0
if os.path.isdir(EV_DIR):
    for path in glob.glob(os.path.join(EV_DIR, "**", "*.yaml"), recursive=True):
        body = open(path, encoding="utf-8").read()
        kind = re.search(r"^kind:\s*(\S+)", body, re.MULTILINE)
        if not kind or kind.group(1).strip() != "slo_breach":
            continue
        breach_checked += 1
        slo_ref = re.search(r"^slo:\s*(\S+)", body, re.MULTILINE)
        if not slo_ref:
            errors.append(f"{path}: slo_breach record missing `slo` field")
        elif slo_ref.group(1).strip() not in defined_ids:
            errors.append(f"{path}: slo_breach references undefined SLO '{slo_ref.group(1).strip()}' (SLO-4)")

print(f"  SLOs defined:        {len(slos)}")
print(f"  slo_breach records:  {breach_checked} (cross-checked vs defined SLOs)")
for s in slos:
    print(f"    • {s.get('id','?'):<24} {s.get('objective','?'):<12} {s.get('service','?')}")

if errors:
    print(f"\n  ❌ SLO definition violations: {len(errors)}")
    for e in errors:
        print(f"     {e}")
    sys.exit(1)

print("\n  ✅ SLO definitions valid; every slo_breach references a defined SLO.")
PY

echo ""
echo "✅ SLO definitions check complete."
