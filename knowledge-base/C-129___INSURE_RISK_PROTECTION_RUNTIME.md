# C-129 — INSURE RISK PROTECTION RUNTIME

## TEC Ecosystem — Risk Protection Layer

> **Truth State:** `[Future Vision]`
> **Governance State:** `[Draft]`
> **Verification:** `[Assumed]`
> **Authority Scope:** `[Domain]`
> **Build Gate:** Phase 2 (1k+ users)
> **Legal Note:** Risk platform ≠ Insurance company. No regulatory license required for V1-V2.
> **Domain:** `insure.tecosystem.app` (live pattern now) → `insure.pi` (future)

---

## Institutional Identity

```
Risk Protection Runtime
System of Protection (User Layer)
```

---

## Mission

Protect individuals, assets, and economic activities
from financial, operational, and digital risks
across the Pi economy.

---

## Core Question

```
"How do I protect myself, my assets, and my activities?"
```

---

## Institutional Role

```
Insure sits between verification and execution.

Zone verifies what can be trusted.
Insure protects what has been trusted.

Without Insure:
  Commerce = unprotected transactions
  FundX = unprotected investments
  Estate = unprotected property transfers
  Assets = unprotected ownership claims

With Insure:
  Every economic interaction
  has a defined protection layer.
```

---

## The Problem Insure Solves

```
In Pi ecosystem today:

Buyer sends Pi to seller:
  → No protection if seller disappears
  → No escrow mechanism
  → No dispute resolution

Investor puts Pi into FundX pool:
  → No risk assessment
  → No loss protection layer
  → No early warning system

User owns digital assets:
  → No protection against loss
  → No recovery mechanism
  → No emergency plan

Insure addresses all three scenarios.
```

---

## Critical Legal Boundary

```
Insure V1-V2:
  ✅ Risk scoring (assessment)
  ✅ Escrow (transaction holding)
  ✅ Recovery center (account + asset recovery)
  ✅ Risk alerts (notification)
  ✅ Beneficiary management (inheritance planning)
  ❌ Insurance underwriting (requires regulatory license)
  ❌ Policy issuance (requires insurance license)
  ❌ Claims payment from Insure reserves (regulatory risk)

Insure V3+ (Insurance Marketplace):
  Insure = intermediary / distribution platform
  Licensed insurance companies = underwriters
  TEC = facilitator (not insurer)
  Legal structure required before V3 launch.
```

---

## 🔴 Custody Hard-Gate — Escrow holds user funds (P0, aligns with FundX / C-113)

```
Escrow = custody of user Pi. Under the Kernel Spec (C-47):
  Invariant #8 — each entity has exactly one owning service.
  payment-service is the ONLY custodian of Pi. insure-service NEVER holds Pi.

Therefore NO escrow-contribution / hold / release code ships until ALL THREE
P0 gates are documented-done (same posture as FundX pool mechanics, C-113 §11):

  1. LEGAL REVIEW FIRST — escrow / holding of third-party funds in Pi reviewed
     for the target jurisdiction (money-transmission / e-money rules).
  2. payment-service CUSTODY — every escrowed π is held, moved, and released
     BY tec-payment-service (DECIMAL(20,8), outbox, ADR-004). insure-service
     only records escrow STATE + conditions; it issues intents, never balances.
  3. SYSTEM GOVERNANCE (C-110) — escrow types + release/dispute rules approved
     as governed workflows; disputes carry full ActorContext + audit trail.

Until all three exist, Insure ships risk scoring + recovery planning + beneficiary
records ONLY (read/plan surfaces) — NO π custody, NO escrow release.
```

---

## Authority Boundary

### Insure OWNS

```
Risk Score:
  Personal Risk Profile     → based on activity + Zone data
  Transaction Risk Score    → per-transaction before execution
  Investment Risk Score     → per FundX opportunity
  Business Risk Profile     → for NBF/Titan entities

Escrow Service:
  Transaction Escrow        → hold Pi until conditions met
  Dispute Resolution        → structured resolution process
  Milestone Escrow          → release on milestone completion
  Multi-party Escrow        → complex transaction protection

Recovery Center:
  Account Recovery          → lost access restoration
  Asset Recovery            → lost/locked asset resolution
  Emergency Access          → designated guardian access
  Recovery Vault            → backup of critical documents

Protection Records:
  Asset Protection Plans    → user-defined protection settings
  Beneficiary Management    → inheritance + emergency contacts
  Emergency Contacts        → who to notify in critical events
  Protection History        → complete audit trail
```

