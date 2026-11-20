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
that does not run it. Measured: 69.5 / 61.3 / 63.9 / 74.9 — above its floor.

**Every app, measured first, then switched on** (statements · branches · functions · lines):

| App | Measured | Floor in CI | Commit |
|---|---|---|---|
| 18 template apps (Alert · Analytics · Dx · Elite · Epic · Estate · Explorer · FundX · Insure · Legend · Nexus · NX · Titan · VIP · System · NBF · Brookfield · Zone) | 67.6–75.2 · 58.8–65.9 · 61.2–68.8 · 73.3–80.8 | the fleet's 60/60/60/50 | one each |
| Life | 83.4 · 76.8 · 81.3 · 87.2 | already ran it | — |
| **Hub** | 75.9 · 66.8 · 71.3 · 79.4 | 60/60/60/50 — **and it could not measure at all before**: the provider was declared twice (root `^4.0.18`, frontend `^4.1.8`) and the newer one crashed against vitest 4.0.18; now declared once, at the root | `Tec-App 0288c0e7` |
| Connection | 45.6 · 36.4 · 36.5 · 51.3 | **ratchet** at that | `7796c59` |
| Commerce | 54.0 · 48.0 · 46.3 · 56.8 | **ratchet** | `2c78a80` |
| Assets | 39.8 · 32.8 · 32.5 · 41.3 | **ratchet** | `849bd2e` |
| Ecommerce | 34.8 · 29.3 · 27.1 · 38.5 | **ratchet** | `9302dfb` |

A **ratchet** is a floor set at what the app passes today: it can only go up, and each number is
raised as tests are added, until it reaches the fleet's. It is the honest alternative to lowering
the fleet's floor or leaving the app without one.

**Still open — how the template apps count.** Commerce, Assets and Ecommerce are measured over
**every** file in `src/` (an untested file counts as 0). The template's config measures only the
files the tests load, so an untested file does not lower its number — the same three apps read
~77 % that way and 35–54 % honestly. Moving the template to `include: ['src/**']` is the right
measure and will put most apps under 60; it needs the same ratchet, app by app. Scheduled, not done.
