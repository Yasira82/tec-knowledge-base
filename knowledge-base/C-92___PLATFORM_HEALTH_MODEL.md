# C-92 — PLATFORM HEALTH MODEL

## TEC Ecosystem — Unified Health Definition, Measurement, and Dashboard Specification

> **Truth State:** `[Planned State]` — model defined; runtime implementation pending
> **Governance State:** `[Draft]`
> **Verification:** `[Documentation Verified]`
> **Version:** 1.0 | June 2026
> **Authority Scope:** Platform
> **Relation to C-78:** C-78 = incident response + SLOs. C-92 = what "healthy" means formally, how health is measured continuously, and what a health dashboard must display.

---

## PREAMBLE

```
C-78 answers: "What do we do when something goes wrong?"
C-92 answers: "What does 'healthy' mean, and how do we know when we're there?"

Without C-92:
  - "The platform is healthy" is an assumption, not a measurement
  - Observability is per-service, not system-wide
  - A silent degradation in payment health doesn't surface until users complain
  - Deployment decisions lack health gates

With C-92:
  - Platform health is a verifiable claim at any moment
  - A single composite Health Score drives operational decisions
  - Deployments are gated by health state
  - Incidents are detected before users report them
```

---

## 1. Health Philosophy

### 1.1 Health Is a System Property
No single service is "healthy" in isolation. Platform health is the composite state of all health dimensions interacting.

```
WRONG: "Payment service is up → payments are healthy"
RIGHT: "Payment service is up + Pi Network API responding + wallet integrity intact
        + outbox queue draining + success rate ≥ 95% → payments are healthy"
```

### 1.2 Health Dimensions (5)

```
Dimension 1: Identity Health    — can users authenticate?
Dimension 2: Payment Health     — can Pi transactions complete?
Dimension 3: App Health         — are the 4 apps serving users?
Dimension 4: Service Health     — are the 12 Railway services operational?
Dimension 5: Event Bus Health   — is event delivery functioning?
```

Each dimension has an independent health state. The composite platform health is a function of all 5.

### 1.3 Health ≠ Uptime

```
Uptime:  "Is the service responding to HTTP requests?"
Health:  "Is the service delivering its economic function correctly?"

Example: Auth service returning 200 but issuing malformed JWTs → UP, UNHEALTHY
Example: Payment service responding but success rate = 40% → UP, UNHEALTHY
Example: Gateway responding but INTERNAL_SECRET mismatch → UP, UNHEALTHY
```

---

## 2. Health State Machine

Every health dimension and the platform composite follow this state machine:

```
            ┌──────────────────────────────────────────────────┐
            │                   GREEN                          │
            │  All signals nominal. SLOs met. No alerts.      │
            └──────────────────┬───────────────────────────────┘
                               │
               ┌───────────────▼───────────────┐
               │           DEGRADED            │
               │  One signal outside nominal.  │
               │  SLO approaching breach.      │
               │  Users may notice.            │
               └──────────────┬────────────────┘
                              │
              ┌───────────────▼────────────────┐
              │           CRITICAL             │
              │  SLO breached. Economic        │
              │  function impaired. Users      │
              │  affected. Incident open.      │
              └──────────────┬─────────────────┘
                             │
             ┌───────────────▼──────────────────┐
             │              DOWN                │
             │  Service / dimension completely  │
             │  unavailable. P0/P1 declared.    │
             │  Rollback initiated.             │
             └──────────────────────────────────┘
```

**Transition Rules:**
- GREEN → DEGRADED: Any signal outside nominal range (no manual action yet)
- DEGRADED → CRITICAL: SLO breached OR economic function impaired
- CRITICAL → DOWN: Complete unavailability OR integrity violation detected
- Any state → GREEN: All signals nominal for ≥ 5 minutes sustained

---

## 3. Dimension Definitions

### 3.1 Identity Health

**What it measures:** Can users authenticate, and is the identity layer trustworthy?

| Signal | Healthy | Degraded | Critical |
|--------|---------|----------|----------|
| Auth service response time | < 200ms | 200–500ms | > 500ms |
| JWT issuance success rate | ≥ 99.5% | 99–99.5% | < 99% |
| SSO cookie set rate | ≥ 99.9% | 99–99.9% | < 99% |
| Session refresh success | ≥ 99% | 95–99% | < 95% |
| Pi identity verification | ≥ 99% | 95–99% | < 95% |

**Identity Health = DOWN when:**
```
- tec-auth-service unreachable
- JWT signing key unavailable
- Pi Network identity endpoint unreachable
- REDIS_URL disconnected (session storage lost)
```

**Critical Invariant:** Identity Health CRITICAL or DOWN → ALL other health dimensions inherit CRITICAL minimum. (P6 Fail Closed — no operation without identity)

