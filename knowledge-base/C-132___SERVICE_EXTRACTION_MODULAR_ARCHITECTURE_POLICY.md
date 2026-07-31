# C-132 — SERVICE EXTRACTION & MODULAR ARCHITECTURE POLICY

## TEC Platform — Modules-First Architecture (ADR-011 detail)

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`
> **Authority Scope:** `[Platform]`
> **Decision Record:** ADR-011 (C-64) — this document is its full detail (the ADR-007 → C-76 pattern)
> **Decision Authority:** CEO (C-47)

---

## 0. Why this document exists

TEC has **24 apps**. The single most expensive architectural mistake available to
the platform is the reflex **"1 app = 1 microservice"** → 24 deploys, 24 databases,
24 health checks, 24 points of failure — before the platform has the load to justify
even 5. This document is the **permanent guardrail** against that reflex.

It answers, once and for all:

```
When does an app get its OWN backend service?
When is it a MODULE inside an existing service?
When is it a FRONTEND only?
```

Authority hierarchy (C-00): this sits below the Kernel Spec (C-47) and Domain
Ownership (C-68); it **refines** how their boundaries are physically deployed. It
never weakens Invariant #8 (single custodian) — see §4.

---

## 1. Modules-First Principle

The correct layering has **three** levels, not two:

```
App  →  Domain Module  →  Service
```

**NOT:**

```
App  →  Microservice          ← the anti-pattern
```

An **App** (a Next.js frontend) and a **Service** (a deployed backend) are two
different levels. Equating them is the mistake. A domain's backend logic starts life
as a **module inside an existing service** and is only **extracted** into its own
service when the runtime proves it must be (§5).

> **Rule R-1 (Modules-First):** A new domain's backend ships as a **module inside an
> existing service** by default. Creating a new microservice requires an explicit
> extraction trigger (§5) — documented, not assumed.

**Proven in production today:** Life, Connection, and Zone are all modules inside
`tec-identity-service` (`identity/life/*`, `identity/connection/*`,
`identity/zone/*`) — not separate services. This is the reference pattern.

---

## 2. Design-for-Extraction (the companion principle)

Modules-First is only cheap **later** if the module has a clean seam **now**. A
module that is a known future-service candidate (e.g. Explorer → Search) must be
built so extraction is **mechanical, not a redesign**:

```
✅ Own module folder            src/modules/<domain>/
✅ Own DB tables, namespaced     <domain>_*  (no shared tables with the host)
✅ Own cache namespace           <domain>:*  (C-68 §7)
✅ Talks to sibling modules ONLY through service APIs / events — never a cross-module DB join
✅ Own event names (C-70)        <domain>.<action>.v1
```

> **Rule R-2 (Design-for-Extraction):** Any module flagged as an extraction
> candidate (§6 "Extractable" column) is built with a hard internal seam from day one.
> Cross-module DB joins inside the host service are **forbidden** for these modules —
> they would weld the module to the host and make extraction a rewrite.

**Explorer is the canonical example.** Search (index / ranking / full-text /
recommendations / filters) has a fundamentally different scaling profile from CRUD,
so it is the **first** real candidate to become a standalone `search-service`. It may
remain a module for a while, but it is designed from the start to be lifted out.

---

## 3. Domain Ownership (reference)

This policy governs **physical deployment** (service vs module); it does **not**
redefine **write authority**. Write authority is owned by C-68 (Domain Ownership
Matrix) and is unchanged:

- One domain → one owning authority → one writer → one event publisher.
- A module inside a host service still owns **its own** tables + events; the host
  service does **not** get to write the module's domain.
- Moving a domain from module → service **must not** change its owner or its event
  contract — only where it is deployed.

> **Rule R-3:** Extraction is a **deployment** change, never an **ownership** change.
> If extraction would change who owns a domain, that is a separate C-68 decision.

---

## 4. Financial Boundary — the ONE non-negotiable (regardless of scale)

Kernel Invariant #8: **`tec-payment-service` is the single custodian of Pi.** No
scaling argument, no "it's just a module", no convenience ever overrides this.

Consequences for this policy:

```
Payment-service ALONE:
  • moves Pi          • approves payments      • records financial transactions
  • holds balances (DECIMAL(20,8))             • owns the outbox (ADR-004)

FundX / Insure / Brookfield / NBF are NOT custody services.
They are STATE + WORKFLOW + APPROVAL modules that issue INTENTS to payment-service.
  FundX     = pool state + investment logic + approval  →  payment-service moves the π
  Insure    = risk state + escrow record + release intent →  payment-service custodies the π
  Brookfield= asset/fund state + governance             →  payment-service + FundX move capital
```

> **Rule R-4 (Financial Hard-Gate):** No module or service other than
> `payment-service` may hold, move, or compute Pi balances. The highest-financial-risk
> apps therefore need **no custody service of their own** — they need a state module +
> payment-service custody. (This is the FundX C-113 / Insure C-129 custody hard-gate,
> generalized.) `Wallet` balances live within the payment custody boundary; a separate
> `wallet-service` is an extraction reserved by C-68, not a requirement to build now.

---

## 5. Runtime Extraction Criteria — WHEN a module becomes a service

"It has business logic" is **not** a criterion — every app has business logic.
Extraction is justified when **any one** of these four real signals appears **in
production** (extract-on-load, not extract-on-imagination):

| # | Trigger | The question it answers |
|---|---------|--------------------------|
| **T1** | **Different scaling profile** | Does this domain scale on a different axis (search index, realtime fan-out, heavy aggregation) than its host's CRUD? |
| **T2** | **Different consistency / security boundary** | Does it need an isolation, consistency, or blast-radius boundary the host cannot give it? *(This one can justify extraction BEFORE load.)* |
| **T3** | **Independent deploy cadence** | Does it change so much more often than its host that co-deployment is friction / risk? |
| **T4** | **Different team ownership** | Is a distinct team going to own it end-to-end? |

```
extract-on-load  =  start simple → watch production → split when reality forces it
                    NOT when you imagine it might one day be big.
```

> **Rule R-5:** Extraction requires a **documented** trigger (T1–T4) observed in
> production (T2 may be pre-emptive when it is a security/consistency boundary). A
> "might grow" hunch is not a trigger.

---

## 6. Extraction Decision Matrix

Read top-to-bottom; the first row that matches decides.

| If the domain… | …then it is | Example |
|---|---|---|
| moves/holds Pi | **payment-service only** (never its own) | FundX, Insure, Brookfield custody |
| is one of the 11 live core services | **its own service** (already extracted) | auth, payment, commerce, asset, analytics, … |
| has a **T1–T4** trigger observed in prod | **extract to its own service** | Explorer → search-service (when load hits) |
| owns real backend state, no trigger yet | **module in an existing service** (design-for-extraction if a candidate) | Life, Connection, Zone (live); Estate, FundX-state, Explorer, Insure-state, NX |
| owns no backend state — only reads/orchestrates others | **frontend only** (BFF over existing services) | Nexus, TEC AI, System, DX, Titan, VIP, Elite, Epic, Legend, NBF, Brookfield |

---

## 7. Current Mapping — Apps → Modules → Services

### 7.1 The live backend services (11) — no additions planned

```
tec-api-gateway (4000)     tec-notification-service (4008)
tec-auth-service (4001)    tec-realtime-service (4009)
tec-payment-service (4002) tec-storage-service (4010)
tec-commerce-service (4003)
tec-identity-service (4004)  ← hosts Life / Connection / Zone / Explorer / Legend / NBF modules
tec-kyc-service (4005)
tec-asset-service (4006)
tec-analytics-service (4007)
```

> The target service count **now** is **these 11 — unchanged.** Not 12–18. The next
> service is created only when §5 fires.

### 7.2 Bucket A — App owns / is backed by a core service (already extracted)

| App | Backing service |
|-----|-----------------|
| Hub | auth-service + identity-service |
| Commerce | commerce-service |
| Ecommerce | commerce-service (marketplace scope) |
| Assets | asset-service |
| Analytics | analytics-service |
| Alert | notification-service |

### 7.3 Bucket B — App runs as a MODULE inside an existing service

| App | Host service | Status | Extractable? (design-for-extraction) |
|-----|--------------|--------|--------------------------------------|
| **Life** | identity-service (`identity/life/*`) | ✅ live | when personal-data read load grows |
| **Connection** | identity-service (`identity/connection/*`) | ✅ live | graph/messaging → may sit on realtime-service later |
| **Zone** | identity-service (`identity/zone/*`) | ✅ live | when it becomes an external standard (`zone.pi`) |
| **Explorer** | identity-service (`identity/explorer/*`) | ✅ live | **YES — first candidate** → `search-service` (T1 scaling); built with the clean seam |
| **Legend** | identity-service (`identity/legend/*`) | ✅ live | read layer (append-only outcomes); scores served from Analytics |
| **NBF** | identity-service (`identity/nbf/*`) | ✅ live | business identity; graduates a business INTO Titan (C-130) |
| **Estate** | estate module (host: commerce/identity) | planned | when real inventory/leases appear |
| **FundX** | fundx state module | planned | custody stays in payment-service (R-4) forever |
| **Insure** | insure state module | planned | custody stays in payment-service (R-4) forever |
| **NX** | opportunity module | planned | low — light index over commerce/connection |

> **Live modules in `tec-identity-service`:** this table lists the original 7 (identity ·
> life · connection · zone · explorer · legend · nbf), but the host has since grown to
> **17 domain modules** as Bucket-C apps were promoted (R-1/R-5). The full, code-verified
> list + per-module DB namespace + events + seam status is the **§7.5 Module-Seam Audit**
> below. Each owns namespaced tables (`<domain>_*`); cross-talk is event-only except the
> one flagged VIP→Elite in-service read — so extraction stays mechanical. This is the
> Modules-First law proven in production, not on paper.

### 7.4 Bucket C — Frontend only (consumes existing services via BFF)

| App | Consumes |
|-----|----------|
| Nexus | analytics + connection + commerce |
| TEC AI | analytics + zone + life + connection |
| System | all services (governance / monitoring) |
| DX | developer APIs (SDK distribution) |
| Titan | analytics + system + zone + commerce (enterprise console) |
| VIP | auth (subscription — Hub PRO) + life + commerce |
| Elite | analytics + legend |
| Epic | life + analytics |
| Brookfield | estate + asset |

> A Bucket-C app **may** grow a Bucket-B module later — this already happened: Legend
> (read-model) and NBF (business identity) started frontend-only and were promoted to
> live `identity/*` modules (July 2026) following R-1/R-5, with no new service. Epic
> (a projects table) is a likely next promotion. Promotion is never a reason to spin a
> new service.

### 7.5 Module-Seam Audit — `tec-identity-service` (2026-07-31)

> **Truth State:** `[Current State]` · **Verification:** `[Code Verified]` — read from
> `src/modules/*` + `prisma/schema.prisma` in `tec-core-backend`.

**Finding — the module count grew past what §7.2/§7.3 recorded.** §7.2 named **7** live
modules; the host service now runs **17 domain modules** (many "planned"/Bucket-C apps
were promoted to live `identity/*` modules following R-1/R-5). Each owns namespaced
tables — the Modules-First seam held as the platform grew. Full audit:

| Module | Folder | DB namespace (Prisma) | Events | Seam / extraction |
|--------|--------|-----------------------|--------|-------------------|
| identity (core) | `identity/` | `User·Profile·Kyc·Role·UserRole·Session·AuditLog` | — | host core — not extracted |
| life | `life/` | `LifeGoal·LifePreference` | — | ✅ clean |
| connection | `connection/` | `Follow·TrustEdge·ProcessedTrustEvent·ConnectionNotification` | emits `connection.milestone.v1` · consumes `order.paid.v1` | ✅ clean (event-only cross-talk) |
| zone | `zone/` | `ZoneEntity·ZoneEvidence` | emits `zone.badge.issued.v1` | ✅ clean |
| explorer | `explorer/` | `ExplorerBusiness` | consumes `kyc.*` · `analytics.business.popularity.v1` | ✅ **T1 extraction candidate → `search-service`** (R-2) |
| legend | `legend/` | `LegendProfile·LegendAchievement·LegendBadge` | consumes `payment/epic/zone/connection/fundx` | ✅ clean (append-only read layer) |
| nbf | `nbf/` | `NbfBusiness` | — | ✅ clean |
| elite | `elite/` | `EliteRecognition` | — | ✅ clean |
| epic | `epic/` | `EpicProject` | emits `epic.project.completed.v1` | ✅ clean |
| vip | `vip/` | `VipTierDef·VipMembership` | — | ⚠️ **reads `EliteRecognition` directly** (see below) |
| insure | `insure/` | `InsureProtection·InsureRiskProfile` | — | ✅ state module — custody stays in payment-service (R-4) |
| system | `system/` | `SystemPolicy·SystemTierDef·SystemCapability` | — | ✅ clean |
| dx | `dx/` | `DxSdk·DxTemplate·DxCapability·DxGuide` | — | ✅ clean |
| nx | `nx/` | `NxOpportunity` | — | ✅ clean |
| alert | `alert/` | `AlertNotification` | — | ✅ clean |
| titan | `titan/` | `TitanOrg·TitanMember` | — | ✅ clean |
| pioneer | `pioneer/` | `_registry.ts` SSoT (C-134) | — | runtime charter (C-134) |

> ⚠️ **Seam note — VIP → Elite (R-2 watch):** `vip.getCurrentTier` reads the `EliteRecognition`
> table directly (to lift the base tier to `ELITE` — the Elite→VIP value-chain edge, C-128).
> This is acceptable **only** because both are modules **inside the same service**. If VIP
> or Elite is ever extracted, this read MUST become an Elite **service API call** or an
> **event** consumption — a direct cross-service DB read would violate R-2. Recorded here so
> the coupling is not forgotten at extraction time. No other cross-module DB read was found;
> all other cross-talk is event-only (R-2 satisfied).

> **Extraction posture:** Explorer is the one flagged T1 candidate (`→ search-service`).
> Everything else stays a module until a documented §5 T1–T4 trigger — Modules-First (R-1).

---

## 8. Enforcement

- **PR review:** a PR that creates a **new backend service** must cite the §5 trigger
  (T1–T4) it satisfies, or it is rejected (Modules-First, R-1).
- **PR review:** a PR that lets any non-payment service move/hold Pi is a **P1
  violation** (R-4 / Invariant #8) — block.
- **PR review:** a cross-module DB join inside a host service for an extraction
  candidate (§6) is rejected (R-2).
- **Extraction PR:** must preserve the C-68 owner + the C-70 event contract unchanged
  (R-3) — deployment-only diff.

---

## 9. Summary

```
1 app ≠ 1 service.        App → Module → Service.
Modules-First.           New service only on a documented T1–T4 trigger.
Design-for-Extraction.   Candidates (Explorer) get a clean seam from day one.
Financial Hard-Gate.     payment-service is the ONLY Pi custodian — always.
extract-on-load.         Split when production forces it, not when you imagine it.
Target now: 11 services. The other domains are modules or frontends.
```

---

## Related Contents

- C-47 — Kernel Spec (Invariant #8 — single custodian; P5 Layer Responsibility)
- C-64 — ADR-011 (this document is its full detail)
- C-68 — Domain Ownership Matrix (write authority — unchanged by this policy)
- C-70 — Event Governance Spec (event contract preserved across extraction)
- C-76 — ADR-007 Pi Payment Ownership (custody authority)
- C-113 — FundX (custody hard-gate, the pattern generalized in §4)
- C-129 — Insure (custody hard-gate)
- C-108 — Explorer (the first extraction candidate → search-service)
- C-20 — Backend Services · C-65 — New Backend Service Template
