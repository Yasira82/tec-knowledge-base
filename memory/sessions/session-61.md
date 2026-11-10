# Session 61 — every service migrates at start; production's databases compared, not assumed; one guard everywhere; the rotation begins (8–10 Nov 2026)

> Truth State: **[Current State]**. Everything below is merged to `main` unless it says otherwise.
> Verification: **[Code Verified]** — tests and tsc on every PR, each migration run against a real
> Postgres 16 (an empty database and a replica of production). **[Runtime Verified]** where it says
> so: Railway deploy logs, settings and read-only SQL, from the owner's screenshots.
> Same branch as sessions 57–60 (`claude/tec-knowledge-base-review-6wzngc`). Follows
> [session 60](session-60.md), whose "Left open" list this session worked through in order.

## Merged

| PR | What |
|---|---|
| tec-core-backend #493 | `MIGRATE_SKIP=1` — an emergency start without the migrate step (exact value `1` only; it says so in the log). The gateway's `/health/detailed` also checks the eight services moved out of identity (life · ai · connection · nexus · search · platform · business · trust) when their URL is set; unset = identity still serves them, not a fault |
| tec-app #322 | The Hub's per-service health (`/api/health/services`) reads the gateway's `/health/detailed` with the internal key. It used to ask `/api/<svc>/health`, a path the services do not serve, so most read `error` while running. **Runtime Verified 8 Nov: all 20 services `ok`** |
| #494 | analytics: the three indexes every event read filters on (`type`, `user_id`, `created_at`) |
| #495 | auth: a migration that builds the schema (two columns + eleven indexes, all idempotent); `remove_payment_model` made safe on a database without `payments`; auth starts through `migrate.cjs`. Production was built with `db push` and its history held two names the repository does not have — reconciled once with `MIGRATE_RECONCILE=1` (**Runtime Verified**; the variable was then removed, owner's screenshot 9 Nov) |
| #496 | notification — see below |
| #497 | commerce — see below |
| #498 | wallet — see below |
| #499 | asset — see below |
| #500 | Phase 5 — one internal-key guard in every Fastify service — see below |

## How each database was compared with its schema

Every service's production database was compared with its schema **before** any code changed. The
owner ran one read-only query per database; it returns one short hash per table and enum (columns
with type, nullability and default; indexes; foreign keys and checks; enum values in order) plus
the migration history. A local database rebuilt from the git history the same way is hashed with
the same query. **When every hash matches, the replica is production's structure exactly**, and a
migration can be tested against it before it ships. A query that returned only the differences
(184 expected items inline, 13 KB) was cut off by the phone's copy; the hash form is ~1 KB.

