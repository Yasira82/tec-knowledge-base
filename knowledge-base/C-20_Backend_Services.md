# C-20 — BACKEND SERVICES MAP
## 12 Microservices — Ports + URLs + Patterns

---

## 1. SERVICE REGISTRY

| Service | Port | Framework | Railway URL |
|---|---|---|---|
| api-gateway | 3000 | NestJS+Express | api-gateway-production-6a68.up.railway.app |
| auth | 5001 | NestJS | auth-service-pi.up.railway.app |
| wallet | 5002 | Express* | wallet-service-production-445d.up.railway.app |
| payment | 5003 | Express* | payment-service-production-90e5.up.railway.app |
| identity | 5004 | NestJS | identity-service-production-fe57.up.railway.app |
| commerce | 5005 | NestJS | commerce-service-production.up.railway.app |
| storage | 5006 | NestJS | storage-sevice-production.up.railway.app ⚠️ typo |
| notification | 5007 | NestJS | notification-service-production-dc81.up.railway.app |
| kyc | 5008 | NestJS | kyc-service-production-ba73.up.railway.app |
| asset | 5009 | NestJS | asset-service-production-54c4.up.railway.app |
| realtime | 5010 | NestJS+WS | realtime-service-production-9630.up.railway.app |
| analytics | 5011 | NestJS+Fastify | Supabase PostgreSQL |

---

## 5. PAYMENT SERVICE (:5003)

```
Patterns:
  ✅ 5-state lifecycle + ALLOWED_TRANSITIONS
  ✅ Outbox Pattern (Worker polls 5s)
  ✅ Idempotency (Redis NX)
  ✅ Circuit Breaker (5 fail → 60s open)
  ✅ Reconciliation (cron 60min)
  ✅ getPiApiKey(source) ← per-app API key
  ✅ PI_SANDBOX: z.enum (no default)
  ⚠️ NEW-B: INTERNAL_SECRET optional (يجب required)
```

---

## Health Check URLs

```
Hub:     https://hub.tecosystem.app/api/health
Gateway: https://api-gateway-production-6a68.up.railway.app/health
Auth:    https://auth-service-pi.up.railway.app/health
Payment: https://payment-service-production-90e5.up.railway.app/health
```