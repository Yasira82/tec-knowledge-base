# Database placement and backups — Railway Hobby (2026-10-12)

**Truth State:** [Planned State] · **Governance State:** [Draft] — decided by the owner
(§1); the runbooks below are drafts, and nothing in production has changed.
**Verification:** [Documentation Verified] — the Railway limits come from Railway's own
agent and docs, read on 2026-10-12.

Companion to `audits/APP_EXPANSION_ARCHITECTURE_2026-10-11.md` (§1.4 and step S4).

---

## 0. What was found

| Fact | Source |
|---|---|
| The project is on **Hobby**: **10 volumes per project**, and all 10 are in use (9 Postgres + Redis). A new database needs a volume, so Railway refuses it. Pro raises the cap to 20. | Railway agent + docs, 2026-10-12 |
| **None of the 9 Postgres volumes has a backup.** Hobby allows 0 volume backups; backups are a Pro feature (daily, kept 6 days). | Railway notice (24 days old) + plan limits |
| `payment-db` was offline for about 30 minutes on 2026-10-03 after a hardware failure. The data survived. With no backup, the next failure might not leave it. | Railway notification |
| Services: 22 of 50. The service cap is not the limit; the volume cap is. | Railway agent |

## 1. Decided (owner, 2026-10-12)

1. **Shared infrastructure, separate data.** New services use **logical databases** inside an
   existing PostgreSQL server, not a new server each. Every service still owns its database
   (or its schema), its credentials and its migrations, and never reads another service's
   data directly (C-47: one owner per entity, no shared database logic).
2. **`tec_life` is NOT placed on `db-identity` by default.** Two databases on one server
   separate permissions, but they share that server's failures and its administrator. The
   server is chosen after a read-only review of resources and trust boundaries (§2).
3. **No change to the payment, identity and KYC databases**, and no new database on
   `payment-db`, `wallet-db`, `auth-db` or `db-kyc` (money and identity).
4. **No upgrade to Pro just to get more volumes.**
5. **Backups that can be restored are a priority, separately from all of this.** While on
   Hobby: an external `pg_dump` of every database **with a real restore test**. An export
   that succeeded is not a backup until a restore from it has been seen to work (§4).
6. **`tec-life-service` does not touch production** until §2 has picked its server.
7. **Where the next services' databases go (owner, 2026-10-13)** — three servers only, never the
   money / identity / orders ones (decision 3 extended to `db-commerce` and `db-identity`):

   | Server | Logical databases (existing + planned) |
   |---|---|
   | `notification-realtime` | notifications · `tec_life` · `tec_ai` · `tec_platform` |
   | `db-storage` | files · `tec_connection` · `tec_trust` |
   | `db-asset` | assets · `tec_search` · `tec_business` · `tec_nexus` |

   **Considered and not taken (2026-10-13):** moving KYC's database onto `db-identity` to free
   the `db-kyc` volume. Not needed while the three servers above have room (each is under 5 %
   of 5 GB), it puts KYC data beside identity's (the shared-failure concern of decision 2), and
   it reverses decision 3. Kept as the option to revisit **if** the volumes run out.

## 2. Step 1: a read-only resource report (Railway agent)

To paste into Railway's agent. It asks for reading only:

> Read-only. Do not create, delete, restart, redeploy or modify anything.
> For each PostgreSQL service in Tec-Ecosystem / production (payment-db, wallet-db, auth-db,
> db-identity, db-kyc, db-commerce, db-asset, db-storage, notification-realtime):
> 1. Volume: size used / allocated.
> 2. Database size of every database on that server (`pg_database_size`), and the number of databases.
> 3. RAM and CPU over the last 7 days: average and peak.
> 4. Connections: `max_connections`, current and peak connections.
> 5. PostgreSQL major version.
> 6. Which services reference it (variables that point at it).
> 7. Which roles exist on it (`pg_roles`: name, superuser, can login), and which users are
>    connected now (`pg_stat_activity.usename`).
> Present one table, one row per database service.

