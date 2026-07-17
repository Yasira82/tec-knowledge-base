#!/usr/bin/env bash
# =============================================================================
# TEC Registry Integrity Engine v2.0
# =============================================================================
# The Institutional Linter — validates architecture/asset-registry.yaml
# against architecture/registry-integrity-rules.yaml
#
# v2.0 additions:
#   - R-SEMANTIC-001: institutional_role MUST match file H1 (fuzzy word overlap)
#   - R-SEMANTIC-002: authoritative_for claims SHOULD appear in file content
#   - R-COVERAGE-001: ALL C-docs MUST be registered (100% coverage)
#   - R-COVERAGE-002: No orphan registry entries
#   - Fixed: unbound variable bug from v1.0
#   - Fixed: empty fields in generated report
#
# This is a BLOCKING check. Exit code 0 = clean, 1 = violations found.
#
# Usage:
#   bash evals/check-registry-integrity.sh
#   bash evals/check-registry-integrity.sh --verbose
#   bash evals/check-registry-integrity.sh --json
# =============================================================================

set -uo pipefail

# --- Setup ----------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REGISTRY="${REPO_ROOT}/architecture/asset-registry.yaml"
RULES="${REPO_ROOT}/architecture/registry-integrity-rules.yaml"
REPORT="${REPO_ROOT}/architecture/registry-integrity-report.md"
REPORT_JSON="${REPO_ROOT}/architecture/registry-integrity-report.json"

VERBOSE=0
JSON_OUTPUT=0
for arg in "$@"; do
  case "$arg" in
    --verbose|-v) VERBOSE=1 ;;
    --json) JSON_OUTPUT=1 ;;
    --help|-h)
      echo "Usage: $0 [--verbose] [--json]"
      exit 0
      ;;
  esac
done

# --- Preflight checks -----------------------------------------------------
if [ ! -f "$REGISTRY" ]; then
  echo "ERROR: Registry not found at $REGISTRY"
  exit 1
fi

if [ ! -f "$RULES" ]; then
  echo "ERROR: Rules not found at $RULES"
  exit 1
fi

# --- Python availability check --------------------------------------------
if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required for YAML parsing"
  exit 1
fi

if ! python3 -c "import yaml" 2>/dev/null; then
  echo "ERROR: PyYAML not installed. Run: pip install pyyaml"
  exit 1
fi

# --- Run the integrity engine --------------------------------------------
# Note: passing paths via argv (not env) to avoid set -u issues
REGISTRY_PATH="$REGISTRY" \
RULES_PATH="$RULES" \
REPORT_PATH="$REPORT" \
REPORT_JSON_PATH="$REPORT_JSON" \
REPO_ROOT="${REPO_ROOT}" \
VERBOSE="${VERBOSE}" \
JSON_OUTPUT="${JSON_OUTPUT}" \
python3 <<'PYEOF'
import sys
import os
import yaml
import json
import re
from datetime import datetime, date
from pathlib import Path

# Read env vars (with fallback defaults)
REGISTRY_PATH = os.environ.get("REGISTRY_PATH", "")
RULES_PATH = os.environ.get("RULES_PATH", "")
REPORT_PATH = os.environ.get("REPORT_PATH", "")
REPORT_JSON_PATH = os.environ.get("REPORT_JSON_PATH", "")
REPO_ROOT = os.environ.get("REPO_ROOT", ".")
VERBOSE = int(os.environ.get("VERBOSE", "0"))
JSON_OUTPUT = int(os.environ.get("JSON_OUTPUT", "0"))

errors = []
warnings = []
info = []
asset_results = {}

# --- Load registry & rules -----------------------------------------------
try:
    with open(REGISTRY_PATH) as f:
        registry = yaml.safe_load(f)
    with open(RULES_PATH) as f:
        rules = yaml.safe_load(f)
except Exception as e:
    print(f"FATAL: Cannot parse YAML: {e}", file=sys.stderr)
    sys.exit(2)

assets = registry.get("assets", [])
schema_rules = rules.get("schema_rules", [])
structural = rules.get("structural_rules", [])
governance = rules.get("governance_rules", [])
lifecycle = rules.get("lifecycle_rules", [])
audit = rules.get("audit_rules", [])

# --- Helpers --------------------------------------------------------------
def add_error(asset_id, rule_id, msg):
    errors.append({"asset": asset_id, "rule": rule_id, "message": msg})