---

### 3.2 Payment Health

**What it measures:** Can Pi transactions complete successfully and with integrity?

| Signal | Healthy | Degraded | Critical |
|--------|---------|----------|----------|
| Payment success rate (24h) | ≥ 95% | 90–95% | < 90% |
| Payment completion time | < 30s | 30–60s | > 60s |
| Outbox queue depth | < 50 | 50–200 | > 200 |
| Outbox drain rate | ≥ 1/s | 0.5–1/s | < 0.5/s |
| Pi Network API response | < 500ms | 500ms–2s | > 2s or timeout |
| Orphan payments (> 60 min) | 0 | 1–3 | > 3 |

**Payment Health = DOWN when:**
```
- tec-payment-service unreachable
- Pi Network API unreachable (payments cannot settle)
- Outbox worker stopped (queue not draining)
- INTERNAL_SECRET mismatch (all payment calls → 401)
- Wallet balance integrity violation detected
```

**Economic Integrity Signals (zero tolerance):**
```
- Duplicate payment completion: → immediate P0 + DOWN
- Wallet balance < 0:           → immediate P0 + DOWN
- Payment completed without Pi approval: → immediate P0 + DOWN
```

---

### 3.3 App Health

**What it measures:** Are the 4 Vercel apps serving users correctly?

| App | Health Signal | Healthy | Degraded | Critical |
|-----|--------------|---------|----------|----------|
| Hub | Response time | < 500ms | 500ms–2s | > 2s |
| Hub | SSO cookie delivery | ≥ 99.9% | — | < 99.9% |
| Commerce | Page load (P95) | < 1s | 1–3s | > 3s |
| Assets | Page load (P95) | < 1s | 1–3s | > 3s |
| Ecommerce | Page load (P95) | < 1s | 1–3s | > 3s |
| All apps | Error rate (4xx/5xx) | < 1% | 1–5% | > 5% |
| All apps | Vercel deployment | Active | — | Failed/Rolled back |

**App Health = CRITICAL when:**
```
- Hub is DOWN (SSO authority — all apps lose auth)
- Any app returning > 10% 5xx errors
- Any app Vercel deployment failed
```

---

### 3.4 Service Health

**What it measures:** Are the 12 Railway microservices operational?

**Service Tiers (from C-78):**
```
Tier 0 (platform critical): auth, payment, gateway, PAL
Tier 1 (economic critical): identity, wallet
Tier 2 (shared runtime):    analytics, realtime, notification
Tier 3 (domain runtime):    commerce, asset, storage, kyc
```

| Signal per Service | Healthy | Degraded | Critical |
|--------------------|---------|----------|----------|
| HTTP /health endpoint | 200 | 200 (slow) | Non-200 or timeout |
| Response time (P95) | < 200ms | 200–500ms | > 500ms |
| Memory usage | < 80% | 80–90% | > 90% |
| Restart count (24h) | 0 | 1–2 | > 2 |
| INTERNAL_SECRET valid | ✅ | — | ❌ → 401 cascade |

**Service Health = CRITICAL when:**
- Any Tier 0 service DOWN
- INTERNAL_SECRET mismatch on any service (auth cascade failure)
- > 2 restarts in 24h on any Tier 0 service

**Service Health = DOWN when:**
- tec-api-gateway DOWN (all BFF routes fail)
- tec-auth-service DOWN (identity health → DOWN)
- tec-payment-service DOWN (payment health → DOWN)

---

### 3.5 Event Bus Health

**What it measures:** Is the event delivery infrastructure functioning?

*Current State: [Planned State] — event bus architecture defined in C-70; full implementation Phase 1*

| Signal | Healthy | Degraded | Critical |
|--------|---------|----------|----------|
| Event delivery latency | < 100ms | 100–500ms | > 500ms |
| Event delivery success rate | ≥ 99.9% | 99–99.9% | < 99% |
| Dead letter queue depth | 0 | 1–10 | > 10 |
| Consumer lag | < 5s | 5–30s | > 30s |
| Outbox processor uptime | 100% | — | < 100% |

**Event Bus Health = CRITICAL when:**
```
- Dead letter queue growing (events not being consumed)
- payment.completed.v1 events failing to deliver (financial integrity risk)
- Outbox processor down
```

---

## 4. Composite Platform Health Score

The Platform Health Score (PHS) is a single number representing overall platform state.

### 4.1 Dimension Weights

| Dimension | Weight | Rationale |
|-----------|--------|----------|
| Identity Health | 30% | Foundation — no identity = nothing works |
| Payment Health | 30% | Economic core — reason the platform exists |
| Service Health | 20% | Infrastructure backbone |
| App Health | 15% | User-facing experience |
| Event Bus Health | 5% | Eventual consistency layer |

