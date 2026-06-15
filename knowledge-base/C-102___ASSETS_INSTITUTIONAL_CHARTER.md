# C-102 — ASSETS INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** Current State
**Governance State:** Draft
**Verification State:** Documentation Verified + Code Verified
**Authority Scope:** Application
**Decision Status:** Approved

---

## 1. MISSION

Assets is the digital ownership layer of the TEC ecosystem — the system through which Pi-native digital assets (NFTs, creator tokens, digital goods) are created, owned, traded, and transferred between identities.

---

## 2. INSTITUTIONAL ROLE

**System of Production (Ownership Layer)** — Digital asset creation and peer-to-peer ownership transfer.

```
Settlement → Record → Reasoning → Access → Construction → PRODUCTION → Economic Activity → Settlement
                                                               ↑
                                                            ASSETS
                                                      (Ownership Sub-layer)
```

If Commerce handles goods and services, Assets handles ownership claims — NFTs, digital certificates, creator reputation tokens, and any Pi-native asset whose primary value is the proof of ownership itself.

---

## 3. ECONOMIC PURPOSE

Assets exists to create a Pi-native ownership economy:

- **Asset Creation**: Pi users mint digital assets tied to their Pi identity
- **Ownership Proof**: Every asset has a verifiable owner (one principal — Invariant 3)
- **Peer-to-Peer Trading**: Asset transfers require Pi payment approval, creating a trading market
- **Creator Economy**: Artists, developers, and creators can monetize digital work in Pi
- **Portfolio Management**: Users see their digital asset holdings, value, and history

Without Assets, Pi tokens can be transferred but cannot be exchanged for *ownership claims* — Assets creates the institutional layer for Pi-denominated property rights.

---

## 4. AUTHORITY BOUNDARY

### Owns
- Asset portfolio UI and display
- Asset creation workflow (UI layer only — service layer owns minting)
- Creator profile design and attribution
- NFT display and trading flow UI
- Asset discovery and search UI
- Pi App ID: `assets-app-af2fb490e7b03db7`

### Does NOT Own
- Asset ownership records (tec-asset-service owns — Port 4006)
- Asset ownership transitions (tec-asset-service is the authority — never derive client-side)
- Payment creation for asset transfers (tec-payment-service — Port 4002)
- Creator identity verification (tec-auth-service + tec-kyc-service)
- NFT metadata storage (tec-storage-service — Port 4010)

### Interface Points
```
Exposes to ecosystem:
  - Public asset pages (browsable by non-authenticated users)
  - Creator profile pages (public reputation layer)
  - Asset trading flow (authenticated users)

Consumed from:
  - Hub (C-100): SSO cookies, payment modal (/hub?pay=1), KYC status
  - tec-asset-service (4006): asset records, ownership, metadata
  - tec-payment-service (4002): payment for asset transfers
  - tec-storage-service (4010): asset media files
  - @yasser172/tec-auth: getStoredUser(), ssoRedirect()
  - @yasser172/tec-ui: TEC_COLORS, GlobalNav
  - @yasser172/tec-sdk: BFF Gateway proxy
```

---

## 5. TECHNICAL ARCHITECTURE

### Stack
- Next.js 15 App Router + TypeScript strict
- Deployment: Vercel (assets.tecosystem.app)
- Vitest (unit) + Playwright (e2e)
- @yasser172/tec-ui, @yasser172/tec-auth, @yasser172/tec-sdk

### Critical Pattern — Asset Ownership Authority
```typescript
// CORRECT: Ownership always from tec-asset-service
const asset = await TecSdk.assets.getAsset(assetId) // server-side BFF
const isOwner = asset.ownerId === user.userId

// FORBIDDEN: Never derive ownership client-side
// const isOwner = localAssetData.owner === username // BANNED
```

### ADR-007 — Pi Foreign Session Guard
```typescript
const isHubNavigation = () =>
  document.referrer.toLowerCase().includes('hub.tecosystem.app')

if (isHubNavigation() || !(window as any).Pi || !piReady) {
  redirectToHubPayment(asset) // Mode 1: Hub modal redirect
  return
}
// Mode 2: Direct Pi Browser payment for asset transfer
```

