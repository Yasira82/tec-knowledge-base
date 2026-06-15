# C-107 — CONNECTION INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** Future Vision
**Governance State:** Draft
**Verification State:** Unverified
**Authority Scope:** Domain
**Decision Status:** Exploratory

---

## 1. MISSION

Connection is the social relationship infrastructure of the TEC ecosystem — the system that maps trust relationships between Pi identities, enabling social commerce, peer recommendations, reputation transfer, and cooperative economic participation.

---

## 2. INSTITUTIONAL ROLE

**System of Infrastructure (Relationship Layer)** — The trust graph of the Pi economy.

```
Settlement → Record → Reasoning → Access → Construction → PRODUCTION → Economic Activity → Settlement
                                                                 ↑
                                                           CONNECTION
                                                      (Relationship Infrastructure)
```

Connection is infrastructure, not production. It doesn't produce economic value directly — it creates the trust substrate on which social commerce, cooperative pools, and peer-to-peer economic activity operate. Every connection is an economic relationship claim.

---

## 3. ECONOMIC PURPOSE

Connection exists to create trust-weighted economic relationships:

- **Identity Network**: Pi identities + TEC profiles form a verifiable social graph
- **Trust Graph**: Follow relationships create trust signals for commerce and lending
- **Social Commerce**: See what your trusted network is buying → reduces discovery cost
- **Peer Reputation**: Your reputation in the network is an economic asset
- **Cooperative Economics**: Groups can pool resources, coordinate purchases, share information
- **Messaging**: Direct economic coordination between Pi identities

Without Connection, TEC is a set of isolated apps. With Connection, it becomes a network economy where social trust creates economic efficiency.

---

## 4. AUTHORITY BOUNDARY

### Owns
- Social graph (who follows whom, mutual connections)
- Direct messaging between Pi identities
- User profile design (TEC-level profile separate from Pi profile)
- Connection requests and acceptance workflow
- Group creation and membership
- Reputation score (TEC-level, separate from Pi's reputation system)

### Does NOT Own
- Pi Network identity (tec-auth-service owns)
- Pi Network's own reputation/trust scores (Pi Network sovereign)
- Payment initiation (Hub payment modal)
- Asset ownership (tec-asset-service)
- Content/posts (Connection is relationships, not social media)

### Interface Points
```
Exposes to ecosystem:
  - Trust score API: GET /api/connection/trust/{userId} (for FundX, Commerce)
  - Social graph API: GET /api/connection/network/{userId} (for Ecommerce recommendations)
  - Mutual connection check: GET /api/connection/mutual/{userId1}/{userId2}
  - Group membership: GET /api/connection/groups/{userId}

Consumed from:
  - Hub (C-100): SSO identity (Pi username = connection node ID)
  - tec-auth-service (4001): identity verification
  - tec-analytics-service (4007): activity signals for reputation scoring
  - Assets (C-102): creator reputation data enriches connection profiles
```

---

## 5. TECHNICAL ARCHITECTURE

### Planned Stack
- Next.js 15 App Router + TypeScript strict
- New backend service: `tec-connection-service` (Port 4013 — to be provisioned)
- **Graph Database**: Neo4j or PostgreSQL with recursive CTEs for graph traversal
- Redis: social graph cache (frequent trust lookups need low latency)
- tec-realtime-service (4009): real-time messaging delivery
- Deployment: Vercel (connection.tecosystem.app)

### Social Graph Schema
```typescript
// Connection node
interface TecProfile {
  id: string            // UUID
  piUsername: string    // from tec-auth-service (LOCKED identity)
  displayName: string
  avatarHash: string    // hash of avatar stored in tec-storage-service
  bio: string
  tecReputationScore: number  // 0-1000, computed
  createdAt: string
}

// Edge in social graph
interface Connection {
  fromUserId: string
  toUserId: string
  type: 'follow' | 'mutual' | 'blocked'
  createdAt: string
  // trust weight computed from: mutual connections, Pi transaction history together, reputation
}

// Computed trust score
interface TrustScore {
  fromUserId: string
  toUserId: string
  score: number         // 0-100
  components: {
    mutualConnections: number
    transactionHistory: number  // Pi transactions between them
    reputationScore: number
    activityRecency: number
  }
}
```

### Messaging Architecture
```
Direct message:
  Sender → POST /api/bff/connection/messages
    → tec-connection-service (4013): store message
    → tec-notification-service (4008): push notification
    → tec-realtime-service (4009): WebSocket delivery
  Recipient receives real-time in UI

Encryption: End-to-end encryption for messages (Phase 2)
Retention: Messages stored 90 days (configurable by user)
```

### Trust Score Computation
```
tecReputationScore = weighted sum of:
  - Transaction history (Pi payments sent + received) : 30%
  - Connection network quality (connections' reputation) : 25%
  - Asset portfolio value (from Assets C-102) : 15%
  - Activity recency (last active on platform) : 15%
  - KYC verification status : 15%

Computed nightly via batch job.
Cached in Redis (TTL: 24h).
```

---

## 6. SECURITY MODEL

### Authentication
- All Connection endpoints require authenticated session
- Pi username = immutable identity node (from tec-auth-service — never user-modifiable)

### Authorization
- Profile visibility: configurable (public / connections-only / private)
- Message access: only sender and recipient
- Blocked users cannot view profile or send messages
- Trust score: the requester's trust score toward a user (not the user's own score, which is public)