### 4.2 Scoring Formula

```
Dimension Score:
  GREEN    = 100
  DEGRADED = 70
  CRITICAL = 30
  DOWN     = 0

PHS = (Identity × 0.30) + (Payment × 0.30) + (Service × 0.20) + (App × 0.15) + (Events × 0.05)

Example — all healthy:
  PHS = (100×0.30) + (100×0.30) + (100×0.20) + (100×0.15) + (100×0.05) = 100

Example — payment CRITICAL, rest healthy:
  PHS = (100×0.30) + (30×0.30) + (100×0.20) + (100×0.15) + (100×0.05) = 72

Example — identity DOWN:
  PHS = (0×0.30) + (0×0.30) + (70×0.20) + (0×0.15) + (70×0.05) = 21
  (identity DOWN forces payment + app to inherit CRITICAL minimum = 0)
```

### 4.3 PHS Thresholds

| PHS | Platform State | Operational Mode |
|-----|---------------|------------------|
| 90–100 | GREEN | Normal operations |
| 70–89 | DEGRADED | Monitor + investigate |
| 40–69 | CRITICAL | Incident open, mitigate |
| 0–39 | DOWN | P0/P1 declared, rollback |

---

## 5. Health Propagation Rules

Health states propagate through the system per these rules:

```
Rule 1 — Identity Cascade:
  Identity DOWN → Payment, App both inherit CRITICAL minimum (score = 0 for those dims)
  Identity CRITICAL → Payment inherits DEGRADED minimum

Rule 2 — Gateway Cascade:
  Gateway DOWN → Service Health = DOWN (all BFF routes fail)
  Gateway CRITICAL → App Health inherits DEGRADED minimum

Rule 3 — Payment Independence:
  Payment DOWN does NOT affect Identity or App Health directly
  (users can still auth + browse; only checkout fails)

Rule 4 — Event Bus Isolation:
  Event Bus CRITICAL does NOT cascade to synchronous health dims
  (only async flows affected)

Rule 5 — Tier Cascade:
  Any Tier 0 service DOWN → Service Health = CRITICAL minimum
  Multiple Tier 0 services DOWN → Service Health = DOWN
```

---

## 6. Health Gates

Health must be checked at two operational checkpoints:

### 6.1 Deployment Gate

Before ANY production deployment:

```bash
# Pseudo-code — implement as Railway/Vercel pre-deploy hook
if PHS < 80:
  BLOCK deployment — "Platform health below deployment threshold (PHS=$PHS)"
  require manual override with incident number

if PaymentHealth == CRITICAL or DOWN:
  BLOCK — "Payment health critical — no deploys during payment incidents"

if IdentityHealth == CRITICAL or DOWN:
  BLOCK — "Identity health critical — no deploys during auth incidents"
```

### 6.2 Release Chain Gate (C-75)

```
Before publishing tec-sdk / tec-auth / tec-ui:
  PHS must be GREEN (≥ 90) for 30 minutes sustained

Before deploying tec-core-backend:
  Service Health must be GREEN
  Payment Health must be GREEN or DEGRADED (CRITICAL = block)
```

---

## 7. Dashboard Specification

*[Future Vision] — implement as Phase 1 deliverable inside tec-analytics-service or Hub admin panel*

### 7.1 Top-Level View

```
┌─────────────────────────────────────────────────────┐
│  TEC Platform Health                    PHS: 97/100 │
│  ● GREEN — All systems operational      2026-06-15  │
├───────────┬───────────┬──────────┬──────────────────┤
│ Identity  │ Payment   │ Services │ Apps    │ Events  │
│ ● GREEN   │ ● GREEN   │ ● GREEN  │ ● GREEN │ ● GREEN │
│   100     │    98     │   100   │   95    │   100   │
└───────────┴───────────┴──────────┴─────────┴─────────┘
```

### 7.2 Payment Health Panel (most important)

```
Payment Health                                    98/100 ●
─────────────────────────────────────────────────────────
Success Rate (24h):   97.3%  ████████████████████░░ ✅
Outbox Queue:         3      ██░░░░░░░░░░░░░░░░░░░░ ✅
Avg Completion Time:  12s    █████░░░░░░░░░░░░░░░░░ ✅
Orphan Payments:      0      ░░░░░░░░░░░░░░░░░░░░░░ ✅
Pi Network API:       241ms  ████████░░░░░░░░░░░░░░ ✅
─────────────────────────────────────────────────────────
Economic Integrity:   ✅ No violations detected (30d)
```

### 7.3 Identity Health Panel

