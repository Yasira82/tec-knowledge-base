# C-113 — FUNDX INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Future Vision]
**Governance State:** [Draft]
**Verification State:** [Unverified]
**Authority Scope:** [Application]
**Decision Status:** [Exploratory]

---

## 1. MISSION

Enable governed collective capital formation on Pi Network — allowing TEC users to pool Pi resources, co-invest in shared goals, and earn returns within a legally and technically sound framework.

---

## 2. INSTITUTIONAL ROLE

```
System of Production — Capital Coordination Infrastructure
```

---

## 3. ECONOMIC PURPOSE

تجميع رأس المال بطريقة منظمة ومحكومة.

- بدون FundX: تجميع Pi يحتاج trust يدوي → لا يحدث على النطاق الواسع
- بوجود FundX: governed pools + transparent returns + audit trail
- اقتصادياً: capital velocity increases → Pi economy deepens

---

## 4. AUTHORITY BOUNDARY

### Owns
- Investment pool creation and management UI
- Pool contribution and withdrawal flows
- Return distribution calculations
- Fund charter display (governance rules of each pool)
- Investor portfolio view

### Does NOT Own
- Pool capital custody (tec-payment-service holds Pi balances)
- Pool governance authority (SYSTEM defines pool rules — C-110)
- Legal compliance verification (requires external legal consultation)
- Asset collateral (tec-asset-service — C-102)

### Interface Points
```
OUTBOUND:
  /hub?pay=1&...        → Mode 1 payment for pool contributions
  Pool governance events → SYSTEM (C-110) for policy enforcement
  Capital flow data     → Analytics (C-105)
  Pool workflows        → Nexus (C-109) for multi-party coordination

INBOUND:
  tec_user cookie       → investor identity
  KYC verification      → tec-kyc-service (4005) REQUIRED before investment
  Pool governance       → SYSTEM policies for pool type approval
  payment.completed.v1  → contribution confirmation
```

---

## 5. TECHNICAL ARCHITECTURE

```
Planned Stack:
  Next.js 15 App Router + TypeScript strict
  @yasser172/tec-ui (shared design system)
  tec-payment-service (4002) — pool balance management
  tec-kyc-service (4005) — mandatory KYC before participation
  tec-analytics-service (4007) — pool performance metrics
  Nexus (C-109) — multi-party contribution workflows

Critical Pre-Conditions (must be met before launch):
  1. Legal consultation on Pi-denominated investment pools
  2. KYC maturity (≥ 90% verification success rate)
  3. SYSTEM pool governance policies defined
  4. tec-payment-service pool escrow pattern implemented

Pool Architecture (planned):
  Pool Charter:    rules, target, min contribution, duration, return model
  Pool State:      open | funding | locked | distributing | closed
  Contribution:    payment to pool escrow wallet
  Distribution:    pro-rata return based on contribution % + pool returns

Compliance Requirement:
  Educational pools only (Phase 1 — C-47 roadmap note)
  No promise of guaranteed returns
  Pool charter must disclose all risks
  Investor must explicitly acknowledge charter before contributing
```

---

## 6. SECURITY MODEL

```
Highest Financial Risk App in TEC:
  FundX handles pooled capital — security breach = multi-user loss

Mandatory Pre-Conditions:
  KYC verified investor (no anonymous pool participation)
  Admin approval for each pool charter (SYSTEM — C-110)
  Legal review of return model before launch

Pool Integrity:
  Pool balance: DECIMAL(20,8) in tec-payment-service (never in FundX)
  Distribution calculation: server-side only (FundX UI displays, never computes)
  Audit trail: every contribution + withdrawal + distribution logged
  Immutable pool charter: once pool is live, terms cannot change

Invariant Extension:
  Pool balance NEVER goes negative (extends System Invariant #1)
  No distribution without confirmed returns (extends Invariant #2)
  Every pool action has full actor context
```

---

## 7. REVENUE MODEL

**Transaction-Based (Investment Infrastructure)**

| Channel | Mechanism | Notes |
|---------|-----------|-------|
| Pool Management Fee | % of pool capital (ongoing) | Primary |
| Success Fee | % of returns above target | Secondary |
| Premium Pool Creation | Fee to create verified pool | Phase 2 |

---

## 8. KEY METRICS

```
KYC Completion Rate:         ≥ 95% before FundX launch
Pool Contribution Success:   ≥ 99% (payment pathway reliability)
Distribution Accuracy:       100% (pro-rata within 0.00000001 Pi)
Pool Charter Compliance:     100% (no pool live without SYSTEM approval)
Investor Acknowledgment:     100% (explicit charter acceptance logged)
Audit Trail Coverage:        100% (every pool action traceable)
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Capital Depth** — pools aggregate Pi that would otherwise sit idle
- **Community Formation** — co-investors become a community within TEC
- **Advanced Pi Utility** — Pi used not just for purchases but for capital formation
- **Trust Signal** — functional investment pools prove Pi economic maturity

---

## 10. FUTURE EVOLUTION

```
Phase 1 (requires: mature KYC + legal consultation):
  → Educational pools only (learning + skill pools)
  → Manual admin approval for each pool
  → Simple pro-rata distribution

Phase 2:
  → Commercial pools (product development, merchant groups)
  → Automated distribution via Nexus workflows
  → Pool analytics and performance tracking

Phase 3:
  → Pi Capital Infrastructure
  → Asset-backed pools (FundX + Assets integration)
  → Cross-pool diversification
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 (Hard Gates — do not build without these):**
```
[P0-1] Legal Consultation FIRST
  Cannot build investment pool mechanics without legal review.
  Jurisdiction: where is Yasser based? Pi Network rules on DeFi?
  Document legal opinions before a single line of pool code.

[P0-2] KYC Maturity Gate
  FundX requires tec-kyc-service (4005) to have ≥ 90% success rate.
  Currently: KYC service deployed but maturity unverified.
  Do not launch FundX until KYC is battle-tested.

[P0-3] SYSTEM Pool Governance Policies
  SYSTEM (C-110) must define: what pool types are permitted,
  what return models are allowed, approval workflow for pool charters.
  FundX is governed by SYSTEM, not self-governing.
```

---

## 12. INTEGRATION MAP

```
This charter (C-113) depends on:
  C-100 HUB       → SSO + payment modal routing
  C-110 SYSTEM    → pool governance + charter approval
  C-109 NEXUS     → multi-party contribution workflows
  C-102 ASSETS    → future: asset-backed pool collateral
  tec-kyc-service (4005) → mandatory investor verification
  tec-payment-service (4002) → pool escrow balance management

Other charters depend on this one for:
  C-105 ANALYTICS → capital flow data
  C-107 CONNECTION → co-investor relationship signals
```
