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

Knowledge Base v3.7.0 | Governance Charter v1.2


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

## Session 14.6 Additions (v3.7.0) — Runtime Governance Layer (begins)

First in-repo step of the unanimous #1 gap (doc ↔ runtime). Authority: `audits/EXECUTION_PLAN_2026-06-21.md` (NEXT — Runtime Governance Layer).

| Document | Path | Purpose |
|----------|------|---------|
| Portal Readiness Engine | `evals/check-portal-readiness.sh` | CI gate: auto pre-submission audit. Asserts the documented Pi-Portal readiness is internally consistent before any app is submitted — App ID/domain agree across C-01 (canonical) ↔ C-02 ↔ PORTAL_RUNBOOK, no placeholders, PI_SANDBOX=false, Privacy/Terms present, no open ENG/OPS checklist items, no stale Commerce domain. |
| Drift Detection gate | each app's `.github/workflows/ci.yml` (step "Drift Detection — KB claims vs code") | Per-app CI gate binding code to specific C-docs: **ADR-009** (payment `amount` is a number, `x-internal-key`) · **C-12 §11** (CSRF middleware-only) · **C-76/ADR-007** (every Mode-2 buy handler guarded with `isHubNavigation()`; pi-test exempt). Hub also enforces **C-96** single health poller. Live in all 4 apps. |
| C-96 dual-poller fix (NEW-K) | tec-app `src/context/PlatformHealthContext.tsx` | Single health-poller runtime; `BackendOfflineBanner` + `BackendStatus` are consumers. C-96 Finding 1 → RESOLVED. |
| Runtime Evidence schema | `manifests/runtime-evidence-schema.yaml` + `evals/check-runtime-evidence.sh` | **12th KB gate**. Contract for runtime evidence (metric/health_snapshot/incident/slo_breach): every record attributable to a `source` + `binds_to` ≥ 1 existing C-doc → consumable by C-93 at VAM tier V-5. Behavior↔claim half of Runtime Governance. Records live in `runtime-evidence/`. |

### v3.7.0 shift
CI gates now: **12** in KB (was 10) + a per-app **Drift Detection** gate in all 4 frontend apps. These are the first gates that bind the constitution to *runtime reality* — not document structure. The Runtime Governance Layer's in-repo half is complete: Portal readiness + code↔claim drift (Drift Detection) + behavior↔claim evidence (Runtime Evidence). Remaining NEXT is infra/ops: the Observability stack (Prometheus/SLOs) emitting into `runtime-evidence/`.