def add_warning(asset_id, rule_id, msg):
    warnings.append({"asset": asset_id, "rule": rule_id, "message": msg})

def add_info(asset_id, rule_id, msg):
    info.append({"asset": asset_id, "rule": rule_id, "message": msg})

def log(asset_id, msg):
    if VERBOSE:
        print(f"  [{asset_id}] {msg}")

def get_file_h1(path):
    """Extract first H1 from a markdown file."""
    full_path = os.path.join(REPO_ROOT, path)
    if not os.path.exists(full_path):
        return ""
    try:
        with open(full_path, encoding='utf-8', errors='ignore') as f:
            for line in f:
                line = line.strip()
                if line.startswith('# '):
                    return line[2:].strip()
    except Exception:
        pass
    return ""

def get_file_content(path, max_lines=100):
    """Get first N lines of a file."""
    full_path = os.path.join(REPO_ROOT, path)
    if not os.path.exists(full_path):
        return ""
    try:
        with open(full_path, encoding='utf-8', errors='ignore') as f:
            return ''.join(f.readline() for _ in range(max_lines)).lower()
    except Exception:
        return ""

STOP_WORDS = {'the', 'a', 'an', 'of', 'and', 'or', 'to', 'in', 'for', 'on', 'with',
              'tec', 'c-', 'platform', 'v1', 'v2', 'v3', 'constitution', 'charter',
              'constitutional', 'v1.0', 'v1.2', 'v2.0', 'v3.0', 'v3.4', 'v3.5', 'v3.6'}

def get_significant_words(text, min_len=3):
    """Extract significant lowercase words from text, excluding stop words."""
    if not text:
        return set()
    # Normalize: lowercase, strip punctuation
    text = text.lower()
    text = re.sub(r'[^a-z0-9 ]', ' ', text)
    words = set()
    for w in text.split():
        if len(w) >= min_len and w not in STOP_WORDS:
            words.add(w)
    return words

# =============================================================================
# R-SCHEMA — schema validation
# =============================================================================
required_fields = ["id", "type", "tier", "institutional_role", "constitutional",
                   "owner", "authoritative_for", "depends_on", "supersedes",
                   "superseded_by", "last_verified"]

for asset in assets:
    aid = asset.get("id", "<unknown>")
    asset_results[aid] = {"errors": 0, "warnings": 0, "info": 0}

    for f in required_fields:
        if f not in asset:
            add_error(aid, "R-SCHEMA-001", f"Missing required field: {f}")

    ts = asset.get("constitutional", {}).get("truth_state")
    if ts and ts not in ["idea", "speculation", "future-vision", "planned-state", "current-state", "deprecated"]:
        add_error(aid, "R-SCHEMA-002", f"Invalid truth_state: {ts}")

    gs = asset.get("constitutional", {}).get("governance_state")
    if gs and gs not in ["draft", "governance-approved", "adr-approved", "documentation-verified", "rejected"]:
        add_error(aid, "R-SCHEMA-003", f"Invalid governance_state: {gs}")

    vs = asset.get("constitutional", {}).get("verification_state")
    if vs and vs not in ["unverified", "documentation-verified", "code-verified", "runtime-verified", "assumed"]:
        add_error(aid, "R-SCHEMA-004", f"Invalid verification_state: {vs}")

    tier = asset.get("tier")
    valid_tiers = ["tier-0-foundational", "tier-1-constitutional-runtime",
                   "tier-1-institutional-intelligence", "tier-2-experimental"]
    if tier and tier not in valid_tiers:
        add_error(aid, "R-SCHEMA-005", f"Invalid tier: {tier}")

    path = asset.get("path", "")
    if path and not path.startswith("ALL"):
        full_path = os.path.join(REPO_ROOT, path.split("#")[0])
        if not os.path.exists(full_path):
            add_error(aid, "R-SCHEMA-006", f"Path does not exist: {path}")

    scope = asset.get("constitutional", {}).get("authority_scope")
    if scope and scope not in ["platform", "domain", "app", "service", "constitutional", "experimental"]:
        add_error(aid, "R-SCHEMA-007", f"Invalid authority_scope: {scope}")

