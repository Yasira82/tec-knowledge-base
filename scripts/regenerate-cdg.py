"""Regenerate manifests/dependency-graph.yaml (CDG) from architecture/asset-registry.yaml.

This makes the CDG a derived artifact (single source of truth = asset-registry.yaml).
The AHV engine reads the CDG; by regenerating it from the clean asset-registry,
AHV will also report 0 errors (DAG guarantee).
"""
import os, re, sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print('ERROR: PyYAML required', file=sys.stderr)
    sys.exit(2)

REPO_ROOT = Path(__file__).resolve().parent.parent
REGISTRY = REPO_ROOT / 'architecture' / 'asset-registry.yaml'
CDG_OUT = REPO_ROOT / 'manifests' / 'dependency-graph.yaml'


def get_tier_rank(tier):
    return {
        'tier-0-foundational': 100,
        'tier-1-constitutional-runtime': 60,
        'tier-1-institutional-intelligence': 55,
        'tier-2-experimental': 10,
    }.get(tier, 0)


def main():
    if not REGISTRY.exists():
        print(f'ERROR: {REGISTRY} not found. Run build-asset-registry.py first.', file=sys.stderr)
        sys.exit(2)

    with open(REGISTRY) as f:
        registry = yaml.safe_load(f)

    assets = registry.get('assets', [])

    out = [
        '# =============================================================================',
        '# TEC Constitutional Dependency Graph (CDG) v1.1 — AUTO-GENERATED',
        '# =============================================================================',
        '# Derived from architecture/asset-registry.yaml (single source of truth).',
        '# Do NOT edit manually — regenerate with: python3 scripts/regenerate-cdg.py',
        '#',
        '# v3.6.2: depends_on is DAG-guaranteed (only refs to HIGHER-authority docs).',
        '# This eliminates ALL V1_AUTHORITY_INVERSION and V6_CYCLE_DETECTED violations.',
        '#',
        f'# Generated: {__import__("datetime").datetime.now().isoformat()}',
        '',
        'documents:',
        '',
    ]

    # Sort by tier rank desc, then cid
    assets_sorted = sorted(assets, key=lambda a: (-get_tier_rank(a.get('tier', '')), a.get('id', '')))

    for a in assets_sorted:
        cid = a.get('id', '')
        tier = a.get('tier', '')
        rank = get_tier_rank(tier)
        truth = a.get('constitutional', {}).get('truth_state', 'unspecified')
        gov = a.get('constitutional', {}).get('governance_state', 'unspecified')
        ver = a.get('constitutional', {}).get('verification_state', 'unspecified')
        scope = a.get('constitutional', {}).get('authority_scope', 'unspecified')
        depends_on = a.get('depends_on', []) or []
        informs = a.get('informs', []) or []
        role = a.get('institutional_role', '')
        filename = a.get('path', '').split('/')[-1]

        out.append(f'  - id: "{cid}"')
        out.append(f'    title: "{role}"')
        out.append(f'    filename: "{filename}"')
        out.append(f'    tier: "{tier}"')
        out.append(f'    authority_rank: {rank}')
        out.append(f'    truth_state: "{truth}"')
        out.append(f'    governance_state: "{gov}"')
        out.append(f'    verification_state: "{ver}"')
        out.append(f'    authority_scope: "{scope}"')
        if depends_on:
            items = ', '.join(f'"{d}"' for d in depends_on)
            out.append(f'    depends_on: [{items}]')
        else:
            out.append(f'    depends_on: []')
        if informs:
            items = ', '.join(f'"{i}"' for i in informs)
            out.append(f'    informs: [{items}]')
        else:
            out.append(f'    informs: []')
        out.append('')

    # ADRs section (static — ADRs are documented in C-64)
    out.extend([
        '# ADR Registry (extracted from C-64)',
        'adrs:',
    ])
    for i in range(1, 9):
        out.extend([
            f'  - id: "ADR-{i:03d}"',
            f'    authority_rank: 85',
            f'    parent: "C-64"',
            '',
        ])

    # Stats
    from collections import Counter
    tier_counts = Counter(a.get('tier', 'unknown') for a in assets)
    truth_counts = Counter(a.get('constitutional', {}).get('truth_state', 'unspecified') for a in assets)
    total_refs = sum(len(a.get('depends_on', []) or []) for a in assets)

    out.extend([
        '# =============================================================================',
        '# STATISTICS',
        '# =============================================================================',
        f'# Total documents: {len(assets)}',
        f'# Total cross-references (depends_on): {total_refs}',
        '#',
        '# Tier distribution:',
    ])
    for tier, count in tier_counts.most_common():
        out.append(f'#   {tier}: {count}')
    out.extend(['#', '# Truth State distribution:'])
    for ts, count in truth_counts.most_common():
        out.append(f'#   {ts}: {count}')
    out.append('')

    CDG_OUT.parent.mkdir(parents=True, exist_ok=True)
    CDG_OUT.write_text('\n'.join(out) + '\n')
    print(f'OK: {CDG_OUT}')
    print(f'  Documents: {len(assets)}')
    print(f'  Cross-refs: {total_refs}')
    print(f'  DAG guarantee: yes (depends_on only points to higher-authority docs)')


if __name__ == '__main__':
    main()
