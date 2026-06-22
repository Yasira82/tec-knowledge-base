# C-02 — CURRENT STATE
## Living Document — Updated End of Every Session

> ⚠️ **SESSION START RULE:** هذا أول ملف لازم يتقرأ في كل session جديد. لا تعتمد على الذاكرة أو الملخص.
> Repo: `yasira82/tec-knowledge-base` | Branch: `main`

**Last Updated:** 20 June 2026 (Session 14 — Payment Unification)

---

## SCORE

| المصدر | Score |
|--------|-------|
| Self | ~8.5/10 |
| External (قبل Session 4 fixes) | 7.1/10 avg (Ecom 5.5 / Hub 6.5 / Commerce 7.0 / Assets 7.5) |
| External (Session 3 audit) | 7.65/10 |
| External (متوقع بعد الـ fixes) | **~8.5–9.0/10** |
| Architectural Review (Session 8) | **9.1/10 overall** (Knowledge Architecture: 9.5+/10) |
| Engineering Assessment (Session 9) | KB reconciliation: C-57 ✅ + C-40 ✅ + C-41 ✅ + C-93→C-99 Institutional Loop |
| **Code Verified Inspection (Session 9)** | **9.3/10 overall** — Architecture 8.7 / Security 8.9 / Gateway **8.6** / Runtime Visibility **7.8** / Observability **8.2** / KB 9.1 / Constitutional Governance **9.8** |
| **ADR-008 — Runtime Observability Architecture** | **✅** — ACCEPTED · June 2026 · ADR-008a/b/c/d: Health Runtime + Redis + Evidence Endpoint + Timeout |
| **P1 Fixes Applied (Session 10)** | **✅** — NEW-K/L/N/O all VERIFIED · C-81 Implementation Guide applied · PRI 8.22 → 8.8+/10 |
| **Port Conflict Resolved** | **✅** — Canonical: Gateway `:3000` / Services `:5001–5011` (C-20 Code Verified) — README + memory updated |
| **Truth State Rollout** | **✅** — Added to C-00, C-10, C-12, C-20, C-64 (5 core docs) |
| **Skills README** | **✅** — Updated 13→16 (added charter-advisor, mcp-orchestrator, observability) |
| **v3.5.0 — Authority Automation** | **✅** — 28→66 docs (33%→79% adoption) · C-116 AHV Constitution · CDG manifest + AHV engine v1 + Impact Analysis · LANGUAGE_POLICY + 90-Day Roadmap |
| **v3.6.0 — Registry Integrity** | **✅** — Registry auto-generated (96/96 coverage) · R-SEMANTIC-001 catches drift · C-117 Registry Integrity Constitution · check-registry-integrity.sh v2.0 · 28 rules across 7 categories |
| **Registry Semantic Accuracy** | **✅** — Fixed v1.0 mislabeling (C-93/94/95 institutional_role now matches file H1) |
| **Coverage 19%→100%** | **✅** — All 96 C-docs now registered (was 18/96) |
| **CI Gates** | **9 total** — 5 original + 3 from v3.5.0 + check-registry-integrity.sh (BLOCKING) |
| **v3.6.1 — VAM Restoration** | **✅** — VAM restored from v3.5.0 + check-vam-compliance.sh BLOCKING CI gate added |
| **v3.6.2 — DAG-Guaranteed + C-118** | **✅** — 0 cycles · 0 inversions · 0 errors across all 10 CI gates · C-118 Dependency Propagation Constitution · propagate-dependency.py + regenerate-cdg.py |
| **CI Gates** | **10 total** (was 9) — added check-vam-compliance.sh |
| **Knowledge Base Version** | **v3.6.2** — Phase 1 complete · Phase B2 starting · 0 violations · 10 CI gates pass |
| **Session 13 — ADR-007 Foreign Session Fix** | **✅** — `__TEC_PI_FOREIGN_SESSION` defense-in-depth added to ALL 5 Ecommerce payment files (pi-payment.ts + page.tsx + product/[id] + store/[id] + CartDrawer) — Hub redirect on foreign session |
| **Tec-App (Hub) Test Coverage** | **95.5%** — 2026 tests passing |
| **Session 14 — Payment Unification (ADR-009)** | **✅** — root-caused & fixed the post-audit payment breakage across all repos (see block below) |
| الهدف | **9.5/10** |

