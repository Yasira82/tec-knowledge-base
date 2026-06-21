# TEC Platform — Pi Portal Submission Runbook

> **Date:** 2026-06-21 · **Status:** ✅ **Portal-ready** (all engineering + ops items closed)
> **Scope:** the 4 Pi-paying apps (Hub, Ecommerce, Assets, Commerce)
> **Companion:** payment architecture in `knowledge-base/C-12_Dual_Mode_Payment.md` · readiness in `knowledge-base/C-02___CURRENT_STATE_.md` · re-audit in `audits/EXTERNAL_AUDIT_2026-06-20_Session14.md`

---

## 1. Per-app registration

| App | Pi App ID | Production domain | Privacy | Terms | PI_SANDBOX |
|-----|-----------|-------------------|---------|-------|------------|
| Hub | `tec-app-923b947851f9dfe1` | `hub.tecosystem.app` | `/privacy` | `/terms` | false |
| Ecommerce | `ecommerce-app-71ca4d3e462eaf54` | `ecommerce.tecosystem.app` | `/privacy` | `/terms` | false |
| Assets | *(confirm in Pi Portal)* | `assets.tecosystem.app` | `/privacy` | `/terms` | false |
| Commerce | `commerce-app-68aa99081fc1897a` | `commerce.tecosystem.app` | `/privacy` | `/terms` | false |

> The Pi App ID + registered domain in the Pi Developer Portal MUST match the production domain exactly — a mismatch breaks `Pi.init()` / payment authorisation.

---

## 2. Final readiness checklist (all ✅)

```
ENGINEERING (code — verified in main)
  ✅ Dual-mode payment: Mode 1 (Hub modal) + Mode 2 (standalone) — both prod-verified
  ✅ Unified payment contract (ADR-009): amount=number, /api/payment/*, x-internal-key
  ✅ Outbox event durability (ADR-004) + reconciliation (Pi = source of truth)
  ✅ CSRF enforced ONCE in middleware (double-submit OR first-party Origin) — P2
  ✅ CI guard blocks any route-level CSRF check (regression-proof) — all 4 apps
  ✅ Open-redirect blocked in SSO callback — all 4 apps
  ✅ Security: no jwt.decode · no localStorage tokens · no CORS * · DECIMAL(20,8) · non-root Docker
  ✅ .dockerignore on all 12 backend services · INTERNAL_SECRET startup guard unconditional

OPS / ENV (Railway · Vercel · Pi Portal)
  ✅ PI_SANDBOX=false in production (each Pi-paying app)
  ✅ REALTIME_URL set on Hub
  ✅ INTERNAL_SECRET set + identical across all 12 services
  ✅ Pi Portal domains + App IDs match production
  ✅ Privacy + Terms pages live + URLs registered per app

DEFERRED (non-blocking for Portal)
  □ Sentry major-version alignment (Assets v10 vs v8) — build-verified change
  □ tec-realtime-service unit tests · move vite/vitest to devDeps
```

---

## 3. Submission steps (per app)

1. In the Pi Developer Portal, open the app and confirm: **App ID**, **production domain**, **Privacy URL**, **Terms URL**.
2. Confirm **Mainnet** mode (sandbox OFF) for the app.
3. Run a **real Pi payment** end-to-end: standalone (Mode 2) **and** via the Hub (`/hub?pay=1`, Mode 1). Confirm the payment completes **and** the downstream record (order / asset / subscription) is created.
4. Submit the app for Pi review.
5. Repeat for each of the 4 apps.

> Release order if redeploying backend: `tec-core-backend → tec-sdk → tec-auth → tec-ui → all 4 apps (simultaneously)`.

---

## 4. Post-submission monitoring

- **Payments:** watch for `403` on `/api/bff/payment/*` or `/api/bff/orders` — the CI guard prevents the route-level-CSRF regression, but verify Vercel logs after each deploy.
- **Stuck payments:** self-heal hourly via `tec-payment-service` reconciliation (Pi = source of truth); on-demand via `/api/admin/reconcile`.
- **Realtime:** `/api/bff/realtime` depends on `REALTIME_URL` being set on Hub.

---

## 5. Key lesson carried forward (do not repeat)

CSRF must be enforced in **exactly one layer — the middleware** (double-submit OR first-party Origin). A duplicate route-level CSRF check 403's legitimate payments in Pi Browser (the `sameSite=None` cookie is dropped). A route may *forward* `x-csrf-token` downstream, but must **never validate** it. Enforced by the per-app CI guard (see `C-12 §11`).
