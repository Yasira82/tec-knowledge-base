# C-108 — EXPLORER INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** Future Vision
**Governance State:** Draft
**Verification State:** Unverified
**Authority Scope:** Domain
**Decision Status:** Exploratory

---

## 1. MISSION

Explorer is the discovery infrastructure of the TEC ecosystem — the system that maps Pi-accepting businesses, services, and assets to physical and digital locations, enabling users to find and transact with the Pi economy around them.

---

## 2. INSTITUTIONAL ROLE

**System of Infrastructure (Discovery Layer)** — The Pi economy map.

```
Settlement → Record → Reasoning → Access → Construction → PRODUCTION → Economic Activity → Settlement
                                                                 ↑
                                                           EXPLORER
                                                      (Discovery Infrastructure)
```

Explorer is infrastructure that enables production. It doesn't produce goods or services — it makes the production layer discoverable. Discovery converts the Pi economy from an abstract network into a tangible, navigable marketplace.

---

## 3. ECONOMIC PURPOSE

Explorer solves the Pi economy's discovery problem:

- **Business Listing**: Pi-accepting businesses register their location, categories, payment terms
- **Location Search**: "Find Pi-accepting restaurants near me" — local Pi economy discovery
- **Category Browse**: Discover Pi merchants by type (food, services, digital, real estate)
- **Asset Discovery**: Find digital assets by location association (local art, location-tagged NFTs)
- **Estate Integration**: Find Pi-accepting property listings by location (C-114)
- **Verification Badge**: Trust signal for verified Pi-accepting businesses

Without Explorer, the Pi economy is invisible to physical-world users. Explorer bridges the digital Pi wallet with the physical world, making Pi spendable on goods and services people encounter in daily life.

---

## 4. AUTHORITY BOUNDARY

### Owns
- Business listing directory (Pi-accepting businesses)
- Location-based search and filtering
- Business verification workflow (basic — deep KYC is tec-kyc-service)
- Map UI and geospatial display
- Category taxonomy (what types of businesses are listed)
- Business review and rating aggregation (Explorer-specific ratings)

### Does NOT Own
- Pi payments (Hub payment modal handles all payments)
- Business identity verification (tec-kyc-service owns — Port 4005)
- Asset ownership records (tec-asset-service)
- Social connections (Connection C-107 owns trust graph)
- Merchant product catalog (Commerce C-101 owns)

### Interface Points
```
Exposes to ecosystem:
  - Business search API: GET /api/explorer/search?lat=&lng=&category=&radius=
  - Business profile: GET /api/explorer/business/{id}
  - Category index: GET /api/explorer/categories
  - Verification status: GET /api/explorer/verify/{businessId}

Consumed from:
  - Hub (C-100): SSO identity for business registration
  - tec-kyc-service (4005): business verification status
  - tec-storage-service (4010): business photos and media
  - Commerce (C-101): merchant data for businesses with TEC Commerce presence
  - Assets (C-102): location-tagged digital assets
  - Estate (C-114): property listings integration
  - Connection (C-107): trust-weighted business recommendations from network
```

---

## 5. TECHNICAL ARCHITECTURE

### Planned Stack
- Next.js 15 App Router + TypeScript strict
- New backend service: `tec-explorer-service` (Port 4014 — to be provisioned)
- PostgreSQL + PostGIS extension: geospatial queries for location search
- Redis: search result caching (TTL: 5min for location queries)
- External: Map tile provider (MapLibre GL / OpenStreetMap — no Google Maps lock-in)
- Deployment: Vercel (explorer.tecosystem.app)

### Data Architecture
```typescript
interface Business {
  id: string
  ownerId: string          // Pi username (from tec_user cookie)
  name: string
  category: BusinessCategory
  description: string
  location: {
    lat: number
    lng: number
    address: string
    city: string
    country: string
  }
  piAccepting: boolean
  paymentMethods: string[]  // ['pi_direct', 'hub_modal']
  verificationStatus: 'unverified' | 'basic' | 'kyc_verified'
  commerceMerchantId?: string  // if linked to Commerce (C-101)
  createdAt: string
  updatedAt: string
}

interface BusinessReview {
  id: string
  businessId: string
  reviewerId: string       // Pi username
  rating: number           // 1-5
  comment: string
  piTransactionId?: string // proof of transaction (verified review)
  createdAt: string
}
```

### Location Search Architecture
```sql
-- PostGIS geospatial query example
SELECT b.*, 
  ST_Distance(b.location, ST_MakePoint($lng, $lat)::geography) AS distance_meters
FROM businesses b
WHERE b.pi_accepting = true
  AND b.category = $category
  AND ST_DWithin(b.location, ST_MakePoint($lng, $lat)::geography, $radius_meters)
ORDER BY distance_meters
LIMIT 50;
```

