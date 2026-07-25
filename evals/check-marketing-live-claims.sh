#!/bin/bash
# TEC Knowledge Base — Marketing Live-Claim Engine
# =============================================================================
# Turns the "claim-on-verify" honesty rule (C-133 §7, launch-posts.md guard)
# into an ENFORCED build gate. The honesty rule forbids telling the Pi community
# an app is "live" when it isn't actually deployed + reachable. Until now that
# rule lived only as prose a human had to remember. This gate makes it break the
# build.
#
# It is a documentation-truth gate — it does NOT call Pi or any live URL. It
# cross-reads two files that are BOTH in this repo:
#
#   architecture/app-fleet.yaml   ← single source of truth for per-app stage
#                                   (status: live-verified | live-readonly-gated)
#   marketing/*.md                ← the posts we hand people to publish
#
# Rules enforced (any violation = exit 1):
#   R1  OVER-CLAIM   a marketing post says an app is "live" but the fleet
#                    registry does NOT mark that app as deployed-live. This is
#                    the exact honesty violation the guard warns about.
#   R2  GATED-AS-LIVE a `live-readonly-gated` app (FundX pools / Insure escrow /
#                    Brookfield REITs — Invariant-#8 hard-gated) is marketed as a
#                    bare "live" post with no "preview"/gated qualifier. "live"
#                    subscription != live financial mechanics (app-fleet legend).
#   R3  UNKNOWN APP  a marketing post names an app that is not in the fleet
#                    registry at all (typo / stale name / drift).
#
# Under-claiming (an app the fleet says is live, posted as "preview") is ALWAYS
# allowed — being conservative is never an honesty violation.
#
# Authority: knowledge-base/C-133 (Marketing) §7 honesty rule
#            + architecture/app-fleet.yaml (fleet SSoT)
#            + marketing/launch-posts.md (claim-on-verify guard)
#
# Usage: bash evals/check-marketing-live-claims.sh
# Exit:   0 = every marketing live-claim is backed by the fleet SSoT
#         1 = at least one post over-claims (blocking)
# =============================================================================

set -e

echo "📣 TEC — Marketing Live-Claim Engine"
echo "===================================="

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLEET="$ROOT/architecture/app-fleet.yaml"
MKT_DIR="$ROOT/marketing"

if [ ! -f "$FLEET" ]; then
  echo "⚠️  architecture/app-fleet.yaml not found — cannot verify marketing claims."
  echo "    (This gate needs the fleet SSoT. Failing closed.)"
  exit 1
fi

if [ ! -d "$MKT_DIR" ]; then
  echo "ℹ️  No marketing/ directory — nothing to check."
  exit 0
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "⚠️  python3 not available — skipping marketing live-claim check."
  exit 0
fi

python3 - "$FLEET" "$MKT_DIR" <<'PY'
import re, sys, os, glob
import yaml

fleet_path, mkt_dir = sys.argv[1], sys.argv[2]

# ── 1. Load the fleet SSoT → {normalized app name: status} ────────────────────
with open(fleet_path, encoding="utf-8") as f:
    fleet = yaml.safe_load(f)

LIVE_STATUSES   = {"live-verified", "live-readonly-gated"}
GATED_STATUSES  = {"live-readonly-gated"}

def norm(name: str) -> str:
    """Fold an app name to a comparable key: lowercase, strip 'TEC', punctuation."""
    n = name.lower()
    n = re.sub(r"\btec\b", " ", n)          # drop a standalone 'TEC' prefix
    n = re.sub(r"[^a-z0-9]+", "", n)        # keep alnum only (NX, FundX, ...)
    return n

status_by_app = {}
name_by_key   = {}
for rec in (fleet.get("apps") or []):
    app = str(rec.get("app", "")).strip()
    if not app:
        continue
    key = norm(app)
    status_by_app[key] = str(rec.get("status", "")).strip()
    name_by_key[key]   = app

if not status_by_app:
    print("⚠️  app-fleet.yaml has no `apps:` entries — cannot verify. Failing closed.")
    sys.exit(1)

# ── 2. Claim detection ────────────────────────────────────────────────────────
# A block is a PREVIEW claim if it carries any hedge word; otherwise, if it
# asserts "live", it is a LIVE claim. Bilingual (EN + AR).
PREVIEW_MARKERS = ("preview", "معاينة", "simulated", "educational", "coming soon")
LIVE_MARKERS_EN = ("is live on pi", "live on pi")
LIVE_MARKERS_AR = ("شغّال دلوقتي", "شغال دلوقتي")

