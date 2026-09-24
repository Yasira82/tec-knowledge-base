# SESSION 14 — PAYMENT UNIFICATION (20 June 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

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

### Session 14.8 — Production incident + Hub reliability fixes (25 June 2026) ✅
Live Hub testing surfaced a cluster of bugs. Two distinct things were happening: (1) a **transient** Railway infra incident (declared; 23/24 online — recovered), and (2) a **recurring** gateway defect (**NEW-U**) that kept re-triggering the "Backend Offline" banner *after* the infra recovered. All seven bugs below are real and now fixed; runtime evidence: `runtime-evidence/ev-2026-06-22-010.yaml` (infra incident + the BFF-contract bugs) and `runtime-evidence/ev-2026-06-25-011.yaml` (NEW-U gateway saturation, runtime-verified from HTTP logs).

| ID | Symptom | Root cause | Fix | PR |
|----|---------|-----------|-----|-----|
| **NEW-P** | Hub wallet → "Something went wrong" (full ErrorBoundary) | `/api/bff/wallet/balance` returns `balance` as a **string** (ADR-009 string-in-API); page called `balance.toFixed()` → throw in render | coerce to number at the `useWallet` boundary (balance + fallback tx + realtime) | tec-app #45 |
| **NEW-Q** | False "Backend Offline" banner during latency blips | double 5s timeout (client+BFF) + **no failure threshold** (1 fail → offline) | client→BFF 12s · BFF→gateway 10s · `failureThreshold=2` (consecutive) — kept honest, not blind (C-96) | tec-app #46 |
| **NEW-R** | `/api/notification/unread-count` + `/read` → 404 (repeated) | BFF called endpoints the service doesn't expose | use base `GET /api/notification` (returns unreadCount) + `:id/read` / `read-all` | tec-app #46 |
| **NEW-S** | `PATCH /notifications/:id/read` → 400 | `Content-Type: application/json` sent with **empty body** → Fastify rejects (self-inflicted by NEW-R) | drop Content-Type on bodyless PATCH | tec-app #47 |
| **NEW-T** | `/api/bff/realtime` → **500** spam (~119 err/30min in Vercel logs) + WS reconnect loops | route **threw** when `REALTIME_URL` unset; realtime is OPTIONAL | return `{enabled:false,url:null}` 200; hooks skip cleanly when url null (C-96: no phantom failures for an off feature) | tec-app #48 |
| **Gateway timeout** | one slow upstream hangs requests 30s → cascade | gateway `proxyTimeout` default **30s** (KB NEW-L claimed 10s — drift) | default **30s → 15s** (fail-fast; still configurable via `PROXY_TIMEOUT`) | tec-core-backend #87 |
| **NEW-U** | recurring **`/health → 499`** bursts + **"Backend Offline"** banner | proxy opened a **fresh TCP+TLS connection per request**; a page-load fan-out of ~15-20 concurrent calls → ~20 simultaneous **TLS handshakes** → CPU 0→**1.5 vCPU** → single-thread event-loop saturates → even sync `/health` starves → 499 (NOT OOM; memory ~100MB) | shared **keepAlive** http/https Agent → reuse warm TCP+TLS; `maxSockets` (env `PROXY_MAX_SOCKETS`, default 64) bounds the burst | tec-core-backend #88 |

