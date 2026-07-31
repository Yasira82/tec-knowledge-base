# C-130 — TITAN ENTERPRISE OS RUNTIME

## TEC Ecosystem — Enterprise Operating Layer

> **Truth State:** `[Future Vision]`
> **Governance State:** `[Draft]`
> **Verification:** `[Assumed]`
> **Authority Scope:** `[Domain]`
> **Build Gate:** Phase 3 (mature platform — needs NBF + Commerce + Zone live)
> **Domain:** `titan.tecosystem.app` (live pattern now) → `titan.pi` (future)

---
## Deployment Status (2026-07-31)

> **Truth State:** `[Current State]` for the deployed app + live payment · `[Future Vision]` for the full runtime below
> **Verification:** `[Runtime Verified]` — deployed on Mainnet, real Pi payment live (SSoT: `architecture/app-fleet.yaml` → `live-verified`)

**Titan is deployed on Mainnet** with Hub SSO and dual-mode (ADR-007) Pi payment live:
- **Domain:** `titan.tecosystem.app` · **Pi App ID:** `titan-e1ta` · **APP_SOURCE:** `titan`
- **Payment:** real Pi subscription — Mode 1 (Hub) + Mode 2 (standalone); `PI_API_KEY_TITAN` set on payment-service.
- **Hub SSO:** enabled (in `/api/auth/sso` ALLOWED_TARGETS + Hub domain registry).
- **Growth:** referral loop wired (C-133).