def classify(block: str):
    """Return 'preview', 'live', or None for a section's text."""
    low = block.lower()
    has_preview = any(m in low for m in PREVIEW_MARKERS) or any(m in block for m in PREVIEW_MARKERS)
    has_live    = any(m in low for m in LIVE_MARKERS_EN) or any(m in block for m in LIVE_MARKERS_AR)
    if has_preview:
        return "preview"
    if has_live:
        return "live"
    return None

def section_app_name(header: str):
    """'### TEC (Hub) — 🔷' → 'Hub' ; '### FundX — 📈 (educational…)' → 'FundX'."""
    h = header.lstrip("#").strip()
    # Prefer an explicit '(Hub)'-style disambiguation in parentheses.
    m = re.search(r"\(([^)]*hub[^)]*)\)", h, re.I)
    if m:
        return "Hub"
    # Otherwise take the text before the first em/en dash or '('.
    core = re.split(r"[—\-(]", h, 1)[0]
    core = re.sub(r"\btec\b", "", core, flags=re.I).strip()
    return core or None

# ── 3. Walk every marketing/*.md, collect (file, app, claim, header) ──────────
SECTION_RE = re.compile(r"^\s*###\s+(.+?)\s*$")
PLACEHOLDER = re.compile(r"\{app\}|\{App\}")   # skip the copy-me template block

records = []       # (file, app_display, claim, raw_header)
for md in sorted(glob.glob(os.path.join(mkt_dir, "*.md"))):
    with open(md, encoding="utf-8") as f:
        lines = f.readlines()
    rel = os.path.relpath(md, os.path.dirname(mkt_dir))
    cur_header, cur_app, buf = None, None, []

    def flush():
        if cur_header and cur_app and buf:
            body = "".join(buf)
            if PLACEHOLDER.search(body):        # template scaffold — not a claim
                return
            claim = classify(body)
            if claim:
                records.append((rel, cur_app, claim, cur_header))

    for ln in lines:
        m = SECTION_RE.match(ln)
        if m:
            flush()
            cur_header = m.group(1)
            cur_app    = section_app_name(cur_header)
            buf = []
        else:
            if cur_header is not None:
                buf.append(ln)
    flush()

if not records:
    print("ℹ️  No per-app marketing claims found (no '### <App>' sections). Nothing to verify.")
    sys.exit(0)

# ── 4. Apply the rules ────────────────────────────────────────────────────────
errors, live_ok, preview_ok = [], 0, 0
for rel, app, claim, header in records:
    key = norm(app or "")
    if key not in status_by_app:
        errors.append(
            f"R3 UNKNOWN  {rel}: post '### {header}' names app '{app}', "
            f"which is not in architecture/app-fleet.yaml (typo or stale name)."
        )
        continue
    status = status_by_app[key]
    canon  = name_by_key[key]
    if claim == "live":
        if status not in LIVE_STATUSES:
            errors.append(
                f"R1 OVER-CLAIM  {rel}: '{canon}' is posted as LIVE but the fleet "
                f"registry status is '{status or '<none>'}' (not deployed-live). "
                f"Flip the post to the preview variant until it is live."
            )
        elif status in GATED_STATUSES:
            errors.append(
                f"R2 GATED-AS-LIVE  {rel}: '{canon}' is '{status}' — its subscription "
                f"is live but its financial mechanics are Invariant-#8 hard-gated. A bare "
                f"'live' post is misleading; use the preview/gated variant (Escrow/pools "
                f"gated), matching app-fleet.yaml's legend."
            )
        else:
            live_ok += 1
    else:
        preview_ok += 1

# ── 5. Report ─────────────────────────────────────────────────────────────────
print(f"  Fleet apps:          {len(status_by_app)}")
print(f"  Marketing claims:    {len(records)}  ({live_ok} live ✓ · {preview_ok} preview)")
print(f"  Cross-read:          architecture/app-fleet.yaml ↔ marketing/*.md")

if errors:
    print(f"\n  ❌ Marketing honesty violations: {len(errors)}")
    for e in errors:
        print(f"     {e}")
    print("\n  → C-133 §7: never tell the Pi community an app is 'live' before the")
    print("    fleet registry marks it live. Fix the post OR the fleet status.")
    sys.exit(1)

print("\n  ✅ Every marketing 'live' claim is backed by app-fleet.yaml.")
print("     (Under-claiming — a live app posted as preview — is always allowed.)")
PY

echo ""
echo "✅ Marketing live-claim check complete."
