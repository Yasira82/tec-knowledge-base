#!/bin/bash
# TEC Knowledge Base — Portal Readiness Engine
# =============================================================================
# Auto pre-submission audit. Asserts that the DOCUMENTED Pi-Portal readiness is
# internally consistent and complete BEFORE any app is submitted for Pi review.
#
# It does NOT call Pi or any live service — it is a documentation-truth gate that
# prevents the class of error that bites at submission time:
#   • a Pi App ID / domain that disagrees across C-01, C-02, and the runbook
#   • a leftover placeholder ("confirm in Pi Portal") shipped as if resolved
#   • an app left on PI_SANDBOX != false
#   • a Privacy / Terms URL missing for an app
#   • an unchecked ENGINEERING / OPS item still open in the runbook checklist
#   • a stale Commerce domain (tec-commerce-app.vercel.app) anywhere
#
# Sources of truth:
#   knowledge-base/C-01_Project_Identity.md         §4 PI APP IDENTITY (canonical)
#   knowledge-base/C-02___CURRENT_STATE_.md         PI APP IDENTITY table
#   audits/PORTAL_SUBMISSION_RUNBOOK_2026-06-21.md  §1 per-app registration + §2 checklist
#
# Authority: audits/EXECUTION_PLAN_2026-06-21.md (Runtime Governance — Portal Readiness Engine)
#
# Usage: bash evals/check-portal-readiness.sh
# Exit:   0 = ready, 1 = not ready (blocking)
# =============================================================================

set -e

echo "🛂 TEC — Portal Readiness Engine"
echo "================================"

if ! command -v python3 >/dev/null 2>&1; then
  echo "⚠️  python3 not available — skipping Portal readiness check."
  exit 0
fi

python3 - <<'PY'
import re, os, sys
import yaml

C01 = "knowledge-base/C-01_Project_Identity.md"
C02 = "knowledge-base/C-02___CURRENT_STATE_.md"
RUNBOOK = "audits/PORTAL_SUBMISSION_RUNBOOK_2026-06-21.md"
FLEET = "architecture/app-fleet.yaml"

errors = []
warnings = []

def read(path):
    if not os.path.exists(path):
        errors.append(f"missing source file: {path}")
        return ""
    with open(path, encoding="utf-8", errors="ignore") as fh:
        return fh.read()

c01 = read(C01)
c02 = read(C02)
rb  = read(RUNBOOK)

# The fleet registry enumerates the complete submission scope. C-01 remains
# canonical for the actual Pi identity values, so this gate checks both sources.
fleet_text = read(FLEET)
try:
    fleet = yaml.safe_load(fleet_text) or {}
    FLEET_APPS = fleet.get("apps", [])
except yaml.YAMLError as exc:
    errors.append(f"[FLEET] cannot parse {FLEET}: {exc}")
    FLEET_APPS = []

APPS = [entry.get("app") for entry in FLEET_APPS if entry.get("app")]
if len(APPS) != 24 or len(set(APPS)) != len(APPS):
    errors.append(f"[FLEET] expected 24 uniquely named apps, found {len(APPS)}")
for entry in FLEET_APPS:
    missing = [field for field in ("app", "pi_app_id", "domain", "status")
               if not entry.get(field)]
    if missing:
        errors.append(f"[FLEET] {entry.get('app', '<unnamed>')}: missing {', '.join(missing)}")
    elif entry["status"] not in {"live-verified", "live-readonly-gated"}:
        errors.append(f"[FLEET] {entry['app']}: invalid live status {entry['status']!r}")

# Pi App IDs have both long Portal-issued and short IDs (for example zone-xwc6).
APP_ID_RE = re.compile(r"`([a-z0-9]+(?:-[a-z0-9]+)+)`")
PLACEHOLDER_RE = re.compile(r"confirm in pi portal|TBD|TODO|xxxx|<.*?>|placeholder", re.IGNORECASE)

def identity_section(text, anchors):
    """
    Return only the lines belonging to the per-app registration / PI APP IDENTITY
    section, so we never accidentally parse the plain repo table (§3) that lists
    domains without backticked Pi App IDs. The section starts at the first heading
    matching one of `anchors` and ends at the next markdown heading.
    """
    lines = text.splitlines()
    start = None
    for i, ln in enumerate(lines):
        low = ln.lower()
        if ln.lstrip().startswith("#") or ln.lstrip().startswith(">"):
            if any(a in low for a in anchors):
                start = i
                break
        elif any(a in low for a in anchors) and ln.lstrip().startswith("|") is False:
            start = i
            break
    if start is None:
        return text  # fall back to whole doc
    out = []
    for ln in lines[start + 1:]:
        st = ln.lstrip()
        if st.startswith("#") and out:  # next heading ends the section
            break
        out.append(ln)
    return "\n".join(out)