### How the server is chosen

| Rule | Why |
|---|---|
| Not `payment-db` · `wallet-db` · `auth-db` · `db-kyc` · `db-commerce` | Money, identity and orders: a failure or a privilege mistake there costs the most (decision 3) |
| Not `db-identity` unless §2 shows it is the only server with room | Decision 2: Life already shares identity's failures today; moving it should lower that, not keep it |
| The lowest RAM/CPU peak and enough free volume for 12 months of growth | A logical database adds load to a server it does not own |
| Trust: the server's other data is no more sensitive than Life's | Life holds goals, budget and intent (C-106) |

The candidates left by these rules are `db-asset`, `db-storage` and `notification-realtime`.
The report decides between them.

### The report (Railway agent, 2026-10-12 — metrics window ≈ Oct 4–12)

| Server | PG | Volume used / allocated | CPU peak (vCPU) | RAM (approx.) |
|---|---|---|---|---|
| payment-db | 17 (on disk) | 0.119 / **0.5 GB** (24 %) | 0.0003 | 0.049–0.053 GB |
| wallet-db | 17 (image tag) | 0.117 / **0.5 GB** (23 %) | < 0.0004 | 0.04–0.05 GB |
| auth-db | 17 (image tag) | 0.116 / **0.5 GB** (23 %) | < 0.0004 | 0.04–0.08 GB |
| db-identity | 18 (image tag) | 0.230 / 5 GB (4.6 %) | < 0.0004 | 0.04–0.08 GB |
| db-kyc | 18 | 0.216 / 5 GB (4.3 %) | < 0.0004 | 0.04–0.08 GB |
| db-commerce | 18 | 0.220 / 5 GB (4.4 %) | < 0.0004 | 0.04–0.08 GB |
| db-asset | 18 | 0.217 / 5 GB (4.3 %) | < 0.0004 | 0.04–0.08 GB |
| db-storage | 18 | 0.215 / 5 GB (4.3 %) | < 0.0004 | 0.04–0.08 GB |
| notification-realtime | 18 | 0.221 / 5 GB (4.4 %) | < 0.0004 | 0.04–0.08 GB |

Not retrieved (the agent has no SQL access): database sizes, roles, connected users and
`max_connections` except payment-db's (100). The service ↔ database mapping is inferred
from names, not verified.

**What it means**

- **Load decides nothing.** Every server idles (< 0.0004 vCPU, < 0.1 GB RAM). The three
  candidates are identical in resources, so the choice is made on trust (below).
- **The trust question is the superuser, not the neighbour's data.** Railway's default
  `DATABASE_URL` connects as `postgres`, the server's superuser. Whatever service owns the
  host server holds a credential that can read every database on it, `tec_life` included —
  role isolation (§3) protects against `tec_life_svc`, not against that service. So `tec_life`
  belongs on the server whose owning service is the least exposed and changes least. Moving
  each existing service off the superuser onto its own role is the follow-up that closes this
  (not part of this change).
- **Two findings to keep, not to act on now:** payment · wallet · auth have **0.5 GB**
  volumes (about 24 % used), the other six 5 GB — watch their growth. payment-db's data
  directory holds `.railway-major-upgrade.lock` (2026-08-10), left by the PG 17 upgrade;
  ask Railway what it means before any change to that server.

**Recommendation (for the owner to decide): `notification-realtime`.** Its owning service has
the smallest surface of the three, read from `tec-core-backend` main on 2026-10-12:

| Owning service | Commits, last 60 days | HTTP routes | Handles uploads | Stream consumers |
|---|---|---|---|---|
| tec-notification-service → `notification-realtime` | **6** | **9** | **no** | 2 |
| tec-storage-service → `db-storage` | 8 | 11 | yes | 0 |
| tec-asset-service → `db-asset` | 16 | 22 | yes | 6 |

