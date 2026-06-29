# C-02 — CURRENT STATE
## Living Document — Updated End of Every Session

> ⚠️ **SESSION START RULE:** هذا أول ملف لازم يتقرأ في كل session جديد. لا تعتمد على الذاكرة أو الملخص.
> Repo: `yasira82/tec-knowledge-base` | Branch: `main`

**Last Updated:** 29 June 2026 (Session 16 — Hub Pi-Browser login loop fixed; Analytics shipped)

---

## SESSION 16 — HUB LOGIN LOOP IN PI BROWSER (root-caused & fixed) (29 June 2026) ✅

> Truth State: **[Current State]** · Verification: **[Code Verified] + [Runtime Verified]** (Vercel logs + production retest)

**Symptom (production, `hub.tecosystem.app`, Pi Browser only):** "Sign in with Pi"
succeeded on the backend but the Hub never opened — it looped login → `/hub` → `/`
every few seconds. Standalone Chrome was fine.

**Two independent causes (one masked the other):**

1. **Stuck incomplete Pi payment (red herring, now cleared).** An approved +
   on-chain-verified but **not** `developer_completed` U2A payment
   (`BgWyxcJfkmeuBLwcYR2ILwBZV4XT`, `source:ecommerce`) surfaced on every
   `onIncompletePaymentFound`. `resolve-incomplete` returned **409** (terminal
   locally) so it never cleared on Pi → noise in the logs. **Resolved** by calling
   Pi `…/complete` with the txid (cancel is invalid for U2A). Not the real blocker.

2. **THE real blocker — Pi Browser cookie handling.** The frontend decided "am I
   logged in?" by reading `tec_user` from `document.cookie`. Pi Browser (a) **drops
   `sameSite=None` cookies** and (b) can **hide a stored cookie from client JS** even
   while sending it to the server (proof: `/hub` returned **304**, i.e. middleware
   *saw* `tec_access_token`, yet client `getStoredUser()` was null → `usePiAuth`
   `isAuthenticated=false` → `router.replace('/')`).

**Fix (Hub repo, merged to `main` via #56 + #58):**

| Change | File(s) | Why |
|--------|---------|-----|
| `sameSite` `none` → **`lax`** on session cookies | `api/auth/{pi-login,refresh,sso-callback,logout-from-sso}`, `middleware.ts` | Pi Browser keeps `lax`; first-party Hub cookies sent on the top-level nav to `/hub`. SSO unaffected (token rides the URL, not a cross-domain cookie). |
| New **`GET /api/auth/me`** | `api/auth/me/route.ts` | Server resolves the session from the request cookie (always readable server-side) → returns the user; fail-closed 401. |
| `usePiAuth` server fallback + `authSettledRef` | `lib-client/hooks/usePiAuth.ts` | When the client cookie read returns null, ask `/api/auth/me`; stay `isLoading` until it resolves so `/hub` shows a skeleton instead of bouncing. Ref stops a late `/api/auth/me` clobbering a succeeded login. |
| Tests aligned (`sameSite='lax'`, async `usePiAuth`) + race-guard test | `__tests__/auth/refresh-cookie.test.ts`, `__tests__/usePiAuth.test.ts` | CI green on `main`. |

**Deployment lesson:** production `hub.tecosystem.app` builds from **`main`**, not the
`claude/*` working branch — fixes on the branch had no effect until merged. Confirm the
target branch before "it didn't work" investigations.

**OPEN — wallet shows no balance ("—") after login (under investigation).** NOT caused
by the login fix: `/api/bff/wallet/balance` uses **server-side cookie auth**
(`createHandler` + `credentials:'include'`), which `sameSite=lax` makes *more* reliable.
Most likely same family as historical **NEW-L** (token expiry / empty gateway wallet).
Next data point: response of `/api/bff/wallet/balance` while logged in (401 `TOKEN_EXPIRED`
vs `balance:"0"` vs empty `wallets[]`).

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

## SESSION 15 — ANALYTICS APP (build-next) (27 June 2026) ✅

First app built from the 24-app rollout registry (`build-next` track). The standalone
`tec-analytics` repo (`analytics.tecosystem.app`) was a pristine `tec-template-base`
clone; turned it into a real, compliant Analytics app on branch `claude/tec-repos-review-ht2n8s`.

| Phase | Work | Detail |
|-------|------|--------|
| **0 — customize** | template → tec-analytics | name · domain `analytics.tecosystem.app` · APP_SOURCE `analytics` · SSO audiences · legal pages · Analytics-specific CLAUDE.md/README (data-ownership C-105 §4, merchant-isolation §6, eventual-consistency) |
| **1 — dashboard MVP** | platform intelligence UI | BFF `/api/bff/analytics/{overview,payments,users,events}` → `tec-analytics-service` via gateway (Bearer + `x-internal-key`, fail-closed); `/app` dashboard (overview cards + 30d payment volume + inline bar chart + recent events) with loading/error/retry (C-96); typed client hooks |
| **2 — parity** | Drift Detection CI gate | ADR-009 · C-12 §11 · ADR-007 — parity with the 4 live apps |

**Backend contract verified (code):** `tec-analytics-service` exposes `GET /analytics/{overview,payments,users,events}`, auth via Bearer **OR** `x-internal-key`; gateway rewrites `^/api/analytics → /analytics`.

**Honest gap (documented in C-105 §11a):** `tec-analytics-service` aggregates are **platform-level** — `DailyMetric` keyed by date only, no `merchantId`. Merchant isolation (C-105 §6) needs a **service-side** schema/aggregation change first; not faked client-side. Dashboard is platform/admin-only until then.

**Verified:** typecheck 0 · 24/24 tests (+6) · build clean · lint 0 errors · Drift + payment-policy gates 0 violations. KB: C-105 §11a implementation-status added (charter stays `[Planned]` — pre-deploy); validate-charters / truth-framework / links / structure / c57-index all green.

**Constitutional (C-122 — NEW):** elevated Analytics to its Tier-1 runtime identity, mirroring the Zone precedent (Zone has C-120 runtime charter; Analytics had only the C-105 app charter). **C-122 Analytics Constitutional Runtime Charter** = Intelligence Runtime / **Reality Infrastructure** ("what is happening?"), the **Reality↔Trust duality** with Zone, the **§5 disclosure boundary** (aggregate-everything / expose-only own|de-identified|sovereign — P6), **engine-vs-surface** ownership (Analytics owns the engine, each app owns its surface — preserves C-119 Rule 1), and **operational(raw) vs institutional(Zone-verified)** input layers. C-105 reconciled → product/BI-surface charter that defers to C-122. Registry rebuilt (102→103, 100% coverage, tier-1); C-57 TIER 10 → C-119→C-122. Truth State `[Future Vision]` (vision, not runtime).

**NEXT for Analytics:** deploy (Vercel) + register Pi App ID (Portal) → then flip rollout-registry `to-build → live` + C-105 → `[Current]`; service-side merchant scoping for §6.

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
