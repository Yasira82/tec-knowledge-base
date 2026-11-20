# P7 — Testing & QA · cycle 2026-11-11 · Run 4

**Status: PASSED_WITH_FINDINGS** · actual results only · 13 Nov 2026

> **What was run:** each repository's own suite, in this environment, on its working tree — which
> is `origin/main` **plus the local remediation commits of Runs 1–3** (not pushed: GitHub Actions
> is refused for the account). Those commits add tests; none removes or skips one. A run on `main`
> itself is BLOCKED until CI is back.

## Results

**Backend — 20 services, 4,264 tests, all passing** (`backend-test-run.txt`). Two tests skip by
design: a real-database test each in connection-service and identity-service, which run only with
`TEST_DATABASE_URL` → part of **0038**. Every service declares coverage thresholds, and backend CI
runs `jest --coverage`, so they are enforced there.

**Apps — 25 repositories, 9,559 tests, all passing**, plus tsc and lint clean in each (Run 3's
remediation ran every suite):

| Repository | Tests |
|---|---|
| tec-template-base | 223 |
| Tec-Alert | 204 |
| Tec-Analytics- | 213 |
| Tec-Connection | 584 |
| Tec-Dx | 193 |
| Tec-Elite | 190 |
| Tec-Epic | 201 |
| Tec-Estate | 204 |
| Tec-Explorer | 505 |
| Tec-Fundx | 194 |
| Tec-Insure | 195 |
| Tec-Legend | 196 |
| Tec-Nexus | 203 |
| Tec-Nx | 198 |
| Tec-Titan | 190 |
| Tec-Vip | 194 |
| Tec-system | 203 |
| tec-nbf | 198 |
| tec-brookfield | 191 |
| Tec-Life | 581 |
| Tec-Zone | 229 |
| Tec-Commerce | 424 |
| Tec-Assets | 327 |
| Tec-Ecommerce | 248 |
| Tec-App (Hub) | 3271 |

## What was checked beyond pass/fail

| Check | Result |
|---|---|
| Coverage floors are enforced | **In 1 of the 21 app repositories that declare one → 0037.** 21 `vitest.config`s declare 60/60/60/50 (the Hub, Assets, Commerce and Ecommerce declare none); CI runs `npm test` (no coverage) and the coverage provider is not even installed. Only Life runs `test:coverage`. The template, measured here: **69.5 % statements · 61.2 % branches · 63.9 % functions · 74.9 % lines** — it would pass its own floor |
| A test crosses a service boundary | **None does → 0038.** Producer and consumer of each event test against their own hand-written payloads; nothing checks that the stream name and shape one side writes is what the other reads |
| End-to-end (Playwright) | every app has an e2e workflow (1–7 specs); not run here (needs browsers + a deployed backend) — P8 |
| The flaky Analytics test (Run 2: 1 of 189 failed once) | **Not reproduced** — 7 runs, 5 of them while the backend suites loaded the machine. Kept on watch; no finding |
| Tests that only pass against the old code | none found: every Run 1–3 fix came with a test shown red on the old code |

## Summary

**2 findings: 2 MEDIUM.** The suites are large and green; the weakness is in what they are
**allowed to skip**: a coverage floor nobody runs, and the seams between services, where three of
this cycle's most costly defects lived (a consumer that listened on the wrong stream and was never
registered — TEC-AUDIT-0001's neighbour; the reconciliation's missing event, 0030; the
best-effort stream, 0036).
