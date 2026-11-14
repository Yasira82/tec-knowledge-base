# P8 — Infrastructure & DevOps · cycle 2026-11-11 · Run 5

**Status: PASSED_WITH_FINDINGS** · [Code Verified] at `origin/main`, 13 Nov 2026. **BLOCKED here:**
the Vercel connector did not connect this session and this environment's proxy refuses outside
hosts, so nothing was read live — the served headers, each project's Node version and region,
Railway's per-service settings. Those are marked below; the owner read two of them (13 Nov) and they are recorded as such.

## What was checked, and what it found

| Check | Result |
|---|---|
| Every backend service has `/health` and `/ready` | **Yes, all 20** — the migrate-on-start script can be made safe everywhere |
| Containers run as a non-root user | **Yes, all 20** (`USER` in every Dockerfile); Node 22 everywhere |
| The settings that keep a deploy safe are reviewable | **No → 0039.** Only the gateway keeps them in the repo (`railway.toml`: health path, stop timeout). For the other 19 the Healthcheck Path — which the migrate script **depends on** to avoid a DOWN service (payment-service, most of 8 Nov) — the start command and "Wait for CI" exist only in the dashboard |
| Scheduled safety checks keep running | **No → 0040.** 31 scheduled jobs, every one on GitHub Actions — weekly CodeQL in 28 repos, the KB's weekly drift check, the template's weekly fleet-drift, the monthly backup **restore check**. None has run since Actions was refused (12 Nov); the next restore check is due 3 Dec. The nightly backup itself runs on Railway and is unaffected |
| A check fails when it cannot check | **Not the restore check → 0040.** With its secrets missing it prints a notice and **passes**. It *was* configured and proven (12 Oct; again after the passphrase rotation, 10 Nov), so this is latent — a renamed secret would turn it green and silent |
| Backups | Nightly, encrypted, to R2, on Railway; restore proven twice (above). **`ALERT_WEBHOOK_URL` is not set** (owner, 13 Nov): a failed backup only marks the cron run failed in Railway, which tells nobody. With the restore check stopped too (0040), a broken backup would go unseen → part of **0040**, and TEC-AUDIT-0006 |
| Apps pin the Node they build on | **No, none of 25 → 0042** (no `engines`, no `.nvmrc`); Vercel builds on each project's dashboard setting, CI on 22 |
| "Wait for CI" and the Actions hold | **Off on every service** (owner, 13 Nov). So a merge deploys at once — the hold cannot block a deploy, but nothing checks one either: while Actions is refused, a merge is a deploy with no CI. Every local commit in this cycle was tested here before commit; a merge must still wait for CI to be back, or be tested by hand |
| Staging, uptime paging | Still none → TEC-AUDIT-0006 (unchanged) |
| Served headers (HSTS, CSP), e2e against a preview | **BLOCKED** (no Vercel access this session; no outside network) |

## Summary

**4 findings here and in P9: 3 MEDIUM · 2 LOW** (0039 · 0040 · 0042 here). The infrastructure is
sound where it is written down — non-root containers, health endpoints everywhere, backups that
were restored, a migrate script that refuses on doubt. What hurts is what is **not** written
down or **not** independent: deploy safety lives in a dashboard, and every scheduled guard stops
together when one bill is unpaid.
