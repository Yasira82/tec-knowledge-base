#!/usr/bin/env python3
"""
TEC Authority Hierarchy Validation (AHV) Engine v1.0
======================================================

Reads manifests/dependency-graph.yaml and enforces the authority hierarchy
declared in C-67 Source of Truth Matrix. Detects:

  V1: Low-authority document depending on lower-authority document
  V2: "Current State" document depending on "Planned" or "Future Vision" doc
  V3: Orphan references — doc mentioned in `informs` but the target
      doesn't acknowledge it in `depends_on` (broken bidirectional link)
  V4: Truth State declared but Governance State missing (or vice versa)
  V5: Document with authority_rank ≥ 85 (Constitutional) lacking Truth State
  V6: Cycle detection in depends_on graph

Exit codes:
  0 = pass (no violations)
  1 = violations found (CI fails)
  2 = script error (manifest missing/invalid)

Usage:
  python3 scripts/ahv_engine.py [--manifest manifests/dependency-graph.yaml]
                                [--format text|json|sarif]
                                [--severity error|warning|info]
                                [--strict]   # treat warnings as errors

Authority: C-116 Authority Automation Constitution
Source:    C-67 Source of Truth Matrix
"""
import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path


# ─── YAML parser (no external dependency) ────────────────────────────
def parse_yaml_simple(text):
    """Minimal YAML parser for our specific CDG format. Not general-purpose."""
    documents = []
    adrs = []
    section = None
    current = None
    for line in text.splitlines():
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        if line.startswith('documents:'):
            section = 'documents'
            continue
        if line.startswith('adrs:'):
            section = 'adrs'
            continue
        # Match "  - id: C-XX"
        m = re.match(r'^\s*-\s+id:\s+"?(C-\d+|ADR-\d+)"?\s*$', line)
        if m:
            if current:
                (documents if section == 'documents' else adrs).append(current)
            current = {'id': m.group(1)}
            continue
        # Match "    key: value" or "    key: [a, b, c]"
        m = re.match(r'^\s{4}(\w+):\s*(.*)$', line)
        if m and current:
            key, value = m.groups()
            value = value.strip()
            if value.startswith('[') and value.endswith(']'):
                # List
                inner = value[1:-1].strip()
                if inner:
                    items = [v.strip().strip('"').strip("'") for v in inner.split(',')]
                    current[key] = items
                else:
                    current[key] = []
            elif value.startswith('"') and value.endswith('"'):
                current[key] = value[1:-1]
            elif value.startswith("'") and value.endswith("'"):
                current[key] = value[1:-1]
            else:
                try:
                    current[key] = int(value)
                except ValueError:
                    current[key] = value
    if current:
        (documents if section == 'documents' else adrs).append(current)
    return documents, adrs


# ─── Validation rules ────────────────────────────────────────────────
class Violation:
    SEVERITY_ERROR = 'error'
    SEVERITY_WARNING = 'warning'
    SEVERITY_INFO = 'info'

    def __init__(self, code, severity, doc_id, message, ref=None):
        self.code = code
        self.severity = severity
        self.doc_id = doc_id
        self.message = message
        self.ref = ref

    def to_dict(self):
        d = {'code': self.code, 'severity': self.severity,
             'doc': self.doc_id, 'message': self.message}
        if self.ref:
            d['ref'] = self.ref
        return d


