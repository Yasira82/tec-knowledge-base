---
name: check-violations
description: Audit all P1 violations status across the TEC platform
---

Run a complete P1 violation audit across all TEC repositories.

## Steps

1. Check each violation against current code state:

### NEW-A: Railway URLs in client bundle
```
Status: ✅ CLOSED
Verification: Search for NEXT_PUBLIC_API_GATEWAY_URL in client components
Command: grep -r "NEXT_PUBLIC_API_GATEWAY_URL" src/app src/components
Expected: Zero results (only in /api/* server routes as fallback)
```

### NEW-B: INTERNAL_SECRET missing on Railway
```
Status: ⚠️ OPS ONLY
Verification: Check Railway env vars for all 4 backend services
Services: tec-api-gateway, tec-auth-service, tec-payment-service, tec-commerce-service
Fix: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
     Set same value on all 4 services in Railway dashboard
```

### NEW-D: tec-auth-service test coverage
```
Status: ✅ CLOSED (95% stmt / 92.98% branch / 100% lines)
Verification: Check latest CI run for tec-core-backend
```

### NEW-J: Ecommerce Cart Phase 2+3
```
Status: ✅ CLOSED — useCart + CartDrawer + ShopHeader badge
```

### NEW-K: Hub sub-pages missing
```
Status: ✅ CLOSED — /hub/kyc + /hub/subscription + /hub/notifications + /hub/profile
```

### NEW-L: Wallet zero balance bug
```
Status: ✅ CLOSED — useWallet uses /api/bff/wallet/balance
```

2. Check for any NEW violations:
   - Search recent PRs for Policy CI failures
   - Check Vercel runtime logs for silent errors
   - Review any 422/401 patterns in payment routes

3. Output violation dashboard:

```
P1 VIOLATIONS STATUS
====================
✅ NEW-A: Railway URLs removed from client bundle
⚠️ NEW-B: INTERNAL_SECRET — OPS TASK (Railway env vars)
✅ NEW-D: tec-auth-service coverage ≥ 95%
✅ NEW-J: Ecommerce cart complete
✅ NEW-K: Hub sub-pages complete
✅ NEW-L: Wallet balance fix complete

Open: 1 (NEW-B — ops only, not a code change)
Blocked: 0
Closed: 5/6
```

## Related Skills
- `security-reviewer` — for new violation detection
- `payment-expert` — for payment-related violations
- `platform-architect` — for architectural violations