### Insure DOES NOT OWN

```
Verification              → Zone verifies entities
Risk data computation     → Analytics computes risk patterns
Alert routing             → Alert delivers notifications
Actual insurance policies → V3+ (requires licensed partner)
Economic execution        → payment-service executes
Investment decisions      → FundX governs investments
Governance authority      → System governs platform
```

---

## The Escrow Architecture — Highest Priority V1 Feature

```
Why Escrow is Insure's most critical V1 feature:

Current Pi Commerce problem:
  "I won't pay before receiving the product"
  "I won't ship before receiving payment"
  = trust deadlock

Insure Escrow breaks the deadlock:

BUYER                INSURE ESCROW           SELLER
   │                      │                    │
   │──Pay 10π ──────────► │                    │
   │                      │──Notify seller ───►│
   │                      │                 [Ships]
   │                      │◄──Confirm receipt──│
   │                      │──Release 10π ─────►│
   │                      │                    │
   └──── Transaction complete ─────────────────┘

Dispute scenario:
   BUYER                INSURE               SELLER
     │──Dispute ────────►│                    │
     │                   │──Hold Pi           │
     │                   │──Request evidence──►│
     │◄──Resolution ─────│                    │

This single feature makes:
  Commerce significantly more trusted
  Estate property transfers safer
  FundX investment flows more secure
  Epic project funding reliable
```

---

## Technical Architecture (Planned)

```
Pi Browser (WebView)
    ↓
insure.tecosystem.app (Vercel — Next.js 15)
    ↓
BFF /api/* routes
    ↓
API Gateway :3000 (Railway)
    ↓
insure-service (NEW — Phase 2)
zone-service       → entity risk signals
analytics-service  → risk computation
alert-service      → risk threshold alerts
payment-service    → escrow Pi holding
commerce-service   → transaction context
fundx-service      → investment risk context
```

### Core Entities

```typescript
interface RiskProfile {
  user_id:              string;
  overall_risk_score:   number;    // 0-100 (higher = lower risk)
  dimensions: {
    identity_verified:  boolean;   // Hub + Zone
    activity_history:   number;    // transaction volume/age
    dispute_rate:       number;    // % of transactions disputed
    completion_rate:    number;    // % of commitments fulfilled
    legend_score:       number;    // reputation signal
  };
  last_updated:         string;
  next_review:          string;
}

interface EscrowContract {
  escrow_id:       string;
  type:            EscrowType;     // TRANSACTION | MILESTONE | MULTI_PARTY
  buyer_id:        string;
  seller_id:       string;
  amount:          PiAmount;
  conditions:      EscrowCondition[];
  status:          EscrowStatus;   // PENDING | ACTIVE | DISPUTED | RELEASED | REFUNDED
  created_at:      string;
  expires_at:      string;
  evidence:        Evidence[];
  resolution?:     Resolution;
}

interface Beneficiary {
  beneficiary_id:  string;
  user_id:         string;
  name:            string;
  pi_identity:     string;
  relationship:    string;
  access_level:    AccessLevel;    // EMERGENCY | FULL | ASSETS_ONLY
  conditions:      string;
  activated:       boolean;
}
```

---

## Redis Streams (C-56)

```
Subscribes to:
  payment.initiated.v1   → check risk score before proceeding
  payment.completed.v1   → update transaction risk history
  payment.failed.v1      → update risk profile
  zone.badge.revoked.v1  → recalculate risk scores
  epic.project.milestone.v1 → milestone escrow release trigger
  fundx.pool.alert.v1    → investment risk notification

Publishes:
  insure.escrow.created.v1   → notify buyer + seller
  insure.escrow.released.v1  → notify parties
  insure.dispute.opened.v1   → escalate to Alert
  insure.risk.threshold.v1   → alert user + Alert service
  insure.recovery.initiated.v1 → emergency protocol
```

---

## Security Model

