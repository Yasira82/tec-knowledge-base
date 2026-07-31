# C-128 — VIP PREMIUM EXPERIENCE RUNTIME

## TEC Ecosystem — Premium Experience Layer

> **Truth State:** `[Planned State]`  (V1 = Hub PRO/ENTERPRISE exists; V2/V3 future)
> **Governance State:** `[Draft]`
> **Verification:** `[Assumed]`
> **Authority Scope:** `[Domain]`
> **Build Gate:** V1 = Hub PRO/ENTERPRISE (EXISTS) | V2 = Phase 2 | V3 = Phase 3
> **Domain:** `vip.tecosystem.app` (live pattern now) → `vip.pi` (future)

---
## Implementation Status (2026-07-31)

> **Truth State:** `[Current State]` — the Elite → VIP lift below · V1 = Hub PRO/ENTERPRISE (exists)
> **Verification:** `[Code Verified]` (merged) · deployment per app CLAUDE.md

**Value chain LIVE — Elite → VIP (earned, not bought):** `getCurrentTier`
(`tec-identity-service`) lifts the base `STANDARD` experience to `ELITE` when the owner
holds an **ACTIVE** Elite recognition (C-127) — checked **live**, never stored in VIP, and
never downgrading a purchased tier (P5). `[Code Verified]` (merged). The only sold tier
stays `STANDARD`; earned tiers are unlocked by recognition/verification elsewhere.

**Still future:** the dedicated `vip-service` (V2) with live status/benefits/events/
concierge endpoints, and `vip.pi` external membership (V3).

---

## Institutional Identity

```
Premium Experience Runtime
System of Privilege (Cross-Cutting Layer)
```

---

## Mission

Deliver exclusive access, concierge services,
premium memberships, and privileged benefits
across the TEC ecosystem —
enabling verified members to experience
a qualitatively different level of service.

---

## Core Question

```
"What exclusive benefits do I receive?"
```

---

## The Three-Layer Foundation

```
VIP is the reward layer of a three-part chain:

Legend (Evidence)
    ↓  "What have you achieved?"
Elite (Recognition)
    ↓  "Are you officially recognized?"
VIP (Experience)
    ↓  "What privileges do you receive?"

VIP without Legend + Elite = arbitrary privilege.
VIP with Legend + Elite = earned premium experience.

Constitutional rule:
  VIP elite tier requires Elite recognition.
  VIP standard tier available via subscription.
  VIP cannot grant Elite recognition.
  VIP cannot modify Legend records.
```

---

## Institutional Role

```
VIP is not a subscription plan.
VIP is not a loyalty program.
VIP is not a social rank.

VIP is the Premium Experience Runtime —
the layer that translates recognition and achievement
into concrete, exclusive, high-value experiences
across the entire TEC ecosystem.

VIP does not own any economic capability.
VIP adds a premium experience layer
ON TOP of existing capabilities.
```

---

## Authority Boundary

### VIP OWNS

```
Membership Tiers:
  VIP_STANDARD    → subscription-based (any user)
  VIP_ELITE       → requires Elite recognition
  VIP_MERCHANT    → for verified Commerce merchants
  VIP_INVESTOR    → for verified FundX investors
  VIP_FOUNDER     → for verified NBF/Epic project founders
  VIP_PARTNER     → for institutional Pi partners

Premium Benefits (cross-app):
  Commerce VIP:   exclusive products, priority listings, reduced fees
  FundX VIP:      early access to investment opportunities
  Estate VIP:     premium property listings, priority viewing
  Explorer VIP:   featured discovery, premium search results
  Epic VIP:       priority Zone verification, incubator access
  Connection VIP: exclusive networking circles, VIP events
  Zone VIP:       priority verification processing
  Analytics VIP:  advanced intelligence dashboards

Concierge Services:
  Personal assistant (async)
  Priority support (< 2hr response)
  Dedicated account manager (FOUNDER+ tier)
  Meeting arrangement
  Service coordination

Exclusive Access:
  VIP events (Pi summits, investment rounds)
  Private community channels (Connection)
  Early access to new TEC features
  Private Beta programs
  Exclusive NFT collections (Assets)
  Closed investment rounds (FundX)
```