> ⚠️ **SUPERSEDED by §14.11 (26 Jun):** this attributed the recurring freeze to **NEW-U** (keep-alive / TLS-handshake storm). **That was wrong** — the freeze recurred after NEW-U deployed. The true root cause is **NEW-V** (the gateway's Redis dependency on the request path; see §14.11 + `ev-2026-06-26-012`). NEW-U remains a valid perf improvement, just not the fix. *(Original text kept below for the audit trail.)*
>
> ~~**Root-cause correction (runtime-verified):** the **recurring** Backend-Offline banner was the gateway connection-pool defect **NEW-U**, proven from Railway HTTP Logs (02:12:04 `/health` 200/4ms → 02:12:13 `/health` 499/4s) + the CPU→1.5 vCPU spike. Evidence: `ev-2026-06-25-011`. The June Railway incident (`ev-2026-06-22-010`) was a separate transient outage.~~

**Ops fix (no code):** the Vercel **Supabase integration** (preview-branch provisioning) was attached to the **tec-app** project but only **Analytics** uses Supabase — it failed provisioning and red-X'd Hub preview deploys. Disconnected from tec-app (Hub uses Railway `DATABASE_URL`; verified zero Supabase usage in code). Check the other 3 apps too.

> **Lesson:** the BFF↔service contract bugs (NEW-P/Q/R/S/T) are **string vs number · wrong paths · Content-Type/body · timeout alignment · optional-feature-as-500** — Drift-Detection candidates. **NEW-U is a different class: a runtime/resource defect** (per-request TLS handshakes) invisible to any static gate — only the HTTP-log + CPU evidence revealed it. This is exactly why the Runtime Governance Layer (C-96 evidence) exists: a static-only platform would never have caught it.

### Session 14.13 — "Backend Offline" durable fix: event-loop resilience (NEW-W) (26 June 2026) ✅
The recurring "Backend Offline" returned **again** after NEW-V. Root cause finally pinned by reading the gateway code end-to-end (not screenshots): **event-loop saturation on the single-threaded gateway.** The repeated signal across every incident — the trivial, dependency-free `/health` going from 2ms → 9s/499 while CPU hits 1.5 vCPU — can only mean a blocked event loop. **It is NOT Redis** (the gateway creates no Redis client at all — `createClient` is never called) and **NOT tec-sdk.**

| Prior attempt | Verdict |
|---------------|---------|
| NEW-U (keep-alive) | trigger-only — freeze recurred |
| NEW-V (in-memory rate-limit) | **claim "true root cause" was WRONG** — recurred; no Redis client exists. Kept as correct hardening. |

**NEW-W (tec-core-backend #93) — durable fix, 4 structural changes:** (1) `/health`+`/ready` registered as the FIRST routes, isolated from cache/JWT/rate-limit/proxy → liveness never fails under load (kills the FALSE offline); (2) per-request proxy logging OFF by default + prod log levels exclude `debug` → removes synchronous stdout backpressure that blocks the loop under the polling flood; (3) hard `proxyReq.setTimeout(...).destroy()` → slow upstream (pi-login hung 24s vs 15s) can't hold connections; (4) event-loop-lag **load shedding** → fast 503 above `MAX_EVENT_LOOP_LAG_MS` instead of snowballing. **Amplifier fix (tec-app #53):** `/api/bff/realtime` request storm from unstable React callback deps in `useWalletRealtime`/`useRealtimeNotifications` (effect re-ran every render) → callbacks moved to refs.

**Evidence:** `runtime-evidence/ev-2026-06-26-013.yaml` (supersedes ev-012, which is flagged `superseded_by` + kept unaltered for an honest audit trail). **Lesson:** diagnosing from symptom screenshots without the gateway **Deploy Logs** produced two confident wrong calls; the durable fix targets the *architectural fragility* so the platform degrades gracefully (503 + live `/health`) regardless of which trigger fires — verifiable post-deploy on Railway.

### Session 14.12 — Economic OS Model integrated (C-119→C-121, TIER 10) (26 June 2026) ✅
Integrated three new constitutional vision-layer docs into the KB as **TIER 10 — Economic Operating System Model**.

| Doc | Role | Truth State |
|-----|------|-------------|
| **C-119** | Economic Operating System Model — TEC = 3-tier economic OS (Tier 1 Constitutional Runtimes: Hub/Zone/Analytics/System · Tier 2 User Runtimes · Tier 3 Economic Products) | `[Future Vision]` / `[Draft]` |
| **C-120** | Zone Constitutional Runtime Charter — Zone = Verification Runtime ("What can be trusted?"), `zone.pi` strategic asset, V1→V4 | `[Future Vision]` / `[Draft]` |
| **C-121** | Institutional Knowledge Pipeline — sequential chain Hub → Life → Connection → Zone → Analytics → Nexus → TEC AI | `[Future Vision]` / `[Draft]` |

**Integration engineering:**
- `scripts/build-asset-registry.py` — added range `119–121 → tier-1-institutional-intelligence` (without this the docs would default to `tier-2-experimental` — wrong for constitutional docs). Registry rebuilt: **102 assets, 100% coverage, 0 errors**.
- **C-30 partial supersession:** C-119 supersedes only C-30's *build sequence*; the app catalogue stays valid. Documented as a banner in C-30 (not a deletion).
- Normalized headers to schema: C-120 `[Future Vision — V1 Planned]` → `[Future Vision]`; all three `[Unverified]` → `[Assumed]`. Added a **Related Documents** footer to C-120.
- C-57 master index: added TIER 10 table + ranges + counter (C-00 → C-121).
- **All 13 KB CI gates pass** (registry-integrity, truth-framework, c57-index, authority-consistency, VAM, runtime-evidence, SLO, links, structure, portal-readiness, knowledge-gaps — 0 errors).

### Session 14.11 — TRUE root cause of "Backend Offline" + polish finish (26 June 2026) ✅
The recurring gateway freeze **kept recurring after NEW-U (keep-alive) shipped** — so keep-alive was **NOT** the root cause (correcting §14.8). Decisive evidence (Railway Deploy Logs): a flood of `ERROR Error: The client is offline` on every Redis blip, **plus the rate-limit-EXEMPT `/health` itself 499'ing** — only possible if the **event loop is saturated**, not if the limiter were merely blocking.

| ID | True cause | Fix | PR |
|----|-----------|-----|-----|
| **NEW-V** | gateway used **Redis on the request path** (rate-limit-redis). A Redis drop (Railway idle / restart) flooded "client is offline" rejections → event-loop saturation (CPU→1.5 vCPU) → every handler incl. `/health` 499s → "Backend Offline". The single entry point's liveness was tied to Redis. | **in-memory rate limiting** (MemoryStore) — zero Redis on the gateway hot path; a Redis outage can no longer freeze it | tec-core-backend #90 (partial: disableOfflineQueue+passOnStoreError — insufficient) → **#91** (complete) |

> **Correction to §14.8 / ev-2026-06-25-011:** those credited **NEW-U (keep-alive / TLS-handshake storm)** as the cause of the *recurring* Backend-Offline. Production proved otherwise — it recurred. NEW-U is a real perf win but **not** the freeze fix. The freeze fix is **NEW-V** (Redis-independence). Evidence: `runtime-evidence/ev-2026-06-26-012.yaml`. **Lesson:** when a fix "looks right" but the symptom recurs, the diagnosis was incomplete — keep `/health` (exempt path) as the canary; its freezing pointed at event-loop saturation, not the request handler.

**UI polish finish:** EVL **domain-tinted app tiles** (`lib/hub/appAccent.ts` — each Live-Now tile tinted by its EVL domain, keeps the brand emoji) — the "middle path" that supersedes §14.10's "app-launcher icons rejected" note (tinting ≠ mono-icon conversion). tec-app #52. **Data finding:** the `Dfgh`/`test` categories are **dynamically derived from products** (`page.tsx` `new Set(products.map(p=>p.category))`) → pure data cleanup (delete test products), not a code fix.

### Session 14.10 — Professional UI polish, platform-wide (26 June 2026) ✅
Live-screenshot-driven polish pass after EVL adoption. Fixed real UI defects + introduced a shared professional UI layer; verified live (deploy pipeline confirmed working — the "colors didn't change" was the subtle `#d4af37→#FBBF24` shift + browser cache, not a deploy failure).

| Work | Detail | Repo / PR |
|------|--------|-----------|
| **Shared UI primitives** | `Icon` (lucide-style inline SVG set, 18 glyphs, Pi-Browser-safe, currentColor) + `CountUp` (rAF easeOutCubic + thousands separator + prefers-reduced-motion) added to `@yasser172/tec-ui` **v2.1.0** (additive minor) | tec-ui #15 |
| **Hub flagship** | header overflow fix (`ECOSYSTEMAM`) · emoji chrome → Icon (nav/bell/AI-FAB) · balance + Pi-price `CountUp` · dual-tone EVL glow | tec-app #50/#51 |
| **Assets** | bottom-nav emoji → Icon (gem/cart/receipt/chart) · Portfolio Value `CountUp` (respects hideBalance) · tec-ui→2.1.0 | tec-assets #34 |
| **Commerce** | overview + bottom-nav + tab-pills + empty-state emoji → Icon · tec-ui→2.1.0 (chrome now 100% emoji-free) | tec-commerce #43/#44 |
| **Ecommerce** | ShopHeader nav + cart emoji → Icon · tec-ui→2.1.0 · **also fixed a real bug**: product cards showed the raw seller **UUID** as store name → clean "TEC Store" fallback | tec-ecommerce #46/#47 |

> **Decision (app-launcher icons):** the 24 ecosystem app tiles use *branded personality* emoji (VIP 👑, Titan ⚔️, Epic 🔥…). Mechanical conversion to mono line-icons was **rejected** — for branded launcher tiles it strips identity and isn't more professional. Correct path = **custom per-app icons/logos** (deferred design task), not a code sweep.
>
> **Remaining (deferred):** custom app-tile art · category-chip icons + purge of test categories (`Dfgh`/`test` — data cleanup, not code) · optional depth/motion on secondary cards · ESLint 10 flat-config migration (Dependabot, post-Portal).

### Session 14.9 — EVL adopted as live identity (26 June 2026) ✅
Governance decision: the **Economic Visual Language (C-83) color system** is now the live platform identity (was the legacy `#d4af37` gold set). Implemented in `@yasser172/tec-ui` **v2.0.0** — the color-token half of C-83 moves `[Planned] → [Current/Code-Verified]`.

| Work | Detail | Repo |
|------|--------|------|
| **tec-ui v2.0.0** | `TEC_COLORS`: gold `#d4af37→#FBBF24` · bg `#020205→#050816` · surface `#0d0d14→#0B1020` · +`surface2` + semantic `purple/green/cyan/red/blue` (C-83 §4–§5); state colors aligned; PaymentModal/StatusBadge de-hardcoded. Major bump (R5 coordinated breaking). 75 tests · typecheck 0 · build clean | tec-ui (v1.2.1→2.0.0) |
| **Skills synced** | `design/tec-design-system` + `design/ui-patterns` updated to the v2.0.0 tokens (code = SoT) | tec-knowledge-base |
| **C-83 reconciled** | color tokens marked adopted; shapes/motion/ESL/CSS-vars remain `[Planned]` | tec-knowledge-base |

> **Remaining (deferred, coordinated):** the 4 consumer apps re-skin by bumping `@yasser172/tec-ui` to `^2.0.0` — **no compile break** (only token values changed, no exports removed). Per R5, do the simultaneous app deploy **after Pi Portal submission** to avoid changing the identity mid-submission.

### Session 14.7 — Runtime Governance in-repo half complete (22 June 2026) ✅
Closes the doc↔runtime loop with two more KB gates (now **13** total).

| Work | Detail |
|------|--------|
| **Runtime Evidence schema** | `manifests/runtime-evidence-schema.yaml` + `evals/check-runtime-evidence.sh` (12th gate). Every evidence record (metric/health_snapshot/incident/slo_breach) is attributable to a `source` + `binds_to` a real C-doc → C-93 at VAM V-5. Behavior↔claim half. |
| **SLO Definitions** | `manifests/slo-definitions.yaml` + `evals/check-slo-definitions.sh` (13th gate). C-78 §2 targets made machine-readable; cross-checks every `slo_breach` references a defined SLO. Engineering's half of the Observability handoff. |
| **Template v2** | `tec-template-base`: health endpoint · PAL (PiRuntime + circuit breaker) · structured logger · Sentry-ready reportError · feature flags · coverage gate. Every new app is production-ready by default. |
| **24-app rollout registry** | `manifests/app-rollout-registry.yaml`: the 24 auction domains → 4 live + 20 to-build, with per-app checklist (repo→deploy→portal→smoke→5 users). 11 of 20 have KB blueprints; 9 need product definition. |

> **In-repo Runtime Governance is DONE.** Remaining is ops-only: Pi Portal submission + Observability stack (Prometheus/alerts → emit `slo_breach` into `runtime-evidence/`).
>
> **24-app scale (Core Team gate):** 4 live; 20 to build from Template v2. Per-app: repo→deploy→Pi Portal→≥5 users. Repo creation + deploy + Portal + users are ops/marketing (deferred). See `manifests/app-rollout-registry.yaml`.

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
