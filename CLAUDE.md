# TEC Knowledge Base

Centralized knowledge base for the TEC Federated Platform Ecosystem.

## Structure

```
knowledge-base/     # Platform knowledge (C-00 → C-99 + C-100→C-115)
governance/         # Platform governance documents
marketing/          # Marketing Assets Kit — launch posts, one-liners, Portal copy,
                    #   ambassador kit (executes C-133; SSoT = tec-app registry valueProp)
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

Knowledge Base v3.12.0 | Governance Charter v1.2


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

## Session 19 Additions (v3.12.0) — Value Chain WIRED (Epic/Zone → Legend → Elite → VIP)

The user-layer **reputation value chain** (C-121 Rule 3 "Data Flows Forward") moved
from `[Future Vision]` to **`[Code Verified]` (merged to `main`)**. It is the first
live, event-driven forward-flow in the platform. Built in `tec-identity-service`
(backend) + the app frontends; all 6 PRs merged.

| Edge | Signal (C-70) | Direction | Status |
|------|---------------|-----------|--------|
| Epic → Legend | `epic.project.completed.v1` | create → earn | ✅ Code Verified |
| Zone → Legend | `zone.badge.issued.v1` | verify → earn | ✅ Code Verified |
| Elite → VIP | live tier check (no event) | recognition → experience | ✅ Code Verified |
| → Legend (consumer) | `legend.consumer.ts`, idempotent by `eventId` | ingest | ✅ Code Verified |

**Producer:** `src/events/stream-emitter.ts` (shared Redis Streams emitter; fail-safe
no-op when `REDIS_URL` is unset — never rolls back the source write).

### v3.12.0 doc updates (this session)
- Added an **`## Implementation Status`** section to **C-120 (Zone)**, **C-121
  (Pipeline)**, **C-125 (Epic)**, **C-126 (Legend)**, **C-127 (Elite)**, and **C-128
  (VIP)** — each declares, per the Truth Framework, exactly which edge is now
  `[Code Verified]` vs still `[Future Vision]`. Charter **headers were intentionally
  left unchanged**: each charter's primary claim (the full runtime) genuinely remains
  future — only the named V0/V1 slice is current.
- **Honest gaps recorded:** (1) the chain is `[Code Verified]`, **NOT** `[Runtime
  Verified]` — it fires only when `REDIS_URL` is set on `tec-identity-service` and the
  Legend consumer runs; (2) the **Legend → Elite** edge is deliberately NOT wired —
  criteria evaluation is Analytics' function (C-127), not to be faked.
- Registry unaffected: the parser reads `Truth State` from the FIRST header line
  (unchanged), so no truth_state/tier reclassification. All KB gates re-run below.

### Operational follow-ups (ops, not code)
- Set `REDIS_URL` on `tec-identity-service` (Railway) + ensure the Legend consumer runs
  → promotes the chain from `[Code Verified]` to `[Runtime Verified]`.
- Next code step: Analytics criteria engine → wires the missing **Legend → Elite** edge.

