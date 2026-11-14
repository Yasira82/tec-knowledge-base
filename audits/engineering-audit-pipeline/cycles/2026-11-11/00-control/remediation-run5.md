# Remediation after Run 5 — cycle 2026-11-11 (13 Nov 2026)

> Truth State: **[Planned State]** — committed locally, not pushed (GitHub Actions refused for
> the account; no backend PR before 1 Dec). Verification: [Code Verified] — each new test shown
> failing on the old code (or a deliberately broken copy) before it was trusted.

| Finding | Fix | Proof | Where |
|---|---|---|---|
| **0040 (HIGH)** | The GitHub restore check **fails** when unconfigured (it passed with a notice). `RESTORE_LOCAL_POSTGRES=1`: the same check starts a throwaway Postgres in its own container (initdb in a temp dir, 127.0.0.1, stopped and deleted whatever happens) — so it can run as a **Railway cron** next to the backup, independent of GitHub. Image: the postgresql-18 server, `PG_BIN` set | run here as a non-root user on Postgres 16: the server starts, is reachable, is stopped and deleted, also when the check throws; **end to end**: backup → encrypt → restore into the throwaway server → exact counts. 26/26. The image itself was not built here (no Docker daemon) | `Tec-core-backend 719dbbb7` |
| 0039 | `railway.toml` in all 19 services: `healthcheckPath = "/health"`, 120 s — only that; the start command stays in the dashboard until read off it, since the file overrides it. `scripts/check-railway-config.sh` in CI's policy job | every `/health` checked outside any global prefix; the check shown failing with one file removed | `4dda30dd` |
| 0041 | Explorer and NX search read **one page** (limit ≤ 100, offset, both clamped; `hasMore`; `id` as last sort key). search-service migration: `pg_trgm` + a GIN trigram index on `search_text`, replacing the btree | paging tests red on the old code; on a fresh Postgres 16 the migrations build exactly the schema (CI's own script) and `EXPLAIN` shows a Bitmap Index Scan for `LIKE '%cafe%'`; `DROP INDEX` is not destructive to `migrate.cjs` | `61b9d346` |
| 0042 | `"engines": { "node": "22.x" }` in the template and every app (the Hub's root said `>=20.0.0`); template-sync marker on `package.json` | lock files synced; the marker raises nothing on an app that has it | one commit per repo |
| 0043 | p95 latency targets in C-78 §2 and `slo-definitions.yaml` (gateway < 800 ms, auth refresh < 500 ms, payment create < 1000 ms) — `[Planned State]`, not yet measured | the SLO gate and the drift check pass | KB |

## Owner

1. **Railway — the restore check without GitHub:** a cron service from `tec-backup-job`,
   schedule `17 4 3 * *`, start `node dist/restore-check.js`, `RESTORE_LOCAL_POSTGRES=1` and the
   read-only R2 token + passphrase (README step 5). Before 3 Dec, when the GitHub one would run.
2. **Config-as-code:** on one service, confirm Railway reads `railway.toml` from the service's
   root directory, as it does for the gateway.
3. `ALERT_WEBHOOK_URL` — deferred by the owner (risk accepted, 13 Nov).

## Not done

- **0043's other half** — a recorded k6 run needs a staging environment (TEC-AUDIT-0006).
