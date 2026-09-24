# C-103 — ECOMMERCE INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Current State]
**Governance State:** [Draft]
**Verification State:** [Documentation Verified]
**Authority Scope:** [Application]
**Decision Status:** [Approved]

---

## 1. MISSION

Enable Pi-native consumer commerce — product discovery, multi-item shopping cart, merchant stores, and Pi payments — for end consumers on the TEC platform.

---

## 2. INSTITUTIONAL ROLE

```
System of Production — Consumer Marketplace
```

Ecommerce is the **consumer-facing marketplace** — the highest transaction volume surface in the ecosystem. It follows payment patterns established in Commerce (reference implementation).

---

## 3. ECONOMIC PURPOSE

Turn users into active buyers inside the Pi economy.

- Without Ecommerce: the Pi economy is limited to peer-to-peer
- With Ecommerce: consumer demand → merchant supply → economic cycle
- Economically: the highest transaction volume in the system → proof of Pi utility at scale

---

## 4. AUTHORITY BOUNDARY

### Owns
- Product listing display and search
- Shopping cart state (localStorage `tec_cart`)
- Consumer checkout flow (CartDrawer)
- Order history display
- Merchant store pages

### Does NOT Own
- Product inventory truth (tec-commerce-service:4003)
- Order state machine (tec-commerce-service)
- Payment processing (tec-payment-service:4002)
- Merchant identity (tec-auth-service:4001)

### Interface Points
```
OUTBOUND:
  GET  /api/bff/products        → product listing + search
  GET  /api/bff/store/[id]      → merchant + products
  GET  /api/bff/orders          → order history
  POST /api/bff/orders          → create order (items[] or product_id)
  /hub?pay=1&...                → Mode 1 payment (ADR-007)
  Pi.createPayment              → Mode 2 payment (only when !isHubNavigation)

INBOUND:
  POST /api/bff/payment/approve → Pi callback
  POST /api/bff/payment/complete → Pi callback
  POST /api/bff/payment/resolve  → orphan recovery
```

---

## 5. TECHNICAL ARCHITECTURE

```
Stack:
  Next.js 15 App Router + TypeScript strict
  @yasser172/tec-ui v1.2.1 (CartDrawer, PaymentModal, TEC_COLORS)
  @yasser172/tec-auth (getStoredUser, getAccessToken, ssoRedirect)
  @yasser172/tec-sdk (BFF → API Gateway:4000)
  Vitest (unit) + Playwright (e2e)
  Deployment: Vercel (ecommerce.tecosystem.app)

Pi App ID: ecommerce-app-71ca4d3e462eaf54
Domain:    https://ecommerce.tecosystem.app

Cart Architecture:
  useCart hook → localStorage 'tec_cart'
  CartDrawer → multi-item checkout UI
  ShopHeader → cart badge + floating FAB
  Cart total = sum(price × qty) — NEVER modified server-side before order

ADR-007 Guard Files (ALL 4 MUST HAVE guard):
  src/app/page.tsx                   → handleBuy
  src/app/product/[id]/page.tsx      → handleBuy
  src/app/store/[id]/page.tsx        → handleBuy
  src/components/shop/CartDrawer.tsx → handleCheckout

CI Status: ✅ GREEN (commit 33d2d141)
  - All tests passing
  - x-internal-key sent only when INTERNAL_SECRET SET
  - getUserId: u?.id ?? u?.sub ?? u?.piId ?? ''
  - NEXT_PUBLIC fallback for GW URL in all 3 payment routes
```

---

## 6. SECURITY MODEL