### Verified Reviews (Proof-of-Transaction)
```
Verified review = review attached to a real Pi payment transaction ID
Process:
  1. User completes Pi payment at business
  2. payment_id returned to user
  3. User submits review with payment_id
  4. Explorer verifies payment_id exists in tec-payment-service
  5. Review marked 'verified' (trust signal)

Verified reviews weighted 3x vs unverified in rating aggregation.
```

---

## 6. SECURITY MODEL

### Authentication
- Browse: public (no auth required for discovery)
- Business registration: authenticated session required
- Review submission: authenticated + optional payment verification
- Business management: owner identity from tec_user cookie (never URL param)

### Threat Vectors
| Threat | Mitigation |
|--------|------------|
| Fake business listings | Basic verification flow + KYC for badge |
| Review manipulation | Proof-of-transaction reviews weighted higher |
| Location data spoofing | IP geolocation cross-check on registration |
| Business ID spoofing | Owner always from tec_user cookie |
| Scraping business database | Rate limiting on search API |

---

## 7. REVENUE MODEL

### Direct
1. **Featured Listing**: Businesses pay Pi to appear prominently in search results
2. **Verified Business Badge**: Pi fee for KYC verification (trust signal)
3. **PRO Business Profile**: Enhanced listing with photos, products, analytics
4. **Category Sponsorship**: Merchants pay for category page prominence

### Indirect
- Discovery → more Pi spending in physical world → higher Pi velocity
- Verified businesses → trust in Pi economy → more users willing to use Pi
- Explorer data → TEC AI (C-104) for location-aware recommendations

---

## 8. KEY METRICS

### SLOs
| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| Explorer availability | ≥ 99.0% | < 98.0% |
| Search response time | < 500ms P95 | > 2s P95 |
| Location accuracy | < 100m error for listed businesses | > 1km error |

### KPIs
| Metric | Target | Frequency |
|--------|--------|----------|
| Listed Pi businesses | Growth trend | Monthly |
| Search-to-visit conversion | ≥ 10% | Monthly |
| Verified reviews per business | ≥ 3 average | Monthly |
| Discovery → payment attribution | Tracked | Weekly |

---

## 9. ECOSYSTEM CONTRIBUTION

1. **Pi Economy Visibility**: Makes the Pi economy visible in physical space — critical for mainstream adoption
2. **Merchant Acquisition**: Local businesses joining Explorer are potential Commerce merchants
3. **Pi Velocity**: Location-based discovery → more physical Pi spending → higher token velocity
4. **Trust Infrastructure**: Verified business listings create a Pi economy trust layer
5. **Estate Bridge**: Property listings visible in Explorer map — real estate in the Pi economy

---

## 10. FUTURE EVOLUTION

### Phase 1 (MVP — Month 5–6 post-Mainnet)
- Business registration and listing
- Location-based search (radius + category)
- Basic map display (OpenStreetMap)
- Unverified reviews and ratings

### Phase 2 (Month 7–8)
- KYC-verified business badges
- Proof-of-transaction verified reviews
- Commerce merchant integration (linked storefronts)
- Connection trust-weighted recommendations

### Phase 3 (Month 9–12)
- Estate property listings on map
- AR overlay (Pi businesses visible in phone camera view)
- TEC AI recommendations (nearby businesses your connections visited)
- Pi tourism routes (curated local Pi-accepting experience guides)

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Critical (Before Explorer MVP)**
1. **Provision tec-explorer-service** (Port 4014) on Railway
2. **PostGIS setup**: PostgreSQL instance needs PostGIS extension for geospatial queries
3. **Map tile decision**: Choose map provider (OpenStreetMap tile server or hosted) — ADR required

**P1 — High Priority**
4. **Business registration BFF**: `/api/bff/explorer/business` with owner from tec_user cookie
5. **Payment verification integration**: `/api/bff/explorer/reviews` verifies payment_id against tec-payment-service
6. **Location privacy**: Opt-in for precise location; default to city-level only

**P2 — Medium Priority**
7. **Commerce merchant sync**: Auto-populate Explorer listing when merchant registers in Commerce
8. **Analytics integration**: Discovery → purchase attribution tracked in tec-analytics-service
9. **CDN for map tiles**: Cache map tiles at Vercel edge for low-latency global access

---

## 12. INTEGRATION MAP

```
C-108 (EXPLORER) depends on:
← C-100 (HUB)        : SSO identity for business registration
← C-101 (COMMERCE)   : Merchant data for linked storefronts
← C-102 (ASSETS)     : Location-tagged digital assets
← C-107 (CONNECTION) : Trust-weighted recommendations from network
← C-114 (ESTATE)     : Property listings on map
← tec-core-backend   : tec-kyc-service (4005), tec-storage-service (4010)

C-108 (EXPLORER) contributes to:
→ C-104 (TEC AI)     : Location and category data for recommendations
→ C-105 (ANALYTICS)  : Discovery events (search, view, click-to-pay)
→ C-114 (ESTATE)     : Map-based property discovery
```

---

*Charter issued by TEC Economic Infrastructure Design Partnership*
*Version 1.0 — 2026-06-15*
