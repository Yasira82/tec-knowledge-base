# C-107 — CONNECTION INSTITUTIONAL CHARTER
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

**Connection is deployed on Mainnet** with Hub SSO and dual-mode (ADR-007) Pi payment live:
- **Domain:** `connection.tecosystem.app` · **Pi App ID:** `connection-aa9fba4f11664096` · **APP_SOURCE:** `connection`
- **Payment:** real Pi subscription — Mode 1 (Hub) + Mode 2 (standalone); `PI_API_KEY_CONNECTION` set on payment-service.
- **Hub SSO:** enabled (in `/api/auth/sso` ALLOWED_TARGETS + Hub domain registry).
- **Growth:** referral loop wired (C-133).

**Still `[Future Vision]`:** the advanced runtime described below (V2+ / the charter's later phases) — vision, not yet built.

---


## Verified Badge — WIRED (2026-09-02)

> Truth State: **[Current State]** · Verification: **[Code Verified]** — tec-core-backend
> **#264** (in review). Session 50.

`ConnectionProfile.verified` was read, **ranked by**, and rendered with a comment saying it
is "presented from Zone/kyc" — and **nothing ever wrote it**. Every profile sat at the
default `false`.

Worse than a missing feature: the directory orders `[{ verified: 'desc' }, { featured:
'desc' }, … ]`, so with the earned signal pinned false the ranking collapsed onto
`featured` — Connection Pro, which is **bought**. The directory ranked by the paid signal
because the earned one was empty. `DirectoryCard`'s own comment warns against exactly that.

**Now driven by `zone.badge.issued.v1` / `.revoked.v1`, for `BUILDER` and `MERCHANT` only.**
Those two are facts about the PERSON — Zone's own person type, and a reviewer confirming
this person runs this business. `PROJECT` and `COMMUNITY` are things a person is merely
associated with: **verifying a community does not vouch for whoever registered it**, and a
directory of people that said otherwise would make a claim nobody reviewed.

Two properties worth keeping:
- **Recompute, never toggle.** A person may hold several verifications; revoking one must
  not clear a badge Zone never withdrew. It also makes at-least-once delivery harmless.
- **Through `ZoneService`, never Zone's tables** — the R-2-clean seam (Elite → Legend,
  VIP → Elite). The type rule lives there, not in the consumer: deciding it twice is how
  two answers start to disagree.

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

---

## 14. TEC CONNECT — THE DISTRIBUTION PLAN (2026-09-01)

**Truth State (this section):** [Current State] for §14.2 · [Planned State] for §14.3 · [Future Vision] for §14.4
**Verification:** [Code Verified] — Tec-Connection #53
**Governance State:** [Governance Approved] — architectural decision of record

### 14.1 The premise, and why it is not a new idea

The plan is to stop asking anyone to "open Connection". Connection becomes a
**layer inside the rest of TEC** rather than a destination: a `[Follow]`, `[Message]`
or `[Connect]` control appears wherever a person is shown — in Explorer, in Life, on
a business card — and the user never has to know which app performed it.

This is **not a change of direction.** §4 of this charter already says Connection
OWNS the graph and the other apps READ it. What happened is that the app was built
and the layer was not. §14 is the layer, finally.

> **The acquisition claim, stated plainly:** the distribution channel is a person
> sending another person a link — not a campaign. `/u/<handle>` is that link.

### 14.2 SHIPPED — the profile link does the thing (Tec-Connection #53)

`/u/<handle>` already existed, with an OG card that renders the person's name,
headline and follower count when pasted into WhatsApp or Telegram. Two gaps made it
inert, and both are now closed:

| Was | Is |
|---|---|
| The button was `<Link href="/app">` — literally *"go and open the app"*, the one sentence a shared link exists to avoid. Whoever tapped it landed in an empty app with no memory of who they came to see. | It **follows that person**, signing in on the way if there is no session, and returning to the same profile. |
| Nothing offered to share the link. The reader had to notice the address bar and copy the URL by hand. | A share control that opens the **native sheet** — straight into WhatsApp / Telegram / Pi Chat — with clipboard, then a visible URL, as fallbacks. |

**The cold-start round trip:**

```
tap Follow  →  Pi sign-in  →  back to THIS profile  →  followed
```

Three decisions worth keeping:

- **The intent rides in the URL (`?follow=1`), not in storage.** The Hub already
  preserves `pathname + search` of the sign-in target and returns it to
  `/api/auth/sso-callback` as `redirect` — so nothing has to survive a redirect that
  Pi Browser is known to be rough with (**C-123**).
- **The intent is spent when it is READ, before the request.** Left in the address
  bar it replays on every refresh, and a screenshot of that URL would follow on the
  reader's behalf.
- **`navigator.share` before clipboard.** On a phone the native sheet *is* the
  distribution path; the clipboard is the desktop fallback, and a selectable URL is
  the fallback for both — Pi Browser does not always grant clipboard access, and a
  share button that appears to do nothing is worse than none.

### 14.3 NEXT — TEC Connect inside other apps, and the constraint that shapes it

> 🔴 **The constraint the plan must be built around: each TEC app is a SEPARATE ORIGIN.**
>
> `explorer.tecosystem.app` and `connection.tecosystem.app` do not share a cookie
> jar. A `[Follow]` button inside Explorer therefore **MUST NOT** call Connection's
> API from the browser — that is a third-party request with credentials, exactly the
> case **C-123** documents Pi Browser breaking (`Partitioned` cookies; `Set-Cookie`
> dropped on XHR and on 3xx).
>
> **It goes through the host app's OWN BFF:** `Explorer → /api/bff/connection/follow`
> → gateway → identity-service. Same origin from the browser's point of view — the
> two-SDK boundary the platform already has.
>
> Built the other way it **works in Chrome and fails in Pi Browser** — the worst kind
> of failure, because it passes every test.

**Order, and why not an SDK first.** The proposal was a universal
component/SDK dropped into Explorer and Life together. That is premature abstraction:
the shape is not known yet, and this platform has already paid for that mistake — the
`tec-ui` major left **18 apps frozen on a `^1.1.0` caret for months**, unnoticed
(C-02 Session 46). A shared social component across 24 apps carries the same
coordination cost.

```
1. ✅ /u/<handle> follows + shares            — shipped, §14.2
2. □  Explorer: ONE copy-pasted [Follow], through Explorer's own BFF
3. □  Life:     the second copy
4. □  Extract the shared piece — AFTER two call sites show what actually varies
```

**One unresolved naming decision (blocking step 2).** *Follow* and *Connect* are
used interchangeably in the proposal, but only **Follow** exists: one-directional, no
consent. A button labelled *Connect* that performs a Follow is a lie in the UI.
Mutual connection is a whole feature — request, accept, reject, notify — and the same
machinery was just built for group join requests. **Recommendation: ship Follow only
until the graph has users.**

### 14.4 DEFERRED — with the reason, not just the label

| Item | Status | Why it is deferred, not forgotten |
|---|---|---|
| **Mutual "Connect" (request → accept)** | Deferred | A second approval queue before the first one has users. Follow answers the same need today. |
| **`[Message]` from another app** | Deferred | Needs step 2's BFF pattern proven first, plus a decision on what a DM from a stranger costs (spam surface). |
| **Universal Connect SDK / shared component** | Deferred **by design** | Extract after two call sites, never before — see §14.3. |
| **"Connect" to someone not yet on TEC** | Deferred | Would create a **half-edge to a principal that may never exist**. The identity anchor is `piUsername` (§4). If built: the invite is a **signed expiring token, not an edge** — the edge is created on redemption, both sides verified. Same discipline as the group invite code. |
| **Find-me-by-phone (opt-in, OTP)** | Deferred | Coherent only as a user's own opt-in. Never as a lookup. |
| **Phone → Pi account directory** | 🔴 **Rejected, permanently** | Pi exposes no such directory, and building one would violate §6 privacy regardless of feasibility. Recorded as rejected so it is not re-proposed. |

### 14.5 An open privacy decision this surfaces

`/u/<any handle>` is a **public page at a guessable URL** that states a follower
count. §4 of this charter says the graph is **sovereign — the user controls what any
other app may see**, and Legend (C-126) already carries `PUBLIC / CONNECTIONS /
PRIVATE`. **Connection carries nothing equivalent.**

Today this is mitigated only by the page being opt-in — a profile appears solely
after the user publishes it — which is a real protection and probably the right
default. But *published* currently means one thing and cannot be narrowed, and the
follower count was never separately consented to.

**This needs an explicit decision before §14.3 multiplies the surface**, because every
new `[Follow]` button in another app is another place that count is read. It is
recorded here as **open**, not resolved.