Fewer changes and no file parsing mean fewer chances for the superuser credential on that
server to leak. `db-storage` is the second choice. Before §3, read on the chosen server only
(read-only): `SELECT usename, count(*) FROM pg_stat_activity GROUP BY 1;` ·
`SELECT rolname, rolsuper, rolcanlogin FROM pg_roles WHERE rolname NOT LIKE 'pg\_%';` ·
`SELECT datname, pg_size_pretty(pg_database_size(datname)) FROM pg_database;` ·
`SHOW max_connections;`.

**Read on `notification-realtime` (owner, Railway Data tab, 2026-10-12):**

| Fact | Value |
|---|---|
| Roles | one: `postgres` (superuser, login) — every connection uses it |
| Connections now | 3 × `postgres`, 7 system; `max_connections` 500 |
| Databases | `railway` 9.0 MB · `postgres` 7.5 MB · templates |
| Tables in `railway` | `notifications` (960 rows, last write 2026-10-10) · `notification_preferences` · `device_tokens` · `_prisma_migrations` (2 migrations — the same 2 the repo holds) · **`analytics_events` and `daily_metrics`, both empty** |
| analytics-service `DATABASE_URL` | points at **Supabase** (owner checked the variable) |

The two analytics tables are **empty leftovers**, not a second live owner: tec-analytics-service
writes to Supabase. Nothing is removed now; dropping them is a later, separate cleanup. The
recommendation stands: **`notification-realtime`**, with only tec-notification-service holding
its superuser credential.

## 3. Step 2: creating a logical database with full isolation (runbook draft)

`CREATE ROLE` + `CREATE DATABASE` is **not** isolation by itself. In PostgreSQL every role
can connect to every database through the `PUBLIC` grant, and on older servers can create
objects in `public`. The steps below close both, and the last block proves it.

Run as the server's administrator (`postgres`) on the server chosen in §2. **The password is
generated by the owner, stored only in Railway Variables, and never written in code, in the
repository, or in a message.** It goes into SQL through a client variable, not typed into the
statement:

```sql
-- psql:  \set pw `cat /dev/stdin`   (paste, then Ctrl-D)  — never in shell history
CREATE ROLE tec_life_svc LOGIN PASSWORD :'pw'
  NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS
  CONNECTION LIMIT 20;
CREATE DATABASE tec_life OWNER tec_life_svc;
REVOKE ALL ON DATABASE tec_life FROM PUBLIC;

\connect tec_life
REVOKE ALL ON SCHEMA public FROM PUBLIC;
ALTER SCHEMA public OWNER TO tec_life_svc;
```

**Keeping `tec_life_svc` out of the server's other databases.** This is the step that changes
an existing database, so it comes with a check first:

```sql
-- 1. Who connects to each existing database today? Every name listed must keep access.
SELECT datname, usename, count(*) FROM pg_stat_activity GROUP BY 1, 2;
-- 2. Only if every existing connection is the administrator (postgres), for each OTHER database D:
REVOKE CONNECT ON DATABASE "D" FROM PUBLIC;
GRANT  CONNECT ON DATABASE "D" TO postgres;   -- explicit, although a superuser needs no grant
```

If step 1 shows any role other than `postgres`, stop and review: that role relied on `PUBLIC`
and needs its own `GRANT CONNECT` first.

**Proof (all must hold before the service is pointed at it):**

```sql
SELECT rolsuper, rolcreatedb, rolcreaterole, rolbypassrls FROM pg_roles WHERE rolname = 'tec_life_svc';  -- all false
SELECT datname, has_database_privilege('tec_life_svc', datname, 'CONNECT') AS can_connect
FROM pg_database WHERE NOT datistemplate;     -- true ONLY for tec_life
```

Then, from outside: connecting as `tec_life_svc` to any other database on the server must be
refused (`permission denied for database`).

