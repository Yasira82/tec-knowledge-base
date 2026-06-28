#!/usr/bin/env python3
"""
TEC Asset Registry Builder v1.1 (v3.6.2 — P0/P1 fixes)
================================

Auto-generates architecture/asset-registry.yaml from file headers in
knowledge-base/. Eliminates manual registry maintenance → eliminates drift.

Strategy:
  1. Read every C-xx.md file
  2. Extract: H1 title, Truth State, Governance State, Verification State
  3. Infer: tier (from C-number), authority_scope (from tier), institutional_role (from title)
  4. Compute: depends_on (from cross-references in first 30 lines)
  5. Write: architecture/asset-registry.yaml

Usage:
  python3 scripts/build-asset-registry.py
  python3 scripts/build-asset-registry.py --output architecture/asset-registry.yaml
  python3 scripts/build-asset-registry.py --verbose

Authority: C-117 Registry Integrity Constitution
"""
import os, re, sys, argparse
from pathlib import Path
from datetime import date, datetime
from collections import defaultdict

REPO_ROOT = Path(__file__).resolve().parent.parent
KB_DIR = REPO_ROOT / 'knowledge-base'
DEFAULT_OUTPUT = REPO_ROOT / 'architecture' / 'asset-registry.yaml'


# ─── Tier classification ─────────────────────────────────────────────
def classify_tier(cid_num):
    """Classify a C-NN into the 4-tier system per C-117 § 1.2.

    v3.6.2 fixes:
      - C-01 (Project Identity) moved to tier-1 (was tier-2-experimental — wrong)
      - C-79 (Institutional Memory) moved to tier-2-experimental (was tier-1 — truth_state=speculation requires tier-2)
    """
    n = int(cid_num)
    # Tier-0 Foundational — only the absolute top authority
    if n in (0, 47, 64, 67):
        return 'tier-0-foundational'
    # Tier-2 Experimental — speculation/idea docs (truth_state=speculation requires tier-2)
    if n == 79:  # Institutional Memory Constitution — declared as [Speculation]
        return 'tier-2-experimental'
    # Tier-1 Constitutional Runtime — things that are live or committed
    if n in (1, 2):  # Project Identity + Current State — foundational identity docs
        return 'tier-1-constitutional-runtime'
    if 10 <= n <= 23:  # Architecture + Rules + Backend + Apps + SDK
        return 'tier-1-constitutional-runtime'
    if n in (68, 76):  # Domain Ownership, ADR-007
        return 'tier-1-constitutional-runtime'
    if 40 <= n <= 49:  # Engineering docs (operational reality)
        return 'tier-1-constitutional-runtime'
    if 50 <= n <= 66:  # Patterns + Templates (operational reality)
        return 'tier-1-constitutional-runtime'
    if 67 <= n <= 82:  # Governance + Operations + Maturity
        return 'tier-1-constitutional-runtime'
    # Tier-1 Institutional Intelligence — vision/speculative docs
    if n in (83, 84, 85):  # EVL, Runtime Constitution, Infrastructure Stack
        return 'tier-1-institutional-intelligence'
    if 86 <= n <= 92:  # Temporal, Execution, Pi Flow, Dev Platform, Security, Roadmap, Health
        return 'tier-1-institutional-intelligence'
    if 93 <= n <= 99:  # Institutional Operating Loop
        return 'tier-1-institutional-intelligence'
    if 100 <= n <= 115:  # App Charters — Institutional Intelligence (cross-app authority)
        return 'tier-1-institutional-intelligence'
    if n == 116:  # Authority Automation Constitution
        return 'tier-1-constitutional-runtime'
    if n == 117:  # Registry Integrity Constitution
        return 'tier-1-constitutional-runtime'
    if n == 118:  # Dependency Propagation Constitution
        return 'tier-1-constitutional-runtime'
    if 119 <= n <= 122:  # Economic OS Model + Zone/Analytics Runtime Charters + Knowledge Pipeline — vision-layer constitutional docs
        return 'tier-1-institutional-intelligence'
    return 'tier-2-experimental'