---

## SESSION 14 — PAYMENT UNIFICATION (20 June 2026) ✅

Root cause of the platform-wide payment failures: a hardening audit added a **divergent BFF stack** + a **CSRF gate on payment routes** that broke every app. Fixed end-to-end:

| Fix | Detail | Repo / PR |
|-----|--------|-----------|
| **ADR-009 Unified Payment Contract** | one contract in `@yasser172/tec-sdk` `contracts/payment.ts` — `amount: number`, `/api/payment/*`, `x-internal-key` | TEC-SDK #8 ✅ merged · C-64 ADR-009 |
| **Hub amount=number** | Mode-1 create sent `String(amount)` → backend wants number | Tec-App #37 ✅ merged |
| **CSRF Origin fallback** | the audit's cookie-only double-submit 403'd every payment in Pi Browser (drops `sameSite=None`). Middleware now accepts double-submit **OR** first-party Origin | all 4 apps ✅ merged |
| **Assets mint unified** | mint used a divergent client → legacy approve hardcoded `amount:1` (DB ≠ charge). Now canonical client | Tec-Assets #22/#24 ✅ merged |
| **Token-refresh on resolve/cancel** | expired token left payments stuck (`TOKEN_EXPIRED`). `gatewayPost()` refreshes once | Tec-App #37 ✅ merged |
| **Reconciliation = Pi source-of-truth** | cron no longer blind-fails; asks Pi → complete/cancel/skip. Auto-clears stuck payments hourly + `/api/admin/reconcile` on-demand | tec-core-backend #83 ✅ merged |
| **CI policy guard** | every app's CI fails on `x-service-secret` / `SERVICE_SECRET` / `z.string()` amount | all 4 apps ✅ |
| **tec-ui test fix** | added `@testing-library/dom` (v16 peer) — 3 test files were failing | tec-ui ✅ |
| **Payment runbook** | `tec-app/docs/PAYMENT_SYSTEM.md` + C-12 §11 — how payments work + anti-regression guide | Tec-App + KB #20 |

### Session 14.3 — Route-level CSRF hotfix + permanent guard (21 June 2026) ✅
A second, deeper instance of the CSRF bug surfaced: even after the **middleware** was fixed (double-submit OR Origin), some **BFF routes still did their OWN strict double-submit CSRF check** — a duplicate that 403'd legit Mode-2 payments in Pi Browser (dropped `sameSite=None` cookie). Hub→app (Mode 1) worked (routes not called); standalone (Mode 2) failed.

