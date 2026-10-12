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

Pro would replace §4 with Railway's own daily backups. That remains an option the owner may
take at any time; it is not needed for §2–§3.

## 5. Order

1. §2 report → choose `tec_life`'s server (owner).
2. §4 backups first, **before** any data is copied into a new database: a migration of data
   with no backup to fall back on is the riskiest moment there is.
3. §3 on the chosen server, with the proof.
4. `tec-life-service` from `tec-service-template`, deployed against `tec_life`. Data copy and
   gateway switch remain separate steps (`APP_EXPANSION_ARCHITECTURE_2026-10-11.md` §1.4).
