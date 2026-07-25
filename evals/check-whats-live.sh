#!/bin/bash
# TEC Knowledge Base — What's-Live Proof-Sheet Engine
# =============================================================================
# The marketing proof sheet (`marketing/whats-live.md`) is the honest, hand-to-a-
# skeptic answer to "is this real?". Because it makes per-app "Live" claims, it
# is only trustworthy if it can never drift from the platform's source of truth.
# This gate binds it to `architecture/app-fleet.yaml` and fails the build on ANY
# drift, so the sheet can't quietly become a lie.
#
# Rules enforced (any violation = exit 1):
#   R1  MISSING     a fleet app is absent from the proof-sheet table.
#   R2  WRONG-STATUS  an app's stated status label does not match its fleet
#                     status (🟢 Live ↔ live-verified · 🟡 Live · core gated ↔
#                     live-readonly-gated).
#   R3  UNKNOWN     the sheet lists an app that is not in the fleet registry.
#
# Authority: architecture/app-fleet.yaml (fleet SSoT) + C-133 §7 (honesty rules).
#
# Usage: bash evals/check-whats-live.sh
# Exit:   0 = proof sheet matches the fleet exactly · 1 = drift (blocking)
# =============================================================================

set -e

echo "🧾 TEC — What's-Live Proof-Sheet Engine"
echo "======================================="

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLEET="$ROOT/architecture/app-fleet.yaml"
SHEET="$ROOT/marketing/whats-live.md"

if [ ! -f "$SHEET" ]; then
  echo "ℹ️  marketing/whats-live.md not found — nothing to check."
  exit 0
fi
if [ ! -f "$FLEET" ]; then
  echo "⚠️  architecture/app-fleet.yaml not found — cannot verify. Failing closed."
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "⚠️  python3 not available — skipping proof-sheet check."
  exit 0
fi

python3 - "$FLEET" "$SHEET" <<'PY'
import re, sys
import yaml

fleet_path, sheet_path = sys.argv[1], sys.argv[2]

with open(fleet_path, encoding="utf-8") as f:
    fleet = yaml.safe_load(f)

def norm(name: str) -> str:
    n = name.lower()
    n = re.sub(r"\btec\b", " ", n)
    n = re.sub(r"[^a-z0-9]+", "", n)
    return n

fleet_status = {}
fleet_name   = {}
for rec in (fleet.get("apps") or []):
    app = str(rec.get("app", "")).strip()
    if not app:
        continue
    fleet_status[norm(app)] = str(rec.get("status", "")).strip()
    fleet_name[norm(app)]   = app

if not fleet_status:
    print("⚠️  app-fleet.yaml has no apps — failing closed.")
    sys.exit(1)

# Marketing status label → fleet status token.
LABEL_TO_STATUS = {
    "live · core gated": "live-readonly-gated",
    "live core gated":   "live-readonly-gated",
    "live":              "live-verified",
}

def resolve_label(cell: str):
    """A table Status cell like '🟡 Live · core gated' → fleet status token."""
    txt = re.sub(r"[^a-z ·]+", "", cell.lower()).strip()   # drop emoji, keep words + ·
    txt = re.sub(r"\s+", " ", txt).strip()
    # longest label first so 'live · core gated' wins over 'live'
    for label in sorted(LABEL_TO_STATUS, key=len, reverse=True):
        if txt.startswith(label):
            return LABEL_TO_STATUS[label]
    return None

# ── Parse the proof-sheet table rows: | App | Status | ... | ... | ──
with open(sheet_path, encoding="utf-8") as f:
    lines = f.readlines()

seen = {}   # norm(app) -> status token
errors = []
for ln in lines:
    if not ln.lstrip().startswith("|"):
        continue
    cells = [c.strip() for c in ln.strip().strip("|").split("|")]
    if len(cells) < 2:
        continue
    app_cell, status_cell = cells[0], cells[1]
    # skip header + separator rows
    if app_cell.lower() in ("app", "") or set(app_cell) <= set("-: "):
        continue
    key = norm(app_cell)
    if not key:
        continue
    status = resolve_label(status_cell)
    if status is None:
        continue   # not a status row (e.g. a legend/example table elsewhere)
    seen[key] = status
    if key not in fleet_status:
        errors.append(f"R3 UNKNOWN  proof sheet lists '{app_cell}', not in app-fleet.yaml.")
    elif fleet_status[key] != status:
        errors.append(
            f"R2 WRONG-STATUS  '{fleet_name[key]}': sheet says '{status_cell}' "
            f"(→ {status}) but the fleet says '{fleet_status[key]}'."
        )

for key, status in fleet_status.items():
    if key not in seen:
        errors.append(
            f"R1 MISSING  '{fleet_name[key]}' ({status}) is in the fleet but absent "
            f"from the proof sheet table."
        )

print(f"  Fleet apps:      {len(fleet_status)}")
print(f"  Sheet rows:      {len(seen)} matched")
print(f"  Cross-read:      architecture/app-fleet.yaml ↔ marketing/whats-live.md")

if errors:
    print(f"\n  ❌ Proof-sheet drift: {len(errors)}")
    for e in errors:
        print(f"     {e}")
    print("\n  → Fix marketing/whats-live.md OR app-fleet.yaml so they agree.")
    sys.exit(1)

print("\n  ✅ Proof sheet matches the fleet registry exactly — every app present,")
print("     every status honest.")
PY

echo ""
echo "✅ What's-Live proof-sheet check complete."
