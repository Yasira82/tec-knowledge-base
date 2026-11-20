# Remediation after Run 3 — cycle 2026-11-11 (13 Nov 2026)

> Truth State: **[Planned State]** — committed in `Tec-core-backend` (local, not pushed: GitHub
> Actions is refused for the account; no backend PR before 1 Dec).
> Verification: [Code Verified] — each test shown red on the old code, then green; payment-service
> 469/469, `tsc`, build; lint has only its 3 earlier warnings.

## Fixed

| Finding | Fix | Proof |
|---|---|---|
| **0030 (HIGH)** | `services/payment-transitions.ts` — `completeOpenPayment`: the status changes only from `created`/`approved` (in the WHERE), and `payment.completed.v1` is queued in the same transaction, with the normal path's envelope. The hourly reconciliation uses it; a payment another path finished first is counted as skipped and gets no second event or audit row | `payment-transitions.test.ts`: 4 cases red on the old reconciliation |
| 0031 | `cancelOpenPayment` (same condition) in both cancel branches of `resolve-incomplete`; the audit row only when the payment really changed | a controller case for the race, red on the old code |

**Correction made while fixing 0031:** the endpoint already refuses a payment that is final when
it first reads it (409). The real gap is the window of one or two Pi round trips between that read
and the write. The finding's text is corrected in the register.

## Then: 0033 · 0035 (template + every app)

| Finding | Fix | Proof |
|---|---|---|
| 0033 | `src/lib/gateway-fetch.ts`, shared through template-sync: `fetch` with a deadline **just past the gateway's own** — the gateway answers 504 at 25 s, so the BFF waits 30 s (90 s for an `/ai/` path; the gateway waits 75 s for TEC AI). While the gateway is alive its answer always comes first, so nothing it would still complete is cut — a payment approve included; the deadline only fires when the gateway cannot answer at all. A codemod moved **435 calls in 25 repositories (437 matched, the Hub's 2 own-origin calls then restored)** onto it | `gateway-fetch.test.ts` (shared): the two deadlines, a caller's own signal, pass-through — and a scan that fails on any bare gateway fetch in `src/`, shown first to find one. Every repository: tsc, lint, full suite green (the Hub: 3,271 tests) |
| 0035 | The example route moves to `docs/examples/bff-route.example.ts` (still type-checked) and out of the 20 apps that carried it unchanged and never called it | each app's suite green after removal |

**A correction found by the Hub's own tests:** two of Run 3's 467 "gateway calls" were the Hub
calling its **own** origin (`${req.nextUrl.origin}/api/auth/refresh`). The codemod had wrapped
them; the Hub's SSO-timeout guard failed, and that is how it was seen. They are back to plain
`fetch` (each already had its own bound), and the scan now exempts own-origin calls. The real
count was 437 of 465. A deadline shorter than the gateway's was considered and rejected: it would
cut a payment approve the backend was still completing.

## Then: 0032

approve and complete now write through the controller's `transitionPayment` (the same helper
the fail / cancel race fix used): the from-state is in the WHERE; the loser of a race writes
nothing, queues no event and gets 409 — the answer a sequential duplicate already got. Three
cases red on the old code; 472/472 (`Tec-core-backend 5863f4b9`). No unconditional status write is
left in payment-service: a search for `payment.update(` / `payment.upsert(` in its source finds
only comments (the search finds the old calls on `origin/main`, so its silence counts).

## Production read (owner, 13 Nov — read-only, Railway console on payment-service)

`diagnose-recovery-completions.mjs` as deployed (the `--counts-only` / per-path version is in the
local commit, not yet deployed — so the deployed one ignored the flag and listed the one row it
flags; that row is not reproduced here):

| | |
|---|---|
| Completed payments | 1,000 |
| with `payment.completed.v1` | 471 — from 2026-06-20 to 2026-11-11 |
| **without** it | 529 — from 2026-03-14 to **2026-08-06** |
| without an event *and* without `PAYMENT_CONFIRMED` | 19 of 529 |
| look like a Pro / Enterprise purchase | 1 — 10 π, 6 Aug, `user=gateway` (a service identity, not a Pioneer) |

What it says:

1. **Nothing completed after 6 Aug is missing its event.** Whatever dropped events stopped then;
   the hourly reconciliation (0030) left **no** payment without its event in the three months since.
   0030 was a real defect with no production victims in that window — the fix stays, it prevents
   the next one.
2. **Most of the 529 are history, not victims.** The event stream starts on 20 Jun (the outbox's
   first row); payments completed before it never had one, by construction. 510 of the 529 carry
   the normal path's `PAYMENT_CONFIRMED`, so they completed normally, in the days of direct
   publishing.
3. **The only subscription-shaped one is not a person** (`user=gateway`).

**Decision for the owner: do not re-emit in bulk.** Re-sending 529 events would replay
deliveries for months-old payments that were delivered through the older path; the consumers are
idempotent by payment id, but a consumer that did not record the old delivery would deliver
again. If anything is to be re-sent, it is the narrow set *completed between 20 Jun and 6 Aug,
with no event and no `PAYMENT_CONFIRMED`* — checked one by one against the consuming app first.
`1,000` exactly is worth one `count(*)` to rule out a cap before relying on the total.

## Not done — and why

- **Re-emitting events for payments the cron already completed.** Those users paid and may not
  have received what they bought. Finding them (the `PAYMENT_RECONCILED` / `completed` audit rows)
  and re-queuing their event is a write to production — a one-off, audited step the owner
  approves (Forbidden #10). The consumers ignore a duplicate, so it is safe to re-emit.
- **`completeFromRecovery`** (the recovery endpoint's own completion) is conditional on
  `status <> 'completed'` rather than on the open states. Left as it is: it runs only when Pi
  says the money moved, after a 409 on a final state, and Pi is the truth for money. Noted for P6.
- **0034** (needs an ADR — where domain contracts live) — the owner's decision.
