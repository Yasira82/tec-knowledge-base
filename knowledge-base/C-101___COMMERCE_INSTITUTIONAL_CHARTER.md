# C-101 — COMMERCE INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** Current State
**Governance State:** Draft
**Verification State:** Documentation Verified + Code Verified
**Authority Scope:** Application
**Decision Status:** Approved

---

## 1. MISSION

Commerce is the merchant production layer of the TEC ecosystem — the system through which Pi-economy merchants create products, manage orders, fulfill transactions, and track revenue in Pi.

---

## 2. INSTITUTIONAL ROLE

**System of Production (Merchant Layer)** — Economic production through merchant commerce.

```
Settlement → Record → Reasoning → Access → Construction → PRODUCTION → Economic Activity → Settlement
                                                               ↑
                                                           COMMERCE
```

Commerce is the institutional bridge between merchant capability (product creation, order management) and Pi-native settlement. It is the reference implementation for all platform payment patterns.

---

## 3. ECONOMIC PURPOSE

Commerce exists to enable Pi-denominated merchant commerce within the TEC ecosystem:

- **Merchant Onboarding**: Merchants register their store, publish products priced in Pi
- **Order Lifecycle Management**: From cart → payment approval → fulfillment → settlement
- **Revenue Analytics**: Merchants see Pi earnings broken down by product, period, and order status
- **Merchant Trust**: Verified merchant identity (from tec_user cookie) prevents identity spoofing

Without Commerce, the Pi economy has no production layer — only peer-to-peer transfers. Commerce creates the institutional framework for Pi-denominated goods and services markets.

**Reference Implementation Role**: Commerce is the first app to implement any new platform payment or BFF pattern. Patterns proven here are then propagated to Assets and Ecommerce.

---

## 4. AUTHORITY BOUNDARY

### Owns
- Merchant dashboard UI and layout design
- Product management workflow (create, edit, publish, archive)
- Order fulfillment tracking UI
- Revenue analytics views and reporting design
- Merchant store page routing (`/store/[id]`)
- Pi App ID: `commerce-app-68aa99081fc1897a`

### Does NOT Own
- Payment creation (tec-payment-service owns — Port 4002)
- Order state machine transitions (tec-commerce-service owns — Port 4003)
- Merchant identity verification (tec-auth-service owns — Port 4001)
- Pi SDK calls outside of the ADR-007 guard pattern
- Subscription billing (Hub owns)

### Interface Points
```
Exposes to ecosystem:
  - Reference implementation of BFF route patterns
  - Reference implementation of payment handler pattern (ADR-007)
  - Merchant store pages (public browsable)

Consumed from:
  - Hub (C-100): SSO cookies (tec_access_token, tec_csrf, tec_user), payment modal
  - tec-commerce-service (4003): order creation, product management, merchant records
  - tec-payment-service (4002): payment initiation (Commerce never creates payments directly)
  - @yasser172/tec-auth: getStoredUser(), getAccessToken(), ssoRedirect()
  - @yasser172/tec-ui: TEC_COLORS, GlobalNav, shared components
  - @yasser172/tec-sdk: BFF Gateway proxy
```

---

## 5. TECHNICAL ARCHITECTURE

### Stack
- Next.js 15 App Router + TypeScript strict
- Deployment: Vercel (tec-commerce-app.vercel.app)
- Vitest (unit) + Playwright (e2e)
- @yasser172/tec-ui, @yasser172/tec-auth, @yasser172/tec-sdk

### Critical Security Pattern — Merchant Identity
```typescript
// CORRECT: Merchant identity ALWAYS from tec_user cookie (server-side)
const user = getStoredUser() // reads tec_user cookie
const merchantId = user?.merchantId // derived from authenticated session

// FORBIDDEN: Never trust client-sent merchant IDs
// body.merchantId → REJECTED (Policy CI blocks body.userId / body.merchantId)
```

### ADR-007 — Pi Foreign Session Guard
```typescript
const isHubNavigation = () =>
  document.referrer.toLowerCase().includes('hub.tecosystem.app')

if (isHubNavigation() || !(window as any).Pi || !piReady) {
  redirectToHubPayment(product) // Mode 1: Hub modal redirect
  return
}
// Mode 2: Direct Pi Browser payment
```