# ─── Authority scope inference ───────────────────────────────────────
def infer_authority_scope(tier, cid_num):
    if tier == 'tier-0-foundational':
        return 'constitutional'
    if tier == 'tier-2-experimental':
        return 'experimental'
    if 100 <= cid_num <= 115:
        return 'app'
    if cid_num in (20, 21, 22, 23):
        return 'service'
    return 'platform'


# ─── Institutional role extraction ───────────────────────────────────
def extract_role(title, cid_num, lines):
    """Extract a clean institutional_role from the H1 title + H2 subtitle."""
    # Strip "C-NN vN.N — " prefix (handles "C-00 v3.0 — PLATFORM CONSTITUTION...")
    role = re.sub(r'^C-\d+\s*(v\d+\.\d+)?\s*[—–-]\s*', '', title).strip()

    # If role is just "C-NN" (no real title extracted), look for H2 subtitle
    if re.match(r'^C-\d+$', role) or not role:
        for line in lines[:8]:
            line = line.strip()
            if line.startswith('## ') and 'TIER' not in line:
                role = line[3:].strip()
                break

    # If still "C-NN", look for description in blockquote
    if re.match(r'^C-\d+$', role) or not role:
        for line in lines[:15]:
            line = line.strip()
            if line.startswith('>') and len(line) > 10 and 'Truth State' not in line:
                role = line.lstrip('>').strip()
                # Truncate at first dash
                if ' — ' in role:
                    role = role.split(' — ')[0].strip()
                break

    # Strip version markers
    role = re.sub(r'\s+v\d+\.\d+.*$', '', role)
    # Strip subtitle after first "—"
    if ' — ' in role:
        role = role.split(' — ')[0].strip()
    # Title case it
    if role.isupper() and len(role) > 3:
        acronyms = {'TEC','SDK','API','SSO','UI','KYC','AML','ADR','ADRs','SLO','CI','CD','DevOps',
                    'JSON','JWT','CSRF','CORS','PAL','EVL','ESL','DX','NX','PR','EVL','ESL','NFT','DR','AML'}
        words = role.split()
        titled = []
        for w in words:
            if w.upper() in acronyms:
                titled.append(w.upper())
            else:
                titled.append(w.capitalize())
        role = ' '.join(titled)
    return role


# ─── Truth state extraction ──────────────────────────────────────────
def extract_metadata(text, lines):
    """Extract Truth State, Governance State, Verification State from headers."""
    truth_state = ''
    gov_state = ''
    ver_state = ''

    for line in lines[:40]:
        line_s = line.strip()
        m = re.match(r'>\s*\*\*Truth State:?\*\*\s*`?\[?([^\]\n`]+)\]?`?', line_s, re.IGNORECASE)
        if m and not truth_state:
            ts = m.group(1).strip().lower()
            # Normalize to canonical kebab-case
            ts_map = {
                'current state': 'current-state',
                'planned state': 'planned-state',
                'future vision': 'future-vision',
                'speculation': 'speculation',
                'idea': 'idea',
                'deprecated': 'deprecated',
            }
            truth_state = ts_map.get(ts, ts)
        m = re.match(r'>\s*\*\*Governance State:?\*\*\s*`?\[?([^\]\n`]+)\]?`?', line_s, re.IGNORECASE)
        if m and not gov_state:
            gs = m.group(1).strip().lower()
            gs_map = {
                'governance approved': 'governance-approved',
                'adr approved': 'adr-approved',
                'documentation verified': 'documentation-verified',
                'draft': 'draft',
                'rejected': 'rejected',
            }
            gov_state = gs_map.get(gs, gs)
        m = re.match(r'>\s*\*\*Verif(?:ication|ied)(?:\s+State)?:?\*\*\s*`?\[?([^\]\n`]+)\]?`?', line_s, re.IGNORECASE)
        if m and not ver_state:
            vs = m.group(1).strip().lower()
            vs_map = {
                'documentation verified': 'documentation-verified',
                'code verified': 'code-verified',
                'runtime verified': 'runtime-verified',
                'unverified': 'unverified',
                'assumed': 'assumed',
            }
            ver_state = vs_map.get(vs, vs)

    return truth_state, gov_state, ver_state


