# C-103 — ECOMMERCE INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** Current State
**Governance State:** Draft
**Verification State:** Documentation Verified + Code Verified
**Authority Scope:** Application
**Decision Status:** Approved

---

## 1. MISSION

Ecommerce is the consumer marketplace of the TEC ecosystem — the Pi-native shopping experience where users discover products, build carts, and complete purchases using Pi cryptocurrency.

---

## 2. INSTITUTIONAL ROLE

**System of Production (Consumer Marketplace)** — The demand side of the Pi economy.

```
Settlement → Record → Reasoning → Access → Construction → PRODUCTION → Economic Activity → Settlement
                                                               ↑
                                                          ECOMMERCE
                                                      (Consumer Sub-layer)
```

If Commerce (C-101) is the supply side (merchants), Ecommerce is the demand side (consumers). Together they form the complete Pi economic production layer: products created in Commerce are discovered and purchased in Ecommerce.

---

## 3. ECONOMIC PURPOSE

Ecommerce exists to drive Pi token velocity through consumer purchasing:

- **Product Discovery**: Consumers browse Pi-priced goods from TEC merchants
- **Cart Experience**: Multi-item shopping with persistent cart state
- **Pi Checkout**: Streamlined Pi payment flow via CartDrawer or Buy Now
- **Order History**: Transaction record for consumer confidence
- **Merchant Discovery**: Every product links to merchant store page — drives merchant reputation

Ecommerce is the primary Pi token sink in the ecosystem — the place where Pi stored in wallets becomes economic activity. Without Ecommerce, Commerce merchants have no marketplace to sell through.

---

## 4. AUTHORITY BOUNDARY

### Owns
- Consumer shopping UI (product listing, search, filters)
- Shopping cart state (useCart hook, localStorage persistence: `tec_cart`)
- CartDrawer component and multi-item checkout UX
- Store pages (public browsable merchant storefronts)
- Order history view
- Pi App ID: `ecommerce-app-71ca4d3e462eaf54`

### Does NOT Own
- Product data (tec-commerce-service owns — Port 4003)
- Order creation records (tec-commerce-service)
- Payment creation (tec-payment-service — Port 4002)
- Merchant identity verification (tec-auth-service)
- Pi SDK session management (Hub manages via ADR-007)

### Interface Points
```
Exposes to ecosystem:
  - Consumer marketplace (ecommerce.tecosystem.app)
  - Public product listings (browsable without auth)
  - Merchant store pages (/store/[id]) — drives merchant reputation

Consumed from:
  - Hub (C-100): SSO cookies, payment modal (/hub?pay=1), subscription tier
  - tec-commerce-service (4003): products, stores, orders
  - tec-payment-service (4002): payment initiation via BFF
  - @yasser172/tec-auth: getStoredUser(), getAccessToken(), ssoRedirect()
  - @yasser172/tec-ui: TEC_COLORS, GlobalNav, shared components
  - @yasser172/tec-sdk: BFF Gateway proxy
```

---

## 5. TECHNICAL ARCHITECTURE

### Stack
- Next.js 15 App Router + TypeScript strict
- Deployment: Vercel (ecommerce.tecosystem.app)
- Vitest (unit) + Playwright (e2e)
- CI: ✅ GREEN — all tests passing

### Feature Map
```
/shop              → Product listing + search (✅)
/product/[id]      → Product detail + Buy Now (✅)
/store/[id]        → Merchant store + Buy Now (✅)
/orders            → Order history (✅)
CartDrawer         → Multi-item checkout (✅)
ProductCard        → Merchant store link icon (🏪) (✅)
ShopHeader         → Cart badge + floating FAB (✅)
```

### ADR-007 — 4 Guard Locations (DO NOT REMOVE FROM ANY)
```typescript
// All 4 files implement this guard:
const isHubNavigation = () =>
  document.referrer.toLowerCase().includes('hub.tecosystem.app')

if (isHubNavigation() || !(window as any).Pi || !piReady) {
  redirectToHubPayment(...)   // Mode 1
  return
}
// Mode 2: Direct Pi Browser payment
```

Files with ADR-007 guard:
```
src/app/page.tsx                     → handleBuy
src/app/product/[id]/page.tsx        → handleBuy
src/app/store/[id]/page.tsx          → handleBuy
src/components/shop/CartDrawer.tsx   → handleCheckout
```

