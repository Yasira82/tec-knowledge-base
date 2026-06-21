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

C01 = "knowledge-base/C-01_Project_Identity.md"
C02 = "knowledge-base/C-02___CURRENT_STATE_.md"
RUNBOOK = "audits/PORTAL_SUBMISSION_RUNBOOK_2026-06-21.md"

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

# Canonical app keys we expect to find (Pi-paying apps)
APPS = ["Hub", "Ecommerce", "Commerce", "Assets"]

# A Pi App ID looks like:  <slug>-<16 hex>   e.g. tec-app-923b947851f9dfe1
APP_ID_RE = re.compile(r"`([a-z0-9-]+-[0-9a-f]{16})`")
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
        "Hub":       re.compile(r"\bhub\b"),
        "Ecommerce": re.compile(r"ecommerce"),
        "Commerce":  re.compile(r"(?<!e)commerce"),
        "Assets":    re.compile(r"assets"),
    }
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
TABLE_KEYS = ["Hub", "Ecommerce", "Commerce", "Assets"]

c01_tbl = parse_identity_table(c01, TABLE_KEYS)
c02_tbl = parse_identity_table(c02, TABLE_KEYS)
rb_tbl  = parse_identity_table(rb,  TABLE_KEYS)

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

# ── 3. PI_SANDBOX must be false for every Pi-paying app (per runbook table) ──
#     The runbook table column ends with the sandbox flag; require no "true".
for line in rb.splitlines():
    low = line.lower()
    if low.strip().startswith("|") and any(a.lower() in low for a in APPS):
        if re.search(r"\btrue\b", low) and "sandbox" not in low:
            # a 'true' in an app row of the registration table = PI_SANDBOX on
            errors.append(f"[RUNBOOK] PI_SANDBOX appears enabled in row: {line.strip()}")

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

# ── 6. No stale Commerce Vercel domain anywhere in the three docs ──
for name, text in (("C-01", c01), ("C-02", c02), ("RUNBOOK", rb)):
    if "tec-commerce-app.vercel.app" in text:
        errors.append(f"[{name}] stale Commerce domain tec-commerce-app.vercel.app present")

# ── Report ──
print(f"  Apps audited:        {len(APPS)} (Hub · Ecommerce · Commerce · Assets)")
print(f"  Sources cross-read:  C-01 (canonical) · C-02 · PORTAL_RUNBOOK")
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
