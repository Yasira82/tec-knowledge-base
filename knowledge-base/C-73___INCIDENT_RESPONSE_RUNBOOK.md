# C-73 — INCIDENT RESPONSE RUNBOOK

Production Failure + Security + Payment Incidents

⚠️ راجع C-10 section 12 للـ Quick Reference
هذا الملف = detailed runbooks

---

## 1. SEVERITY LEVELS

```
P0 → Financial corruption / auth compromise / data loss
P1 → Core feature broken (payment / auth / wallet)
P2 → Partial degradation (one app broken)
P3 → Minor issue (UI bug / non-critical)
```

---

## 2. P0 INCIDENTS — فوري بدون استثناء

```
Examples:
  - negative balance في DB
  - duplicate settlement
  - leaked secret (JWT_SECRET / INTERNAL_SECRET)
  - payment completion بدون Pi verification
  - auth bypass

Actions:
  ✅ freeze payment completion فوراً
  ✅ وقّف كل deployments
  ✅ export audit logs
  ✅ snapshot DB state
```

---

## 3. PAYMENT INCIDENT FLOW

```
Symptoms: payment stuck / wallet لم يتحدث

1. Check payment-service: GET /health
2. Check Circuit Breaker: GET /metrics → circuit_breaker_state
3. Check Redis Streams lag: XLEN payment:outbox
4. Check PI_SANDBOX=false في Railway
5. Check Pi Network API: https://api.minepi.com/v2/me
6. لو Circuit Breaker open → انتظر 60s → auto-reset
7. Reconciliation service يصلح خلال 60min تلقائياً
8. Manual: POST /api/payment/resolve-incomplete
```

---

## 4. DUPLICATE SETTLEMENT FLOW — P0

```
1. Freeze payment completion route فوراً
2. Identify affected payment_ids
3. Export wallet ledger snapshot
4. Compare vs Pi API txids
5. Generate audit report
6. Compensating entries للـ duplicates
7. مش rollback — compensating transactions بس
```

---

## 5. SECRET LEAK FLOW — P0

```
Immediately:
  ✅ rotate leaked secret في Railway
  ✅ invalidate all sessions (clear Redis blacklist keys)
  ✅ redeploy affected services
  ✅ inspect access logs للـ 24h السابقة
  ✅ check لو secret اتضمن في any response
```

---

## 6. AUTH COMPLETE FAILURE FLOW

```
Symptoms: Pi login يفشل / cookies لا تُعيَّن

1. Check auth-service: GET /health
2. Check Redis connection (للـ blacklist)
3. Check JWT_SECRET في Railway
4. Check COOKIE_DOMAIN=.tecosystem.app
5. Check sameSite:none على الـ cookies
6. Check Pi API: /v2/me
```

---

## 7. WALLET INCONSISTENCY FLOW

```
Symptoms: balance خاطئ / 0.00 بشكل غير متوقع

1. Check piUsername في Hub header (الـ account صح؟)
2. Check wallet-service health
3. Check JWT token صالح (logout + login)
4. Check ProcessedEvent للـ idempotency
5. Check XLEN payment:outbox (هل في events لسه pending?)
6. Manual reconciliation: check payment-service logs
```

---

## 8. ROLLBACK RULES

```
✅ Allowed بدون restrictions:
  - Frontend rollback (Vercel instant)
  - Stateless service rollback

⚠️ يحتاج reconciliation قبل rollback:
  - wallet-service
  - payment-service

❌ ممنوع:
  - DB rollback على financial tables بدون audit
  - Rollback لو في payments in-progress
```

---

## 9. RECOVERY VALIDATION CHECKLIST

```
قبل إعلان resolution:

□ Health checks green (كل الـ /health/ready)
□ Redis Streams queues drained (XLEN = 0)
□ Reconciliation passed (60min cron)
□ Pi API responding
□ Payment test end-to-end ناجح
□ No active alerts
```

---

## 10. COMMUNICATION RULES

```
كل P0/P1 يحتاج incident report يحتوي:
  □ Timeline (discovery → resolution)
  □ Root cause
  □ Impact (users affected / amount at risk)
  □ Mitigation steps
  □ Prevention (ADR update or C-40 new violation)
```

---

## 11. POSTMORTEM RULES

```
كل P0/P1:
→ mandatory prevention update في C-40 أو ADR جديد
→ مش بس "fix the bug" — لازم تمنع التكرار
```

---

## 12. VIOLATIONS

| Violation | Severity |
|---|---|
| لا reconciliation بعد financial incident | P0 |
| Restore corrupted balances بدون audit | P0 |
| Missing incident report بعد P0/P1 | P1 |
| Deploy during active P0 | P1 |

---

## Related Contents

- C-10 — System Architecture
- C-40 — Violations Map
- C-45 — Observability
- C-62 — SLO Definitions
- C-71 — Financial Integrity
