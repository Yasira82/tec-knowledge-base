# C-40 — OPEN VIOLATIONS MAP
## Current Issues + Priority + Fix

> **Truth State:** `[Current State]`
> **Governance State:** `[ADR Approved]`
> **Verification:** `[Documentation Verified]`

**Last Updated:** 16 June 2026 (Session 9 — synced with C-02)

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

## SUMMARY (Updated Session 9 — 16 June 2026)

```
P0 Open:  0
P1 Open:  0  ✅ (كل P1 violations مغلقة + VERIFIED)
P2 Open:  0  ✅ (NEW-C/E/F/G — كلها VERIFIED بعد Session 8)
Pending:  0  ✅ (Ecommerce PR #25 — closed)
Deferred: 3  (post-Portal — VM-NEW-009, VM-NEW-014, ISS-010)

OVERALL: ZERO OPEN VIOLATIONS ✅
Next: External Re-Audit → target 8.5–9.0/10 → Portal Submission
```