| Service | What production turned out to be | What shipped |
|---|---|---|
| **notification** (#496) | Exactly what its two migrations build, minus one index (`notifications_type_idx`). Its `docker-entrypoint.sh` ended every step in `\|\| true` and sent errors to `/dev/null`: a failed migration was invisible and the server started anyway. The same database (`notification-realtime`) also holds `analytics_events` and `daily_metrics`, which nothing in the repository reads there — leftovers from before analytics moved to Supabase | The schema states the database's defaults; one `CREATE INDEX IF NOT EXISTS`; start through `migrate.cjs`. **Runtime Verified 9 Nov:** Active, the index applied, a WARNING naming the two leftover tables, nothing else |
| **commerce** (#497) | Rebuilt as: `db push` of the 20 Mar schema (4200be43) → **the first migration marked applied without running** (the entrypoint ran `migrate resolve --applied <first> \|\| true` on every start) → the other nine deployed. All 19 hashes matched. Missing against the schema: `OrderStatus` value `PROCESSING` (the code had filtered statuses in JS since September because of it), **the unique index on `orders.payment_id`** — the code refuses a payment already used, but two concurrent checkouts could both pass that read — two plain indexes; `orders_pi_payment_id_key` existed as a partial index | `20260320000000_initial_tables` (the db-push tables, every statement guarded — a no-op on production; lets an empty database build); `20261109120000_align_with_schema` (the enum value, the two unique indexes — the partial one rebuilt as plain in the same transaction — two indexes; nothing destructive). Before merging the owner checked for duplicate payments: **0 rows**. **Runtime Verified 9 Nov:** Active, connected |
| **wallet** (#498) | **Exactly what its five migrations build**, all recorded — production was right. The schema was wrong: it declared eight of auth's models (users, sessions, payments, …) that do not exist in wallet's database, and differed on the five tables that do (`wallets.deleted_at` missing, `audit_logs.user_id` nullable, defaults, indexes, a unique on `transactions.tx_hash` the database never had) | The schema describes wallet's five tables only; a wallet refers to its user by `user_id`. **No migration and no database change.** The code passes `currency` and `asset_type` on every write, so the database defaults (`asset_type 'USD'`) never apply. **Runtime Verified 9 Nov:** "schema up to date", Active |
| **asset** (#499) | `db push` only, no migration record. Every table and enum equal to the schema except `AssetCategory`'s value order (DOMAIN, REAL_ESTATE, DIGITAL_ASSET, NFT, TOKEN, BADGE — the order db push added them), which Prisma does not count. Its two migration folders had never run and could not (one altered an enum nothing created; `YYYYMMDD_add_deleted_status` is not a valid name) | One baseline migration in production's enum order; start through `migrate.cjs`, which marks it applied after checking the database matches — nothing runs. **Railway's Custom Start Command is `node dist/main`, which bypasses this until it is set to `npm start`** (not yet confirmed) |

After #499, CI's `check-migrations-match-schema.sh` skips no service: every service's migrations
build its schema on an empty Postgres. Every Railway service checked has a Healthcheck Path `/health`
(owner's screenshots: payment · kyc · analytics · auth · notification · commerce · wallet · asset).

## Phase 5 — the guard (#500)

`internal-auth.ts` had drifted into nine versions. The template's guard refuses an `/internal/`
route to a caller the gateway marked as a user, even with the key the gateway adds to everything it
forwards (C15 · C17). **Six services had an older copy without that check** — commerce, asset,
analytics, kyc, notification, storage; storage serves two such routes (`internal/public-object`,
`internal/purge-objects`) with no check of its own. The gateway refuses `/internal/` paths to callers
without the key, so they were not open to users; the service-side check is the second lock.

- Every Fastify service now carries the template's file byte for byte (15 + the template); a
  service's public exceptions are passed from its `main.ts` (only identity's `/health/streams`,
  which the gateway's health check reads without the key).
- `/metrics` was public in six services and served by none — removed.
- auth and payment (Express): with `INTERNAL_SECRET` unset the guard called `next()`. Both refuse to
  boot without it, so it was unreachable; it now refuses with 403 and says why.
- CI: `scripts/check-guard-copies.sh` — every `internal-auth.ts` is the template's, every
  `owner-match.guard.ts` the same file. Not covered (different shape): realtime, wallet (a Nest guard
  per route, already closed without the secret), the gateway.
- Copies checked by CI, not `@yasser172/tec-shared`: each image is built from its own folder, so a
  shared package would need publishing and a new build context for twenty services.

## Also

- **connection-service:** one build failed with a Railway infrastructure error on #495's commit (that
  commit changed only auth); the previous version kept serving, and the next deploy was Active.
- Railway showed a banner all day: "External network blocks affecting access to Railway".

## The rotation begins

The code phase of the audit is done; the secrets rotation is the last step
(`audits/RAILWAY_SECRET_ROTATION_2026-10-22.md` §4). Step 1 (AI keys) was done in October. **Step 2,
the Pi API keys**, was handed to the owner on 9 Nov: only payment-service reads them (checked in
every repository); the Hub's key first (`PI_API_KEY`) — regenerate in the Pi Developer Portal, replace
the value on payment-service, deploy, one test payment — then every `PI_API_KEY_<APP>` in one deploy.
Not done when this was written. The A2U seed is not put back (owner, 30 Oct — C-02 row 29).

## Left open (in this order)

1. **asset:** set the Custom Start Command to `npm start`; the log should read "marked applied, none run".
2. **The rotation**, step 2 → 7 of the runbook, one step at a time. Then asymmetric JWT and a key per caller.
3. Healthcheck Path on the eight template services (ai · business · connection · life · nexus · platform ·
   search · trust): running and baselined, the setting itself not seen on a screenshot.
4. Decisions, none urgent: `analytics_events` / `daily_metrics` in notification's database (count
   their rows read-only first); wallet's unused `accounts` table; a unique `transactions.tx_hash`;
   drop `backup_20261108` after 2026-12-08.
5. Lockfiles for `shared` and `tec-asset-service`; NestJS 10 → 11.
