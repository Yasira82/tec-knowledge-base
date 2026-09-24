# C-101 — COMMERCE INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Current State]
**Governance State:** [Draft]
**Verification State:** [Documentation Verified]
**Authority Scope:** [Application]
**Decision Status:** [Approved]

---

## 1. MISSION

Enable Pi-native merchant commerce — product listings, order management, and revenue analytics — for businesses operating inside the TEC ecosystem.

---

## 2. INSTITUTIONAL ROLE

```
System of Production — Economic Exchange Infrastructure
Reference Implementation for payment and BFF patterns
```

Commerce is the **reference implementation** for all platform-level engineering patterns. If a payment pattern, BFF route, or auth guard works here, it is then propagated to Assets and Ecommerce.

---

## 3. ECONOMIC PURPOSE

Create real economic exchange inside the system.

- Without Commerce: the Pi economy is theoretical — no real goods
- With Commerce: merchants sell in Pi → real economic velocity
- Economically: every commercial transaction = proof that Pi has utility

---

## 4. AUTHORITY BOUNDARY

### Owns
- Merchant dashboard UI and product management
- Order creation and fulfillment tracking UI
- Revenue analytics views (earnings by product, by period)
- Merchant session context (from tec_user cookie)
- Payment initiation (Mode 1 via Hub OR Mode 2 direct)

### Does NOT Own
- Order state machine (owned by tec-commerce-service:4003)
- Payment processing (owned by tec-payment-service:4002)
- Merchant identity verification (owned by tec-auth-service:4001)
- Pi amounts calculation authority (backend owns truth)

### Interface Points
```
OUTBOUND:
  /api/bff/products → tec-commerce-service (product CRUD)
  /api/bff/orders   → tec-commerce-service (order creation)
  /hub?pay=1&...    → Mode 1 payment (ADR-007)
  Pi.createPayment  → Mode 2 payment (only when !isHubNavigation)

INBOUND:
  tec_user cookie   → merchant identity (NEVER body.merchantId)
  /api/bff/payment/approve  → Pi callback
  /api/bff/payment/complete → Pi callback
```

---

## 5. TECHNICAL ARCHITECTURE

```
Stack:
  Next.js 15 App Router + TypeScript strict
  @yasser172/tec-ui v1.2.1 (PaymentModal, TEC_COLORS)
  @yasser172/tec-auth (getStoredUser, getAccessToken, ssoRedirect)
  @yasser172/tec-sdk (BFF → API Gateway:4000 → commerce-service:4003)
  Vitest (unit) + Playwright (e2e)
  Deployment: Vercel (custom domain commerce.tecosystem.app)

Pi App ID: commerce-app-68aa99081fc1897a
Domain:    https://commerce.tecosystem.app

Critical Security Pattern:
  Merchant identity = ALWAYS from tec_user cookie (server-side)
  Policy CI blocks body.merchantId and body.userId
  NEVER derive merchant from request body

Payment Flow (ADR-007):
  if (isHubNavigation() || !piReady) → /hub?pay=1&...  (Mode 1)
  else → Pi.createPayment(...)                          (Mode 2)

Revenue Figures Pattern:
  DB:  DECIMAL(20,8)
  API: string (never JS Number — float precision loss)
  UI:  parseFloat(amount).toFixed(2) + ' π'

Order State Machine (tec-commerce-service owns):
  pending → payment_approved → fulfilling → completed
  pending → cancelled
  payment_approved → payment_failed
  Terminal: completed, cancelled, payment_failed (NO transitions out)
```

---

## 6. SECURITY MODEL

```
Merchant Authorization:
  Source: tec_user cookie ONLY
  Verification: server-side in every BFF route
  Forbidden: body.merchantId, body.userId, query.merchantId
  Policy CI: blocks any body.userId or body.merchantId pattern

Payment Security:
  ADR-007 guard: isHubNavigation() in every payment handler
  C-76 backend-first: /api/bff/payment/create BEFORE Pi.createPayment
  Idempotency: Idempotency-Key header on all payment calls
  Terminal state: orders in completed/cancelled/payment_failed = immutable

SSO:
  Cookies from Hub: tec_access_token, tec_csrf, tec_user
  NEVER localStorage for tokens
  CSRF header on all POST/PUT/DELETE

Infrastructure:
  API_GATEWAY_URL: server-only env var (never NEXT_PUBLIC_)
  INTERNAL_SECRET: conditional header (only when SET)
  Railway URLs: NEVER in client bundle or API responses
```

