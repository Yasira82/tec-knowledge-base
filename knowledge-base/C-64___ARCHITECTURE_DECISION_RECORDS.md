# C-64 — ARCHITECTURE DECISION RECORDS

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

## ADR Index + 8 Core Decisions

Why do ADRs exist?
Every unconventional architectural decision needs a formal written justification.
An external auditor sees httpOnly:false → "bug"
An external auditor sees ADR-001 → "intentional — justified"
The difference: -0.5 points vs +0.2 points in the score.

## ADR LIFECYCLE

```
PROPOSED → ACCEPTED → DEPRECATED
⚠️ ACCEPTED = لا يُعاد النقاش فيه إلا بـ ADR جديد
```

## INDEX

| ADR | Title | Status |
|-----|--------|--------|
| ADR-001 | httpOnly:false on tec_access_token | ACCEPTED |
| ADR-002 | Dual-Mode Payment Architecture | ACCEPTED |
| ADR-003 | FOREIGN_SESSION Detection Pattern | ACCEPTED |
| ADR-004 | BFF-Only Architecture | ACCEPTED |
| ADR-005 | Redis Streams over Kafka/RabbitMQ | ACCEPTED |
| ADR-006 | CSRF Exclusion on Payment BFF Routes | ACCEPTED |
| ADR-007 | Pi Payment Ownership Authority | ACCEPTED (details in C-76) |
| ADR-008 | Runtime Observability Architecture | ACCEPTED (June 2026) |
| ADR-009 | Unified Payment Contract (Single Source of Truth) | ACCEPTED (June 2026) |
| ADR-010 | NX repurposed → Opportunity Exchange · Security Governance folded into System | ACCEPTED (July 2026) |
| ADR-011 | Modules-First — Service Extraction & Modular Architecture Policy | ACCEPTED (July 2026 · details in C-132) |
| ADR-012 | Referral Rewards = Gift Subscription (raw-Pi bonus hard-gated) | ACCEPTED (July 2026) |

---

## ADR-001 — httpOnly:false on tec_access_token

**Status:** ACCEPTED | **Date:** April 2026

**Context:** Pi Browser is a WebView — the Pi SDK needs to read the token from `document.cookie`

**Decision:** `tec_access_token` is set with `httpOnly: false`

**Managed risks:**
- CSRF double-submit protection
- CSP + HTTPS + Token TTL 24h
- tec_refresh_token = httpOnly:true, always

**Rejected alternatives:** httpOnly:true → Pi Browser cannot read it | localStorage → blocked by Policy CI

---

## ADR-002 — Dual-Mode Payment Architecture

**Status:** ACCEPTED | **Date:** April 2026

**Context:** Pi.createPayment() only works if Pi.init() ran on the same domain. If a user came from Hub → the app cannot run Pi.init() again.

**Decision:** every app supports two modes:

- **Mode 1 — Hub Redirect:** app → `hub.tecosystem.app/hub?pay=1&...` → Hub runs Pi.createPayment()
- **Mode 2 — Direct Payment:** Pi.init() on the app's domain → Pi.createPayment() directly

**Constitutional rules:**
- ✅ Every app must support Mode 1 (Hub fallback) — mandatory
- ✅ Commerce = Reference Implementation
- ❌ An app with only one mode = P1 violation

---

## ADR-003 — FOREIGN_SESSION Detection Pattern

**Status:** ACCEPTED | **Date:** April 2026

**Context:** Pi Browser makes every app share the same Pi session.

**Decision:** `window.__TEC_PI_FOREIGN_SESSION = true` when Pi.init() throws "already initialized".

**Fixed rule:**
❌ NEVER block a payment because FOREIGN_SESSION=true — Pi.createPayment() works in both cases

---

## ADR-004 — BFF-Only Architecture

**Status:** ACCEPTED | **Date:** March 2026

**Context:** Railway URLs must be hidden from the client.

