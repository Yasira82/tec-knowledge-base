# C-100 — TEC HUB INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Current State]
**Governance State:** [Draft]
**Verification State:** [Documentation Verified]
**Authority Scope:** [Platform]
**Decision Status:** [Approved]

---

## 1. MISSION

Provide unified, secure, identity-authenticated access to the entire TEC Economic Runtime for every Pi Network user.

---

## 2. INSTITUTIONAL ROLE

```
System of Access
```

Hub is the **Conductor** of the federated platform. Every other app is an instrument. Hub owns the SSO authority contract that all other apps consume — not as a convenience, but as a constitutional requirement.

---

## 3. ECONOMIC PURPOSE

Reduce the friction between the user and the digital economy.

- Without Hub: every app needs its own login → friction → churn
- With Hub: log in once → the whole ecosystem is available
- Hub's economics: an activation engine — every user passes through Hub before reaching any value

---

## 4. AUTHORITY BOUNDARY

### Owns
- SSO authority (cookie issuance: `tec_access_token`, `tec_csrf`, `tec_user`)
- Pi SDK initialization and circuit breaker state
- Payment modal routing (hub?pay=1 — LOCKED)
- App registry and ecosystem navigation
- Wallet display (balance via BFF)
- Hub sub-pages: KYC, Subscription, Notifications, Profile
- Metrics dashboard (24h payment observability)

### Does NOT Own
- Product listings or commerce logic
- Asset ownership records
- Payment processing (delegated to tec-payment-service)
- Identity verification (delegated to tec-auth-service)
- Merchant state

### Interface Points
```
OUTBOUND:
  /hub?pay=1&...       → All apps route payment here (ADR-007 Mode 1)
  Hub SSO cookies      → Consumed by all 4 apps
  /api/bff/metrics     → 24h payment dashboard
  /api/bff/wallet/*    → Wallet data (token-refresh aware)

INBOUND:
  Pi SDK callbacks     → PiRuntime.* (PAL abstraction)
  tec-payment-service  → approve/complete callbacks
  tec-auth-service     → JWT verification + session refresh
```

---

## 5. TECHNICAL ARCHITECTURE

```
Stack:
  Next.js 15 App Router + TypeScript strict
  @yasser172/tec-ui (shared design system)
  @yasser172/tec-auth (usePiAuth, ssoRedirect)
  @yasser172/tec-sdk (BFF → API Gateway)
  packages/tec-core-sdk (browser Pi SDK hooks)
  Deployment: Vercel

Key Patterns:
  PiRuntime.* — PAL abstraction (never window.Pi.* directly)
  PiCircuitBreaker — CLOSED→OPEN(3 failures/60s)→HALF_OPEN
  BFF-first rule — all data via /api/bff/* (auto token refresh)
  CSRF double-submit — all POST/PUT/DELETE require x-csrf-token
  isHubNavigation() — ADR-007 guard before every Pi call

BFF Routes:
  GET  /api/bff/wallet/balance   → balance (createHandler + refresh)
  GET  /api/bff/payments/history → payment history
  GET  /api/bff/notifications    → notifications
  GET  /api/bff/metrics          → 24h observability
  POST /api/bff/payment/approve  → Pi callback
  POST /api/bff/payment/complete → Pi callback
  POST /api/bff/payment/resolve  → orphan recovery

Key Files:
  src/lib-client/pi/PiRuntime.ts      → Pi abstraction layer
  src/lib-client/pi/PiCircuitBreaker.ts → circuit breaker
  src/app/hub/layout.tsx              → imports design tokens CSS
  src/styles/tec-design-tokens.css    → --tec-gold, --tec-surface-*
```

---

## 6. SECURITY MODEL

```
Identity:
  Pi SDK authentication via PiRuntime.authenticate()
  JWT HS256 — issued by tec-auth-service
  HttpOnly cookies for sensitive tokens
  CSRF double-submit on all mutations

Session:
  tec_access_token: false (Pi Browser needs document.cookie)
  tec_refresh_token: true (server-side only)
  tec_user: false (client needs user data)
  tec_csrf: false (double-submit pattern)
  sameSite: 'none' REQUIRED (Pi Browser WebView)

Payment:
  ADR-007 — isHubNavigation() before every Pi call
  PiCircuitBreaker — 3 failures → OPEN 60s → HALF_OPEN
  C-76 backend-first — /api/bff/payment/create BEFORE Pi.createPayment
  Terminal state protection — no transitions from completed/failed/cancelled

Infrastructure:
  No Railway URLs in client bundle (NEW-A compliant)
  API_GATEWAY_URL server-only (never NEXT_PUBLIC_)
  INTERNAL_SECRET conditional header (only when SET)
```

