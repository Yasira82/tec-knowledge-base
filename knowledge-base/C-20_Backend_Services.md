# C-20 — BACKEND SERVICES MAP
## 12 Microservices — Ports + URLs + Patterns

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Code Verified]` — Canonical Port Authority for the platform
> **Port Scheme:** Gateway `:3000` · Services `:5001`–`:5011` (supersedes any other reference)
> Last verified against code + runtime: 2026-09-24 (and weekly by `scripts/check-drift.py`) — every port below is the `main.ts`
> default on tec-core-backend `main` AND the port in the gateway's boot routing table after
> ADR-005 (C-02 Session 56m). tec-core-backend's CLAUDE.md carried a 4000-series table until its #333; it now matches.

---

## 1. SERVICE REGISTRY

| Service | Port | Framework | Network (after ADR-005) |
|---|---|---|---|
| api-gateway | 3000 | NestJS+Express | **public** — `api-gateway-production-6a68.up.railway.app` (every client enters here) |
| auth | 5001 | NestJS | private — `triumphant-spirit.railway.internal` |
| wallet | 5002 | Express* | private — `wallet-service.railway.internal` |
| payment | 5003 | Express* | private — `payment-service.railway.internal` · `PORT` is **required** in its env schema (no code default) |
| asset | 5004 | NestJS | private — `tec-core-backend-a5f9.railway.internal` |
| identity | 5005 | NestJS | private — `identity-service.railway.internal` |
| notification | 5006 | NestJS | private — `notification-service.railway.internal` |
| storage | 5007 | NestJS | private — `tec-core-backend-4aa8.railway.internal` |
| kyc | 5008 | NestJS | private — `kyc-service.railway.internal` |
| commerce | 5009 | NestJS | private — `commerce-service.railway.internal` |
| realtime | 5010 | NestJS+WS | **public** — the browser opens its WebSocket directly (gateway has no `ws: true`) |
| analytics | 5011 | NestJS+Fastify | private — `analytics-service.railway.internal` · data in Supabase PostgreSQL |

The nine private services answer Railway's "Unexposed service" 404 from the internet; the
gateway reaches them over `*.railway.internal` with `x-internal-key` (ADR-005). Do not
re-add a public domain to call one directly — go through the gateway.

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
  ✅ INTERNAL_SECRET required (env schema: min 32 chars) — NEW-B closed
```

---

## Health Check URLs

```
Hub:      https://hub.tecosystem.app/api/health
Gateway:  https://api-gateway-production-6a68.up.railway.app/health
Services: GET <gateway>/health/detailed  — the gateway checks all 11 over the private
          network (the services' own public URLs were removed by ADR-005)
```
