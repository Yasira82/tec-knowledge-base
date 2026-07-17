# C-107 — CONNECTION INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Future Vision]
**Governance State:** [Draft]
**Verification State:** [Assumed]
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

### 13.4 Slice 2 — Trust Graph — SHIPPED [Current State] [Runtime Verified]

Trust signals from real economic activity (C-107 §4/§6). **Correction to §11
[P1-1]:** `payment.completed.v1` is a **single-party** User-to-App event (payer
only) — it cannot form a user↔user edge. Trust is built from **`order.paid.v1`**
(buyer + seller), which commerce now emits.

```
Emit    (tec-commerce-service):
  order.paid.v1 { buyer_id, sellers:[{seller_id, amount}], currency } on every
  PAID order (createOrder w/ payment_id + checkout). Fail-soft (a Redis outage
  never fails a sale). Commerce owns order truth; it only emits the fact.
Consume (tec-identity-service):
  order-paid.consumer (Redis Streams) → TrustEdge(source=buyer → target=seller,
  order_count + volume DECIMAL). IDEMPOTENT via ProcessedTrustEvent (eventId in
  the same tx → a redelivery is a no-op; C-70 at-least-once). Self-trust skipped.
  GET identity/connection/trust → own-scope given/received (partners, orders, π).
Frontend (tec-connection): useTrust + Trust card (given/received) — replaces the
  "Soon" pillar. Diagnostic: GET /trust/diag (processed_events liveness).

Security foundation (P6/R1): buyer_id is now derived from the SESSION (JWT sub) in
  ALL commerce order endpoints — previously client-supplied (spoofable). This also
  aligns buyer_id = seller_id = the trust keyspace.
```

**Runtime Verified 2026-07-04:** a real buyer with 2 paid orders to 2 distinct
sellers showed `given: 2 partners · 2 orders · π 20` in the Trust card; idempotent
(2 orders = 2 clean edges), own-scope, money correct.

Consistency: trust is **derived / eventual** (C-47 §6) — never financial truth.

### 13.5 Slice 3 — Presence — SHIPPED [Current State]

The first live-layer feature (System of Engagement, §13.1) — on
**tec-realtime-service**, keyed by Pi username (the follow-graph anchor).

```
Backend  (tec-realtime-service): PresenceService (Redis SET presence:<user> EX 45s
  + mget) + POST /presence/sync { usernames } → marks caller online + returns the
  online subset. Ephemeral, fail-soft, NO durable state. Reached via the gateway
  /api/realtime/presence/sync.
Frontend (tec-connection): usePresence — 30s HTTP heartbeat (no browser WebSocket)
  → green online dot per followed user + "N online" in the Connections header.
```

Consistency: **eventual**, ephemeral. This is the live layer *reacting to* the
graph (identity owns), never owning it — the §13.1 CQRS split, in code.

### 13.6 "New follower" notifications — SHIPPED [Current State]

A durable relationship notice, created **synchronously in the follow handler**
(no event bus, no WebSocket) — the engineering-correct choice over a fragile
instant toast (durable + own-scope + HTTP-verifiable).

```
Backend  (tec-identity-service): ConnectionNotification (recipient/actor/type,
  read; @@unique(recipient,actor,type) → a re-follow refreshes, never spams).
  follow() upserts a 'follow' notice for the followee — FAIL-SOFT (a notification
  write never fails the follow). GET/POST identity/connection/notifications
  (list + unread; mark read) — recipient = session username (P6).
Frontend (tec-connection): useNotifications (30s poll) + 🔔 banner with an unread
  badge; opening marks read.
```
> NOTE: the platform-wide `Notification` entity is owned by tec-notification-
> service (C-47). This is a bounded Connection-domain relationship notice,
> migratable to notification-service later. A live WS push (realtime gateway)
> remains an optional fast-follow on top of this durable base.

### 13.7 Collaboration — shared collections — SHIPPED [Current State]

The ✨ pillar (§4 "collaboration context" / §10 Phase 2 "collaborative features").
"Shared context for working together": an owner creates a collection, invites
people they're connected to, and any member adds items.

```
Backend  (tec-identity-service): Collection + CollectionMember + CollectionItem
  (username-keyed, cascade). CollectionService — own-or-member scope (P6): create
  (owner auto-member), list (owned OR member), get (member-only), addItem
  (member-only), addMember (OWNER-only invite). @Controller
  'identity/connection/collections'.
Frontend (tec-connection): useCollections/useCollection + Collaboration card in
  /app — create, open, add items, invite.
```

Consistency: **strong** for the self-declared collection (the members control it).

### 13.8 Pillar set — COMPLETE

All four C-107 pillars are live and own-scope (P6):

| Pillar | Layer | Status |
|--------|-------|--------|
| 🤝 Connections (follow) + 🟢 Presence + 🔔 Notifications | SoR graph + live | ✅ `[Current State]` |
| 🛡️ Trust (from `order.paid.v1`) | SoR graph, derived | ✅ `[Runtime Verified]` |
| ✨ Collaboration (shared collections) | SoR graph | ✅ `[Current State]` |

The §13.1 two-layer split held throughout: durable graph (follow · trust ·
collections · notifications) in **tec-identity-service**; the live layer
(presence) on **tec-realtime-service**. Extraction to a standalone
`tec-connection-service` remains the §13.2 trigger (~5k–10k users / ~100k nodes).
