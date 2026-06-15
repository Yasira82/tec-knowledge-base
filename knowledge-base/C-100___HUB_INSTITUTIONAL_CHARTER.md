# C-100 — TEC HUB INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** Current State
**Governance State:** Draft
**Verification State:** Documentation Verified + Code Verified
**Authority Scope:** Platform
**Decision Status:** Approved

---

## 1. MISSION

Hub is the identity authority, payment orchestrator, and access control plane for the entire TEC Federated Platform — the single entry point through which every user, every payment, and every session must pass.

---

## 2. INSTITUTIONAL ROLE

**System of Access** — The Conductor of the TEC Economic Runtime.

Hub sits at the intersection of every economic lifecycle:
```
Settlement → Record → Reasoning → ACCESS → Construction → Production → Economic Activity → Settlement
                                    ↑
                                  HUB
```

Without Hub, no other system can authenticate, pay, or operate. Hub is not an app — it is the platform's immune system and front door simultaneously.

---

## 3. ECONOMIC PURPOSE

Hub solves the identity-payment bootstrap problem in a decentralized Pi-native ecosystem:

- **Who are you?** — SSO via Pi identity, one authenticated session shared across all apps
- **What can you do?** — Subscription tier (FREE/PRO/ENTERPRISE) gates capabilities
- **Can you pay?** — Payment orchestration via Pi wallet, single approval flow
- **Are you verified?** — KYC status exposed to all downstream apps

Without Hub as the central authority, each app would need to independently implement Pi authentication, creating fragmentation, security drift, and a broken user experience across the ecosystem.

Hub enforces: one identity → one session → one wallet → one payment flow → all apps.

---

## 4. AUTHORITY BOUNDARY

### Owns
- SSO identity for all TEC apps (Pi username → TEC session)
- Cookie contract: `tec_access_token`, `tec_csrf`, `tec_user` (LOCKED — changes require platform-wide coordination)
- Payment modal: `/hub?pay=1&...` is the canonical payment URL (ADR-007)
- Subscription tiers: FREE / PRO / ENTERPRISE — gating logic lives here
- KYC status exposure (delegates verification to tec-kyc-service)
- App registry: which apps exist in the ecosystem
- Wallet balance display (reads from tec-payment-service via BFF)
- Circuit breaker for Pi SDK: PiCircuitBreaker (3 failures → OPEN 60s → HALF_OPEN)
- Pi Abstraction Layer (PAL): PiRuntime.* — all window.Pi calls must go through here

### Does NOT Own
- Pi identity verification (tec-auth-service owns — Port 4001)
- Wallet ledger mutations (tec-payment-service — Port 4002)
- Order lifecycle (tec-commerce-service — Port 4003)
- KYC verification logic (tec-kyc-service — Port 4005)
- Asset ownership (tec-asset-service — Port 4006)
- Analytics aggregation (tec-analytics-service — Port 4007)

### Interface Points
```
Exposes to all downstream apps:
  - SSO session via HttpOnly cookies (tec_access_token, tec_csrf, tec_user)
  - Payment entry: /hub?pay=1&product=...&amount=...&appId=...
  - KYC status readable from tec_user cookie payload
  - Subscription tier readable from tec_user cookie payload

Consumed from upstream:
  - tec-auth-service (4001): Pi identity verification, JWT issuance
  - tec-payment-service (4002): wallet balance, payment initiation
  - tec-kyc-service (4005): KYC workflow
  - tec-analytics-service (4007): 24h payment metrics dashboard
```

---

## 5. TECHNICAL ARCHITECTURE

### Stack
- Next.js 15 App Router + TypeScript strict
- @yasser172/tec-auth (SSO hooks, cookie parsing)
- @yasser172/tec-ui (shared design system — TEC_COLORS, GlobalNav)
- @yasser172/tec-sdk (server-side BFF SDK — API Gateway proxy)
- packages/tec-core-sdk (browser Pi SDK hooks — usePiAuth, useTecWallet)
- Deployment: Vercel

### Key BFF Routes
```
GET  /api/bff/wallet/balance    → tec-payment-service (cookie auth + token refresh) ✅ USE THIS
GET  /api/bff/payments/history  → tec-payment-service (payment history)
GET  /api/bff/metrics           → tec-analytics-service (24h observability)
GET  /api/bff/notifications     → tec-notification-service
POST /api/bff/payment/approve   → Pi payment callback handler
POST /api/bff/payment/complete  → Pi payment callback handler
POST /api/bff/payment/resolve   → Incomplete payment reconciliation
⚠️  /api/wallet/balance         → LEGACY — Authorization header only, no token refresh
```

### Pi Abstraction Layer (PAL)
```typescript
// ALL window.Pi.* calls go through PiRuntime — never call window.Pi directly
PiRuntime.init(appId, sandbox)         // replaces window.Pi.init
PiRuntime.authenticate(scopes, cb)     // with circuit breaker + ADR-007 check
PiRuntime.createPayment(config, cbs)   // with ownership check (C-76)
PiRuntime.canAttempt()                 // circuit breaker state check
```