### Threat Vectors
| Threat | Mitigation |
|--------|------------|
| Fake connections inflating trust score | Trust score weighted by Pi transaction history (hard to fake) |
| Message spam | Rate limit: 50 messages/hour on FREE, 200 on PRO |
| Profile scraping | Rate limit on profile lookups; bot detection |
| Identity impersonation | piUsername from tec-auth-service — immutable, Pi-verified |
| Sybil attacks on reputation | KYC verification required for reputation score > 500 |

---

## 7. REVENUE MODEL

### Direct
1. **Connection PRO**: Extended message history, advanced group features, priority in social commerce
2. **Verified Reputation Badge**: KYC + activity verification badge (trust signal for commerce)
3. **Group Commerce Tools**: Merchant tools for community buying groups

### Indirect
- Social trust → higher Ecommerce conversion (peer recommendations reduce hesitation)
- Reputation system → FundX pool access (trust = collateral equivalent)
- Engaged social network → higher platform retention and DAU

---

## 8. KEY METRICS

### SLOs
| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| Connection service availability | ≥ 99.0% | < 98.0% |
| Message delivery latency | < 500ms P95 | > 2s P95 |
| Trust score computation lag | < 24h from activity | > 48h |
| Social graph query response | < 200ms P95 | > 1s P95 |

### KPIs
| Metric | Target | Frequency |
|--------|--------|----------|
| Connections per active user | ≥ 5 average | Monthly |
| Message volume | Increasing trend | Weekly |
| Social commerce conversion | ≥ 20% higher than discovery | Monthly |
| Trust score distribution | < 10% users at minimum score | Monthly |

---

## 9. ECOSYSTEM CONTRIBUTION

1. **Trust Infrastructure**: Every other system can query Connection for trust signals (FundX, Commerce, Assets)
2. **Social Commerce Amplifier**: Connected users buy more from each other — peer recommendations drive Ecommerce conversion
3. **Retention Engine**: Social graphs are sticky — users with connections churn at dramatically lower rates
4. **Pi Network Integration**: TEC Connection profile enriches Pi Network's social layer with economic activity data
5. **FundX Trust Collateral**: Reputation score substitutes for credit history in Pi-native lending

---

## 10. FUTURE EVOLUTION

### Phase 1 (MVP — Month 3–4 post-Mainnet)
- Follow/unfollow Pi identities
- Basic TEC profile (avatar, bio, reputation score display)
- Direct messaging (stored, async)
- See connections' recent Commerce purchases (privacy setting: opt-in)

### Phase 2 (Month 5–6)
- Real-time messaging via tec-realtime-service (4009)
- Groups: create/join groups for collective purchasing
- Social commerce: shared product lists, group buying coordination
- Trust score API live for FundX integration

### Phase 3 (Month 7–8)
- End-to-end encrypted messaging
- Reputation-staked recommendations: stake Pi on a product recommendation
- Connection-based lending circles (micro-pools via FundX)
- Cross-app identity: TEC Connection profile visible from Assets, Explorer

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Critical (Before Connection MVP)**
1. **Provision tec-connection-service** (Port 4013) on Railway
2. **Graph database decision**: Choose between Neo4j (full graph DB) or PostgreSQL with recursive CTEs — ADR required
3. **piUsername immutability**: Confirm tec-auth-service enforces immutable Pi username — it is the graph node ID

**P1 — High Priority**
4. **Trust score schema**: Define all components and weights before first computation
5. **Message storage encryption**: Messages at rest encrypted in PostgreSQL
6. **Rate limiting**: Message and API rate limits enforced server-side before launch

**P2 — Medium Priority**
7. **Real-time relay**: tec-realtime-service (4009) integration for WebSocket messages
8. **Profile media storage**: tec-storage-service (4010) integration for avatars
9. **Social commerce BFF**: `/api/bff/connection/feed` for social purchase activity

---

## 12. INTEGRATION MAP

```
C-107 (CONNECTION) depends on:
← C-100 (HUB)        : SSO identity (Pi username = graph node ID)
← C-102 (ASSETS)     : Creator reputation enriches connection profile
← C-105 (ANALYTICS)  : Activity signals for reputation scoring
← tec-core-backend   : tec-auth-service (4001), tec-realtime-service (4009)

C-107 (CONNECTION) contributes to:
→ C-103 (ECOMMERCE)  : Social commerce recommendations
→ C-104 (TEC AI)     : Social graph signals for recommendations
→ C-108 (EXPLORER)   : Connection-aware local discovery
→ C-113 (FUNDX)      : Trust score as collateral for lending pools
```

---

*Charter issued by TEC Economic Infrastructure Design Partnership*
*Version 1.0 — 2026-06-15*
