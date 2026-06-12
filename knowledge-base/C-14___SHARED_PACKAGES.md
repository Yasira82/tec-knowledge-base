# C-14 — SHARED PACKAGES
## @yasser172/* — Platform Layer

**Last Updated:** June 2026

---

## 1. PACKAGE MAP

| Package | Version | الدور | npm |
|---------|---------|-------|-----|
| tec-sdk | v1.2.2 | BFF → Backend API calls | @yasser172/tec-sdk |
| tec-shared | v1.1.0 | Backend middleware + event bus | shared/ جوه Tec-core-backend |
| tec-ui | v1.1.0 → **v1.2.0⏳** | Shared UI + types + payment utils | @yasser172/tec-ui |
| tec-auth | **v1.0.0** | Auth middleware + SSO + hooks | @yasser172/tec-auth |

```
tec-auth v1.0.0:
  ✅ 95% statement coverage
  ✅ 46 tests — 4 files
  Status: NEW-D VERIFIED ✅

tec-ui v1.2.0 = NEXT (Portal blocker):
  □ createU2APayment() — Mode 2 payment
  □ PaymentModal component
  □ C-83 Phase 1: CSS tokens + SemanticDomain type
```

---

## 2. @yasser172/tec-sdk v1.2.2

```typescript
import { TecSdk } from '@yasser172/tec-sdk';

const sdk = new TecSdk({
  gatewayUrl: process.env.API_GATEWAY_URL!,  // NOT NEXT_PUBLIC_
  timeout:    15000,
});

sdk.setAuthToken(token);

// 7 Clients:
sdk.auth          // login, refresh, logout, getProfile
sdk.wallet        // balance, deposit, withdraw, transfer
sdk.payment       // create, approve, complete, resolve
sdk.assets        // list, get, provision, mint
sdk.commerce      // products, orders, cart
sdk.notifications // list, read, unread count
sdk.health        // check gateway health
```

---

## 4. @yasser172/tec-ui v1.1.0 → v1.2.0

### v1.2.0 — TO BUILD (Portal blocker)
```typescript
// New exports:
createU2APayment(amount, memo, metadata, internalId)  // Mode 2
PaymentModal                                           // shared component

// C-83 Phase 1 exports:
type SemanticDomain = 'identity'|'wealth'|'growth'|'intelligence'|'risk'|'governance';
const DOMAIN_PRIORITY: Record<SemanticDomain, 0|1|2|3>
const resolveDomain(primary, event?): SemanticDomain

// CSS tokens:
--tec-bg: #050816
--tec-purple: #8B5CF6  // identity
--tec-gold:   #FBBF24  // wealth
--tec-green:  #22C55E  // growth
```

### Publish sequence (إلزامي)
```
tec-shared → tec-sdk → tec-auth → tec-ui → Commerce (test first) → apps
```

### Rules
```typescript
// ✅ CORRECT — pinned version
"@yasser172/tec-ui": "1.2.0"  // exact, no ^

// ❌ WRONG — floating
"@yasser172/tec-ui": "^1.2.0"
```

---

## 6. UPDATE PROTOCOL

```
1. تعديل الـ package
2. npm run test → 100% pass
3. npm run build → 0 errors
4. version bump في package.json
5. npm publish
6. في Commerce أولاً للاختبار
7. بعد Commerce ✅ → Assets → Ecommerce → template
```