### ADR-007 — Foreign Session Guard
```typescript
const isHubNavigation = () =>
  document.referrer.toLowerCase().includes('hub.tecosystem.app')

// Before EVERY Pi payment:
if (isHubNavigation() || !window.Pi || !piReady) {
  redirectToHubModal(product)
  return
}
```

### Hub Sub-Pages
```
/hub          → Home: wallet card, apps grid, payment modal
/hub/kyc      → KYC verification flow
/hub/subscription → FREE/PRO/ENTERPRISE plans
/hub/notifications → Notification center
/hub/profile  → Account info + quick actions
/hub/pay      → Redirects to /hub?pay=1 (governance: never process payments here)
```

### Circuit Breaker State Machine
```
CLOSED → (3 failures) → OPEN → (60s timeout) → HALF_OPEN → (success) → CLOSED
                                                            → (failure) → OPEN
State persisted: localStorage key 'tec_pi_cb'
Manual recovery: piCircuitBreaker.reset()
```

### BFF-First Rule (enforced — learned from production bug NEW-L)
All client-side data fetching MUST use `/api/bff/*` routes. The legacy `/api/wallet/balance` route silently returns `{balance:0, walletId:null}` on token expiry — the BFF route has `createHandler` with auto token refresh.

---

## 6. SECURITY MODEL

### Authentication
- Pi identity verified exclusively by tec-auth-service (ADR-002)
- JWT HS256 verify() at gateway — NEVER jwt.decode() (Policy CI enforces)
- Session stored in HttpOnly cookies — NEVER localStorage or sessionStorage
- CSRF double-submit pattern: `tec_csrf` cookie + `x-csrf-token` header required on all POST/PUT/DELETE

### Authorization
- Subscription tier read from `tec_user` cookie payload (server-side)
- KYC status gates features requiring verification
- Fail Closed (P6): missing session → deny, redirect to login

### Threat Vectors & Mitigations
| Threat | Mitigation |
|--------|------------|
| Pi SDK foreign session (ADR-007) | isHubNavigation() check before every Pi call |
| Token expiry silent failure | BFF route createHandler with auto refresh |
| CSRF on state mutations | Double-submit cookie pattern |
| Railway URLs in client bundle | BFF proxy — no NEXT_PUBLIC_* for internal URLs |
| Pi SDK circuit open | PiCircuitBreaker — 3 failures → 60s cooldown |
| Session hijacking | HttpOnly + Secure + SameSite=Strict cookies |

---

## 7. REVENUE MODEL

### Direct
1. **Subscription Fees** (PRIMARY): PRO tier ($X/month in Pi), ENTERPRISE tier (negotiated)
2. **Transaction Fees**: Platform cut on Pi payments processed through Hub modal
3. **KYC Upgrade**: Premium KYC verification for high-value transactions

### Indirect
- Hub is the gateway to all commerce — every Pi transaction on the platform flows through Hub payment orchestration
- Higher Hub engagement = higher ecosystem transaction volume = higher platform revenue
- Subscription tier data enables targeted feature gating that drives upgrades

### Priority Order
1. Transaction fees (immediate, tied to payment volume)
2. Subscription upgrades (recurring, predictable)
3. KYC premium services (Phase 1)

---

## 8. KEY METRICS

### SLOs
| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| Hub availability | ≥ 99.9% | < 99.5% |
| SSO cookie issuance success rate | ≥ 99.5% | < 99.0% |
| Payment modal open → approve latency | < 3s P95 | > 5s P95 |
| BFF /wallet/balance response time | < 500ms P95 | > 1s P95 |
| Token refresh success rate | ≥ 99.0% | < 98.0% |
| Pi SDK circuit breaker OPEN frequency | < 1/day | > 3/day |

### KPIs
| Metric | Target | Frequency |
|--------|--------|----------|
| Daily active users (DAU) | Baseline + 10% MoM | Weekly |
| Payment completion rate | ≥ 95% | Daily |
| Session duration | > 5 min average | Weekly |
| PRO subscription conversion | ≥ 5% of active users | Monthly |
| KYC completion rate | ≥ 80% of started flows | Weekly |
| Cross-app navigation rate | ≥ 40% of sessions | Weekly |

### Health Dashboard Signals
- 24h payment metrics: `/api/bff/metrics` (currently implemented)
- Circuit breaker state visible in Hub admin panel (Phase 1)
- BFF route error rates tracked per endpoint

---

## 9. ECOSYSTEM CONTRIBUTION