### Repo-wide status reconciliation (all 24 apps live)
All apps are **deployed on Mainnet with real Pi payment live** (SSoT:
`architecture/app-fleet.yaml` — 21 `live-verified`, 3 `live-readonly-gated`). Added a
**`## Deployment Status`** section to the 14 app charters that still read
`[Future Vision]` with no status (C-106 Life · C-107 Connection · C-108 Explorer ·
C-109 Nexus · C-110 System · C-111 Alert · C-112 NX · C-113 FundX · C-114 Estate ·
C-115 DX · C-124 NBF · C-129 Insure · C-130 Titan · C-131 Brookfield) — each cites the
fleet, records `[Runtime Verified]` for the deployed app + live payment (domain / Pi
App ID / APP_SOURCE / Hub SSO / referral), and keeps the full runtime `[Future Vision]`.
The **3 financially hard-gated** apps (FundX pools · Insure escrow · Brookfield
investment/REITs) are marked read-only until legal + payment-service custody + SYSTEM
(Invariant #8) — only their Pro subscription processes real Pi. Charter **headers
unchanged** (the grand runtime stays future) → registry `truth_state`/tier untouched.

## Session 20.1 Additions — Audit Remediation (P0/P1 batch)

Acting on the v3.10.0 Engineering Audit — implemented the 4 verified items (the audit's
"numbering drift" P0 was checked against the repo and found **already fixed**: the
C-124→C-131 renumber is clean, no stale C-122/C-123 references remain).

| Item | Path | Purpose |
|------|------|---------|
| Event Catalog | `manifests/events-catalog.yaml` | Canonical machine-readable event registry (12 events: 10 live · 2 planned), sourced from real backend code. C-70 GOVERNS; this CATALOGS. |
| Event Catalog Engine | `evals/check-events-catalog.sh` | **14th KB gate** — schema + `binds_to` resolves to a C-doc + unique names + naming law (unversioned only if flagged legacy). |
| AI numbering guard | `.cursorrules` **RULE 6** | AI MUST NOT invent / renumber / reuse / replace `C-NN`; human authority only; propose content with a `PLACEHOLDER` header. |
| Quick Start | `docs/QUICKSTART.md` | 10-minute onboarding (clone → run → login → pay → deploy). **NOT a C-doc** — not in C-57, no Truth Framework header (it changes weekly; a C-doc would add drift). |
| C-132 §7.5 Module-Seam Audit | `knowledge-base/C-132___...POLICY.md` | Code-verified audit of `tec-identity-service`: **17 domain modules** (§7 recorded 7), each with folder + DB namespace + events; flags the one VIP→Elite in-service table read for R-2 at extraction time. |

### Canonical numbering gates (folded in from PR #99)
The audit's "canonical numbering" idea landed as **two bash/py gates** — the right
design compares sessions to the **canonical files** (not to an external PDF):
| Gate | Path | Checks |
|------|------|--------|
| Canonical Numbering Engine | `evals/check-canonical-numbering.sh` | files ⟺ `asset-registry.yaml` ⟺ C-57 index match (116/116/116); catches duplicate / invented / renumbered / orphan / missing IDs. Reserved-range gaps = INFO. |
| Session Canonical Reference Check | `evals/check-session-canonical.sh` | every `C-NN` cited in `memory/` + `audits/` resolves to a real canonical file (0 dangling). |

> Both pass on this branch: **0 numbering drift · 0 dangling refs**. This supersedes the
> earlier "no session-canonical gate is possible" note — it *is* possible against the
> canonical files (there is no PDF in the repo; canonical = C-01 + C-57 + asset-registry).

### Notes
- **Deferred (with reason):** Service-JWT (ADR-013) is a real architectural decision →
  a post-scale ADR, not a silent change (`INTERNAL_SECRET` spans 12 services).
- KB gates now: **16** (added: events-catalog + canonical-numbering + session-canonical).
  Registry unaffected (no C-doc headers changed).

## Session 21 Additions — Legend → Elite criteria engine (value chain complete)

The value chain is now **Runtime-live** (`REDIS_URL` set on `tec-identity-service`; all
consumers boot in prod) and the **last edge is wired**: Legend → Elite.

| Item | Path | Purpose |
|------|------|---------|
| Elite criteria engine | `tec-identity-service/src/modules/elite/elite.service.ts` (`evaluateOwner`) | Grants criteria-based recognition from Legend evidence; GOLD/PLATINUM → CANDIDATE/PANEL; EXPIRE on drop; earned-not-sold (C-127). tec-core-backend #159. |
| Legend evidence API | `legend.service.ts` (`getStatsForOwner`) | Analytics `score_*` (relayed) + verified/Zone counts — a **service API**, the R-2-clean seam (not a raw table read). |
| Consumer trigger | `legend.consumer.ts` + `main.ts` | Legend outcome consumer calls `elite.evaluateOwner(owner)` after each achievement (fail-safe). |

### Doc reconciliation (this session)
- **C-127** Implementation Status: Legend → Elite flipped from "NOT yet wired" → `[Code Verified]`.
- **C-121**: pipeline note updated — the reputation chain is now end-to-end.
- **C-132 §7.5**: added the Elite → Legend **reference seam** (service API = the R-2-clean
  way to build a cross-module dependency; contrast the VIP → Elite raw read).
- **C-02**: Session 21 block (Runtime-live consumers + Legend → Elite). Charter headers
  unchanged → registry stable.

## Session 22 Additions — Value-chain loose ends closed (2 of 3 gaps; 1 deferred with reason)

Backend `tec-core-backend #161` closed the two clean-to-close gaps from the value-chain
audit; the docs are reconciled here. Registry unaffected (no C-doc header lines changed).

| Gap | Fix (code) | Doc reconciliation |
|-----|------------|--------------------|
| **1 — popularity producer missing** | `analytics-service` daily scoring batch (`scoring.service.ts::runScoringBatch`, ADR-013) now ALSO emits `analytics.business.popularity.v1` per active owner (popularity = merchant-activity count, from Analytics' OWN log — no cross-service read). Explorer degrades gracefully without it. | `events-catalog.yaml`: that event flipped **planned → live** (11 live · 1 planned). **C-105** Implementation Status: "Shipped Session 22" producer note. |
| **2 — VIP→Elite raw cross-module DB read** | `vip.getCurrentTier` no longer reads the `EliteRecognition` table; it calls **`EliteService.hasActiveRecognition(owner)`** — a service API (VipModule imports EliteModule), the same R-2-clean pattern as Elite→Legend. | **C-132 §7.5**: seam note flipped ⚠️ R-2-watch → ✅ **R-2 RESOLVED**; module table row + intro note updated. **Every cross-module dependency in `tec-identity-service` is now service-API or event-only — zero raw cross-module reads.** |
| **3 — unversioned events (`user.created`, `wallet.update`)** | **Deferred, tracked (not a silent rename).** Each has live cross-service consumers (`user.created`: identity · analytics · realtime), so C-70 versioning needs a coordinated dual-emit/dual-read migration across independent deploys — a dedicated careful change, not bundled with a feature. | `events-catalog.yaml`: `user.created` note records the decision + rationale; the events gate already accepts them as flagged legacy debt. |

**Honest status:** gaps 1 & 2 are `[Code Verified]` (merged), not yet `[Runtime Verified]`
(fire only when `REDIS_URL` is set on `tec-identity-service` + `tec-analytics-service` and
the batch/consumers run). All 16 KB gates pass, 0 errors.

## Session 23 Additions — Gap 3 begun (event versioning) + phantom-event correction

Acting on the last value-chain loose end (Gap 3: unversioned events). Reading the code
first surfaced two facts that reshaped the task:

- **`wallet.update` was a PHANTOM catalog entry** — cataloged as live+verified, but there
  is **no producer** in code (`tec-wallet-service` XADDs nothing; its only event constant is
  the `payment.completed` it CONSUMES; every `wallet.update` in code is a Prisma
  `tx.wallet.update()` DB write; balance changes reach the client as the *socket* event
  `wallet.updated`, not a stream). **Removed** from `events-catalog.yaml` with a correction
  note — the catalog is code-sourced, so a fictional event can't stay. Nothing to version.
- **`user.created` shipped with no `eventId`** (a C-70 violation) and has **FOUR** live
  consumers (identity · analytics · realtime · notification), not the 3 previously noted.

**`user.created` C-70 rename — Phases 1 + 2 DONE** (`tec-core-backend #162`):
- **Phase 1 (Expand):** the auth producer adds an `eventId` and **dual-emits** to both
  `user.created` and the new `user.created.v1` (shared eventId, MAXLEN-bounded).
- **Phase 2 (Migrate reads):** all **four** consumers (identity · analytics · realtime ·
  notification) now **dual-read** both streams in one `xreadgroup`, deduped by `eventId`
  (`SET NX`, released on error) → exactly-once, gapless, no double side-effects. Identity
  needs no dedup (`findOrCreateUser` is idempotent by username). `analytics.claimEvent`
  is unit-tested.

`events-catalog.yaml`: `user.created.v1` now shows the four consumers; both notes record
Phase 1+2 done. **Only Phase 3 remains** — drop the legacy emit → naming-debt = 0 (safe once
#162 is deployed and consumers are confirmed reading `.v1`); its own follow-up PR.

Registry rebuilt (timestamp only). Events: 13 (12 live · 1 planned). All 16 KB gates pass.

## Session 24 Additions — Gap 3 CLOSED (event versioning complete)

Phase 3 (Contract) shipped (`tec-core-backend #163`): the auth producer now emits **only**
`user.created.v1` — the legacy unversioned `user.created` emit is dropped. The full C-70
rename is done end-to-end (expand → migrate → contract): **naming-debt = 0**.

- `events-catalog.yaml`: legacy `user.created` **RETIRED** (no producer — removed with a
  history note); `user.created.v1` is now the canonical SOLE new-user event.
- Safe ordering: #163 (drop legacy) deploys AFTER #162's dual-read consumers (merged first),
  so no event is missed. The now-silent legacy stream is a harmless no-op the consumers still
  tolerate — a future housekeeping cleanup can drop that vestigial read.
- Events: 12 (11 live · 1 planned) — one fewer after retiring the legacy entry. All 16 gates pass.

**Gap 3 is fully closed.** With the two phantom corrections (Session 22 popularity → live;
Session 23 `wallet.update` removed) and this rename, the events-catalog now has **zero
unversioned-legacy debt** and every entry is code-sourced.

## Session 25 Additions — Nervous System: consumer-liveness sensor → evidence loop

The event layer went from `[Code Verified]` to **observable at runtime**. Two silent
prod breakages this month (Explorer-KYC dead stream · analytics Decimal crash) were both
"a consumer isn't doing its job" and neither tripped any health check — found only by
hand from Railway logs. This closes that gap end-to-end.

| Piece | Repo / Path | Purpose |
|-------|-------------|---------|
| Consumer-liveness sensor | `tec-identity-service/src/modules/health/stream-health.service.ts` + `GET /health/streams` | One Redis client sees EVERY consumer group; read-only XINFO; fail-safe always-200; `EXPECTED` map (11 streams) synced with the CLI twin + events-catalog. (merged, tec-core-backend #167) |
| Gateway aggregation | `tec-api-gateway` `/health/detailed` `streams` field | Relays the sensor verdict through the platform's single aggregation point. **Informational — NOT folded into `status`** (a dead consumer never false-flips the gateway offline, NEW-W). tec-core-backend #168 |
| Hub surface | `tec-app` `/api/health/streams` BFF + pi-test "Consumer Liveness" | The Hub (and any uptime monitor) sees `ok`/`missingGroups`/`degraded`. NOT a second poller (C-96 single-poller stays `/api/health`). tec-app #134 |
| **Evidence producer** | `scripts/verify-runtime.mjs --emit-evidence` | Emits a schema-conforming `health_snapshot` runtime-evidence record from the live XINFO data → the **PRODUCER half of the C-96 loop** (`Reality → Evidence → Governance`). PHS = 10 − 2·missing − 0.5·warnings; binds_to `[C-96, C-92, C-70]`. Verified against a live Redis: healthy → PHS 10.0 exit 0; a dropped `identity-explorer` group on `kyc.verified` → PHS 8.0, `broken_streams: [kyc.verified]`, exit 1 (the exact Explorer-KYC regression, now caught + recorded). |
| Evidence example | `runtime-evidence/examples/consumer-liveness-example.yaml` | Illustrative sample of the emitter's output; validates against the schema. **Runtime Evidence gate: 9 records, 0 errors.** |

### Honest status
- The sensor + emitter are `[Code Verified]`; they become `[Runtime Verified]` when ops
  runs `--emit-evidence` against **prod** Redis and commits the record (no fabricated prod
  telemetry is committed — the KB record above is an explicit example, not a prod reading).
- Registry unaffected (no C-doc header lines changed). Runtime-evidence gate re-run: pass.

## Session 26 Additions — Subscription activation + Pro entitlement (fleet-wide)

Closed the platform's largest pre-campaign gap: every app's in-app **"Pro" button** took a
real Pi payment but activated **nothing** — commerce had no consumer linking payment →
subscription (the old `OrderConsumer` is registered in no module = dead code). Users could
pay and get no entitlement across ~19 apps.

| Piece | Repo / Path | Purpose |
|-------|-------------|---------|
| SubscriptionConsumer | `tec-commerce-service/src/modules/subscription/subscription.consumer.ts` | Consumes `payment.completed.v1`; activates PRO/ENTERPRISE via `SubscriptionService.subscribe` when the payment is a Pro buy (`<slug>_pro_monthly` item_id/product_id or `metadata.plan`). Idempotent; both payment modes; same path as the Hub (P2). New group `commerce-subscription`. tec-core-backend #188. |
| Read path (BFF) | each app `src/app/api/bff/subscription/route.ts` | `GET /api/bff/subscription` → gateway `/api/commerce/subscriptions/status`. Needed because auth `/me` never carries the plan (`getMe` selects none; login hardcodes `subscriptionPlan: null`). Subscription stays commerce-owned (C-47). |
| Pro entitlement UI | 19 app Pro components | Shows "★ You're on Pro" when subscribed, gated on `isActive` + not `isExpired` (30-day pass; no auto-renewal) → ends when the month lapses. Life also: ★ PRO badge + unlimited-goals benefit. |
| Sensor sync | `stream-health.service.ts` + `scripts/verify-runtime.mjs` | Added `commerce-subscription` (and `identity-nexus`, from the Nexus resume fix) to the `payment.completed.v1` EXPECTED map. |
| Docs | `C-02` Session 26 block · `events-catalog.yaml` (`payment.completed.v1` now lists 3 consumers) | Code-sourced; events gate passes (13 events, 0 errors). |

### Honest status
- **[Runtime Verified] = Life only** (a real 5π Life Pro payment → ★ PRO live after redeploy;
  full loop activate → read → show → expire). The other 18 apps are merged `[Code Verified]`
  — each needs its Vercel redeploy + a real payment; earlier (pre-consumer) payments do NOT
  back-activate.
- **Follow-ups (recorded):** no auto-renewal (Pi U2A one-time → renewal reminder flow);
  no server-side downgrade job (a commerce cron flip expired→FREE); price-vs-plan assertion
  at activation (`PLANS.PRO=10π` vs some 5π surfaces). System intentionally excluded
  (`system_supporter` grants nothing, C-110).

## Session 27 Additions — Subscription expiry: lazy self-heal + downgrade sweep + renewal reminder

Closed **two of the three Session 26 follow-ups** (the largest post-campaign
revenue-integrity gap): a lapsed paid subscription used to stay `plan=PRO/status=ACTIVE`
in the DB forever — closed only because every reader also checked `isExpired` (fragile,
easy to forget) — with **no downgrade and no renewal reminder**. Now the period actually
closes and the user is prompted to renew.

| Piece | Repo / Path | Purpose |
|-------|-------------|---------|
| Lazy expiry (self-heal on read) | `tec-commerce-service/subscription.service.ts::getSubscription` | A paid ACTIVE sub past `current_period_end` is flipped to **EXPIRED** with a `SubscriptionHistory` audit row (Invariant #4), idempotently. `isActive` now = `ACTIVE && !isExpired` → every gate closes uniformly. Read never fails if the downgrade write races (P6). No cron needed — reads keep the DB honest. tec-core-backend PR (branch). |
| Renewal signal | same `getSubscription` | `daysRemaining` added to the status payload → frontends show a "expires in N days" reminder (Pi U2A is one-time; no auto-renew). |
| Bulk sweep + internal endpoint | `subscription.service.ts::expireStale` + `POST /commerce/subscriptions/expire-stale` (x-internal-key, constant-time, fail closed) | Downgrades **dormant** lapsed subs nobody reads, one audit row each, fail-safe per row. For an external Railway cron (service-to-service, no user auth). |
| Hub renewal reminder (UI) | `tec-app` `/hub/subscription/page.tsx` | Surfaces `daysRemaining`/`isExpired`: normal "Expires in N days", amber "⏳" in the last 7 days (+ "one-time payment, re-subscribe" note), red "⚠️ Expired — renew to restore Pro". Pure UI over existing status fields. tec-app PR (branch). |

### Honest status
- **No schema change** — uses the existing `EXPIRED` status + `SubscriptionHistory`, so
  **no `prisma db push`** is needed. Subscription stays commerce-owned (C-47).
- `[Code Verified]`: commerce suite **83/83** green + typecheck clean; Hub typecheck clean.
  Becomes `[Runtime Verified]` when a real Pro period lapses in prod (self-heal on next
  status read) and/or ops wires the Railway cron to `expire-stale`.
- Registry unaffected (no C-doc header lines changed).

### Activation floor — last Session 26 follow-up CLOSED (and it was a security gap)
The "price-vs-plan assertion at activation" follow-up turned out to be a **financial-integrity
gap**, not a pricing tweak. `SubscriptionConsumer` derived the plan from the payment's own
**client-set metadata** (`item_id`/`plan`) and activated PRO/ENTERPRISE with **no amount
check** — a user could complete a **dust payment** tagged `_enterprise_monthly` and be
granted ENTERPRISE (50π value) for ~0.1π (underpayment / tier-escalation).

- **Why not gate on `PLANS.PRO` (10π):** each app sets its OWN Pro price (Life/Connection/
  Alert 5π … Titan 25π), all mapping to the single PRO plan — a hard 10π gate would reject a
  legitimate 5π payment (the "paid-and-got-nothing" bug again).
- **Fix:** `planFloorPi` / `coversPlanFloor` (commerce `subscription.service.ts`) enforce the
  LOWEST legit price per tier — **PRO ≥ 5π · ENTERPRISE ≥ 50π** (env-overridable
  `SUBSCRIPTION_MIN_PI_PRO` / `_ENTERPRISE`; 1e-8 epsilon). The consumer enforces it at the
  untrusted-event boundary: **underpayment = permanent drop** (log + ack, never grant/retry);
  **missing amount = fail OPEN** (activate + warn — `payment.completed.v1` carries `amount`, so
  absence = a legacy/malformed event from a real completed payment, not an attack).
- The Hub **direct path is unchanged** — its `verifyPiPayment` already checks `amount ≥
  PLANS.price` (PRO 10 / ENT 50), consistent with the Hub's own PLAN_META. Commerce **94/94**
  green; typecheck clean; no schema change. (Tec-core-backend #204.)

### Subscription-contract regression guard (both sides of the shape)
The fleet-wide Pro-detection incident (Session 26 root-cause) was a *consumer* misparse
of a *correct* backend shape — a BFF read `.data.plan` instead of `.data.subscription.plan`,
silently resolved FREE, and locked Pro OFF for paying users; the unit tests mocked a FLAT
shape and green-lit it. Guard added on **both** sides so it can't recur:

| Side | Where | Guard |
|------|-------|-------|
| **Producer** (commerce) | `tec-commerce-service/src/__tests__/subscription.contract.spec.ts` | Pins the `GET /subscriptions/status` envelope: `{ success, data: { subscription: { plan, isActive, isExpired, current_period_end, daysRemaining } } }` — asserts it is **NESTED** (`data.plan` is `undefined`) + every fleet-depended field passes through + user derives from the verified JWT (P6). Flattening the envelope now fails in ONE place instead of 19 silent breakages. |
| **Consumer** (template) | `tec-template-base` `src/lib/subscription/pro-status.ts` + `src/app/api/bff/subscription/route.ts` + `pro-status.test.ts` | The **canonical** `resolveProStatus` / `resolveProState` — unwraps the nested envelope in ONE place, fails closed to FREE (P6), surfaces `daysRemaining`/`isExpired`. Its test mocks the **real nested shape** (the lesson: "a BFF unit test is only as good as the shape it mocks"). Future apps cloned from the template inherit the correct parser — CLAUDE.md says **import it, don't hand-roll another**. |

Companion PRs: Tec-core-backend #204 (producer contract) · tec-template-base #25
(consumer canonical + guard). Existing apps keep their (now-fixed) per-app resolvers;
the template guard prevents the NEXT app from regrowing the bug.

### Activation visibility — silent paid-activation failures made observable
Every failure this session addressed was **silent** (a paid user simply doesn't get Pro).
Two additions turn paid activation into something you can SEE during the campaign:
- **`getStats()` + `GET /commerce/subscriptions/stats`** (INTERNAL, x-internal-key) — active
  paid counts by tier + expired/cancelled/total + a **recent-upgrade feed** from the
  append-only history (`status=ACTIVE, plan != FREE`). Own-data, read-only, no new infra —
  poll it to watch paid subs climb or catch a stall.
- **`recordRejectedActivation()`** — an underpaid/dropped activation (from the amount-floor
  guard) is written as a **`PAST_DUE` history row** (Invariant #4 — a payment that moved π
  but granted nothing is a financial event, not just a log line); the consumer calls it
  best-effort (audit failure never changes the drop). `PAST_DUE` keeps rejections OUT of the
  "activated Pro" feed while making them queryable per user. Commerce **97/97** green. (#204)

### In-app renewal reminder — reference pattern (Life) → propagated fleet-wide
The Hub shows "expires in N days" (tec-app #138); the app Pro components did not. **Life**
(the Runtime-Verified reference) shipped it first: `useSubscription` exposes
`daysRemaining`/`isExpired` and `LifePro`'s active state shows "Expires in N days" (amber +
re-subscribe nudge in the last week). Pure UI; 21/21 green. (Tec-Life #23)

**Then propagated to the other 16 app Pro components** — the `<App>Pro.tsx` subscription
fetch (byte-identical across apps) now also reads `daysRemaining` (with a period-end
fallback) and the active "★ You're on Pro" card shows the same reminder. Applied via a
fail-closed script (skips any file whose anchors don't match — none did); **typechecked
clean on the 8 apps that had deps installed** (Connection · Zone · Nx · Alert · Analytics ·
Vip · Legend · Epic), and the remaining 8 use the identical edit + confirmed same imports.
PRs: Zone #27 · Connection #29 · Nx #19 · Alert #18 · Explorer #22 · Estate #20 · FundX #16 ·
Nexus #20 · Dx #17 · Epic #23 · Legend #21 · Elite #17 · Insure #17 · Vip #17 · Titan #17 ·
Analytics #31. Every app's Pro card now surfaces its own expiry — no more silent lapse.

> **Audit note:** prices + Pro benefits are ALREADY shown clearly in every app's Pro
> component (price = the same const charged, so no mismatch by construction; benefits are
> described). The only real polish gap was the in-app expiry display above.

## Session 46 Additions — Platform visual identity unified (tec-ui v3.0.0) + one Dependabot policy

Two fleet-wide drifts closed. Both had the same shape: a rule existed, one repo followed
it, and nobody back-adopted it — so the platform diverged quietly for months. Session
record: **C-02 Session 46**. Token authority updated: **C-83**.

### 1. WEALTH moved to the Pi amber — and the fleet actually received it

| Item | Detail |
|------|--------|
| `@yasser172/tec-ui` **v3.0.0** | `gold #FBBF24 → #FBB44A` (sampled from the Pi app's splash mark), `goldDark → #E8962A`, `goldLight → #FDCF7A`. MAJOR because values move; **nothing renamed or removed**. |
| `theme-contract.test.ts` | New. Pins the Pi amber **and** the hex-only format. |
| 23 repos adopted | Hub + 20 domain apps + NBF + Brookfield, each on `^3.0.0` **with its local `tec-design-tokens.css` swept in the same PR**. |
| Excluded, on purpose | `tec-assets` (104 hardcoded hexes) · `tec-commerce` (149) · `tec-ecommerce` (202) — a re-skin, not an upgrade; separate decision. |

**The semver caret trap (root cause).** 18 apps sat on `^1.1.0`, which can *never* resolve
to a 2.x. They were frozen out of the EVL palette from the day v2.0.0 shipped. `npm update`
did exactly what it was told, forever, and nothing warned. **When a shared package takes a
major, the consumers' ranges are part of the release — auditing them is not optional.**

**An app paints from TWO sources.** Proven on Zone before the sweep: package-only bump →
one page carrying `#050816` **and** `#020205`, and two golds. `TEC_COLORS.*` (inline styles)
and `var(--tec-*)` (the app's own token file) must move together, in one change.

**Every token stays a plain 6-digit hex — load-bearing.** Consumers append alpha
(`` `${TEC_COLORS.gold}33` ``, 216 places). A `var()` there yields `var(--tec-gold)33`:
invalid CSS, **no error**, borders that silently stop painting fleet-wide.

### 2. Apps stopped introducing themselves as "TEC App"

15 of the SSO landings still carried the `tec-template-base` placeholder `🔷 TEC App` — on
the one screen where a user decides whether to trust the app they just tapped. Each app now
names itself in caps (`TEC ZONE`), matching the Hub grid / Portal listing / icon wordmark.

> `sso-callback/route.ts` is **plain HTML served before any stylesheet** — it cannot read a
> CSS variable, so its colours are hex literals **by necessity**. Same class of constraint
> as `next/og` (Satori resolves no custom properties). Do not "fix" either into `var()`.

### 3. One Dependabot policy across the fleet — and 112 unmergeable PRs closed

19 repos ran the original config (no `ignore`; a devDependencies-only group). On a platform
pinning **Next 15 / React 18 / @sentry/nextjs v8** that manufactures work nobody can merge:
the standing group PR bumped `typescript → ^7.0.2` and `eslint-config-next → 16.3.1`.

> **Next 15 does not recognise TypeScript 7 as a TypeScript install at all** — Typecheck and
> the build fail before reading a line of source, and **no tsconfig change reaches it**.
> `eslint-config-next`'s major tracks the Next major → 16 on Next 15 is a mismatch by
> construction. Dependabot rebuilt the PR after every merge, so a permanent red check
> followed each repo — which is how a CI signal teaches people to ignore it.

`tec-template-base` had already solved this; NBF and Brookfield inherited it; the fleet never
back-adopted it. Now copied verbatim to all 19 + the Hub: **ignore ALL majors** · one grouped
**minor+patch** PR · `github-actions` grouped the same way. Majors are not abandoned — the
entries come out in the same change that moves an app to Next 16.

**112 stale Dependabot PRs closed** (18 domain apps). Legitimate minors return as one grouped
PR, so nothing is lost. **Left open deliberately:** `tec-core-backend` (16 real per-service
patch bumps — different repo, policy not applied there), `tec-assets` #46 / `tec-commerce`
#54 (excluded repos), and NBF/Brookfield/template-base, whose open PRs are what the new
policy wants.

### Also this session (Hub, CEO-verified on a phone)
Gold topbar band → inner pages only · username chip → a real account menu behind a **3-bar**
glyph (the chevron was rejected) · `Settings` → **Profile** · bottom nav to 5 tabs · wallet
card compacted with a **24h market** delta — labelled *market*, **never** "PNL": the platform
does not compute the user's P&L, and a fiat delta on a held balance is not one. Plus the
traced `TecMark` monogram and the 1024/512/192 + maskable app icons.

### Process rule adopted
Three times this session the CEO asked *"why is there no open PR?"*. In a workflow where the
CEO's role **is** to merge, a pushed branch with no PR is invisible work. **Pushing to the
development branch and opening its PR are one step.**

### 4. The backend needed a DIFFERENT policy, not the same one (tec-core-backend #213)

`tec-core-backend` is the one repo the app config could not be copied into. Reading it
first showed the `ignore`-majors half was **already right** in all 13 service blocks —
which is precisely why this repo never produced the TypeScript 7 PRs the apps drowned in.
The gaps were elsewhere:

| Gap | Detail |
|-----|--------|
| No grouping | One PR per package per service → 16 open PRs a month |
| Root app invisible | `/package.json` is a real Nest app (NestJS 10 · Prisma 5 · helmet · ioredis) and **no block named `/`** — never updated, security included |
| No `github-actions` block at all | `actions/setup-node` on **v4** vs the fleet's v6; `checkout@v4` unpatched |

Two deliberate departures from the app policy:
- **Grouping stops AT the service boundary.** Services deploy independently on Railway, so
  a PR spanning two would let one red check block eleven unrelated deploys. **Thirteen
  grouped PRs is correct here — not one.**
- **Majors ignored for npm, NOT for actions.** Nothing pins an action major, and every
  workflow pins `node-version: '20'` on `ubuntu-latest`, so a runner-action major cannot
  change the Node the build runs on.

Monthly, not weekly: this repo heads the release chain, so churn here is the most expensive
churn on the platform.

**Verified:** #213 merged + 14 of the 16 standing dependency PRs merged, **CI 30/30 green
on `main`**. The policy proved itself at once — the next Dependabot runs opened **#214/#215**
as *grouped* PRs. **#175 and #184 conflicted** because an earlier merge touched the same
service's lockfile — the grouping argument demonstrated live. **#175 wants a read, not a
merge:** `0.14 → 0.15` on a `0.x` package is breaking under semver, and it is on auth.

### 5. Three defects the Dependabot work uncovered in the backend deploy path

Merging the grouped PRs meant watching real CI runs on `main`. That is the only reason any
of this surfaced — none was caused by a dependency bump, and none is visible from reading
the code. Shipped as tec-core-backend **#226** + **#227**.

| # | Defect |
|---|--------|
| a | **The deploy step had never deployed a service.** It stripped the `-service` suffix as well as the `tec-` prefix (`tec-auth-service` → `auth`), and Railway keeps the suffix. Every lookup missed — and `not found` logged a warning and `exit 0`, so the job reported SUCCESS while doing nothing. `api-gateway` has no suffix and was the only name that came out right. |
| b | **A push to ANY `claude/**` branch deployed to PRODUCTION.** `on.push.branches` includes them and the deploy job checked only `event_name == 'push'` — no PR, no review. |
| c | **The auth-service image could not build without the network.** `bcrypt` is native; on musl it downloads a prebuilt binary and falls back to source compile, but the alpine image has no Python. One `ECONNRESET` killed the build of the platform's identity authority. |

> **The sharpest lesson: a defect can be load-bearing.** (a) was the access control for (b).
> Every branch deploy asked for the wrong name, missed, and exited 0. Fixing the name removed
> that accidental safety net — and the deploy job in the fix's own PR ran **45 seconds against
> production** instead of skipping. Repairing a bug without asking what it was silently
> preventing is how a fix becomes an incident.
>
> Compounding it: **#226 squash-merged only its first commit**, so `main` briefly carried the
> name fix *without* the guard — the most dangerous of the three combinations. Check what a
> squash actually took when a PR carries more than one commit.

### 6. …and the deploy actually deployed, for the first time (2026-08-28)

Fixing the name (§5a) turned a silent `exit 0` into a real red run: `identity-service`
**not found**, while four sibling services deployed. The temptation was to guess. Instead
the failure branch was made to print what the token can see — and the answer was one
character wide.

Three services carried a **trailing space** in their Railway name:

```
- identity-service :      ● Online      ← space          - wallet-service:  ● Online
- commerce-service :      ● Online      ← space          - auth-service:    ● Online
- notification-service :  ● Online      ← space          - kyc-service:     ● Online
```

The correlation was exact: of the five services in that run, the four without the space
deployed and the one with it failed. Renamed in the Railway dashboard (an owner action,
not a code change) → **`Deploy (tec-identity-service)` went green.** That is the first
time this pipeline has ever deployed a `-service` — every previous green was the swallowed
`exit 0`.

> **Two lessons, and the second is the one that generalises.**
>
> A whole class of bug can be one invisible character. Nothing in the repo, the Dockerfile
> or the workflow was wrong; a name had a space nobody could see.
>
> And: **when a fix produces a red run, the red run is the deliverable.** The instinct is
> to explain it away — token scope, wrong project, stale config, all plausible. Printing
> what the tool actually sees cost four lines and settled it in one run. Three plausible
> theories are worth less than one piece of evidence.

Also hardened while there: `--service $VAR` was unquoted, so a name containing whitespace
could never be addressed at all — the shell silently dropped it. Quoted now, so the rename
cannot be undone later by a shell detail. (tec-core-backend #229 · #230 · #231)

**Verified rather than assumed:** `class-validator 0.14 → 0.15` (breaking under semver on a
`0.x`, on the auth path) was installed and exercised before merging — typecheck clean, 47/47,
plus a purpose-written probe confirming the auth DTOs still **reject** empty / non-string /
oversized / malformed input. A validation library that fails *open* is a P6 violation, and a
green suite does not prove it didn't.

### Open after this session (all decisions, nothing blocked)

| # | Item | Why still open |
|---|------|----------------|
| 1 | `tec-assets` / `tec-commerce` / `tec-ecommerce` **re-skin** | 104 / 149 / 202 hardcoded hexes — real design work, not a sweep. **3 of 26 repos stay on the old palette**: a known deliberate gap, not drift. |
| 2 | npm **Trusted Publishing** | Tokens expire **25 Nov 2026**. The Aug 26 expiry caused a publish `E404` — on a scoped package `E404` on `PUT` means *auth failure*, not "not found". Do it before the next expiry, not after. |
| 3 | Backend grouped PRs | ✅ **CLOSED.** 7 of 12 merged directly; the 5 stale ones (217 · 220 · 221 · 223 · 224) could not be rebased from here, so their updates were applied against current `main` instead (#228, 339 tests green) and Dependabot auto-closed all five. One bump was deliberately NOT taken: #217 would have **downgraded** identity's `@typescript-eslint/parser` `^8.65.0 → ^8.59.1` — resolved as `max(main, PR)`, not copied. |
| 4 | **Fleet deploy of the palette** | Merged ≠ deployed. The apps deploy together or two palettes are on screen at once. |
| 5 | **Runtime-verify beyond 3 apps** | Only Life, Zone and Epic were seen on a real device; the other 20 are `[Code Verified]` and nothing more. `scripts/verify-palette.mjs` now turns this from a per-release chore into one command — it needs running from a machine with network access. |
