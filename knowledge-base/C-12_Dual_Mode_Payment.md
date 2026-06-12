# C-12 — DUAL-MODE PAYMENT ARCHITECTURE
## أهم قاعدة معمارية في الـ Ecosystem

---

## ⚠️ READ THIS BEFORE ANY PAYMENT CODE

> ✅ **Pi Network Mainnet** — PI_SANDBOX=false دايماً
> ✅ كل payment حقيقي — مش testnet

---

## 1. القاعدة الذهبية

كل app في TEC تدعم **وضعين للدفع في نفس الوقت:**

### Mode 1 — عبر Hub Redirect
```
App → hub.tecosystem.app/hub?pay=1&...
→ Hub PaymentModal → Pi.createPayment() على Hub domain
→ Redirect لـ return_url?payment_status=success&txid=X&payment_id=Y
```

### Mode 2 — مباشرة من الـ App
```
App → Pi.init() على domain الـ app
→ window.Pi.createPayment() مباشرة
→ BFF routes (/api/bff/payment/*)
→ Success في نفس الصفحة
```

---

## 2. Commerce = Reference Implementation ✅

---

## 3. __TEC_PI_FOREIGN_SESSION

| القيمة | المعنى |
|---|---|
| `false` | الـ app عملت Pi.init() بنجاح — دفع مباشر |
| `true` | Hub أو app تانية عملت Pi.init() قبلنا |

---

## 4. Hub PaymentModal Flow

```
URL Params اللي Hub يستقبلها:
  /hub?pay=1
  &amount=X
  &memo=ENCODED_TEXT
  &product_id=PRODUCT_ID
  &return_url=ENCODED_RETURN_URL
  &source=commerce|assets|ecommerce

بعد النجاح:
  redirect → return_url?payment_status=success&txid=X&payment_id=Y
```

---

## 5. BFF Payment Routes

```
/api/bff/payment/create           ← ينشئ payment record
/api/bff/payment/approve          ← onReadyForServerApproval
/api/bff/payment/complete         ← onReadyForServerCompletion
/api/bff/payment/resolve-incomplete ← يحل incomplete payments
```

### create route — القواعد الحرجة:
```typescript
// ✅ userId من cookie — مش من body
const getUserId = (req: NextRequest): string | null => {
  const raw = req.cookies.get('tec_user')?.value ?? '';
  const u   = JSON.parse(decodeURIComponent(raw));
  return u?.id ?? u?.sub ?? null;
};

// ✅ API_GATEWAY_URL server-only — مش NEXT_PUBLIC_
const GW = process.env.API_GATEWAY_URL
        ?? process.env.NEXT_PUBLIC_API_GATEWAY_URL
        ?? 'https://api-gateway-...';

// ✅ Idempotency-Key في كل payment call
headers: { 'Idempotency-Key': crypto.randomUUID() }
```

---

## 6. Backend Payment Lifecycle (5 States)

```
created → approved → completed ✅ (terminal)
created → cancelled ✅ (terminal)
approved → cancelled ✅ (terminal)
any → failed ✅ (terminal)
❌ NO transitions FROM terminal states
```

Patterns:
```
✅ Outbox Pattern
✅ Idempotency Keys (Redis NX)
✅ Circuit Breaker (5 failures → 60s open)
✅ Reconciliation (cron 60min)
```

---

## 7. PI_SANDBOX Rule

```typescript
PI_SANDBOX: z.enum(['true', 'false'], {
  required_error: 'PI_SANDBOX must be explicitly set'
  // ❌ NO DEFAULT
})
// ✅ Mainnet: PI_SANDBOX=false دايماً في production
```

---

## 10. Financial Integrity Rules (DB Level)

```sql
DECIMAL(20, 8)  -- ❌ NEVER Float/DOUBLE PRECISION

ALTER TABLE wallets
  ADD CONSTRAINT wallets_balance_non_negative
  CHECK (balance >= 0);  -- ✅ مطبق في production
```