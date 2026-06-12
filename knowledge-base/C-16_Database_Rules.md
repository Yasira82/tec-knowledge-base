# C-16 — DATABASE RULES
## Financial Integrity + Isolation + Patterns

---

## 1. DATABASE-PER-SERVICE (LOCKED)

```
tec_auth        ← auth-service only
tec_wallet      ← wallet-service only
tec_payment     ← payment-service only
tec_commerce    ← commerce-service only
tec_identity    ← identity-service only
tec_storage     ← storage-service only
tec_notification ← notification-service only
tec_kyc         ← kyc-service only
tec_asset       ← asset-service only
tec_realtime    ← realtime-service only
tec_analytics   ← Supabase PostgreSQL

❌ NO cross-service DB queries
❌ NO shared schemas
✅ Cross-service communication via Events (Redis Streams)
```

---

## 2. FINANCIAL AMOUNTS — NON-NEGOTIABLE

```sql
-- ✅ ALWAYS for Pi amounts
balance  DECIMAL(20, 8)
amount   DECIMAL(20, 8)

-- ❌ NEVER
balance  FLOAT
amount   DOUBLE PRECISION
```

---

## 3. WALLET CONSTRAINTS

```sql
-- ✅ Balance constraint
ALTER TABLE wallets
  ADD CONSTRAINT wallets_balance_non_negative
  CHECK (balance >= 0);

-- ✅ Unique wallet per user+currency
@@unique([user_id, currency])
```

---

## 4. ATOMIC WALLET OPERATIONS

```typescript
await prisma.$transaction(async (tx) => {
  const wallet = await tx.wallet.upsert({
    where:  { user_id_currency: { user_id, currency } },
    update: {},
    create: { user_id, currency, balance: 0 },
  });

  // ✅ Idempotency check
  const existing = await tx.processedEvent.findUnique({
    where: { event_key: eventId }
  });
  if (existing) return;

  await tx.wallet.update({
    where: { id: wallet.id },
    data:  { balance: { increment: amount } },
  });
});
```

---

## 6. PAYMENT STATE MACHINE (DB Level)

```typescript
const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  created:  ['approved', 'cancelled', 'failed'],
  approved: ['completed', 'cancelled', 'failed'],
  // Terminal states — NO transitions FROM these
  completed: [],
  cancelled:  [],
  failed:     [],
};
```

---

## 9. ANALYTICS — SUPABASE EXCEPTION

```
analytics-service:
  ✅ Supabase PostgreSQL (hosted)
  ✅ NestJS + Fastify
  ❌ NOT Railway PostgreSQL (exception to per-service rule)
```