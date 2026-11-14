# P4 — Database & Data Integrity · cycle 2026-11-11 · Run 3

**Status: PASSED_WITH_FINDINGS** · one check BLOCKED (production row counts for 0012 / 0013) ·
[Code Verified] at `origin/main`, 13 Nov 2026

## What was checked, and what it found

| Check | Method | Result |
|---|---|---|
| Money columns | every `schema.prisma` on main: `Decimal` vs `Float` on amount-like fields | DECIMAL(20,8) for payments, wallets, ledger, orders. The Float columns are the ones Run 1 found → **0012 · 0013, still open** (corrected in Run 6: this line first said "fixed locally, Run 1" — the register said, rightly, *deferred to P4*, and P4 did not do them; asset `price` is still `Float` at HEAD) |
| Wallet never negative (Invariant #1) | migrations | `CHECK (balance >= 0)` in `20260419000000_financial_integrity` — **holds** |
| One Pi payment, one row | unique constraints | `payments.pi_payment_id` is `@unique`; commerce `orders.payment_id` / `pi_payment_id` unique since `20261109120000_align_with_schema` — **holds** |
| Order state changes | commerce writes to `orders.status` | conditional `updateMany` on the from-state — **holds** |
| Payment state changes | every write to `payment.status` in payment-service | Recovery endpoint fixed (`completeFromRecovery`); **the hourly reconciliation completes with no event → 0030 (HIGH)**; a recovery branch can cancel a payment that completed while Pi was asked → **0031**; approve/complete are check-then-act → **0032** |
| Event on every completion (ADR-004) | `saveOutboxEvent` against each path that sets `completed` | 2 of 3 paths emit; the cron does not (0030) |
| Consumers idempotent | each `payment.completed.v1` consumer | asset (upsert by paymentId), commerce subscription (same payment_id → return), identity legend/nexus (by paymentId) — **all idempotent**, which is why 0032 is LOW |
| Migrations apply to an empty database | CI job (backend) | Exists; not run here (no CI — billing hold) |
| Float rows in production (0012 / 0013) | row counts | **BLOCKED** — no database access from this environment; the owner runs the read-only count before the migration ships |

## Summary

**3 findings: 1 HIGH · 1 MEDIUM · 1 LOW.** The schema protects the money invariants well (CHECK,
DECIMAL, unique keys). The weakness is in code, and it is one pattern: **a status written outside
the state machine**. The recovery endpoint was moved onto the conditional, event-emitting path
in October; two neighbours were not. 0030 is the one with a user-visible cost — paid, nothing
delivered — and it runs every hour.
