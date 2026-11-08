# Session 60 — the backend audit fixed in phases; migrations run on deploy; payment-service down most of 8 Nov (7–8 Nov 2026)

> Truth State: **[Current State]**. Everything below is merged to `main` unless it says otherwise.
> Verification: **[Code Verified]** — tests, tsc and lint on every PR, and each migration scenario run
> against a real Postgres 16. **[Runtime Verified]** where it says so: Railway deploy logs and read-only
> SQL, from the owner's screenshots.
> Same branch as sessions 57–59 (`claude/tec-knowledge-base-review-6wzngc`).

## Development resumed for the backend (owner, 2026-11-07)

The owner asked for an engineering audit of `tec-core-backend` (score **6.5/10**: C1 secrets not
rotated · H1 Node 20 · H2 dependency vulnerabilities · H3 shared symmetric secrets · M1 rate limit ·
M2 uploads · M3 coverage · M4 migrations · M5 duplicated middleware · L1–L7), then: **fix everything,
in phases; the secrets rotation is the last step.**

## What happened

### Merged

| PR | What |
|---|---|
| tec-core-backend #486 | Security: owner taken from the token only (storage, commerce products — a CI check now blocks `{ owner, ...body }`), real upload checks (`HeadObject` size and type, folder allowlist), rate limit keyed on the verified user, no dev-secret fallbacks, JWT `HS256` only |
| #487 | Node 22 everywhere, bcrypt 6, targeted dependency updates; **per-user rate-limit budgets** (see Corrections) |
| #488 | 168 switched-off tests run again, coverage counts all of `src`, a floor per service; asset-service `strict` |
| #489 | One guarded migrate step at start (`scripts/migrate.cjs`, the template's, CI checks every copy): baselines a `db push` database only when it matches the schema, refuses a pending DROP/TRUNCATE/DELETE/type change unless `MIGRATE_ALLOW_DESTRUCTIVE=<name>`, `MIGRATE_RECONCILE=1` by hand. payment · kyc · analytics now apply their schema on deploy. CI builds every service's migrations on an empty Postgres and fails unless they equal the schema |
| #490 | `npx` printed "npm notice New major version…" into the captured diff and the script read it as a schema difference: Prisma now runs under `node` directly, the diff is read from stdout only |
| #491 | The schema comparison reads through `DIRECT_URL`; through Supabase's transaction pooler it never answered |
| #492 | analytics: schema and baseline rewritten from production's `information_schema` (hand-made tables: uuid ids, nullable counters, timestamps without time zone, no secondary indexes) |
| Tec-Assets #82 | **Assets Pro** (`assets_pro_monthly`, 5π): the quota is lifted by Hub Pro or Assets Pro |

### Each service's database, recorded (Runtime Verified, deploy logs 8 Nov)

- **kyc** — baselined, `schema up to date`.
- **analytics** — `DIRECT_URL` moved to Supabase's **session pooler** (`aws-1-eu-west-1.pooler.supabase.com:5432`;
  the direct host is IPv6-only and Railway cannot reach it), then baselined after #492.
- **payment** — baselined after the manual step below (5 migrations marked applied, none run).
- ai · business · connection · life · nexus · platform · search · trust — `schema up to date`, running.

## Incident — payment-service down for most of 8 Nov

- **What:** payment-service did not serve. Its start step refused a database that did not match the
  schema, and Railway restarted it every ~2 s.
- **Why it was an outage and not a refused deploy:** payment-service had **no Healthcheck Path**.
  Railway marked each new deployment Active at once and removed the one that worked. kyc and
  analytics had a healthcheck and kept their old version.
- **Window:** most likely from the first deploy after #489 (~07:26 GMT+2) to **18:21:57 GMT+2**.
  The start is inferred: #489's own deploy hit the npm-notice bug fixed in #490.
- **Impact (read-only SQL):** the last payment row is from 7 Nov 18:00 UTC; none in the window. Pi
  moves nothing without approve + complete, so no money moved. An attempt in the window would have
  failed at create and left nothing.
- **Root cause in the data:** `payments.amount` was **`double precision`**. Migration
  `20260419000001_payment_decimal` (VM-NEW-010, DECIMAL(20,8)) had never run in production, because
  migrations never ran on deploy before #489.

### The manual step (audit trail)

Run by the owner in payment-db → Query, one step at a time, each checked before the next:

1. Check: 2070 rows · max |amount| 580 · `would_round` 0.
2. Backup: `create schema backup_20261108; create table backup_20261108.payments_amount as select id, amount from payments;`
   → 2070 rows. (Railway's free plan cannot create backups; the separate schema keeps it out of
   Prisma's comparison.)
3. Exactly the repository migration's SQL: `ALTER TABLE "payments" ALTER COLUMN "amount" TYPE DECIMAL(20, 8) USING "amount"::DECIMAL(20, 8);`
4. Verify: 0 rows differ from the backup.

The restarting service then found a matching database, baselined it and started. A Healthcheck Path
`/health` was added, and the next deploy (18:26) started cleanly.

## Corrections

- **#486 made Assets show nothing** (429): the rate limit was keyed per user but kept the per-address
  budget (100 per 15 min). #487 gave users their own budget (3000 / 120 / 60).
- **I advised merging #489 without checking that payment-service had a healthcheck.** The script
  refusing to start is safe only behind a healthcheck. That turned a refused deploy into an outage.
- The Hub's `/api/health/services` has reported most services as `error` for a long time. It asks
  `/api/<svc>/health`, which the gateway rewrites to `/<svc>/health`, and the services serve `/health`.
  Do not read an outage from it.

## Left open (in this order)

1. **Healthcheck Path `/health` on every service that runs `migrate.cjs`.** Confirmed: payment · kyc ·
   analytics. **Not confirmed:** ai · business · connection · life · nexus · platform · search · trust.
2. **`MIGRATE_SKIP=1`** (an emergency start without the migrate step), plus the Hub health page fixed to
   read the gateway's `/health/detailed`.
3. **analytics:** a migration for the four secondary indexes. It could not ship with the baseline.
4. **Drop `backup_20261108` after 2026-12-08** once nothing has disagreed.
5. **Other services' migrations** (CI skips them with a warning):
   - auth: its recorded history differs from the repository, and `remove_payment_model` would DROP
     `payments`. Check first, then `MIGRATE_RECONCILE=1`.
   - asset: an invalid folder `YYYYMMDD_add_deleted_status`.
   - commerce · asset: migrations fail on an empty database.
   - notification · wallet: drift.
6. Lockfiles for `shared` and `tec-asset-service`; NestJS 10 → 11.
7. **Phase 5:** one shared security middleware (`internal-auth.ts` in 20 services, 9 variants).
8. **Last:** the rotation (`audits/RAILWAY_SECRET_ROTATION_2026-10-22.md`), Pi keys first, then
   asymmetric JWT and a key per caller.