---

## 7. REVENUE MODEL

**Indirect (Platform Activation)**

| Channel | Mechanism | Priority |
|---------|-----------|----------|
| Traffic routing | All users enter Hub first → distribute to apps | P1 |
| Subscription | FREE/PRO/ENTERPRISE plans — /hub/subscription | P1 |
| Cross-sell | App discovery grid → Commerce, Assets, Ecommerce | P2 |
| Retention | Wallet card, Pi price carousel, notifications | P2 |

Hub never charges transaction fees — its economic value is activation and retention of the ecosystem.

---

## 8. KEY METRICS

```
Availability:     ≥ 99.9% uptime (identity authority — cannot go down)
SSO Success Rate: ≥ 99.5% (cookie issuance on Pi authenticate)
Payment Routing:  ≥ 99% (hub?pay=1 modal opens correctly)
CI Green:         ✅ 2026 tests passing — MUST NEVER drop
Circuit Breaker:  < 1% OPEN state in 24h window
Token Refresh:    100% success on /api/bff/wallet/balance
Page Load (P95):  < 2s on Pi Browser
Notification Delivery: ≥ 99% (eventual — 5min max delay)
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **SSO Authority** — single source of identity for 4 apps + all future apps
- **Payment Modal** — unified payment entry point prevents fragmentation
- **Metrics Dashboard** — only place with 24h cross-app payment observability
- **Navigation** — discovery mechanism that drives traffic to all production systems
- **Subscription** — monetizes the platform layer independent of transaction volume

---

## 10. FUTURE EVOLUTION

```
Phase 1 (Post-Mainnet):
  → Hub Analytics Dashboard — cross-app activity timeline
  → App Registry — dynamic (not hardcoded grid)
  → Advanced notifications — push (Pi Browser) + in-app

Phase 2:
  → Unified Economic Dashboard — wallet + spending + assets + orders
  → VIP/PRO/ENTERPRISE subscription gating
  → Hub as Economic Console — Life + Connection + Analytics data

Phase 3:
  → Federated SSO for external Pi apps (Hub as identity provider)
  → AI-assisted Hub (TEC AI recommendations on dashboard)
  → Economic Operating Console for full ecosystem
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Security Critical:**
```
[P0-1] PAL Completion (Objective 0.0)
  PiRuntime.init() and PiRuntime.createPayment() must be the ONLY
  entry points for Pi SDK. Audit all files for window.Pi.* direct calls.
  Files: src/lib-client/pi/PiRuntime.ts
```

**P1 — Phase 0 Gate:**
```
[P1-1] External Audit ≥ 9.5
  All P1 violations closed. Only NEW-B remains (ops task).
  PRs #27 (Ecommerce) and #24 (Hub) must be merged first.

[P1-2] PI_SANDBOX=false Verification
  Confirm on Vercel env — cannot submit to Pi Network with sandbox=true.

[P1-3] Subscription Gating
  /hub/subscription page exists but gating logic (FREE vs PRO feature set)
  is not implemented. Define capability matrix before Phase 1.
```

**P2 — Post-Mainnet:**
```
[P2-1] App Registry Dynamic Loading
  HubAppsGrid currently hardcoded. Move to API-driven config.

[P2-2] Real-time Notifications
  Current: polling. Target: WebSocket via tec-realtime-service (4009).

[P2-3] Hub Metrics Granularity
  /api/bff/metrics returns 24h window. Add 7d + 30d windows.
```

---

## 12. INTEGRATION MAP

```
This charter (C-100) depends on:
  C-101 COMMERCE  → /hub?pay=1 routing from commerce
  C-102 ASSETS    → /hub?pay=1 routing from assets
  C-103 ECOMMERCE → /hub?pay=1 routing from ecommerce
  C-104 TEC AI    → future: AI recommendations on Hub dashboard
  C-110 SYSTEM    → subscription governance + feature gating

All other charters depend on this one for:
  SSO cookie contract
  Payment modal URL (/hub?pay=1)
  isHubNavigation() behavior (ADR-007)
```
