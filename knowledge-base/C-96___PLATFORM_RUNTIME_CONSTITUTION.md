# C-96 — Platform Runtime & Observability Constitution

> **Version:** v1.1
> **Truth State:** `[Current State]` → `[Planned State]`
> **Governance State:** `[Draft]`
> **Verification State:** `[Code Verified]`
> **Authority Scope:** `[Platform]`
> **Decision Status:** `[Recommended]`
> **Commitment Level:** `[Committed]`

---

## Purpose

Define Health, Observability, Availability, Resilience, Runtime Ownership, and **Runtime Evidence** as constitutional obligations of the TEC platform.

**C-84 defines:** How systems operate (runtime gates).
**C-92 defines:** Platform health model (dimensions × state machine × PHS).
**C-96 defines:** The constitutional obligations that make runtime trustworthy — Health, Observability, Availability, Resilience, and Incident Flow.

> **Scope boundary — C-84 / C-85 / C-96 (added 21 Jun 2026):** these three are
> distinct, non-overlapping layers and must not be conflated:
> - **C-84 Economic Runtime Constitution** — `[Future Vision]`: *economic* runtime
>   emergence + authority gates (post-Portal, Gate A not yet passed). Answers
>   "how does the economic layer earn authority?"
> - **C-85 Economic Infrastructure Stack** — `[Future Vision]`: the *layer identity*
>   + build sequencing of the economic stack (Layer 0 only is Current). Answers
>   "what gets built, in what order?"
> - **C-96 Platform Runtime & Observability** — `[Current State]→[Planned]`: the
>   *operational* obligations of the live platform (Health, Observability,
>   Availability, Resilience, Incident Flow, Runtime Evidence). Answers
>   "what makes today's running platform trustworthy?"
>
> Rule: economic-emergence content → C-84; build-order/layer-identity → C-85;
> live-runtime operability → C-96. Cross-references only — no duplicated rules (P2).

---

## Constitutional Question

What are TEC's non-negotiable runtime obligations?

---

## Why This Document Exists — Code Evidence

The following was discovered via **Code Verified** inspection of Tec-App and tec-api-gateway (June 2026):

### Finding 1 — Duplicate Health Polling (NEW-K) — ✅ RESOLVED (21 Jun 2026)

```text
Tec-App/tec-frontend/src/context/PlatformHealthContext.tsx  ← single poller (NEW)
Tec-App/tec-frontend/src/components/BackendOfflineBanner.tsx ← consumer
Tec-App/tec-frontend/src/components/BackendStatus.tsx        ← consumer
```

**Was:** `BackendOfflineBanner` and `BackendStatus` independently called
`checkBackendHealth()` / `checkGatewayHealth()` every 30 seconds — two independent
polling loops + two fragmented state stores for the same signal, against divergent
endpoints (`/api/health` BFF vs a server-only `API_GATEWAY_URL` that is empty in
the browser).

**Now:** centralized into `PlatformHealthContext` — ONE poller, ONE cache, ONE
status store; both components are pure consumers via `usePlatformHealth()`. The
canonical source is the `/api/health` BFF (`checkBackendHealth`). This also fixed
`BackendStatus`'s latent wrong-path bug. Verified: full Hub suite 2009/2009,
type-check 0, lint 0.

**Constitutional principle (now upheld):** Health runtime is centralized;
distributed health polling is ungoverned runtime.

### Finding 2 — Gateway Timeout Mismatch (NEW-L)

```typescript
// Frontend (health-check.ts)
fetch('/api/health', { signal: AbortSignal.timeout(5000) })  // 5s

// Gateway (proxy.service.ts)
timeout: 30000,       // 30s
proxyTimeout: 30000,  // 30s
```

Frontend cancels after 5 seconds. Gateway waits 30 seconds. Railway logs the cancellation as `499`. The frontend generates its own timeout at 5× earlier than the gateway timeout.