# =============================================================================
# R-SEMANTIC — semantic accuracy (NEW in v2.0)
# =============================================================================
for asset in assets:
    aid = asset.get("id")
    path = asset.get("path", "")
    role = asset.get("institutional_role", "")

    # R-SEMANTIC-001: institutional_role MUST match file H1
    if path and role:
        file_h1 = get_file_h1(path)
        if file_h1:
            role_words = get_significant_words(role)
            h1_words = get_significant_words(file_h1)
            overlap = role_words & h1_words
            if len(overlap) < 2:
                add_error(aid, "R-SEMANTIC-001",
                          f"institutional_role='{role}' does not match file H1='{file_h1}' "
                          f"(overlap: {len(overlap)} words, need ≥2)")

    # R-SEMANTIC-002: authoritative_for claims SHOULD appear in file content.
    # Generated non-curated claims are namespaced as c-NN-<claim> for uniqueness;
    # that namespace is registry metadata, not text expected in the C-document.
    auth_for = asset.get("authoritative_for", [])
    if auth_for and path:
        file_content = get_file_content(path, 100)
        normalized_content = re.sub(r'[^a-z0-9]+', ' ', file_content)
        compact_content = re.sub(r'[^a-z0-9]+', '', file_content)
        matches = 0
        for claim in auth_for:
            claim_without_namespace = re.sub(r'^c-\d+-', '', claim.lower())
            claim_normalized = re.sub(r'[^a-z0-9]+', ' ', claim_without_namespace)
            compact_claim = re.sub(r'[^a-z0-9]+', '', claim_without_namespace)
            if claim_normalized in normalized_content or compact_claim in compact_content:
                matches += 1
        match_ratio = matches / len(auth_for) if auth_for else 0
        if match_ratio < 0.5:
            add_warning(aid, "R-SEMANTIC-002",
                        f"Only {matches}/{len(auth_for)} authoritative_for claims found in file content "
                        f"({match_ratio*100:.0f}%, need ≥50%)")

# =============================================================================
# R-STRUCT — structural / graph validation
# =============================================================================
asset_by_id = {a.get("id"): a for a in assets if a.get("id")}

# R-STRUCT-002: detect cycles in depends_on
def has_cycle(start_id, graph, visited=None, path=None):
    if visited is None:
        visited = set()
    if path is None:
        path = []
    if start_id in path:
        return path[path.index(start_id):] + [start_id]
    if start_id in visited:
        return None
    visited.add(start_id)
    path = path + [start_id]
    node = graph.get(start_id, {})
    for dep in node.get("depends_on", []):
        if dep == "ALL" or dep == "ALL-SKILLS":
            continue
        if dep in asset_by_id:
            cycle = has_cycle(dep, graph, visited, path)
            if cycle:
                return cycle
    return None

depends_graph = {a.get("id"): a for a in assets}
for asset in assets:
    aid = asset.get("id")
    cycle = has_cycle(aid, depends_graph)
    if cycle:
        add_error(aid, "R-STRUCT-002", f"Circular dependency detected: {' -> '.join(cycle)}")

# R-STRUCT-001: orphan detection
referenced_by = {a.get("id"): set() for a in assets if a.get("id")}
for asset in assets:
    aid = asset.get("id")
    for dep in asset.get("depends_on", []):
        if dep in referenced_by:
            referenced_by[dep].add(aid)
    for inv in asset.get("invalidates", []):
        if inv in referenced_by:
            referenced_by[inv].add(aid)

for asset in assets:
    aid = asset.get("id")
    if aid == "C-00":
        continue
    if not referenced_by.get(aid):
        add_info(aid, "R-STRUCT-001", f"No inbound references — standalone asset")

# R-STRUCT-003: tier-2 isolation
for asset in assets:
    aid = asset.get("id")
    tier = asset.get("tier")
    vs = asset.get("constitutional", {}).get("verification_state")
    if tier in ["tier-0-foundational", "tier-1-constitutional-runtime", "tier-1-institutional-intelligence"]:
        for dep in asset.get("depends_on", []):
            dep_asset = asset_by_id.get(dep)
            if dep_asset and dep_asset.get("tier") == "tier-2-experimental":
                if vs != "unverified":
                    add_error(aid, "R-STRUCT-003",
                              f"Current-state asset depends on tier-2-experimental: {dep}")

# R-STRUCT-004: superseded_by bidirectional
for asset in assets:
    aid = asset.get("id")
    sup_by = asset.get("superseded_by")
    if sup_by and sup_by in asset_by_id:
        if aid not in asset_by_id[sup_by].get("supersedes", []):
            add_error(aid, "R-STRUCT-004",
                      f"superseded_by={sup_by} but {sup_by} does not list {aid} in supersedes")

