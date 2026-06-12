# TEC Platform Architecture

> Truth State: [Current State] — verified against live platform (June 2026)
> Authority: C-00 Platform Constitution + C-67 Source of Truth Matrix
> ADR References: ADR-001 → ADR-007 (C-64)

---

## 1. PLATFORM IDENTITY

```
TEC = Stripe + Tencent + Shopify — inside Pi Network

Not: a super app
Not: a monolithic SaaS
Is:  a Federated Economic Coordination Platform

Core Flow:
  Economic Graph → Identity Graph → Federated Applications → Coordination
```

---

## 2. SYSTEM LAYERS

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

## 3. FEDERATED APP MODEL

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

## 4. IDENTITY & AUTH ARCHITECTURE

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

## 5. PAYMENT ARCHITECTURE (DUAL-MODE)

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

## 6. BACKEND SERVICES MAP

| Service | Port | Role | Owner Entity |
|---------|------|------|--------------|
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

## 7. EVENT ARCHITECTURE

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

## 8. DATA ARCHITECTURE

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

## 9. SECURITY ARCHITECTURE

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

## 10. TECHNOLOGY STACK

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

## 11. ARCHITECTURE DECISION RECORDS

| ADR | Decision | Status |
|-----|----------|--------|
| ADR-001 | HttpOnly cookies for auth (httpOnly:false for access token — Pi Browser req.) | ACCEPTED |
| ADR-002 | Dual-Mode Payment (Hub redirect + Direct) | ACCEPTED |
| ADR-003 | FOREIGN_SESSION detection for Pi SDK | ACCEPTED |
| ADR-004 | Outbox Pattern for payment-service | ACCEPTED |
| ADR-005 | BFF Pattern — services not internet-facing | ACCEPTED |
| ADR-006 | SSO redirect to Hub for all apps | ACCEPTED |
| ADR-007 | Pi Payment Ownership Authority (isHubNavigation) | ACCEPTED |

Full ADR details → [`knowledge-base/C-64___ADR_SYSTEM.md`](../knowledge-base/C-64___ADR_SYSTEM.md)

---

## 12. PLATFORM EVOLUTION STAGES

```
Stage 1  Multi-App Startup           ✅  COMPLETE
Stage 2  Federated Platform          ◀   CURRENT
Stage 3  Operational Platform            Gate A required
Stage 4  Economic Coordination           Gates B+C+D required
Stage 5  Ecosystem Infrastructure        Gate E required
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

## 13. FAILURE DOMAINS

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

## 14. COMPOSABLE SOVEREIGNTY

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

*Architecture Reference — TEC Platform v2.0 — June 2026*
*Owner: Yasser | Yasira82 | @yasser172*
*Authority: C-00 → C-67 → ADRs → This Document*