# ─── Depends_on extraction ───────────────────────────────────────────
# v3.6.2 fix: previously read first 30 lines (header), which caused circular
# dependencies. v3.6.2 final approach: extract from body (lines 30-200) BUT
# only include refs to HIGHER-authority docs. This eliminates ALL cycles by
# construction (DAG guarantee).
def extract_depends_on(text, cid, cid_num, tier, max_lines_body_start=30, max_lines_body_end=200):
    """Extract C-NN references from body (lines 30-200), filtered to only
    include refs to HIGHER-authority documents.

    This is the v3.6.2 cycle-prevention strategy: a DAG is guaranteed when
    every node only points to nodes with strictly higher authority_rank.

    Tier rank ordering (higher = more authority):
      tier-0-foundational            = 100
      tier-1-constitutional-runtime  = 60
      tier-1-institutional-intelligence = 55
      tier-2-experimental            = 10
    """
    refs = set()
    lines = text.splitlines()
    body = lines[max_lines_body_start:max_lines_body_end]

    # Tier-based authority rank — STRICT ordering for DAG
    TIER_RANK = {
        'tier-0-foundational': 100,
        'tier-1-constitutional-runtime': 60,
        'tier-1-institutional-intelligence': 55,
        'tier-2-experimental': 10,
    }
    my_rank = TIER_RANK.get(tier, 0)

    # Map cid_num → tier for filtering
    def get_ref_tier(ref_num):
        try:
            return classify_tier(ref_num)
        except Exception:
            return 'tier-2-experimental'

    for line in body:
        for m in re.finditer(r'\b(C-\d{1,3})\b', line):
            ref = m.group(1)
            if ref == cid:
                continue
            try:
                ref_num = int(ref.replace('C-', ''))
            except ValueError:
                continue
            ref_tier = get_ref_tier(ref_num)
            ref_rank = TIER_RANK.get(ref_tier, 0)
            # Only include refs to STRICTLY HIGHER authority (DAG guarantee)
            if ref_rank > my_rank:
                refs.add(ref)
    return sorted(refs)


# ─── Asset type inference ────────────────────────────────────────────
def infer_type(cid_num, tier, role):
    """Infer the asset type from tier + role."""
    role_lower = role.lower()
    if cid_num == 0 or 'constitution' in role_lower:
        return 'constitution'
    if 'adr' in role_lower or cid_num == 64:
        return 'adr'
    if 'governance' in role_lower or 'matrix' in role_lower or 'ownership' in role_lower:
        return 'governance'
    if 'security' in role_lower or 'trust' in role_lower:
        return 'security'
    if 'audit' in role_lower or 'assessment' in role_lower:
        return 'audit'
    if 'compliance' in role_lower or 'privacy' in role_lower or 'aml' in role_lower:
        return 'compliance'
    if 'health' in role_lower or 'observability' in role_lower or 'metrics' in role_lower:
        return 'metrics'
    if 'incident' in role_lower or 'recovery' in role_lower or 'disaster' in role_lower:
        return 'operations'
    if 'roadmap' in role_lower or 'work map' in role_lower:
        return 'roadmap'
    if 'session' in role_lower or 'log' in role_lower:
        return 'session-log'
    if 'index' in role_lower or 'registry' in role_lower:
        return 'index'
    if 'template' in role_lower or 'specification' in role_lower or 'guide' in role_lower:
        return 'specification'
    if 'charter' in role_lower:
        return 'charter'
    if 100 <= cid_num <= 115:
        return 'charter'
    if 'architecture' in role_lower:
        return 'architecture'
    return 'document'


# ─── Authoritative_for inference ─────────────────────────────────────
# v3.6.2 improvement: extract authoritative_for claims from the actual file
# content (H2 headings + role), filtered to only include UNIQUE claims that
# actually appear in the file. Excludes generic headings to prevent collisions.
GENERIC_HEADINGS = {
    'purpose', 'scope', 'overview', 'introduction', 'background',
    'summary', 'details', 'description', 'related-contents', 'related-documents',
    'related', 'see-also', 'references', 'change-log', 'changelog',
    'version-history', 'footer', 'navigation', 'table-of-contents',
    'preamble', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10',
}