# R-STRUCT-005: no self-supersession
for asset in assets:
    aid = asset.get("id")
    if aid in asset.get("supersedes", []):
        add_error(aid, "R-STRUCT-005", "Asset cannot supersede itself")
    if asset.get("superseded_by") == aid:
        add_error(aid, "R-STRUCT-005", "Asset cannot be superseded by itself")

# R-STRUCT-006: invalidates-depends_on symmetry
def closure_depends(start_id, visited=None):
    if visited is None:
        visited = set()
    if start_id in visited:
        return visited
    visited.add(start_id)
    a = asset_by_id.get(start_id, {})
    for dep in a.get("depends_on", []):
        if dep in asset_by_id:
            closure_depends(dep, visited)
    return visited

def closure_invalidates(start_id, visited=None):
    if visited is None:
        visited = set()
    if start_id in visited:
        return visited
    visited.add(start_id)
    a = asset_by_id.get(start_id, {})
    for inv in a.get("invalidates", []):
        if inv in asset_by_id:
            closure_invalidates(inv, visited)
    return visited

for asset in assets:
    aid = asset.get("id")
    invalidated = closure_invalidates(aid) - {aid}
    for inv in invalidated:
        inv_closure = closure_depends(inv)
        if aid not in inv_closure:
            add_error(aid, "R-STRUCT-006",
                      f"Invalidates {inv} but {inv} does not (transitively) depend on {aid}")

# =============================================================================
# R-GOV — governance validation
# =============================================================================
auth_for_map = {}
for asset in assets:
    aid = asset.get("id")
    for claim in asset.get("authoritative_for", []):
        if claim in auth_for_map:
            add_error(aid, "R-GOV-002",
                      f"authoritative_for='{claim}' already claimed by {auth_for_map[claim]}")
        else:
            auth_for_map[claim] = aid

for asset in assets:
    aid = asset.get("id")
    ts = asset.get("constitutional", {}).get("truth_state")
    vs = asset.get("constitutional", {}).get("verification_state")
    tier = asset.get("tier")
    scope = asset.get("constitutional", {}).get("authority_scope")

    if not asset.get("owner"):
        add_error(aid, "R-GOV-001", "Owner is required")

    if ts == "current-state" and vs in ["unverified", "assumed", None]:
        add_error(aid, "R-GOV-003",
                  f"truth_state=current-state but verification_state={vs}")

    if tier == "tier-0-foundational" and ts == "deprecated":
        add_error(aid, "R-GOV-004", "Tier-0 foundational asset cannot be deprecated")

    if tier in ["tier-0-foundational", "tier-1-constitutional-runtime", "tier-1-institutional-intelligence"]:
        if not asset.get("authoritative_for"):
            add_error(aid, "R-GOV-006", "Tier-0/Tier-1 asset must have non-empty authoritative_for")

    if tier == "tier-2-experimental":
        if asset.get("authoritative_for"):
            add_error(aid, "R-GOV-007", "Tier-2-experimental must have empty authoritative_for")

    tier_compat = {
        "tier-0-foundational": ["current-state"],
        "tier-1-constitutional-runtime": ["current-state", "future-vision", "planned-state"],
        "tier-1-institutional-intelligence": ["current-state", "future-vision", "planned-state", "speculation"],
        "tier-2-experimental": ["speculation", "future-vision", "idea"],
    }
    if tier in tier_compat and ts and ts not in tier_compat[tier]:
        add_error(aid, "R-GOV-008",
                  f"tier={tier} cannot have truth_state={ts}. Allowed: {tier_compat[tier]}")

    if tier == "tier-2-experimental" and scope != "experimental":
        add_error(aid, "R-GOV-009",
                  f"tier-2-experimental requires authority_scope=experimental, got {scope}")

    scope_compat = {
        "tier-0-foundational": ["platform", "constitutional"],
        "tier-1-institutional-intelligence": ["platform", "constitutional", "app"],
        "tier-1-constitutional-runtime": ["platform", "constitutional", "domain", "app", "service"],
    }
    if tier in scope_compat and scope and scope not in scope_compat[tier]:
        add_error(aid, "R-GOV-010",
                  f"{tier} requires authority_scope in {scope_compat[tier]}, got {scope}")