### VIP DOES NOT OWN

```
Recognition decisions    → Elite grants recognition
Reputation recording     → Legend records achievements
Identity verification    → Hub + Zone own identity
Economic execution       → payment-service executes
Investment decisions     → FundX governs
Governance authority     → System governs
Risk management          → Insure manages protection
```

---

## VIP Membership Tiers

```
┌─────────────────────────────────────────────────────────┐
│                    VIP TIER STRUCTURE                    │
├──────────────┬──────────────┬──────────────┬────────────┤
│    STANDARD  │    ELITE     │   MERCHANT   │  FOUNDER   │
├──────────────┼──────────────┼──────────────┼────────────┤
│ 50π/month    │ Elite cert   │ 100π/month   │ 500π/month │
│ Any user     │ required     │ Zone merch.  │ NBF/Epic   │
│ Subscription │ + 30π/month  │ verified     │ verified   │
├──────────────┼──────────────┼──────────────┼────────────┤
│ • Reduced    │ • All        │ • 0% Commerce│ • All      │
│   fees       │   STANDARD   │   fee        │   MERCH.   │
│ • Priority   │ • Exclusive  │ • Featured   │ • Early    │
│   support    │   events     │   placement  │   FundX    │
│ • Advanced   │ • Early      │ • Priority   │ • Dedicated│
│   analytics  │   FundX      │   Zone verif │   manager  │
│ • VIP badge  │ • VIP lounge │ • VIP store  │ • Incubator│
└──────────────┴──────────────┴──────────────┴────────────┘
```

---

## VIP as Cross-Cutting Layer

```
VIP does not create new apps.
VIP adds a premium experience layer to existing apps:

Commerce + VIP:
  → VIP merchants: 0% transaction fee
  → VIP buyers: exclusive product access
  → VIP stores: premium featured placement

FundX + VIP:
  → VIP investors: 48hr early access before public
  → VIP founders: priority funding review
  → VIP pools: exclusive high-value pools

Estate + VIP:
  → VIP sellers: premium listing visibility
  → VIP buyers: exclusive property previews
  → VIP: dedicated estate advisor

Connection + VIP:
  → VIP networking circles (invite-only)
  → VIP direct messaging with verified leaders
  → VIP events (private Pi summits)

Epic + VIP:
  → VIP founders: Zone verification in 24hr (vs 7 days)
  → VIP incubator: mentorship + resources
  → VIP launch: featured on Epic homepage

This pattern = VIP as experience amplifier,
not as separate economic capability.
```

> **Fee-authority note (P5 Layer Responsibility).** Numbers like "0% Commerce
> fee" or "48hr early access" are *illustrative benefit shapes*, not VIP-set
> policy. VIP does NOT set fees, queue positions, or verification SLAs. VIP
> grants a member **eligibility**; the owning app + System governance define
> and enforce the actual value (Commerce owns transaction fees, Zone owns
> verification SLAs, FundX owns access windows). A VIP grant that an owning
> app has not honored is inert — the downstream service is the authority.

---

## Technical Architecture

```
V1 (EXISTS — Hub subscription):
  Hub PRO/ENTERPRISE = basic VIP
  Benefits delivered via Hub token claims
  No separate VIP service needed

V2 (Phase 2 — vip-service):
  Pi Browser (WebView)
      ↓
  vip.tecosystem.app
      ↓
  vip-service (lightweight)
    GET /vip/status/:userId        → current tier + benefits
    GET /vip/benefits/:appId       → benefits for specific app
    GET /vip/events                → upcoming VIP events
    POST /vip/concierge            → concierge request
    GET /vip/exclusive-access      → current exclusive opportunities

V3 (Phase 3 — vip.pi):
  External Pi ecosystem membership
  Pi events and summits
  Cross-platform VIP standard
```

### Core Entities

