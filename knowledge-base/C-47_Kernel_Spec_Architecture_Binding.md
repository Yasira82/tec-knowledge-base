# C-47 — KERNEL SPEC & ARCHITECTURE BINDING
## TEC Constitutional Layer v1.2.0

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Code Verified]`


---

## 1. PURPOSE

> TEC Kernel Spec = Constitutional source of truth
> Architecture Binding = Where each rule is enforced in the actual code
> "A rule without an enforcement point is incomplete."

---

## 2. CORE PRINCIPLES (P1-P6)

| Principle | Rule |
|---|---|
| **P1** Single Source of Truth | Every rule is defined in one place only |
| **P2** No Rule Duplication | No rule is defined differently in more than one layer |
| **P3** Strict State Transitions | Every state change follows an explicit lifecycle |
| **P4** Event-Driven Truth | Events = facts |
| **P5** Layer Responsibility | SDK=contracts, Gateway=orchestration, Services=execution |
| **P6** **Fail Closed** | If there is doubt about identity/permission/state → **deny by default** |

> ⚠️ P6 is the most important — non-negotiable for a financial platform

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

## 10. EVIDENCE RULES (E1–E3)

> Adopted 2026-10-04 by the owner from TECO's Decision Core (its "Golden Rules"); TECO is TEC's
> decision product, under the TEC name and domain (`audits/TECO_DECISION_CORE_ASSESSMENT_2026-10-04.md`).
> They govern anything TEC shows as a verdict, a rank, a score or a status — trust, risk,
> verification, recognition, discovery.

| Rule | Statement |
|---|---|
| **E1** Unknown is never positive evidence | What was not observed is not counted, and is **never worded as favourable or neutral**. "No problems found" for something nobody checked is forbidden; the wording is "There is not enough evidence to assess X." A missing value is never filled in with a default that reads as a finding (`?? 'MODERATE'`, `?? 0`). E1 is P6 applied to what TEC *says*. |
| **E2** Integrity status precedes score | Rank by status first; a score orders only within one status. Verified before unverified, whatever the score — and paid visibility never outranks verification. |
| **E3** Hard constraints exclude before scoring | A candidate that fails a hard constraint (budget, stock, a required criterion) is **removed**, not given a low score. It is not shown as "a bad match"; it is not a match. |

**Evidence status — the shared words.** When a TEC record says how much it knows, it uses these
five and no synonyms:

| Status | Meaning | Counts toward a verdict? |
|---|---|---|
| `verified` | Observed and confirmed | yes |
| `partial` | Observed, degraded | yes — but lowers coverage |
| `stale` | Was verified, now past its freshness window | no |
| `insufficient` | Observation attempted, unreliable | no |
| `unknown` | Never observed | no — and its value is `null`, never a default |

Every record also carries **when** it was observed and **where** it came from (manual · api ·
licensed · partner, or the TEC service that produced it). A record states an observation; it
never contains the score, rank or recommendation made from it. This is the vocabulary the
deferred Evidence Engine starts from (`audits/EVIDENCE_ENGINE_TARGET_SPEC_v1.0_2026-10-04.md`).

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
| E1 unknown is no finding | Insure · Explorer · Alert | `riskFromBackend` → null on a missing band (Tec-Insure #43) · Explorer BFF `source:'unavailable'`, no fixture · Alert files no finding for an unclassified metric ✅ |
| E2 status before score | Explorer ranking | identity-service `explorer.service.ts`: trust tier first, paid `featured` only within a tier ✅ |
| E3 constraints before scoring | Commerce hold · Elite (planned) | out-of-stock excluded before payment (tec-core-backend #361) ✅ · Elite criteria all-pass — when recognition is built |

**Binding compliance: ~98% (post-May 2026 audit) | Target: 100%**