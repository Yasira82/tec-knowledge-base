# C-40 — OPEN VIOLATIONS MAP
## Current Issues + Priority + Fix

> **Truth State:** `[Current State]`
> **Governance State:** `[ADR Approved]`
> **Verification:** `[Documentation Verified]`

**Last Updated:** 16 June 2026 (Session 9 — Code Verified inspection)

---

## LIFECYCLE

```
OPEN → IN REMEDIATION → CLOSED → VERIFIED
Only VERIFIED (with test evidence) counts toward score
```

---

## P1 — ZERO OPEN ✅

كل P1 violations اتعالجت. الوحيد الباقي هو Railway ops task:

### NEW-B: INTERNAL_SECRET — Ops Only

```bash
# Generate once — same value for all 4 services
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
# Set INTERNAL_SECRET on Railway:
# tec-api-gateway, tec-auth-service, tec-payment-service, tec-commerce-service
```

الكود صح — فقط Railway env var.

---

## P2 — ALL CLOSED ✅ (synced with C-02 Session 8)

| ID | المشكلة | الحالة | التحقق |
|----|---------|--------|--------|
| NEW-C | CSRF exclusion للـ payment routes غير موثق | ✅ **VERIFIED** | ADR-006 في C-64 — CSRF exclusion موثق |
| NEW-E | tec-ui: لا tests | ✅ **VERIFIED** | tec-ui v1.2.1 — 75 tests + 80% coverage |
| NEW-F | Tec-Ecommerce: Pi App ID + domain غير موثقين | ✅ **VERIFIED** | C-01 + CLAUDE.md — Pi App ID: `ecommerce-app-71ca4d3e462eaf54` |
| NEW-G | Dual-Mode Payment مش في Architecture Binding | ✅ **VERIFIED** | ADR-002 (C-64) + C-12 |

> ⚠️ **ملاحظة من Session 9:** هذه الـ violations كانت لا تزال مُعلَنة OPEN في هذا الملف
> بينما C-02 Session 8 أكد إغلاقها. تم التصحيح الآن لمطابقة C-67 Source of Truth.

---

## OPEN — يحتاج قرار

### Ecommerce PR #25 — RESOLVED

| Field | Value |
|-------|-------|
| PR | https://github.com/Yasira82/Tec-Ecommerce/pull/25 |
| الحالة | ✅ **CLOSED** — PR #27 على main (commit 5d44c501) |
| التفاصيل | `API_GATEWAY_URL` (server-only) + Comprehensive Audit fixes — يتحقق CI |

---

## P1 — OPEN (Code Verified — June 2026)

> **Truth State:** `[Current State]` | **Verification:** `[Code Verified]`

| ID | المشكلة | المصدر | الحل | الحالة |
|----|---------|--------|------|--------|
| **NEW-K** | **Duplicate Health Polling** — BackendOfflineBanner + BackendStatus كلاهما يعمل `checkGatewayHealth()` / `checkBackendHealth()` كل 30 ثانية بشكل مستقل. 2 HTTP calls كل 30s للـ endpoint نفسه، وstate مشتتة بين شجرتين | `Tec-App/tec-frontend/src/components/BackendOfflineBanner.tsx` + `BackendStatus.tsx` | إنشاء `src/context/PlatformHealthContext.tsx` — Single Poller + Single Cache + Single Status Store | **OPEN** |
| **NEW-L** | **Gateway Timeout Mismatch** — Frontend يلغي الطلب بعد 5s (`AbortSignal.timeout(5000)`) لكن Gateway ينتظر 30s (`timeout: 30000`). النتيجة: Railway يسجل 499 (client cancellation) وليس 500/502/503. ملاحظة: الـ499 بـ 595ms duration يُرجَّح أنه browser cancellation / health-check race وليس gateway timeout. | `Tec-App/tec-frontend/src/lib/health-check.ts` + `tec-api-gateway/src/modules/proxy/proxy.service.ts` | خفض Gateway من `30000` إلى `10000` — تنسيق: Frontend 5s / Gateway 10s / Upstream 8s | **OPEN** |
| **NEW-N** | **Redis Silent Failure** — `client.on('error', () => {})` يكتم كل أخطاء Redis بالكامل. Redis failure = Invisible failure. خرق مباشر لمبدأ "No Runtime Without Events" من C-00. | `tec-api-gateway/src/modules/redis/` (أو أي service يستخدم Redis) | إضافة: `client.on('connect', ...)` + `client.on('ready', ...)` + `client.on('error', log)` + `client.on('reconnecting', ...)` + `client.on('end', ...)` — تحويل Silent Runtime إلى Observable Runtime | **OPEN** |

---

## P1-C — OPEN (Code Verified)

