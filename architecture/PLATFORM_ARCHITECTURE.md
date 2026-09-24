# TEC Platform Architecture

> Version: 3.2.0 — June 2026
> Truth State: [Current State] — verified against live platform (June 2026)
> Future Vision sections explicitly labeled
> Authority: C-00 Platform Constitution + C-67 Source of Truth Matrix
> ADR References: ADR-001 → ADR-007 (C-64)

---

## 1. PLATFORM IDENTITY

```
TEC TODAY:    Federated Pi-Native Economic Coordination Platform
TEC DIRECTION: Pi-Native Economic Operating Infrastructure
TEC LONG-TERM: Pi-Native Economic Operating Infrastructure

Not: a super app
Not: a monolithic SaaS
Is:  a Federated Economic Operating Infrastructure

Core Flow:
  Economic Graph → Identity Graph → Federated Applications → Operating Infrastructure
```

---

## 2. THE 9-LAYER INFRASTRUCTURE MODEL

> Truth State: [Future Vision] (complete model) — Layers 1, 4 (partial), 8, 9 are [Current State]

```
 Pi Network (Blockchain + Settlement + Wallet)       [External — Foundation]
      ↓
 Layer 1:  Identity Infrastructure                   [Current State]
           Hub Auth + Trust + Pi identity
      ↓
 Layer 2:  Reality Infrastructure                    [Planned → Future]
           Life (Personal Context) + Connection (Relationships) + Explorer (Discovery)
           → System of Record
      ↓
 Layer 3:  Intelligence Infrastructure               [Planned State]
           Analytics — economic signals + health + risk
      ↓
 Layer 4:  Governance Infrastructure                 [Current State — partial]
           SYSTEM (API Gateway + ADRs + Policy CI + Kill Switches)
      ↓
 Layer 5:  Coordination Infrastructure              [Future Vision]
           Nexus — orchestrates mature layers
      ↓
 Layer 6:  Risk Infrastructure                      [Future Vision]
           ALERT + NX
      ↓
 Layer 7:  Reasoning Infrastructure                 [Future Vision]
           TEC AI — Institutional Reasoning Runtime (cross-layer)
      ↓
 Layer 8:  Access Infrastructure                    [Current State]
           Hub — Unified Access Platform
      ↓
 Layer 9:  Production Infrastructure                [Current State]
           Commerce + Assets + Ecommerce + Apps
      ↓
    Economic Activity
```

### Three-Way System Classification

```
System of Record    = Layers 1-6 (Infrastructure)
  → defines economic reality
  → Truth Owner of all economic state

System of Reasoning = Layer 7 (TEC AI)
  → interprets economic reality
  → produces Recommendations only — NEVER executes
  → Recommendation Owner

System of Access    = Layer 8 (Hub)
  → provides access to TEC infrastructure
  → SSO Authority + Payment Orchestrator + App Registry
  → Access Owner

Systems of Production = Layer 9 (Apps)
  → create economic value within infrastructure
  → Execution Owner within sovereign domain
```

---

## 3. TECHNICAL SYSTEM LAYERS

```
┌─────────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                                │
│  Pi Browser  ·  Hub  ·  Commerce  ·  Assets  ·  Ecommerce      │
│  packages/tec-core-sdk  (usePiAuth, useTecWallet)               │
└──────────────────────────┬──────────────────────────────────────┘
                           │  HTTPS / Cookies
┌──────────────────────────▼──────────────────────────────────────┐
│                      BFF LAYER                                  │
│  Next.js API Routes  /api/bff/*                                 │
│  @yasser172/tec-sdk  (server-side only)                         │
│  Cookie auth + CSRF validation + token refresh                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │  x-internal-key: INTERNAL_SECRET
┌──────────────────────────▼──────────────────────────────────────┐
│                    GATEWAY LAYER                                │
│  tec-api-gateway  :4000  (Railway)                              │
│  JWT verification  ·  routing  ·  rate limiting                 │
│  Single entry point — services NOT exposed to internet          │
└──────┬───────┬──────────┬──────────┬──────────┬────────────────┘
       │       │          │          │          │
   ┌───▼─┐ ┌──▼──┐   ┌───▼──┐  ┌───▼──┐  ┌───▼──┐
   │Auth │ │Pay  │   │Comm  │  │Asset │  │ ...  │
   │4001 │ │4002 │   │4003  │  │4006  │  │      │
   └─────┘ └─────┘   └──────┘  └──────┘  └──────┘
```

**Rule (ADR-005):** Client NEVER calls Railway URLs directly. All traffic goes through BFF → Gateway.

---

## 4. FEDERATED APP MODEL

