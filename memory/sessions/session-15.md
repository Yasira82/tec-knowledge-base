# SESSION 15 — ANALYTICS APP (build-next) (27 June 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

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