### Order Lifecycle (Commerce is CONSUMER, not OWNER)
```
Merchant Dashboard → POST /api/bff/orders → tec-commerce-service (4003)
                                              ↓
                                    tec-payment-service (4002)
                                    [creates payment — Commerce never does this directly]
                                              ↓
                                    Pi Network approval
                                              ↓
                                    POST /api/bff/payment/complete
                                              ↓
                                    Order status: CONFIRMED
```

### BFF Routes
```
GET  /api/bff/products        → tec-commerce-service: product listing
GET  /api/bff/orders          → tec-commerce-service: merchant orders
POST /api/bff/orders          → tec-commerce-service: create order
POST /api/bff/payment/approve → tec-payment-service: Pi callback
POST /api/bff/payment/complete→ tec-payment-service: Pi callback
```

### Revenue Amount Handling
```typescript
// Pi amounts: DECIMAL(20,8) in DB, string in API responses
// CORRECT:
const display = parseFloat(amount).toFixed(2) + ' π'
// FORBIDDEN — precision loss:
const wrong = Number(amount) // floating point truncation
```

### Order State Machine (owned by tec-commerce-service)
```
pending → approved → confirmed → fulfilled → completed
       → cancelled (terminal)
       → failed    (terminal)
Terminal states: completed, cancelled, failed — NO transitions from these
```

---

## 6. SECURITY MODEL

### Authentication
- SSO via Hub cookies: `tec_access_token`, `tec_csrf`, `tec_user`
- CSRF header required on all POST/PUT/DELETE: `x-csrf-token` from `tec_csrf` cookie
- Missing session → deny, redirect to Hub login (P6 Fail Closed)

### Authorization
- Merchant role verified from `tec_user` cookie server-side
- Never trust client-sent `merchantId` — always derive from session
- Policy CI actively blocks any `body.merchantId` or `body.userId` usage

### Threat Vectors & Mitigations
| Threat | Mitigation |
|--------|------------|
| Merchant ID spoofing (body.merchantId) | Policy CI blocks — always from tec_user cookie |
| Pi foreign session (ADR-007) | isHubNavigation() check in every payment handler |
| Revenue amount precision loss | Keep as string until display: parseFloat().toFixed(2) |
| Order state machine bypass | Only tec-commerce-service transitions order state |
| CSRF on mutations | x-csrf-token header required |
| Unauthorized order viewing | Merchant identity from session — never from URL param |

---

## 7. REVENUE MODEL

### Direct
1. **Platform Commission**: Percentage of Pi transactions through Commerce (PRIMARY)
2. **PRO Merchant Tier**: Advanced analytics, featured listings, priority support
3. **Featured Product Placement**: Merchants pay for homepage/search prominence

### Indirect
- Commerce transaction volume drives platform Pi circulation
- Merchant success → merchant loyalty → ecosystem retention
- Analytics data (aggregated) → platform intelligence for TEC AI (C-104)

### Priority Order
1. Transaction commission (immediate, volume-driven)
2. PRO merchant tier (recurring)
3. Featured placement (ad-like model, Phase 2)

---

## 8. KEY METRICS

### SLOs
| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| Commerce app availability | ≥ 99.5% | < 99.0% |
| Order creation success rate | ≥ 98% | < 95% |
| Payment → Order confirmation latency | < 5s P95 | > 10s P95 |
| BFF route response time | < 800ms P95 | > 2s P95 |
| ADR-007 guard coverage | 100% of payment handlers | Any bypass = P0 |

### KPIs
| Metric | Target | Frequency |
|--------|--------|----------|
| Active merchants | Baseline + 15% MoM | Monthly |
| Orders per merchant per day | > 1 average | Weekly |
| Payment success rate | ≥ 95% | Daily |
| Revenue figures accuracy | DECIMAL(20,8) zero truncation errors | Continuous |
| Test coverage | ≥ 60% (Phase 0 gate) | Per PR |
| ADR-007 guard present | 100% of payment handlers | Per PR |

### Health Signals
- Order stuck in 'pending' > 60min → alert (orphan payment reconciliation)
- Revenue figure showing integer (not decimal) → decimal precision violation
- Payment modal opens without Pi Wallet dialog → ADR-007 violation

