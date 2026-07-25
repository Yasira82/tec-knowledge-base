# C-64 — ARCHITECTURE DECISION RECORDS

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

## ADR Index + 8 Core Decisions

ليه ADRs موجودة?
كل قرار معماري غير تقليدي لازم يكون مبرر رسمي مكتوب.
External auditor يشوف httpOnly:false → "bug"
External auditor يشوف ADR-001 → "intentional — مبرر"
الفرق: -0.5 نقطة vs +0.2 نقطة في الـ score.

## ADR LIFECYCLE

```
PROPOSED → ACCEPTED → DEPRECATED
⚠️ ACCEPTED = لا يُعاد النقاش فيه إلا بـ ADR جديد
```

## INDEX

| ADR | العنوان | Status |
|-----|--------|--------|
| ADR-001 | httpOnly:false على tec_access_token | ACCEPTED |
| ADR-002 | Dual-Mode Payment Architecture | ACCEPTED |
| ADR-003 | FOREIGN_SESSION Detection Pattern | ACCEPTED |
| ADR-004 | BFF-Only Architecture | ACCEPTED |
| ADR-005 | Redis Streams over Kafka/RabbitMQ | ACCEPTED |
| ADR-006 | CSRF Exclusion على Payment BFF Routes | ACCEPTED |
| ADR-007 | Pi Payment Ownership Authority | ACCEPTED (تفاصيل في C-76) |
| ADR-008 | Runtime Observability Architecture | ACCEPTED (June 2026) |
| ADR-009 | Unified Payment Contract (Single Source of Truth) | ACCEPTED (June 2026) |
| ADR-010 | NX repurposed → Opportunity Exchange · Security Governance folded into System | ACCEPTED (July 2026) |
| ADR-011 | Modules-First — Service Extraction & Modular Architecture Policy | ACCEPTED (July 2026 · تفاصيل في C-132) |
| ADR-012 | Referral Rewards = Gift Subscription (raw-Pi bonus hard-gated) | ACCEPTED (July 2026) |

---

## ADR-001 — httpOnly:false على tec_access_token

**Status:** ACCEPTED | **Date:** April 2026

**السياق:** Pi Browser هو WebView — Pi SDK يحتاج يقرأ الـ token من `document.cookie`

**القرار:** `tec_access_token` يُعيَّن بـ `httpOnly: false`

**مخاطر مُدارة:**
- CSRF double-submit protection
- CSP + HTTPS + Token TTL 24h
- tec_refresh_token = httpOnly:true دايماً

**البدائل المرفوضة:** httpOnly:true → Pi Browser مش يقدر يقرأه | localStorage → Policy CI يبلوكه

---

## ADR-002 — Dual-Mode Payment Architecture

**Status:** ACCEPTED | **Date:** April 2026

**السياق:** Pi.createPayment() يشتغل فقط لو Pi.init() اتعمل على نفس الـ domain. لو user جه من Hub → الـ app لا تقدر تعمل Pi.init() تاني.

**القرار:** كل app تدعم وضعين:

- **Mode 1 — Hub Redirect:** app → `hub.tecosystem.app/hub?pay=1&...` → Hub يعمل Pi.createPayment()
- **Mode 2 — Direct Payment:** Pi.init() على domain الـ app → Pi.createPayment() مباشر

**قواعد دستورية:**
- ✅ كل app لازم تدعم Mode 1 (Hub fallback) — إلزامي
- ✅ Commerce = Reference Implementation
- ❌ App بـ Mode واحد = P1 violation

---

## ADR-003 — FOREIGN_SESSION Detection Pattern

**Status:** ACCEPTED | **Date:** April 2026

**السياق:** Pi Browser بيخلي كل الـ apps تشارك نفس Pi session.

**القرار:** `window.__TEC_PI_FOREIGN_SESSION = true` لما Pi.init() يرمي "already initialized".

**قاعدة ثابتة:**
❌ NEVER تمنع payment بسبب FOREIGN_SESSION=true — Pi.createPayment() يشتغل في الحالتين