The service's `DATABASE_URL` (a Railway Variable, referencing the server's private host) is
`postgresql://tec_life_svc:<password>@<server>.railway.internal:5432/tec_life`.
`tec-service-template`'s `npm start` applies its migrations there. The role owns the database,
so it needs nothing more.

## 4. Backups while on Hobby (runbook draft)

| | |
|---|---|
| What | `pg_dump -Fc` of every database on all 9 servers (each logical database too, once they exist) |
| Where it runs | A **Railway cron service** in the same project: it reaches the databases over the private network (no public database URL needed), and a service with no volume does not count against the 10-volume cap |
| Where the dumps go | **Outside Railway**: an S3-compatible bucket the owner opens (e.g. Cloudflare R2 or Backblaze B2). A backup on the platform that failed is not a backup |
| Encryption | Encrypted before upload with a key the owner keeps (`age`); the bucket never sees plain data. The dumps hold payment records and personal data |
| Schedule and retention | Nightly; keep 14 daily + 8 weekly |
| `pg_dump` version | The client's major version must be ≥ each server's (17 and 18 today) |
| Alert | A failed or missing dump files a TEC Alert / notification. A backup job that fails silently is the same as no backup job (C-96) |
| **Restore test** | **Monthly, and before the setup is called done:** restore the latest dump of each database into a throwaway Postgres, compare row counts table by table with production (read-only queries), record the result in `runtime-evidence/`. Until the first restore passes, the databases count as **not backed up** |
| Credentials | A read-only backup role per server (`pg_read_all_data`), its password in Railway Variables only |