def validate(docs, adrs):
    violations = []
    by_id = {d['id']: d for d in docs}

    # Merge ADRs into the index for reference lookups
    for adr in adrs:
        by_id[adr['id']] = adr

    # V1: Authority rank inversion in depends_on
    for d in docs:
        for ref in d.get('depends_on', []):
            if ref not in by_id:
                continue
            ref_doc = by_id[ref]
            if ref_doc.get('authority_rank', 0) < d.get('authority_rank', 0):
                violations.append(Violation(
                    'V1_AUTHORITY_INVERSION',
                    Violation.SEVERITY_ERROR,
                    d['id'],
                    f"depends_on {ref} (rank {ref_doc.get('authority_rank')}) "
                    f"which has lower authority than self (rank {d.get('authority_rank')})",
                    ref=ref
                ))

    # V2: Current State depending on Planned/Future Vision
    TRUTH_RANK = {'Current State': 3, 'Planned State': 2,
                  'Future Vision': 1, 'Speculation': 0, 'unspecified': -1}
    for d in docs:
        my_truth = d.get('truth_state', 'unspecified')
        if my_truth != 'Current State':
            continue
        for ref in d.get('depends_on', []):
            if ref not in by_id:
                continue
            ref_truth = by_id[ref].get('truth_state', 'unspecified')
            if TRUTH_RANK.get(ref_truth, -1) < TRUTH_RANK.get(my_truth, -1):
                violations.append(Violation(
                    'V2_TRUTH_STATE_INVERSION',
                    Violation.SEVERITY_ERROR,
                    d['id'],
                    f"declared [Current State] but depends_on {ref} which is [{ref_truth}]",
                    ref=ref
                ))

    # V3: Orphan informs — bidirectional check
    for d in docs:
        for ref in d.get('informs', []):
            if ref not in by_id:
                violations.append(Violation(
                    'V3_ORPHAN_REF',
                    Violation.SEVERITY_WARNING,
                    d['id'],
                    f"informs {ref} but that document does not exist",
                    ref=ref
                ))
                continue
            ref_doc = by_id[ref]
            if d['id'] not in ref_doc.get('depends_on', []):
                violations.append(Violation(
                    'V3_BROKEN_BIDI',
                    Violation.SEVERITY_INFO,
                    d['id'],
                    f"informs {ref} but {ref} does not list this in depends_on",
                    ref=ref
                ))

    # V4: Truth State declared but Governance State missing (or vice versa)
    for d in docs:
        ts = d.get('truth_state', 'unspecified')
        gs = d.get('governance_state', 'unspecified')
        if ts != 'unspecified' and gs == 'unspecified':
            violations.append(Violation(
                'V4_MISSING_GOVERNANCE_STATE',
                Violation.SEVERITY_WARNING,
                d['id'],
                "Truth State declared but Governance State missing"
            ))
        if gs != 'unspecified' and ts == 'unspecified':
            violations.append(Violation(
                'V4_MISSING_TRUTH_STATE',
                Violation.SEVERITY_WARNING,
                d['id'],
                "Governance State declared but Truth State missing"
            ))

    # V5: Constitutional docs (rank >= 85) MUST have Truth State
    for d in docs:
        if d.get('authority_rank', 0) >= 85:
            if d.get('truth_state', 'unspecified') == 'unspecified':
                violations.append(Violation(
                    'V5_CONSTITUTIONAL_MISSING_TRUTH',
                    Violation.SEVERITY_ERROR,
                    d['id'],
                    f"authority_rank {d.get('authority_rank')} (constitutional) "
                    f"but Truth State not declared"
                ))

    # V6: Cycle detection in depends_on
    visited = set()
    stack = set()

    def detect_cycle(doc_id, path):
        if doc_id in stack:
            cycle = ' → '.join(path + [doc_id])
            violations.append(Violation(
                'V6_CYCLE_DETECTED',
                Violation.SEVERITY_ERROR,
                path[0] if path else doc_id,
                f"dependency cycle: {cycle}"
            ))
            return True
        if doc_id in visited:
            return False
        stack.add(doc_id)
        if doc_id in by_id:
            for ref in by_id[doc_id].get('depends_on', []):
                if detect_cycle(ref, path + [doc_id]):
                    stack.discard(doc_id)
                    return True
        stack.discard(doc_id)
        visited.add(doc_id)
        return False

    for d in docs:
        if d['id'] not in visited:
            detect_cycle(d['id'], [])

    return violations