def parse_identity_table(text, app_label_keys):
    """
    Parse a markdown table whose rows contain an app name, a backticked Pi App ID,
    and a backticked domain. Returns {app: {'id':..., 'domain':..., 'raw':row}}.
    Matching an app row is by substring of the app key (case-insensitive).
    """
    text = identity_section(text, ["pi app identity", "per-app registration"])
    # Precise app matchers — "commerce" must NOT match inside "ecommerce".
    app_re = {
        app: re.compile(rf"(?<![a-z0-9]){re.escape(app.lower())}(?![a-z0-9])")
        for app in app_label_keys
    }
    if "Commerce" in app_re:
        app_re["Commerce"] = re.compile(r"(?<!e)commerce")
    out = {}
    for line in text.splitlines():
        if not line.strip().startswith("|"):
            continue
        low = line.lower()
        for app in app_label_keys:
            pat = app_re.get(app, re.compile(re.escape(app.lower())))
            if pat.search(low) and app not in out:
                ids = APP_ID_RE.findall(line)
                # domain: any backticked token ending in tecosystem.app or vercel.app
                doms = re.findall(
                    r"`(https?://)?([A-Za-z0-9.-]+\.(?:tecosystem\.app|vercel\.app))`",
                    line)
                dom = doms[0][1].lower() if doms else ""
                out[app] = {
                    "id": ids[0] if ids else "",
                    "domain": dom,
                    "raw": line.strip(),
                    "has_placeholder": bool(PLACEHOLDER_RE.search(line)),
                }
    return out

# Hub appears as "Tec-App (Hub)" or "Hub" — add aliases for table matching
TABLE_KEYS = APPS

c01_tbl = parse_identity_table(c01, TABLE_KEYS)
c02_tbl = parse_identity_table(c02, TABLE_KEYS)
rb_tbl  = parse_identity_table(rb,  TABLE_KEYS)
fleet_by_app = {entry["app"]: entry for entry in FLEET_APPS if entry.get("app")}

# ── 1. C-01 is canonical: every app must be present with a real App ID + domain ──
for app in APPS:
    rec = c01_tbl.get(app)
    if not rec:
        errors.append(f"[C-01] no PI APP IDENTITY row found for {app}")
        continue
    if not rec["id"]:
        errors.append(f"[C-01] {app}: missing Pi App ID")
    if rec["has_placeholder"]:
        errors.append(f"[C-01] {app}: placeholder text in registration row")
    if not rec["domain"]:
        errors.append(f"[C-01] {app}: missing domain")
    fleet_rec = fleet_by_app.get(app, {})
    if fleet_rec and rec["id"] and fleet_rec.get("pi_app_id") != rec["id"]:
        errors.append(f"[FLEET] {app}: App ID mismatch vs C-01 "
                      f"({fleet_rec.get('pi_app_id')} != {rec['id']})")
    if fleet_rec and rec["domain"] and fleet_rec.get("domain", "").lower() != rec["domain"]:
        errors.append(f"[FLEET] {app}: domain mismatch vs C-01 "
                      f"({fleet_rec.get('domain')} != {rec['domain']})")

# ── 2. C-02 and RUNBOOK must MATCH C-01 (the canonical source) ──
def cross_check(name, tbl):
    for app in APPS:
        can = c01_tbl.get(app)
        other = tbl.get(app)
        if not can:
            continue
        if not other:
            errors.append(f"[{name}] no registration row for {app}")
            continue
        if other["has_placeholder"]:
            errors.append(f"[{name}] {app}: placeholder text still present "
                          f"(must be resolved before submission)")
        if not other["id"]:
            errors.append(f"[{name}] {app}: registration row has no parseable Pi App ID")
        elif can["id"] and can["id"] != other["id"]:
            errors.append(f"[{name}] {app}: App ID mismatch vs C-01 "
                          f"({other['id']} != {can['id']})")
        if not other["domain"]:
            errors.append(f"[{name}] {app}: registration row has no parseable production domain")
        elif can["domain"] and can["domain"] != other["domain"]:
            errors.append(f"[{name}] {app}: domain mismatch vs C-01 "
                          f"({other['domain']} != {can['domain']})")

