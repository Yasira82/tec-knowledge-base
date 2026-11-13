# P4 evidence — cycle 2026-11-11 · Run 3

All reads are `git show origin/main:<path>` in `Tec-core-backend` (no checkout, nothing run).

```bash
git show origin/main:tec-payment-service/src/services/reconciliation.service.ts | sed -n '80,95p;180,215p'
git show origin/main:tec-payment-service/src/controllers/payment.controller.ts | sed -n '1280,1300p;1365,1460p'
git grep -n "saveOutboxEvent\|status: 'completed'" origin/main -- tec-payment-service/src
```

| Ref | Finding | Location | Observation |
|---|---|---|---|
| EV-0060 | 0030 | `reconciliation.service.ts:80-95` | `markCompleted`: bare `payment.update` + audit; no outbox |
| EV-0061 | 0030 | `reconciliation.service.ts:194-210` | runs when Pi shows completed or approved+verified |
| EV-0062 | 0030 | `server.ts:85-96` | hourly cron |
| EV-0063 | 0030 | `payment.controller.ts:1280-1300` | `completeFromRecovery`: conditional + event, the model |
| EV-0064 | 0031 | `payment.controller.ts:1442-1456` | guard `status !== 'cancelled'` only |
| EV-0065 | 0031 | `payment.controller.ts:1371-1376` | terminal check, then unconditional update |
| EV-0066 · 0067 | 0032 | `payment.controller.ts:377 · 555` | `tx.payment.update({ where: { id } })` after a read |

The negative results (wallet CHECK, unique keys, conditional order updates, idempotent
consumers) were each found by reading the line that makes them true, not by a search returning
nothing.
