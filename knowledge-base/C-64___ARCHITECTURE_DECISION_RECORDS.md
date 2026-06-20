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