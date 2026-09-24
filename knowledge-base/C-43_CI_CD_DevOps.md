# C-43 — CI/CD DevOps Pipeline
## GitHub Actions + Railway + Vercel

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---


---

## 1. PIPELINE MAP

| Repo | CI Workflows | Deploy |
|---|---|---|
| Tec-core-backend | ci.yml + codeql.yml + load-test.yml | Railway auto |
| Tec-App (Hub) | ci.yml + e2e.yml | Vercel auto |
| Tec-Commerce | ci.yml | Vercel auto |
| Tec-Assets | ci.yml | Vercel auto |
| Tec-Ecommerce | ci.yml | Vercel auto |
| TEC-SDK | publish.yml + codeql.yml | npm manual |
| tec-auth | publish.yml | npm manual |
| tec-ui | publish.yml | npm manual |

---

## 2. BACKEND CI (Tec-core-backend)

```yaml
jobs:
  policy-check:
    # يبلوك:
    # - jwt.decode(
    # - localStorage.*token
    # - origin: '*'
    # - body.userId
    # - continue-on-error: true على build/test/deploy

  test:
    strategy:
      matrix:
        service: [auth, wallet, payment, identity, commerce, storage, notification, kyc, asset, realtime]
    steps:
      - npm ci
      - npm test -- --coverage

  coverage-gate:
    # 60% lines threshold

  docker-build:
    # Multi-stage, node:20-slim, non-root USER, GHA cache

  deploy:
    # Railway CLI, max-parallel: 4
    # ❌ NO continue-on-error
```

---

## 6. DOCKER STANDARD

```dockerfile
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM node:20-slim AS runner
WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules

USER appuser
EXPOSE ${PORT}
HEALTHCHECK --interval=30s --timeout=10s \
  CMD curl -f http://localhost:${PORT}/health/ready || exit 1

CMD ["node", "dist/main.js"]
```

---

## 9. ENVIRONMENT VARIABLES CHECKLIST

### Every frontend app needs
```
NEXT_PUBLIC_PI_APP_ID=        # منفصل لكل app
NEXT_PUBLIC_PI_SANDBOX=false  # ✅ Mainnet
NEXT_PUBLIC_APP_NAME=
NEXT_PUBLIC_APP_URL=
NEXT_PUBLIC_HUB_URL=https://hub.tecosystem.app
API_GATEWAY_URL=              # server-only ← مش NEXT_PUBLIC_
JWT_SECRET=
SSO_SECRET=
```

### Backend services need
```
DATABASE_URL=
REDIS_URL=
JWT_SECRET=
REFRESH_SECRET=
INTERNAL_SECRET=    # ≥ 32 chars (NEW-B fix)
PI_API_KEY=
PI_SANDBOX=false    # ✅ Mainnet
PI_WEBHOOK_SECRET=
SENTRY_DSN=
```