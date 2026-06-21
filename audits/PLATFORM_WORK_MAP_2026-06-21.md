# TEC Platform — Engineering Work Map / Roadmap

> **Date:** 2026-06-21 · **Owner:** Platform Engineering · **Status doc:** living
> **Companion:** `knowledge-base/C-02___CURRENT_STATE_.md` (state) · `C-12_Dual_Mode_Payment.md` (payment) · `audits/PORTAL_SUBMISSION_RUNBOOK_2026-06-21.md`
> **KB health:** 10/10 integrity gates green · registry 99/99 (100% coverage, 0 errors)

---

## 0. Where we are — one line
Payment works (Mode 1 + Mode 2, prod-verified); the CSRF/payment regression is closed **and** guarded; every repo's CI is at parity; the new-app template is Portal-ready. **P0 + P1 + P2 are CLOSED, and P3's safe code part is done (security bumps) — cleared for Portal submission.** Remaining P3 is ops-gated (publish tec-auth v1.1.0) or infra (SLOs).

---

## 1. Repo status board

| Repo | Role | State | Open items |
|------|------|-------|-----------|
| tec-app (Hub) | Conductor / SSO / payment orchestrator | ✅ healthy | — |
| tec-ecommerce | marketplace | ✅ payment-verified | — |
| tec-assets | NFT/assets | ✅ healthy (Sentry→v8) | — |
| tec-commerce | merchant | ✅ healthy | — |
| tec-core-backend | 12 microservices | ✅ healthy (realtime tests added) | — |
| @yasser172/tec-sdk | server BFF SDK | ✅ complete CI | — |
| @yasser172/tec-auth | auth package | ✅ CSRF fixed + full CI | branch-protection check names |
| @yasser172/tec-ui | design system | ✅ CodeQL added | raise coverage over time |
| tec-template-base | new-app golden template | ✅ Portal-ready | — |
| tec-knowledge-base | governance | ✅ 10/10 gates | — |

---

## 2. Done (this cycle — Session 14.x)

```
Payment subsystem
  ✅ ADR-009 unified contract (amount:number · /api/payment/* · x-internal-key)
  ✅ CSRF = middleware-only (double-submit OR first-party Origin) — Pi-Browser safe
  ✅ Removed duplicate route-level CSRF (ecommerce create/approve/complete/orders + Hub)
  ✅ Outbox (ADR-004) + reconciliation (Pi source-of-truth)
  ✅ Permanent CI guard against route-level CSRF (all 4 apps)
  ✅ Open-redirect blocked in all 4 SSO callbacks

Hardening / hygiene
  ✅ .dockerignore on 12 services · INTERNAL_SECRET unconditional · npm-audit advisory
  ✅ tec-auth CSRF fix (package-level) + real CI (build/codeql/publish) + 80% gate
  ✅ tec-ui CodeQL + coverage floor · tec-sdk verified complete

Template + docs
  ✅ tec-template-base completed (payment/SSO/legal/CSRF/CI/tests/checklist)
  ✅ /privacy + /terms on all 4 apps + template
  ✅ KB: C-12 §11 anti-regression, re-audit (~9.0–9.2), Portal runbook, this roadmap
```

---

## 3. Remaining — prioritised

### P1 — Ops / env — ✅ COMPLETE (confirmed 21 Jun 2026)
```
✅ PI_SANDBOX=false verified in production for each Pi-paying app
✅ REALTIME_URL set on Hub (closes /api/bff/realtime 500s)
✅ Pi Developer Portal: domains + App IDs match production
✅ Privacy + Terms URLs registered per app in the Portal
✅ Real end-to-end Pi payment per app: Mode 1 (Hub) AND Mode 2 (standalone)
✅ tec-auth branch protection: required check names updated
```

### P2 — Deferred quality — ✅ COMPLETE (21 Jun 2026)
```
✅ Sentry major-version alignment — Assets @sentry/nextjs v10 → v8 (build-verified)
✅ tec-realtime-service unit tests — 0 → 9 (gateway + health controller)
✅ Move vite plugin to devDeps — ecommerce · assets · commerce
○ Raise tec-ui coverage floor as components gain tests (ongoing — floor set 72/62/68/75)
```

### P3 — Forward / strategic — 🟡 PARTIAL (safe code part done 21 Jun 2026)
```
✅ npm-audit triage + non-breaking fixes — next 15.5.12→15.5.19 (+ ws/form-data/
   engine.io); high 6→2 per app, all 4 apps. Lesson: use package-scoped bumps,
   not broad `npm audit fix` (it reshuffled vite/rolldown → broke Hub vitest JSX).
⏸️ Promote npm-audit advisory → blocking — NOT yet; residual high=2 (@sentry+rollup
   want v10 vs platform v8) + critical=1 (happy-dom, test-only devDep). Stays advisory.
⏸️ Publish tec-auth v1.1.0 + bump consumers — ops-gated (NPM_TOKEN + Release; workflow ready)
⏸️ Migrate apps' inline middleware → package middleware — AFTER v1.1.0 published
   (else apps pull old buggy 1.0.0 and re-break payments)
⏸️ Observability SLOs (C-78) wired to dashboards — infra/ops
```

> **P3 forward sequence:** merge PRs → cut a tec-auth **Release** (fires `publish.yml`) →
> bump the 4 apps + template to `@yasser172/tec-auth@^1.1.0` → optionally migrate
> inline middleware → package middleware → re-triage npm-audit → consider flipping to blocking.

---

## 4. Submit-to-Portal sequence

```
1. Confirm all §3 P1 ops/env items
2. Real Pi payment smoke test per app (Mode 1 + Mode 2)
3. Submit each app in the Pi Developer Portal (see PORTAL_SUBMISSION_RUNBOOK)
4. Monitor: payment 403s (guard prevents the known regression), reconciliation, realtime
```

---

## 5. Guardrails now permanent (won't regress silently)
- CI **payment-policy** in every app: blocks `x-service-secret` / string `amount` / **route-level CSRF**.
- CI **CodeQL** on every app + tec-sdk + tec-ui.
- Coverage gates: tec-auth 80% · tec-ui floor · tec-sdk threshold · payment-service.
- KB **10 integrity gates** keep governance honest (registry/truth-framework/authority).
- Template encodes all of the above → new apps inherit correctness by default.
