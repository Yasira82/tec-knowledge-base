# Phase B2 — P2/P3 Resolution PRD

> **Version:** v1.0 — June 2026
> **Authority:** audits/PLATFORM_WORK_MAP_2026-06-21.md §3
> **Truth State:** `[Planned State]`
> **Governance State:** `[Governance Approved]`
> **Scope:** All P2 (deferred quality) + P3 (forward/strategic) items

---

## Purpose

After Pi Portal submission, the platform enters Phase B2: closing the quality debt that was deferred to unblock submission. This PRD defines every P2/P3 item with: owner, effort, acceptance criteria, and dependency. Total effort: ~40 hours across 6 weeks.

---

## P2 — Deferred Quality (non-blocking for Portal)

### P2-1: Sentry Major-Version Alignment

| Field | Value |
|-------|-------|
| **ID** | P2-1 |
| **Item** | Sentry major-version alignment (Assets @sentry/nextjs v10 vs v8 elsewhere) |
| **Current state** | Build-verified — does not break functionality |
| **Why deferred** | Assets uses @sentry/nextjs v10 (newer), other apps use v8. The mismatch is cosmetic — both work. |
| **Effort** | 4 hours |
| **Owner** | Founder |
| **Acceptance criteria** | All 4 apps + Hub use the same @sentry/nextjs major version. CI green. |
| **Steps** | 1. Check @sentry/nextjs v10 compatibility with Hub/Ecommerce/Commerce<br/>2. If compatible: bump all to v10<br/>3. If not: downgrade Assets to v8<br/>4. Test Sentry error capture in each app<br/>5. Verify Vercel build passes |
| **Dependency** | None |

### P2-2: tec-realtime-service Unit Tests

| Field | Value |
|-------|-------|
| **ID** | P2-2 |
| **Item** | tec-realtime-service unit tests |
| **Current state** | Service is healthy and running — no tests |
| **Why deferred** | Service works in production; tests are hygiene |
| **Effort** | 6 hours |
| **Owner** | Founder |
| **Acceptance criteria** | ≥ 70% coverage on tec-realtime-service. CI green. |
| **Steps** | 1. Review realtime-service code<br/>2. Write unit tests for: WebSocket connection, room join/leave, message broadcast, reconnection logic<br/>3. Add to CI: `npm test` in tec-core-backend/realtime-service<br/>4. Set coverage gate at 70% |
| **Dependency** | None |

### P2-3: Move vite/vitest to devDependencies

| Field | Value |
|-------|-------|
| **ID** | P2-3 |
| **Item** | Move vite/vitest to devDeps where they leaked into prod deps |
| **Current state** | Some apps have vite/vitest in `dependencies` instead of `devDependencies` |
| **Why deferred** | Does not affect runtime — Vercel bundles correctly |
| **Effort** | 2 hours |
| **Owner** | Founder |
| **Acceptance criteria** | `npm ls vite vitest` shows them only in devDependencies across all repos |
| **Steps** | 1. For each repo: `npm uninstall vite vitest` then `npm install -D vite vitest`<br/>2. Verify build still works<br/>3. Verify test still runs<br/>4. Commit |
| **Dependency** | None |

### P2-4: tec-ui Coverage Floor

| Field | Value |
|-------|-------|
| **ID** | P2-4 |
| **Item** | Raise tec-ui coverage floor as components gain tests |
| **Current state** | Coverage floor set at 72/62/68/75 (lines/branches/functions/statements) |
| **Why deferred** | Coverage grows organically as components are tested |
| **Effort** | 8 hours (ongoing) |
| **Owner** | Founder |
| **Acceptance criteria** | Coverage floor raised to 80/70/75/80 by end of Phase B2 |
| **Steps** | 1. Identify untested components<br/>2. Write tests for PaymentModal, createU2APayment, TEC_COLORS, etc.<br/>3. Raise coverage gate in CI<br/>4. Repeat weekly |
| **Dependency** | None |

---

## P3 — Forward / Strategic (post-Portal)

### P3-1: Publish tec-auth v1.1.0 + Bump Consumers