### Asset Transfer Lifecycle
```
Buyer clicks 'Buy Asset'
  → isHubNavigation() check (ADR-007)
  → POST /api/bff/asset-transfer/initiate → tec-asset-service (4006)
    → tec-payment-service (4002) creates payment
    → Pi Network payment approval
    → POST /api/bff/payment/complete
      → tec-asset-service updates ownership
      → Ownership transfer: seller → buyer (atomic)
```

### KYC Gate for Asset Transfers
```typescript
// High-value asset transfers require KYC
const user = getStoredUser()
if (asset.price > KYC_THRESHOLD && !user.kycVerified) {
  redirectToHubKyc() // /hub/kyc
  return
}
```

### BFF Routes (Required — currently needs specification)
```
GET  /api/bff/assets           → tec-asset-service: portfolio listing
GET  /api/bff/assets/[id]      → tec-asset-service: asset detail
POST /api/bff/assets           → tec-asset-service: create/mint asset
POST /api/bff/asset-transfer   → tec-asset-service: initiate transfer
POST /api/bff/payment/approve  → tec-payment-service: Pi callback
POST /api/bff/payment/complete → tec-payment-service: Pi callback + ownership update
```

### Asset Ownership Invariant
```
Invariant: Every asset has exactly ONE owner at any point in time.
Transfer = atomic swap: payment completion triggers ownership record update.
Orphan detection: if payment completes but ownership not updated → ALERT to tec-analytics-service
```

---

## 6. SECURITY MODEL

### Authentication
- SSO via Hub cookies: `tec_access_token`, `tec_csrf`, `tec_user`
- Missing session on asset action → deny, redirect to Hub login (P6 Fail Closed)
- CSRF header required on all POST/PUT/DELETE

### Authorization
- Asset owner = identity from `tec_user` cookie (Pi username bound to tec-asset-service record)
- KYC status from `tec_user` cookie gates high-value transfers
- Ownership transitions only through tec-asset-service — never from client assertions

### Threat Vectors & Mitigations
| Threat | Mitigation |
|--------|------------|
| Pi foreign session (ADR-007) | isHubNavigation() in every payment handler |
| Ownership derived client-side | tec-asset-service is sole authority |
| Asset transfer without payment | Ownership update atomic with payment.completed event |
| CSRF on transfer mutations | x-csrf-token header required |
| KYC bypass on high-value transfer | Server-side KYC check from tec_user cookie |
| Orphan asset (payment done, ownership not updated) | Alert + reconciliation cron |

---

## 7. REVENUE MODEL

### Direct
1. **Transfer Commission**: Platform takes % of every Pi asset transfer (PRIMARY)
2. **Minting Fee**: Small Pi fee to mint a new asset (creates demand for Pi utility)
3. **Creator PRO**: Premium creator features — analytics, custom storefronts, batch minting

### Indirect
- Creator economy drives user acquisition (creators bring their audience)
- Asset portfolio value → user retention (users with assets stay in the ecosystem)
- Asset trading volume → platform Pi circulation → higher ecosystem economic activity

### Priority Order
1. Transfer commission (immediate, volume-driven)
2. Minting fees (per creation event)
3. Creator PRO tier (recurring, Phase 2)

---

## 8. KEY METRICS

### SLOs
| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| Assets app availability | ≥ 99.5% | < 99.0% |
| Asset transfer success rate | ≥ 97% | < 95% |
| Ownership update latency (post-payment) | < 3s P95 | > 10s P95 |
| Asset portfolio load time | < 1s P95 | > 3s P95 |
| Orphan asset detection | < 1 per day | > 5 per day |

### KPIs
| Metric | Target | Frequency |
|--------|--------|----------|
| Active creators | Baseline + 10% MoM | Monthly |
| Assets minted per day | Baseline + 5% WoW | Weekly |
| Transfer volume (Pi) | Increasing trend | Weekly |
| Test coverage | ≥ 60% (Phase 0 gate) | Per PR |
| ADR-007 guard in all payment handlers | 100% | Per PR |