---

## ADR-004 — BFF-Only Architecture

**Status:** ACCEPTED | **Date:** March 2026

**السياق:** Railway URLs يجب إخفاؤها عن الـ client.

**القرار:** Client Components → /api/* (BFF) → API Gateway → Services

```typescript
const GW = process.env.API_GATEWAY_URL;              // ✅ server-only
const GW = process.env.NEXT_PUBLIC_API_GATEWAY_URL;  // ❌ violation NEW-A
```

---

## ADR-005 — Redis Streams over Kafka/RabbitMQ

**Status:** ACCEPTED | **Date:** March 2026

**السياق:** Event bus موزع مطلوب. Redis موجود بالفعل.

**القرار:** Redis Streams (XADD/XREADGROUP/XACK)

**الأسباب:** Zero additional infrastructure + At-least-once delivery + Message persistence

⚠️ Kafka يُعاد النظر فيه بعد 100k+ active users

---

## ADR-006 — CSRF Exclusion على Payment BFF Routes

**Status:** ACCEPTED | **Date:** April 2026

**السياق:** Payment callbacks من Pi SDK مش بيدعم CSRF headers.

**القرار:** `CSRF_EXCLUDED = ['/api/bff/payment/']`

**التبرير:** JWT verification في كل route + Idempotency-Key يمنع replay + HTTPS only

**قاعدة ثابتة:** ✅ كل BFF payment route لازم JWT verify — إلزامي

---

## ADR-008 — Runtime Observability Architecture

**Status:** ACCEPTED | **Date:** June 2026 | **Verification:** `[Code Verified]`

**السياق:**
فحص Code Verified لـ Tec-App و tec-api-gateway (يونيو 2026) كشف 3 مشاكل بنيوية:

1. `BackendOfflineBanner` و `BackendStatus` كلاهما يعمل health polling مستقل كل 30s → Split Runtime View
2. `client.on('error', () => {})` في Redis Client → Silent Failures، خرق مباشر لـ C-00 "No Runtime Without Events"
3. `GET /api/health` يُعيد `{ "status": "ok" }` فقط → لا runtime evidence عند وقوع incidents

**القرارات:**

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

**التبرير:** Distributed pollers يخلقون Split Runtime View — جزء من الـ UI يعتقد Backend Online والجزء الآخر Offline في نفس اللحظة.

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

**التبرير:** Silent error handlers يمنعون verification (C-93). Invisible failure = ungoverned runtime (C-96).

### ADR-008c — Runtime Evidence Endpoint

```
// REJECTED: conclusion-only
GET /api/health → { "status": "ok" }  ❌

// ACCEPTED: evidence-first
GET /api/health          → { status }                    ✅ (public)
GET /api/health/details  → full runtime state            ✅ (x-internal-key)
  { gateway, redis, uptime, memory, services: { auth, wallet, payment... } }
```

**التبرير:** `{ "status": "ok" }` is a conclusion, not evidence. C-93 requires evidence to establish institutional state. Without `/health/details`, incidents cannot be diagnosed or verified.

### ADR-008d — Timeout Contract

```
// REJECTED: misaligned
Frontend: AbortSignal.timeout(5000)   →  Gateway: timeout: 30000  ❌

// ACCEPTED: aligned stack
Frontend:  5,000 ms (user experience boundary — unchanged)
Gateway:  10,000 ms (2× frontend — upstream has enough time)
Upstream:  8,000 ms (within gateway window)
```

**التبرير:** 25,000ms gap causes Railway to log 499 (client cancellation) instead of 500/502/503. The 499 at 595ms during incidents is a Runtime Visibility failure caused by missing observability — not a timeout failure.

**قواعد دستورية (تُطبَّق بـ Policy CI):**
- ❌ FORBIDDEN: `client.on('error', () => {})` — empty error handlers on critical clients
- ❌ FORBIDDEN: Health endpoints that return conclusions without evidence
- ✅ REQUIRED: Centralized health runtime — no distributed polling of the same signal
- ✅ REQUIRED: Timeout alignment across frontend → gateway → upstream

**الـ violations المفتوحة:** NEW-K, NEW-N, NEW-O, NEW-L في C-40

**References:** C-96 Platform Runtime & Observability Constitution

---

## ADR-007 — Pi Payment Ownership Authority

**Status:** ACCEPTED — تفاصيل كاملة في C-76

---

## ADR-009 — Unified Payment Contract (Single Source of Truth)

**Status:** ACCEPTED | **Date:** June 2026
**Repos:** tec-sdk (owner) · tec-app · tec-ecommerce · tec-assets · tec-commerce · tec-core-backend (reference)
**Severity:** P1 | **Extends:** ADR-002 (Dual-Mode Payment), ADR-004 (BFF-Only)

**السياق (السبب الجذري):**
بعد الـ hardening audit، اتولد **stack دفع متوازي** مختلف عن الـ legacy. كل تطبيق
عرّف عقد الدفع بنفسه، فحصل drift في ٣ محاور أدّى لفشل دفع متكرر (إصلاح تطبيق
واحد ما بيصلّحش الباقي):

| المحور | الانحراف المرصود | الصح (مصدر الحقيقة = tec-payment-service) |
|--------|------------------|------------------------------------------|
| `amount` | بعضهم `string` (Zod `z.string()`) وبعضهم `number` | **`number`** — DECIMAL في الـ DB |
| Internal header | `x-service-secret` / `SERVICE_SECRET` في `bffFetch` | **`x-internal-key` / `INTERNAL_SECRET`** فقط |
| Gateway path | `/api/v1/payments/*` · bare `/payments` (404 على host خام) | **`/api/payment/*`** (rewrite نظيف `^/api/payment → /payments`) |

ده انتهاك مباشر لـ **C-47**: P1 (Single Source of Truth) · P2 (No Rule Duplication)
· Forbidden #5 (Divergent SDK contracts vs backend).

**القرار:**
عقد الدفع يُعرَّف **مرة واحدة** في `@yasser172/tec-sdk` ويُستورد في كل BFF route:
- `src/contracts/payment.ts` → `CreatePaymentRequestSchema` · `ApprovePaymentRequestSchema`
  · `CompletePaymentRequestSchema` · `PAYMENT_GATEWAY_PATHS` · `INTERNAL_KEY_HEADER`
  · حُرّاس صيغة Pi id/txid.
- `amount` = `z.coerce.number()` — يتحوّل من string **مرة واحدة عند حدود الـ BFF**؛
  رقم في كل طبقة تحته (P5).

**قواعد ثابتة (تُطبَّق بـ Policy CI لاحقًا):**
- ❌ FORBIDDEN: تعريف Zod schema للدفع محليًا داخل أي app (لازم import من tec-sdk).
- ❌ FORBIDDEN: `x-service-secret` / `SERVICE_SECRET` في أي gateway call.
- ❌ FORBIDDEN: إرسال `amount` كـ string لأي payment endpoint.
- ✅ REQUIRED: مسارات `/api/payment/*` (مفرد) لكل نداء على الـ gateway.

**التبرير:** عقد واحد = إصلاح واحد. يقفل فئة الـ bug كلها بدل ترقيع نسخة في كل repo،
ويتوافق مع P5 (SDK = طبقة العقود) و C-41 (tec-ui v1.2.0 PaymentModal/createU2APayment
المشتركين فوق نفس العقد).

**خطة الانتشار (release chain):**
`tec-core-backend → tec-sdk@1.3.0 (نُشر العقد) → tec-ui v1.2.0 → الـ4 apps (نشر متزامن)`.
التطبيقات تستبدل الـ Zod المحلي بـ import من tec-sdk عند نشر 1.3.0 على npm.

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

**Status:** ACCEPTED — تفاصيل كاملة في **C-132** | **Date:** July 2026 | **Decision Authority:** CEO (C-47)

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
