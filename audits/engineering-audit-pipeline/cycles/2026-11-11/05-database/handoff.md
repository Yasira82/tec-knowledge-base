# P4 → handoff · cycle 2026-11-11 · Run 3

- **Remediation now (owner's rule: fix the run before the next):** 0030 and 0031 in
  payment-service — a local backend commit, each with a test red on the old code. No PR before 1 Dec.
- **P6:** trace a reconciled payment through to delivery once 0030 is fixed; list every write to
  `payment.status` and confirm each goes through the state machine.
- **Owner:** the read-only Float row counts (0012 / 0013) before their migration ships.
- **After 0030 ships:** payments the cron completed before the fix have no event. A one-off,
  audited re-emit for those rows (by `PAYMENT_RECONCILED` audit entries) is a separate, owner-approved step — never ad hoc (Forbidden #10).
