# P0 — Discovery & Repository Mapping · cycle 2026-11-11 · Run 1

**Status: PASSED_WITH_FINDINGS** · Gate A met · [Code Verified] at `origin/main`, 11 Nov 2026

## What exists

**30 repositories**: 24 apps, 5 platform repositories, the knowledge base. Every entry in
`architecture/app-fleet.yaml` has a clone; no clone is outside the fleet list.

### Apps

| Kind | Apps | Stack |
|---|---|---|
| Hub (control plane) | Tec-App (`tec-frontend/`) | Next 15.5.29 · 542 files · 187 test files |
| First-generation apps | Tec-Commerce · Tec-Assets · Tec-Ecommerce | Next 15.5.29 · tec-ui 2.1.0 (pinned, not a range) |
| Made from `tec-template-base` | 20 apps, tec-nbf and tec-brookfield included | Next 15.5.29 — **except tec-nbf and tec-brookfield: 15.5.12** (TEC-AUDIT-0002) |

### Platform

| Repository | Last commit on main | Role |
|---|---|---|
| Tec-core-backend | 2026-11-11 | 20 services + backup-job + shared + service template |
| tec-template-base | 2026-11-11 | the starter every new app is made from |
| TEC-SDK (`@yasser172/tec-sdk`) | 2026-09-13 | server-side BFF SDK |
| Tec-ui (`@yasser172/tec-ui`) | 2026-09-13 | design system |
| tec-auth (`@yasser172/tec-auth`) | 2026-09-19 | auth package |

The three npm packages have not changed in eight weeks while their consumers moved daily.
That is a fact, not a defect; P10 compares the versions published with the ranges consumed.

### Backend services (Tec-core-backend)

| Framework | Services |
|---|---|
| Nest + Express (Nest 10 / Express 4) | tec-api-gateway (3000) · tec-auth-service (5001) · tec-wallet-service (5002) · tec-realtime-service (5010) |
| Express, no Nest | tec-payment-service (`server.ts`; port from env, C-20) |
| Nest 11 + Fastify 5 | analytics (5011) · asset (5004) · commerce (5009) · identity (5005) · kyc (5008) · notification (5006) · storage (5007) · ai · business · connection · life · nexus · platform · search · trust (PORT required, no default) |
| Node job | tec-backup-job |

Prisma schemas: 18 of 20 services (gateway and realtime have none — correct for the gateway,
C-47 Forbidden #4). Migrations on main: commerce 12, life 8, auth 7, payment 5, wallet 5,
platform 3, notification 3, analytics 2, nexus 2, one each for the rest; identity 0 (it uses
its own `db push` variant, by design). `scripts/migrate.cjs` present in 17 services; storage
runs migrations from its entrypoint.

### Databases and external integrations (found in code)

PostgreSQL (one per service, through Prisma) · Redis (event bus and caches) · Supabase
(analytics) · Pi Platform API (auth-service and payment-service only — P1-C18 CLEAN) · Pi
Horizon, read-only ledger (analytics, nexus, payment) · AI providers: Groq, Anthropic,
Gemini, OpenRouter (Hub and ai-service) · Tavily (search) · Cloudflare R2 (storage) · Upstash
· Sentry · OKX and CoinGecko (prices).

### Deployment targets

Apps on Vercel; backend services and the backup job on Railway (C-20, C-78). Verified in
P8, not here.

## Findings

| ID | Severity | Title |
|---|---|---|
| TEC-AUDIT-0001…0008 | — | Carried from the 11 Nov baseline review (two closed, six open) |
| TEC-AUDIT-0009 | MEDIUM | Generated C-11 and C-44 are stale against the code |
| TEC-AUDIT-0010 | LOW | Load tests live in a nested `tec-core-backend/tec-core-backend/k6/` |
| TEC-AUDIT-0017 | INFO — **invalid**, closed | Raised as "C-20 misses eight services"; C-20 lists all 20 by short name. The real gap (a hand-typed service list in check-drift) is fixed |

Full records: `findings.json`. Evidence: `evidence.md`.