---

## 7. REVENUE MODEL

**Direct (Transaction-Based)**

| Channel | Mechanism | Target |
|---------|-----------|--------|
| Transaction Fees | % of each Pi sale | Primary |
| Merchant Services | Premium listings, featured placement | Secondary |
| Promotions | Paid visibility boosts | Tertiary |
| Analytics | Merchant intelligence reports | Phase 2 |

Revenue truth: tec-commerce-service owns all Pi amount calculations. Commerce UI only displays — never computes.

---

## 8. KEY METRICS

```
Order Creation Success:  ≥ 98% (POST /api/bff/orders)
Payment Success Rate:    ≥ 95% (Mode 1 + Mode 2 combined)
Order State Correctness: 100% (no stuck 'pending' after payment)
Merchant Auth Failures:  0 (body.merchantId NEVER accepted)
Revenue Figure Accuracy: 100% DECIMAL(20,8) preserved end-to-end
Test Coverage:           ≥ 60% (Phase 0 gate — PENDING)
CI Status:               Must be green before any deploy
Page Load (P95):         < 3s on Pi Browser
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Reference Implementation** — payment and BFF patterns proven here first, then propagated
- **Merchant Economic Activity** — primary revenue-generating surface for Pi ecosystem
- **Order Audit Trail** — every order has actor context + full audit (System Invariant #4)
- **Pattern Library** — isHubNavigation(), getUserId, conditional x-internal-key all originated here

---

## 10. FUTURE EVOLUTION

```
Phase 1 (Post-Mainnet):
  → Test coverage ≥ 60% (Vitest)
  → Analytics: merchant sees Pi earnings by product and period
  → Order fulfillment: full cycle tracking UI

Phase 2:
  → Multi-merchant marketplace (discovery across merchants)
  → Subscription commerce (recurring Pi payments)
  → Merchant analytics dashboard via tec-analytics-service

Phase 3:
  → Federated Pi Marketplace Infrastructure
  → B2B commerce (merchant-to-merchant)
  → Revenue sharing with TEC ecosystem
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Security Critical:**
```
[P0-1] Policy CI Audit
  Verify grep pattern 'body\.merchantId|body\.userId' blocks in CI.
  Test: attempt to POST with body.merchantId → must return 403.
```

**P1 — Phase 0 Gate:**
```
[P1-1] Test Coverage ≥ 60%
  Priority scenarios:
  - Merchant auth guard: missing cookie, valid merchant, wrong role
  - Payment handler: isHubNavigation true/false, piReady false, success
  - Order creation: success, payment_id mismatch, duplicate order
  - BFF routes: auth fail, gateway error, pagination

[P1-2] PI_SANDBOX=false Verification
  Confirm on Vercel — commerce Pi App ID must be in production mode.

[P1-3] Domain Registration — ✅ DONE (21 Jun 2026)
  Pi App ID commerce-app-68aa99081fc1897a registered in the
  Pi Developer Portal on commerce.tecosystem.app.
  Domain: commerce.tecosystem.app (aligned with ecosystem) ✅
```

**P2 — Post-Mainnet:**
```
[P2-1] Merchant Analytics
  Connect to tec-analytics-service (4007) for Pi earnings data.

[P2-2] Order Fulfillment Tracking
  Real-time order state via tec-realtime-service (4009) WebSocket.
```

---

## 12. INTEGRATION MAP

```
This charter (C-101) depends on:
  C-100 HUB       → SSO cookies + /hub?pay=1 routing
  C-105 ANALYTICS → merchant revenue intelligence (Phase 2)
  C-110 SYSTEM    → governance policies for merchant activation

Other charters depend on this one for:
  C-102 ASSETS    → payment pattern (reference impl)
  C-103 ECOMMERCE → payment pattern (reference impl)
  C-100 HUB       → payment callback patterns
```
