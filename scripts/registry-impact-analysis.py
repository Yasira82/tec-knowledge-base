#!/usr/bin/env python3
"""
TEC Registry Impact Analysis Engine v1.0
==========================================

Given a document ID (e.g., "ADR-007" or "C-12"), compute the blast radius:
  - Direct dependents (who depends_on this doc)
  - Indirect dependents (transitive closure)
  - Affected ADRs
  - Affected App Charters (C-100 → C-115)
  - Affected tiers
  - Suggested review list (ranked by tier priority)

Reads architecture/asset-registry.yaml.

Usage:
  python3 scripts/registry-impact-analysis.py ADR-007
  python3 scripts/registry-impact-analysis.py C-12 --format json
  python3 scripts/registry-impact-analysis.py C-67 --depth 3

Authority: C-117 Registry Integrity Constitution
"""
import argparse
import json
import os
import sys
import re
from collections import defaultdict, deque
from pathlib import Path

try:
    import yaml
except ImportError:
    print('ERROR: PyYAML required. Run: pip install pyyaml', file=sys.stderr)
    sys.exit(2)


REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_REGISTRY = REPO_ROOT / 'architecture' / 'asset-registry.yaml'

# Tier priority for review ordering
TIER_PRIORITY = {
    'tier-0-foundational': 0,
    'tier-1-constitutional-runtime': 1,
    'tier-1-institutional-intelligence': 2,
    'tier-2-experimental': 3,
}


def build_reverse_index(assets):
    """Build reverse maps: who depends_on X, who invalidates X."""
    depends_on_me = {a['id']: [] for a in assets}
    invalidates_me = {a['id']: [] for a in assets}
    for a in assets:
        for ref in a.get('depends_on', []):
            if ref in depends_on_me:
                depends_on_me[ref].append(a['id'])
        for ref in a.get('invalidates', []) or []:
            if ref in invalidates_me:
                invalidates_me[ref].append(a['id'])
    return depends_on_me, invalidates_me


def transitive_closure(start, reverse_map, max_depth=10):
    """BFS through reverse_map from start."""
    visited = {}
    queue = deque([(start, 0)])
    while queue:
        node, depth = queue.popleft()
        if depth >= max_depth:
            continue
        for next_node in reverse_map.get(node, []):
            if next_node not in visited or visited[next_node] > depth + 1:
                visited[next_node] = depth + 1
                queue.append((next_node, depth + 1))
    visited.pop(start, None)
    return visited


def analyze(target_id, assets, max_depth=10):
    by_id = {a['id']: a for a in assets}

    if target_id not in by_id:
        return {'error': f'Asset {target_id} not found in registry'}

    depends_on_me, invalidates_me = build_reverse_index(assets)

    # Direct dependents
    direct_dependents = depends_on_me.get(target_id, [])
    transitive_dependents = transitive_closure(target_id, depends_on_me, max_depth)

    # Direct invalidates
    direct_invalidates = invalidates_me.get(target_id, [])

    # Affected ADRs
    affected_adrs = [d_id for d_id in (direct_dependents + list(transitive_dependents.keys()))
                     if d_id.startswith('ADR-')]

    # Affected App Charters (C-100 → C-115)
    affected_charters = [d_id for d_id in (direct_dependents + list(transitive_dependents.keys()))
                         if d_id.startswith('C-1') and len(d_id) <= 5
                         and d_id[2:].isdigit() and 100 <= int(d_id[2:]) <= 115]

    # Affected tiers
    affected_tiers = defaultdict(int)
    all_affected = set(direct_dependents) | set(transitive_dependents.keys())
    for d_id in all_affected:
        if d_id in by_id:
            tier = by_id[d_id].get('tier', 'unknown')
            affected_tiers[tier] += 1

    # Suggested review list — sorted by tier priority then depth
    review_list = []
    for d_id in all_affected:
        if d_id in by_id:
            d = by_id[d_id]
            review_list.append({
                'id': d_id,
                'title': d.get('institutional_role', ''),
                'tier': d.get('tier', 'unknown'),
                'truth_state': d.get('constitutional', {}).get('truth_state', 'unknown'),
                'authority_scope': d.get('constitutional', {}).get('authority_scope', 'unknown'),
                'depth': transitive_dependents.get(d_id, 1) if d_id in transitive_dependents else 1,
                'tier_priority': TIER_PRIORITY.get(d.get('tier'), 99),
            })
    review_list.sort(key=lambda x: (x['tier_priority'], x['depth'], x['id']))

    return {
        'target': target_id,
        'target_title': by_id[target_id].get('institutional_role', ''),
        'target_tier': by_id[target_id].get('tier', 'unknown'),
        'target_truth_state': by_id[target_id].get('constitutional', {}).get('truth_state', 'unknown'),
        'target_authority_scope': by_id[target_id].get('constitutional', {}).get('authority_scope', 'unknown'),
        'target_path': by_id[target_id].get('path', ''),
        'direct_dependents': direct_dependents,
        'transitive_dependents': dict(transitive_dependents),
        'direct_invalidates': direct_invalidates,
        'affected_adrs': affected_adrs,
        'affected_charters': affected_charters,
        'affected_tiers': dict(affected_tiers),
        'review_list': review_list,
        'summary': {
            'total_affected': len(all_affected),
            'direct_count': len(direct_dependents),
            'transitive_count': len(transitive_dependents),
            'adr_count': len(affected_adrs),
            'charter_count': len(affected_charters),
            'max_depth_reached': max(transitive_dependents.values()) if transitive_dependents else 0,
        },
    }


