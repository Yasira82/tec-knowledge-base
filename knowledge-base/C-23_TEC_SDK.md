# C-23 — TEC SDK Shared Client
## @yasser172/tec-sdk v1.2.2 — Internals + Usage

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Code Verified]`

---

## 1. ARCHITECTURE

```
TecSdk (Facade)
    │
    ├── AuthClient          → /api/v1/auth/*
    ├── WalletClient        → /api/v1/wallet/*
    ├── PaymentClient       → /api/v1/payment/* (+ Zod validation)
    ├── AssetClient         → /api/v1/asset/*
    ├── CommerceClient      → /api/v1/commerce/*
    ├── NotificationClient  → /api/v1/notification/*
    └── HealthClient        → /health
         │
         └── BaseClient
               ├── axios (15s timeout)
               ├── Bearer interceptor
               ├── TecSdkError normalizer
               └── withRetry(3, exponential)
```

---

## 2. USAGE (BFF Routes Only)

```typescript
import { TecSdk } from '@yasser172/tec-sdk';

export const sdk = new TecSdk({
  gatewayUrl: process.env.API_GATEWAY_URL!,
  timeout:    15_000,
});

sdk.setAuthToken(token);  // يضبط لكل الـ 7 clients

const balance = await sdk.wallet.getBalance(userId);
const payment = await sdk.payment.getPayment(paymentId);
```

---

## 3. RETRY PATTERN

```typescript
// 3 attempts — exponential backoff
// 500ms → 1000ms → 2000ms
// Retries on: 5xx + 429
// No retry on: 4xx
```

---

## 8. RULES

```
✅ BFF routes فقط — مش client components
✅ setAuthToken يضبط كل الـ 7 clients
❌ مش في browser/client components
❌ مش في window.Pi flows
```