**Live and restore-verified (2026-10-12).** `tec-core-backend/tec-backup-job` (PRs #412, #413)
runs as the Railway cron service `backup-job` (01:23 UTC nightly, no volume). Storage: Cloudflare R2
bucket `tec-db-backups`, with two tokens scoped to that bucket only (read-write for Railway,
read-only for GitHub). Encryption: AES-256-GCM with an scrypt key from the owner's passphrase
(the owner chose a passphrase over an age key pair, which needed a terminal on the phone).
First run: 18 databases, 1.4 MB, 0 failures. **First restore check (GitHub Actions, manual):
all 18 restored into a throwaway Postgres 18, every table's row count equal** —
`runtime-evidence/ev-2026-10-12-025.yaml`. From here the databases count as backed up.
The check repeats monthly; a failed night or check exits non-zero. Later hardening: a
`pg_read_all_data` role per server instead of the superuser URL; an alert webhook.

Pro would replace §4 with Railway's own daily backups. That remains an option the owner may
take at any time; it is not needed for §2–§3.

## 5. Order

1. §2 report → choose `tec_life`'s server (owner). **Done: `notification-realtime` (owner, 2026-10-12).**
2. §4 backups first, **before** any data is copied into a new database — **done 2026-10-12**: a migration of data
   with no backup to fall back on is the riskiest moment there is.
3. §3 on the chosen server, with the proof. **Done 2026-10-12 (owner, Railway console + Data tab):** `tec_life`
   owned by `tec_life_svc` (no superuser / createdb / createrole / replication / bypassrls,
   connection limit 20, password generated in the container and kept by the owner only);
   `REVOKE CONNECT … FROM PUBLIC` on `railway` and `postgres`. Proof read back:
   `tec_life_svc` can connect to `tec_life` only (`railway` false, `postgres` false), and
   notification-service still holds 4 connections to `railway`. The nightly backup picks
   `tec_life` up with no change (it dumps every database on each server).
4. `tec-life-service` from `tec-service-template`, deployed against `tec_life`. **Done 2026-10-12**
   (tec-core-backend #414 · #415 · #416). Private only, port 5012, Healthcheck Path `/ready`;
   `DATABASE_URL` uses `${{notification-realtime.RAILWAY_PRIVATE_DOMAIN}}` — the server's private
   host is `postgres-1e8b.railway.internal`, not its display name (the first deploy failed P1001
   on the hand-written host). The init migration ran as `tec_life_svc`.
5. **Cutover, 2026-10-12, owner + console:** copy (`--apply`) → 73 rows, every count equal
   (goals 5 · progress 2 · consents 8 · skills 1 · preferences 2 · budgets 3 · Life audit 52) →
   gateway `LIFE_SERVICE_URL` set → copy again: 0 new rows. Proof from the app: a new goal and a
   progress entry landed in `tec_life` (goals 6 / progress 3 there, still 5 / 2 in identity), old
   goals shown unchanged, Arabic and π amounts intact. Weekly check-in moved:
   `LIFE_CHECKIN_ENABLED=false` on identity, `true` on Life. The temporary `SOURCE_DATABASE_URL`
   was removed from Life once the copy was done.
   **Rollback:** delete `LIFE_SERVICE_URL` on the gateway (and swap the two check-in flags) —
   identity's tables are untouched, but writes made since the cutover live only in `tec_life`.
6. **Contract, part 1 — done 2026-10-12 (tec-core-backend #417):** the Life module (routes,
   sweeper, review, intent store) removed from identity; every caller reaches Life through the
   gateway. **Still open:** part 2 — drop Life's tables from identity (kept, marked frozen in
   its `schema.prisma`: `migrate.cjs` refuses a non-additive diff, and they are the pre-cutover
   copy) — a deliberate, separate step. Rotate identity's database password:
   it was shown in a screenshot during step 5 (private network only; do it with the owner, step by
   step, so identity does not lose its connection).

### `tec_ai` — the second logical database (2026-10-12 → 13)

Same server (`notification-realtime`, owner's choice), same recipe as `tec_life`: role
`tec_ai_svc` (no superuser / createdb), `REVOKE ALL … FROM PUBLIC` on `tec_ai`. Read back:
`tec_ai_svc` connects to `tec_ai` only; `tec_life_svc` cannot reach `tec_ai`. Lessons from the
deploy, both about the connection string and neither about the code:
- **P1000** (wrong password) — the password was rotated with `ALTER ROLE` and a 32-character
  hex value, short enough to copy on a phone without a line break.
- **P1013 `empty host`** — a `${{…RAILWAY_PRIVATE_DOMAIN}}` reference broken while editing in
  Railway's variable editor (its autocomplete rewrites `${{`). Fixed by writing the private host
  literally: `postgres-1e8b.railway.internal`.


### `tec_connection` — the third logical database (2026-10-13)

On `db-storage` (decision 7), same recipe: role `tec_connection_svc` (no superuser / createdb,
connection limit 20, password generated in the container), `tec_connection` owned by it,
`REVOKE ALL … FROM PUBLIC` on it. Before closing the server's other databases the owner read
who connects: only `postgres` (storage-service), 2 connections — so
`REVOKE CONNECT ON DATABASE railway / postgres FROM PUBLIC` was safe. Proof read back:
`tec_connection_svc` connects to `tec_connection` only (`railway` false, `postgres` false), and
storage-service still holds its 2 connections. The private host was written literally
(`postgres-1wvb.railway.internal`) from the start, per the P1013 lesson above.

### `tec_nexus` — the fourth logical database (2026-10-13)

On `db-asset` (decision 7), same recipe in one console command: role `tec_nexus_svc`,
`tec_nexus` owned by it, `REVOKE ALL … FROM PUBLIC` on it, and `REVOKE CONNECT` on `railway` /
`postgres` after the owner read that only `postgres` (asset-service, 2 connections) connects.
Proof read back: `tec_nexus_svc` connects to `tec_nexus` only, not superuser; asset-service
still holds its 2 connections. Private host written literally: `postgres-hwjm.railway.internal`.
- **Password exposed, rotated the same hour.** A screenshot of the service's Variables showed
  `DATABASE_URL` with the eye open. Rotated with `ALTER ROLE tec_nexus_svc PASSWORD …` (32 hex,
  generated in the container) before anything called the service; the next copy dry run
  connected with the new value.
- **Service name collision.** The first create attempt left a second service named
  `tec-nexus-service`, so the working one kept the repo's name. After removing the duplicate and
  renaming, Railway kept the original private host (`tec-core-backend-2db203ab.railway.internal`)
  and it cannot be edited — the gateway's `NEXUS_SERVICE_URL` uses it. Harmless; just not the name.

### `db-identity` superuser password rotated (2026-10-15)

The password shown in a screenshot on 2026-10-12 (§5 step 6) was `postgres`'s — the only role
that connects to `db-identity` (owner read `pg_stat_activity`: 5 + 1 connections, all `postgres`)
— and the server **has a public TCP proxy** (`autorack.proxy.rlwy.net`), so the exposure was
reachable from the internet, not only the private network. Rotated, owner + console, in this order:
1. `ALTER ROLE postgres PASSWORD …` (32 hex, generated in the container; open connections survive).
2. identity-service `DATABASE_URL` — written literally, not a reference — edited, deployed:
   `[PrismaService] Connected to database`, every consumer started.
3. backup-job `BACKUP_DB_DB_IDENTITY` (also literal) edited. **The first manual run still failed**
   (`INCOMPLETE … server: db-identity … password authentication failed`) — the variable had been
   saved but the cron service not redeployed. After the redeploy: `backup: complete … databases: 22
   … failures: []`. The job reported its own failure loudly, as §4 requires.
4. `db-identity`'s own `POSTGRES_PASSWORD` updated (the Data tab); the server restarted (~30 s).

Verified: Hub login works.

**Still open (not done):**
- Every Postgres server here has a public TCP proxy, and each one hands out its superuser. Nothing
  found so far needs them (services and the backup job use `*.railway.internal`). Removing them
  is the next hardening step — one server at a time, after checking that nothing uses its public URL.
- `DATABASE_URL` on identity-service and the backup job's entries are literal strings. As
  references (`${{db-identity.DATABASE_URL}}`), the next rotation would be one change, not three.

### `tec_search` — the fifth logical database (2026-10-15)

On `db-asset` beside `tec_nexus` (decision 7): role `tec_search_svc`, `tec_search` owned by it,
`REVOKE ALL … FROM PUBLIC`. Proof read back: `tec_search_svc` connects to `tec_search` only
(`tec_nexus`, `railway`, `postgres` false), not superuser, and `tec_nexus_svc` cannot reach
`tec_search`. The service was renamed **before** its first deploy, so its private host is the
right one this time (`tec-search-service.railway.internal`) — the Nexus lesson applied.

### `tec_platform` — the sixth logical database (2026-10-15)

On `notification-realtime` beside `tec_life` and `tec_ai` (decision 7): role `tec_platform_svc`,
`tec_platform` owned by it, `REVOKE ALL … FROM PUBLIC`. Proof read back: `tec_platform_svc`
connects to `tec_platform` only (`tec_life`, `tec_ai`, `railway`, `postgres` false), not
superuser; `tec_ai_svc` cannot reach `tec_platform`. Service renamed before its first deploy —
private host `tec-platform-service.railway.internal`.

### `tec_business` — the seventh logical database (2026-10-15)

On `db-asset` beside `tec_nexus` and `tec_search` (decision 7), which completes that server's
planned set: role `tec_business_svc`, `tec_business` owned by it, `REVOKE ALL … FROM PUBLIC`.
Proof read back: `tec_business_svc` connects to `tec_business` only (`tec_nexus`, `tec_search`,
`railway`, `postgres` false), not superuser; the other two roles cannot reach `tec_business`.
Service renamed before its first deploy — private host `tec-business-service.railway.internal`.
The first deploy failed only at the healthcheck: its path had been entered as the root
directory (`/tec-business-service`), which the internal-key guard answers with 403. The app had
started; setting the path to `/ready` fixed it. Every new service's healthcheck is `/ready`.