Hub makes the platform stronger by:
1. **Single authentication point**: Apps don't implement auth — they consume Hub SSO
2. **Payment safety net**: ADR-007 ensures no app triggers Pi SDK in foreign session
3. **Subscription gating**: PRO/ENTERPRISE features consistently enforced platform-wide
4. **Circuit breaker isolation**: Pi SDK failures don't cascade across apps
5. **Observability**: 24h metrics endpoint gives platform-wide payment health visibility
6. **Design consistency**: tec-design-tokens.css imported in hub/layout.tsx ensures all /hub/* sub-pages have consistent styling

---

## 10. FUTURE EVOLUTION

### Phase 1 (Post-Mainnet, Month 1–2)
- Analytics dashboard: Hub admin sees platform-wide payment health, user growth, subscription distribution
- Notification center upgrades: real-time WebSocket via tec-realtime-service (4009)
- Hub VIP/PRO/ENTERPRISE subscription management UI completion
- App registry UI: visual ecosystem map of all TEC apps

### Phase 2 (Month 3–4)
- Multi-app session context: Hub knows which app a user navigated from, personalizes payment modal
- Subscription enforcement API: downstream apps query Hub for tier access (rather than parsing cookie)
- Hub-level analytics: per-app usage, cross-app funnel analysis
- Developer portal: external app registration (Pi Network ecosystem expansion)

### Phase 3 (Month 5–8)
- Hub as OAuth server: external apps can request TEC identity (Hub as IdP)
- Multi-wallet support: Pi wallet + future payment methods
- Hub governance module: voting on platform parameters (SYSTEM integration)
- Economic dashboard: real-time Pi volume, ecosystem GDP, settlement flows

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Critical (Pre-Mainnet)**
1. **NEW-B (OPS)**: Set `INTERNAL_SECRET` on Railway for all 4 services — tec-api-gateway, tec-auth-service, tec-payment-service, tec-commerce-service. Generate with: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`
2. **PI_SANDBOX=false**: Verify `PI_SANDBOX=false` on ALL production Railway services before mainnet submission
3. **Legacy route deprecation**: Add deprecation warning to `/api/wallet/balance` — route should 301 redirect to `/api/bff/wallet/balance`

**P1 — High Priority (Phase 0 completion)**
4. **@yasser172/tec-ui v1.2.0**: Publish with `createU2APayment()` + `PaymentModal` component — Hub currently has its own payment UI that should use the shared version
5. **Notification WebSocket**: Hub notifications currently poll — migrate to tec-realtime-service (4009) WebSocket for real-time delivery
6. **Subscription enforcement**: Subscription tier currently from cookie only — add server-side verification against tec-commerce-service subscription records

**P2 — Medium Priority (Phase 1)**
7. **Hub admin panel**: Circuit breaker status, BFF route health, payment success rates — currently no admin view
8. **App registry API**: `/api/bff/apps` endpoint that returns registered ecosystem apps with their status — currently hardcoded in HubAppsGrid.tsx
9. **Session analytics**: Track which apps users navigate to from Hub — feeds into ecosystem health metrics
10. **Progressive KYC**: KYC prompt triggered by payment amount threshold (e.g., payments > 10 Pi require KYC)

---

## 12. INTEGRATION MAP

```
C-100 (HUB) is the root node — all other systems depend on it for:

→ C-101 (COMMERCE)   : SSO cookies, payment modal (/hub?pay=1), subscription tier
→ C-102 (ASSETS)     : SSO cookies, payment modal (/hub?pay=1), KYC status for asset transfer
→ C-103 (ECOMMERCE)  : SSO cookies, payment modal (/hub?pay=1), cart checkout redirect
→ C-104 (TEC AI)     : SSO session for AI request authentication
→ C-105 (ANALYTICS)  : Hub emits events to tec-analytics-service; analytics feeds Hub metrics dashboard
→ C-106 (LIFE)       : SSO identity for financial record ownership
→ C-107 (CONNECTION) : SSO identity for relationship graph
→ C-108 (EXPLORER)   : SSO for discovery personalization
→ C-109 (NEXUS)      : Hub subscription data feeds Nexus coordination decisions
→ C-110 (SYSTEM)     : Hub governance participation requires authenticated identity
→ C-111 (ALERT)      : Alert system notifies Hub when anomalies detected; Hub surfaces to user
→ C-112 (NX)         : NX security layer wraps Hub routes
→ C-113 (FUNDX)      : SSO identity for pool participation; KYC required
→ C-114 (ESTATE)     : SSO identity for property listings
→ C-115 (DX)         : DX developer environment needs Hub test SSO

Upstream dependencies:
← tec-core-backend (C-47): All backend services Hub proxies through
← @yasser172/tec-auth: Cookie parsing, SSO hooks
← @yasser172/tec-ui: Design system, components
← @yasser172/tec-sdk: BFF SDK for Gateway calls
```

---

*Charter issued by TEC Economic Infrastructure Design Partnership*
*Version 1.0 — 2026-06-15*
