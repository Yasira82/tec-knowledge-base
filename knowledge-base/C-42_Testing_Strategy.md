# C-42 — TESTING STRATEGY
## Jest + Vitest + Playwright + k6

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---


---

## 1. TESTING MAP

| Repo | Framework | Status | Coverage |
|---|---|---|---|
| Tec-core-backend | Jest + ts-jest | ✅ | 60%+ (payment + wallet) |
| Tec-App (Hub) | Vitest + Playwright | ✅ | passing |
| Tec-Commerce | Vitest | ✅ | CI passing |
| Tec-Assets | Vitest | ⚠️ | Low |
| Tec-Ecommerce | Vitest | ❌ | Not written |
| TEC-SDK | Jest | ✅ | prepublish gate |
| tec-auth | Vitest | ❌ | Not written |
| tec-ui | Vitest | ❌ | Not written |

---

## 2. BACKEND TESTS (Jest + ts-jest)

```typescript
// Coverage thresholds (payment + wallet)
{
  coverageThreshold: {
    global: {
      lines:      60,
      branches:   50,
      functions:  60,
      statements: 60,
    }
  }
}
```

### Critical Tests (P0)
```
✅ Payment: 5-state lifecycle transitions
✅ Wallet: balance >= 0 constraint (upsert)
✅ Auth: JWT verify HS256
✅ Auth: refresh rotation + blacklist
✅ Payment: Idempotency (Redis NX)
✅ Payment: Outbox worker
✅ CSRF: validation middleware
```

---

## 3. FRONTEND TESTS (Vitest)

```typescript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react-oxc';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'happy-dom',
    globals:     true,
    exclude:     ['**/node_modules/**', '**/.next/**'],
  },
});
```

### Critical Frontend Tests
```
□ Dual-Mode payment flow (Mode 1 + Mode 2)
□ Hub payment return params parsing
□ CSRF token injection
□ Cookie reading (getAccessToken)
□ SSO redirect logic
```

---

## 7. TESTING TODO (Priority Order)

```
P1 — Before Mainnet:
  □ tec-auth: createAuthMiddleware tests
  □ tec-auth: CSRF validation tests
  □ Hub: PaymentModal E2E

P2 — After Mainnet:
  □ tec-ui: payment utils tests
  □ Assets: coverage ≥ 60%
  □ Ecommerce: write all tests
  □ SDK: increase coverage

P3 — Later:
  □ k6: load tests on payment endpoint
  □ E2E: SSO flow full
  □ Contract tests: SDK ↔ Backend
```