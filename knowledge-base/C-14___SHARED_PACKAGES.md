# C-14 — SHARED PACKAGES
## @yasser172/* — Platform Layer

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Code Verified]`
> Last verified against code: 2026-09-24 — and weekly by `scripts/check-drift.py` (versions ↔ `package.json`).

**Last Updated:** 24 September 2026 — versions verified against each repo's `package.json` on `main`.

---

## 1. PACKAGE MAP

| Package | Version | الدور | npm |
|---------|---------|-------|-----|
| tec-sdk | **v1.4.0** | BFF → Backend API calls · canonical payment contract (v1.3.0) | @yasser172/tec-sdk |
| tec-shared | v1.1.0 | Backend middleware + event bus | shared/ جوه Tec-core-backend |
| tec-ui | **v3.0.0** | Shared UI + types + payment utils + EVL palette (C-83) on the **Pi amber** + Icon/CountUp + app glyphs | @yasser172/tec-ui |
| tec-auth | **v1.2.0** | Auth middleware + SSO + hooks · `ssoRedirect` replaces the sign-in page (back returns to the page you came from) | @yasser172/tec-auth |

```
tec-auth v1.2.0 (1.0.0 → 1.1.1 packaging → 1.2.0 ssoRedirect location.replace):
  ✅ 95% statement coverage
  ✅ 46 tests — 4 files
  Status: NEW-D VERIFIED ✅

tec-ui status:
  ✅ createU2APayment() — Mode 2 payment   (shipped v1.2.x)
  ✅ PaymentModal component                (shipped v1.2.x)
  ✅ C-83 EVL color tokens                 (shipped v2.0.0 — live identity)
  ✅ WEALTH → Pi amber #FBB44A             (v3.0.0 — MAJOR: values moved, nothing renamed)
  □ C-83 Phase 1 remainder: CSS-var layer + SemanticDomain type (planned)
```

---

## 2. @yasser172/tec-sdk (v1.4.0 — history below)

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

## 4. @yasser172/tec-ui (v3.0.0 — history below)

### Shipped
```typescript
// v1.2.x:
createU2APayment(amount, memo, metadata, internalId)  // Mode 2 ✅
PaymentModal                                           // shared component ✅

// v2.0.0 — EVL color tokens live in TEC_COLORS (C-83 §4–§5): ✅
TEC_COLORS.gold   = '#FBBF24'  // WEALTH
TEC_COLORS.bg     = '#050816'  // Layer 1
TEC_COLORS.purple = '#8B5CF6'  // IDENTITY  (+ green/cyan/red/blue + surface2)
```

### Still planned (C-83 Phase 1 remainder)
```typescript
type SemanticDomain = 'identity'|'wealth'|'growth'|'intelligence'|'risk'|'governance';
const DOMAIN_PRIORITY: Record<SemanticDomain, 0|1|2|3>
const resolveDomain(primary, event?): SemanticDomain
// + CSS-variable layer (--tec-* custom properties)
```

### Publish sequence (إلزامي)
```
tec-shared → tec-sdk → tec-auth → tec-ui → Commerce (test first) → apps
```

### Rules
```typescript
// ✅ CORRECT — pinned version (apps adopt EVL by pinning 2.0.0)
"@yasser172/tec-ui": "2.0.0"  // exact, no ^

// ❌ WRONG — floating
"@yasser172/tec-ui": "^2.0.0"
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