### Cart State Architecture
```typescript
// useCart hook — localStorage persistence
const CART_KEY = 'tec_cart'

interface CartItem {
  productId: string
  name: string
  price: string // Pi amount as string (DECIMAL precision)
  qty: number
  merchantId: string
}

// Cart total computed from items (never stored, always derived)
const total = items.reduce((sum, item) =>
  sum + parseFloat(item.price) * item.qty, 0
)
```

### BFF Routes
```
GET  /api/bff/products          → tec-commerce-service: product listing + search
GET  /api/bff/store/[id]        → tec-commerce-service: merchant + products
GET  /api/bff/orders            → tec-commerce-service: order history
POST /api/bff/orders            → tec-commerce-service: create order
                                   Payload: { items: [{productId, qty}], payment_id }
                                   OR legacy: { product_id, qty, payment_id }
POST /api/bff/payment/approve   → tec-payment-service: Pi callback
POST /api/bff/payment/complete  → tec-payment-service: Pi callback
POST /api/bff/payment/resolve   → incomplete payment resolver
```

### Order Creation Flow (C-76 Backend-First)
```
1. POST /api/.../payment/create  → backend creates payment record FIRST
2. Pi.createPayment(config, cbs) → Pi Network approval
3. POST /api/bff/payment/approve → onReadyForServerApproval callback
4. POST /api/bff/orders          → order created AFTER payment approved
5. POST /api/bff/payment/complete→ Pi payment finalized
```

**Test Note (C-76)**: Tests failing with 422 means `payment/create` fetch mock missing.
Fix: add `mockCreateSuccess()` before each payment test.

### Auth Pattern
```typescript
const user  = getStoredUser()   // tec_user cookie
const token = getAccessToken()  // tec_access_token cookie
const isAuth = !!(user && token)
headers: { 'x-csrf-token': getCsrfToken() } // tec_csrf cookie
```

---

## 6. SECURITY MODEL

### Authentication
- SSO via Hub cookies: `tec_access_token`, `tec_csrf`, `tec_user`
- Missing session on checkout → deny, redirect to Hub login (P6 Fail Closed)
- CSRF double-submit on all mutations

### Authorization
- Order history: only authenticated user's own orders (never another user's)
- Cart state: client-side only (localStorage) — no server-side cart auth needed
- Checkout requires authentication: unauthenticated cart → Hub login redirect

### Threat Vectors & Mitigations
| Threat | Mitigation |
|--------|------------|
| Pi foreign session | ADR-007 in 4 files — DO NOT REMOVE |
| Cart manipulation (price change) | Server validates price from tec-commerce-service — never trusts client price |
| Order viewing by wrong user | BFF derives user from tec_user cookie — never URL param |
| CSRF on order creation | x-csrf-token required |
| Payment double-charge | C-76 backend-first + outbox pattern in tec-payment-service |
| Cart state poisoning | Cart = display only; server validates all items at checkout |

---

## 7. REVENUE MODEL

### Direct
1. **Platform Commission**: % of every Pi purchase through Ecommerce (PRIMARY)
2. **Featured Listings**: Merchants pay for prominent placement in consumer marketplace
3. **PRO Consumer Features**: Wish lists, price alerts, order tracking (Phase 2)

### Indirect
- Ecommerce drives merchant loyalty to Commerce (C-101) — merchants stay where buyers are
- Consumer purchasing data → platform analytics → better product recommendations (TEC AI)
- High transaction volume → platform Pi circulation → ecosystem health

### Priority Order
1. Platform commission (immediate, volume-driven)
2. Featured merchant placement (ad model, Phase 1)
3. PRO consumer features (Phase 2)

---

## 8. KEY METRICS

### SLOs
| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| Ecommerce app availability | ≥ 99.5% | < 99.0% |
| Checkout success rate | ≥ 95% | < 90% |
| Product listing load time | < 1s P95 | > 3s P95 |
| Cart persistence across sessions | 100% (localStorage) | Any loss event |
| ADR-007 guard coverage (4 files) | 100% | Any bypass = P0 |

### KPIs
| Metric | Target | Frequency |
|--------|--------|----------|
| Daily active shoppers | Baseline + 10% MoM | Monthly |
| Cart → checkout conversion | ≥ 40% | Weekly |
| Payment success rate | ≥ 95% | Daily |
| Average cart value (Pi) | Increasing trend | Weekly |
| Test coverage | ≥ 60% (Phase 0 gate) | Per PR |
| Multi-item checkout usage | ≥ 20% of checkouts | Weekly |

