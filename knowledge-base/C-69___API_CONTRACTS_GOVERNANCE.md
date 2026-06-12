# C-69 — API CONTRACTS GOVERNANCE

HTTP Contracts + Versioning + Compatibility Rules

⚠️ أي breaking API change بدون versioning = P1 violation

---

## 1. GLOBAL RESPONSE CONTRACT

كل APIs لازم ترجع نفس الشكل — راجع C-59 للتفاصيل الكاملة

```json
// ✅ SUCCESS
{
  "success": true,
  "data": {},
  "meta": {}
}

// ✅ ERROR
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "field": "email"
  }
}
```

❌ ممنوع:
- raw strings كـ response
- HTML responses من APIs
- inconsistent shapes بين endpoints

---

## 2. VERSIONING RULES

```
Current:
→ /api/v1/

مثال:
/api/v1/auth/login
/api/v1/payment/create
/api/v1/wallet/balance

Adding v2 triggers:
→ فقط لما يكون في breaking change حقيقي
→ v1 يفضل شغال minimum 90 يوم
→ لازم migration guide قبل deprecation
→ الـ team يحدد breaking change عبر ADR
```

---

## 3. BREAKING CHANGE POLICY

```
Breaking change examples:
❌ حذف field من response
❌ تغيير type (string → number)
❌ تغيير enum values
❌ تغيير auth behavior
❌ تغيير error structure
❌ تغيير HTTP status codes

Non-breaking (لا يحتاج v2):
✅ إضافة field اختياري جديد
✅ إضافة endpoint جديد
✅ تحسين performance
✅ bug fixes بدون signature change
```

---

## 4. PAGINATION STANDARD

```json
{
  "success": true,
  "data": [],
  "meta": {
    "page":     1,
    "limit":    20,
    "total":    200,
    "has_next": true
  }
}
```

---

## 5. HTTP METHOD RULES

```
GET     → read only — لا side effects
POST    → create / action
PUT     → full replace
PATCH   → partial update
DELETE  → delete

❌ ممنوع استخدام POST للقراءة
❌ ممنوع GET لـ mutations
```

---

## 6. IDEMPOTENCY RULES

```
كل financial POST لازم يتبع Idempotency-Key:

Headers:
  Idempotency-Key: <uuid>

Required على:
  - POST /payment/create
  - POST /payment/approve
  - POST /payment/complete
  - POST /wallet/transfer
  - POST /subscription/upgrade

ممنوع الطلب يُنَفَّذ ثاني بنفس الـ key
```

---

## 7. ERROR CODE STANDARD

```
VALIDATION_ERROR      ← 400 — invalid input
MISSING_FIELD         ← 400 — required field absent
UNAUTHORIZED          ← 401 — no/invalid token
FORBIDDEN             ← 403 — no permission
CSRF_INVALID          ← 403 — CSRF mismatch
NOT_FOUND             ← 404 — resource not found
PAYMENT_INVALID_STATE ← 409 — wrong state transition
RATE_LIMITED          ← 429 — too many requests
INTERNAL_ERROR        ← 500 — unexpected error
SERVICE_UNAVAILABLE   ← 503 — downstream down
PAYMENT_FAILED        ← 422 — Pi API rejected
PAYMENT_TIMEOUT       ← 422 — exceeded 90s

❌ ممنوع dynamic error codes
❌ ممنوع error codes خارج القائمة دي
```

---

## 8. NULLABILITY RULES

```json
// ❌ WRONG
{ "bio": undefined }

// ✅ CORRECT
{ "bio": null }
```

---

## 9. DATE FORMAT

```
✅ ISO-8601 فقط
"2026-05-27T18:20:00.000Z"

❌ ممنوع unix timestamps في API responses
```

---

## 10. DECIMAL RULES — CRITICAL

```json
// ✅ CORRECT
{ "amount": "10.50000000" }
{ "balance": "1234.12345678" }

// ❌ NEVER
{ "amount": 10.5 }
{ "balance": 1234.12 }
```

Reason: JS number → floating-point errors. DECIMAL(20,8) → string في API → لا errors.

---

## 11. CACHE HEADERS

```
Financial endpoints:
  Cache-Control: no-store, no-cache

Public catalog (products, plans):
  Cache-Control: public, max-age=60
```

---

## 12. AUTHORIZATION RULES

```
✅ userId من JWT فقط — via req.user?.id
❌ ممنوع userId في request body
❌ ممنوع userId في query params
```

---

## 13. DEPRECATION POLICY

```
Deprecated endpoint:
→ minimum 90 days support

Required قبل deprecation:
  □ changelog مكتوب
  □ migration path واضح
  □ replacement endpoint موجود
  □ Deprecation-Date header موجود
```

---

## 14. VALIDATION RULES

```
كل input لازم يتحقق منه:
✅ Zod (backend NestJS)
✅ class-validator

❌ ممنوع any unchecked input يوصل للـ DB
```

---

## 15. API GOVERNANCE CHECKLIST

```
□ Route versioned (/api/v1/)
□ Unified response shape
□ Zod validation على input
□ Auth verified (JWT)
□ Idempotency-Key على financial POST
□ Rate limiting configured
□ Error code from standard dictionary
□ No breaking changes without v2
□ Financial amounts as string
□ ISO-8601 dates
```

---

## Related Contents

- C-15 — Security Rules
- C-20 — Backend Services
- C-59 — Unified Error Format (full error spec)
- C-60 — Code Templates (BFF route patterns)
- C-67 — Source of Truth Matrix