```
Escrow Pi holding (custody = payment-service ONLY — see Custody Hard-Gate):
  Every escrowed π is custodied BY tec-payment-service (never insure-service).
  insure-service records escrow STATE + conditions; it issues release/refund
  INTENTS that payment-service executes via the outbox (ADR-004).
  Multi-signature release (buyer + seller confirmation) — enforced downstream.
  Timeout auto-release (configurable per contract) — payment-service acts.
  Dispute freeze (held until resolution) — state flag; funds stay in custody.

Risk data:
  User risk profiles are private by default
  Counterparty sees aggregate risk score only (not details)
  Risk history retained 7 years (per C-93)

Recovery center:
  Recovery requires Pi identity re-verification
  Guardian access requires pre-authorization
  Emergency access has 48-hour delay (anti-fraud)
```

---

## Infrastructure Dependencies

```
Zone            → entity verification (REQUIRED for escrow)
Analytics       → risk computation (REQUIRED for scores)
Alert           → risk threshold notifications
payment-service → Pi escrow management
Commerce        → transaction context + dispute evidence
FundX           → investment risk signals
Assets          → asset protection records
Hub             → Pi identity (REQUIRED for all features)
Legend          → reputation signals for risk scoring
```

---

## Revenue Model

```
Insure Free:
  Basic risk score view
  1 active escrow contract

Insure Pro (Hub PRO — 10π/month):
  Unlimited escrow contracts
  Full risk profile
  Recovery center access
  Beneficiary management (up to 3)
  Priority dispute resolution

Insure Enterprise (Hub ENTERPRISE — 50π/month):
  API access (risk scores for B2B)
  Bulk escrow management
  Organization risk profile
  Dedicated dispute resolution
  Recovery vault (encrypted document storage)

Transaction Fees (V1):
  Escrow service: 0.5% of escrowed amount (capped at 10π)
  Dispute resolution: 1π flat fee (win or lose)

Insurance Marketplace (V3 — per partnership):
  Commission on insurance policies facilitated
  Partner listing fees
  API integration fees
```

---

## Key Metrics

```
Primary (Protection Quality):
  Escrow contracts completed without dispute
  Dispute resolution time (target: < 7 days)
  Risk score accuracy (predicted vs actual outcomes)
  Recovery success rate

Secondary:
  Escrow volume (π per month)
  Risk profiles created
  Beneficiary plans activated
  False positive risk alerts (should be < 5%)
```

---

## Build Protocol

```
V1 (Phase 2 — 6 weeks):
  □ Risk Score (from Zone + Legend + Analytics)
  □ Escrow contracts (TRANSACTION type)
  □ Dispute resolution (basic: evidence + decision)
  □ Recovery center (account recovery)
  □ Beneficiary management (up to 3)

V2 (Phase 3 — 4 weeks):
  □ MILESTONE + MULTI_PARTY escrow types
  □ Advanced risk analytics (investment risk)
  □ Recovery vault (encrypted documents)
  □ Organization risk profiles (NBF + Titan)
  □ Insure API (B2B risk scoring)

V3 (Phase 4 — legal required):
  □ Insurance Marketplace
  □ Licensed insurer partner integrations
  □ Policy comparison engine
  □ Claims facilitation (not underwriting)
```

---

## Ecosystem Contribution

```
Insure provides to TEC:
  Commerce  → escrow makes transactions safer
  Estate    → property transfer protection
  FundX     → investment risk assessment
  Epic      → project milestone escrow
  Connection → partnership risk scoring
  Legend    → protection track record (dispute-free record)

Insure generates for Pi:
  Economic trust infrastructure
  Fraud reduction across Pi marketplace
  Protection standard for Pi transactions
```

---

## Positioning Statement

```
Insure is not an insurance company.
Insure is the Risk Protection Runtime of TEC.

The difference matters:

An insurance company sells protection after risk is defined.
A Risk Protection Runtime prevents risk from becoming loss.

Insure does not wait for something to go wrong.
Insure builds protection before anything happens:
  Before a transaction — escrow is ready
  Before a risk — score is computed
  Before an emergency — recovery plan exists
  Before death — beneficiaries are designated

In the Pi economy, protection is infrastructure.
Not a product. Not a service.
Infrastructure.

Insure is that infrastructure.
```

---

## Related Documents

- **C-00** Platform Constitution · **C-47** Kernel Spec (P6 Fail Closed, ActorContext, custody Invariant #8)
- **C-70** Event Governance (`domain.action.version`) · **C-105** Analytics (score/metric computation)
- **C-113/FundX** custody posture · **C-120** Zone (entity risk) · **C-126** Legend (risk signal)
- **C-12** Dual-Mode Payment (anti-regression) · **C-123** Pi Browser Session & Cookie Spec (login/cookies)
