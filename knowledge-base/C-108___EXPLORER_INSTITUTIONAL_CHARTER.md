# C-108 — EXPLORER INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Future Vision]
**Governance State:** [Draft]
**Verification State:** [Unverified]
**Authority Scope:** [Domain]
**Decision Status:** [Exploratory]

---

## 1. MISSION

Make the Pi economy discoverable — surfacing Pi-accepting businesses, economic opportunities, and trusted providers to users based on location, intent, and relationship context.

---

## 2. INSTITUTIONAL ROLE

```
System of Record — Economic Discovery Infrastructure
```

Explorer bridges supply and demand. Without Explorer, users cannot find Pi-accepting merchants outside TEC apps. With Explorer, the entire Pi real-world economy becomes searchable.

---

## 3. ECONOMIC PURPOSE

ربط الطلب بالعرض عبر الاكتشاف الجغرافي والاجتماعي.

- بدون Explorer: Pi لا تقدر تعرف مين يقبلها حولي
- بوجود Explorer: user يفتح التطبيق ويجد merchants على بُعد 500 متر
- اقتصادياً: discovery → transaction → trust signal → relationship → retention

---

## 4. AUTHORITY BOUNDARY

### Owns
- Business listing index (Pi-accepting businesses)
- Location-aware search and ranking
- Category browsing and filtering
- Trust-weighted discovery (using Connection graph)
- Opportunity listings (jobs, services, partnerships)

### Does NOT Own
- Business identity verification (tec-kyc-service:4005)
- Trust scores (Connection owns — C-107)
- Payment processing (tec-payment-service:4002)
- Business content truth (business self-declares — Explorer indexes)

### Interface Points
```
OUTBOUND:
  Search API          → Users (product/merchant discovery)
  Business listings   → Ecommerce (C-103) — cross-discovery
  Opportunity feeds   → Life (C-106) — intent-relevant opportunities

INBOUND:
  Trust signals       → Connection (C-107) — ranking boost for trusted
  Location data       → User device (consent-gated)
  Business profiles   → tec-identity-service (4004)
  KYC verification    → tec-kyc-service (4005) — verified badge
  Category ontology   → SYSTEM (C-110) — what categories are allowed
```

---

## 5. TECHNICAL ARCHITECTURE

```
Planned Stack:
  Next.js 15 App Router + TypeScript strict
  @yasser172/tec-ui (shared design system)
  Search: Elasticsearch or PostgreSQL full-text (pg_trgm + GiST)
    Recommendation: start with PostgreSQL, migrate to ES at 10k+ listings
  Location: PostGIS for geospatial queries
  Caching: Redis for hot search results (TTL: 5min)
  tec-identity-service (4004) — business profile storage
  tec-kyc-service (4005) — verification badges

Search Architecture:
  Query → intent parsing → category + location filter
  → PostgreSQL full-text + PostGIS → result set
  → Connection trust score boost (re-rank top 20)
  → KYC verification badge → final results

Business Listing Schema:
  { businessId, name, category, location[lat,lng], address,
    piAccepted: true, piAppId?, verificationStatus,
    trustScore (from Connection), rating, reviewCount }

Consistency:
  Search index: eventual (updated via event stream)
  Business profile updates: propagate within 15min
  Trust score updates: propagate within 5min
```

---

## 6. SECURITY MODEL

```
Location Privacy:
  Location used for search only — never stored permanently
  Explicit consent before accessing device location
  Fallback: manual city/area search if consent denied

Listing Integrity:
  Business self-declaration requires tec_user authentication
  KYC verification required for 'Verified Business' badge
  Spam/fake listing detection: rate limiting + community reporting
  Anti-competitive manipulation: trust score algorithm audit quarterly

Data Governance:
  Explorer indexes public business information only
  No personal user data stored in Explorer search history
  Search analytics: anonymized aggregate only
```

---

## 7. REVENUE MODEL

**Discovery Commerce (Marketplace)**

| Channel | Mechanism | Target |
|---------|-----------|--------|
| Sponsored Discovery | Paid placement in search results | Primary |
| Business Profiles | Premium profile features + analytics | Secondary |
| Verified Badges | KYC-backed trust certification | Secondary |
| Local Promotion | Area-targeted visibility boost | Phase 2 |

---

## 8. KEY METRICS

```
Search Latency (P95):      < 500ms
Listing Accuracy:          ≥ 95% (verified Pi-accepting)
Trust Score Integration:   % of results with Connection data
Discovery-to-Transaction:  Track click-through → Pi payment rate
Listing Coverage:          Count of Pi-accepting businesses indexed
Fake Listing Rate:         < 1% (flagged / total)
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Pi Real-World Bridge** — connects digital Pi economy to physical businesses
- **Merchant Acquisition Channel** — businesses join TEC to be discoverable
- **Trust Amplifier** — Connection trust scores make Explorer results more relevant
- **Life Integration** — intent-aware discovery (what user needs right now)

---

## 10. FUTURE EVOLUTION

```
Phase 1 (MVP):
  → Manual business listing submission
  → Category search + location filter
  → Verified business badge (KYC-backed)

Phase 2:
  → Trust-weighted results (Connection integration)
  → Intent-aware search (Life integration)
  → Map view with Pi-accepting locations

Phase 3:
  → Economic Discovery Graph
  → Real-time 'open now' + Pi payment availability
  → Cross-Pi-ecosystem discovery (not just TEC businesses)
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P0:**
```
[P0-1] Search Technology Decision
  Before building: benchmark PostgreSQL full-text vs Elasticsearch
  for 1k, 10k, 100k listings. Choose based on 12-month growth target.

[P0-2] Location Consent Architecture
  Define consent flow before building location features.
  Must comply with Pi Browser WebView location permissions.
```

**P1:**
```
[P1-1] Business Listing Schema v1
  Define schema in tec-identity-service before Explorer launches.
  Key field: piAccepted: true (required for Explorer indexing).

[P1-2] Verification Partnership with KYC
  Define workflow: business submits KYC → tec-kyc-service verifies
  → Explorer displays badge. SLA: < 48h for verification.
```

---

## 12. INTEGRATION MAP

```
This charter (C-108) depends on:
  C-107 CONNECTION → trust signals for result ranking
  C-106 LIFE      → user intent for personalized discovery
  C-110 SYSTEM    → category governance + listing policies
  tec-kyc-service (4005) → business verification

Other charters depend on this one for:
  C-103 ECOMMERCE → cross-discovery (product → store discovery)
  C-101 COMMERCE  → merchant visibility channel
  C-104 TEC AI    → opportunity signals for recommendations
```
