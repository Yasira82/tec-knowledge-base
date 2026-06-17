# C-47 — KERNEL SPEC & ARCHITECTURE BINDING
## TEC Constitutional Layer v1.1.1

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---

## 1. PURPOSE

> TEC Kernel Spec = Constitutional source of truth
> Architecture Binding = Where each rule is enforced in the actual code
> "A rule without an enforcement point is incomplete."

---

## 2. CORE PRINCIPLES (P1-P6)

| Principle | Rule |
|---|---|
| **P1** Single Source of Truth | كل rule تتعرف في مكان واحد فقط |
| **P2** No Rule Duplication | لا rule تتعرف بشكل مختلف في أكتر من layer |
| **P3** Strict State Transitions | كل state change يتبع lifecycle صريح |
| **P4** Event-Driven Truth | Events = facts |
| **P5** Layer Responsibility | SDK=contracts, Gateway=orchestration, Services=execution |
| **P6** **Fail Closed** | لو فيه شك في identity/permission/state → **deny by default** |

> ⚠️ P6 هو الأهم — non-negotiable لـ financial platform

---

## 3. SYSTEM INVARIANTS

```
1. Wallet balance لا يصبح سالب
2. Payment لا يكتمل بدون approval
3. Identity دايماً تحل لـ principal واحد
4. كل financial action عنده audit trail
5. Events immutable — لا تتعدل
6. لا state mutation بدون actor context
7. Terminal states نهائية — لا transitions من completed/failed/cancelled
8. كل entity عنده service مالك واحد
9. Non-sensitive classification لا تعفي من logging
```

---

## 8. FORBIDDEN BEHAVIORS (10)

```
1. Direct DB mutation bypassing service layer
2. Payment completion without event verification
3. Cross-service shared database logic
4. Business logic inside API Gateway
5. Divergent SDK contracts vs backend behavior
6. Silent failure in financial flows
7. Reading another user's wallet/payment without authorization
8. Accepting operations with missing ActorContext on sensitive paths
9. Transitioning from terminal payment states
10. Ad-hoc system recovery without audit trail
```

---

## 9. VIOLATION RESPONSE

| Violation Type | Response | HTTP |
|---|---|---|
| Invariant violation | Reject immediately | 400/403 |
| Unknown actor context | Deny by default | 401 |
| Contract mismatch (bad request) | Reject | 400/422 |
| Contract mismatch (SDK↔backend) | Fail closed | 500 + alert |
| Orphan payment state | Reconciliation path | cron 60min |
| Terminal state transition | Reject | 409 Conflict |

---

## 12. ARCHITECTURE BINDING — ENFORCEMENT MAP

| Rule | Enforced At | File/Location |
|---|---|---|
| JWT HS256 verify() | Gateway + shared | jwt-auth.ts + auth-extractor.ts |
| No jwt.decode() | Policy CI | ci.yml policy-check |
| No localStorage tokens | Policy CI | ci.yml policy-check |
| No CORS wildcard | Policy CI + CORS config | ci.yml + main.ts |
| timingSafeEqual | Gateway + wallet + shared | validateInternalKey() |
| INTERNAL_SECRET fatal guard | Auth + Payment startup | main.ts process.exit(1) |
| DECIMAL(20,8) for Pi amounts | DB schema | schema.prisma + migration ✅ |
| balance >= 0 | DB constraint | migration.sql ✅ |
| userId from req.user.id | Policy CI | blocks body.userId |
| Payment state machine | payment-service | ALLOWED_TRANSITIONS ✅ |
| Outbox pattern | payment-service | outbox.worker.ts ✅ |
| Idempotency (Redis NX) | payment + wallet | idempotency.middleware.ts ✅ |
| Circuit breaker | payment-service | pi-api.ts ✅ |
| BFF isolation | All frontend apps | /api/* routes only ✅ |
| CSRF double-submit | middleware.ts | All frontend apps ✅ |
| Non-root Docker USER | All Dockerfiles | USER appuser ✅ |

**Binding compliance: ~98% (post-May 2026 audit) | Target: 100%**