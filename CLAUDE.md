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
| C-116–C-118 | Constitutional Automation (Authority + Registry + Dependency) |
| C-119–C-121 | Economic Operating System Model (OS Model + Zone Charter + Knowledge Pipeline) |
| C-122 | Analytics Constitutional Runtime Charter (Intelligence Runtime) |
| C-123 | Pi Browser Session & Cookie Spec (Runtime Operational Law) |
| C-124–C-131 | User-Layer App Charters (NBF · Epic · Legend · Elite · VIP · Insure · Titan · Brookfield) |
| C-132 | Service Extraction & Modular Architecture Policy (ADR-011 detail — Modules-First) |

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

Knowledge Base v3.11.0 | Governance Charter v1.2


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
| SLO definitions | `manifests/slo-definitions.yaml` + `evals/check-slo-definitions.sh` | **13th KB gate**. Engineering's half of the Observability handoff: C-78 §2 SLO targets made machine-readable (auth/payment/gateway/PAL/hub availability + payment success ≥95% + PHS). Validates binds_to + cross-checks that every `slo_breach` evidence record references a **defined** SLO. Ops wires Prometheus alerts from this. |

### v3.7.0 shift
CI gates now: **13** in KB (was 10) + a per-app **Drift Detection** gate in all 4 frontend apps. These are the first gates that bind the constitution to *runtime reality* — not document structure. The Runtime Governance Layer's in-repo half is complete: Portal readiness + code↔claim drift (Drift Detection) + behavior↔claim evidence (Runtime Evidence) + SLO definitions (engineering's observability half). Remaining NEXT is infra/ops: ops stands up the Observability stack (Prometheus/alerts) emitting `slo_breach` into `runtime-evidence/`.

## Session 14.12 Additions (v3.8.0) — TIER 10: Economic Operating System Model

Three new vision-layer constitutional docs integrated as **TIER 10**. They articulate the *why* above the app charters (C-100→C-115): TEC as a 3-tier economic operating system, not a collection of apps.

| Document | Path | Purpose |
|----------|------|---------|
| C-119 Economic Operating System Model | `knowledge-base/C-119___ECONOMIC_OPERATING_SYSTEM_MODEL.md` | 3-tier model (Constitutional Runtimes / User Runtimes / Economic Products) + build sequence. Supersedes C-30's *build sequence* only. |
| C-120 Zone Constitutional Runtime Charter | `knowledge-base/C-120___ZONE_CONSTITUTIONAL_RUNTIME_CHARTER.md` | Zone = Verification Runtime ("What can be trusted?"); `zone.pi` strategic asset; V1→V4. |
| C-121 Institutional Knowledge Pipeline | `knowledge-base/C-121___INSTITUTIONAL_KNOWLEDGE_PIPELINE.md` | Sequential intelligence chain Hub → Life → Connection → Zone → Analytics → Nexus → TEC AI. |

### v3.8.0 integration notes
- `build-asset-registry.py` classifier extended (`119–121 → tier-1-institutional-intelligence`). Registry rebuilt: 102 assets, 100% coverage.
- C-30 marked **partially superseded** (build sequence only) — banner added, not deleted.
- Headers normalized to schema (`[Future Vision]` + `[Assumed]`); C-120 gained a Related Documents footer.
- **All 13 CI gates pass, 0 errors.** Truth State of all three = `[Future Vision]` / `[Draft]` — vision, not current runtime.

## Session 16 Additions (v3.9.0) — C-123: Pi Browser Session & Cookie Spec

Born from the July 2026 Hub login outage (multi-day production incident,
root-caused from Vercel runtime logs). Everything in it is **Runtime Verified**.