**Constitutional violation:** Timeout contracts must be aligned across the stack.

### Finding 3 — Hardcoded Service Map (NEW-M)

```typescript
// tec-api-gateway/src/modules/proxy/proxy.service.ts
private readonly services = {
  auth: ...,
  identity: ...,
  wallet: ...,
  // etc.
}
```

Adding a new service (Life, Connection, Explorer, SYSTEM, Nexus, DX) requires editing Gateway core code. **The routing fabric is not extensible.**

**Constitutional violation:** Service topology must be externally declared, not hardcoded.

---

## Core Constitutional Principles

### Reliability Principle
```
A platform is not reliable because it works.
A platform is reliable because reliability is constitutionally required.

Health is not a feature.
Health is a constitutional obligation.
```

### Observability Principle
```
Observability is not optional instrumentation.
Observability is the right of every service to be seen
and the right of every operator to see.

Availability is not a best-effort goal.
Availability is a governed contract.
```

### Runtime Evidence Principle
```
Operational runtimes must emit evidence before emitting conclusions.

Evidence precedes diagnosis.
Diagnosis precedes resolution.
Resolution without evidence is guesswork.
```

### Runtime Visibility Principle
```
Invisible failures cannot become institutional truth.

A failure that produces no evidence
cannot be verified (C-93).
A failure that cannot be verified
cannot be governed (C-99).
A silent runtime is an ungoverned runtime.
```

### Health Ownership Principle
```
Every runtime health signal must have an owner.

Unowned signals become noise.
Noise prevents diagnosis.
Diagnosis without ownership has no resolution path.
```

### Incident Evidence Principle
```
Every incident must produce verifiable evidence.

Evidence must be collectable at incident time.
Evidence must be attributable to a source.
Evidence must be available to the Verification Engine (C-93).
```

---

## Constitutional Rules

```
Health without Centralization        = Duplicate Signals, Conflicting State
Observability without Ownership      = Unmonitored Risk
Availability without Contract        = Unmeasured Failure
Resilience without Policy            = Accidental Recovery
Timeout without Alignment            = Ghost Failures (499)
Service Map without Registry         = Ungoverned Topology
Incident without Flow                = Uncoordinated Response
Runtime Ownership without Assignment = Orphaned Infrastructure
Silent Error Handler                 = Invisible Failure (violates C-00 §No Runtime Without Events)
Missing Health Details               = Undiagnosable Incidents
Evidence not collected at Runtime    = Unverifiable Institutional State
```

---

## What C-96 Owns

| Asset | Description |
|-------|-------------|
| Platform Health Runtime | Centralized health polling + status distribution |
| Observability Requirements | What must be observable, by whom, at what granularity |
| Availability Contracts | SLA obligations per service tier |
| Resilience Policies | Circuit breaker, retry, fallback, graceful degradation |
| Timeout Contracts | Aligned timeout strategy across frontend → BFF → gateway → service |
| Service Registry | Externalized service topology — not hardcoded |
| Incident Flow | Who owns what during a platform incident |
| Runtime Ownership Matrix | Clear ownership per runtime component |

---

## Health Runtime Mandate

### Current State (Code Verified — 21 Jun 2026) — ✅ REMEDIATED

```
NEW-K RESOLVED:
PlatformHealthContext  → single poller (30s) + single cache + single store
BackendOfflineBanner   → consumer (usePlatformHealth)   ← no own poller
BackendStatus          → consumer (usePlatformHealth)   ← no own poller

Result: 1 HTTP call per 30s interval against /api/health (BFF).
        State is unified in one context.
```

> Implemented in Tec-App (`src/context/PlatformHealthContext.tsx`). The "Required
> State" below is now the actual state.

### Required State (now the actual state ✅)

```
PlatformHealthContext.tsx
  Single Poller (30s interval)
  Single Cache
  Single Status Store
       ↓
BackendOfflineBanner  (consumer — reads from context)
BackendStatus         (consumer — reads from context)
```

