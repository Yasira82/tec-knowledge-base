# C-22 — COMMERCE + ASSETS + ECOMMERCE APPS
## The 3 ready apps — patterns + status

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Code Verified]`

**Last Updated:** June 2026

---

## PAYMENT STATUS SUMMARY (June 2026)

| App | Mode 1 | Mode 2 | ADR-007 | Status |
|-----|--------|--------|---------|--------|
| Commerce | ✅ | ✅ | ✅ | Reference Implementation |
| Assets | ✅ | ✅ | ✅ | FIXED June 1, 2026 |
| Ecommerce | ✅ | ✅ | ✅ | FIXED June 3, 2026 |

---

## 1. TEC-COMMERCE (commerce.tecosystem.app)

### Dual-Mode Payment (Reference Implementation ✅)
```typescript
const handleBuy = async (product: Product) => {
  // ADR-007: isHubNavigation() أولاً
  if (isHubNavigation() || !window.__TEC_PI_READY || window.__TEC_PI_FOREIGN_SESSION) {
    redirectToHubPayment(product);  // Mode 1
    return;
  }
  // Mode 2: Direct Pi.createPayment()
  const internalId = await createPaymentRecord(product.price, product.id, memo);
  const result = await createU2APayment(product.price, memo, metadata, internalId);
};
```

### Status: ✅ CLEAN — No open violations

---

## 2. TEC-ASSETS (assets.tecosystem.app)

### Status: ✅ FIXED — NEW-I VERIFIED June 1, 2026

---

## 3. TEC-ECOMMERCE (ecommerce.tecosystem.app)

### Status: ✅ FIXED — NEW-J VERIFIED June 3, 2026

---

## 4. SHARED PATTERNS (the 3 apps)

### ADR-007 — isHubNavigation() (mandatory)
```typescript
const isHubNavigation = (): boolean => {
  if (typeof document === 'undefined') return false;
  return document.referrer.toLowerCase().includes('hub.tecosystem.app');
};

// Decision:
// isHubNavigation() === true  → Mode 1 (immediate)
// FOREIGN_SESSION === true    → Mode 1
// else                        → Mode 2
```

### Hub Payment Return — Standard
```typescript
const { status, txid, paymentId } = getPaymentReturnParams();
if (status === 'success') { /* refresh + show success */ }
clearHubPaymentParams();
```

---

## 5. HUB REDIRECT URL (ADR-007)

```
✅ CORRECT:
hub.tecosystem.app/hub?pay=1&amount=X&memo=Y&product_id=Z&return_url=APP_URL

❌ FORBIDDEN:
hub.tecosystem.app/hub/pay (مش موجود)
```