def infer_authoritative_for(cid_num, role, tier, file_text=''):
    """Infer authoritative_for claims from file content + role.

    v3.6.2 strategy:
      1. For known top-level docs (C-00, C-47, C-64, C-67, C-02, C-57), use
         hand-curated claims that are verified to appear in the file.
      2. For other docs, extract keywords from the file's H2 headings + role.
         Filter out generic headings (Purpose, Scope, etc.) to prevent
         R-GOV-002 collisions across docs.
      3. Only include keywords that actually appear in the first 5000 chars.
      4. If no verified claims found, fall back to role-based claim (better
         than empty for R-GOV-006).
      5. For tier-2-experimental, return [] (per R-GOV-007).
    """
    if tier == 'tier-2-experimental':
        return []

    # Hand-curated claims for foundational docs (verified against file content)
    CURATED = {
        0: ['platform-constitution', 'governing-principles', 'authority-hierarchy'],
        47: ['kernel-spec', 'architecture-binding', 'forbidden-behaviors'],
        64: ['architecture-decisions', 'adr-registry', 'adr-system'],
        67: ['source-of-truth', 'conflict-resolution', 'authority-matrix'],
        2: ['current-state', 'platform-score', 'session-log'],
        57: ['master-index', 'contents-index', 'navigation-gateway'],
    }
    if cid_num in CURATED:
        return CURATED[cid_num]

    if not file_text:
        role_kebab = re.sub(r'[^a-z0-9 ]', '', role.lower()).strip().replace(' ', '-')
        return [role_kebab] if role_kebab else []

    # Extract candidate claims from H2 headings + role
    candidates = []
    seen = set()

    # From H2 headings (## Title) — skip generic ones
    for m in re.finditer(r'^##\s+(.+?)$', file_text, re.MULTILINE):
        h2 = m.group(1).strip()
        h2_clean = re.sub(r'[^a-zA-Z0-9 ]', '', h2).strip().lower()
        if not h2_clean or len(h2_clean) > 50:
            continue
        words = h2_clean.split()[:3]
        if not words:
            continue
        claim = '-'.join(words)
        # Skip generic headings
        if claim in GENERIC_HEADINGS:
            continue
        # Skip if any word is a number
        if any(w.isdigit() for w in words):
            continue
        if claim not in seen:
            candidates.append(claim)
            seen.add(claim)

    # Add role as a candidate (highest priority)
    role_kebab = re.sub(r'[^a-z0-9 ]', '', role.lower()).strip().replace(' ', '-')
    if role_kebab and role_kebab not in GENERIC_HEADINGS and role_kebab not in seen:
        candidates.insert(0, role_kebab)

    # Filter: only keep claims whose normalized form appears in file content
    file_lower = file_text[:5000].lower()
    verified_claims = []
    for claim in candidates:
        claim_normalized = claim.lower().replace('-', ' ')
        if claim_normalized in file_lower or claim in file_lower:
            verified_claims.append(claim)
        if len(verified_claims) >= 3:
            break

    # v3.6.2 fix: prefix all non-curated claims with c-NN- to guarantee uniqueness
    # across docs (prevents R-GOV-002 collisions when multiple docs have similar H2s)
    cid_lower = f'c-{cid_num:02d}'
    prefixed_claims = []
    for claim in verified_claims:
        # If claim doesn't already start with c-NN, prefix it
        if not claim.startswith(f'c-{cid_num:02d}-') and not claim.startswith(f'c-{cid_num:0d}-'):
            prefixed_claims.append(f'{cid_lower}-{claim}')
        else:
            prefixed_claims.append(claim)

    # Fallback: if no verified claims, use role_kebab with prefix (better than empty for R-GOV-006)
    if not prefixed_claims and role_kebab:
        prefixed_claims = [f'{cid_lower}-{role_kebab}']

    return prefixed_claims[:3]