```typescript
interface VIPMembership {
  user_id:          string;
  tier:             VIPTier;          // STANDARD | ELITE | MERCHANT | FOUNDER | PARTNER
  status:           MembershipStatus; // ACTIVE | EXPIRED | SUSPENDED
  source:           MembershipSource; // SUBSCRIPTION | ELITE_EARNED | GIFTED
  elite_cert_id?:   string;           // if tier requires Elite
  benefits:         BenefitGrant[];
  started_at:       string;
  renews_at:        string;
  concierge_credits: number;
}

interface BenefitGrant {
  benefit_id:     string;
  app:            string;           // commerce | fundx | estate | epic | connection
  benefit_type:   BenefitType;     // FEE_REDUCTION | EXCLUSIVE_ACCESS | PRIORITY | BADGE
  value:          BenefitValue;
  active:         boolean;
  expires_at?:    string;
}

interface ConciergeRequest {
  request_id:     string;
  user_id:        string;
  tier:           VIPTier;
  type:           RequestType;      // SUPPORT | MEETING | SERVICE | ACCESS
  description:    string;
  status:         RequestStatus;    // OPEN | IN_PROGRESS | RESOLVED
  sla_hours:      number;           // 2 for STANDARD, 0.5 for FOUNDER
  created_at:     string;
  resolved_at?:   string;
}
```

---

## Security Model

```
Tier verification:
  ELITE tier: checks Elite certificate validity in real-time
  MERCHANT tier: checks Zone merchant verification
  FOUNDER tier: checks NBF/Epic founder status
  STANDARD tier: payment verification only

Benefit delivery:
  Benefits are read from vip-service by each app
  Apps do not store VIP status — always checked live
  VIP status cannot be modified by users

Concierge privacy:
  Concierge conversations are private
  No third-party access to concierge requests
  Retained 90 days (per C-93)
```

---

## Infrastructure Dependencies

```
Hub             → identity + PRO/ENTERPRISE subscription (V1 EXISTS)
Elite           → Elite recognition verification (V2+)
Legend          → achievement evidence for tier eligibility
Zone            → merchant/founder verification
payment-service → subscription billing in Pi
Commerce        → fee reduction integration
FundX           → early access integration
Estate          → premium listing integration
notification-service → benefit alerts + events
```

---

## Revenue Model

```
VIP Standard:   50π/month
VIP Elite:      30π/month (+ requires Elite cert)
VIP Merchant:   100π/month
VIP Investor:   200π/month
VIP Founder:    500π/month
VIP Partner:    1,000π/month (institutional)

Annual discount: 20% (pay 10 months, get 12)

VIP Events (separate revenue):
  Pi Elite Summit:        100π/ticket
  Investment Roundtable:  500π/participant
  Founder Mastermind:     1,000π/session

V3 — vip.pi external:
  Pi Community VIP:       25π/month
  Pi Business VIP:        200π/month
  Pi Institutional VIP:   2,000π/month

VIP = TEC's highest margin revenue stream.
Combined ARR potential at 10k users:
  Conservative: 500k+ π/year
```

---

## Key Metrics

```
Primary (Experience Quality):
  VIP member satisfaction (NPS)
  Concierge resolution time (target: < SLA)
  VIP retention rate (target: > 80% monthly)
  VIP → Elite conversion (VIP drives aspiration)

Secondary:
  VIP members per tier distribution
  Most used benefits per tier
  VIP event attendance rate
  Revenue per VIP tier
```

---

## Positioning Statement

```
VIP is not a premium tier.
VIP is the Premium Experience Runtime of TEC.

The difference:
  Premium tiers sell access.
  Experience runtimes deliver transformation.

A VIP member in TEC does not just pay more.
A VIP member experiences the ecosystem differently:
  Faster (priority in every queue)
  Deeper (exclusive access to opportunities)
  Supported (concierge for any need)
  Recognized (visible as verified premium)

VIP does not change what TEC is.
VIP changes what it feels like
to be exceptional in TEC.

Excellence deserves exceptional experience.
VIP delivers that experience.
```

---

## Related Documents

- **C-00** Platform Constitution · **C-47** Kernel Spec (P6 Fail Closed, ActorContext, custody Invariant #8)
- **C-70** Event Governance (`domain.action.version`) · **C-105** Analytics (score/metric computation)
- **C-110** System (subscription gating) · **C-126** Legend (evidence) · **C-127** Elite (recognition)
- **C-12** Dual-Mode Payment (anti-regression) · **C-123** Pi Browser Session & Cookie Spec (login/cookies)
