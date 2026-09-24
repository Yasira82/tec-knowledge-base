# C-56 — REDIS STREAMS EVENTS MAP
## Event Bus Architecture — من الكود الفعلي

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`
> **Canonical list:** `manifests/events-catalog.yaml` — code-sourced, gated by
> `evals/check-events-catalog.sh`, every entry found in tec-core-backend on 2026-09-24.
> This file explains the **patterns** (consumer groups, idempotency, outbox). For *which*
> events exist, read the catalog; where the two differ, the catalog wins.

---


---

## 1. نظرة عامة

```
Pattern: XADD → Redis Stream → XREADGROUP (consumer groups)
Library: ioredis (backend) + @yasser172/tec-shared (helpers)
Format:  XADD [stream] * data [JSON.stringify(payload)]
```

> ✅ Delivery: At-least-once → كل consumer لازم idempotent
> ✅ Pending messages recovery موجودة في كل consumer
> ❌ مش Pub/Sub — لا تستخدم SUBSCRIBE/PUBLISH

---

## 2. EVENTS MAP — الكاملة

### Event: `payment.completed`

**Publisher:**
```typescript
// tec-payment-service/src/services/payment.service.ts:173
await publishEvent(pub, EVENTS.PAYMENT_COMPLETED, {
  payment_id: payment.id,
  user_id:    payment.userId,
  amount:     payment.amount,    // DECIMAL string
  currency:   payment.currency,
  txid:       payment.txid,
  source:     payment.source,    // 'commerce' | 'assets' | 'ecommerce'
  product_id: payment.metadata?.product_id,
  timestamp:  new Date().toISOString(),
});
```

**Consumers:**

| Service | Consumer Group | Consumer Name | Action |
|---|---|---|---|
| wallet-service | `wallet-service` | `wallet-consumer-1` | credit wallet balance |
| notification-service | `notification-service` | `notification-consumer-1` | push notification |
| analytics-service | `analytics-service` | `analytics-consumer-1` | record revenue |
| realtime-service | `realtime-service` | `realtime-consumer-1` | live UI update |

---

### Event: `user.created` → retired; now `user.created.v1` (C-70 rename, Sessions 23–24)

> The unversioned `user.created` emit was dropped in Session 24 (tec-core-backend #163).
> The producer now emits only `user.created.v1`, **with an `eventId`**, and four consumers
> (identity · analytics · realtime · notification) dedupe on it. The snippet below is the
> pre-rename shape, kept for the pattern only.

**Publisher (historical shape):**
```typescript
// tec-auth-service/src/modules/auth/auth.service.ts:62
await this.redis.xadd('user.created', '*', 'data', JSON.stringify({
  userId:    user.id,
  username:  user.piUsername,
  piId:      user.piId,
  createdAt: new Date().toISOString(),
}));
```

**Consumers:**

| Service | Consumer Group | Consumer Name | Action |
|---|---|---|---|
| notification-service | `notification-service` | `notification-consumer-2` | welcome notification |
| analytics-service | `analytics-service` | `analytics-consumer-2` | record new user |
| realtime-service | `realtime-service` | `realtime-consumer-2` | welcome realtime event |

---

## 3. STREAM NAMES

The two-line list that stood here ("كلهم" — all of them) had been wrong since July: one of
its two streams was retired and a dozen more went live. The live set, from the catalog on
2026-09-24 — **15 live · 1 planned**:

```
Identity / payment core   user.created.v1 · payment.approved.v1 · payment.completed
                          payment.completed.v1 · order.paid.v1
Verification              kyc.verified · kyc.rejected
Zone                      zone.badge.issued.v1 · zone.badge.revoked.v1
Value chain               epic.project.completed.v1 · connection.milestone.v1
                          connection.trust.updated.v1 · legend.scores.updated.v1
Analytics                 analytics.business.popularity.v1 · analytics.finding.raised.v1
Planned                   fundx.investment.closed.v1
Internal (not an event)   payment:outbox  ← payment-service outbox worker
```

`payment.completed` (unversioned) is still emitted beside `.v1` and still has consumers — a
legacy name the catalog flags; do not add new consumers to it.

---

## 4. CONSUMER GROUP PATTERN

```typescript
// كل consumer يعمل ده عند startup
await ensureConsumerGroup(client, STREAM, GROUP);

// ثم يبدأ الـ read loop
while (!isShuttingDown) {
  const results = await client.xreadgroup(
    'GROUP', GROUP, CONSUMER,
    'COUNT', 10,
    'BLOCK', 5000,
    'STREAMS', STREAM, '>'
  );
  // process + XACK
}
```

---

## 5. IDEMPOTENCY PATTERN (wallet)

```typescript
const existing = await tx.processedEvent.findUnique({
  where: { event_key: `payment_completed:${payment_id}` }
});
if (existing) return;

await tx.processedEvent.create({
  data: { event_key: `payment_completed:${payment_id}`, processed_at: new Date() }
});
```

---

## 6. SHARED HELPERS (@yasser172/tec-shared)

```typescript
import {
  publishEvent,
  subscribeStream,
  ensureConsumerGroup,
  EVENTS,
} from '@yasser172/tec-shared';

EVENTS.PAYMENT_COMPLETED = 'payment.completed'
```

---

## 7. عند إضافة Service جديدة (Life / Connection)

```typescript
const startLifeConsumer = async (client: Redis) => {
  await ensureConsumerGroup(client, EVENTS.PAYMENT_COMPLETED, 'life-service');
  await subscribeStream(
    client,
    EVENTS.PAYMENT_COMPLETED,
    'life-service',
    'life-consumer-1',
    async (payload) => {
      await updateSpendingTimeline(payload.user_id, payload.amount, payload.source);
    },
    { batchSize: 10, blockMs: 5000 },
  );
};
```

---

## 8. EVENTS لم تُنفَذ بعد (Future)

The planned list is the catalog's `status: planned` entries — today only
`fundx.investment.closed.v1`.

The four names that used to be here — `kyc.approved`, `asset.transferred`,
`subscription.upgraded`, `order.created` — were **never adopted**: verification ships as
`kyc.verified` / `kyc.rejected`, orders as `order.paid.v1`, and none of the four exists in
tec-core-backend (the only `order.created` in the code is the `order.created_at` column).
A new event is added to the catalog first, versioned (C-70), then implemented.

---

## 9. OUTBOX PATTERN (payment-service)

```
completePayment()
  → DB transaction: payment.status = 'completed' + outbox.status = 'pending'
  → Worker polls every 5s
  → XADD payment.completed
  → outbox.status = 'published'
  → max 5 retries + exponential backoff
```

> ✅ Guarantees at-least-once delivery
> ✅ Payment never lost even if Redis is temporarily down