# Status snapshot, June 2026 (DONE · PENDING · NEXT · PLATFORM STATE)

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **historical record**, not current state — for current state read C-02.

## DONE ✅ (تراكمي)

| Item | التفاصيل |
|------|----------|
| P1 violations | كلها closed (NEW-A → NEW-J) |
| **NEW-B** | **INTERNAL_SECRET set على Railway — 4 services ✅** |
| Security audit (10 items) | PRs #22 Ecommerce + #65 Backend + #19 Commerce + #21 Hub |
| Mode 1 + Mode 2 + ADR-007 | كل 4 apps ✅ |
| CORS | 5 domains في Gateway + Auth + Payment ✅ |
| Hub sub-pages | KYC + Subscription + Notifications + Profile ✅ |
| tec-ui v1.2.1 | PaymentModal + createU2APayment() + 75 tests 80% ✅ |
| Consumer apps on v1.2.1 | Ecommerce + Commerce + Assets ✅ |
| Tests coverage ≥ 60% | كل repos — tec-auth 95% (46 tests), tec-ui 80% (75 tests) ✅ |
| Commerce schema fix | PR #20 merged |
| Ecommerce 503 fix | PR #25 merged |
| NEW-C | ADR-006 في C-64 — CSRF exclusion موثق ✅ |
| NEW-E | tec-ui 75 tests 80% coverage ✅ |
| NEW-F | Pi App ID: `ecommerce-app-71ca4d3e462eaf54` + `ecommerce.tecosystem.app` — C-01 + CLAUDE.md ✅ |
| NEW-G | Dual-Mode في ADR-002 (C-64) + C-12 ✅ |
| Audit Fix — Commerce | Railway URL removed, x-internal-key + Zod + ADR-007 — PR #22 merged ✅ |
| Audit Fix — Assets | Railway URL removed, x-internal-key + Zod + 503 guard — main c411fe9 ✅ |
| **Pi App IDs — كل 4 apps** | Ecommerce + Commerce + Assets + Hub — موثقة في C-01 ✅ |
| **CLAUDE.md session start → main** | كل repos — branch محدّث لـ main ✅ |
| **Comprehensive Audit fixes — Ecommerce** | **✅ ON MAIN** — pushed directly, PR #27 closed. CI ✅ (5d44c501) |
| **Comprehensive Audit fixes — Hub** | **✅ ON MAIN** — pushed directly, PR #24 closed. CI ✅ (275d6fd0) |
| Comprehensive Audit fixes — Commerce | pushed to main |
| Comprehensive Audit fixes — Assets | pushed to main |
| Hub — JWT decode forbidden fix | pushed to main (SHA: 687247d) |
| **Hub CI green** | **✅ CONFIRMED** — 2026 tests passing (commit 275d6fd0) |
| **Ecommerce CI fixes** | **✅** — test files aligned to resolve-based pattern (commit 33d2d141) |
| **Ecommerce payment fix** | **✅** — x-internal-key sent only when INTERNAL_SECRET SET (commit 5d44c501) |
| **Knowledge Base v3.1.0** | **✅ Phase 1+2+3+4** — Skills + MCP + Commands + CI + C-02 updated |
| **C-92 Platform Health Model** | **✅** — 5 dimensions × state machine × PHS composite score × dashboard spec × manual checklist |
| **Engineering Assessment (Session 9)** | **✅** — C-95 (Assessment) + C-57 reconciled (31 fixes) + C-40/C-41 synced + governance renamed |
| **C-93 Institutional Verification Constitution** | **✅** — v1.2 [Future Vision][Draft] — Tier-1 Constitutional Layer |
| **C-94 Governed Capability Constitution** | **✅** — v1.0 [Speculation][Draft] — Tier-1 Constitutional Layer |
| **C-95 Institutional Knowledge Constitution** | **✅** — v1.0 [Speculation][Draft] — Tier-1 Constitutional Layer |
| **C-96 Platform Runtime Constitution** | **✅** — v1.1 [Current State][Draft] — Health/Observability/Resilience — NEW-K/L/N/O ✅ VERIFIED |
| **C-97 Context Constitution** | **✅** — v1.0 [Speculation][Draft] — Tier-1 Constitutional Layer |
| **C-98 Institutional Construction Constitution** | **✅** — v1.0 [Speculation][Draft] — Tier-2 Asset |
| **C-99 Institutional Governance Constitution** | **✅** — v1.0 [Speculation][Draft] — Tier-1 — closes Institutional Operating Loop |
| **C-96 Platform Runtime Constitution** | **✅** — v1.1 [Current State][Draft] — Health/Observability/Availability/Resilience — NEW-K/L/N/O ✅ VERIFIED |
| **C-79 Institutional Memory Constitution** | **✅** — v1.0 [Speculation][Draft] — Tier-2 Asset (moved from C-96) |
| **Code Verified Inspection (Session 9)** | **✅** — NEW-K/L/M documented — Tec-App + tec-api-gateway — 9.3/10 |
| **P1 Fixes Applied (Session 10)** | **✅** — NEW-K/L/N/O VERIFIED — C-81 implementation guide applied — PRI 8.22 → 8.8+ |
| **ADR-007 Foreign Session Fix (Session 13)** | **✅** — `__TEC_PI_FOREIGN_SESSION` check in all 5 Ecommerce payment handlers — defense-in-depth for PiSdkLoader foreign session (piReady=true but Pi.authenticate fails) |
| **Ecommerce Buy Button Fix (Session 13)** | **✅** — Removed `disabled={!piReady}` from ProductCard — buttons always clickable, handleBuy does the redirect logic |
| **Knowledge Base v3.6.2 (Session 13)** | **✅** — 48 new files · 17 new C-docs (C-17/18/19 + C-79/80/81 + C-93→C-99 + C-116→C-118) · evals/ + scripts/ + architecture/ + manifests/ · Governance Charter v1.2 |