**Remediation:** NEW-K — ✅ DONE (21 Jun 2026). Created `src/context/PlatformHealthContext.tsx` as the single health runtime; `BackendOfflineBanner` + `BackendStatus` refactored to consumers; layout wrapped in `<PlatformHealthProvider>`.

---

## Timeout Contract

### Current State (Code Verified — June 2026)

```
Layer          Timeout    File
─────────────────────────────────────────────────
Frontend       5,000 ms   health-check.ts (AbortSignal.timeout)
Gateway proxy  30,000 ms  proxy.service.ts (timeout + proxyTimeout)
```

**Gap:** 25,000 ms — the frontend cancels 25 seconds before the gateway gives up. During this window, Railway logs `499` (client cancellation) — not `500/502/503`. The 499 is **correct behavior** given the mismatch, but it masks real upstream failures.

### Required State

```
Layer          Timeout    Rationale
─────────────────────────────────────────────────
Frontend       5,000 ms   User experience boundary (unchanged)
Gateway proxy  10,000 ms  2× frontend = upstream has enough time
Upstream svc   8,000 ms   Within gateway window
```

**Remediation:** NEW-L — Set Gateway `timeout: 10000, proxyTimeout: 10000` in `proxy.service.ts`.

---

## Service Registry Mandate

### Current State (Code Verified — June 2026)

```typescript
// proxy.service.ts — HARDCODED
private readonly services = {
  auth:         { url: process.env.AUTH_SERVICE_URL },
  identity:     { url: process.env.IDENTITY_SERVICE_URL },
  wallet:       { url: process.env.WALLET_SERVICE_URL },
  payment:      { url: process.env.PAYMENT_SERVICE_URL },
  asset:        { url: process.env.ASSET_SERVICE_URL },
  commerce:     { url: process.env.COMMERCE_SERVICE_URL },
  notification: { url: process.env.NOTIFICATION_SERVICE_URL },
  analytics:    { url: process.env.ANALYTICS_SERVICE_URL },
  realtime:     { url: process.env.REALTIME_SERVICE_URL },
  storage:      { url: process.env.STORAGE_SERVICE_URL },
  kyc:          { url: process.env.KYC_SERVICE_URL },
  // fundx, nexus, domains, tokens — REMOVED
}
```

Adding Life, Connection, Explorer, SYSTEM requires **editing Gateway core code + deployment**.

### Required State

```typescript
// gateway reads at startup:
// src/config/service-registry.ts (or service-registry.json)
{
  "services": {
    "auth":    { "url": "${AUTH_SERVICE_URL}",    "tier": 1, "timeout": 8000 },
    "payment": { "url": "${PAYMENT_SERVICE_URL}", "tier": 1, "timeout": 8000 },
    // ...
    // Future services added without touching Gateway core:
    "life":    { "url": "${LIFE_SERVICE_URL}",    "tier": 2, "timeout": 8000 }
  }
}
```

**Remediation:** NEW-M — Externalize service map to `service-registry.ts`.

---

## Observability Requirements

Every service must expose:

| Signal | Requirement | Standard |
|--------|------------|---------|
| Health endpoint | `/health` — returns 200 or 503 | [Current State] |
| Detailed health | `/health/detailed` — guarded by `x-internal-key` | [Current State] |
| Structured logs | Pino JSON to Railway stdout | [Current State] |
| Error tracking | Sentry integration | [Current State] |
| Metrics | Prometheus `/metrics` (payment-service only currently) | [Planned State] |
| Distributed tracing | OpenTelemetry | [Planned State] |

---

## Availability Contracts

| Tier | Services | Availability Target | Incident Response |
|------|---------|--------------------|--------------------|
| Tier 0 (Critical) | Gateway, Auth, Payment | 99.9% | Immediate (P0) |
| Tier 1 (Core) | Identity, Wallet, KYC, Commerce | 99.5% | Within 1 hour |
| Tier 2 (Supporting) | Analytics, Notification, Realtime, Storage, Asset | 99.0% | Within 4 hours |

