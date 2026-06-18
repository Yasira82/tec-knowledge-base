# C-75 — RELEASE GOVERNANCE SPEC

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---


Deployments + Production Gates + Package Releases

⚠️ راجع C-43 للـ CI/CD implementation details
هذا الملف = governance rules + gates فقط

---

## 1. RELEASE PRINCIPLE

```
✅ deploy safely continuously
❌ deploy fast blindly

كل deploy لازم يمر بـ gates محددة
```

---

## 2. RELEASE TYPES

```
PATCH (x.x.N):
  → bug fixes فقط
  → backward compatible
  → مش محتاج migration guide

MINOR (x.N.x):
  → backward-compatible features
  → محتاج changelog

MAJOR (N.x.x):
  → breaking changes
  → محتاج migration guide + 90-day deprecation
```

---

## 3. PRODUCTION DEPLOY GATES

```
قبل أي deploy:

□ CI green (tests + lint + typecheck)
□ env vars validated (Zod startup guard)
□ DB migrations reviewed (backward compatible)
□ لا open P0/P1 violations
□ rollback plan موجود
```

---

## 4. PAYMENT SERVICE DEPLOY RULES

```
payment-service deploy خصوصاً:
  □ reconciliation healthy قبل deploy
  □ لا payments in-progress (لو ممكن)
  □ Circuit Breaker closed
  □ Outbox lag = 0
```

---

## 5. DATABASE MIGRATION RULES

```
Pattern إلزامي:

Step 1: Expand (add new column/table — backward compatible)
  ↓
Step 2: Deploy new code (يقرأ الجديد والقديم)
  ↓
Step 3: Migrate data
  ↓
Step 4: Contract (اشيل القديم)

❌ ممنوع destructive migration مباشرة على production
❌ ممنوع DROP column بدون expand-contract cycle
```

---

## 6. PACKAGE RELEASE GATES (@yasser172/*)

```
قبل npm publish:
  □ npm run build — بدون errors
  □ npm test — كل الـ tests بتعدي
  □ version bump في package.json
  □ CHANGELOG.md محدّث
  □ اختبر على Commerce أولاً (Integration gate)

ترتيب publish الإلزامي:
  tec-shared → tec-sdk → tec-auth → tec-ui → apps
```

---

## 7. VERSION PINNING RULES

```
Internal packages:
  ✅ pinned exact version
  ❌ floating "latest"
  ❌ "^" أو "~" للـ platform packages

// ✅ CORRECT
"@yasser172/tec-ui": "1.1.0"

// ❌ WRONG
"@yasser172/tec-ui": "^1.1.0"
```

---

## 8. ENV VALIDATION GATE

```typescript
// Service يرفض يشتغل لو:
//   - INTERNAL_SECRET مش موجود
//   - REDIS_URL مش موجود في production
//   - PI_SANDBOX مش set صراحة

// في main.ts — إلزامي
if (!env.INTERNAL_SECRET) {
  logger.error('FATAL: INTERNAL_SECRET not configured');
  process.exit(1);
}
```

---

## 9. ROLLBACK READINESS

```
كل deploy لازم يكون عنده:

Frontend (Vercel):
  ✅ instant rollback via Vercel dashboard

Backend (Railway):
  ✅ redeploy previous image

Package (@yasser172/*):
  ✅ npm install @yasser172/tec-ui@PREVIOUS_VERSION

⚠️ payment-service + wallet-service:
  → rollback يحتاج reconciliation check أولاً
```

---

## 10. HOTFIX RULES

```
Hotfix allowed فقط لـ:
  - P0 incidents
  - P1 blocking incidents

بعد hotfix:
  → mandatory postmortem
  → C-40 update
  → ADR update لو في decision جديد
```

---

## 11. RELEASE CHECKLIST

```
□ CI green
□ migrations backward compatible
□ health checks passing
□ rollback tested
□ no open P0/P1
□ SLO impact reviewed
□ changelog updated
```

---

## 12. VIOLATIONS

| Violation | Severity |
|---|---|
| Deploy مع failing tests | P1 |
| Destructive migration بدون expand-contract | P1 |
| Breaking API بدون version | P1 |
| Floating package versions | P2 |
| Deploy أثناء active P0 | P1 |
| Production secret في code | P0 |

---

## Related Contents

- C-43 — CI/CD & DevOps
- C-44 — Environment Variables
- C-54 — Package Management
- C-62 — SLO Definitions
- C-69 — API Contracts
- C-73 — Incident Runbook