def main():
    parser = argparse.ArgumentParser(description='TEC AHV Engine v1.0')
    parser.add_argument('--manifest', default='manifests/dependency-graph.yaml',
                        help='Path to CDG manifest')
    parser.add_argument('--format', choices=['text', 'json', 'sarif'], default='text')
    parser.add_argument('--severity', choices=['error', 'warning', 'info'],
                        default='info', help='Minimum severity to report')
    parser.add_argument('--strict', action='store_true',
                        help='Treat warnings as errors (exit 1)')
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    if not manifest_path.exists():
        print(f'ERROR: manifest not found: {manifest_path}', file=sys.stderr)
        sys.exit(2)

    text = manifest_path.read_text(encoding='utf-8')
    docs, adrs = parse_yaml_simple(text)
    if not docs:
        print('ERROR: no documents parsed from manifest', file=sys.stderr)
        sys.exit(2)

    violations = validate(docs, adrs)

    # Filter by severity
    sev_rank = {'info': 0, 'warning': 1, 'error': 2}
    min_rank = sev_rank[args.severity]
    violations = [v for v in violations if sev_rank[v.severity] >= min_rank]

    # Output
    if args.format == 'json':
        out = {
            'summary': {
                'total_docs': len(docs),
                'total_adrs': len(adrs),
                'violations': len(violations),
                'errors': sum(1 for v in violations if v.severity == 'error'),
                'warnings': sum(1 for v in violations if v.severity == 'warning'),
                'infos': sum(1 for v in violations if v.severity == 'info'),
            },
            'violations': [v.to_dict() for v in violations],
        }
        print(json.dumps(out, indent=2, ensure_ascii=False))
    elif args.format == 'sarif':
        # Simplified SARIF for CI integration
        rules = {
            'V1_AUTHORITY_INVERSION': 'Low-authority doc depends on lower-authority doc',
            'V2_TRUTH_STATE_INVERSION': 'Current State doc depends on Planned/Future doc',
            'V3_ORPHAN_REF': 'Reference target does not exist',
            'V3_BROKEN_BIDI': 'Bidirectional link not acknowledged',
            'V4_MISSING_GOVERNANCE_STATE': 'Truth State without Governance State',
            'V4_MISSING_TRUTH_STATE': 'Governance State without Truth State',
            'V5_CONSTITUTIONAL_MISSING_TRUTH': 'Constitutional doc missing Truth State',
            'V6_CYCLE_DETECTED': 'Dependency cycle detected',
        }
        sarif = {
            'version': '2.1.0',
            'runs': [{
                'tool': {'driver': {'name': 'TEC AHV Engine', 'version': '1.0.0',
                                    'rules': [{'id': k, 'shortDescription': {'text': v}}
                                              for k, v in rules.items()]}},
                'results': [{
                    'ruleId': v.code,
                    'level': {'error': 'error', 'warning': 'warning', 'info': 'note'}[v.severity],
                    'message': {'text': v.message},
                    'locations': [{'physicalLocation': {'artifactLocation': {'uri': v.doc_id}}}]
                } for v in violations]
            }]
        }
        print(json.dumps(sarif, indent=2))
    else:
        # Text format
        print('═══════════════════════════════════════════════════════════════')
        print('  TEC Authority Hierarchy Validation (AHV) Engine v1.0')
        print('═══════════════════════════════════════════════════════════════')
        print(f'  Manifest:    {args.manifest}')
        print(f'  Documents:   {len(docs)} C-docs + {len(adrs)} ADRs')
        print('')
        errors = [v for v in violations if v.severity == 'error']
        warnings = [v for v in violations if v.severity == 'warning']
        infos = [v for v in violations if v.severity == 'info']
        print(f'  Errors:      {len(errors)}')
        print(f'  Warnings:    {len(warnings)}')
        print(f'  Info:        {len(infos)}')
        print('───────────────────────────────────────────────────────────────')
        if violations:
            for v in violations:
                icon = {'error': '✗', 'warning': '⚠', 'info': 'ℹ'}[v.severity]
                line = f'  {icon} [{v.code}] {v.doc_id}'
                if v.ref:
                    line += f' → {v.ref}'
                line += f'\n      {v.message}'
                print(line)
        else:
            print('  ✓ No violations — authority hierarchy consistent')
        print('═══════════════════════════════════════════════════════════════')

    # Exit code
    has_blocking = any(v.severity == 'error' for v in violations)
    if args.strict:
        has_blocking = has_blocking or any(v.severity == 'warning' for v in violations)
    sys.exit(1 if has_blocking else 0)


if __name__ == '__main__':
    main()