```
Identity Health                                  100/100 ●
─────────────────────────────────────────────────────────
Auth Response (P95):  87ms   ████░░░░░░░░░░░░░░░░░░ ✅
JWT Issuance Rate:    99.9%  ████████████████████░░ ✅
SSO Cookie Set:       100%   ████████████████████████✅
Session Refresh:      99.8%  ████████████████████░░ ✅
Pi Verification:      99.7%  ████████████████████░░ ✅
```

### 7.4 Service Health Panel

```
Service Health                                   100/100 ●
─────────────────────────────────────────────────────────
TIER 0
  ● tec-api-gateway    :4000  UP    45ms  0 restarts
  ● tec-auth-service   :4001  UP    32ms  0 restarts
  ● tec-payment-service:4002  UP    78ms  0 restarts

TIER 1
  ● tec-identity       :4004  UP    41ms
  ● tec-wallet         :4011  UP    38ms

TIER 2
  ● tec-analytics      :4007  UP    55ms
  ● tec-realtime       :4009  UP    12ms
  ● tec-notification   :4008  UP    29ms

TIER 3
  ● tec-commerce       :4003  UP    62ms
  ● tec-asset          :4006  UP    48ms
  ● tec-storage        :4010  UP    91ms
  ● tec-kyc            :4005  UP    34ms

INTERNAL_SECRET:  ✅ valid on all services
```

### 7.5 Required Dashboard Data Sources

| Panel | Data Source | Implementation |
|-------|-------------|----------------|
| Service health | /health endpoints on each Railway service | Railway health checks + cron ping |
| Payment metrics | tec-payment-service metrics API | tec-analytics-service aggregation |
| Auth metrics | tec-auth-service metrics API | tec-analytics-service aggregation |
| App health | Vercel deployment API + synthetic checks | Vercel webhooks |
| Event bus | Outbox table stats from payment-service | DB query |

---

## 8. Health Monitoring Implementation Path

### Phase 0 (now — manual)
```
□ Each Railway service exposes GET /health → { status, uptime, version }
□ Outbox queue depth exposed via GET /health on payment-service
□ Manual health check before every deployment (use checklist below)
□ INTERNAL_SECRET validation included in /health response
```

### Phase 1 (after Mainnet — automated)
```
□ tec-analytics-service aggregates all /health endpoints every 60s
□ Hub admin panel displays Platform Health Dashboard (Section 7 spec)
□ Railway health check alert → Slack/email notification
□ PHS computed + stored every 60s in analytics DB
□ Deployment gate: check PHS before Vercel build starts
```

### Phase 2 (scale)
```
□ Real-time event bus health monitoring
□ Economic integrity anomaly detection (unusual payment patterns)
□ PHS history graph (7d, 30d trends)
□ Automated P0 detection + on-call paging
```

---

## 9. Manual Health Checklist

*Use this now (Phase 0) before every deployment and after every incident:*

```bash
# Identity Health
□ curl https://hub.tecosystem.app/api/health → 200
□ curl [auth-service]/health → { status: "ok" }
□ Test login with Pi account → SSO cookie set correctly

# Payment Health
□ curl [payment-service]/health → { status: "ok", outboxDepth: N }
□ Check Railway logs: no payment errors in last 60 min
□ Verify INTERNAL_SECRET set: x-internal-key header accepted (no 401s)

# Service Health
□ All 12 Railway services: status = Running (not Crashed/Sleeping)
□ No service restarted in last 24h
□ Gateway /health responding

# App Health
□ hub.tecosystem.app → loads in < 2s
□ ecommerce.tecosystem.app → loads in < 2s
□ assets.tecosystem.app → loads in < 2s
□ tec-commerce-app.vercel.app → loads in < 2s
□ No Vercel deployment failures in last 24h

# Economic Integrity
□ No orphan payments (pending > 60min): check payment-service DB
□ No wallet balance violations: check wallet-service logs
□ Pi Network API: responding (test ping from payment-service)
```

---

## 10. Relation to Other Documents

| Document | Relationship |
|----------|--------------|
| C-78 | C-78 = what to do during incidents. C-92 = how to detect + measure health |
| C-47 (Kernel Spec) | P6 Fail Closed = health enforcement at runtime level |
| C-71 (Financial Integrity) | Economic integrity signals in Payment Health dimension |
| C-70 (Event Governance) | Event Bus Health signals derived from C-70 event model |
| C-75 (Release Governance) | Health gates enforce C-75 deployment rules |
| C-77 (Strategic Risk) | Risk register maps to health dimensions |
| C-104 (TEC AI Charter) | Future: AI-driven anomaly detection on PHS history |
| C-105 (Analytics Charter) | Dashboard implementation lives in Analytics service |

---

*Platform Health Model v1.0 | June 2026*
*Authority: C-00 Platform Constitution → C-78 Operations → C-92 Health (this document)*
*Next Review: After Phase 1 implementation — validate signals against real data*
