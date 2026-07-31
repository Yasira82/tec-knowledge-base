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

**`user.created` C-70 rename — Phase 1 (Expand) DONE** (`tec-core-backend #162`): the auth
producer now adds an `eventId` and **dual-emits** to both `user.created` and the new
`user.created.v1` (shared eventId, MAXLEN-bounded). Consumers still read the legacy stream →
behaviour-neutral, zero double-processing. `events-catalog.yaml`: added `user.created.v1`
(live), corrected the `user.created` consumer list + migration note.

**Deferred with reason (production-mindset):** Phase 2 (make analytics/notification consumers
idempotent BY eventId, then cut over to `.v1`) + Phase 3 (drop legacy emit → naming-debt = 0).
The analytics/notification consumers are **not** idempotent today, so a same-PR dual-**read**
would double-count users + duplicate welcome notifications on a live Mainnet platform. Each
phase is its own careful PR. Registry rebuilt (timestamp only). Events: 13 (12 live · 1 planned).