| ID | المشكلة | المصدر | الحل | الحالة |
|----|---------|--------|------|--------|
| **NEW-O** | **Health Endpoint Missing Detail** — `/api/health` يُعيد `{ "status": "ok" }` فقط. لا Redis state، لا upstream services state، لا memory، لا uptime. عند وقوع incident لا توجد runtime evidence. | `tec-api-gateway/src/modules/health/` | إنشاء `/api/health/details` (guarded by `x-internal-key`) يُعيد gateway + redis + uptime + memory + services map | **OPEN** |

---

## P2 — OPEN (Code Verified — June 2026)

| ID | المشكلة | المصدر | الحل | الحالة |
|----|---------|--------|------|--------|
| **NEW-M** | **Hardcoded Service Map** — `private readonly services = {}` داخل `proxy.service.ts`. إضافة Life/Connection/Explorer/SYSTEM تحتاج تعديل كود Gateway + redeploy | `tec-api-gateway/src/modules/proxy/proxy.service.ts` | إنشاء `src/config/service-registry.ts` — Gateway يقرأه وقت التشغيل بدل hardcoding | **OPEN** |

---

## DEFERRED (Post-Mainnet)

| ID | الوصف |
|----|--------|
| VM-NEW-009 | Wallet schema: cross-domain models |
| VM-NEW-014 | Gateway main.ts 27KB monolith |
| ISS-010 | Prometheus في payment فقط |

---

## VERIFIED ✅ — كل الـ P1

### Security Audit (June 14, 2026) — 10/10 Closed

| # | Fix | PR |
|---|-----|----|
| 1 | Railway URL من Swagger (→ relative URL) | #65 Tec-core-backend |
| 2 | Pi amount z.number() → z.string().regex() | #21 Tec-App |
| 3 | NEXT_PUBLIC_ fallback removed from Ecommerce | #22 Tec-Ecommerce |
| 4 | userId removed from request body | #22 Tec-Ecommerce |
| 5 | Zod validation على approve + complete | #19 Commerce + #22 Ecommerce |
| 6 | CSRF + timing-safe على payment/create | #21 Tec-App |
| 7 | /health/detailed guarded with x-internal-key | #65 Tec-core-backend |
| 8 | HSTS + security headers | #65 Tec-core-backend |
| 9 | Timing-safe CSRF comparison | #19 + #21 + #22 |
| 10 | x-internal-key على payment callbacks | #19 + #22 |

### باقي P1 Violations

| ID | الوصف | تاريخ |
|----|-------|-------|
| NEW-A | NEXT_PUBLIC_ removed من 48 BFF routes | June 2026 |
| NEW-B (code) | INTERNAL_SECRET z.string().min(32) + process.exit(1) | June 2026 |
| NEW-D | tec-auth 95% coverage — 46 tests | June 2026 |
| NEW-I | Assets Mode 2 + ADR-007 | June 1, 2026 |
| NEW-J | Ecommerce Mode 1 + ADR-007 | June 3, 2026 |
| ECM-01 | Commerce schema snake_case fix | PR #20, June 14, 2026 |

### Security Foundations

```
✅ jwt.verify() + HS256 في كل مكان
✅ timingSafeEqual على INTERNAL_SECRET + CSRF
✅ Idempotency keys على payments
✅ CORS explicit whitelist (5 domains)
✅ Rate limiting على auth + payment
✅ DECIMAL(20,8) + balance>=0
✅ Pi amount z.string() (مش Number)
✅ Policy CI active
✅ HSTS + security headers على gateway
✅ /health/detailed guarded
✅ Railway URLs مش في Swagger
✅ userId من session cookie فقط
```

---

## SUMMARY (Updated Session 9 — 16 June 2026, Code Verified)

```
P0 Open:  0
P1 Open:  4  ⚠️  (NEW-K: Duplicate Health Polling, NEW-L: Timeout Mismatch, NEW-N: Redis Silent, NEW-O: Health Endpoint Missing Detail)
P2 Open:  1  ⚠️  (NEW-M: Hardcoded Service Map)
Deferred: 3  (post-Portal — VM-NEW-009, VM-NEW-014, ISS-010)

Source: Code Verified inspection (Tec-App + tec-api-gateway — June 2026)
Authority: C-96 Platform Runtime Constitution

Score Impact:
  Health Runtime: 6.5/10 (was assumed higher)
  Gateway:        8.3/10

Next:
  1. Fix NEW-K  (PlatformHealthContext.tsx — Centralized Health Runtime)
  2. Fix NEW-N  (Redis Diagnostics — 5 event listeners)
  3. Fix NEW-O  (/api/health/details — Runtime Evidence endpoint)
  4. Fix NEW-L  (Gateway timeout 30s → 10s)
  5. Fix NEW-M  (service-registry.ts)
  4. External Re-Audit → target 9.0–9.5/10 → Portal Submission
```
