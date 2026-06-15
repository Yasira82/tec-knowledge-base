---
name: payment-expert
description: "When working on any payment-related code, ADR-007 guards, BFF payment routes, or Pi SDK integration — enforce C-76 ADR-007, payment invariants, and Mode 1/Mode 2 decision logic."
metadata:
  version: 1.0.0
  tier: CRITICAL
  domain: payment
---

# TEC Payment Expert

All payment changes require this skill. ADR-007 + C-76 + C-71 Financial Integrity.

## ADR-007 Decision Tree (apply BEFORE every payment button)

```
User clicks Pay
    ↓
isHubNavigation() || !window.Pi || !piReady
    ├── TRUE  → Mode 1: redirectToHubPayment() → /hub?pay=1&...
    └── FALSE → Mode 2: createPaymentRecord() → createU2APayment()

Mode 1 URL format (LOCKED — ADR-007):
  /hub?pay=1&amount=X&memo=Y&product_id=Z&return_url=APP_URL&source=ecommerce
  ⚠️  return_url must be APP_URL (home) NOT /shop or /orders (404s)

Mode 2 sequence (C-76 backend-first):
  1. createPaymentRecord()  → POST /api/bff/payment/create → gateway
  2. window.Pi.createPayment()  ← Pi SDK
  3. onReadyForServerApproval → POST /api/bff/payment/approve
  4. onReadyForServerCompletion → POST /api/bff/payment/complete
  5. POST /api/bff/orders  ← create order after payment confirmed
```

## Payment Invariants (Financial Integrity — C-71)

```
1. Payment cannot complete without approval
2. Order not created until payment approved
3. Wallet balance NEVER goes negative
4. Every financial action has audit trail (ActorContext required)
5. Terminal states are FINAL: completed / failed / cancelled
   → No transitions FROM these states (409 Conflict if attempted)
6. Pi amounts: DECIMAL(20,8) in DB, string in API responses
   → NEVER convert to JS Number internally
7. Idempotency key required on all payment gateway calls
```

## BFF Payment Routes Pattern

```typescript
// CORRECT — Gateway headers
const gwHeaders: Record<string, string> = {
  'Content-Type':    'application/json',
  Authorization:     `Bearer ${token}`,
  'Idempotency-Key': crypto.randomUUID(),
};
// Only send x-internal-key if actually SET
// Empty string causes Gateway 401 (NEW-B pattern)
if (process.env.INTERNAL_SECRET) {
  gwHeaders['x-internal-key'] = process.env.INTERNAL_SECRET;
}

// Gateway URL — always include NEXT_PUBLIC fallback
const GW = process.env.API_GATEWAY_URL
        ?? process.env.NEXT_PUBLIC_API_GATEWAY_URL ?? '';

// getUserId — check all Hub SSO cookie formats
const u = JSON.parse(decodeURIComponent(cookie));
return u?.id ?? u?.sub ?? u?.piId ?? '';

// CSRF — only reject when cookie IS present but header mismatches
if (csrfCookie && csrfCookie !== csrfHeader) → 403
// Missing cookie = ok (cross-domain SSO)
```

## Gateway Body (what /api/payment/create accepts)

```json
{
  "userId": "<from tec_user cookie — never from body>",
  "amount": 1.5,
  "currency": "PI",
  "payment_method": "pi",
  "metadata": { "source": "ecommerce", "product_id": "..." }
}
// memo is NOT accepted at gateway level
// memo is Pi SDK client-side only
```

## Files with ADR-007 Guard (DO NOT REMOVE from any)

```
tec-ecommerce:
  src/app/page.tsx                    → handleBuy
  src/app/product/[id]/page.tsx       → handleBuy
  src/app/store/[id]/page.tsx         → handleBuy
  src/components/shop/CartDrawer.tsx  → handleCheckout

tec-commerce: payment handler
tec-assets:   payment handler
tec-app:      /hub?pay=1 (hub owns payment modal)
```

## Test Pattern for Payment (C-76 backend-first)

```typescript
// ALWAYS mock /api/.../payment/create FIRST
const mockCreateSuccess = () =>
  vi.spyOn(globalThis, 'fetch').mockImplementation(async (url) => {
    if (String(url).includes('payment/create'))
      return { ok: true, json: async () => ({ data: { id: 'internal-id' }}) } as Response;
    // ... approve, complete
  });

// Payment tests → RESOLVE not REJECT
// createU2APayment always resolves: { status, success, message? }
```

## P1 Violations Status

| ID | Issue | Status |
|----|-------|--------|
| NEW-B | INTERNAL_SECRET missing on Railway | ⚠️ OPS ONLY |
| NEW-A | Railway URLs removed from client bundle | ✅ CLOSED |

```bash
# Fix NEW-B (one-time ops task)
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
# Set INTERNAL_SECRET on: tec-api-gateway, tec-auth-service,
# tec-payment-service, tec-commerce-service
```
