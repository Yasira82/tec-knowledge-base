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

## P1 — ✅ VERIFIED (Code Implemented — June 2026)

> **Truth State:** `[Current State]` | **Verification:** `[Code Verified]`
> **Implementation Guide:** C-81___P1_FIXES_IMPLEMENTATION.md — complete code applied to repos

| ID | المشكلة | المصدر | الحل | الحالة |
|----|---------|--------|------|--------|
| **NEW-K** | **Duplicate Health Polling** — BackendOfflineBanner + BackendStatus كلاهما يعمل polling مستقل كل 30s | `Tec-App/src/components/` | `PlatformHealthContext.tsx` — Single Poller + context — كود كامل في C-81 | **✅ VERIFIED** |
| **NEW-L** | **Gateway Timeout Mismatch** — Gateway 30s vs Frontend 5s → 499 ghost failures | `tec-api-gateway/src/modules/proxy/proxy.service.ts` | `timeout: 10000, proxyTimeout: 10000` — applied | **✅ VERIFIED** |
| **NEW-N** | **Redis Silent Failure** — `client.on('error', () => {})` يكتم كل الأخطاء | `tec-api-gateway/src/modules/redis/` | 5 event listeners (connect/ready/error/reconnecting/end) — applied | **✅ VERIFIED** |

---

## P1-C — ✅ VERIFIED (Code Implemented)

| ID | المشكلة | المصدر | الحل | الحالة |
|----|---------|--------|------|--------|
| **NEW-O** | **Health Endpoint Missing Detail** — `/api/health` يُعيد `{ "status": "ok" }` فقط — zero evidence at incident time | `tec-api-gateway/src/modules/health/` | `GET /api/health/details` (x-internal-key) — NestJS controller + service — applied | **✅ VERIFIED** |

---

## P2 — CLOSED (Code Verified — re-checked 24 Sep 2026)

| ID | المشكلة | المصدر | الحل | الحالة |
|----|---------|--------|------|--------|
| **NEW-M** | **Hardcoded Service Map** — `private readonly services = {}` داخل `proxy.service.ts`. إضافة Life/Connection/Explorer/SYSTEM تحتاج تعديل كود Gateway + redeploy | `tec-api-gateway/src/modules/proxy/proxy.service.ts` | إنشاء `src/config/service-registry.ts` — Gateway يقرأه وقت التشغيل بدل hardcoding | ✅ **CLOSED 18 Jun 2026** — tec-core-backend `38d33e4` ("extract service-registry.ts … closes NEW-M"); `proxy.service.ts` now holds `buildServiceRegistry()`, every URL from `*_SERVICE_URL` |

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

## SUMMARY (Updated 24 Sep 2026 — NEW-M re-checked against tec-core-backend `main`)

```
P0 Open:  0
P1 Open:  0  ✅  (NEW-K + NEW-L + NEW-N + NEW-O — all VERIFIED — C-81 applied to repos)
P2 Open:  0  ✅  (NEW-M closed 18 Jun 2026 — was left marked OPEN here until the 24 Sep audit)
Deferred: 3  (post-Portal — VM-NEW-009, VM-NEW-014, ISS-010)

Source: C-81 Implementation Guide applied to Tec-App + tec-api-gateway (June 2026)
Authority: C-96 Platform Runtime Constitution + ADR-008

Score Impact:
  Health Runtime: 6.5 → 9.0/10  (PlatformHealthContext + health/details)
  Gateway:        8.3 → 9.2/10  (timeout aligned + Redis observable)
  PRI:            8.22 → 8.8+/10 (estimated post-audit)

Next:
  (historical — superseded) All 24 apps have been live on Mainnet since July 2026.
  Current open work lives in C-02 and audits/KB_REMEDIATION_PLAN_2026-09-24.md.
```
