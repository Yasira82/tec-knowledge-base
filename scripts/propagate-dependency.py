#!/usr/bin/env python3
"""
TEC Dependency Propagation Engine v1.0
========================================

Computes the transitive closure of downstream dependents when a document changes.
Reads architecture/asset-registry.yaml.

Usage:
  python3 scripts/propagate-dependency.py C-67
  python3 scripts/propagate-dependency.py C-93 --format json
  python3 scripts/propagate-dependency.py C-93 --mark-stale

Authority: C-118 Dependency Propagation Constitution
"""
import argparse
import json
import os
import sys
from collections import defaultdict, deque
from pathlib import Path

try:
    import yaml
except ImportError:
    print('ERROR: PyYAML required. Run: pip install pyyaml', file=sys.stderr)
    sys.exit(2)


REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_REGISTRY = REPO_ROOT / 'architecture' / 'asset-registry.yaml'

TIER_PRIORITY = {
    'tier-0-foundational': 0,
    'tier-1-constitutional-runtime': 1,
    'tier-1-institutional-intelligence': 2,
    'tier-2-experimental': 3,
}


def build_reverse_index(assets):
    """Build reverse map: who depends_on X?"""
    depends_on_me = defaultdict(list)
    for a in assets:
        for ref in a.get('depends_on', []) or []:
            depends_on_me[ref].append(a['id'])
    return depends_on_me


def propagate(target_id, assets, max_depth=10):
    """BFS through reverse depends_on graph from target_id."""
    by_id = {a['id']: a for a in assets}
    if target_id not in by_id:
        return {'error': f'Asset {target_id} not found in registry'}

    depends_on_me = build_reverse_index(assets)

    affected = {}  # cid → depth
    queue = deque([(target_id, 0)])
    while queue:
        current, depth = queue.popleft()
        if depth >= max_depth:
            continue
        for dependent in depends_on_me.get(current, []):
            if dependent not in affected or affected[dependent] > depth + 1:
                affected[dependent] = depth + 1
                queue.append((dependent, depth + 1))

    affected.pop(target_id, None)

    # Build review list sorted by tier priority then depth
    review_list = []
    for d_id, depth in affected.items():
        if d_id in by_id:
            d = by_id[d_id]
            review_list.append({
                'id': d_id,
                'title': d.get('institutional_role', ''),
                'tier': d.get('tier', 'unknown'),
                'depth': depth,
                'tier_priority': TIER_PRIORITY.get(d.get('tier'), 99),
                'requires_reverification': depth <= 2,  # direct + depth-2 must re-verify
            })
    review_list.sort(key=lambda x: (x['tier_priority'], x['depth'], x['id']))

    # Group by depth
    by_depth = defaultdict(list)
    for r in review_list:
        by_depth[r['depth']].append(r)

    return {
        'target': target_id,
        'target_title': by_id[target_id].get('institutional_role', ''),
        'target_tier': by_id[target_id].get('tier', 'unknown'),
        'affected_count': len(affected),
        'direct_dependents': [r for r in review_list if r['depth'] == 1],
        'transitive_dependents': [r for r in review_list if r['depth'] > 1],
        'review_list': review_list,
        'by_depth': {str(k): v for k, v in sorted(by_depth.items())},
        'max_depth': max(affected.values()) if affected else 0,
        'requires_reverification_count': sum(1 for r in review_list if r['requires_reverification']),
    }


def main():
    parser = argparse.ArgumentParser(description='TEC Dependency Propagation Engine v1.0')
    parser.add_argument('target', help='Asset ID that changed (e.g., C-93)')
    parser.add_argument('--registry', default=str(DEFAULT_REGISTRY))
    parser.add_argument('--format', choices=['text', 'json'], default='text')
    parser.add_argument('--depth', type=int, default=10)
    parser.add_argument('--mark-stale', action='store_true',
                        help='Output stale-flag entries for asset-registry.yaml (Phase 2)')
    args = parser.parse_args()

    registry_path = Path(args.registry)
    if not registry_path.exists():
        print(f'ERROR: registry not found: {registry_path}', file=sys.stderr)
        sys.exit(2)

    with open(registry_path) as f:
        registry = yaml.safe_load(f)

    assets = registry.get('assets', [])
    result = propagate(args.target, assets, args.depth)

    if 'error' in result:
        print(result['error'], file=sys.stderr)
        sys.exit(2)

    if args.format == 'json':
        print(json.dumps(result, indent=2, ensure_ascii=False))
        return

    # Text format
    print('═══════════════════════════════════════════════════════════════')
    print(f'  TEC Dependency Propagation — {args.target} changed')
    print('═══════════════════════════════════════════════════════════════')
    print(f'  Source:      {args.target} — {result["target_title"]}')
    print(f'  Tier:        {result["target_tier"]}')
    print('───────────────────────────────────────────────────────────────')
    print(f'  Total affected documents:        {result["affected_count"]}')
    print(f'  Direct dependents (depth 1):     {len(result["direct_dependents"])}')
    print(f'  Transitive dependents (depth 2+):{len(result["transitive_dependents"])}')
    print(f'  Requires re-verification:        {result["requires_reverification_count"]}')
    print(f'  Max propagation depth:           {result["max_depth"]}')
    print('───────────────────────────────────────────────────────────────')

    if result['direct_dependents']:
        print('\n  ⚠️  DIRECT DEPENDENTS (must re-verify before merge):')
        for r in result['direct_dependents']:
            print(f'    • {r["id"]:6} (tier {r["tier_priority"]}) — {r["title"][:60]}')

    if result['transitive_dependents']:
        print('\n  📋 TRANSITIVE DEPENDENTS (review if change is non-trivial):')
        for r in result['transitive_dependents']:
            print(f'    • {r["id"]:6} (depth {r["depth"]}) — {r["title"][:60]}')

    if args.mark_stale:
        print('\n  📝 STALE FLAGS (paste into asset-registry.yaml):')
        print('  Add to each affected asset:')
        for r in result['review_list']:
            if r['requires_reverification']:
                rid = r['id']
                print(f'    # {rid}:')
                print(f'    # stale_flags:')
                print(f'    #   - source: {args.target}')
                print(f'    #     detected: 2026-06-18')
                print(f'    #     reason: "{args.target} changed; {rid} depends_on {args.target}"')
                print(f'    #     requires_reverification: true')

    print('\n═══════════════════════════════════════════════════════════════')


if __name__ == '__main__':
    main()
