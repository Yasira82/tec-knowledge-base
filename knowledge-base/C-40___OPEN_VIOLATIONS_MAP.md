# C-40 — OPEN VIOLATIONS MAP
## Current Issues + Priority + Fix

**Last Updated:** 14 June 2026

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

## P2 — يؤثر على Score

| ID | المشكلة | الحالة |
|----|---------|--------|
| NEW-C | CSRF exclusion للـ payment routes غير موثق — محتاج ADR | OPEN |
| NEW-E | tec-ui: لا tests | OPEN |
| NEW-F | Tec-Ecommerce: Pi App ID + domain غير موثقين | OPEN |
| NEW-G | Dual-Mode Payment مش في Architecture Binding | OPEN |

---

## OPEN — يحتاج قرار

### Ecommerce PR #25

| Field | Value |
|-------|-------|
| PR | https://github.com/Yasira82/Tec-Ecommerce/pull/25 |
| المشكلة | 503 على approve/complete في Vercel |
| السبب | `API_GATEWAY_URL` undefined في Vercel runtime |
| PR #25 | أضاف NEXT_PUBLIC_ fallback — لكن PR #22 شاله (security) |
| الحل الصح | تحقق إن `API_GATEWAY_URL` (server-only) set في Vercel → لو صح close PR #25 |

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

## SUMMARY

```
P0 Open:  0
P1 Open:  0  (NEW-B كود OK — Railway ops فقط)
P2 Open:  4  (NEW-C, NEW-E, NEW-F, NEW-G)
Pending:  1  (Ecommerce PR #25 — verify Vercel env var first)
Deferred: 3  (post-Portal)

Next: tec-ui v1.2.0 → External Audit ≥ 9.5 → Portal
```
