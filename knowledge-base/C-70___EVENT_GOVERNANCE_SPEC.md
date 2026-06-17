# C-70 — EVENT GOVERNANCE SPEC

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`


Redis Streams + Event Ownership + Payload Standards

⚠️ اقرأ C-56 أولاً للـ implementation details
هذا الملف = governance rules فقط

---

## 1. EVENT NAMING STANDARD

```
Format: domain.action

✅ CORRECT:
payment.completed
wallet.balance.updated
auth.user.created
subscription.upgraded
notification.created

❌ WRONG:
paymentDone
walletUpdate
newPayment
PAYMENT_COMPLETED
```

---

## 2. EVENT OWNERSHIP

كل event له publisher واحد فقط

| Event | Owner |
|---|---|
| payment.completed | payment-service |
| payment.created | payment-service |
| payment.cancelled | payment-service |
| wallet.balance.updated | wallet-service |
| auth.user.created | auth-service |
| auth.kyc.updated | auth-service |
| subscription.upgraded | auth-service |
| notification.created | notification-service |

⚠️ فقط owner service ينشر (XADD) الـ event
⚠️ باقي الـ services consumer فقط — لا تنشر events غيرها

---

## 3. EVENT PAYLOAD STANDARD

كل event لازم يحتوي:

```json
{
  "event_id":   "uuid",
  "event_type": "payment.completed",
  "timestamp":  "2026-05-27T18:00:00Z",
  "source":     "payment-service",
  "version":    1,
  "payload":    {}
}
```

```
❌ events MUST NOT contain:
  - JWTs
  - refresh tokens
  - raw Pi API keys
  - secrets
```

---

## 4. EVENT IMMUTABILITY

```
Published event:
❌ NEVER modified
❌ NEVER deleted

لو في correction:
→ publish compensating event جديد

// ❌ WRONG
UPDATE stream SET payload = '...' WHERE id = 'xyz';

// ✅ CORRECT
XADD payment.completed * data '{"event_type": "payment.compensation", ...}'
```

---

## 5. DELIVERY GUARANTEE

```
Redis Streams → at-least-once delivery

⚠️ لذلك كل consumer لازم يكون idempotent:

// ✅ Pattern إلزامي في كل consumer
const existing = await tx.processedEvent.findUnique({
  where: { event_key: `${event_type}:${event_id}` }
});
if (existing) return; // already processed — skip
```

---

## 6. CONSUMER RULES

```
كل consumer لازم:
  ✅ consumer group منفصل (SERVICE_NAME)
  ✅ XACK بعد success فقط — مش قبل
  ✅ retry logic داخل subscribeStream
  ✅ idempotency check قبل أي DB write
  ✅ structured logging مع event_id

// ✅ Pattern الصح
 await ensureConsumerGroup(redis, STREAM, GROUP_NAME);
await subscribeStream(redis, STREAM, GROUP_NAME, CONSUMER, handler, opts);
// XACK يحصل داخل subscribeStream بعد handler ينجح
```

---

## 7. DEAD LETTER POLICY

```
بعد 5 retries متتالية:
→ يتنقل الـ event لـ dead-letter stream

Format: dlq.[original_stream]

مثال:
dlq.payment.completed

Dead-letter monitoring:
→ alert لو DLQ فيه > 0 messages
→ manual review إلزامي قبل reprocess
→ NEVER auto-reprocess بدون investigation
```

---

## 8. EVENT VERSIONING

```
Breaking payload change:
→ new version مطلوب

// v1 — current
payment.completed (version: 1)

// v2 — future breaking change
payment.completed (version: 2)
// أو stream name جديد: payment.completed.v2

Backward compatibility:
→ v1 consumers يفضلوا شغالين 90 يوم بعد v2
```

---

## 9. REPLAY RULES

```
✅ Allowed:
  - analytics rebuild
  - projection rebuild
  - recovery بعد consumer failure

❌ Forbidden:
  - duplicate financial settlement
  - replay بدون idempotency check
  - replay على production بدون validation
```

---

## 10. ORDERING GUARANTEE

```
✅ Ordering guaranteed: داخل نفس stream فقط
❌ cross-stream ordering غير مضمون

لو محتاج ordering عبر streams:
→ استخدم correlation_id + timestamp
```

---

## 11. RETENTION POLICY

```
Financial events (payment.*):
→ NEVER delete automatically
→ احتفظ indefinitely

Analytics events:
→ retention 90 days acceptable
```

---

## 12. VIOLATIONS

| Violation | Severity |
|---|---|
| Non-idempotent consumer | P1 |
| Service تنشر foreign event | P1 |
| Event payload يتعدل بعد publish | P1 |
| Financial replay بدون idempotency | P0 |
| XACK قبل processing | P1 |
| Missing dead-letter handling | P2 |
| Secret في event payload | P0 |

---

## Related Contents

- C-56 — Redis Streams Events (implementation map)
- C-20 — Backend Services (consumer patterns)
- C-65 — New Backend Service Template
- C-67 — Source of Truth Matrix
- C-68 — Domain Ownership Matrix
