# Remediation after Run 4 — cycle 2026-11-11 (13 Nov 2026)

> Truth State: **[Planned State]** — committed locally in each repository, not pushed (GitHub
> Actions is refused for the account; no backend PR before 1 Dec).
> Verification: [Code Verified] — every new test was shown failing on the old code (or on a
> deliberately broken copy) before it was trusted; each touched service's full suite, tsc and lint.

## TEC-AUDIT-0036 — completion notifications, live updates, analytics

| Step | Where | Proof |
|---|---|---|
| notification, realtime and analytics read **both** `payment.completed` and `payment.completed.v1` in one group, acting **once per paymentId** (the legacy event has no eventId; the two streams carry different ones); a failed handler releases its claim so the redelivery retries; new groups start at `$` — no replay of history | `Tec-core-backend 1c5aaf38` | one test per service, red on the old consumer; notification 55 · realtime 32 · analytics 178 |
| the log no longer says the outbox retries the legacy stream | `f2d6bfa3` | payment 72 controller tests |
| **the drift check compares consumers, not only names**: each listed consumer must name its stream as a quoted literal in its own `src/`. Run on `main` it found 4 stale entries (wallet and commerce still listed on the legacy stream; search/explorer still listed on `kyc.verified` / `kyc.rejected` after moving to `zone.badge.*`); catalog corrected | KB `666ed93` | 36/36 on `origin/main` |

**Deploy order (owner):** the three consumers first. Retiring the legacy publish is a separate,
later change — after they are live, so no completion falls between. Until then both streams
flow and each payment is acted on once.

## TEC-AUDIT-0038 — the event contract, and the real-database tests

| Step | Where | Proof |
|---|---|---|
| `shared/contracts/payment.completed.v1.json`: the stream and three real examples (Pro purchase · order payment · asset purchase) | `Tec-core-backend 7dc328c6` | — |
| payment-service builds the payload in **one** place (`payment-events.ts`) — it was written out three times, kept equal by comments; its test asserts the real payload has exactly the contract's fields and types | same | a field renamed in the contract → the producer test fails |
| commerce (subscription + order) and asset feed the examples through their **real** handlers and check their stream name | same | pointing the order consumer back at the old stream (its historical bug) → the test fails |
| CI: a change to the contract re-runs those three services; a service whose tests read `TEST_DATABASE_URL` gets an empty database on the job's Postgres | same `ci.yml` | run here on a local Postgres 16: connection 411 and identity 176, **no test skipped** |

Suites: payment 477 · commerce 324 · asset 142 · connection 411 · identity 176 — all green.
Not yet covered by a contract: trust (legend), nexus, wallet — next time each is opened.

## TEC-AUDIT-0037 — the coverage floor

Template (`tec-template-base 7718d93`): CI runs `test:coverage`; `@vitest/coverage-v8` pinned;
template-sync carries a marker on `ci.yml` and the dependency pin, so fleet-drift names any app
that does not run it. Measured: 69.5 / 61.3 / 63.9 / 74.9 — above its floor. The apps: below.
