# C-107 — CONNECTION INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Future Vision]
**Governance State:** [Draft]
**Verification State:** [Unverified]
**Authority Scope:** [Domain]
**Decision Status:** [Exploratory]

---

## 1. MISSION

Model economic relationships between TEC users — trust signals, social graph, business graph, and collaboration context — to enable network-effect-driven economic discovery and coordination.

---

## 2. INSTITUTIONAL ROLE

```
System of Record — Economic Relationship Infrastructure
```

Connection is the **relationship graph** of the TEC economic runtime. Without Connection, TEC AI cannot understand social context, Explorer cannot surface trusted businesses, and the platform lacks network effects.

---

## 3. ECONOMIC PURPOSE

بناء Trust Graph اقتصادي يضاعف قيمة كل مستخدم.

- بدون Connection: كل مستخدم isolated → no network effects
- بوجود Connection: users discover and transact through trusted relationships
- اقتصادياً: trust graph = virality engine → organic growth → lower acquisition cost

---

## 4. AUTHORITY BOUNDARY

### Owns
- Social graph (follow/connect relationships)
- Business graph (merchant-customer relationships)
- Trust signals (verified transactions between users)
- Reputation signals (ratings, reviews, endorsements)
- Collaboration context (shared projects, deals)

### Does NOT Own
- Identity verification (owned by tec-auth-service)
- Transaction truth (owned by tec-payment-service)
- Asset ownership (owned by tec-asset-service)
- Discovery rankings (Explorer owns discovery — C-108)
- AI recommendations (TEC AI owns reasoning — C-104)

### Interface Points
```
OUTBOUND:
  Trust graph API      → Explorer (C-108) — trusted business signals
  Relationship context → TEC AI (C-104) — social context for reasoning
  Network signals      → Analytics (C-105) — relationship metrics
  Referral signals     → SYSTEM (C-110) — for incentive governance

INBOUND:
  payment.completed.v1 → trust signal (user A paid user B = relationship)
  order.created.v1     → commerce relationship signal
  tec_user cookie      → identity anchor for graph node
  User actions         → explicit follow/connect/review
```

---

## 5. TECHNICAL ARCHITECTURE

```
Planned Stack:
  Next.js 15 App Router + TypeScript strict
  Graph Database: Neo4j or PostgreSQL with graph extensions
    (PostgreSQL with recursive CTEs for MVP, Neo4j for scale)
  tec-identity-service (4004) — identity anchor
  tec-realtime-service (4009) — live notifications on relationship events
  Redis — hot relationship cache (followers, trust scores)

Graph Data Model:
  Node types: User, Merchant, Asset, Product
  Edge types: follows, trusts, transacted_with, reviewed,
              co-invested, collaborated
  Edge properties: timestamp, transaction_count, trust_score, direction

Trust Score Computation:
  Inputs: verified_transactions, review_score, shared_connections
  Algorithm: weighted graph traversal (to be defined)
  Update frequency: event-driven (on each trust signal event)
  Output: trust_score [0.0-1.0] per relationship pair

Consistency Model:
  Eventual consistency (relationship signals — C-47 §6)
  Trust scores recalculated asynchronously
  Strong consistency only for: explicit connect/disconnect actions
```

---

## 6. SECURITY MODEL

```
Relationship Privacy:
  Users control visibility of their graph edges
  Default: connections visible to connected users only
  Trust scores: private unless user explicitly shares

Graph Integrity:
  Trust signals only from verified Pi transactions
  Fake review detection: rate limiting + anomaly detection
  Sock puppet protection: KYC-verified users only for trust signals

Access Control:
  User: own graph full access
  TEC AI: aggregate signals (no individual relationship details)
  Explorer: trust signal summary only (not full graph)
  Analytics: anonymized aggregate graph metrics
```

---

## 7. REVENUE MODEL

**Indirect (Network Effects)**

| Channel | Mechanism | Value |
|---------|-----------|-------|
| Network Effects | Larger graph → more valuable platform | Platform-level |
| Discovery Boost | Businesses visible to trusted connections | Explorer integration |
| Referral Infrastructure | Trust graph powers referral mechanics | Platform-level |
| Premium Connection | Enhanced profiles + connection analytics | PRO subscription |

---

## 8. KEY METRICS

```
Graph Density:          Track edges/nodes ratio over time
Trust Signal Coverage:  % of transactions generating trust edge
DAU with Connections:   % of daily active users with ≥1 connection
Referral Conversion:    % of trusted referrals that transact
Network Effect Score:   Value per node as graph grows
Review Integrity:       % flagged reviews vs total reviews
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Viral Growth Engine** — trust graph enables word-of-mouth at scale
- **Discovery Amplifier** — Explorer surfaces trusted businesses first
- **TEC AI Social Context** — AI recommendations informed by who user trusts
- **Retention Multiplier** — connected users churn significantly less

---

## 10. FUTURE EVOLUTION

```
Phase 1 (MVP):
  → Follow/unfollow other TEC users
  → Transaction-based trust signals
  → Basic relationship feed (activity of connections)

Phase 2:
  → Business relationships (merchant-customer graph)
  → Trust-weighted Explorer search
  → Collaborative features (shared wishlists, co-purchase)