```
                    HUB (Conductor)
                  hub.tecosystem.app
                  ┌─────────────────┐
                  │  SSO Authority  │
                  │  Identity Root  │
                  │  Payment Orch.  │
                  │  App Registry   │
                  └────────┬────────┘
                           │  SSO cookies
           ┌───────────────┼───────────────┐
           │               │               │
    ┌──────▼──────┐ ┌──────▼──────┐ ┌─────▼───────┐
    │  Commerce   │ │   Assets    │ │  Ecommerce  │
    │  /commerce  │ │   /assets   │ │    /shop    │
    │  Merchant   │ │  Ownership  │ │  Consumer   │
    │  Dashboard  │ │    Layer    │ │ Marketplace │
    └─────────────┘ └─────────────┘ └─────────────┘
```

**Each app:**
- Has its own Pi App ID (per-app)
- Has its own BFF (Next.js API routes)
- Shares identity via Hub SSO cookies
- Follows Dual-Mode payment (ADR-002 + ADR-007)

---

## 5. IDENTITY & AUTH ARCHITECTURE

```
Pi Network
    │
    │  Pi.authenticate()
    ▼
tec-auth-service :4001
    │  JWT (HS256) issued
    ▼
Hub sets HttpOnly cookies:
  tec_access_token   httpOnly: false  ← Pi Browser requirement (ADR-001)
  tec_refresh_token  httpOnly: true
  tec_csrf           httpOnly: false
  tec_user           httpOnly: false  ← JSON: { userId, username, role }
    │
    │  All apps read same cookies
    ▼
@yasser172/tec-auth
  getStoredUser()      → reads tec_user
  getAccessToken()     → reads tec_access_token
  ssoRedirect(url)     → hub.tecosystem.app/login?return_url=...
  usePiAuth()          → React hook: { user, token, isAuth, loading }
```

**Rule:** Cookie names are LOCKED. Change requires ADR + coordination across all 5 repos.

---

## 6. PAYMENT ARCHITECTURE (DUAL-MODE)

Based on ADR-002 + ADR-007. Every app supports both modes.

```
                    User initiates payment
                           │
               isHubNavigation()?
                    │           │
                   YES           NO
                    │           │
              ┌─────▼──────┐  ┌─▼──────────────────┐
              │   MODE 1   │  │      MODE 2         │
              │Hub Redirect│  │  Direct Pi Payment  │
              └─────┬──────┘  └─────────┬───────────┘
                    │                   │
         /hub?pay=1&amount=X    Pi.authenticate()
         &memo=Y&product_id=Z   Pi.createPayment()
                    │                   │
              Hub PaymentModal   Pi Browser Wallet
                    │                   │
              tec-payment-service :4002
                    │
              Outbox Pattern (ADR-004)
                    │
              Pi Network API
```

**ADR-007 Rule:** If `isHubNavigation() === true` → ALWAYS Mode 1. No exceptions.

```typescript
const isHubNavigation = () =>
  document.referrer.toLowerCase().includes('hub.tecosystem.app')

// Before EVERY Pi payment — mandatory in all 4 apps
if (isHubNavigation() || !window.Pi || !piReady) {
  redirectToHubPayment(amount, memo, productId)
  return
}
```

---

## 7. BACKEND SERVICES MAP

| Service | Port | Role | Owner Entity |
|---------|------|------|------|
| tec-api-gateway | 4000 | Entry point, routing, JWT verify | — |
| tec-auth-service | 4001 | Pi identity, SSO, JWT issuance | Principal, Session |
| tec-payment-service | 4002 | Pi payments, Outbox pattern | Payment |
| tec-commerce-service | 4003 | Orders, products, merchants | Order, Subscription |
| tec-identity-service | 4004 | User profiles, KYC status | Identity |
| tec-kyc-service | 4005 | KYC verification workflow | — |
| tec-asset-service | 4006 | NFT/digital asset management | Asset |
| tec-analytics-service | 4007 | Platform metrics and events | — |
| tec-notification-service | 4008 | Push/email notifications | Notification |
| tec-realtime-service | 4009 | WebSocket events | — |
| tec-storage-service | 4010 | File/media storage (R2) | — |
| tec-wallet-service | 4011 | Pi wallet, balances, ledger | Wallet, LedgerEntry |

**Rule (ADR-005):** Services NEVER exposed directly to internet.
**Rule (ADR-002):** Only `tec-auth-service` verifies Pi identity.
**Rule (ADR-004):** Only `tec-payment-service` calls Pi Network API.

---

## 8. EVENT ARCHITECTURE

```
Service emits event
      │
      ▼
 Redis Streams (shared)
      │
      ▼
Consumer groups (idempotent)
      │
      ├──→ tec-analytics-service  (aggregate metrics)
      ├──→ tec-notification-service (user notifications)
      ├──→ tec-realtime-service   (WebSocket push)
      └──→ tec-wallet-service     (balance updates)
```

