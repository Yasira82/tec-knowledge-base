# C-11 — REPOSITORY MAP

9 Repos — Roles + Key Files + Patterns

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Code Verified]`

## 1. Tec-core-backend (Backend Monorepo)

GitHub: Yasira82/Tec-core-backend → Railway
Stack:  NestJS 10 + Express + Prisma 5.22 + PostgreSQL 16

Structure:
```
  shared/                  ← @yasser172/tec-shared v1.1.0
  tec-api-gateway/         ← :3000 — entry point
  tec-auth-service/        ← :5001
  tec-wallet-service/      ← :5002
  tec-payment-service/     ← :5003
  tec-identity-service/    ← :5004
  tec-commerce-service/    ← :5005
  tec-storage-service/     ← :5006
  tec-notification-service/ ← :5007
  tec-kyc-service/         ← :5008
  tec-asset-service/       ← :5009
  tec-realtime-service/    ← :5010
  tec-analytics-service/   ← :5011
```

## 2. Tec-App (Hub)

GitHub: Yasira82/Tec-App → hub.tecosystem.app (Vercel)
Stack:  Next.js 15 App Router + TypeScript strict

## 3. Tec-Commerce

GitHub: Yasira82/Tec-Commerce → commerce.tecosystem.app (Vercel)
Status: ✅ Reference Implementation for Dual-Mode Payment

## 4. Tec-Assets

GitHub: Yasira82/Tec-Assets → assets.tecosystem.app (Vercel)

## 5. Tec-Ecommerce

GitHub: Yasira82/Tec-Ecommerce → ecommerce.tecosystem.app (Vercel)

## 6. TEC-SDK

GitHub: Yasira82/TEC-SDK → npm @yasser172/tec-sdk v1.2.2
Architecture: TecSdk Facade → 7 Clients (auth | wallet | payment | assets | commerce | notifications | health)

## 7. tec-auth

GitHub: Yasira82/tec-auth → npm @yasser172/tec-auth v1.0.0

Exports:
```
  createAuthMiddleware()     ← Next.js middleware factory
  getAccessToken()           ← من cookie
  getCsrfToken()             ← من cookie
  getStoredUser()            ← من cookie
  loginWithPi()              ← Pi authenticate + BFF call
  refreshAccessToken()       ← dedup queue
  ssoRedirect()              ← redirect to Hub SSO
  usePiAuth()                ← React hook
```

## 8. Tec-ui

GitHub: Yasira82/Tec-ui → npm @yasser172/tec-ui
Current Published: v1.1.0 | Next Planned: v1.2.0

## 9. tec-template-base

GitHub: Yasira82/tec-template-base
Purpose: Base template for all new apps in the 24 apps