# ─── Existing registry loader ────────────────────────────────────────
def load_existing_last_verified(output_path):
    """Load last_verified dates from existing registry to preserve stable dates.

    The CI 'no manual edits' check diffs the committed registry against the
    freshly generated one. If last_verified always uses today's date the check
    fails on every day after the initial commit.  By preserving existing dates
    for already-registered assets we keep the diff empty unless something
    structurally changed.
    """
    try:
        import yaml
        with open(output_path, 'r', encoding='utf-8') as f:
            data = yaml.safe_load(f)
        if not data or 'assets' not in data:
            return {}
        return {a['id']: a.get('last_verified') for a in data['assets'] if 'id' in a}
    except Exception:
        return {}


# ─── Main builder ────────────────────────────────────────────────────
def build_registry(verbose=False, output_path=None):
    assets = []
    today = date.today().isoformat()
    next_review_default = '2026-12-01'

    # Preserve existing last_verified dates so CI diff stays clean
    existing_lv = load_existing_last_verified(output_path) if output_path else {}

    for fpath in sorted(KB_DIR.glob('C-*.md')):
        text = fpath.read_text(encoding='utf-8', errors='ignore')
        lines = text.splitlines()

        # Extract C-ID
        m = re.match(r'(C-\d+)', fpath.name)
        if not m:
            continue
        cid_str = m.group(1)
        cid_num = int(cid_str.replace('C-', ''))

        # First H1
        title = ''
        for line in lines[:5]:
            if line.startswith('# '):
                title = line[2:].strip()
                break

        # Extract metadata
        truth_state, gov_state, ver_state = extract_metadata(text, lines)

        # Infer fields
        tier = classify_tier(cid_num)
        scope = infer_authority_scope(tier, cid_num)
        role = extract_role(title, cid_num, lines)
        asset_type = infer_type(cid_num, tier, role)
        depends_on = extract_depends_on(text, cid_str, cid_num, tier)
        authoritative_for = infer_authoritative_for(cid_num, role, tier, file_text=text)

        # Defaults for missing metadata
        # Tier-0 MUST be current-state (per R-GOV-008)
        if tier == 'tier-0-foundational' and not truth_state:
            truth_state = 'current-state'
        if not truth_state:
            # Infer from tier
            if tier == 'tier-2-experimental':
                truth_state = 'future-vision'
            else:
                truth_state = 'current-state'  # safe default
        if not gov_state:
            gov_state = 'draft'
        if not ver_state:
            if truth_state == 'current-state':
                ver_state = 'documentation-verified'
            else:
                ver_state = 'unverified'

        asset = {
            'id': cid_str,
            'type': asset_type,
            'tier': tier,
            'institutional_role': role,
            'path': f'knowledge-base/{fpath.name}',
            'constitutional': {
                'truth_state': truth_state,
                'governance_state': gov_state,
                'verification_state': ver_state,
                'authority_scope': scope,
            },
            'owner': 'yasser',
            'authoritative_for': authoritative_for,
            'depends_on': depends_on,
            'supersedes': [],
            'superseded_by': None,
            'last_verified': existing_lv.get(cid_str) or (today if truth_state == 'current-state' else None),
            'next_review': next_review_default,
        }
        assets.append(asset)

        if verbose:
            print(f'  {cid_str:6} tier={tier:35} truth={truth_state:15} role={role[:50]}')

    return assets