---

## PENDING ⚠️

| Item | الإجراء |
|------|----------|
| **NEW-M** | **✅ DONE** — `tec-api-gateway/src/config/service-registry.ts` موجود (Code Verified Session 14) |
| **P0-1 Outbox (ADR-004)** | ✅ DONE — wired atomically في approve/complete (PR #84) + **مُتحقَّق: دفعة حقيقية نجحت في الأبس بعد الـ deploy** |
| **P0-4 tec-sdk Railway URL** | 🟡 تأكيد — fallback URL في http-client.ts |
| External Re-Audit | بعد P0 backlog — المتوقع 9.0–9.5/10 |
| Port Conflict | C-10/C-20 (5001) vs README/Charters (4001) — يحتاج قرار موحّد |
| Commerce Domain | ✅ محسوم نهائيًا (21 Jun) — `commerce.tecosystem.app` (المسجّل في Pi Developer Portal) — متطابق عبر C-01/C-02/C-101/C-92/C-10 |
| Truth Framework | ✅ Tier الأساسي (C-00→C-23) مكتمل Truth+Governance State — الباقي قيد التبنّي التدريجي |

---

## NEXT 🔴 (Portal path)

```
1. ✅ Payment Unification (ADR-009) — DONE Session 14
2. ✅ P0-1 Outbox (ADR-004) — DONE (PR #84 merged + payment-verified in prod)
3. ✅ P0-2..P0-5 — all verified CLOSED (see reconciliation table)
4. ✅ P1/P2 hygiene batch (Session 14.1) — DONE:
     · .dockerignore على كل 12 service (4 ناقصة + تنظيف EOF/done) ✅
     · INTERNAL_SECRET startup guard unconditional — wallet كان آخر gap ✅
     · npm audit advisory (non-blocking) في CI لكل 4 apps ✅
     · Assets Zod "v4 drift" = stale — Assets أصلاً على zod ^3.23.8 (3.25.76) ✅
     · متبقي مؤجّل (مش hygiene): Sentry major drift (Assets v10 vs v8) → change متحقَّق منه لوحده · REALTIME_URL = ops env
4b. ✅ Re-audit fix (Session 14.1): payment-service bootstrap INTERNAL_SECRET guard
     made unconditional (PR #85) — last NODE_ENV-gated guard on the platform
5. ✅ Code-Verified Re-Audit (Session 14.1) → ~9.0–9.2 — كل البنود grep-verified
     (مراجعة ذاتية موثّقة بالكود — مش external مستقل؛ الخيار: self-review موثّق + Portal)
6. ✅ Session 14.4 — template completeness + package CI parity (tec-auth/tec-ui/tec-sdk)
7. ✅ P1 ops/env — ALL CONFIRMED (21 Jun 2026): PI_SANDBOX=false · REALTIME_URL ·
     Portal domains/IDs · Privacy/Terms URLs · real Mode-1+Mode-2 payment per app
8. 🟢 Portal Submission → Pi Network  ← CLEARED — submit per app (PORTAL_SUBMISSION_RUNBOOK)
```

### Portal-readiness checklist (Phase-0 gate) — ✅ ALL CLOSED
```
ENGINEERING (code) — ✅ all closed/verified:
  □✅ Payment Mode 1 (Hub) + Mode 2 (standalone) — both working, prod-verified
  □✅ Outbox event durability (ADR-004) + reconciliation (Pi source-of-truth)
  □✅ Security invariants: no jwt.decode · no localStorage tokens · no CORS *
       · INTERNAL_SECRET unconditional (12/12) · x-internal-key on gateway calls
  □✅ CSRF robust (double-submit OR first-party Origin) across SSO + Pi Browser
  □✅ .dockerignore 12/12 · DECIMAL(20,8) + balance>=0 · non-root Docker

OPS / ENV (Railway/Vercel/Pi Portal) — ✅ CONFIRMED 21 Jun 2026:
  □✅ INTERNAL_SECRET set on ALL 12 Railway services
  □✅ PI_SANDBOX=false verified in production (each Pi-paying app)
  □✅ REALTIME_URL set on Hub
  □✅ Pi Developer Portal: domains + App IDs registered & match production
  □✅ Privacy Policy + Terms URLs live on each app domain
  □✅ Real Mode-1 + Mode-2 payment verified per app

DEFERRED (non-blocking for Portal):
  □ Sentry major align (Assets v10 vs v8) — build-verified change
  □ tec-realtime-service tests · move vite/vitest to devDeps
```

---

## PLATFORM STATE

```
12 Railway services:   Active — INTERNAL_SECRET set ✅
24 apps (Vercel):     all registered + deployed + Mainnet subscriptions live
4 npm packages:       tec-auth + tec-ui (v1.2.1) + tec-sdk + tec-shared
PI_SANDBOX:           false (Mainnet)
tec-auth coverage:    95% (46 tests)
tec-ui coverage:      80% (75 tests)
Hub coverage:         95.5% (2026 tests) ✅
Hub CI:               ✅ GREEN — 2026 tests passing (commit 275d6fd0)
Ecommerce CI:         ✅ GREEN — ADR-007 foreign session fix (commit a586c1ca)
All repos coverage:   ≥ 60% ✅
All 24 apps:          Pro/subscription Mode 1 + Mode 2 real-Pi surfaces ✅
All P1 violations:    ✅ ZERO
All P2 violations:    ✅ ZERO
All Pi App IDs:       ✅ all 24 apps registered; canonical list = C-01 §4
All audit fixes:      ✅ ON MAIN — Hub + Ecommerce + Commerce + Assets
Last audit score:     7.65/10 (Session 3) → Architectural Review 9.1/10 (Session 8)
Architectural Review: Knowledge Architecture 9.5+/10 | Platform Engineering 9.0–9.2/10
CLAUDE.md:            ✅ session start → main في كل repos
Knowledge Base:       ✅ v3.10.0 — 112 C-docs + 16 skills + 16 charters + 13 CI gates
Pending PRs:          NONE — all fixes on main ✅
Latest audit:         ✅ Session 14 (2026-06-20) → ~9.0/10 (was ~6.5–7.0) — all P0 closed (Outbox live + payment-verified)
NEXT:                 deepen real product functionality one gated app at a time
```
