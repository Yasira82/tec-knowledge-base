# C-102 — ASSETS INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Current State]
**Governance State:** [Draft]
**Verification State:** [Documentation Verified]
**Authority Scope:** [Application]
**Decision Status:** [Approved]

---

## 1. MISSION

Enable Pi-native creation, discovery, and peer-to-peer trading of digital assets and NFTs within the TEC ecosystem.

---

## 2. INSTITUTIONAL ROLE

```
System of Production — Digital Asset Infrastructure
Ownership Layer of the TEC Economic Runtime
```

---

## 3. ECONOMIC PURPOSE

Turn digital assets into continuous economic activity.

- Without Assets: the Pi economy is momentary (buy/sell only)
- With Assets: wealth accumulates and circulates → economic permanence
- Economically: every asset = a unit of stored Pi value → longer retention cycles

---

## 4. AUTHORITY BOUNDARY

### Owns
- Asset discovery and portfolio display UI
- Asset creation workflow (metadata submission)
- Peer-to-peer trading UI and negotiation flow
- Creator identity attribution (from tec_user cookie)

### Does NOT Own
- Asset ownership records (owned by tec-asset-service:4006)
- Asset ownership transfer (owned by tec-asset-service)
- Payment processing (owned by tec-payment-service:4002)
- Asset authenticity verification (owned by tec-kyc-service:4005)

### Interface Points
```
OUTBOUND:
  /api/bff/assets     → tec-asset-service (read portfolio)
  /api/bff/assets/create → tec-asset-service (mint new asset)
  /hub?pay=1&...      → Mode 1 payment for asset purchase
  Pi.createPayment    → Mode 2 payment (only when !isHubNavigation)

INBOUND:
  tec_user cookie     → user identity (creator attribution)
  /api/bff/payment/approve  → Pi callback
  /api/bff/payment/complete → Pi callback (triggers ownership transfer)
```

---

## 5. TECHNICAL ARCHITECTURE

```
Stack:
  Next.js 15 App Router + TypeScript strict
  @yasser172/tec-ui v1.2.1 (TEC_COLORS, inline styles only)
  @yasser172/tec-auth (getStoredUser, getAccessToken, ssoRedirect)
  @yasser172/tec-sdk (BFF → API Gateway:4000 → asset-service:4006)
  Vitest (unit) + Playwright (e2e)
  Deployment: Vercel (assets.tecosystem.app)

Pi App ID: assets-app-af2fb490e7b03db7
Domain:    https://assets.tecosystem.app

Critical Invariant:
  Asset ownership = ALWAYS from tec-asset-service
  NEVER derive ownership client-side
  NEVER trust client-sent assetId for ownership proof

Ownership Transfer Flow:
  1. Buyer initiates purchase UI
  2. isHubNavigation() check (ADR-007)
  3. Mode 1 or Mode 2 payment
  4. On payment.complete → POST /api/bff/assets/transfer
  5. tec-asset-service updates ownership record
  6. Audit trail created (actor context required)

Creator Attribution:
  Creator = tec_user.piUsername (from SSO cookie)
  NEVER from request body
  Stored permanently in asset metadata
```

---

## 6. SECURITY MODEL

```
Ownership Security:
  tec-asset-service = sole authority for ownership state
  Transfer requires: verified payment completion
  Transfer requires: actor context (who initiated)
  Transfer requires: full audit trail
  Invariant: asset ownership always resolves to ONE principal (P6)

Payment Security:
  ADR-007 guard: isHubNavigation() in every payment handler
  Ownership transfer ONLY after payment.approved.v1 event
  No client-side ownership assumption before service confirms

SSO:
  Cookies from Hub: tec_access_token, tec_csrf, tec_user
  Creator identity from tec_user.piUsername ONLY
  CSRF header on all POST/PUT/DELETE

Infrastructure:
  API_GATEWAY_URL: server-only (never NEXT_PUBLIC_)
  INTERNAL_SECRET: conditional (only when SET)
  503 guard: graceful degradation when tec-asset-service unavailable
```

---

## 7. REVENUE MODEL

**Direct (Asset Economy)**

| Channel | Mechanism | Target |
|---------|-----------|--------|
| Minting Fees | Pi fee per new asset created | Primary |
| Transfer Fees | % of each peer-to-peer trade | Primary |
| Verification Services | Premium authenticity badges | Secondary |
| Creator Subscriptions | Enhanced portfolio features | Phase 2 |

---

## 8. KEY METRICS

```
Asset Service Availability:  ≥ 99.5% (graceful 503 on failure)
Ownership Transfer Success:  ≥ 98% (after payment completion)
Payment Success Rate:        ≥ 95% (Mode 1 + Mode 2)
Ownership Audit Coverage:    100% (every transfer has actor context)
Creator Attribution Accuracy: 100% (always from tec_user cookie)
Test Coverage:               ≥ 60% (Phase 0 gate — PENDING)
Portfolio Load Time (P95):   < 3s on Pi Browser
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Wealth Accumulation Layer** — converts single transactions into stored value
- **Creator Economy** — Pi-native creator attribution and reputation
- **NFT Infrastructure** — digital provenance on Pi Network
- **Economic Permanence** — assets persist longer than single purchases

---

## 10. FUTURE EVOLUTION

```
Phase 1 (Post-Mainnet):
  → Test coverage ≥ 60% (Vitest)
  → Portfolio analytics (asset value over time)
  → Creator reputation score integration

Phase 2:
  → Fractionalized asset ownership (multiple owners)
  → Asset staking / escrow patterns
  → Secondary marketplace with price discovery

Phase 3:
  → Pi Digital Asset Layer (standard for all Pi apps)
  → Cross-ecosystem asset portability
  → Asset-backed lending (requires FundX integration)
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P0:**
```
[P0-1] Ownership Transfer Atomicity
  Payment completion and ownership transfer must be atomic.
  If tec-asset-service fails after payment completes →
  orphan recovery path required (similar to payment orphan cron).
  Current status: UNVERIFIED — needs audit.
```

**P1:**
```
[P1-1] Test Coverage ≥ 60%
  Priority:
  - Asset service 503 graceful degradation
  - Ownership transfer: success, service failure, duplicate transfer
  - Payment handler: ADR-007 Mode 1 vs Mode 2
  - Creator attribution: verify piUsername from cookie

[P1-2] PI_SANDBOX=false Verification
  Confirm on Vercel for Pi App ID assets-app-af2fb490e7b03db7.
```

**P2:**
```
[P2-1] Asset Search
  Current: portfolio only. Need: marketplace search across all assets.

[P2-2] Creator Reputation
  Connect to tec-identity-service (4004) for creator score.
```

---

## 12. INTEGRATION MAP

```
This charter (C-102) depends on:
  C-100 HUB       → SSO cookies + /hub?pay=1 routing
  C-101 COMMERCE  → follows commerce payment patterns
  C-113 FUNDX     → future: asset-backed lending

Other charters depend on this one for:
  C-107 CONNECTION → creator reputation feeds relationship graph
  C-105 ANALYTICS  → asset trading volume metrics
```