def main():
    parser = argparse.ArgumentParser(description='TEC Registry Impact Analysis Engine v1.0')
    parser.add_argument('target', help='Asset ID (e.g., ADR-007, C-12)')
    parser.add_argument('--registry', default=str(DEFAULT_REGISTRY),
                        help='Path to asset-registry.yaml')
    parser.add_argument('--format', choices=['text', 'json'], default='text')
    parser.add_argument('--depth', type=int, default=10, help='Max traversal depth')
    args = parser.parse_args()

    registry_path = Path(args.registry)
    if not registry_path.exists():
        print(f'ERROR: registry not found: {registry_path}', file=sys.stderr)
        sys.exit(2)

    with open(registry_path) as f:
        registry = yaml.safe_load(f)

    assets = registry.get('assets', [])
    result = analyze(args.target, assets, args.depth)

    if 'error' in result:
        print(result['error'], file=sys.stderr)
        sys.exit(2)

    if args.format == 'json':
        print(json.dumps(result, indent=2, ensure_ascii=False))
        return

    # Text format
    s = result['summary']
    print('═══════════════════════════════════════════════════════════════')
    print(f'  TEC Registry Impact Analysis — {args.target}')
    print('═══════════════════════════════════════════════════════════════')
    print(f'  Target:      {args.target} — {result["target_title"]}')
    print(f'  Tier:        {result["target_tier"]}')
    print(f'  Truth State: {result["target_truth_state"]}')
    print(f'  Authority:   {result["target_authority_scope"]}')
    print(f'  Path:        {result["target_path"]}')
    print('───────────────────────────────────────────────────────────────')
    print(f'  Total affected assets:      {s["total_affected"]}')
    print(f'  Direct dependents:          {s["direct_count"]}')
    print(f'  Transitive dependents:      {s["transitive_count"]}')
    print(f'  Affected ADRs:              {s["adr_count"]}')
    print(f'  Affected App Charters:      {s["charter_count"]}')
    print(f'  Max depth reached:          {s["max_depth_reached"]}')
    print('───────────────────────────────────────────────────────────────')

    if result['affected_tiers']:
        print('  Affected by tier:')
        for tier, count in sorted(result['affected_tiers'].items(),
                                   key=lambda x: TIER_PRIORITY.get(x[0], 99)):
            print(f'    • {tier}: {count} asset(s)')
        print('')

    if result['direct_dependents']:
        print('  Direct dependents (must review immediately):')
        for d in result['direct_dependents']:
            d_title = next((a.get('institutional_role', '') for a in assets if a.get('id') == d), '')
            print(f'    • {d:6} — {d_title[:60]}')
        print('')

    if result['transitive_dependents']:
        print('  Transitive dependents (review if change is non-trivial):')
        for d, depth in sorted(result['transitive_dependents'].items(),
                               key=lambda x: (x[1], TIER_PRIORITY.get(
                                   next((a.get('tier', 'unknown') for a in assets if a.get('id') == x[0]), 99), x[0]))):
            print(f'    • {d:6}  (depth {depth})')
        print('')

    if result['affected_charters']:
        print('  Affected App Charters:')
        for c in result['affected_charters']:
            c_title = next((a.get('institutional_role', '') for a in assets if a.get('id') == c), '')
            print(f'    • {c:6} — {c_title[:60]}')
        print('')

    if result['review_list']:
        print('  Suggested review order (tier-0 first, then depth):')
        for r in result['review_list'][:20]:
            print(f'    • [{r["tier_priority"]}] {r["id"]:6} (depth {r["depth"]}) — {r["title"][:60]}')
        if len(result['review_list']) > 20:
            print(f'    ... and {len(result["review_list"]) - 20} more')
    print('═══════════════════════════════════════════════════════════════')


if __name__ == '__main__':
    main()
