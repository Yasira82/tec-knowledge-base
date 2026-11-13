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

## Not done — and why

- **Re-emitting events for payments the cron already completed.** Those users paid and may not
  have received what they bought. Finding them (the `PAYMENT_RECONCILED` / `completed` audit rows)
  and re-queuing their event is a write to production — a one-off, audited step the owner
  approves (Forbidden #10). The consumers ignore a duplicate, so it is safe to re-emit.
- **0032** (approve / complete check-then-act) — LOW; the consumers already absorb a duplicate.
  Next time payment-service is opened.
- **`completeFromRecovery`** (the recovery endpoint's own completion) is conditional on
  `status <> 'completed'` rather than on the open states. Left as it is: it runs only when Pi
  says the money moved, after a 409 on a final state, and Pi is the truth for money. Noted for P6.
- **0033 · 0035** (template + apps) and **0034** (needs an ADR) — next.