**Event naming:** `domain.action.version` — e.g. `payment.completed.v1`
**Required fields:** `eventId, timestamp, actorId, actorType, correlationId, causationId`
**Delivery:** At-least-once → consumers MUST be idempotent

---

## 9. DATA ARCHITECTURE

### Database
- PostgreSQL per service (Railway) — no shared databases (ADR-005)
- `DECIMAL(20,8)` for ALL Pi amounts — stored as string in APIs
- `balance >= 0` enforced at DB constraint level
- Expand-contract migration pattern — never destructive

### Financial Integrity Rules
```
1. Wallet balance NEVER goes negative  (DB constraint)
2. Payment CANNOT complete without approval
3. Every financial action has audit trail
4. Terminal states are FINAL — no transitions from completed/failed/cancelled
5. No state mutation without ActorContext
```

### Consistency Model
| Domain | Consistency | Why |
|--------|-------------|-----|
| Identity reads | **Strong** | Principal must always resolve |
| Wallet balance (write) | **Strong** | Financial accuracy |
| Payment state | **Strong** | State machine integrity |
| Notifications | **Eventual** | Delivery delay acceptable |
| Analytics | **Eventual** | Aggregation tolerates lag |

---

## 10. SECURITY ARCHITECTURE

| Control | Implementation |
|---------|---------------|
| Auth | JWT HS256 — `jwt.verify()` ONLY (never `jwt.decode()`) |
| Inter-service | `x-internal-key: INTERNAL_SECRET` on every call |
| Timing attacks | `timingSafeEqual` for secret comparison |
| CORS | `*.tecosystem.app` only — no wildcard |
| CSRF | Double-submit cookie pattern on all POST/PUT/DELETE |
| Secrets | HttpOnly cookies — NEVER localStorage |
| Infrastructure | API Gateway is the only internet-facing entry point |
| Identity | `userId` ALWAYS from `req.user.id` — NEVER from `body.userId` |
| Docker | Non-root `USER appuser` in all Dockerfiles |

**Policy CI** enforces forbidden patterns on every PR:
- `jwt.decode()` → blocked
- `body.userId` / `body.merchantId` → blocked
- CORS wildcard → blocked
- localStorage tokens → blocked

---

## 11. TECHNOLOGY STACK

| Layer | Technology |
|-------|------------|
| Frontend | Next.js 15 App Router + TypeScript strict |
| Styling | Inline styles (Pi Browser compatible) + CSS tokens |
| Design System | `@yasser172/tec-ui` |
| Auth Package | `@yasser172/tec-auth` |
| BFF SDK | `@yasser172/tec-sdk` |
| Backend | NestJS + TypeScript |
| Database | PostgreSQL (Railway) + Prisma ORM |
| Cache / Events | Redis + Redis Streams |
| File Storage | Cloudflare R2 + CDN |
| Frontend Deploy | Vercel |
| Backend Deploy | Railway |
| Observability | Pino logs + Prometheus (partial) |
| CI | GitHub Actions (path-filtered) |

---

## 12. ARCHITECTURE DECISION RECORDS

| ADR | Decision | Status |
|-----|----------|--------|
| ADR-001 | HttpOnly cookies for auth (httpOnly:false for access token — Pi Browser req.) | ACCEPTED |
| ADR-002 | Dual-Mode Payment (Hub redirect + Direct) | ACCEPTED |
| ADR-003 | FOREIGN_SESSION detection for Pi SDK | ACCEPTED |
| ADR-004 | Outbox Pattern for payment-service | ACCEPTED |
| ADR-005 | BFF Pattern — services not internet-facing | ACCEPTED |
| ADR-006 | SSO redirect to Hub for all apps | ACCEPTED |
| ADR-007 | Pi Payment Ownership Authority (isHubNavigation) | ACCEPTED |

Full ADR details → [`knowledge-base/C-64___ARCHITECTURE_DECISION_RECORDS.md`](../knowledge-base/C-64___ARCHITECTURE_DECISION_RECORDS.md)

---

## 13. PLATFORM EVOLUTION STAGES

```
Stage 1  Multi-App Startup           ✅  COMPLETE
Stage 2  Federated Platform          ◀   CURRENT
Stage 3  Operational Platform            Gate A required
Stage 4  Economic Coordination           Gates B+C+D required
Stage 5  Economic Operating Infrastructure Gate E required
```

### Expansion Gates
| Gate | Requirement | Status |
|------|------------|--------|
| A | tec-ui v1.2.0 + 5+ apps using semantic props | LOCKED |
| B | Event schemas complete + 10k+ active users | LOCKED |
| C | Observability fully operational | LOCKED |
| D | State models audited + 10k events/day | LOCKED |
| E | All A-D + 99.9% reliability (30-day) | LOCKED |

