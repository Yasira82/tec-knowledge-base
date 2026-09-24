# C-62 — SLO DEFINITIONS & PERFORMANCE STANDARDS
## Service Level Objectives — Enterprise Grade

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`
> **Binding SLOs:** **C-78 §2** is the authority and `manifests/slo-definitions.yaml` its
> machine-readable form (gated by `evals/check-slo-definitions.sh`). The **availability**
> figures in this file are stricter than the binding ones —
>
> | Service | This file | Binding (C-78 §2 · manifest) |
> |---|---|---|
> | Payment | 99.99% | **99.9%** |
> | Auth | 99.95% | **99.9%** |
> | Gateway | 99.95% | **99.9%** |
>
> — and are kept as **engineering stretch goals, not SLOs**: nothing alerts on them and no
> error budget is spent against them. The latency, error-rate and Pi-API figures below have
> no binding counterpart yet; they are guidance until the manifest adopts them.
> (Decision recorded 2026-09-24, `audits/KB_REMEDIATION_PLAN_2026-09-24.md`.)

---


---

## 1. What an SLO is and why it matters

```
SLO = Service Level Objective
تعريف رسمي لمستوى الأداء المقبول

بدون SLO:
  "الـ system بطيء" → مش واضح
  "فيه مشكلة" → مش محدد

مع SLO:
  "Gateway p99 > 100ms" → violation مؤكد → action مطلوب
  "Payment error rate > 0.1%" → alert → investigate
```

---

## 2. SLOs — PER SERVICE

### API Gateway (:3000)

| Metric | Target | Alert Threshold |
|---|---|---|
| Availability | 99.9% | < 99.5% |
| p50 latency | < 50ms | > 100ms |
| p95 latency | < 200ms | > 500ms |
| p99 latency | < 500ms | > 1000ms |
| Error rate (5xx) | < 0.1% | > 0.5% |
| Request timeout | 25s | — |
| Proxy timeout | 30s | — |

### Auth Service (:5001)

| Metric | Target | Alert Threshold |
|---|---|---|
| Availability | 99.95% | < 99.9% |
| Login p95 | < 1s | > 2s |
| Refresh p95 | < 300ms | > 500ms |
| Token verify p95 | < 50ms | > 100ms |
| Error rate | < 0.05% | > 0.2% |

### Payment Service (:5003) — the most critical

| Metric | Target | Alert Threshold |
|---|---|---|
| Availability | 99.99% | < 99.95% |
| Create p95 | < 500ms | > 1s |
| Approve p95 | < 2s | > 5s |
| Complete p95 | < 3s | > 8s |
| Error rate | < 0.01% | > 0.05% |
| Outbox lag | < 10s | > 30s |
| Circuit breaker trips | 0 per day | > 3 per day |
| Reconciliation coverage | 100% | < 99% |

### Wallet Service (:5002)

| Metric | Target | Alert Threshold |
|---|---|---|
| Availability | 99.99% | < 99.95% |
| Balance read p95 | < 100ms | > 300ms |
| Credit operation p95 | < 200ms | > 500ms |
| Error rate | < 0.01% | > 0.05% |
| Negative balance incidents | 0 | > 0 → P0 |

### Realtime Service (:5010)

| Metric | Target | Alert Threshold |
|---|---|---|
| WebSocket connections | Unlimited | — |
| Event delivery p95 | < 500ms | > 2s |
| Connection error rate | < 1% | > 5% |

### Frontend (Vercel)

| Metric | Target | Alert Threshold |
|---|---|---|
| LCP (Largest Contentful Paint) | < 2.5s | > 4s |
| FID (First Input Delay) | < 100ms | > 300ms |
| CLS (Cumulative Layout Shift) | < 0.1 | > 0.25 |
| Hub page load | < 3s | > 5s |
| Payment modal open | < 500ms | > 1s |

---

## 3. UPTIME BUDGET

```
99.9% uptime = 8.7 hours downtime/year
99.95% uptime = 4.4 hours downtime/year
99.99% uptime = 52 minutes downtime/year

TEC Targets:
  Payment + Wallet: 99.99% → 52 min/year budget
  Auth + Gateway:   99.95% → 4.4 hours/year budget
  Other services:   99.9%  → 8.7 hours/year budget
  Frontend (Vercel): 99.9% (Vercel SLA)