| Fix | Detail | Repo / PR |
|-----|--------|-----------|
| **ecommerce payment + orders CSRF removed** | `payment/create`/`approve`/`complete` **and** `orders` had the duplicate check → standalone payment **and order creation** 403'd. Removed; middleware is sole CSRF authority | Tec-Ecommerce #38→#39 ✅ merged (payment-verified) |
| **Hub payment/create CSRF removed** | lenient variant (Hub kept working) but same anti-pattern → removed for consistency | Tec-App #40 ✅ merged |
| **Permanent CI guard** | every app's payment-policy CI now **fails on any route-level CSRF check** (`csrfCookie !== csrfHeader` / `CSRF validation failed` / `CSRF token mismatch` under `src/app/api`) — can't regress | all 4 apps (tec-app #41 · ecommerce #40 · assets #27 · commerce #36) |
| **Lesson documented** | C-12 §11 anti-regression table + rules updated (CSRF = middleware-only, P2) | KB |

> **Root lesson (P2):** CSRF must be enforced in exactly ONE layer — the middleware. A route may *forward* `x-csrf-token` downstream, but must **never validate** it. Commerce/Assets had no route check and never broke.

### Session 14.4 — Template completeness + package CI parity (21 June 2026) ✅
Made `tec-template-base` a Portal-ready golden reference and fixed the shared CSRF bug at the package level.

| Work | Detail | Repo / PR |
|------|--------|-----------|
| **Template completed** | full skeleton: payment BFF (create/approve/complete/resolve-incomplete, ADR-009, no route CSRF) · SSO callback (open-redirect-safe) + refresh · `pi-payment.ts` (ADR-007 dual-mode + isHubNavigation + redirectToHubPayment) · `/privacy` + `/terms` · design tokens · example `/app` buy page · payment tests · `.gitignore` · `eslint.config.mjs` · CI payment+CSRF policy · full CLAUDE.md + new-app checklist | tec-template-base #3 ✅ |
| **tec-auth CSRF fix** | `createAuthMiddleware` did pure double-submit → 403 in Pi Browser. Now double-submit **OR** first-party Origin (`trustedOriginSuffix`, default `.tecosystem.app`) + exported `isTrustedCsrf()`. +13 tests, 95%/93.5%/100%. v1.0.0→1.1.0 | tec-auth #5 ✅ |
| **tec-auth CI** | was 1 misnamed job → real `ci.yml` (typecheck/test/build) + `codeql.yml` + real publish-on-release; coverage gate 60→80 | tec-auth #5 ✅ |
| **tec-ui CI** | added `codeql.yml` (only gap) + coverage regression floor (72/62/68/75) | tec-ui #13 ✅ |
| **tec-sdk** | audited — already complete (ci test+build+coverage · codeql · real version-checked publish). No change | — |

> **Lesson:** the template relied on the package middleware that carried the production CSRF bug — a new app would have shipped broken. Template is now self-contained + correct, and the package is fixed too (defence in depth). KB: 10/10 gates green; registry 99/99 (100%).

### Session 14.6 — Runtime Governance Layer begins (21 June 2026) ✅
First in-repo work on the unanimous #1 gap (doc ↔ runtime). Authority: `audits/EXECUTION_PLAN_2026-06-21.md` (NEXT).

| Work | Detail | Repo / PR |
|------|--------|-----------|
| Truth reconciliation (Batch 1) | C-77 + C-91 stale figures (`~7.0–7.5`/`7.25` → ~9.2, P1=0); C-90 Security `[Draft]` → `[Governance Approved]` (registry now reads it); C-84/85/96 scope-boundary note; v9 `deliverables/` imported | KB |
| Commerce domain finalized | `commerce.tecosystem.app` confirmed in Pi Portal — aligned across C-01/C-02/C-101/C-92/C-10 | KB |
| **Portal Readiness Engine** | `evals/check-portal-readiness.sh` — **11th CI gate**. Auto pre-submission audit: App ID/domain consistency (C-01↔C-02↔RUNBOOK), no placeholders, PI_SANDBOX=false, Privacy/Terms, no open ENG/OPS items | KB |
| **C-96 dual-poller fix (NEW-K)** | `PlatformHealthContext` = single health poller; `BackendOfflineBanner` + `BackendStatus` now consumers; fixed BackendStatus's wrong-path bug. C-96 updated: NEW-K RESOLVED | tec-app + KB |
| **Drift Detection gate** | CI gate "Drift Detection — KB claims vs code" in **all 4 apps**: ADR-009 (amount:number) · C-12 §11 (CSRF middleware-only) · C-76/ADR-007 (every Mode-2 buy handler guarded with `isHubNavigation()`). Hub also: C-96 single-poller. Negative-tested | tec-app · ecommerce · assets · commerce |

> Runtime Governance progress: Portal-Readiness ✅ · dual-poller ✅ · Drift Detection ✅ (4 apps).
> Remaining NEXT: Runtime Evidence schema (item 8) → then Observability stack (infra/ops).

### Session 14.5 — P2 deferred-quality + P3 security (21 June 2026) ✅
P0 + P1 were already closed (Portal-ready). This batch cleared the deferred backlog.

**P2 — deferred quality (DONE):**
| Item | Detail | Repo / PR |
|------|--------|-----------|
| Sentry drift | Assets `@sentry/nextjs` v10 → v8 (APIs used are stable both) — typecheck 0 · 133 tests · build OK | tec-assets |
| vite plugin → devDeps | `@vitejs/plugin-react(-oxc)` moved out of prod deps | ecommerce · assets · commerce |
| realtime-service tests | 0 → **9 tests** (HealthController + RealtimeGateway: auth, disconnect, emit) | tec-core-backend |

**P3 — security / strategic (partial — the safe code part DONE):**
| Item | Status |
|------|--------|
| npm-audit triage + non-breaking fixes | ✅ `next` 15.5.12 → 15.5.19 (+ ws/form-data/engine.io) — **high 6 → 2** per app · all 4 apps |
| Lesson | broad `npm audit fix` reshuffled vite/rolldown → broke Hub vitest JSX parsing → use **package-scoped bumps** (next-only), not broad fix. Hub redone next-only (2009/2009 green) |
| npm-audit → blocking | ⏸️ NOT yet — residual high=2 (`@sentry`+`rollup` need v10 vs platform v8) + critical=1 (`happy-dom`, **test-only devDep**). Stays advisory |
| Publish tec-auth v1.1.0 + bump consumers | ⏸️ ops-gated (needs NPM_TOKEN + Release; publish workflow ready) |
| Migrate apps → package middleware (DRY) | ⏸️ deferred until v1.1.0 published (else apps pull old buggy 1.0.0 → re-break payments) |
| Observability SLOs → dashboards (C-78) | ⏸️ infra/ops |

> **P3 forward sequence:** merge PRs → cut a tec-auth Release (fires publish.yml) → bump the 4 apps + template to `@yasser172/tec-auth@^1.1.0` → optionally migrate inline middleware → package middleware.

**Project-wide tests (Session 14):** SDK 174 · Hub 2009 · Assets 133 · Commerce 209 · Ecommerce 75 · payment-service 143 · tec-auth 46 · tec-ui 75 · realtime 9 · KB 10/10 gates — **all green**.

**Operational requirement to clear stuck payments:** `PI_API_KEY` (Hub/tec-app key) + per-app keys set on `tec-payment-service` Railway → resolve/cancel/reconcile work automatically (login auto-resolve + hourly cron + on-demand).

### Re-Audit reconciliation (the 2026-06-19 audit was stale — verified against code)

| Prior finding | Verified status (Session 14) |
|---|---|
| P0-2 terminal-state bypass | ✅ CLOSED — guard at resolve (409) + `isTransitionAllowed` in approve/complete/cancel/fail |
| P0-3 CSRF on payment routes | ✅ CLOSED — middleware: double-submit OR first-party Origin (all 4 apps) |
| P0-4 tec-sdk Railway URL | ✅ CLOSED — `http-client.ts` env-var only + throw, zero railway URL |
| P0-5 tec-sdk `x-internal-key` | ✅ CLOSED — sent by `http-client.ts` |
| P1 auth-service CORS Railway URL | ✅ CLOSED — none in source |
| P1 `NEXT_PUBLIC_REALTIME_URL` client leak | ✅ CLOSED — not in client bundle |
| P1 tec-ui SSR window guards / failing tests | ✅ CLOSED — guards added + `@testing-library/dom` |
| NEW-M service-registry | ✅ CLOSED — `tec-api-gateway/src/config/service-registry.ts` |
| **P0-1 Outbox (ADR-004)** | ✅ **CLOSED** — `saveOutboxEvent()` wired atomically into approve/complete (PR #84 merged) — **payment verified working in production** after deploy |

**New External Audit (Session 14):** `audits/EXTERNAL_AUDIT_2026-06-20_Session14.md` — **~9.0/10** (was ~6.5–7.0). All P0 closed (Outbox now live + payment-verified). Remaining = small P1/P2 hygiene batch → Portal.

---

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

## KNOWLEDGE BASE UPGRADE (Session 6 — v3.1.0) ✅

### Phase 1 — Foundation
| الملف | الوظيفة |
|------|----------|
| `.claude-plugin/plugin.json` | Plugin marketplace manifest |
| `skills/platform/knowledge-orchestrator` | Meta-skill: تحميل C-docs تلقائياً + توجيه كل task |
| `skills/platform/platform-architect` | C-47 guardian: تحقق من كل قرار معماري |
| `skills/platform/payment-expert` | ADR-007 + C-76 + Mode 1/2 decision tree |
| `skills/platform/security-reviewer` | P6 Fail Closed + 10 Forbidden behaviors checklist |
| `skills/engineering/bff-patterns` | BFF route template كامل |
| `skills/engineering/tec-testing` | Vitest + Pi mock + coverage targets |
| `evals/validate-skills.sh` | CI quality gate للـ skills |
| `templates/new-skill, new-adr, new-c-document` | Scaffolds |
| `.github/workflows/knowledge-ci.yml` | CI pipeline |

### Phase 2 — Marketing + Design + Agents
| المجال | Skills |
|-------|--------|
| Marketing | pi-growth, content-strategy, product-launch, community-marketing, seo-aeo |
| Design | tec-design-system, ui-patterns |
| Agents | cmo-advisor, growth-advisor, design-system-advisor |

### Phase 3 — MCP + Commands + Observability
| الملف | الوظيفة |
|------|----------|
| `.mcp.json` | GitHub + Vercel + Railway + Supabase connectors |
| `commands/check-ci` | CI status لكل 8 repos |
| `commands/check-deployments` | Vercel deployments + runtime logs |
| `commands/check-violations` | P1 violations audit |
| `commands/platform-health` | Full health check (CI + Vercel + Railway + payments) |
| `commands/knowledge-sync` | مزامنة C-02 مع الكود |
| `commands/new-adr, new-skill` | Scaffolding commands |
| `skills/platform/mcp-orchestrator` | كيفية استخدام MCP في context الـ TEC |
| `skills/platform/observability` | SLOs + incident response + circuit breaker |

### إجمالي Knowledge Base v3.1.0
```
Skills:   11 skills (4 platform + 2 engineering + 5 marketing + 2 design)
Agents:    3 agents (cmo-advisor + growth-advisor + design-system-advisor)
Commands:  7 commands
Templates: 3 scaffolds (skill, ADR, C-document)
CI:        1 workflow (knowledge-ci.yml)
MCP:       4 connectors (GitHub, Vercel, Railway, Supabase)
```

---

## KNOWLEDGE BASE UPGRADE (Session 7 — v3.2.0) ✅

### App Institutional Charters — C-100→C-115

16 مستند جديد تم إنشاؤهم كـ Economic Infrastructure Design Partnership:

| Charter | App | System Role |
|---------|-----|-------------|
| C-100 | Hub | System of Access (Current State) |
| C-101 | Commerce | System of Production — Reference Impl (Current State) |
| C-102 | Assets | Digital Asset Infrastructure (Current State) |
| C-103 | Ecommerce | Consumer Marketplace (Current State) |
| C-104 | TEC AI | System of Reasoning (Planned) |
| C-105 | Analytics | System of Intelligence (Planned) |
| C-106→C-115 | Life, Connection, Explorer, Nexus, SYSTEM, ALERT, NX, FundX, Estate, DX | Future Vision |

كل charter يشمل:
- Mission + Authority Boundary
- Technical Architecture + Security Model
- Engineering Updates Required (P0/P1/P2)
- Integration Map (cross-charter dependencies)

### CI Fix
- `evals/validate-skills.sh` — fixed bash `((PASS++))` → `PASS=$((PASS+1))`
- Root cause: `set -e` + arithmetic 0 = false → premature exit after first valid file

### v3.2.0 Additions
- `skills/platform/charter-advisor/SKILL.md` — guide to load Charter before any app modification
- `evals/validate-charters.sh` — CI validator for all 16 charters (16/16 pass)
- `memory/platform-snapshot.md` — fast-load session-start reference
- `.claude-plugin/plugin.json` — fixed version 3.1.0→3.2.0, fixed filenames, added 3 skills
- `.github/workflows/knowledge-ci.yml` — added validate-charters job
- `templates/new-charter/CHARTER_TEMPLATE.md` — scaffold for new institutional charters

### C-57 Updated → v3.2.0
- Added TIER 7 (C-87→C-91: Governance + Execution)
- Added TIER 8 (C-100→C-115: App Institutional Charters)
- Updated Quick Lookup with charter references
- Constitutional Hierarchy extended to C-115

---

## KNOWLEDGE BASE (Session 11) ✅

### Engineering Hardening + Enterprise Contents

| التغيير | التفاصيل |
|---------|----------|
| **CI/eval hardening** | إصلاح عيب `check-knowledge-gaps.sh` + تشديد المُحقِّقات + سكربتات جديدة (`validate-structure`, `check-links`, `check-truth-framework`) |
| **Repo standards** | إضافة `LICENSE` (MIT) + `.gitignore` + `SECURITY.md` + `CONTRIBUTING.md` + `CODEOWNERS` |
| **Orphan resolved** | `47___TEC_Kernel_Spec...` → `knowledge-base/archive/` (C-47 هو الـ canonical) |
| **C-17 — Data Privacy, Retention & Compliance** | جديد [Planned][Draft] — تصنيف بيانات + دورة حياة PII/KYC + احتفاظ + حقوق المستخدم |
| **C-18 — Disaster Recovery & Backup** | جديد [Planned][Draft] — RPO/RTO + سياسة نسخ احتياطي + restore drills + ترتيب التعافي |
| **C-19 — Fraud, Abuse & AML / Sanctions** | جديد [Planned][Draft] — ضوابط الإساءة الاقتصادية + حدود KYC + AML/SAR + فحص العقوبات |

---

## KNOWLEDGE BASE (Session 9) ✅

### Institutional Operating Loop Constitutions (C-93→C-99) + C-80 Assessment

**Tier-1 Constitutional Layer — Institutional Operating Loop:**

| التغيير | التفاصيل |
|---------|----------|
| **C-93 — Institutional Verification Constitution** | v1.2 [Speculation][Draft] — Reality → Evidence → Institutional State → Authority |
| **C-94 — Governed Capability Constitution** | v1.0 [Speculation][Draft] — Knowledge → Executable Capability |
| **C-95 — Institutional Knowledge Constitution** | v1.0 [Speculation][Draft] — Institutional State → Knowledge |
| **C-96 — Platform Runtime Constitution** | v1.1 [Current State][Draft] — Health · Observability · Availability · Resilience — NEW-K/L/N/O ✅ VERIFIED |
| **C-97 — Context Constitution** | v1.0 [Speculation][Draft] — Capability → Applicable Action (applicability bridge) |
| **C-98 — Institutional Construction Constitution** | v1.0 [Speculation][Draft] — Tier-2: DX Runtime + SDKs + Governed Assembly |
| **C-99 — Institutional Governance Constitution** | v1.0 [Speculation][Draft] — Authority → Governance → Enforcement — closes the loop |
| **C-80 — Engineering Assessment Report** | تقرير مراجعة هندسية شامل (نُقل من C-95) |
| **C-57 — RECONCILED** | تم تصحيح 31+ وصف مغلوط في TIER 2→6B ليطابق الملفات الفعلية |
| **C-40 — SYNCED** | إغلاق NEW-C/E/F/G كـ VERIFIED + Ecommerce PR #25 closed |
| **C-41 — UPDATED** | tec-ui v1.2.1 ✅ + Phase 1 P2 violations ✅ + External Audit ← NEXT |
| **governance/ file** | إعادة تسمية إلى `TEC_GOVERNANCE_CHARTER_v1.2.md` لتطابق المحتوى |
| **README.md** | Skills count 15→16 + KB count 91→93 + C-93 في Quick Navigation |

### Gap Findings Summary (→ C-93 for full detail)

```
Critical (P0) — تم إصلاحه:
✅ C-57 index: 31 وصف مغلوط → تم التصحيح
✅ C-40 stale: 4 violations مفتوحة بعد إغلاقها → تم التزامن
✅ C-41 stale: tec-ui blocker بعد نشره → تم التحديث
✅ governance filename مش مطابق للـ content version → تم التصحيح

Remaining (P1) — مطلوب في Session القادمة:
⚠️ Port conflict: C-10/C-20 (port 3000/5001) vs README/charters (4000/4001)
✅ Commerce domain: محسوم نهائيًا (21 Jun) — `commerce.tecosystem.app` (المسجّل في Pi Developer Portal) · متطابق عبر C-01/C-02/C-101/C-92/C-10
✅ Truth Framework adoption: 100% on registry (96/96 docs registered via auto-generation) — C-00→C-23 تحتاج Truth State headers
✅ Orphan file: 47___TEC_Kernel_Spec_v1_1.1__ → تمت أرشفته في knowledge-base/archive/ (C-47 هو الـ canonical)
```

---

## KNOWLEDGE BASE (Session 8) ✅

### C-92 Platform Health Model

Closes the Observability gap identified in architectural review (9.1/10 → target 9.5/10):

| Section | Content |
|---------|--------|
| Health Philosophy | Health ≠ Uptime. Health = economic function delivered correctly |
| 5 Dimensions | Identity × Payment × App × Service × Event Bus |
| State Machine | GREEN → DEGRADED → CRITICAL → DOWN (formal transitions) |
| PHS Formula | Composite score: Identity 30% + Payment 30% + Service 20% + App 15% + Events 5% |
| Propagation Rules | Identity cascade + Gateway cascade + Payment independence |
| Health Gates | Deployment gate (PHS < 80 = block) + Release chain gate |
| Dashboard Spec | 5 panels with signal layouts — Phase 1 implementation target |
| Phase 0 Checklist | Manual health verification before every deployment |

### C-57 Updated
- C-92 added to TIER 7 (now C-87→C-92)
- Count updated: 91 → 92 documents
- Quick Lookup: added "Check platform health → C-92"
- Content Ranges: C-87→C-92

---

## VERIFIED ✅ (Session 10 — 17 June 2026)

| Item | الحالة |
|------|--------|
| **NEW-K** | **✅ VERIFIED** — `PlatformHealthContext.tsx` — Single Poller + context — يغني عن polling مزدوج |
| **NEW-N** | **✅ VERIFIED** — Redis: 5 event listeners (connect/ready/error/reconnecting/end) — Observable Runtime |
| **NEW-O** | **✅ VERIFIED** — `GET /api/health/details` (x-internal-key) — gateway + redis + uptime + memory + services |
| **NEW-L** | **✅ VERIFIED** — Gateway timeout: 30000 → 10000 — تنسيق: Frontend 5s / Gateway 10s / Upstream 8s |
| **C-81 Implementation Guide** | **✅ CREATED** — كود كامل لـ 4 fixes — مطبّق على Tec-App + Tec-core-backend |

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

## PI APP IDENTITY

| App | Pi App ID | Domain |
|-----|-----------|--------|
| Tec-Ecommerce | `ecommerce-app-71ca4d3e462eaf54` | `https://ecommerce.tecosystem.app` |
| Tec-Commerce | `commerce-app-68aa99081fc1897a` | `https://commerce.tecosystem.app` |
| Tec-Assets | `assets-app-af2fb490e7b03db7` | `https://assets.tecosystem.app` |
| Tec-App (Hub) | `tec-app-923b947851f9dfe1` | `https://hub.tecosystem.app` |

---

## PLATFORM STATE

```
12 Railway services:   Active — INTERNAL_SECRET set ✅
4 apps (Vercel):      Hub + Commerce + Assets + Ecommerce
4 npm packages:       tec-auth + tec-ui (v1.2.1) + tec-sdk + tec-shared
PI_SANDBOX:           false (Mainnet)
tec-auth coverage:    95% (46 tests)
tec-ui coverage:      80% (75 tests)
Hub coverage:         95.5% (2026 tests) ✅
Hub CI:               ✅ GREEN — 2026 tests passing (commit 275d6fd0)
Ecommerce CI:         ✅ GREEN — ADR-007 foreign session fix (commit a586c1ca)
All repos coverage:   ≥ 60% ✅
All 4 apps:           Mode 1 + Mode 2 + ADR-007 + __TEC_PI_FOREIGN_SESSION ✅
All P1 violations:    ✅ ZERO
All P2 violations:    ✅ ZERO
All Pi App IDs:       ✅ كل 4 apps مسجّلة
All audit fixes:      ✅ ON MAIN — Hub + Ecommerce + Commerce + Assets
Last audit score:     7.65/10 (Session 3) → Architectural Review 9.1/10 (Session 8)
Architectural Review: Knowledge Architecture 9.5+/10 | Platform Engineering 9.0–9.2/10
CLAUDE.md:            ✅ session start → main في كل repos
Knowledge Base:       ✅ v3.6.2 — 96 C-docs + 16 skills + 16 charters + 10 CI gates + evals/ + scripts/ + architecture/
Pending PRs:          NONE — all fixes on main ✅
Latest audit:         ✅ Session 14 (2026-06-20) → ~9.0/10 (was ~6.5–7.0) — all P0 closed (Outbox live + payment-verified)
NEXT:                 P1/P2 hygiene batch → Portal Submission
```

---

## UPDATE PROTOCOL

```
آخر كل session — قبل الإغلاق:
☐ أضف لـ DONE كل حاجة اتخلصت
☐ احذف من PENDING كل حاجة اتحلت
☐ حدّث NEXT بالأولوية الجديدة
☐ حدّث Last Updated
```