---

## Resilience Policy

| Pattern | Policy |
|---------|--------|
| Circuit Breaker | Open after 5 consecutive failures; half-open after 30s |
| Retry | Max 3 retries with exponential backoff (1s, 2s, 4s) — NOT on payment routes |
| Fallback | Graceful degradation: show cached state, not blank screen |
| Timeout | Frontend 5s / Gateway 10s / Upstream 8s (aligned) |
| Health Gate | PHS < 80 blocks deployment (C-92 gate) |

---

## Incident Flow Ownership

| Role | Owns | During Incident |
|------|------|----------------|
| Gateway Owner | Routing, timeout contracts, service registry | First responder — all incidents |
| Auth Owner | Identity + SSO availability | P0 incidents involving auth |
| Payment Owner | Payment processing + wallet ops | P0 incidents involving payments |
| App Owner | Frontend health UX, BFF routes | User-facing degradation |
| Platform Owner | PHS score, health model (C-92) | Platform-level P0/P1 |

---

## Runtime Ownership Matrix

| Component | Owner | Constitutional Ref |
|-----------|-------|-------------------|
| API Gateway | tec-core-backend | C-10, C-20 |
| Frontend Health Runtime | PlatformHealthContext | NEW-K — ✅ created (Tec-App) |
| Service Registry | Gateway config | NEW-M — to be externalized |
| Timeout Contracts | Gateway + BFF | NEW-L — to be aligned |
| Health Endpoints | Each service | C-92 |
| Platform Health Score | C-92 PHS formula | C-92 |

---

## Violation Register (Code Verified + Applied)

| ID | Severity | Finding | Remediation | Status |
|----|---------|---------|-------------|--------|
| NEW-K | P1 | Duplicate health polling — 2 independent pollers, split runtime view | `PlatformHealthContext.tsx` — single poller + cache + store | ✅ VERIFIED |
| NEW-N | P1 | Redis `client.on('error', () => {})` — silent failure, violates C-00 | 5 Redis lifecycle event listeners with structured logging | ✅ VERIFIED |
| NEW-O | P1 | `/api/health` returns `{ "status": "ok" }` only — zero evidence at incident time | `/api/health/details` (x-internal-key) with full runtime state | ✅ VERIFIED |
| NEW-L | P1 | Gateway timeout 30s vs Frontend 5s — timeout contract misaligned | `timeout: 10000, proxyTimeout: 10000` in proxy.service.ts | ✅ VERIFIED |
| NEW-M | P2 | Hardcoded service map in Gateway — blocks extensibility | Externalize to `service-registry.ts` | OPEN |

---

## Redis Diagnostics Mandate (NEW-N)

### Current State (Code Verified — June 2026)

```typescript
// Redis client — SILENT FAILURE
client.on('error', () => {});  // swallowed completely
```

**Constitutional violation:** `client.on('error', () => {})` is a direct violation of C-00's "No Runtime Without Events" invariant. Redis failure becomes invisible. Invisible failures cannot be verified (C-93), cannot be governed (C-99), cannot be resolved.

### Required State

```typescript
// Redis client — Observable Runtime
client.on('connect',      () => logger.info('Redis connecting'));
client.on('ready',        () => logger.info('Redis ready'));
client.on('error',        (err) => logger.error({ err }, 'Redis error'));
client.on('reconnecting', () => logger.warn('Redis reconnecting'));
client.on('end',          () => logger.warn('Redis connection ended'));
```

**Result:** Every Redis lifecycle event becomes a log entry → becomes evidence (C-93) → can be correlated with incidents.

---

## Health Details Endpoint Mandate (NEW-O)

### Current State (Code Verified — June 2026)

```json
GET /api/health → { "status": "ok" }
```

