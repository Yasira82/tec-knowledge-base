# C-131 — BROOKFIELD INFRASTRUCTURE RUNTIME

## TEC Ecosystem — Infrastructure & Institutional Assets Layer

> **Truth State:** `[Future Vision]`
> **Governance State:** `[Draft]`
> **Verification:** `[Assumed]`
> **Authority Scope:** `[Domain]`
> **Build Gate:** Phase 3 (10k+ users + legal clearance)
> **Legal Gate:** REQUIRED before any real Pi investment (securities / REIT law)
> **Domain:** `brookfield.tecosystem.app` (live pattern now) → `brookfield.pi` (future)

---
## Deployment Status (2026-07-31)

> **Truth State:** `[Current State]` for the deployed app + live payment · `[Future Vision]` for the full runtime below
> **Verification:** `[Runtime Verified]` — deployed on Mainnet, real Pi payment live (SSoT: `architecture/app-fleet.yaml` → `live-readonly-gated`)

**Brookfield is deployed on Mainnet** with Hub SSO and dual-mode (ADR-007) Pi payment live:
- **Domain:** `brookfield.tecosystem.app` · **Pi App ID:** `brookfield-ftq4` · **APP_SOURCE:** `brookfield`
- **Payment:** real Pi subscription — Mode 1 (Hub) + Mode 2 (standalone); `PI_API_KEY_BROOKFIELD` set on payment-service.
- **Hub SSO:** enabled (in `/api/auth/sso` ALLOWED_TARGETS + Hub domain registry).
- **Growth:** referral loop wired (C-133).
- ⚠️ **Financial mechanics HARD-GATED (read-only):** Brookfield investment / REIT mechanics stay simulated/read-only until legal + payment-service custody + SYSTEM (Invariant #8). Only the Pro subscription processes real Pi.

**Still `[Future Vision]`:** the gated financial mechanics + the advanced runtime described below — vision, not yet built.

---

## Institutional Identity

```
Infrastructure Runtime
System of Institutional Assets (B2B / B2I Layer)
```

---

## Mission

Enable the ownership, financing, governance, and operation of
large-scale assets — infrastructure projects, institutional real
estate, and asset funds — in the Pi economy.

---

## Core Question

```
"How do we own, finance, and operate large-scale assets in the Pi economy?"
```

---

## Institutional Role

```
Brookfield is the institutional counterpart to Estate.

Estate    = individual / SME property   (B2C — "where do I live?")
Brookfield = institutional / infrastructure assets (B2B/B2I — "who owns the project?")

They share Zone verification but serve different SCALES:
  Airbnb (Estate)  vs  Blackstone (Brookfield)
  Zillow (Estate)  vs  CBRE (Brookfield)

Brookfield fills the MISSING MIDDLE of the Pi capital stack:
  FundX      raises the capital        ("how do we fund it?")
  Brookfield owns + operates the asset ("who owns the project?")
  Estate     sells the retail units    ("who lives here?")
```

---

## The Capital Stack (Brookfield + FundX, not above it)

```
Brookfield does NOT sit above FundX — they are complementary:

  FundX      = small-to-medium capital coordination
  Brookfield = large-scale institutional capital + asset ownership

  Pi Network (Settlement)
      ↓
  TEC Identity (Hub + Zone)
      ↓
  Capital Formation      → FundX (raise) + Brookfield (own)
      ↓
  Asset Ownership        → Assets (digital) + Estate (B2C) + Brookfield (institutional)
      ↓
  Operations             → Commerce + Titan
      ↓
  Intelligence           → Analytics + TEC AI
```

---

## 🔴 Custody + Legal Hard-Gate — the DEFINING constraint (P0)

```
Brookfield is MORE regulated than FundX (C-113) or Insure (C-129):

  FundX      = capital coordination (some regulatory avoidable)
  Insure     = escrow custody (money-transmission)
  Brookfield = infrastructure investment funds + REITs
             = SECURITIES LAW in most jurisdictions

Therefore NO real Pi investment / fund / REIT mechanic ships until ALL of
these are documented-done — same posture as FundX pool mechanics (C-113 §11):

  1. LEGAL CLEARANCE FIRST — securities / REIT / institutional-investor law
     reviewed for the target jurisdiction, BEFORE any real Pi movement.
  2. payment-service CUSTODY — every invested π is held/moved/distributed BY
     tec-payment-service (DECIMAL(20,8), outbox, ADR-004; Invariant #8).
     brookfield-service NEVER holds capital — it records the asset + governance
     state and issues intents, never balances.
  3. SYSTEM GOVERNANCE (C-110) — permitted asset classes + fund types + return
     models + multi-party governance workflows approved as governed workflows;
     full ActorContext + audit trail.
  4. FundX V2 operational — Brookfield's financing integrates FundX; it does not
     re-implement capital raising.

Until ALL of the above exist, Brookfield ships **simulated / educational
read-only ONLY** — sample institutional asset portfolios, definitions, and
governance illustrations. NO real Pi, NO investment, NO custody, NO REITs.
```

---

## Authority Boundary

### Brookfield OWNS

```
Asset Records:
  Infrastructure Project record (Energy / Data / Transport)
  Institutional Asset record (Hotels / Malls / Factories)
  Real Estate Fund definition (collective ownership structure)
  Asset lifecycle + status

Asset Governance:
  Multi-party decision records (proposals + votes — recorded, not executed)
  Ownership-stake register (by ID reference)
  Governance workflow COORDINATION (SYSTEM governs which are permitted)
```

### Brookfield DOES NOT OWN

```
Capital custody        → tec-payment-service (Invariant #8) — never brookfield-service
Capital raising        → FundX (C-113) — Brookfield coordinates, never re-implements
Operations execution   → Titan (C-130) enterprise operations
Verification           → Zone (C-120) verifies asset/owner/agent — presented, never minted
Legal compliance       → external counsel (securities / REIT)
Valuation truth        → external market data (presented via Analytics, never asserted)
Retail unit sale       → Estate (C-114, B2C) / Commerce
Reputation             → Legend (C-126) · Zone + Connection
Metrics                → Analytics (C-105)
```

---

## The 5 Asset Classes — phased

```
| Asset Class               | Phase | Note                                   |
|---------------------------|-------|----------------------------------------|
| Real Estate Funds         | V1    | simulated/educational first            |
| Infrastructure Projects   | V2    | needs Zone verification + legal        |
| Institutional Assets      | V2    | needs NBF/Titan integration            |
| Infrastructure Financing  | V3    | needs FundX V2 + legal                 |
| REITs                     | V3+   | full regulatory clearance required     |
```

---

## Technical Architecture (Planned)

```
Pi Browser (WebView)
    ↓
brookfield.tecosystem.app (Vercel — Next.js 15)
[Clone from tec-template-base]
    ↓
BFF /api/bff/brookfield/* routes (server-only)
    ↓
API Gateway :4000 (Railway)
    ↓
brookfield-service (NEW — Phase 3; records asset + governance state ONLY)
  Reads / coordinates (ID-only references):
    payment-service → capital custody (the ONLY π custodian)
    fundx-service   → capital raising integration (C-113)
    titan-service   → operations (C-130)
    zone-service    → asset / owner verification (C-120)
    analytics-service → performance + valuation presentation (C-105)
    system-service  → permitted asset classes + governance (C-110)
```

### Core Entities

```typescript
interface InstitutionalAsset {
  asset_id:       string;
  type:           AssetClass;   // INFRA_PROJECT | INSTITUTIONAL | RE_FUND | REIT
  name:           string;
  scale:          string;       // indicative scale band (never asserted as truth)
  zone_verified:  boolean;      // presented from Zone — never minted here
  fund_ref?:      string;       // FundX fund id (capital raised THERE)
  status:         AssetStatus;  // DRAFT | VERIFIED | FUNDED | OPERATIONAL | CLOSED
  simulated:      boolean;      // V1 = always true (no real capital)
}

interface GovernanceRecord {
  record_id:      string;
  asset_id:       string;
  proposal:       string;
  parties:        string[];     // ID references
  status:         'OPEN' | 'DECIDED';   // recorded — execution is elsewhere
}
```

---

## Security Model

```
Isolation (P6):  identity from the tec_user session cookie server-side —
                 never a query param or body. No session → fail closed.
Capital:         held ONLY by payment-service (Invariant #8) — brookfield-service
                 records state + issues intents, never balances.
Governance:      multi-party records are append-only + audit-trailed; SYSTEM
                 governs which asset classes + workflows are permitted.
Simulated flag:  V1 assets carry simulated=true; no real-Pi path exists in V1.
```

---

## Revenue Model

```
Brookfield Free:
  Browse simulated institutional asset portfolios (educational)

Brookfield Pro (subscription — via Hub):
  Advanced asset analytics · governance tooling · portfolio views

Institutional Revenue (Phase 3+ — POST legal clearance):
  Asset management + coordination fees
  Fund administration (with FundX)
  Infrastructure financing facilitation (never custody)

⚠️ NONE of the institutional revenue flows ship before the Custody + Legal
   Hard-Gate is documented-done.
```

---

## Build Protocol

```
Brookfield V0/V1 — Scaffold + Portal Readiness + simulated portfolios:
  □ Clone tec-template-base → identity / domain / slug (brookfield) / legal
  □ Read-only simulated institutional asset portfolio + /asset/[id] + governance demo
  □ Brookfield Pro (real Pi U2A subscription — the Portal "Process a Transaction" gate)
  □ Hub SSO enablement (ALLOWED_TARGETS + domain registry)

Brookfield V2+ (POST Custody + Legal Hard-Gate — legal + payment-service custody +
  SYSTEM + FundX V2): real infrastructure projects → institutional assets →
  infrastructure financing → REITs. NONE ship until all P0 gates documented-done.
```

---

## Positioning Statement

```
Brookfield is not a property marketplace.
Brookfield is the Infrastructure & Institutional Assets Runtime of TEC.

Estate answers "where do I live?"
Brookfield answers "who owns the project?"

The Pi economy will one day need Pi-native data centers, renewable energy
for Pi mining, and infrastructure for Pi communities. Someone has to own,
finance, and operate them.

Brookfield is that platform — the missing middle between raising capital
(FundX) and selling units (Estate).

But institutional scale carries institutional law:
  Portal first. FundX V2 before Brookfield. Legal clearance before any Pi.
```

---

## Related Documents

- **C-00** Platform Constitution · **C-47** Kernel Spec (Invariant #8 custody, P6, ActorContext)
- **C-113** FundX (capital raising + the hard-gate posture Brookfield mirrors)
- **C-114** Estate (the B2C counterpart) · **C-130** Titan (operations) · **C-120** Zone (verification)
- **C-105** Analytics · **C-110** System (governance) · **C-129** Insure (custody-gate precedent)
- **C-12** Dual-Mode Payment (anti-regression) · **C-123** Pi Browser Session & Cookie Spec
