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

## Not done — and why

- **Re-emitting events for payments the cron already completed.** Those users paid and may not
  have received what they bought. Finding them (the `PAYMENT_RECONCILED` / `completed` audit rows)
  and re-queuing their event is a write to production — a one-off, audited step the owner
  approves (Forbidden #10). The consumers ignore a duplicate, so it is safe to re-emit.
- **`completeFromRecovery`** (the recovery endpoint's own completion) is conditional on
  `status <> 'completed'` rather than on the open states. Left as it is: it runs only when Pi
  says the money moved, after a 409 on a final state, and Pi is the truth for money. Noted for P6.
- **0034** (needs an ADR — where domain contracts live) — the owner's decision.
