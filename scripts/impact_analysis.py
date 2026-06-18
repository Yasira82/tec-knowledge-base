#!/usr/bin/env python3
"""
TEC Impact Analysis Engine v1.0
================================

Given a document ID (e.g., "ADR-007" or "C-12"), compute the blast radius:
  - Direct dependents (who depends_on this doc)
  - Indirect dependents (transitive closure)
  - Downstream informs (who this doc informs, recursively)
  - Affected ADRs
  - Affected App Charters (C-100 → C-115)
  - Suggested review list (ranked by authority_rank)

Reads manifests/dependency-graph.yaml.

Usage:
  python3 scripts/impact_analysis.py ADR-007
  python3 scripts/impact_analysis.py C-12 --format json
  python3 scripts/impact_analysis.py C-67 --depth 3
"""
import argparse
import json
import re
import sys
from collections import deque
from pathlib import Path

# Reuse the YAML parser from ahv_engine
sys.path.insert(0, str(Path(__file__).parent))
from ahv_engine import parse_yaml_simple


def build_reverse_index(docs):
    """Build reverse maps: who depends_on X, who informs X."""
    depends_on_me = {d['id']: [] for d in docs}
    informed_by_me = {d['id']: [] for d in docs}
    for d in docs:
        for ref in d.get('depends_on', []):
            if ref in depends_on_me:
                depends_on_me[ref].append(d['id'])
        for ref in d.get('informs', []):
            if ref in informed_by_me:
                informed_by_me[ref].append(d['id'])
    return depends_on_me, informed_by_me


def transitive_closure(start, reverse_map, max_depth=10):
    """BFS through reverse_map from start, return all reachable nodes with depth."""
    visited = {}  # node → depth
    queue = deque([(start, 0)])
    while queue:
        node, depth = queue.popleft()
        if depth >= max_depth:
            continue
        for next_node in reverse_map.get(node, []):
            if next_node not in visited or visited[next_node] > depth + 1:
                visited[next_node] = depth + 1
                queue.append((next_node, depth + 1))
    visited.pop(start, None)  # remove self
    return visited


def analyze(target_id, docs, adrs, max_depth=10):
    by_id = {d['id']: d for d in docs}
    for adr in adrs:
        by_id[adr['id']] = adr

    if target_id not in by_id:
        return {'error': f'Document {target_id} not found in manifest'}

    depends_on_me, informed_by_me = build_reverse_index(docs + adrs)

    # Direct dependents
    direct_dependents = depends_on_me.get(target_id, [])
    # Transitive closure (who would be affected if THIS doc changes)
    transitive_dependents = transitive_closure(target_id, depends_on_me, max_depth)

    # Direct informed-by-me (downstream)
    direct_informs = informed_by_me.get(target_id, [])
    transitive_informs = transitive_closure(target_id, informed_by_me, max_depth)

    # Affected ADRs
    affected_adrs = [d_id for d_id in (direct_dependents + list(transitive_dependents.keys()))
                     if d_id.startswith('ADR-')]

    # Affected App Charters
    affected_charters = [d_id for d_id in (direct_dependents + list(transitive_dependents.keys()))
                         if d_id.startswith('C-1') and len(d_id) <= 5 and d_id[2:].isdigit()
                         and 100 <= int(d_id[2:]) <= 115]

    # Suggested review list — sorted by authority_rank desc
    all_affected = set(direct_dependents) | set(transitive_dependents.keys())
    review_list = []
    for d_id in all_affected:
        if d_id in by_id:
            d = by_id[d_id]
            review_list.append({
                'id': d_id,
                'title': d.get('title', ''),
                'authority_rank': d.get('authority_rank', 0),
                'truth_state': d.get('truth_state', 'unspecified'),
                'depth': transitive_dependents.get(d_id, 1) if d_id in transitive_dependents else 1,
            })
    review_list.sort(key=lambda x: (-x['authority_rank'], x['depth']))

    return {
        'target': target_id,
        'target_title': by_id[target_id].get('title', ''),
        'target_truth_state': by_id[target_id].get('truth_state', 'unspecified'),
        'target_authority_rank': by_id[target_id].get('authority_rank', 0),
        'direct_dependents': direct_dependents,
        'transitive_dependents': dict(transitive_dependents),
        'direct_informs': direct_informs,
        'transitive_informs': dict(transitive_informs),
        'affected_adrs': affected_adrs,
        'affected_charters': affected_charters,
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
    parser = argparse.ArgumentParser(description='TEC Impact Analysis Engine v1.0')
    parser.add_argument('target', help='Document ID (e.g., ADR-007, C-12)')
    parser.add_argument('--manifest', default='manifests/dependency-graph.yaml')
    parser.add_argument('--format', choices=['text', 'json'], default='text')
    parser.add_argument('--depth', type=int, default=10, help='Max traversal depth')
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    if not manifest_path.exists():
        print(f'ERROR: manifest not found: {manifest_path}', file=sys.stderr)
        sys.exit(2)

    docs, adrs = parse_yaml_simple(manifest_path.read_text(encoding='utf-8'))
    result = analyze(args.target, docs, adrs, args.depth)

    if 'error' in result:
        print(result['error'], file=sys.stderr)
        sys.exit(2)

    if args.format == 'json':
        print(json.dumps(result, indent=2, ensure_ascii=False))
        return

    # Text format
    s = result['summary']
    print('═══════════════════════════════════════════════════════════════')
    print(f'  TEC Impact Analysis — {args.target}')
    print('═══════════════════════════════════════════════════════════════')
    print(f'  Target:      {args.target} — {result["target_title"]}')
    print(f'  Truth State: {result["target_truth_state"]}')
    print(f'  Authority:   rank {result["target_authority_rank"]}')
    print('───────────────────────────────────────────────────────────────')
    print(f'  Total affected documents:   {s["total_affected"]}')
    print(f'  Direct dependents:          {s["direct_count"]}')
    print(f'  Transitive dependents:      {s["transitive_count"]}')
    print(f'  Affected ADRs:              {s["adr_count"]}')
    print(f'  Affected App Charters:      {s["charter_count"]}')
    print(f'  Max depth reached:          {s["max_depth_reached"]}')
    print('───────────────────────────────────────────────────────────────')

    if result['direct_dependents']:
        print('  Direct dependents (must review immediately):')
        for d in result['direct_dependents']:
            print(f'    • {d}')
        print('')

    if result['transitive_dependents']:
        print('  Transitive dependents (review if change is non-trivial):')
        for d, depth in sorted(result['transitive_dependents'].items(),
                               key=lambda x: (x[1], x[0])):
            print(f'    • {d}  (depth {depth})')
        print('')

    if result['affected_charters']:
        print('  Affected App Charters:')
        for c in result['affected_charters']:
            print(f'    • {c}')
        print('')

    if result['review_list']:
        print('  Suggested review order (highest authority first):')
        for r in result['review_list'][:15]:
            print(f'    • [{r["authority_rank"]:3}] {r["id"]:6} (depth {r["depth"]}) — {r["title"][:60]}')
        if len(result['review_list']) > 15:
            print(f'    ... and {len(result["review_list"]) - 15} more')
    print('═══════════════════════════════════════════════════════════════')


if __name__ == '__main__':
    main()
