# PROPOSED — Transactional Outbox for payment events

> Truth State: `[Current State]` for what the code does · `[Planned State]` for the record
> Governance State: `[Draft]` — the owner accepts it and assigns the number (suggested: ADR-015)
> Verification: `[Code Verified]` — Last verified on code: 2026-11-14 (tec-core-backend, work branch)

## Context

A payment changes state in payment-service's database, and other services must learn of it
through an event (`payment.*.v1` on Redis Streams, ADR-005): commerce delivers an order or
activates Pro, Legend records an outcome. Writing the row and then publishing the event are
two systems. If the process dies between them, either the state changed with no event (a
paid user gets nothing) or an event went out for a change that rolled back.

The platform solved this long ago and cites the solution everywhere as "ADR-004". C-64's
ADR-004 is **BFF-Only Architecture**; the outbox has no record. The rule exists only in code
and in the citations.

## Decision

1. **The state change and its event are one transaction.** Every payment transition writes
   its `outbox_events` row with `saveOutboxEvent(tx, …)` inside the same
   `prisma.$transaction` as the `payments` update (`payment-transitions.ts`,
   `payment.controller.ts`). There is no path that changes a payment's state and publishes
   directly.
2. **A worker publishes.** `outbox.worker.ts` polls (`OUTBOX_WORKER_INTERVAL_MS`, default 5 s),
   takes up to 10 `pending` rows whose `next_retry` has passed, `XADD`s each to its stream
   with the row id as `outboxId`, and marks it `published`.
3. **Failures retry with backoff, then stop visibly.** A failed publish sets
   `next_retry = now + min(2^attempts s, 60 s)`; the last allowed failure (`max_attempts`,
   default 5) marks the row `failed` and logs `Outbox event permanently failed`.
4. **Delivery is at-least-once.** Consumers must be idempotent (C-70); `outboxId` in every
   message is the key to deduplicate on.
5. **Scope: payment-service only.** It is the only Pi custodian (Invariant #8). Another
   service that needs the same guarantee adopts this ADR by name.

## Consequences

- An event can be published twice (a crash after `XADD`, before `published`) but never lost
  while the row exists. Consumers carry the cost of idempotency.
- **Known gaps, recorded here so they are not rediscovered:**
  - The worker's `SELECT … FOR UPDATE SKIP LOCKED` runs outside a transaction, so its lock
    ends with the statement: two replicas can publish the same row. This is within the
    at-least-once contract above; it is not exactly-once and must not be described as such.
  - Until 14 Nov 2026 the last allowed failure never marked a row `failed` — it stayed
    `pending` and was never picked again (TEC-AUDIT-0049, fixed on the work branch).
    Rows already stuck need an audited recovery (Forbidden #10), not an ad-hoc update.
  - `failed` rows have no alert. Wiring one (C-78) is the follow-up that makes decision 3
    true for a person and not only for the log.

## On acceptance — citations to re-point to the assigned number

- KB: C-88 §(ADR table) · C-90 (idempotency control) · C-129 (two places) · C-131 · C-132 §(custody box)
- tec-core-backend: `CLAUDE.md` ("no C-64 record yet") · `tec-payment-service/src/controllers/payment.controller.ts` (3 comments) · `src/services/payment-transitions.ts` (1 comment)

**References:** C-47 (Invariant #2, #4, #8; Forbidden #2, #6) · ADR-005 (Redis Streams) · C-70 (event governance, idempotent consumers) · C-71 (financial integrity)
