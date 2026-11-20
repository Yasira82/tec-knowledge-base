# P6 evidence — cycle 2026-11-11 · Run 4

```bash
git grep -lnE "payment\.completed\.v1|PAYMENT_COMPLETED" origin/main -- '*/src/**/*.ts'      # producers + consumers
git grep -nE "['\"]payment\.completed['\"]|EVENTS\.PAYMENT_COMPLETED" origin/main -- '*/src/**/*.ts'
```

| Ref | Finding | Location | Observation |
|---|---|---|---|
| EV-0075 | 0036 | `tec-payment-service/src/controllers/payment.controller.ts:600-630` | direct publish of `payment.completed` after the response; skipped if the publisher is not ready, logged as "outbox worker will retry" |
| EV-0076 | 0036 | `notification.consumer.ts:36` · `redis.consumer.ts:36` (realtime) · `analytics.consumer.ts:134` | read the unversioned stream only |
| EV-0077 | 0036 | `manifests/events-catalog.yaml:60-72` · `scripts/check-drift.py:167-193` | catalog lists wallet/commerce as consumers (both on `.v1` now); drift compares names, not consumers |
