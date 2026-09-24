# C-45 — OBSERVABILITY & MONITORING
## Sentry + Pino + Prometheus + Redis

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---


---

## 1. CURRENT STATE

| Tool | Where | Status |
|---|---|---|
| Sentry | Frontend (Hub + apps) | ✅ |
| Pino | Backend (all services) | ✅ |
| Prometheus | payment-service only | ⚠️ ISS-010 |
| Railway Metrics | CPU + Memory | ✅ |
| Distributed Tracing | — | ❌ |
| Centralized Logging | — | ❌ |
| Grafana | — | ❌ |

---

## 3. PINO (Backend)

```typescript
export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',

  // ✅ Redaction — لا secrets في logs
  redact: {
    paths: [
      'accessToken', 'refreshToken', 'authorization',
      'headers.authorization', 'headers["x-internal-key"]',
      '*.password', '*.token', '*.secret',
    ],
    censor: '[REDACTED]',
  },
});

logger.info({ userId, paymentId }, 'Payment created');
logger.error({ err, userId }, 'Payment failed');
```

---

## 5. WHAT'S MISSING (ISS-010)

```
❌ Prometheus في 11 service تانية
❌ Grafana dashboard
❌ Centralized log aggregation
❌ Distributed tracing (OpenTelemetry)
❌ Alerting
❌ SLO dashboards

Fix (post-Mainnet):
  Phase 1: Prometheus في كل service
  Phase 2: Grafana + alerting
  Phase 3: OpenTelemetry distributed tracing
```

---

## 7. HEALTH CHECKS

```typescript
// GET /health
{ status: 'ok', service: 'payment', version: '1.0.0' }

// GET /health/ready (DB + Redis check)
{ status: 'ready', database: 'ok', redis: 'ok' }

// Dockerfile healthcheck
HEALTHCHECK --interval=30s --timeout=10s \
  CMD curl -f http://localhost:${PORT}/health/ready || exit 1
```