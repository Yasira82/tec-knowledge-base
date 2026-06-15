# C-114 — ESTATE INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Future Vision]
**Governance State:** [Draft]
**Verification State:** [Unverified]
**Authority Scope:** [Application]
**Decision Status:** [Exploratory]

---

## 1. MISSION

Connect real estate opportunities — property listings, gallery exploration, and transaction facilitation — with Pi Network's digital economy, enabling property discovery and coordination through the TEC ecosystem.

---

## 2. INSTITUTIONAL ROLE

```
System of Production — Real Estate Coordination Infrastructure
```

---

## 3. ECONOMIC PURPOSE

ربط العقارات بالاقتصاد الرقمي.

- بدون Estate: العقار وال Pi اقتصادين منفصلان
- بوجود Estate: Pi users يجدون عقارات، يدفعون خدمات بـ Pi
- اقتصادياً: أكبر عملية Pi ممكنة (عقارات) = Pi utility peak proof

---

## 4. AUTHORITY BOUNDARY

### Owns
- Property listing UI (search, filter, gallery)
- Property detail pages + virtual tour coordination
- Inquiry and contact flow between buyer and agent
- Pi-payment coordination for services (not property itself)

### Does NOT Own
- Legal property title transfer (external legal process)
- Property valuation truth (external market data)
- Payment processing (tec-payment-service for Pi-denominated services)
- Identity verification of agents/buyers (tec-kyc-service)

### Key Distinction
```
Estate does NOT process full property purchase in Pi (legal complexity)
Estate DOES process Pi-denominated services:
  - Listing fees (agents pay Pi to list)
  - Consultation fees (Pi for property advice)
  - Viewing fees (Pi for premium listings)
  - Reservation deposits (Pi-denominated, refundable)
```

### Interface Points
```
OUTBOUND:
  /hub?pay=1&...        → Pi service payment routing
  Property signals      → Explorer (C-108) — property discovery
  Capital signals       → FundX (C-113) — property investment pools

INBOUND:
  tec_user cookie       → buyer/agent identity
  KYC verification      → tec-kyc-service (for agents)
  Location data         → user consent (property search by area)
  payment.completed.v1  → listing fee confirmation
```

---

## 5. TECHNICAL ARCHITECTURE

```
Planned Stack:
  Next.js 15 App Router + TypeScript strict
  @yasser172/tec-ui (shared design system)
  Property Search: PostgreSQL + PostGIS (location-aware)
  Image Gallery: Cloudflare R2 (via tec-storage-service:4010)
  Maps Integration: Mapbox or Google Maps (property location display)
  tec-kyc-service (4005) — agent verification
  tec-payment-service (4002) — Pi service payments

Property Listing Schema:
  { propertyId, agentId, title, description, type, status,
    location[lat,lng,address,city,country],
    price[piEquivalent, currency, priceType],
    features[], images[], virtualTourUrl?,
    piServices[listingFee, consultationFee, viewingFee],
    verificationStatus, createdAt }

Search Architecture:
  Location-based: PostGIS radius search
  Price range: Pi equivalent (with disclaimer: indicative only)
  Property type: residential, commercial, land, investment
  Trust ranking: agents with more completed Pi transactions rank higher

Content Delivery:
  Images: Cloudflare R2 via tec-storage-service
  Virtual tours: external embed (Matterport / YouTube 360)
  Map tiles: cached to avoid Pi Browser network issues
```

---

## 6. SECURITY MODEL

```
Agent Verification:
  KYC required for listing agents (not for property browsers)
  Agent identity from tec_user cookie (never from listing body)
  Verified agent badge: tec-kyc-service confirmation

Payment Security (for Pi services only):
  ADR-007 guard: isHubNavigation() before all Pi service payments
  Pi service payments: same pattern as Commerce (reference impl)
  No Pi payment for full property value — legal liability too high

Content Security:
  Property images: served through tec-storage-service (not direct R2)
  No personal contact info in public listings (inquiry form only)
  Agent contact: mediated through TEC messaging (no direct phone/email)
```

---

## 7. REVENUE MODEL

**Marketplace (Service Fees)**

| Channel | Mechanism | Notes |
|---------|-----------|-------|
| Listing Fees | Agents pay Pi to list properties | Primary |
| Premium Visibility | Paid placement in search results | Secondary |
| Consultation Pi | Buyers pay Pi for agent consultation | Platform fee |
| Brokerage Coordination | Pi fee for successful viewing → deal connection | Phase 2 |

---

## 8. KEY METRICS

```
Agent KYC Completion:    ≥ 95% (required before listing)
Listing Quality Score:   Track (images, description completeness)
Inquiry-to-Contact Rate: Track conversion from listing to inquiry
Pi Service Payment Success: ≥ 95% (same SLO as Commerce)
Search Latency (P95):    < 1s (PostGIS + Redis cache)
Image Load Time (P95):   < 3s on Pi Browser (Cloudflare R2)
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Largest Pi Transaction Size** — property-related Pi payments are largest on platform
- **Explorer Integration** — property listings in Explorer (location-aware discovery)
- **FundX Synergy** — property investment pools (co-invest in real estate)
- **Pi Economy Proof** — real estate services in Pi = strongest utility demonstration

---

## 10. FUTURE EVOLUTION

```
Phase 1 (MVP):
  → Property listing directory (search + gallery)
  → Pi-denominated listing fees
  → Inquiry form (no full transaction)

Phase 2:
  → Pi consultation fees + viewing fees
  → Property investment coordination with FundX
  → Agent reputation system (from Connection graph)

Phase 3:
  → Pi Property Infrastructure
  → Fractional property investment (FundX integration)
  → Cross-border Pi property search
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P0:**
```
[P0-1] Legal Boundary Definition
  Must explicitly define before launch:
  - Estate does NOT handle property title transfer in Pi
  - Estate facilitates services AROUND property (listing, consultation)
  - This distinction must be in Terms of Service + Charter
  - Legal review required before any Pi service payment goes live.

[P0-2] Image Storage Architecture
  Property listings require many high-resolution images.
  Cloudflare R2 via tec-storage-service (4010) is the correct path.
  Implement upload + CDN delivery before launch.
```

**P1:**
```
[P1-1] Location Search
  PostGIS setup on estate-specific PostgreSQL instance.
  Radius search: 'show properties within X km of location'.

[P1-2] Agent Verification Flow
  KYC workflow specifically for real estate agents.
  Documents: business license, agent certification, ID verification.
```

---

## 12. INTEGRATION MAP

```
This charter (C-114) depends on:
  C-100 HUB       → SSO + payment modal routing
  C-108 EXPLORER  → property discovery surface
  C-113 FUNDX     → property investment pool coordination
  tec-kyc-service (4005) → agent verification
  tec-storage-service (4010) → property image CDN
  tec-payment-service (4002) → Pi service payments

Other charters depend on this one for:
  C-105 ANALYTICS → property market signals
  C-108 EXPLORER  → property listings in discovery feed
  C-113 FUNDX     → investment-grade property signals
```
