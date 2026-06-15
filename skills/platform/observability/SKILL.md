---
name: observability
description: "When monitoring platform health, investigating incidents, or reviewing SLOs — apply TEC observability framework: payment metrics, error rates, service health, and incident response protocol."
metadata:
  version: 1.0.0
  tier: HIGH
  domain: platform
  related_skills:
    - mcp-orchestrator
    - platform-architect
    - security-reviewer
  related_documents:
    - knowledge-base/C-78___PLATFORM_OPERATIONS___RELIABILITY_GOVERNANCE.md
---

# TEC Platform Observability

## Service Level Objectives (SLOs)

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Payment success rate | ≥ 95% | < 90% → P1 incident |
| Auth service availability | ≥ 99.9% | < 99% → P0 incident |
| API Gateway latency P95 | < 500ms | > 2s → investigate |
| BFF route error rate | < 1% | > 5% → P1 incident |
| Vercel deployment success | ≥ 99% | 2 consecutive fails → alert |

## Payment Metrics (/api/bff/metrics)

```typescript
// 24-hour payment observability endpoint
GET /api/bff/metrics

Returns:
  total_payments:      number
  successful:          number
  failed:              number
  cancelled:           number
  success_rate:        number  // percentage
  avg_approval_ms:     number  // time: create → approve
  avg_completion_ms:   number  // time: approve → complete
  incomplete_count:    number  // orphan payments
```

## Error Classification

### P0 — Platform Critical (immediate response)
```
→ Payment service down (all payments failing)
→ Auth service down (all logins failing)
→ API Gateway unreachable
→ Identity resolution ambiguous (violates Invariant #3)
```

### P1 — Serious Degradation (< 1 hour response)
```
→ Payment success rate < 90%
→ Auth service regression (coverage drops)
→ BFF route > 5% error rate
→ Wallet balance showing 0 on all users (NEW-L pattern)
→ Any frontend showing blank/broken for > 10 min
```

### P2 — Non-critical (next sprint)
```
→ Single user payment failure
→ UI regression on non-payment feature
→ Analytics data lag > 1 hour
```

## Incident Response Protocol

### P0 Response
```
1. REVERT immediately (git revert last deploy)
2. Notify: all engineers (< 5 min)
3. Identify root cause (check Railway logs + Vercel logs)
4. Hotfix with test — DO NOT skip tests even in emergency
5. Deploy hotfix with manual approval gate
6. Post-mortem within 24 hours
7. Update C-78 with incident record
```

### P1 Response
```
1. Diagnose: check Vercel logs + Railway logs via MCP
2. Hotfix branch → fix + test → evidence in PR
3. Deploy after CI passes
4. Monitor: watch success rate for 30 min post-deploy
5. Document: add to C-02 violation tracker
```

## Log Patterns to Watch

```bash
# Payment create failures
[bff/payment/create] gateway error: 401  → x-internal-key empty (NEW-B)
[bff/payment/create] gateway error: 422  → wrong body (memo field?)
[bff/payment/create] missing userId      → tec_user cookie format
[bff/payment/create] network error       → Railway gateway down

# Auth failures
[bff/wallet/balance] 401                 → token expired (use createHandler)
[middleware] missing tec_user            → Hub SSO not setting cookies

# Gateway patterns
gateway error: 503                       → backend service sleeping (Railway free)
gateway error: 500                       → INTERNAL_SECRET mismatch (NEW-B)
```

## Payment Orphan Recovery

```
Orphan payment: payment created but stuck in 'pending'

Cause: Pi Browser closed mid-payment / network error

Automatic: cron job every 60 min checks orphan payments
  → calls /api/bff/payment/resolve-incomplete
  → Pi Network verify
  → update to completed / failed

Manual check:
  GET /api/bff/metrics → inspect incomplete_count
  If > 10 orphans → investigate payment-service outbox
```

## Circuit Breaker States (Pi SDK)

```
CLOSED    → Normal: Pi SDK calls go through
OPEN      → 3 consecutive failures → blocks Pi calls for 60s
HALF_OPEN → After 60s → trial call → success → CLOSED

Storage: localStorage key `tec_pi_cb`
Manual reset: piCircuitBreaker.reset()

Monitor: if users report "payment not opening" → check circuit breaker state
```
