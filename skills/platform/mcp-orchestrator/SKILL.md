---
name: mcp-orchestrator
description: "When using MCP tools to check platform health, CI status, deployments, or Railway services — apply TEC-specific query patterns and interpret results through the platform knowledge lens."
metadata:
  version: 1.0.0
  tier: HIGH
  domain: platform
  related_skills:
    - knowledge-orchestrator
    - platform-architect
    - payment-expert
---

# TEC MCP Orchestrator

Use MCP tools to observe and verify the live state of the TEC platform. Always interpret results through the knowledge base.

## Available MCP Integrations

| MCP Server | Capability | When to Use |
|-----------|-----------|-------------|
| **GitHub** | CI status, PR reviews, commits, branch state | Verify fixes landed, check test results |
| **Vercel** | Deployments, runtime logs, error traces | Debug production issues, verify deploy success |
| **Railway** | Service health, env vars, deploy logs | Check backend status, NEW-B verification |
| **Supabase** | DB queries, migrations, schema | Database health if applicable |

## GitHub MCP — TEC Query Patterns

```
Check CI for a repo:
  → list workflow runs — owner: yasira82, repo: tec-ecommerce, branch: main
  → get failed job logs — for the latest failed run_id

Check a specific file:
  → get file contents — path: src/app/api/bff/payment/create/route.ts

Search for pattern:
  → search code — query: "x-internal-key" in yasira82/tec-ecommerce

Check PR status:
  → list pull requests — state: open, repo: tec-ecommerce
```

## Vercel MCP — TEC Query Patterns

```
Get runtime logs for BFF failures:
  → get runtime logs — project: tec-ecommerce
  → filter: level: ["error"], source: ["serverless"]
  → query: "bff/payment/create"

Check deployment:
  → list deployments — project: tec-ecommerce
  → get deployment — for latest deploymentId
```

## Interpreting Results Through Knowledge Lens

### CI Failure Patterns

| Error Pattern in Logs | Root Cause | Knowledge Reference |
|----------------------|-----------|--------------------|
| `Payment setup failed (422)` | Missing fetch mock for payment/create | `tec-testing` skill — C-76 backend-first |
| `.rejects.toThrow(...)` failing | Old reject-based assertions | `tec-testing` — always resolves pattern |
| `body.userId` in policy check | Merchant ID from request body | `security-reviewer` — Forbidden #8 |
| `jwt.decode` detected | JWT decoded without verification | C-47 Forbidden #2 |
| `NEXT_PUBLIC_API_GATEWAY_URL` in client | NEW-A violation | `security-reviewer` skill |

### Vercel Runtime Error Patterns

| Error in Vercel Logs | Root Cause | Fix |
|---------------------|-----------|-----|
| `Gateway not configured (503)` | `NEXT_PUBLIC_API_GATEWAY_URL` not set | Add env var on Vercel |
| `missing userId from tec_user cookie (401)` | Cookie format issue | Check `getUserId` — `u?.id ?? u?.sub ?? u?.piId` |
| `CSRF validation failed (403)` | CSRF cookie present but header missing | Check `x-csrf-token` header in client |
| `gateway error: 401` | `x-internal-key: ''` (empty string) | Only send header if `INTERNAL_SECRET` is SET |
| `gateway error: 422` | Gateway rejects request body | Check gateway contract — no `memo` field |

### Railway Service States

| State | Meaning | Action |
|-------|---------|--------|
| `Active` | Service running normally | ✅ OK |
| `Crashed` | Service exited with error | Check Railway logs immediately (P0) |
| `Sleeping` | Inactive (free tier) | Expected on free Railway plan |
| `Building` | Deploying new version | Wait 2-3 minutes |

## NEW-B Verification via Railway MCP

```
Query: List env vars for each service
Check: INTERNAL_SECRET is SET (not empty) on:
  → tec-api-gateway
  → tec-auth-service
  → tec-payment-service
  → tec-commerce-service

If MISSING: generate secret + set on all 4 services
  node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

## Multi-repo Verification Pattern

When a fix is pushed to one repo, verify cross-repo impact:

```
1. payment-expert skill change in tec-ecommerce
   → Verify: same fix needed in tec-assets? tec-commerce?
   → Check: each has isHubNavigation() guard (ADR-007)

2. tec-ui version bump
   → Verify: ALL 4 apps updated (not staggered)
   → Check: each builds without type errors

3. Gateway API change in tec-core-backend
   → Verify: tec-sdk contracts updated FIRST
   → Check: all BFF routes still work
```
