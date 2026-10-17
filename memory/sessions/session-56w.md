# Session 56w — identity taken apart: eight services, nine private databases, and a session that lived ten minutes (11–17 Oct 2026)

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** for every cutover (the
> owner opened each app after its switch, and read counts in the Railway console), for the token
> lifetime fix (the boot log), the proxy removals, the table drop and the gateway warning;
> **[Code Verified]** for every PR — tests, tsc, lint. Same branch as 56s–56v
> (`claude/tec-knowledge-base-review-6wzngc`, KB PR #215). The plan and every row of evidence are in
> `audits/APP_EXPANSION_ARCHITECTURE_2026-10-11.md` and
> `audits/DATABASE_PLACEMENT_AND_BACKUP_2026-10-12.md`; this file is the story, not a copy.

## 1. Why

`tec-identity-service` carried 24 controllers for ~17 apps (C-02 row 17, the single points of
failure audit): every Life change redeployed sign-in, a Nexus dispatcher loop ran inside the event
loop that answers every request, and one database held every app's tables. The decision
(`APP_EXPANSION_ARCHITECTURE_2026-10-11.md`): **a service of its own where a trigger exists
(C-132 §5), one host per domain otherwise** — not one service per app, which one person could not
run.

## 2. Backups first (12 Oct)

No data moved before a backup could be restored: `tec-backup-job` (Railway cron, 01:23 UTC) dumps
every database on every server, encrypted, to Cloudflare R2; a manual GitHub Actions check restored
all 18 databases with every table's row count equal (`runtime-evidence/ev-2026-10-12-025.yaml`,
KB #214).

## 3. The moves (12 → 16 Oct)

The same five steps each time: code (same paths, so no app changed) → a logical database with its
own role (`REVOKE … FROM PUBLIC`, proof read back) → deploy → a counted copy from identity
(`scripts/copy-from-identity.mjs`, read-only snapshot on the source, exits 1 on any difference) →
cutover (one gateway variable; the stream consumer flipped off on identity and on in the new
service in the same step) → the owner opens the app.

| Service | Port | Took | PR |
|---|---|---|---|
| `tec-life-service` | 5012 | Life | #414–#417 |
| `tec-ai-service` | 5013 | TEC AI conversations, then reasoning | #418–#420 |
| `tec-connection-service` | 5014 | Connection (18 tables) | #421 |
| `tec-nexus-service` | 5015 | Nexus + Intent | #422 |
| `tec-search-service` | 5016 | Explorer | #423 |
| `tec-platform-service` | 5017 | System · DX · Feedback · Pioneer + campaign | #424 · #426 · #428 |
| `tec-business-service` | 5018 | NBF · Titan · NX · Epic | #425 |
| `tec-trust-service` | 5019 | Zone · Legend · Elite · VIP | #431 |

What bit, once each:

- **A Railway reference to a wrong service name is an empty string, silently** — the trust copy
  read nothing until `${{identity-service.DATABASE_URL}}`.
- **Boot seeds collide with the copy**: Zone's registry and Elite's samples are written on first
  boot under new ids, so the first copy needed `--refresh` (identity wins), run once before the
  switch and never after.
- **A password shown in a screenshot is a rotation** (db-identity's, 15 Oct): passwords are now
  generated on the server and never shown.

## 4. C17, again (15–16 Oct)

The gateway adds `x-internal-key` to every request it proxies, so "has the key" never proves a
service called. Found on the way: Feedback triage readable by any signed-in user (#426), and
`pioneer/arrived` creditable by a person (#427). Then a sweep of every key-only route (#432):
commerce's subscription `grant` (free PRO / ENTERPRISE) · `expire-stale` · `renewable` · `stats`,
product `admin/deactivate` (reachable with **no session** — `/api/commerce/products` is a public
prefix), order `reserve` / `release`, asset marketplace lock/unlock, Life's context door, and
Connection's report queue and story purge. Each now also needs the gateway's `service` mark
(`isServiceCaller`). The owner read `grant`'s history: no grant nobody can account for.
`audits/SECURITY_C17_KEY_ONLY_ROUTES_2026-10-16.md`.

## 5. The incident — refreshed sessions lived ten minutes (16 Oct)

Assets and Connection emptied until re-entry. Root cause: refresh read `JWT_EXPIRES_IN=604800`
through a parser that took a bare number as milliseconds → 604 s. Fixed by one shared
`parseExpiry` (#429); the boot log now states both lifetimes from real signed tokens and logs an
ERROR on a short one (#430, read back: `access 604800s, refresh 604800s`). A diagnostic that names
`tokenProblem` and `expiredMinutesAgo` went into the template and every app, and a "session
expired — reopen through the Hub" notice into Assets and Connection — both as open PRs.
`audits/INCIDENT_TEN_MINUTE_SESSIONS_2026-10-16.md`.

## 6. Closing the doors (16 Oct)

- **Public TCP proxies removed from all nine Postgres servers** — one at a time, the owner opening
  the apps that use each server after it restarted. Every database is now private-network only.
- **Gateway `MaxListenersExceededWarning`** — not a leak: http-proxy-middleware adds one `close`
  listener per proxy route, and there are more than ten routes. The limit is now the route count +
  10 (#434); the warning is gone from the deploy log.

## 7. The contract (16–17 Oct)

- **Code** (#433): the eighteen moved modules and their consumers removed from identity. A gateway
  carve-out variable is now the routing itself — deleting one answers 404, not identity.
- **Tables** (#435): the 62 moved tables and 40 enums dropped from `db-identity`, in the order:
  backup run by hand (`failures: []`) → restore check green → a read-only check of every table's
  rows and newest write (every count equal to its cutover's, nothing written after) → the SQL, one
  transaction, no CASCADE → the schema deploy. Tested locally first; the schema deploy alone would
  have refused (`db push` will not drop a table holding rows without the flag `migrate.cjs`
  withholds). Identity keeps 11 tables: the person, Alert, Insure.
- **Demo purge** (#436): moved to business and trust with the tables. Both dry runs in production
  found nothing to remove.

## 8. Left open

- **Account deletion must reach Life · TEC AI · Connection** — the person's data now lives in
  several services; one `account.deleted` event the owning services act on (C-106 §5). Not built.
- The incident's preventive PRs (diagnostic in 23 apps + the template; the session-expired notice)
  are open, and the synthetic sign-in-and-refresh check is not built.
- C-20 (the port authority) does not yet list ports 5012–5019.