```
Cart Security:
  Cart = client-side only (localStorage)
  Order total verified server-side against product prices
  NEVER trust client-sent prices in order creation

Payment Security:
  ADR-007 in ALL 4 payment handlers — DO NOT REMOVE
  C-76 backend-first: /api/bff/payment/create BEFORE Pi.createPayment
  x-internal-key: conditional (only when INTERNAL_SECRET SET)
  CSRF: double-submit on all mutations

Auth:
  Consumer identity: tec_user cookie (never body.userId)
  Order ownership: verified from session on every BFF call
  CSRF: x-csrf-token header required

Infrastructure:
  API_GATEWAY_URL ?? NEXT_PUBLIC_API_GATEWAY_URL (Vercel fallback)
  INTERNAL_SECRET: never send empty string — causes Gateway 401
```

---

## 7. REVENUE MODEL

**Transaction-Based (Platform Marketplace)**

| Channel | Mechanism | Target |
|---------|-----------|--------|
| Platform Fees | % of each Pi transaction via Ecommerce | Primary |
| Featured Products | Paid placement in search results | Secondary |
| Merchant Premium | Enhanced store pages + analytics | Phase 2 |

---

## 8. KEY METRICS

```
Payment Success Rate:     ≥ 95% (24h target — /api/bff/metrics)
Cart-to-Order Rate:       Track (baseline needed after Mainnet)
ADR-007 Guard Coverage:   100% — all 4 payment handler files
CI Green:                 ✅ MUST NEVER drop (33d2d141 baseline)
Order Creation Success:   ≥ 98%
Gateway 401 Rate:         0% (x-internal-key bug fixed 5d44c501)
Test Coverage:            ≥ 60% (Phase 0 gate — PENDING)
Page Load (P95):          < 3s on Pi Browser
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Highest Transaction Volume** — primary proof of Pi utility at scale
- **Consumer Demand Signal** — drives merchant supply in Commerce
- **Cart Pattern** — useCart hook usable across all consumer apps
- **Merchant Discovery** — every product links to merchant store (🏪)

---

## 10. FUTURE EVOLUTION

```
Phase 1:
  → Test coverage ≥ 60% (Vitest for useCart + BFF routes)
  → Wishlist / saved items
  → Order tracking via tec-realtime-service

Phase 2:
  → Personalized recommendations (TEC AI integration)
  → Multi-currency display (Pi + fiat equivalent)
  → Subscription purchasing (recurring Pi payments)

Phase 3:
  → Social commerce (Connection graph → product discovery)
  → Live commerce (realtime seller sessions)
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Already Fixed (document for audit):**
```
[P0-DONE] x-internal-key empty string bug
  Fixed: 5d44c501 — conditional header pattern
  Fixed: getUserId pattern: u?.id ?? u?.sub ?? u?.piId ?? ''
  Fixed: NEXT_PUBLIC fallback in all 3 payment BFF routes
```

**P1:**
```
[P1-1] Test Coverage ≥ 60%
  Priority:
  - useCart: addToCart, removeFromCart, updateQty, clearCart, persist
  - POST /api/bff/orders: single product, multi-item, auth fail
  - POST /api/bff/payment/approve: success, invalid, gateway error
  - POST /api/bff/payment/complete: success, 409 (already done), error

[P1-2] PI_SANDBOX=false Verification
  Confirm on Vercel for Pi App ID ecommerce-app-71ca4d3e462eaf54.
```

**P2:**
```
[P2-1] PAL Integration
  Ecommerce currently uses window.Pi indirectly via tec-core-sdk.
  When PiRuntime is fully built in Hub, Ecommerce should consume
  the same abstraction.

[P2-2] Product Search Optimization
  Current: client-side filter on loaded products.
  Target: server-side search via tec-commerce-service query params.
```

---

## 12. INTEGRATION MAP

```
This charter (C-103) depends on:
  C-100 HUB       → SSO cookies + /hub?pay=1 routing
  C-101 COMMERCE  → product truth from tec-commerce-service
  C-104 TEC AI    → future: personalized recommendations
  C-107 CONNECTION → future: social commerce

Other charters depend on this one for:
  C-105 ANALYTICS → consumer behavior + transaction volume data
```