### Health Signals
- Cart total mismatch (client vs server) → pricing inconsistency alert
- ADR-007 guard removed from any of the 4 files → P0 incident
- Payment opens but Pi Wallet doesn't appear → foreign session violation
- Order stuck in pending > 60min → orphan payment reconciliation

---

## 9. ECOSYSTEM CONTRIBUTION

1. **Consumer Demand**: Creates the buyer side of the Pi economy — without consumers, merchants have no market
2. **Pi Token Velocity**: Shopping drives Pi circulation — the primary economic activity driver
3. **Merchant Discovery**: `/store/[id]` pages let consumers discover merchants → drives Commerce adoption
4. **Multi-item Checkout**: CartDrawer pattern enables bundled Pi payments — higher average transaction value
5. **ADR-007 Stress Test**: 4 payment handler files in Ecommerce are the most-tested ADR-007 implementations in the platform
6. **CI Reference**: Ecommerce CI is GREEN — serves as reference for test configuration patterns

---

## 10. FUTURE EVOLUTION

### Phase 1 (Post-Mainnet, Month 1–2)
- Product search and filters: category, price range, merchant, Pi rating
- Wishlist: save products for later (server-side persistence)
- Order tracking: real-time status updates via tec-realtime-service (4009)
- Reviews and ratings: consumer feedback on products and merchants

### Phase 2 (Month 3–4)
- Personalized recommendations: TEC AI (C-104) powered product suggestions
- Price history: track Pi price changes over time
- Group buying: multiple buyers pool Pi for bulk purchase discount
- Merchant subscription products: recurring Pi payments for subscriptions

### Phase 3 (Month 5–8)
- Social commerce: Connection (C-107) integration — see what connections are buying
- Location-aware commerce: Explorer (C-108) integration — products from nearby merchants
- Loyalty tokens: repeat buyers earn Asset (C-102) tokens from merchants
- Live commerce: real-time product launches via tec-realtime-service

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Critical (Pre-Mainnet)**
1. **PI_SANDBOX=false**: Verify production environment
2. **ADR-007 audit**: Confirm all 4 files have guard — run automated check in CI
3. **Server-side price validation**: Verify BFF validates product prices from tec-commerce-service — never trusts client-provided prices

**P1 — High Priority (Phase 0 completion)**
4. **Test coverage ≥ 60%**: Priority files:
   - `src/lib-client/cart/useCart.ts`: addToCart, removeFromCart, updateQty, clearCart, localStorage persist
   - `src/app/api/bff/orders/route.ts`: single product, multi-item, auth fail
   - `src/app/api/bff/payment/approve/route.ts`: success, invalid payment_id, gateway error
   - `src/app/api/bff/payment/complete/route.ts`: success, already completed (409), gateway error
5. **C-76 test pattern**: Add `mockCreateSuccess()` to all payment tests (mock `/api/.../payment/create` fetch)
6. **@yasser172/tec-ui v1.2.0**: Upgrade to shared PaymentModal when published

**P2 — Medium Priority (Phase 1)**
7. **Product search API**: `/api/bff/products?q=...&category=...` with pagination
8. **Wishlist BFF route**: Server-side wishlist via tec-commerce-service
9. **Order reconciliation**: Detect orders stuck in pending > 60min → alert
10. **Pi price display standardization**: All amounts use `parseFloat(amount).toFixed(2) + ' π'` — audit for consistency

---

## 12. INTEGRATION MAP

```
C-103 (ECOMMERCE) depends on:
← C-100 (HUB)           : SSO identity, payment modal, subscription tier
← C-101 (COMMERCE)      : Products and merchant data via tec-commerce-service
← tec-core-backend      : tec-commerce-service (4003), tec-payment-service (4002)
← @yasser172/tec-auth   : getStoredUser(), getAccessToken()
← @yasser172/tec-ui     : TEC_COLORS, components
← @yasser172/tec-sdk    : BFF Gateway proxy

C-103 (ECOMMERCE) contributes to:
→ C-101 (COMMERCE)     : Consumer demand drives merchant revenue
→ C-105 (ANALYTICS)    : Purchase events → platform analytics
→ C-104 (TEC AI)       : Purchase patterns → recommendation engine
→ C-107 (CONNECTION)   : Social commerce in Phase 3

Follows patterns from:
→ C-101 (COMMERCE)     : Commerce is reference implementation
```

---

*Charter issued by TEC Economic Infrastructure Design Partnership*
*Version 1.0 — 2026-06-15*