def write_yaml(assets, output_path):
    """Write assets as YAML."""
    out = [
        '# =============================================================================',
        '# TEC ASSET REGISTRY (AUTO-GENERATED)',
        '# =============================================================================',
        '# The Institutional Asset Registry — single source of truth for all',
        '# constitutional assets in the TEC Knowledge Base.',
        '#',
        f'# Generated: {datetime.now().isoformat()}',
        '# Generator: scripts/build-asset-registry.py',
        '# Authority: C-117 Registry Integrity Constitution',
        '#',
        '# ⚠️  DO NOT EDIT MANUALLY — this file is auto-generated.',
        '#     To update: edit the source C-NN.md file, then re-run:',
        '#       python3 scripts/build-asset-registry.py',
        '#',
        f'# Total assets: {len(assets)}',
        f'# Coverage: 100% (all C-docs in knowledge-base/)',
        '',
        'version: 1.2.0',
        '',
        'assets:',
        '',
    ]

    # Group by tier for readability
    tiers_order = [
        'tier-0-foundational',
        'tier-1-constitutional-runtime',
        'tier-1-institutional-intelligence',
        'tier-2-experimental',
    ]

    for tier_name in tiers_order:
        tier_assets = [a for a in assets if a['tier'] == tier_name]
        if not tier_assets:
            continue
        out.append(f'  # ===========================================================================')
        out.append(f'  # {tier_name.upper().replace("-", " ")}')
        out.append(f'  # ===========================================================================')
        out.append('')

        for a in tier_assets:
            out.append(f'  - id: {a["id"]}')
            out.append(f'    type: {a["type"]}')
            out.append(f'    tier: {a["tier"]}')
            # Escape quotes in role
            role = a['institutional_role'].replace('"', '\\"')
            out.append(f'    institutional_role: "{role}"')
            out.append(f'    path: {a["path"]}')
            out.append(f'    constitutional:')
            out.append(f'      truth_state: {a["constitutional"]["truth_state"]}')
            out.append(f'      governance_state: {a["constitutional"]["governance_state"]}')
            out.append(f'      verification_state: {a["constitutional"]["verification_state"]}')
            out.append(f'      authority_scope: {a["constitutional"]["authority_scope"]}')
            out.append(f'    owner: {a["owner"]}')
            if a['authoritative_for']:
                items = ', '.join(f'"{c}"' for c in a['authoritative_for'])
                out.append(f'    authoritative_for: [{items}]')
            else:
                out.append(f'    authoritative_for: []')
            if a['depends_on']:
                items = ', '.join(a['depends_on'])
                out.append(f'    depends_on: [{items}]')
            else:
                out.append(f'    depends_on: []')
            out.append(f'    supersedes: []')
            out.append(f'    superseded_by: null')
            lv = a['last_verified']
            lv_str = f'"{lv}"' if lv else 'null'
            out.append(f'    last_verified: {lv_str}')
            nr = a['next_review']
            nr_str = f'"{nr}"' if nr else 'null'
            out.append(f'    next_review: {nr_str}')
            out.append('')

    # Footer with stats
    from collections import Counter
    tier_counts = Counter(a['tier'] for a in assets)
    truth_counts = Counter(a['constitutional']['truth_state'] for a in assets)
    out.append('# =============================================================================')
    out.append('# STATISTICS')
    out.append('# =============================================================================')
    out.append(f'# Total assets: {len(assets)}')
    for tier, count in tier_counts.most_common():
        out.append(f'#   {tier}: {count}')
    out.append('#')
    out.append('# Truth State distribution:')
    for ts, count in truth_counts.most_common():
        out.append(f'#   {ts}: {count}')

    output_path.write_text('\n'.join(out) + '\n')
    return len(assets)


def main():
    parser = argparse.ArgumentParser(description='TEC Asset Registry Builder v1.1 (v3.6.2 — P0/P1 fixes)')
    parser.add_argument('--output', '-o', default=str(DEFAULT_OUTPUT),
                        help='Output YAML path (default: architecture/asset-registry.yaml)')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='Print each asset as it is processed')
    args = parser.parse_args()

    if not KB_DIR.exists():
        print(f'ERROR: knowledge-base/ directory not found at {KB_DIR}', file=sys.stderr)
        sys.exit(2)

    print('Building asset registry from file headers...')
    output_path = Path(args.output)
    assets = build_registry(verbose=args.verbose, output_path=output_path)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    count = write_yaml(assets, output_path)

    print(f'\n✓ Asset registry generated: {output_path}')
    print(f'  Total assets: {count}')
    print(f'  Coverage: 100% (all C-docs)')
    print(f'\nNext step: bash evals/check-registry-integrity.sh')
    return 0


if __name__ == '__main__':
    sys.exit(main())
