# C-56 — REDIS STREAMS EVENTS MAP
## Event Bus Architecture — من الكود الفعلي

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

### Event: `user.created`

**Publisher:**
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

## 3. STREAM NAMES (كلهم)

```
payment.completed  ← payment-service publishes
user.created       ← auth-service publishes
payment:outbox     ← payment-service internal (outbox worker)
```

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

```
kyc.approved
asset.transferred
subscription.upgraded
order.created
```

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