# TEC Knowledge Base

Centralized knowledge base for the TEC Federated Platform Ecosystem.

## Structure

```
knowledge-base/     # Platform knowledge (C-00 → C-99 + C-100→C-115)
governance/         # Platform governance documents
```

## Contents

| Range | Domain |
|-------|--------|
| C-00 | Platform Constitution |
| C-01–C-02 | Identity + Current State |
| C-10–C-16 | Architecture + Rules |
| C-20–C-23 | Backend + Apps + SDK |
| C-30–C-32 | Vision + App Blueprints |
| C-40–C-49 | Engineering + Violations + Roadmap |
| C-50–C-58 | Session + Patterns + Protocols |
| C-59–C-66 | Templates + Code + Guides |
| C-67–C-78 | Governance + Integrity + Operations |
| C-82–C-92 | Future Vision + Execution Governance |
| C-79 | Institutional Memory Constitution (Tier-2 Asset) |
| C-93–C-99 | Institutional Operating Loop Constitutions (Tier-1 + Tier-2) |
| C-80 | Engineering Assessment Report |
| C-100–C-115 | App Institutional Charters (Economic Infrastructure) |

## Governance

- `governance/TEC_GOVERNANCE_CHARTER_v1.2.md` — Platform governance charter

## Navigation

For full index → `knowledge-base/C-57___MASTER_CONTENTS_INDEX.md`

## Authority Hierarchy

C-00 → C-67 → ADRs (C-64) → Current State docs → Runtime Evidence → Code

## Truth Framework

Every architectural statement must declare:
- Truth State: [Current State] | [Planned State] | [Future Vision] | [Speculation]
- Governance State: [ADR Approved] | [Governance Approved] | [Draft] | [Rejected]
- Verification: [Documentation Verified] | [Code Verified] | [Runtime Verified] | [Assumed]

## Version

Knowledge Base v3.6.2 | Governance Charter v1.2


---

## Skills

Available via plugin — invoke automatically when the situation matches:

| Situation | Skill |
|-----------|-------|
| Updating or reviewing any knowledge-base document | `/docs-guard` |
| Stress-testing an architectural decision against existing ADRs | `/grill-with-docs` |
| Converting a strategic discussion into a PRD | `/to-prd` |
| Breaking a roadmap item into GitHub Issues | `/to-issues` |
| Session is getting long or context is filling up | `/handoff` |

## Session 12 Additions (v3.6.0)

| Document | Path | Purpose |
|----------|------|---------|
| C-117 Registry Integrity Constitution | `knowledge-base/C-117___REGISTRY_INTEGRITY_CONSTITUTION.md` | Defines auto-generated registry, R-SEMANTIC rules, 100% coverage requirement |
| Asset Registry (auto-generated) | `architecture/asset-registry.yaml` | 96 C-docs with tier + truth_state + depends_on — DO NOT EDIT MANUALLY |
| Registry Integrity Rules v2.0 | `architecture/registry-integrity-rules.yaml` | 28 rules across 7 categories (added R-SEMANTIC + R-COVERAGE) |
| Asset Registry Builder | `scripts/build-asset-registry.py` | Auto-generates registry from file headers |
| Registry Impact Analysis | `scripts/registry-impact-analysis.py` | Blast radius calculator using the registry |
| Registry Integrity Engine v2.0 | `evals/check-registry-integrity.sh` | CI gate: validates registry against rules + against actual files |

### Key shift in v3.6.0

The asset registry is now **auto-generated**. To update it:
1. Edit the source C-NN.md file
2. Run `python3 scripts/build-asset-registry.py`
3. Commit both files together

Manually editing `architecture/asset-registry.yaml` is forbidden and CI will reject it.

## Session 12.1 Additions (v3.6.1)

| Document | Path | Purpose |
|----------|------|---------|
| VAM Manifest (restored) | `manifests/verification-authority-matrix.yaml` | 7 verification tiers + 7 policies — restored from v3.5.0 |
| VAM Compliance Engine | `evals/check-vam-compliance.sh` | CI gate: validates every current-state asset against VAM requirements |

### v3.6.1 fix
v3.6.0 accidentally dropped the VAM manifest from v3.5.0. v3.6.1 restores it AND adds a new CI gate to enforce it. Total CI gates now: **10**.

## Session 12.2 Additions (v3.6.2)

| Document | Path | Purpose |
|----------|------|---------|
| C-118 Dependency Propagation Constitution | `knowledge-base/C-118___DEPENDENCY_PROPAGATION_CONSTITUTION.md` | Defines change propagation + stale flag mechanism |
| Propagation Engine | `scripts/propagate-dependency.py` | Computes transitive closure of downstream dependents |
| CDG Regenerator | `scripts/regenerate-cdg.py` | Derives CDG from asset-registry (single source of truth) |
| build-asset-registry.py v1.2 | `scripts/build-asset-registry.py` | DAG-guaranteed depends_on + prefixed authoritative_for |

### v3.6.2 Engineering Achievement

**All 10 CI gates pass with 0 errors.** This is the first version where:
- Registry Integrity: 0 errors (was 30 in v3.6.0)
- AHV Engine: 0 errors (was 65 in v3.6.0)
- C-57 Drift: 0 (was 31 in v3.4.0)
- Truth Framework: 0 blocking violations
- VAM Compliance: 0 violations

The DAG-guarantee (depends_on only points to HIGHER-authority docs) eliminates cycles by construction. The prefixed authoritative_for (c-NN-claim) eliminates authority vacuum by construction.
