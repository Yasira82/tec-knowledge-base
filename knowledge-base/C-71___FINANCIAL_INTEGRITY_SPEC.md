# C-71 — FINANCIAL INTEGRITY SPEC

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---


Balances + Ledger + Settlement + Anti-Corruption Rules

⚠️ Any violation here = P0 immediately
⚠️ See C-16 for the detailed DB rules

---

## 1. CORE RULE

```
الـ DB هي الحقيقة الوحيدة المالية.

❌ Frontend balance = display only
❌ Cache balance = temporary
✅ wallet-service DB = source of truth
```

---

## 2. CURRENT FINANCIAL MODEL

```
Wallet:
  balance    DECIMAL(20,8)   ← current state
  currency   String
  user_id    String

Transaction:
  id
  type       CREDIT | DEBIT
  amount     DECIMAL(20,8)
  balance    DECIMAL(20,8)   ← snapshot بعد العملية
  reference
  source

AuditLog:
  ← كل mutation يُسجَّل

⚠️ النموذج الحالي = single-entry مع audit trail
⚠️ Double-entry ledger مخطط post-Mainnet
```

---

## 3. BALANCE RULES

```
✅ ALWAYS:
  DECIMAL(20,8) في DB
  String في API responses
  لا arithmetic في JS على financial values

❌ NEVER:
  FLOAT / DOUBLE PRECISION في DB
  number في API للـ Pi amounts
  JS floating-point math على balances
```

---

## 4. BALANCE CONSTRAINTS — DB LEVEL

```sql
-- ✅ مطبق في production
ALTER TABLE wallets
  ADD CONSTRAINT wallets_balance_non_negative
  CHECK (balance >= 0);
```

Any negative balance: → P0 — the DB rejects the operation

---

## 5. ATOMIC WALLET OPERATIONS

```typescript
// ✅ كل balance mutation داخل $transaction
await prisma.$transaction(async (tx) => {
  // 1. upsert wallet (race condition safe)
  const wallet = await tx.wallet.upsert({
    where:  { user_id_currency: { user_id, currency } },
    update: {},
    create: { user_id, currency, balance: 0 },
  });

  // 2. idempotency check
  const existing = await tx.processedEvent.findUnique({
    where: { event_key: eventId }
  });
  if (existing) return;

  // 3. balance mutation
  await tx.wallet.update({
    where: { id: wallet.id },
    data:  { balance: { increment: amount } },
  });

  // 4. mark processed
  await tx.processedEvent.create({
    data: { event_key: eventId, processed_at: new Date() }
  });
});
```

---

## 6. IDEMPOTENCY — mandatory for every financial operation

```
// pattern في wallet-service
event_key format:
  payment_completed:{payment_id}
  transfer:{transfer_id}

// لو processed قبل كده → skip بدون error
if (existing) return;
```

---

## 7. PAYMENT STATES — TERMINAL

```
CREATED   → APPROVED   → COMPLETED ✅ terminal
CREATED   → CANCELLED  ✅ terminal
APPROVED  → CANCELLED  ✅ terminal
any       → FAILED     ✅ terminal

❌ ممنوع أي transition من terminal state
❌ ممنوع COMPLETED → أي state
❌ ممنوع FAILED → أي state

// Enforcement في payment-service
if (ALLOWED_TRANSITIONS[current].length === 0) {
  throw new Error(`Terminal state ${current}`);
}
```

---

## 8. PI VERIFICATION — mandatory

```
كل payment completion:
✅ verify txid مع Pi API
✅ verify amount يطابق DB record
✅ verify user_uid يطابق JWT
✅ verify payment لم يُستخدم قبل كده

❌ NEVER:
  يكتمل payment بدون Pi verification
  يُصدَّق amount من client metadata
```

---

## 9. WALLET WRITE AUTHORITY

```
✅ wallet-service فقط يكتب في tec_wallet
✅ payment-service ينشر event فقط — لا يكتب في wallet
✅ auth-service ينشئ wallet عند أول login (via event)

// payment-service → XADD payment.completed
// wallet-service → consume → credit balance
```

---

## 10. FINANCIAL AUDIT TRAIL

```
كل financial action يُسجَّل:
  user_id
  payment_id / event_id
  amount
  source
  timestamp
  balance_before
  balance_after
```

---

## 11. RECONCILIATION — mandatory

```
Reconciliation cron (60 min):
→ payment-service يتحقق من stale payments
→ Pi API لو فيه payments completed لكن مش updated في DB

أي mismatch:
→ P0 incident → runbook C-73
```

---

## 12. VIOLATIONS

| Violation | Severity |
|---|---|
| Float/Double for Pi amounts | P0 |
| Negative balance in the DB | P0 |
| Payment completion without Pi verification | P0 |
| Settlement duplication | P0 |
| Missing idempotency on a wallet write | P1 |
| Transition from a terminal state | P1 |
| Frontend computes the balance | P1 |
| Balance mutation outside $transaction | P1 |

---

## Related Contents

- C-12 — Dual-Mode Payment
- C-16 — Database Rules
- C-56 — Redis Streams
- C-62 — SLO Definitions
- C-68 — Domain Ownership
- C-73 — Incident Runbook