**Decision:** Client Components → /api/* (BFF) → API Gateway → Services

```typescript
const GW = process.env.API_GATEWAY_URL;              // ✅ server-only
const GW = process.env.NEXT_PUBLIC_API_GATEWAY_URL;  // ❌ violation NEW-A
```

---

## ADR-005 — Redis Streams over Kafka/RabbitMQ

**Status:** ACCEPTED | **Date:** March 2026

**Context:** A distributed event bus is needed. Redis already exists.

**Decision:** Redis Streams (XADD/XREADGROUP/XACK)

**Reasons:** Zero additional infrastructure + At-least-once delivery + Message persistence

⚠️ Kafka to be reconsidered after 100k+ active users

---

## ADR-006 — CSRF Exclusion on Payment BFF Routes

**Status:** ACCEPTED | **Date:** April 2026

**Context:** Payment callbacks from the Pi SDK do not support CSRF headers.

**Decision:** `CSRF_EXCLUDED = ['/api/bff/payment/']`

**Justification:** JWT verification in every route + Idempotency-Key prevents replay + HTTPS only

**Fixed rule:** ✅ Every BFF payment route must verify the JWT — mandatory

---

## ADR-008 — Runtime Observability Architecture

**Status:** ACCEPTED | **Date:** June 2026 | **Verification:** `[Code Verified]`

**Context:**
A Code Verified inspection of Tec-App and tec-api-gateway (June 2026) found 3 structural problems:

1. `BackendOfflineBanner` and `BackendStatus` each ran their own health polling every 30s → Split Runtime View
2. `client.on('error', () => {})` in the Redis client → Silent Failures, a direct breach of C-00 "No Runtime Without Events"
3. `GET /api/health` returns only `{ "status": "ok" }` → no runtime evidence when incidents happen

**Decisions:**

### ADR-008a — Centralized Health Runtime

```typescript
// REJECTED: distributed polling
BackendOfflineBanner polls independently   ❌
BackendStatus polls independently          ❌

// ACCEPTED: centralized context
src/context/PlatformHealthContext.tsx      ✅
  Single Poller (30s) → Single Cache → Single Status Store
  BackendOfflineBanner reads from context  ✅
  BackendStatus reads from context         ✅
```

**Justification:** Distributed pollers create a Split Runtime View — one part of the UI believes the backend is online and another believes it is offline at the same moment.

### ADR-008b — Redis Observable Lifecycle

```typescript
// REJECTED: silent error handler
client.on('error', () => {});  ❌

// ACCEPTED: observable lifecycle
client.on('connect',      () => logger.info('Redis connecting'));   ✅
client.on('ready',        () => logger.info('Redis ready'));        ✅
client.on('error',        (err) => logger.error({ err }, '...'));  ✅
client.on('reconnecting', () => logger.warn('Redis reconnecting')); ✅
client.on('end',          () => logger.warn('Redis ended'));        ✅
```

**Justification:** Silent error handlers prevent verification (C-93). Invisible failure = ungoverned runtime (C-96).

### ADR-008c — Runtime Evidence Endpoint

```
// REJECTED: conclusion-only
GET /api/health → { "status": "ok" }  ❌

// ACCEPTED: evidence-first
GET /api/health          → { status }                    ✅ (public)
GET /api/health/details  → full runtime state            ✅ (x-internal-key)
  { gateway, redis, uptime, memory, services: { auth, wallet, payment... } }
```

**Justification:** `{ "status": "ok" }` is a conclusion, not evidence. C-93 requires evidence to establish institutional state. Without `/health/details`, incidents cannot be diagnosed or verified.

### ADR-008d — Timeout Contract

```
// REJECTED: misaligned
Frontend: AbortSignal.timeout(5000)   →  Gateway: timeout: 30000  ❌

// ACCEPTED: aligned stack
Frontend:  5,000 ms (user experience boundary — unchanged)
Gateway:  10,000 ms (2× frontend — upstream has enough time)
Upstream:  8,000 ms (within gateway window)
```

**Justification:** 25,000ms gap causes Railway to log 499 (client cancellation) instead of 500/502/503. The 499 at 595ms during incidents is a Runtime Visibility failure caused by missing observability — not a timeout failure.

**Constitutional rules (enforced by Policy CI):**
- ❌ FORBIDDEN: `client.on('error', () => {})` — empty error handlers on critical clients
- ❌ FORBIDDEN: Health endpoints that return conclusions without evidence
- ✅ REQUIRED: Centralized health runtime — no distributed polling of the same signal
- ✅ REQUIRED: Timeout alignment across frontend → gateway → upstream

**Open violations:** NEW-K, NEW-N, NEW-O, NEW-L in C-40

**References:** C-96 Platform Runtime & Observability Constitution

---

## ADR-007 — Pi Payment Ownership Authority

**Status:** ACCEPTED — full details in C-76

---

## ADR-009 — Unified Payment Contract (Single Source of Truth)

**Status:** ACCEPTED | **Date:** June 2026
**Repos:** tec-sdk (owner) · tec-app · tec-ecommerce · tec-assets · tec-commerce · tec-core-backend (reference)
**Severity:** P1 | **Extends:** ADR-002 (Dual-Mode Payment), ADR-004 (BFF-Only)

**Context (root cause):**
After the hardening audit, a **parallel payment stack** emerged, different from the legacy one. Each app
defined the payment contract itself, so it drifted on 3 axes and caused repeated payment failures (fixing one
app did not fix the others):

| Axis | Observed drift | Correct (source of truth = tec-payment-service) |
|--------|------------------|------------------------------------------|
| `amount` | Some `string` (Zod `z.string()`), some `number` | **`number`** — DECIMAL in the DB |
| Internal header | `x-service-secret` / `SERVICE_SECRET` in `bffFetch` | **`x-internal-key` / `INTERNAL_SECRET`** only |
| Gateway path | `/api/v1/payments/*` · bare `/payments` (404 on a raw host) | **`/api/payment/*`** (clean rewrite `^/api/payment → /payments`) |

This directly violates **C-47**: P1 (Single Source of Truth) · P2 (No Rule Duplication)
· Forbidden #5 (Divergent SDK contracts vs backend).

**Decision:**
The payment contract is defined **once** in `@yasser172/tec-sdk` and imported in every BFF route:
- `src/contracts/payment.ts` → `CreatePaymentRequestSchema` · `ApprovePaymentRequestSchema`
  · `CompletePaymentRequestSchema` · `PAYMENT_GATEWAY_PATHS` · `INTERNAL_KEY_HEADER`
  · Pi id/txid format guards.
- `amount` = `z.coerce.number()` — converted from a string **once, at the BFF boundary**;
  a number in every layer below it (P5).

**Fixed rules (to be enforced by Policy CI later):**
- ❌ FORBIDDEN: defining a payment Zod schema locally inside any app (it must be imported from tec-sdk).
- ❌ FORBIDDEN: `x-service-secret` / `SERVICE_SECRET` in any gateway call.
- ❌ FORBIDDEN: sending `amount` as a string to any payment endpoint.
- ✅ REQUIRED: `/api/payment/*` paths (singular) for every call to the gateway.

**Justification:** one contract = one fix. It closes the whole class of bug instead of patching a copy in every repo,
and is consistent with P5 (SDK = the contracts layer) and C-41 (tec-ui v1.2.0 PaymentModal/createU2APayment
built on the same contract).

**Rollout plan (release chain):**
`tec-core-backend → tec-sdk@1.3.0 (contract published) → tec-ui v1.2.0 → the 4 apps (simultaneous deploy)`.
Apps replace their local Zod with an import from tec-sdk once 1.3.0 is published on npm.

**References:** C-12 Dual-Mode Payment · C-76 ADR-007 · C-47 §14 SDK Contract Rules
---

## ADR-010 — NX repurposed → Opportunity Exchange · Security Governance → System

**Status:** ACCEPTED | **Date:** July 2026 | **Decision Authority:** CEO (C-47)

### Context
C-112 originally defined **NX = Cyber Security** (System of Security). But the platform
already has three institutions that overlap that space, causing role confusion:
- **System (C-110)** — platform operations + governance + runtime.
- **Alert (C-111)** — the notification/incident surface (security/fraud/risk *alerts*).
- **Zone (C-120)** — verification + trust + evidence + reputation.

Separately, there was **no home** for a first-class "Opportunity Exchange" (jobs,
partnerships, grants, hackathons, investments, co-founders, mentorship) — the single
biggest missing value for the Pi community (no unified opportunity marketplace exists).

### Decision
1. **NX is repurposed to `Network / Opportunity Exchange`** — connecting people to
   opportunities ("What is the right opportunity for me now?"). It is NOT a security app.
2. **Cyber-security is NOT a standalone app (now).** Its runtime functions
   (threat detection, security audit, access logs, device management, incident response)
   are folded into **System as a "Security Center" / Security Governance** — consistent
   with System being the operations + governance runtime. (If security ever becomes a
   standalone product for the wider Pi community, it gets its OWN new domain — e.g.
   `sentinel.pi` — but **never** the `NX` slug.)
3. Security **alerts** remain in **Alert** (the surface); **enforcement/response** is a
   System Security-Center concern; **verification/trust** stays in **Zone**.

### Consequences
- **C-112** is superseded on its *domain* (Security → Opportunity Exchange). Its useful
  security concepts move to System's Security-Center scope, not deleted.
- **C-110 (System)** scope gains **Security Governance** (Security Center).
- No overlap remains: Hub=identity · Life=personal · Connection=relationships ·
  Zone=verification · Analytics=insight · TEC AI=reasoning · Nexus=orchestration ·
  System=operations+security governance · Alert=notifications · **NX=opportunity**.
- Downstream refs that read "NX → security violation signals" (C-110 §12 inbound) now
  read "Security Center (in System) + Alert" instead of NX.

**References:** C-110 SYSTEM · C-111 ALERT · C-112 NX (superseded domain) · C-120 ZONE

---

## ADR-011 — Modules-First — Service Extraction & Modular Architecture Policy

**Status:** ACCEPTED — full details in **C-132** | **Date:** July 2026 | **Decision Authority:** CEO (C-47)

### Context
TEC has **24 apps**. The default reflex "1 app = 1 microservice" would create 24
deploys / 24 databases / 24 points of failure long before the load justifies even a
handful — an unrecoverable ops mistake for a pre-scale platform on Pi Network.

### Decision
The correct layering is **App → Domain Module → Service**, not App → Microservice:
1. **Modules-First** — a new domain's backend ships as a **module inside an existing
   service** by default (proven: Life / Connection / Zone are modules in
   `tec-identity-service`). A new service requires a **documented extraction trigger**.
2. **Extraction triggers (T1–T4)** — extract only on a real production signal:
   different scaling profile · different consistency/security boundary · independent
   deploy cadence · different team ownership. "Has business logic" is not a trigger.
   *(extract-on-load, not extract-on-imagination.)*
3. **Design-for-Extraction** — a known future-service candidate (Explorer → Search)
   gets a clean seam from day one (own folder, namespaced tables, no cross-module DB
   joins) so extraction is mechanical.
4. **Financial Hard-Gate** — `tec-payment-service` is the **only** Pi custodian
   (Invariant #8), at any scale. FundX / Insure / Brookfield are state+workflow
   modules that issue intents; they get **no custody service of their own**.
5. **Target service count now = the 11 live services — unchanged.** Every other
   domain is a module or a frontend until §5 (C-132) fires.

### Consequences
- A PR that creates a new backend service must cite its T1–T4 trigger, or it is rejected.
- Extraction is a **deployment** change, never an **ownership** change (C-68 owner +
  C-70 event contract preserved).
- Explorer is the designated first extraction candidate (→ `search-service`).

**References:** C-132 (full detail) · C-47 (Invariant #8, P5) · C-68 (Domain Ownership) ·
C-70 (Event Governance) · C-113 FundX · C-129 Insure · C-108 Explorer

---

## ADR-012 — Referral Rewards = Gift Subscription (raw-Pi bonus hard-gated)

**Status:** ACCEPTED | **Date:** July 2026 | **Decision Authority:** CEO (C-47) | **Extends:** C-133 (Growth Governance)

### Context
A referral / invite program (à la Binance/OKX) is the natural amplifier for the
existing **Founding-Pioneer** growth funnel (C-133). The tempting design — pay the
referrer a **Pi cash bonus** — is a trap on this platform: a raw-Pi payout is
**capital movement**, and under the Kernel Spec **`tec-payment-service` is the only
Pi custodian** (Invariant #8). A Pi giveaway also carries promotions/lottery
regulatory exposure and is trivially **sybil-farmable** (mass-register → self-refer).

### Decision
1. **Reward = a gift SUBSCRIPTION month, never raw Pi.** The referrer and the
   referee each receive a **+30-day PRO** entitlement. No Pi is moved → no custody,
   no legal gate. Gifting a FREE user makes them PRO; stacking on a paid user extends
   `current_period_end` (never a downgrade).
2. **Reward on OUTCOME, not signup.** The reward fires only on the **referee's first
   paid subscription** — so an account with no economic action earns nothing. Mirrors
   Legend's "records outcomes, not claims" (C-126).
3. **Idempotent, once-only.** Attribution is `PENDING → REWARDED` via an **atomic
   claim**; an upgrade / re-subscribe can never double-reward. A user can be referred
   **at most once** (unique referee).
4. **Owned by `tec-commerce-service`.** The reward *is* a subscription extension, so
   the whole loop (code · attribution · grant) stays atomic in the service that owns
   `Subscription` — no cross-service call. Identity is derived from the verified JWT,
   never the request body (P6).
5. **Raw-Pi cashback is HARD-GATED** (future, not built): it may not ship until it
   clears the same P0 gates as FundX/Insure custody — **legal review + payment-service
   custody + SYSTEM governance + anti-fraud** (C-113 / C-129 pattern).

### Consequences
- A PR that pays a referral bonus in Pi (or moves Pi outside payment-service for
  growth) is rejected — it must cite the three P0 gates first.
- The reward path is fail-safe: `subscription.subscribe()` grants the referral bonus
  in a `try/catch`, so a referral hiccup never breaks the (financial) payment path.
- Three entry points, one attribution: the animated **Invite & Earn** carousel slide,
  the **🎁 Invite** Hub tool, and any **`?ref=` invite link** captured before login
  (applied automatically on first authentication).

**Implementation:** `tec-commerce-service` referral module (`commerce/referral` — `GET /me`,
`POST /attribute`) + `ReferralCode` / `ReferralAttribution` (Prisma); Hub `/hub/referral`
+ `/api/referral` BFF + global `?ref` capture. See C-133 §Referral Program.

**References:** C-133 (Growth Governance) · C-47 (Invariant #8 custody, P6) · C-113 FundX
(hard-gate pattern) · C-126 Legend (outcome-not-claim) · C-68 (commerce ownership)

---

## ADR-013 — Legend Scoring Contract (Analytics computes · Legend serves)

**Status:** ACCEPTED | **Date:** July 2026 | **Decision Authority:** CEO (C-47) | **Extends:** C-105 (Analytics) · C-126 (Legend) · C-127 (Elite)

### Context
The reputation value chain (Epic/Zone → Legend → Elite → VIP) shipped, but the
**score-based** Elite programs (TOP_MERCHANT/CREATOR/INVESTOR/BUILDER/COMMUNITY) were
**dormant**: they grant on `LegendProfile.score_*`, and nobody computed those — they
defaulted to `0`. C-126 is explicit that **Legend never computes a score** (it serves a
projection Analytics refreshes), and C-105 assigns intelligence/computation to Analytics.
So the missing piece is a **scoring contract** between the two services — and *where* it
runs + *who writes* the result is an architectural decision (Invariant #8: each entity has
exactly one owning service; `LegendProfile` is Legend's).

### Decision
1. **Analytics COMPUTES from its OWN data.** Scores are derived in `tec-analytics-service`
   from its `AnalyticsEvent` log — **no cross-service DB read** of Legend's tables. To have
   the signals, the Analytics consumer ingests the reputation-dimension events
   (`order.paid.v1` → merchant · `epic.project.completed.v1` → creator · `zone.badge.issued.v1`
   → builder · `connection.milestone.v1` → collaborator), attributed to the Pi-username owner.
2. **ABSOLUTE scoring, not percentile.** A fixed, published count→score curve (monotone,
   bounded `[0,100]`); `overall` = mean of the five dimensions. A recognition is **earned
   against a stable bar** (C-127), not relative to how active everyone else happens to be.
   Changing the curve is an ADR-013 change (it is the criteria bar).
3. **`investor` scores 0 until FundX exists.** Its only signal (`fundx.investment.closed.v1`)
   is hard-gated (C-113) — the dimension is dormant by design, **never faked**.
4. **Legend OWNS the write (Invariant #8 / C-126).** Analytics emits
   **`legend.scores.updated.v1`** (owner + the six scores); `LegendService.updateScores`
   writes `LegendProfile` (clamped, idempotent). Analytics never writes identity-service's DB.
5. **Elite re-evaluates on score change.** The Legend scores-consumer, after applying,
   triggers `elite.evaluateOwner` — a score crossing a threshold grants/adjusts recognition
   (GOLD/PLATINUM still gated to a human PANEL, C-127).
6. **Cadence = daily batch** over recently-active users — matches Analytics = **eventual
   consistency** (C-47 §Consistency); never used for a financial mutation.

### Consequences
- A PR that computes a Legend score inside Legend, or writes `LegendProfile` from another
  service, is rejected (violates C-126 / Invariant #8).
- Scores are **forward-looking**: they accrue as `AnalyticsEvent` collects activity after
  deploy. A historical backfill is a later refinement, not V1.
- V1 grants on **one metric per program**; richer multi-signal composites (weighting, decay)
  are a later ADR-013 revision as Analytics matures.

**Implementation:** `tec-analytics-service` `modules/scoring/*` (pure curve + `computeScoresForUser`
+ daily `runScoringBatch`) + `events/emit.ts` + dimension ingest consumers;
`tec-identity-service` `LegendService.updateScores` + `modules/legend/scores-updated.consumer.ts`.
Event: `legend.scores.updated.v1` (see `manifests/events-catalog.yaml`). tec-core-backend #160.

**References:** C-105 (Analytics — intelligence/computation) · C-126 (Legend — serves, never computes)
· C-127 (Elite — criteria over scores) · C-47 (Invariant #8, eventual consistency) · C-70 (event law)