---

## 9. ECOSYSTEM CONTRIBUTION

1. **Ownership Economy**: Creates the infrastructure for Pi-native property rights — assets, certificates, digital goods
2. **Creator Retention**: Creators who mint assets have economic stake in the ecosystem
3. **Pi Velocity**: Asset trading increases Pi token velocity — more economic activity per token
4. **Identity Enrichment**: Creator reputation data enriches the TEC identity layer (C-107 Connection)
5. **NFT Pioneer**: First Pi-native NFT infrastructure — establishes TEC as the ownership layer for Pi economy

---

## 10. FUTURE EVOLUTION

### Phase 1 (Post-Mainnet, Month 1–2)
- Creator dashboard: earnings by asset, transfer history, royalty tracking
- Asset categories: art, music, software, certificates, game items
- Public marketplace: discoverable asset listings with search and filters
- Royalty system: creator earns % on every secondary transfer

### Phase 2 (Month 3–4)
- Peer-to-peer offers: buyers propose price, seller accepts/counters
- Asset bundles: multiple assets in one Pi payment
- Creator reputation score: based on transfer volume, ratings, history
- Integration with Explorer (C-108) for asset discovery by location

### Phase 3 (Month 5–8)
- Fractional ownership: multiple owners share a single high-value asset
- Asset-backed loans via FundX (C-113): assets as collateral
- Cross-chain bridges: Pi assets ↔ other Pi Network dApps
- Estate integration (C-114): digital certificates for physical property

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Critical (Pre-Mainnet)**
1. **PI_SANDBOX=false**: Verify production environment
2. **ADR-007 audit**: Grep all payment handler files for `isHubNavigation()` — zero exceptions
3. **Ownership never client-side**: Audit all asset ownership checks — must go through tec-asset-service

**P1 — High Priority (Phase 0 completion)**
4. **Test coverage ≥ 60%**: Priority areas:
   - Asset ownership auth guard (missing cookie, valid owner, wrong user)
   - Payment handler ADR-007 (isHubNavigation true/false, piReady false)
   - Asset transfer flow (success, payment mismatch, orphan detection)
   - BFF routes (auth fail, gateway error)
5. **Orphan detection**: If payment.completed but asset ownership not updated within 30s → alert + manual reconciliation path
6. **@yasser172/tec-ui v1.2.0**: Upgrade to shared PaymentModal when published

**P2 — Medium Priority (Phase 1)**
7. **Asset search/discovery API**: Currently no discovery endpoint — BFF needed
8. **Royalty system**: Track creator % on secondary transfers — requires tec-asset-service support
9. **Media optimization**: Asset images via tec-storage-service (4010) — CDN + lazy loading
10. **Creator analytics**: Connect to tec-analytics-service (4007) for earnings dashboard

---

## 12. INTEGRATION MAP

```
C-102 (ASSETS) depends on:
← C-100 (HUB)           : SSO identity, payment modal, KYC status
← tec-core-backend      : tec-asset-service (4006), tec-payment-service (4002), tec-storage-service (4010)
← @yasser172/tec-auth   : getStoredUser(), identity from cookie
← @yasser172/tec-ui     : TEC_COLORS, components
← @yasser172/tec-sdk    : BFF Gateway proxy

C-102 (ASSETS) contributes to:
→ C-105 (ANALYTICS)    : Asset transfer events → platform analytics
→ C-107 (CONNECTION)   : Creator reputation → relationship graph
→ C-108 (EXPLORER)     : Asset discovery by location/category
→ C-113 (FUNDX)        : Assets as collateral for lending pools
→ C-114 (ESTATE)       : Digital certificates for property

Follows patterns from:
→ C-101 (COMMERCE)     : Commerce is reference implementation — Assets adopts proven patterns
```

---

*Charter issued by TEC Economic Infrastructure Design Partnership*
*Version 1.0 — 2026-06-15*
