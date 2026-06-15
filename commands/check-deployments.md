---
name: check-deployments
description: Check Vercel deployment status for all TEC frontend apps
---

Check the latest production deployment status for all TEC frontend apps on Vercel.

## Steps

1. Use Vercel MCP to list recent deployments for:
   - `tec-app` (hub.tecosystem.app)
   - `tec-ecommerce` (ecommerce.tecosystem.app)
   - `tec-assets` (assets.tecosystem.app)
   - `tec-commerce` (commerce.tecosystem.app)

2. For each deployment, report:
   - Status: ✅ READY / ❌ ERROR / ⏳ BUILDING
   - URL and deployment ID
   - Git branch and commit
   - Build duration
   - Any runtime errors in last 30 min

3. If any deployment has errors:
   - Fetch runtime logs for the failing routes
   - Check for common patterns:
     - `[bff/payment/create] gateway error` → see `payment-expert` skill
     - `[bff/wallet/balance] error` → BFF-first rule violation
     - `API_GATEWAY_URL not configured` → missing env var on Vercel

4. Output summary:

```
| App        | Status  | URL                          | Last Deploy |
|------------|---------|------------------------------|-------------|
| Hub        | ✅ READY | hub.tecosystem.app           | 5 min ago   |
| Ecommerce  | ❌ ERROR | ecommerce.tecosystem.app     | 12 min ago  |
```

## Common Deployment Fixes

| Error | Fix |
|-------|-----|
| `Gateway not configured` | Set `NEXT_PUBLIC_API_GATEWAY_URL` on Vercel |
| `Cannot read tec_user cookie` | Check Hub SSO cookie domain config |
| `Build failed: type error` | Run `npm run type-check` locally first |
| `Runtime 500 on /api/bff/*` | Check Railway gateway service health |
