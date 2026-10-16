# Security audit: key-only routes outside `/internal/` (C17), 2026-10-16

Truth State: [Current State] · Verification: [Code Verified] (tec-core-backend #432, merged) ·
[Runtime Verified] for the exposure check below (owner's read-only query, 2026-10-16).

## The rule

The gateway adds `x-internal-key` to **every** request it proxies, so the key alone never
proves a server called. A service-only route must also see `x-tec-caller` = `service` (a BFF or
backend that proved the key to the gateway) or no mark at all (a direct private-network call).
The gateway already refuses any `/internal/` path to a caller without the key; routes outside
`/internal/` must check the mark themselves.

## What was open, and closed by #432

| Route | Reachable by | Effect |
|---|---|---|
| commerce `POST /commerce/subscriptions/grant` | any signed-in user | free PRO / ENTERPRISE for any user id, every app |
| commerce `POST /commerce/products/admin/deactivate` | **anyone, no session** (public `/api/commerce/products` gateway prefix) | hide any seller's products |
| commerce `POST /commerce/orders/reserve` · `release` | any signed-in user | orders as anyone; stock held or released |
| commerce `expire-stale` · `renewable` · `stats` | any signed-in user | run the sweep, probe renewability, read revenue stats |
| asset `POST /assets/marketplace/:id/lock` · `unlock` | any signed-in user | freeze any listing |
| life `GET /identity/life/context/:username` | any signed-in user | read what anyone shared with TEC AI |
| connection `/reports/queue` · `/reports/:id/resolve` · `/stories/purge-expired` | any signed-in user | read the moderation queue; close reports filed against you |

Legitimate callers are unaffected: Nexus and the platform service call directly (no mark); the
Hub's AI BFF and Connection's moderation BFF and story cron send the key to the gateway
(marked `service`). Already closed and unchanged: wallet (`InternalGuard`), storage, analytics
(a Bearer is verified first), explorer purge and connection avatar-key (`/internal/`), asset
`internal/sold`.

## Was `grant` used? — no

Read-only query on db-commerce: every `subscription_history` row with a paid plan, `ACTIVE`, and
no `payment_id`, grouped by origin. `founding` (note `Founding Pioneer #N`) 10 · `other` 3. The
three `other` rows are `Upgraded to PRO` / `ENTERPRISE` for one user — written by `subscribe()`,
the purchase path, which refuses a paid plan without a Pi payment and verifies it with
payment-service; it records the Pi id on the subscription, not on the history row. No grant
with an unknown note exists. The other routes leave no comparable trace and were not checked.

## Left

- Identity's copies of the moved modules (connection reports and stories, explorer) still carry
  the old check; they are unreachable while the gateway carve-outs are set, and are removed in
  the contract step.
