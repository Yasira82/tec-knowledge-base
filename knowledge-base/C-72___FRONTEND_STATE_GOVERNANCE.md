# C-72 — FRONTEND STATE GOVERNANCE

Client Boundaries + State Authority + Security Rules

⚠️ هذا ملف مرجعي — القواعد التفصيلية في:
C-51 (Cookies) + C-63 (Pi Rules) + C-15 (Security)

---

## 1. CORE PRINCIPLE

```
Frontend state = UI convenience فقط
Backend = authority دائماً

❌ ممنوع frontend يُقرّر:
  - balance حقيقي
  - payment approved
  - subscription tier
  - KYC verified
```

---

## 2. SERVER vs CLIENT COMPONENTS

```
Server Components (RSC):
  ✅ data fetching
  ✅ auth-aware rendering
  ✅ no sensitive env exposure

Client Components:
  ✅ interactivity
  ✅ local UI state
  ✅ realtime updates (WebSocket)
```

---

## 3. AUTH BOUNDARIES

راجع C-51 للتفاصيل

```
القاعدة:
  tec_access_token  → document.cookie (Pi Browser requirement)
  tec_refresh_token → httpOnly:true (never client-side)

❌ NEVER localStorage للـ tokens
❌ NEVER sessionStorage للـ tokens
```

---

## 4. PAYMENT STATE

```
❌ Frontend NEVER confirms payment
❌ Frontend NEVER calculates amounts
❌ Frontend NEVER sets payment as completed

Frontend:
  → pending UI بس
  → يانتظر Backend callback

✅ amount source of truth = Backend DB
✅ payment status source of truth = payment-service
```

---

## 5. ROUTING RULES — Pi Browser Critical

```typescript
// Cookie mutation (login/logout):
✅ window.location.href = '/hub'   // full reload إلزامي

// Internal navigation:
✅ router.push('/hub/profile')     // SPA navigation

// ❌ NEVER router.push() بعد login/logout
```

راجع C-63 section 7 للـ rationale الكامل

---

## 6. FINANCIAL DISPLAY RULES

```typescript
// ✅ CORRECT
const { balance } = await fetchWalletBalance();
display(formatPi(balance));  // من tec-ui

// ❌ WRONG
const total = walletBalance + paymentAmount;  // floating-point error
```

✅ Fetch balance من Backend — مش local calculation
❌ NEVER arithmetic على Pi amounts في JS

---

## 7. ENVIRONMENT VARIABLES

```
NEXT_PUBLIC_* = public (visible in browser bundle):
  ✅ PI_APP_ID
  ✅ APP_URL
  ❌ NEVER secrets
  ❌ NEVER API keys
  ❌ NEVER INTERNAL_SECRET

Server-only (BFF routes):
  ✅ API_GATEWAY_URL
  ✅ JWT_SECRET
```

---

## 8. VIOLATIONS

| Violation | Severity |
|---|---|
| Auth in localStorage | P1 |
| Frontend payment authority | P1 |
| Secret in NEXT_PUBLIC_* | P0 |
| Token in WebSocket URL | P1 |
| Float math على Pi amounts | P1 |
| router.push() بعد Pi login | P1 |

---

## Related Contents

- C-51 — Cookie Architecture
- C-63 — Pi Network Rules
- C-15 — Security Rules
- C-59 — Error Format
