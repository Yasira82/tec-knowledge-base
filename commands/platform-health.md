---
name: platform-health
description: Full platform health check — CI, deployments, Railway services, payment metrics
---

Run a complete TEC platform health check across all layers.

## Steps

### Layer 1: Frontend (Vercel)
```
Check deployment status for:
  → hub.tecosystem.app        (tec-app)
  → ecommerce.tecosystem.app  (tec-ecommerce)
  → assets.tecosystem.app     (tec-assets)
  → commerce.tecosystem.app   (tec-commerce)

For each: status + last deploy time + any runtime errors
```

### Layer 2: CI (GitHub Actions)
```
Check latest CI run status for all 8 repos:
  tec-app, tec-ecommerce, tec-assets, tec-commerce,
  tec-core-backend, tec-auth, tec-sdk, tec-ui

For each: pass/fail + job name if failing
```

### Layer 3: Backend (Railway)
```
Check Railway services health:
  tec-api-gateway    (4000) — critical: single entry point
  tec-auth-service   (4001) — critical: identity authority
  tec-payment-service (4002) — critical: Pi payments
  tec-commerce-service (4003)
  tec-identity-service (4004)
  tec-kyc-service    (4005)
  tec-asset-service  (4006)
  tec-analytics-service (4007)
  tec-notification-service (4008)
  tec-realtime-service (4009)
  tec-storage-service (4010)

For each: Active / Crashed / Sleeping + last deployment
```

### Layer 4: Payment Health
```
Check /api/bff/metrics (24h payment observability):
  Payment success rate (target ≥ 95%)
  Failed payment count
  Average approval time
  P95 payment completion time
```

### Layer 5: Violations
```
Run /check-violations to confirm P1 status
```

## Output Format

```
TEC PLATFORM HEALTH REPORT
===========================
Timestamp: [ISO datetime]

FRONTEND (Vercel):
  Hub           ✅ READY  | ecommerce.tecosystem.app  ❌ ERROR
  Assets        ✅ READY  | commerce.tecosystem.app   ✅ READY

CI STATUS:
  tec-app       ✅ pass  | tec-ecommerce  ✅ pass
  tec-assets    ✅ pass  | tec-commerce   ✅ pass
  tec-core-backend ✅ pass | tec-auth      ✅ pass
  tec-sdk       ✅ pass  | tec-ui         ✅ pass

BACKEND (Railway):
  tec-api-gateway    ✅ Active
  tec-auth-service   ✅ Active
  tec-payment-service ✅ Active   [INTERNAL_SECRET: ⚠️ NOT SET]

PAYMENT HEALTH:
  Success rate: XX%  (target ≥ 95%)
  Failed (24h): X

VIOLATIONS:
  Open: 1 (NEW-B — ops)

OVERALL: ⚠️ DEGRADED (1 issue found)
```

## Escalation Rules

| Condition | Severity | Action |
|-----------|----------|--------|
| Gateway down | P0 | Immediate — revert last gateway deploy |
| Auth service down | P0 | Immediate — all logins failing |
| Payment success < 90% | P1 | Hotfix — check NEW-B + outbox pattern |
| Any frontend 500 errors | P1 | Check Vercel logs → BFF route errors |
| CI failing on main | P2 | Fix before next deploy |
