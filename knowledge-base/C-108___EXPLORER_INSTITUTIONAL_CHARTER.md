# C-108 — EXPLORER INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Future Vision]
**Governance State:** [Draft]
**Verification State:** [Assumed]
**Authority Scope:** [Domain]
**Decision Status:** [Exploratory]

---
## Deployment Status (2026-07-31)

> **Truth State:** `[Current State]` for the deployed app + live payment · `[Future Vision]` for the full runtime below
> **Verification:** `[Runtime Verified]` — deployed on Mainnet, real Pi payment live (SSoT: `architecture/app-fleet.yaml` → `live-verified`)

**Explorer is deployed on Mainnet** with Hub SSO and dual-mode (ADR-007) Pi payment live:
- **Domain:** `explorer.tecosystem.app` · **Pi App ID:** `explorer-kxfp` · **APP_SOURCE:** `explorer`
- **Payment:** real Pi subscription — Mode 1 (Hub) + Mode 2 (standalone); `PI_API_KEY_EXPLORER` set on payment-service.
- **Hub SSO:** enabled (in `/api/auth/sso` ALLOWED_TARGETS + Hub domain registry).
- **Growth:** referral loop wired (C-133).

**Still `[Future Vision]`:** the advanced runtime described below (V2+ / the charter's later phases) — vision, not yet built.

---


## Verification Source — CORRECTED (2026-09-02)

> Truth State: **[Current State]** · Verification: **[Code Verified]** — tec-core-backend
> **#264** (in review). Session 50.

**The "Verified business" badge comes from ZONE, not KYC.** §4 of this charter and the
app's CLAUDE.md both said `tec-kyc-service`; **C-120 §3 lists `Merchants → Pi-accepting
businesses` among what Zone owns** — word for word what this index holds. Two charters
disagreed and the code followed the wrong one.

The distinction is not administrative. **KYC verifies a PERSON** (an ID document and a
selfie) and cannot answer whether a shop exists — which is not a shortcoming of KYC; it is
simply not its question. Zone reaches a verdict through append-only evidence and a named
human reviewer, the only process that can back a claim a customer reads before walking
somewhere.

It was also dead: `kyc.verified` carries `{ userId, level }` — a UUID — while the consumer
resolves a Pi username, so `applyVerification` was **never called**. No error, no failing
health check. The zone events carry `piUsername` directly, so the correct source is also
the simpler one.

**Explorer consumes `zone.badge.issued.v1` / `.revoked.v1` for `MERCHANT` entities only.**
A verified BUILDER is not a verified shop.

### Trust is a ladder, not a boolean

Every real merchant was labelled *Unverified*, because the only other value required a
review not reachable end to end. A badge with one attainable value is a warning printed on
everything.

| | Means | Evidence |
|---|---|---|
| **L1** Self-listed | Nobody stands behind it | No owner |
| **L2** Pi account | A real person with a Mainnet wallet listed this | `owner`, written server-side from a verified session token |
| **L3** Verified business | A reviewer checked the business | Zone's verdict |

**L2 is not Explorer minting verification (§4)** — it reports a fact the row already holds.
Derived, never stored: no migration, and no trust column that can drift from what it
summarises.

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
| Verified Badges | **Zone**-reviewed business certification (C-120 §3) — earned, never sold | Secondary |
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
  → Verified business badge (Zone-reviewed — C-120 §3, NOT KYC)

Phase 2:
  → Trust-weighted results (Connection integration)   ✅ SHIPPED — see below
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
  C-120 ZONE      → business (MERCHANT) verification — NOT tec-kyc-service:
                    KYC verifies a PERSON, a listing is an ENTITY

Other charters depend on this one for:
  C-103 ECOMMERCE → cross-discovery (product → store discovery)
  C-101 COMMERCE  → merchant visibility channel
  C-104 TEC AI    → opportunity signals for recommendations
```

---

## Implementation Status

**Truth State:** [Current State] · **Verification:** [Code Verified] · **Governance:** [ADR Approved]

The discovery index is live in the `explorer` module of `tec-identity-service`
(`@Controller('identity/explorer')`), reached only through the gateway. Search runs in
the database with an Arabic normalizer applied to the stored text at write time and to
the query at read time; owners self-list, edit and delete (owner from the session JWT,
never the body — P6); reviews, reports, photos and coordinates all exist; Explorer Pro
drives `featured`, re-synced to the owner's live commerce subscription.

### §10 Phase 2 — Trust-weighted results: SHIPPED (tec-core-backend #265)

Connection owns the Trust Graph (C-107) and announces a seller's DISTINCT-BUYER count
on **`connection.trust.updated.v1`** after its own transaction commits. Explorer stores
it and ranks with it. Explorer does **not** read `order.paid.v1`: deriving the number
here would re-implement Connection's dedupe and idempotency ledger (C-108 §4) *and*
race it — two consumer groups on one stream, with Explorer able to hold a count one
order stale for ever.

The result order, and the rule it encodes — **everything earned outranks everything
bought**:

```
verification  Zone reviewed the business (C-120 §3)   ← earned
trust_tier    distinct people who actually paid       ← earned  (C-107 → §10)
featured      Explorer Pro                            ← BOUGHT  (§7)
popularity    Analytics relevance                      (C-105)
pi_accepted · name
```

Trust ranks **above** `featured`. Before this, a paid listing outranked a shop fifty
real customers had paid — §7 says visibility is purchasable and trust is not, and that
held for the Zone badge but stopped holding one line lower.

Bucketed into tiers (0 · 1–4 · 5+) rather than ordered by the raw count: a count would
make the directory a leaderboard where one order outranks a shop with none, and would
make the paid slot meaningless. Bucketing is Explorer's **ranking** policy (which
Explorer owns); the number itself stays Connection's. Malformed counts fail closed to
tier 0 — no evidence must never outrank real evidence.

### Honest gaps

- `[Code Verified]`, **not** `[Runtime Verified]`: the chain fires only with `REDIS_URL`
  set on `tec-identity-service` and both consumer groups running. The new stream is
  registered in the consumer-liveness EXPECTED map, so a dropped group is visible.
- Listings created before the trust seam carry no `owner_user_id` and rank at tier 0
  until their owner next opens their own listings, which backfills it.
- §10 Phase 2's other two items — intent-aware search (Life) and the map view — the map
  is shipped in the app; Life intent is not started.