| Field | Value |
|-------|-------|
| **ID** | P3-1 |
| **Item** | Publish tec-auth v1.1.0 + bump consumers to the fixed middleware |
| **Current state** | tec-auth has CSRF fix locally (v1.0.0→v1.1.0 in code) but not published to npm |
| **Why deferred** | Apps have inline middleware fix — package publish is defence in depth |
| **Effort** | 4 hours |
| **Owner** | Founder |
| **Acceptance criteria** | `@yasser172/tec-auth@1.1.0` on npm. All 4 apps + template import it. |
| **Steps** | 1. `npm version 1.1.0` in tec-auth<br/>2. `npm publish`<br/>3. In each app: `npm install @yasser172/tec-auth@1.1.0`<br/>4. Replace inline middleware with package middleware<br/>5. Test CSRF still works<br/>6. Deploy |
| **Dependency** | Portal approval (so we don't change auth mid-review) |

### P3-2: Migrate Apps to Package Middleware (DRY)

| Field | Value |
|-------|-------|
| **ID** | P3-2 |
| **Item** | Migrate the 4 apps' inline middleware → the fixed package middleware |
| **Current state** | Each app has its own copy of the CSRF middleware |
| **Why deferred** | DRY refactor — not urgent, but reduces maintenance burden |
| **Effort** | 6 hours |
| **Owner** | Founder |
| **Acceptance criteria** | All 4 apps import `createAuthMiddleware` from `@yasser172/tec-auth` — no inline copies |
| **Steps** | 1. After P3-1 (tec-auth v1.1.0 published)<br/>2. For each app: delete inline middleware, import from package<br/>3. Test CSRF + SSO<br/>4. Deploy |
| **Dependency** | P3-1 |

### P3-3: Promote npm-audit to Blocking

| Field | Value |
|-------|-------|
| **ID** | P3-3 |
| **Item** | Promote npm-audit from advisory → blocking once the advisory backlog is triaged |
| **Current state** | npm-audit runs in CI as advisory (non-blocking) |
| **Why deferred** | Advisory backlog needs triage first — can't block CI on untriaged vulnerabilities |
| **Effort** | 6 hours |
| **Owner** | Founder |
| **Acceptance criteria** | npm-audit is blocking in CI. Advisory backlog = 0. |
| **Steps** | 1. Run `npm audit` in each repo<br/>2. Triage each finding: fix / accept risk / suppress<br/>3. For accepted risks: document in SECURITY.md<br/>4. Change CI from `npm audit --audit-level moderate` (advisory) to `npm audit --audit-level high` (blocking)<br/>5. Test CI |
| **Dependency** | None (but should be done after P2 items to avoid CI churn) |

### P3-4: Observability SLOs Wired to Dashboards

| Field | Value |
|-------|-------|
| **ID** | P3-4 |
| **Item** | Observability SLOs (C-78) wired to dashboards |
| **Current state** | C-78 defines SLOs but they're not wired to monitoring dashboards |
| **Why deferred** | Requires Track C (observability build-out) to be further along |
| **Effort** | 8 hours |
| **Owner** | Founder |
| **Acceptance criteria** | Sentry dashboard shows: payment success rate ≥ 95%, SSO 401 rate < 1%, API p95 < 500ms |
| **Steps** | 1. Review C-78 SLO definitions<br/>2. Create Sentry alerts for each SLO<br/>3. Create Vercel Analytics dashboard<br/>4. Create Railway health dashboard<br/>5. Wire to C-92 Platform Health Model |
| **Dependency** | Track C Weeks 8–10 (observability build-out) |

---

## Timeline

| Week | P2 Items | P3 Items | Total Hours |
|------|----------|----------|-------------|
| W1 (post-Portal) | — | — | 0 (monitoring Portal review) |
| W2 | P2-3 (vite→devDeps) | — | 2 |
| W3 | P2-1 (Sentry align) | — | 4 |
| W4 | P2-2 (realtime tests) | — | 6 |
| W5 | P2-4 (tec-ui coverage) | P3-1 (tec-auth v1.1.0) | 12 |
| W6 | P2-4 (continued) | P3-2 (migrate to package) | 14 |
| W7 | — | P3-3 (npm-audit blocking) | 6 |
| W8–W10 | — | P3-4 (SLOs → dashboards) | 8 |
| **Total** | | | **52 hours** |

---

## Success Metrics

| Metric | Baseline (Session 14) | Target (End of Phase B2) |
|--------|----------------------|--------------------------|
| P2 items open | 4 | 0 |
| P3 items open | 4 | 0 (or 1 if P3-4 deferred to Track C) |
| tec-realtime-service coverage | 0% | ≥ 70% |
| tec-ui coverage floor | 72% | 80% |
| npm packages using inline middleware | 4 apps | 0 (all use package) |
| npm-audit blocking | No | Yes |
| Sentry version alignment | Mixed (v8/v10) | Unified |
| Overall Platform Score | 9.0–9.2 | 9.3–9.4 |

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| P3-1 (tec-auth publish) breaks apps | M | H | Test in staging first; have rollback plan |
| P3-3 (npm-audit blocking) finds critical vuln | M | M | Triage before promoting to blocking |
| P2-2 (realtime tests) reveal bugs | L | M | Fix bugs as found; tests are the point |
| Phase B2 slips beyond W7 | M | L | P2-4 (coverage) can run in parallel with other work |

---

## Exit Criteria (Phase B2 Complete)

- [ ] All 4 P2 items closed
- [ ] All 4 P3 items closed (or P3-4 deferred to Track C with documented reason)
- [ ] Overall Platform Score ≥ 9.3
- [ ] CI still 10/10 green
- [ ] No regressions in production payments
- [ ] Phase B2 entry in C-02 + C-50

---

## Related Documents

```
audits/PLATFORM_WORK_MAP_2026-06-21.md   — Source of P2/P3 items
knowledge-base/C-02___CURRENT_STATE_.md  — Living state doc
knowledge-base/C-78___PLATFORM_OPERATIONS___RELIABILITY_GOVERNANCE.md — SLOs
knowledge-base/C-92___PLATFORM_HEALTH_MODEL.md — Health model
knowledge-base/C-43_CI_CD_DevOps.md      — CI/CD rules
```