Phase 3:
  → Economic Relationship Graph
  → Cross-Pi-ecosystem connection (connect with any Pi user)
  → Reputation portability (trust score follows user across apps)
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P0:**
```
[P0-1] Graph Database Decision
  Choose between PostgreSQL + pgvector/recursive CTEs (MVP, cheaper)
  vs Neo4j (better graph operations, higher cost).
  Recommendation: start with PostgreSQL, migrate to Neo4j at 100k nodes.

[P0-2] Privacy Framework Before Launch
  Define: what relationship data is visible to whom.
  Edge cases: user blocks, relationship deletion, data export.
```

**P1:**
```
[P1-1] Trust Signal Event Consumer
  Must consume payment.completed.v1 from Redis Streams to auto-build
  trust graph without requiring explicit user action.

[P1-2] Spam/Fake Review Protection
  Rate limiting on review submissions.
  KYC requirement for trust signals.
```

---

## 12. INTEGRATION MAP

```
This charter (C-107) depends on:
  C-100 HUB       → SSO identity anchor
  C-105 ANALYTICS → event stream for trust signal ingestion
  C-106 LIFE      → personal context overlay on relationships
  C-110 SYSTEM    → governance for referral incentives

Other charters depend on this one for:
  C-104 TEC AI    → social context for personalized reasoning
  C-108 EXPLORER  → trusted business signals for discovery ranking
  C-103 ECOMMERCE → social commerce (buy what connections bought)
  C-105 ANALYTICS → relationship network metrics
```

---

## 13. RUNTIME PLACEMENT & CURRENT STATE (2026-07)

**Truth State (this section):** [Current State] for the shipped slice · [Planned State] for the split
**Verification:** [Code Verified] (slice 1)
**Governance State:** [Governance Approved] — architectural decision of record

### 13.1 The two-layer split (decision of record)

Connection is **not one runtime** — it is two layers with different consistency and
durability needs. They MUST NOT be collapsed onto a single service:

| Layer | What it holds | Consistency | Home (now) | Home (at scale) |
|-------|---------------|-------------|-----------|-----------------|
| **System of Record** — the durable graph | follow/connect edges, trust scores, community membership | strong for self-declared edges; eventual for derived trust | **tec-identity-service** (incubation) | **tec-connection-service** (extracted) |
| **System of Engagement** — the live layer | presence ("online now"), live follow/connection-request notifications, chat | ephemeral / eventual | **tec-realtime-service** | tec-realtime-service (unchanged) |

**Why the durable graph incubates in identity-service (not realtime, not storage):**
- The graph anchors on the `User`/`Identity` node — co-locating avoids a cross-service
  join per edge (C-47: *cross-service references = ID only; each entity has one owner*).
- Self-declared edges want **read-your-writes** (follow → visible immediately). C-47
  §6: identity reads = **Strong**; realtime is eventual by design.
- realtime-service is optimised for ephemeral pub/sub (WebSockets, presence, streams);
  the source-of-truth graph must not depend on a runtime that restarts / scales
  horizontally without a durable relational store.
- **storage-service is explicitly wrong** — it owns files/blobs (avatars, media),
  not graph edges.

**Why realtime-service still matters:** it owns the *live* half — presence and
push-notifications on relationship events (`§5` already lists `tec-realtime-service
(4009)`). This is CQRS-shaped: identity/connection owns the **write model** (truth),
realtime owns the **read/push model** (live signals). realtime *reacts to* the graph;
it never *owns* it.

### 13.2 Extraction trigger (identity → connection-service)

Extract a standalone `tec-connection-service` when the graph outgrows its incubator —
aligned with §10 Phase evolution + §11 [P0-1]: at **~5k–10k active users or ~100k
graph nodes**. Until then the graph lives in identity-service behind
`@Controller('identity/connection')`, so the existing `/api/identity/*` gateway route
covers it with **no gateway change**. Extraction moves only the durable graph out;
realtime keeps the live layer.

### 13.3 Slice 1 — Follow / Connect — SHIPPED [Current State]

The first slice of §10 Phase 1 ("Follow/unfollow other TEC users") is live:

```
Backend  (tec-identity-service):
  prisma  Follow(follower_id → User, followee_username by Pi identity anchor;
          @@unique(follower_id, followee_username))  → table connection_follows
  @Controller('identity/connection'):
     POST   follow            (upsert; self-follow rejected; username normalized)
     DELETE follow/:username  (unfollow)
     GET    following         (caller's own edges)
     GET    stats             ({ following, followers } counts)
  Isolation (P6): follower = VERIFIED session identity (JWT) — never a param/body.
                  Only the followee comes from the request body.

Frontend (tec-connection):
  /api/bff/connection/*  →  forwardConnection  →  /api/identity/connection/*
  useConnection hook + Connections card in /app: follow @username, unfollow,
  live following/followers counts, own-graph list.

Monetization key: PI_API_KEY_CONNECTION registered in payment-service
  (PI_KEY_SOURCES) so a future Connection Pro buy approves under Connection's own
  Pi App ID (`connection-aa9fba4f11664096`), not the default Hub key.
```

**Next slices (unchanged from §10):** Slice 2 — trust signals from
`payment.completed.v1` (§11 [P1-1], event-driven, eventual) → trust score on the
edge. Slice 3 — presence + live "new follower" notifications via
**tec-realtime-service** (the System-of-Engagement layer above).
