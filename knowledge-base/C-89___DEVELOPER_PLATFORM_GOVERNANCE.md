# C-89 — DEVELOPER PLATFORM GOVERNANCE

## TEC Ecosystem — External Developer Model & Partner Authority

> Status: DRAFT — Strategic Platform Layer
> Authority: Platform Architecture + Partner Governance
> Version: 1.0 — June 2026
> Truth State: [Planned State] — Gate B prerequisite
> Governance State: [Draft]
> Verification State: [Unverified]
> Authority Scope: [Platform]

---

# PREAMBLE

```
C-85 defines TEC's infrastructure layer identity.
C-89 defines who may build on that infrastructure and under what terms.

The progression:
  Stage 1: TEC builds for TEC         (current)
  Stage 2: TEC builds the platform    (Gate A-C)
  Stage 3: Others build on TEC        (Gate B+ — this document governs Stage 3)
```

Documentation Inflation Justification:
```
✅ New authority: who may build on TEC and under what terms (not covered anywhere)
✅ New runtime behavior: app registration, API key governance, partner onboarding
✅ New verification capability: external apps can be verified against platform standards
```

---

# 1. THE DEVELOPER OPPORTUNITY

```
Why external developers want TEC:
  ✅ Identity: Pi SSO without building auth from scratch
  ✅ Payments: Pi payments without Pi SDK complexity
  ✅ Trust: TEC-verified identity signals
  ✅ Discovery: Connection + Explorer economic graph (Gate B+)
  ✅ Intelligence: Analytics economic signals (Gate B+)
  ✅ Reasoning: TEC AI recommendations (Gate D+)

What TEC provides that Pi Network alone does not:
  Pi Network provides:  Wallet + Blockchain + Identity primitive
  TEC provides:         Economic coordination layer above Pi
                        → Trust resolution
                        → Payment orchestration
                        → Economic graph
                        → Governance infrastructure
```

---

# 2. EXTERNAL DEVELOPER MODEL

## Who May Build on TEC

```
Tier 1: TEC Internal Apps          [Current State]
  → Full platform access
  → Hub SSO + Dual-mode payments
  → All 12 backend services
  → Examples: Commerce, Assets, Ecommerce

Tier 2: Verified TEC Partners      [Planned State — Gate B]
  → API key access to defined surface
  → TEC SSO (federated identity)
  → Payment processing through tec-payment-service
  → Read access to public economic signals
  → Examples: Pi-native businesses, Pi app builders

Tier 3: Economic Infrastructure Consumers [Future Vision — Gate D+]
  → Full API surface access
  → TEC AI reasoning signals
  → Economic graph integration
  → Governance participation
  → Examples: Pi ecosystem infrastructure projects
```

## What External Developers May NOT Do

```
❌ Access another user's wallet or payments
❌ Bypass tec-auth-service for identity verification
❌ Call internal Railway services directly
❌ Store tec_access_token or tec_user outside HttpOnly cookies
❌ Implement custom payment state machines (must use tec-payment-service)
❌ Override platform governance rules
❌ Access admin or governance APIs without explicit delegation
```

---

# 3. API SURFACE DEFINITION

## Phase 1 — Identity API (Gate A)

```
GET  /api/v1/identity/verify          → verify Pi principal
GET  /api/v1/identity/profile         → public profile data
POST /api/v1/auth/sso                 → SSO token exchange

Auth: OAuth 2.0 + Pi principal binding
Scope: identity:read
```

## Phase 2 — Payment API (Gate B)

```
POST /api/v1/payments/create          → create Pi payment
POST /api/v1/payments/approve         → approve Pi payment
POST /api/v1/payments/complete        → complete Pi payment
GET  /api/v1/payments/{id}/status     → payment status

Auth: API key + HMAC signature
Scope: payments:write
Rate limit: 100 req/min (Tier 2) | 1000 req/min (Tier 3)
```

## Phase 3 — Economic Intelligence API (Gate B + Analytics mature)

```
GET  /api/v1/analytics/signals        → economic signals
GET  /api/v1/analytics/health         → ecosystem health
GET  /api/v1/explorer/entities        → economic entities
GET  /api/v1/explorer/topology        → relationship topology

Auth: API key
Scope: analytics:read | explorer:read
```

## Phase 4 — Orchestration API (Gate D)

```
POST /api/v1/nexus/intents            → declare coordination intent
GET  /api/v1/nexus/recommendations    → governance-approved actions

Auth: API key + governance approval
Scope: nexus:read | nexus:intents
```

## Phase 5 — Reasoning API (Gate D+)

```
POST /api/v1/reasoning/analyze        → TEC AI analysis request
GET  /api/v1/reasoning/recommendations → TEC AI recommendations

Auth: Tier 3 only + ADR required
Scope: reasoning:read
Assurance: AL-5 (Constitutional)
```

---

# 4. PARTNER ONBOARDING REQUIREMENTS

## Technical Requirements

```
□ Pi App ID registered with Pi Network
□ Domain verified (HTTPS + SSL)
□ isHubNavigation() implemented in all payment handlers
□ No localStorage for TEC tokens
□ CORS restricted to own domain + *.tecosystem.app
□ tec-auth integration tested (SSO flow)
□ Payment flow tested: Mode 1 + Mode 2
□ Webhook endpoint implemented (HTTPS + HMAC verification)
```