# =============================================================================
# R-LIFE — lifecycle validation
# =============================================================================
for asset in assets:
    aid = asset.get("id")
    ts = asset.get("constitutional", {}).get("truth_state")
    nr = asset.get("next_review")

    if ts in ["speculation", "future-vision"] and not nr:
        add_error(aid, "R-LIFE-003", f"truth_state={ts} requires next_review date")

# =============================================================================
# R-AUDIT — audit trail validation
# =============================================================================
for asset in assets:
    aid = asset.get("id")
    ts = asset.get("constitutional", {}).get("truth_state")
    lv = asset.get("last_verified")
    nr = asset.get("next_review")

    if ts == "current-state" and not lv:
        add_error(aid, "R-AUDIT-001", "current-state asset must have last_verified")

    if ts == "current-state" and not nr:
        add_warning(aid, "R-AUDIT-002", "current-state asset should have next_review")

    if ts in ["current-state", "planned-state"] and nr:
        try:
            review_date = datetime.strptime(str(nr), "%Y-%m-%d").date()
            days_past = (date.today() - review_date).days
            if days_past > 30:
                add_error(aid, "R-AUDIT-003",
                          f"Review expired {days_past} days ago ({nr}) — requires re-verification")
            elif days_past > 0:
                add_warning(aid, "R-AUDIT-003",
                            f"Review overdue by {days_past} days ({nr})")
        except (ValueError, TypeError):
            pass

# =============================================================================
# R-COVERAGE — coverage validation (NEW in v2.0)
# =============================================================================
kb_dir = os.path.join(REPO_ROOT, "knowledge-base")
registered_ids = {a.get("id") for a in assets}
files_on_disk = set()
if os.path.isdir(kb_dir):
    for fname in os.listdir(kb_dir):
        m = re.match(r'(C-\d+)', fname)
        if m:
            files_on_disk.add(m.group(1))

# R-COVERAGE-001: every file MUST have an entry
missing_from_registry = files_on_disk - registered_ids
for cid in sorted(missing_from_registry):
    add_error(cid, "R-COVERAGE-001",
              f"C-doc exists in knowledge-base/ but is missing from asset-registry.yaml")

# R-COVERAGE-002: no orphan entries
orphan_entries = registered_ids - files_on_disk
for cid in sorted(orphan_entries):
    add_warning(cid, "R-COVERAGE-002",
                f"Entry exists in registry but no C-doc file found in knowledge-base/")

# =============================================================================
# Tally per-asset results
# =============================================================================
for issue in errors:
    asset_results.setdefault(issue["asset"], {"errors": 0, "warnings": 0, "info": 0})
    asset_results[issue["asset"]]["errors"] += 1
for issue in warnings:
    asset_results.setdefault(issue["asset"], {"errors": 0, "warnings": 0, "info": 0})
    asset_results[issue["asset"]]["warnings"] += 1
for issue in info:
    asset_results.setdefault(issue["asset"], {"errors": 0, "warnings": 0, "info": 0})
    asset_results[issue["asset"]]["info"] += 1

# =============================================================================
# Per-tier breakdown
# =============================================================================
tier_breakdown = {}
for asset in assets:
    tier = asset.get("tier", "unknown")
    if tier not in tier_breakdown:
        tier_breakdown[tier] = {"total": 0, "errors": 0, "warnings": 0}
    tier_breakdown[tier]["total"] += 1
for issue in errors:
    aid = issue["asset"]
    a = asset_by_id.get(aid, {})
    tier = a.get("tier", "unknown")
    tier_breakdown.setdefault(tier, {"total": 0, "errors": 0, "warnings": 0})
    tier_breakdown[tier]["errors"] += 1
for issue in warnings:
    aid = issue["asset"]
    a = asset_by_id.get(aid, {})
    tier = a.get("tier", "unknown")
    tier_breakdown.setdefault(tier, {"total": 0, "errors": 0, "warnings": 0})
    tier_breakdown[tier]["warnings"] += 1

# =============================================================================
# Generate markdown report
# =============================================================================
total_assets = len(assets)
total_files = len(files_on_disk)
coverage_pct = (total_assets / total_files * 100) if total_files else 0
total_errors = len(errors)
total_warnings = len(warnings)
total_info = len(info)
status = "✅ CLEAN" if total_errors == 0 else f"❌ {total_errors} ERRORS"