**Still `[Future Vision]`:** the advanced runtime described below (V2+ / the charter's later phases) — vision, not yet built.

---

## Institutional Identity

```
Enterprise Operating Runtime
System of Organizations (Institutional Layer)
```

---

## Mission

Enable organizations — companies, factories, universities, NGOs,
government bodies, and large investors — to operate in the Pi economy:
managing identity, teams, operations, commerce, assets, payments,
governance, and collaboration from one coordinated console.

---

## Core Question

```
"How do organizations operate in the Pi economy?"
```

---

## Institutional Role

```
Titan is the B2B / institutional counterpart to Life.

Where Life manages the individual in the Pi economy,
Titan manages the organization in the Pi economy.

Where NBF is Business Day 1 (establish + verify + first sale),
Titan is Business at Scale (multi-team operations + governance).

Titan does not replace the owning apps —
Titan is the enterprise console that ORCHESTRATES them for an org.
```

---

## NBF → Titan — the Graduation Loop (C-124)

```
NBF establishes the business.  Titan runs it at scale.

Graduation trigger (defined in NBF, C-124):
  team_size > 5 people
  OR monthly_revenue > 1,000π
  OR active_projects > 3
  OR user_count > 500

NBF does not compete with Titan — NBF graduates INTO Titan.
A graduated NBF business keeps its identity, Zone badge, and Legend
merchant score; Titan adds multi-team management on top.
```

---

## Authority Boundary

### Titan OWNS

```
Enterprise Identity Context:
  Organization profile (built on the graduated NBF business identity)
  Multi-branch / workspace structure
  Team + roles (Owner | Admin | Finance | Sales | HR)
  Role-scope presentation (permissions enforced by tec-auth, not Titan)

Enterprise Coordination:
  Procurement UI (B2B purchasing workflows)
  Enterprise (B2B) commerce CONTEXT over Commerce
  Organization console that orchestrates the owning apps
  Managed VIEWS of org wallet, orders, assets, reports
```

### Titan DOES NOT OWN

```
Funds / custody       → tec-payment-service (Org Wallet is a VIEW, never a new wallet)
Commerce truth        → Commerce (Enterprise Commerce is a B2B context OVER it)
Assets                → tec-asset-service
Capital / financing    → FundX (C-129 gates apply)
Verification          → Zone (C-120) / tec-kyc-service (presented, never minted)
Reputation            → Zone + Connection (C-107); org merchant score → Legend (C-126)
Reports / metrics     → Analytics (C-105)
Role enforcement      → tec-auth (Titan only PRESENTS role scope)
Business formation    → NBF (C-124) — Titan is the graduation target, not the origin
```

---

## Constitutional Rules

```
1. Org Wallet is a managed VIEW of tec-payment-service balances.
   Titan NEVER holds or moves org funds directly (Invariant #8).

2. Org + role identity derive from the tec_user session cookie server-side —
   NEVER from a request body/param (P6 Fail Closed).

3. Role permissions are enforced server-side by tec-auth at runtime.
   The Titan console only PRESENTS them; it is not the authority.

4. Enterprise Commerce is a B2B CONTEXT over Commerce — order/payment truth
   stays with Commerce + payment-service. Titan coordinates, never executes.

5. No org action without ActorContext + audit trail (C-47 §4).
```

---

## Technical Architecture (Planned)

```
Pi Browser (WebView)
    ↓
titan.tecosystem.app (Vercel — Next.js 15)
[Clone from tec-template-base]
    ↓
BFF /api/bff/titan/* routes (server-only)
    ↓
API Gateway :4000 (Railway)
    ↓
Reads (ID-only references) from the owning services:
  tec-auth        → org identity + team roles (authority)
  payment-service → org wallet VIEW (custody authority)
  commerce-service → enterprise (B2B) orders context
  asset-service   → org assets VIEW
  zone-service    → org + agent verification status
  analytics-service → corporate reports
  nbf-service     → graduated business origin (C-124)
```

### Core Entities

```typescript
interface Organization {
  org_id:          string;
  owner_id:        string;          // Hub Pi identity (creator)
  graduated_from?: string;          // NBF business_id (C-124) if graduated
  name:            string;
  kind:            OrgKind;         // COMPANY | FACTORY | UNIVERSITY | NGO | GOV | INVESTOR
  zone_verified:   boolean;         // presented from Zone — never minted here
  branches:        Branch[];
  wallet_view:     WalletView;      // READ-ONLY view of payment-service balance
  created_at:      string;
}

interface TeamMember {
  member_id:   string;              // linked Hub identity
  role:        OrgRole;             // OWNER | ADMIN | FINANCE | SALES | HR
  scope:       string[];            // presented; enforced by tec-auth
  invited_by:  string;
}

interface Module {
  id:        string;                // verification | workspace | org-wallet | team | procurement | ...
  title:     string;
  owned_by:  string;                // the OWNING system (Titan orchestrates, never owns)
  status:    ModuleStatus;          // LIVE | PRESENTED | PLANNED
}
```

---

## Security Model

```
Org access:      Only owner_id + invited team members; role scope from tec-auth
Wallet:          READ-ONLY view — no mutation path from Titan
Verification:    Presented from Zone — cannot be self-granted
Isolation (P6):  No session → no org data (fail closed)
Audit:           Every org mutation carries full ActorContext (C-47 §4)
```

---

## Infrastructure Dependencies

```
Hub / tec-auth   → org identity + team roles (REQUIRED)
NBF (C-124)      → graduated business origin
payment-service  → org wallet VIEW (custody authority)
Commerce         → enterprise (B2B) order context
Zone (C-120)     → org + agent verification (presented)
Assets           → org asset view
Analytics (C-105) → corporate reports
FundX (C-129)    → enterprise financing (gated)
```

---

## Revenue Model

```
Titan Free:
  Read-only enterprise console (org profile + team view + modules map)

Titan Enterprise (25π/month and up — tiered by org size):
  Multi-team management (roles + branches)
  Procurement workflows
  Enterprise commerce context (B2B)
  Corporate analytics dashboard (from Analytics)
  Priority support

Ecosystem Revenue (Phase 3+):
  Institutional onboarding (universities, factories, government)
  White-label enterprise consoles
  B2B marketplace facilitation fees (via Commerce — never held by Titan)
```

---

## Key Metrics

```
Primary (Enterprise Adoption):
  Organizations onboarded / quarter
  NBF → Titan graduation rate (C-124 loop health)
  Active team members per org
  Enterprise (B2B) order volume via Commerce

Secondary:
  Modules activated per org
  Role distribution health (segregation of duties)
  Org retention at 6 / 12 months
```

---

## Ecosystem Contribution

```
Titan feeds:
  Commerce   → B2B order volume
  FundX      → enterprise financing demand (gated)
  Analytics  → corporate activity metrics
  Legend     → organization merchant achievements
  Zone       → organizations to verify

Titan generates for Pi:
  Institutional participation in the Pi economy
  Structured multi-user business operations
  The at-scale destination for graduated NBF businesses
```

---

## Positioning Statement

```
Titan is not an ERP.
Titan is not a dashboard.
Titan is the Enterprise Operating Runtime of TEC.

Where Life manages a person in the Pi economy,
Titan manages an organization.

Titan does not own funds, commerce, assets, or verification.
Titan coordinates the systems that do —
into one console an organization can operate from.

Every Pi enterprise starts as an NBF business.
Titan is where it grows up.
```

---

## Related Documents

- **C-00** Platform Constitution · **C-47** Kernel Spec (Invariant #8 custody, P6, ActorContext)
- **C-124** NBF Business Foundation Runtime — the graduation origin (NBF → Titan)
- **C-105** Analytics · **C-107** Connection · **C-120** Zone · **C-126** Legend · **C-129** Insure/FundX gates
- **C-12** Dual-Mode Payment (anti-regression) · **C-123** Pi Browser Session & Cookie Spec