## Governance Requirements

```
□ Terms of Service agreed
□ Pi Network developer agreement in compliance
□ Data handling declaration (what user data is stored)
□ Economic model declared (free / subscription / per-transaction)
□ Support contact registered
□ Incident notification contact registered
```

## Quality Gates

```
□ API integration test suite provided
□ Payment error handling demonstrated
□ Auth failure handling demonstrated
□ Rate limit handling implemented
□ Webhook retry logic implemented
```

---

# 5. API KEY GOVERNANCE

```
API Key types:
  pk_live_*    → production (Tier 2 + 3)
  pk_test_*    → sandbox (all tiers)
  sk_live_*    → server-side only (never client-exposed)

Key rotation:
  Scheduled: every 90 days (recommended)
  Emergency: immediate on suspected compromise
  Revocation: takes effect within 60 seconds

Key scope:
  Each key has declared scopes (identity, payments, analytics...)
  Key cannot exceed the tier's allowed scope

Audit:
  Every API call logged with: key_id + actor + endpoint + timestamp
  Anomaly detection: > 2σ from baseline → alert
  Abuse threshold: 3 violations → auto-revoke + human review
```

---

# 6. DEVELOPER EXPERIENCE REQUIREMENTS

For TEC to compete with Stripe / Shopify developer experience:

```
Documentation (Gate A prerequisite):
  □ API reference (OpenAPI 3.0)
  □ Quick start (< 15 minutes to first Pi payment)
  □ Integration guides (Next.js, React, Node.js)
  □ Error code reference
  □ Webhook reference
  □ isHubNavigation() guide (Pi-specific — critical)

Developer Tools (Gate B):
  □ Developer Portal (portal.tecosystem.app)
  □ Sandbox environment
  □ API key management UI
  □ Payment testing dashboard
  □ Webhook inspector
  □ API usage analytics

SDKs (Gate B):
  □ JavaScript/TypeScript SDK (@tec/sdk)
  □ React hooks (@tec/react)
  □ Next.js helpers (@tec/nextjs)
  Future: Python, Go (Gate D)

Support (Gate B):
  □ Developer Discord
  □ GitHub Issues + response SLA
  □ Status page (status.tecosystem.app)
  □ Changelog (breaking changes with migration guides)
```

---

# 7. PARTNER TIERS

| Feature | Tier 1 (Internal) | Tier 2 (Partner) | Tier 3 (Infrastructure) |
|---------|------------------|-----------------|------------------------|
| Identity API | ✅ Full | ✅ Full | ✅ Full |
| Payment API | ✅ Full | ✅ Full | ✅ Full |
| Analytics API | ✅ Full | ✅ Read | ✅ Full |
| Explorer API | ✅ Full | ✅ Read | ✅ Full |
| Nexus API | ✅ Full | ❌ | ✅ Intents |
| TEC AI API | ✅ Full | ❌ | ✅ Read |
| Rate limit | Unlimited | 100/min | 1000/min |
| SLA | 99.9% | 99.5% | 99.9% |
| Support | Dedicated | Discord | Dedicated |
| Gate required | Current | Gate B | Gate D+ |

---

# 8. ECONOMIC MODEL FOR PARTNERS

> Truth State: [Future Vision] | Commitment: [Tentative]

```
Value Exchange:
  Partner uses TEC infrastructure
  → TEC provides: identity, payments, intelligence, coordination
  → Partner provides: economic activity on Pi Network
  → Pi Network grows: more transactions, more users, more value

Potential Revenue Model (requires ADR before implementation):
  Option A: Volume-based API fee (Pi per 1000 calls)
  Option B: Success fee (Pi per completed payment)
  Option C: Subscription tier (Pi per month)
  Option D: Freemium (base free, advanced paid)

Constitutional Rule:
  Revenue model requires new ADR.
  INV-E5 applies: fees always declared before execution.
  Pi Network policy compliance required before any fee model.
```

---

# 9. COMPETITIVE POSITIONING

```
Why TEC > building directly on Pi Network:

  Pi Network gives you:       TEC gives you on top:
  ─────────────────────       ──────────────────────────────────────
  Wallet                  →   Wallet + Balance history + LedgerEntries
  Identity primitive      →   Identity + KYC + Trust resolution + SSO
  Payment API             →   Payment API + Orchestration + Outbox + Retry
  Pi Browser              →   Pi Browser + Hub redirect + Mode 1/2 handling
  (nothing)               →   Economic graph (Connection + Explorer)
  (nothing)               →   Analytics + Intelligence signals
  (nothing)               →   TEC AI reasoning (Gate D+)
  (nothing)               →   Governance infrastructure (ADR + Kill switches)
```

---

# FINAL STATEMENT

```
TEC is not a middleman between developers and Pi Network.
TEC is the economic coordination layer that makes Pi Network
programmable at scale.

Without TEC:
  Developer solves: auth + payments + trust + economic graph
  Time to first production app: months
  Risk: high (each team reinvents the wheel)

With TEC:
  Developer solves: their specific economic problem
  Time to first production app: hours (when DX complete)
  Risk: low (platform handles the hard parts)

This is the developer value proposition.
This is why TEC must be infrastructure — not just apps.
```