report = f"""# Registry Integrity Report

> **Generated:** {datetime.now().isoformat()}
> **Registry:** `{REGISTRY_PATH}`
> **Rules:** `{RULES_PATH}`
> **Status:** {status}

## Summary

| Metric | Count |
|--------|-------|
| Total assets in registry | {total_assets} |
| Total C-docs on disk | {total_files} |
| Coverage | {coverage_pct:.1f}% |
| Errors | {total_errors} |
| Warnings | {total_warnings} |
| Info | {total_info} |

## Per-Tier Breakdown

| Tier | Assets | Errors | Warnings |
|------|--------|--------|----------|
"""
for tier, stats in sorted(tier_breakdown.items()):
    report += f"| {tier} | {stats['total']} | {stats['errors']} | {stats['warnings']} |\n"

report += f"\n## Coverage Report (R-COVERAGE)\n\n"
report += f"- Files on disk: {total_files}\n"
report += f"- Files registered: {total_assets}\n"
report += f"- Coverage: {coverage_pct:.1f}%\n"
if missing_from_registry:
    report += f"- Missing from registry: {len(missing_from_registry)} ({', '.join(sorted(missing_from_registry)[:10])}{'...' if len(missing_from_registry) > 10 else ''})\n"
else:
    report += f"- Missing from registry: 0 ✅\n"
if orphan_entries:
    report += f"- Orphan registry entries: {len(orphan_entries)}\n"
else:
    report += f"- Orphan registry entries: 0 ✅\n"

report += f"\n## Semantic Drift Report (R-SEMANTIC)\n\n"
semantic_errors = [e for e in errors if e["rule"].startswith("R-SEMANTIC")]
semantic_warnings = [w for w in warnings if w["rule"].startswith("R-SEMANTIC")]
report += f"- Semantic errors: {len(semantic_errors)}\n"
report += f"- Semantic warnings: {len(semantic_warnings)}\n"
if semantic_errors:
    report += "\n### Semantic Errors (must fix)\n\n"
    for issue in semantic_errors:
        report += f"- **{issue['asset']}** [{issue['rule']}]: {issue['message']}\n"

report += "\n## Errors (must fix)\n\n"
if not errors:
    report += "_No errors._ ✅\n"
else:
    for issue in errors:
        report += f"- **{issue['asset']}** [{issue['rule']}]: {issue['message']}\n"

report += "\n## Warnings (should fix)\n\n"
if not warnings:
    report += "_No warnings._ ✅\n"
else:
    for issue in warnings:
        report += f"- **{issue['asset']}** [{issue['rule']}]: {issue['message']}\n"

report += "\n## Recommended Actions\n\n"
if total_errors > 0:
    report += f"1. Fix {total_errors} error(s) before merging.\n"
if total_warnings > 0:
    report += f"2. Review {total_warnings} warning(s) — address within sprint.\n"
if coverage_pct < 100:
    report += f"3. Coverage is {coverage_pct:.1f}% — run `python3 scripts/build-asset-registry.py` to regenerate.\n"
if total_errors == 0 and total_warnings == 0 and coverage_pct == 100:
    report += "1. Registry is clean and complete. Run `python3 scripts/registry-impact-analysis.py C-XX` for change analysis.\n"

with open(REPORT_PATH, "w") as f:
    f.write(report)

if JSON_OUTPUT:
    with open(REPORT_JSON_PATH, "w") as f:
        json.dump({
            "generated": datetime.now().isoformat(),
            "status": "clean" if total_errors == 0 else "errors",
            "summary": {
                "total_assets": total_assets,
                "total_files": total_files,
                "coverage_pct": coverage_pct,
                "errors": total_errors,
                "warnings": total_warnings,
                "info": total_info,
            },
            "tier_breakdown": tier_breakdown,
            "errors": errors,
            "warnings": warnings,
            "info": info,
            "asset_results": asset_results,
        }, f, indent=2)

# Console output
print(f"\n{'='*70}")
print(f"Registry Integrity Report v2.0 — {status}")
print(f"{'='*70}")
print(f"Assets: {total_assets}/{total_files} ({coverage_pct:.1f}% coverage) | Errors: {total_errors} | Warnings: {total_warnings}")
print(f"Report: {REPORT_PATH}")
if JSON_OUTPUT:
    print(f"JSON:   {REPORT_JSON_PATH}")
print(f"{'='*70}\n")

sys.exit(1 if total_errors > 0 else 0)
PYEOF