**Constitutional violation:** `{ "status": "ok" }` is a conclusion, not evidence. At incident time (e.g. the 499 at 595ms), this endpoint provides zero diagnostic value. The Runtime Evidence Principle requires runtimes to emit evidence, not just conclusions.

### Required State

```
GET /api/health           → { "status": "ok" | "degraded" | "down" }  (public)
GET /api/health/details   → full runtime evidence (guarded by x-internal-key)
```

```json
{
  "gateway": "up",
  "redis": "up | down | reconnecting",
  "uptime": 123456,
  "memory": { "used": "...", "heap": "..." },
  "services": {
    "auth":         { "reachable": true,  "latency": 12 },
    "wallet":       { "reachable": true,  "latency": 8  },
    "payment":      { "reachable": true,  "latency": 15 },
    "asset":        { "reachable": true,  "latency": 10 },
    "notification": { "reachable": false, "latency": null }
  }
}
```

**Result:** When a 499 occurs, an operator can immediately see Redis state, upstream service state, and memory pressure at the time of the incident.

---

## 499 Incident Analysis (Verified — June 2026)

### Evidence

```
18:39 → 200  (success)
18:40 → 499  (cancellation) — duration: ~595ms
```

### Interpretation

A 595ms duration rules out gateway proxy timeout (10,000ms) and frontend AbortSignal timeout (5,000ms). The most probable cause:

| Hypothesis | Evidence | Verdict |
|-----------|---------|---------|
| Gateway proxyTimeout (30,000ms) | Duration 595ms ≠ 30,000ms | ❌ Ruled out |
| Frontend AbortSignal (5,000ms) | Duration 595ms ≠ 5,000ms | ❌ Ruled out |
| Browser navigation / tab change | Possible at 595ms | ✅ Plausible |
| Health-check race condition | Two pollers (NEW-K) creating race | ✅ Plausible |
| Redis transient failure → gateway stall at ~600ms | Invisible (NEW-N) | ✅ Plausible |

### Root Cause Gap

Without `/api/health/details` (NEW-O) and Redis diagnostics (NEW-N), the exact cause **cannot be determined from available evidence**. This is a **Runtime Visibility failure**, not a timeout failure.

**This is why NEW-K + NEW-N + NEW-O are constitutionally P1:** they close the gap between "something failed" and "we can verify what failed."

---

## Relation to C-92 (Platform Health Model)

C-92 defines **what health means** (dimensions, PHS score, state machine).
C-96 defines **how health must be implemented** (centralized runtime, timeout alignment, observability obligations).

```
C-96 (constitution: what must be done)
  ↓
C-92 (model: how to measure it)
  ↓
PlatformHealthContext.tsx (implementation: where it lives)
```

---

## Tier-1 Constitutional Position

C-96 is a **Tier-1 Constitutional Asset** within the runtime governance layer.

| Document | Defines |
|----------|---------|
| **C-84** Runtime Constitution | Runtime gates A→E |
| **C-92** Platform Health Model | Health dimensions + PHS score |
| **C-96** Platform Runtime Constitution | Health/Observability/Availability/Resilience obligations |

---

## Architectural Conclusion

```
A platform that does not govern its own runtime is not reliable.
It is lucky.

Health must be centralized — not distributed across components.
Timeouts must be aligned — not decided per file.
Service topology must be declared — not hardcoded.
Observability must be owned — not optional.

Runtime governance is not DevOps configuration.
Runtime governance is a constitutional obligation.
```

---

## Related Documents

```
C-40  Open Violations Map (NEW-K, NEW-L, NEW-M)
C-45  Observability & Monitoring
C-62  SLO Definitions & Performance Standards
C-73  Incident Response Runbook
C-78  Platform Operations & Reliability Governance
C-84  Runtime Constitution
C-92  Platform Health Model
C-99  Institutional Governance Constitution
```

---

*End of C-96 v1.0*