| Document | Path | Purpose |
|----------|------|---------|
| C-123 Pi Browser Session & Cookie Spec | `knowledge-base/C-123___PI_BROWSER_SESSION_COOKIE_SPEC.md` | TIER 11 — Runtime Operational Law: the 3 cookie laws (XHR Set-Cookie unreliable · 3xx Set-Cookie dropped · embedded context requires `none+secure+Partitioned`), the LOCKED session-cookie contract, verified-entry login architecture (200 HTML landing + `/api/auth/me` gate), server-side token refresh (single-flight), diagnostic playbook (log signatures → causes), and the PR-by-PR incident ledger (#56→#67). |

### v3.9.0 rules
- Any change to cookies, login flow, or token refresh in ANY TEC app MUST cite C-123
  and state which LAW it preserves.
- `sameSite=lax` on session cookies is FORBIDDEN (it caused the outage). CI tests in
  tec-app assert `none`.
- Session cookies are established/rotated ONLY on plain 200 responses.
- All 13 KB gates pass, 0 errors. Registry rebuilt: 104 assets, 100% coverage.

## Session 17 Additions (v3.10.0) — C-124→C-130: User-Layer App Charters

Seven `[Future Vision]` / `[Draft]` app charters integrated as **TIER 12**. They
define the reputation/creation/protection/enterprise value chain above the app
scaffolds already built (Vip/Elite/Insure/Epic/Legend repos + Titan). Gated
(Phase 2/3) — vision, not current runtime.

| Document | Path | Purpose |
|----------|------|---------|
| C-124 NBF Business Foundation Runtime | `knowledge-base/C-124___NBF_BUSINESS_FOUNDATION_RUNTIME.md` | Business Day-1: establish + verify a Pi business in 25 min; graduates INTO Titan |
| C-125 Epic Creation Runtime | `knowledge-base/C-125___EPIC_CREATION_RUNTIME.md` | System of Construction — projects/communities; Epic→Zone→Legend pipeline |
| C-126 Legend Reputation Runtime | `knowledge-base/C-126___LEGEND_REPUTATION_RUNTIME.md` | System of Evidence — records OUTCOMES not claims (read layer; Analytics computes) |
| C-127 Elite Excellence Runtime | `knowledge-base/C-127___ELITE_EXCELLENCE_RUNTIME.md` | System of Recognition — criteria-based (BRONZE→PLATINUM); earned, never bought |
| C-128 VIP Premium Experience Runtime | `knowledge-base/C-128___VIP_PREMIUM_EXPERIENCE_RUNTIME.md` | System of Privilege — VIP grants eligibility; owning apps enforce value (P5) |
| C-129 Insure Risk Protection Runtime | `knowledge-base/C-129___INSURE_RISK_PROTECTION_RUNTIME.md` | System of Protection — escrow custody hard-gated to payment-service (P0, like FundX) |
| C-130 Titan Enterprise OS Runtime | `knowledge-base/C-130___TITAN_ENTERPRISE_OS_RUNTIME.md` | Enterprise OS — B2B counterpart to Life; NBF graduation target; wallet = VIEW only |

### v3.10.0 integration notes
- **Renumbered** from the authored draft (C-122→C-127) to **C-124→C-130** — the
  draft collided with the live **C-122 Analytics** and **C-123 Pi Browser Session
  & Cookie Spec** (Runtime Verified law). Renumbered along the value chain.
- **Header schema normalized**: `Verification: [Unverified]` → `[Assumed]`; VIP
  Truth State → `[Planned State]` (Hub PRO/ENTERPRISE exists).
- **Content hardening**: Insure escrow given a **Custody Hard-Gate** (payment-service
  is the only π custodian — Invariant #8; 3 P0 gates like FundX C-113). Event names
  versioned per C-70 (`payment.completed.v1`). VIP fee-authority note added (P5).
  Domains dual-noted (`<app>.tecosystem.app` now → `<app>.pi` future).
- `build-asset-registry.py` classifier extended (`124–130 → tier-1-institutional-intelligence`,
  scope `app`, type `charter`). Registry rebuilt: **111 assets, 100% coverage**.
- C-57 master index gained **TIER 12**. **All KB gates pass, 0 errors.**

## Session 18 Additions (v3.11.0) — C-132: Modules-First Architecture Policy (ADR-011)

Codifies the platform's service-vs-module deployment law so no future session
regresses to "24 apps = 24 microservices."

| Document | Path | Purpose |
|----------|------|---------|
| C-132 Service Extraction & Modular Architecture Policy | `knowledge-base/C-132___SERVICE_EXTRACTION_MODULAR_ARCHITECTURE_POLICY.md` | ADR-011 full detail — **Modules-First** (App→Module→Service); new service only on a documented **T1–T4** production trigger; **Design-for-Extraction** (Explorer→search-service); **Financial Hard-Gate** (payment-service is the only Pi custodian, Invariant #8); Apps→Modules→Services mapping for all 24 apps; target service count now = the 11 live services. |
| ADR-011 (C-64) | `knowledge-base/C-64___ARCHITECTURE_DECISION_RECORDS.md` | Decision record + pointer to C-132 (ADR-007→C-76 pattern). |

### v3.11.0 notes
- `build-asset-registry.py` classifier extended (`132 → tier-1-constitutional-runtime`,
  type `architecture`). Registry rebuilt: **113 assets, 100% coverage**.
- C-57 master index gained **TIER 13** (Platform Architecture Policy). Range → C-132.
- **All 13 KB gates pass, 0 errors.** Proven in production: Life/Connection/Zone are
  modules inside `tec-identity-service` — the reference pattern C-132 formalizes.