Full maturity model → [`knowledge-base/C-82___PLATFORM_MATURITY_EVOLUTION.md`](../knowledge-base/C-82___PLATFORM_MATURITY_EVOLUTION.md)

---

## 14. FUTURE VISION — TEC AI REASONING INFRASTRUCTURE

> Truth State: [Future Vision] | Gate: D+ | Commitment: [Tentative]

```
TEC AI = Institutional Reasoning Runtime

NOT: an App
NOT: a Domain
NOT: a chatbot
IS:  Cross-layer intelligence that consumes all infrastructure layers

Inputs:
  Economic events from all 12 services
  State from Identity + Reality + Intelligence layers
  Governance rules from SYSTEM layer
  Risk signals from ALERT layer

Outputs:
  Recommendations    → surfaced to human for decision
  Reasoning chains   → explainable, reproducible
  Guidance signals   → to Nexus coordination layer

Constitutional Rules (same as C-84):
  ❌ NEVER execute economic actions
  ❌ NEVER move funds
  ❌ NEVER alter governance rules
  ✅ Every output reproducible from: state + events + rules
  ✅ Human override always available
```

---

## 15. FAILURE DOMAINS

| Domain | Components | Blast Radius | Priority |
|--------|-----------|-------------|----------|
| FD-01 Identity | tec-auth, SSO, Cookies | Platform-wide | P0 |
| FD-02 Economic | Payments, Mode 1/2, Ownership | Economic-wide | P0 |
| FD-03 Pi Runtime | Pi SDK, Pi Browser, Pi API | Platform-wide (external) | P0 |
| FD-04 Federation | Gateway, BFF, Routing | Federation-wide | P1 |

### Controlled Degradation
| Incident | Degraded Mode |
|----------|---------------|
| Pi outage | Force Mode 1 |
| Auth instability | Read-only |
| Event storm | Disable automation |
| Payment latency | Queue approvals |
| Observability outage | Logs-only |

---

## 16. COMPOSABLE SOVEREIGNTY

```
SHARED (platform governs — apps cannot override):
├── Identity API contracts
├── Payment contracts (Dual-Mode, ADR-007)
├── Event schemas (payment.* + user.*)
├── Cookie names and architecture
└── Security policies

SOVEREIGN (each app decides independently):
├── UI/UX design and layout
├── Feature set
├── Internal data models
├── Business logic
└── Deployment timing
```

---

## 17. APP INSTITUTIONAL CHARTERS (C-100→C-115)

Each app has a constitutional document defining its engineering authority, security model, and evolution path. Read the charter before modifying any app.

### Economic System Classification

| System Role | App | Charter | Truth State |
|-------------|-----|---------|-------------|
| System of Access | Hub | C-100 | Current State |
| System of Production | Commerce (Reference Impl) | C-101 | Current State |
| Digital Asset Infrastructure | Assets | C-102 | Current State |
| Consumer Marketplace | Ecommerce | C-103 | Current State |
| System of Reasoning | TEC AI | C-104 | Planned State |
| System of Intelligence | Analytics | C-105 | Planned State |
| System of Record (Personal) | Life | C-106 | Future Vision |
| Economic Relationship Infrastructure | Connection | C-107 | Future Vision |
| Economic Discovery Infrastructure | Explorer | C-108 | Future Vision |
| System of Coordination | Nexus | C-109 | Future Vision |
| System of Governance | SYSTEM | C-110 | Future Vision |
| System of Risk | ALERT | C-111 | Future Vision |
| System of Security | NX | C-112 | Future Vision |
| Capital Coordination Infrastructure | FundX | C-113 | Future Vision |
| Real Estate Coordination | Estate | C-114 | Future Vision |
| System of Construction | DX | C-115 | Future Vision |

### Charter Authority Rule

```
Before modifying any app:
  1. Read the App Institutional Charter (C-100+)
  2. Verify change complies with charter's Authority Boundary
  3. Check P0/P1/P2 engineering gaps — don't duplicate solved patterns
  4. Update charter if new engineering decisions are made

Charter > App CLAUDE.md > Code  (authority order)
```

### Economic Runtime Lifecycle

```
Settlement (Hub/Wallet)
  → Record (Life/Analytics)
    → Reasoning (TEC AI)
      → Access (Hub)
        → Construction (DX)
          → Production (Commerce/Assets/Ecommerce)
            → Economic Activity (Connection/Explorer/FundX/Estate)
              → Settlement (closed loop)
```

---

*Architecture Reference — TEC Platform v3.2.0 — June 2026*
*Owner: Yasser | Yasira82 | @yasser172*
*Authority: C-00 → C-67 → ADRs → App Charters (C-100→C-115) → This Document*