---

## 9. ECOSYSTEM CONTRIBUTION

1. **Reference Implementation**: Commerce proves every new payment pattern before other apps adopt it. If a BFF pattern works in Commerce, it's safe to propagate.
2. **Pi Economy Production Layer**: Without merchant commerce, Pi tokens have no goods/services to purchase — Commerce creates Pi economic utility
3. **Merchant Trust Anchor**: Verified merchant identity from Hub SSO means buyers can trust that stores are linked to real Pi network identities
4. **Revenue data for analytics**: Commerce transaction data feeds tec-analytics-service (4007) which powers platform intelligence
5. **Pattern validation**: Commerce ADR-007 implementation is the canonical reference — tested first, then replicated in Assets and Ecommerce

---

## 10. FUTURE EVOLUTION

### Phase 1 (Post-Mainnet, Month 1–2)
- Full revenue analytics dashboard: Pi earnings by product, category, time period
- Order fulfillment workflow: packing, shipping status, delivery confirmation
- Merchant profile pages: public-facing store with reputation metrics
- Analytics connection to tec-analytics-service (4007)

### Phase 2 (Month 3–4)
- Merchant reputation system: buyer reviews, dispute resolution
- Subscription product support: recurring Pi payments for merchant services
- Bulk product management: CSV import, batch pricing updates
- Merchant-to-merchant marketplace: reseller channels

### Phase 3 (Month 5–8)
- Multi-currency support: Pi + fiat for hybrid merchants
- Commerce API for external merchants: third-party store integration via Hub SSO
- Inventory management: stock levels, low-stock alerts
- Integration with Estate (C-114) for property-related commerce

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Critical (Pre-Mainnet)**
1. **PI_SANDBOX=false**: Verify production Railway environment variable before mainnet
2. **ADR-007 audit**: Run grep across all payment handler files for `isHubNavigation()` — zero exceptions allowed
3. **Merchant ID policy**: Confirm Policy CI is actively blocking `body.merchantId` in all BFF routes

**P1 — High Priority (Phase 0 completion)**
4. **Test coverage ≥ 60%**: Currently below threshold. Priority test files:
   - Merchant auth guard: missing cookie, valid merchant, wrong role
   - Payment handler (ADR-007): isHubNavigation true/false, piReady false, success
   - Order creation flow: success, payment_id mismatch, duplicate order
   - BFF routes (products, orders): auth fail, gateway error, pagination
5. **@yasser172/tec-ui v1.2.0**: Upgrade to shared PaymentModal when published — replace local implementation
6. **Decimal amount validation**: Add Zod validation on all Pi amount fields to enforce string type

**P2 — Medium Priority (Phase 1)**
7. **Revenue analytics API**: Connect to tec-analytics-service (4007) for merchant earnings dashboard
8. **Order reconciliation**: Implement cron job to detect orders stuck in pending > 60min
9. **Merchant verification badge**: Surface KYC status from tec_user cookie in merchant profile
10. **E2E Playwright tests**: Cover full order creation flow in Pi Browser environment

---

## 12. INTEGRATION MAP

```
C-101 (COMMERCE) depends on:
← C-100 (HUB)           : SSO identity, payment modal, subscription tier
← tec-core-backend      : tec-commerce-service (4003), tec-payment-service (4002)
← @yasser172/tec-auth   : getStoredUser(), merchant identity from cookie
← @yasser172/tec-ui     : TEC_COLORS, components
← @yasser172/tec-sdk    : BFF Gateway proxy

C-101 (COMMERCE) contributes to:
→ C-103 (ECOMMERCE)    : Commerce is reference impl — Ecommerce follows Commerce patterns
→ C-105 (ANALYTICS)   : Transaction data → platform analytics
→ C-109 (NEXUS)       : Merchant activity data for ecosystem coordination

C-101 is REFERENCE IMPLEMENTATION for:
→ Payment handler pattern (ADR-007 guard)
→ BFF route pattern (merchant auth guard)
→ Revenue amount handling (DECIMAL string)
```

---

*Charter issued by TEC Economic Infrastructure Design Partnership*
*Version 1.0 — 2026-06-15*