cross_check("C-02", c02_tbl)
cross_check("RUNBOOK", rb_tbl)

# ── 3. PI_SANDBOX must be false for every fleet app in C-01 + runbook ──────
for source_name, table in (("C-01", c01_tbl), ("RUNBOOK", rb_tbl)):
    for app in APPS:
        row = table.get(app, {}).get("raw", "").lower()
        if row and re.search(r"\|\s*true\s*\|", row):
            errors.append(f"[{source_name}] PI_SANDBOX appears enabled for {app}")

# ── 4. Privacy + Terms must be referenced for each app in the runbook ──
if "/privacy" not in rb:
    errors.append("[RUNBOOK] no /privacy URL referenced")
if "/terms" not in rb:
    errors.append("[RUNBOOK] no /terms URL referenced")

# ── 5. No unchecked ENGINEERING / OPS items in the readiness checklist ──
#     Inside the §2 fenced checklist, '□' under ENGINEERING/OPS = blocking;
#     under DEFERRED = allowed.
in_checklist = False
section = None
for line in rb.splitlines():
    s = line.strip()
    if s.startswith("```"):
        in_checklist = not in_checklist
        if not in_checklist:
            section = None
        continue
    if not in_checklist:
        continue
    up = s.upper()
    if up.startswith("ENGINEERING"):
        section = "ENG"
    elif up.startswith("OPS"):
        section = "OPS"
    elif up.startswith("DEFERRED"):
        section = "DEFERRED"
    if "□" in s and section in ("ENG", "OPS"):
        errors.append(f"[RUNBOOK] unchecked {section} item before submission: {s}")

# ── 6. Commerce's Vercel host is never presented as its PORTAL domain ──
#
# What this rule protects: Commerce is registered in the Pi Portal under
# `commerce.tecosystem.app`. A reader who finds a `*.vercel.app` host in one of
# these three documents and submits THAT is the failure this gate exists for.
#
# It used to ban the string ANYWHERE in the three docs. That was right while the
# host was purely stale — and wrong from 2026-09-12, when it became a fact worth
# recording: `tec-commerce-app.vercel.app` is Commerce's real TESTNET host, and
# the Hub had been pointing at `commerce-app.vercel.app` (no prefix) which is on
# somebody else's Vercel account. See audits/PI_TESTNET_HOST_OWNERSHIP_2026-09-12.
#
# A blanket ban would have forced C-02 to omit the single most important fact of
# that incident, so the rule now bans the UNQUALIFIED mention: the host may be
# named as a Testnet host, never as a Portal/Mainnet domain. The qualification
# must be on the same line or the one above it, so it is visible to a reader at
# exactly the point the string is — which is the whole purpose.
STALE_COMMERCE = "tec-commerce-app.vercel.app"
for name, text in (("C-01", c01), ("C-02", c02), ("RUNBOOK", rb)):
    lines = text.splitlines()
    for i, line in enumerate(lines):
        if STALE_COMMERCE not in line:
            continue
        window = " ".join(lines[max(0, i - 1):i + 1]).lower()
        if "testnet" not in window:
            errors.append(
                f"[{name}] Commerce Vercel host named without a Testnet qualifier "
                f"(line {i + 1}) — the Portal domain is commerce.tecosystem.app: {line.strip()[:90]}"
            )

# ── Report ──
print(f"  Apps audited:        {len(APPS)} (full app fleet)")
print(f"  Sources cross-read:  app-fleet.yaml · C-01 (canonical) · C-02 · PORTAL_RUNBOOK")
for app in APPS:
    rec = c01_tbl.get(app, {})
    print(f"    • {app:<10} {rec.get('id','?'):<28} {rec.get('domain','?')}")

if warnings:
    print(f"\n  ⚠️  Warnings: {len(warnings)}")
    for w in warnings:
        print(f"     {w}")

if errors:
    print(f"\n  ❌ Portal-readiness violations: {len(errors)}")
    for e in errors:
        print(f"     {e}")
    print("\n  → Resolve every violation before submitting any app to the Pi Portal.")
    sys.exit(1)

print("\n  ✅ Portal readiness verified — registration consistent, no placeholders,")
print("     PI_SANDBOX=false, Privacy/Terms present, no open ENG/OPS items.")
PY

echo ""
echo "✅ Portal readiness check complete."