```

---

## 4. ERROR BUDGET POLICY

```
لو Error Budget انتهى (> Alert Threshold):
  🔴 P0: Payment/Wallet → immediate on-call response
  🟠 P1: Auth/Gateway → response within 1 hour
  🟡 P2: Other services → response within 4 hours

Error Budget Calculation:
  Budget = (1 - SLO) × time window
  Payment: (1 - 99.99%) × 30 days = 4.32 minutes
  Gateway: (1 - 99.95%) × 30 days = 21.6 minutes
```

---

## 5. PAYMENT FINANCIAL SLOs — the most important

```
Financial Accuracy:
  ✅ Zero negative balance incidents
  ✅ Zero double-charge incidents
  ✅ Zero lost payment completions
  ✅ 100% Outbox delivery (within 10s)
  ✅ 100% Reconciliation coverage (within 60min)

Pi Network Integration:
  Pi API success rate: > 99%
  Circuit breaker trips: 0 per day (alert if > 3)
  Incomplete payment recovery: 100%
```

---

## 6. CURRENT BASELINES (May 2026)

```
من الـ timeout settings في الكود:

Gateway request timeout: 25s (main.ts:575)
Proxy timeout:           30s (proxy.service.ts:108)
Redis BLOCK timeout:     5s  (consumers)
Health check timeout:    2s  (main.ts:686)
SDK timeout:             15s (tec-sdk BaseClient)
BFF fetchWithTimeout:    25s (Hub pi-login)

Prometheus metrics موجودة في payment-service:
  http_request_duration_seconds (histogram)
  payment_created_total
  payment_completed_total
  circuit_breaker_state
```

---

## 7. MONITORING STACK

```
Current:
  ✅ Pino structured logs (all services)
  ✅ Sentry error tracking (frontend)
  ✅ Prometheus metrics (payment-service only)
  ✅ Railway built-in metrics (CPU/Memory/Network)
  ✅ Health check endpoints (/health + /health/ready)

Missing (ISS-010 — post-Mainnet):
  □ Prometheus في كل الـ 12 services
  □ Grafana dashboard (SLO visualization)
  □ Alert manager (SLO breach alerts)
  □ Distributed tracing (OpenTelemetry)
```

---

## 8. PERFORMANCE BUDGETS (apply immediately)

```typescript
// tec-api-gateway/src/main.ts — موجود بالفعل ✅
res.setTimeout(25000, () => {
  res.json({
    success: false,
    error: { code: 'GATEWAY_TIMEOUT', message: 'Request timed out' }
  });
});

// ✅ Recommended: أضف per-route timeouts في payment
// payment create: 10s max
// payment approve (Pi API): 30s max
// payment complete (Pi API): 30s max

// tec-sdk/src/api/baseClient.ts — موجود ✅
timeout: 15000  // 15s لكل BFF → SDK call
```

---

## 9. MAINNET PERFORMANCE CHECKLIST

```
قبل Pi Network submission:
  □ قياس Gateway p95 تحت load (k6)
  □ قياس Payment create end-to-end p95
  □ قياس Auth login p95
  □ قياس Hub page LCP
  □ قياس PaymentModal open time
  □ اختبار circuit breaker behavior
  □ اختبار Outbox delivery time
  □ تأكيد Reconciliation running (60min cron)

k6 Load Tests (موجودة في codebase):
  k6/payment-flow.js ← شغّل قبل submission
```

---

## 10. SLO VIOLATION RESPONSE

```
P0 — Payment/Wallet SLO breach:
  1. Check Railway logs → payment-service
  2. Check circuit breaker state → /metrics
  3. Check Pi Network status → api.minepi.com
  4. Check Redis lag → XLEN payment:outbox
  5. Reconciliation covers within 60min

P1 — Auth/Gateway SLO breach:
  1. Check health endpoints
  2. Check Railway memory/CPU
  3. Check Redis connections
  4. Restart service if needed (Railway)

P2 — Frontend performance:
  1. Check Vercel build logs
  2. Check Core Web Vitals in Vercel Analytics
  3. Check bundle size (next build output)
```
