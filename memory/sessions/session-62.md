# Session 62 — rotation steps 2–4 done; Pi Browser stops opening the wallet after many sign-ins; visits counted once a day; the bottom bar clears Android's buttons (10–11 Nov 2026)

> Truth State: **[Current State]** for what is merged; **[Planned State]** for the open PRs, marked as such.
> Verification: **[Code Verified]** — tests and tsc on every PR. **[Runtime Verified]** where it says
> so: Railway deploy logs, console output and the owner's phone, from the owner's screenshots.
> Same branch as sessions 57–61 (`claude/tec-knowledge-base-review-6wzngc`). Follows
> [session 61](session-61.md), whose "Left open" item 2 (the rotation) this session continued.

## The rotation — steps 2, 3 and 4 done

Runbook: `audits/RAILWAY_SECRET_ROTATION_2026-10-22.md` §4. No secret value passed through the chat:
every new password was generated on the server, and the commands the owner ran print OK/FAIL only.

| Step | What | Result |
|---|---|---|
| 2 | Pi API keys (Mainnet) regenerated per app, each set in payment-service | **Runtime Verified:** a payment in Ecommerce and one in Assets went through. Testnet keys deferred |
| 3 | A new `BACKUP_PASSPHRASE` in backup-job and in GitHub's secret (the old one kept outside Railway until 5 Jan 2027, so older backups still open) | **Runtime Verified 10 Nov:** `backup: complete · databases: 26 · failures: []`; the restore check from GitHub decrypted that day's backup with the new value and restored all 26 databases (148 tables, ~16,700 rows) with every table's row count equal |
| 4 | New role passwords on all 9 Postgres servers (17 roles), each in the service's `DATABASE_URL` and the backup job; Supabase (analytics) twice; Redis | **Runtime Verified:** every consuming service Active after its change; backups `failures: []` |

What step 4 taught:

- **Order matters for a role password: the `ALTER ROLE` first, checked, then the service's redeploy.**
  Wallet and payment failed with `P1000` once because the service was redeployed before the ALTER ran;
  both came back when the ALTER was run and checked. For a database's own `postgres` role the robust
  order is: set the new value in the database service's variables → deploy the database → `ALTER ROLE`
  over the local socket to the value now in its environment → a 4-line OK check → only then redeploy
  the consumers.
- **A copied password was the failure every time a value was pasted by hand** (storage, trust). The
  new value is shown in groups of four for an eye check; the healthcheck refuses a bad deploy.
- **Redis is single-sourced now.** Every service's `REDIS_URL` is the reference `${{Redis.REDIS_URL}}`;
  Redis' own `REDIS_URL` is built from `${{REDIS_PASSWORD}}`. A future rotation is one variable and one
  deploy. (Before this, the Supabase password had been pasted into 18 `REDIS_URL`s by mistake —
  `WRONGPASS` everywhere until the references replaced them; Supabase was rotated again.)
- **Supabase's free plan keeps no backup.** An earlier claim here that it backs itself up was wrong.
  Analytics' data has no copy until backup-job learns to dump it (open item).
- Passwords that appeared in a screenshot were rotated again.

**Step 5, 11 Nov — done.** `JWT_SECRET`, `JWT_REFRESH_SECRET`, `INTERNAL_SECRET` and `SSO_SECRET`
(SSO_SECRET had been in three Railway services during the breach, so it was rotated too). The values
were generated in a Railway console and never passed through the chat. Railway reads the first three
from project **Shared Variables** (`${{shared.…}}` in each of the 20 services); all 24 Vercel projects
got the three values, then a production redeploy (all READY). **Runtime Verified:** the Hub's
`/api/health/services` — which calls the gateway with the internal key — answered `ok` for the gateway
and all 19 services; sign-in and a payment worked. Railway's AI Agent had spent $5.03 of real money on
its own; its limit is now $0.

**Step 6:** `ALERT_WEBHOOK_URL` is not set in backup-job — nothing to rotate, and no alert reaches anyone
when a backup fails. `UPSTASH_REDIS_REST_TOKEN` deferred by the owner (rate-limit counters only).
Step 7 after Round 3 (owner). Round 3 opens only
after the rotation (owner).

## Payments stopped reaching the wallet after browsing many apps — the cause

Owner, 10 Nov, on the phone: after opening several apps from the Hub and browsing for a while in one
Pi Browser session, a payment in **any** app never reached the Pi wallet and timed out; closing Pi
Browser completely and reopening it fixed it. It began roughly when the campaign began.

Every app visit made its own `Pi.authenticate` under that app's id — the visit sign-in that counts the
visitor for the app's `.pi` domain. Dozens in one browser session, after which Pi stops answering
until the browser restarts. **[Runtime Verified by the owner; the mechanism inside Pi is inferred.]**

Fix: **sign a visitor in with Pi once per person per day per app**, not on every visit.

- `lib/pi/counted-once.ts` remembers the day Pi signed a username in on this device
  (`__tec_pi_counted_day`, the last 20 people). The username comes from the app's own `/api/auth/me`.
- A visitor counted today gets no visit handshake; the arrival is still announced (so the Round 3
  mission ticks). The next day's first visit signs in again: Pi's domain screen says a claimed domain
  is "periodically reviewed" and must "still meet the thresholds" after a year, so a person counted
  once and never again would read as an app nobody uses.
- A Pay tap still authenticates first — the announcement does not mark the page authenticated.
- A wallet that never opens now says what to do: close Pi Browser completely, open it again, try once more.

Merged: Assets #84 → #85, Commerce #93, Ecommerce #85, Life #109, Zone #71 (the five Round 3 apps
besides the Hub). Owner, 11 Nov: a payment reached the wallet after browsing. **Open:** the template
(#55) and the other 16 apps (one PR each, below).

**The Hub's app list already opens apps standalone** (no referrer, a one-time sign-in link) since
2 Oct — a visit from the list counts for the app, not the Hub. A plan this session drafted to "make
the grid standalone" was unnecessary and was dropped. Returns after a Hub payment (Mode 1) and
`/mint` still go through the Hub; they are returns, not first visits.

Pi's domain screen (owner, 11 Nov): a claim needs **5 unique KYC'd approved Pioneers** engaging with
the app; deadline **19 Dec 2026**; periodic review; renewal after a year. A wallet implies KYC, so the
campaign's paid Pioneers qualify. assets.pi read "Requirements Not Met" that day.

## Other fixes

| PR | What |
|---|---|
| tec-core-backend #502 | Every Redis client logs its `error` event (`{ error: err.message }`) — consumers in commerce, asset, nexus, notification, search, analytics, connection, trust, realtime, identity, business, the shared event bus and auth's middleware had no listener, so a lost Redis connection was an unhandled error |
| tec-app #323 | The Hub's bottom bar sat under Android's three buttons: Pi Browser draws edge to edge and reports `env(safe-area-inset-bottom)` as 0. A boot script sets `--tec-safe-bottom-fallback: 48px` on Android when the inset is 0; the bar reads `max(…)` of both |
| tec-assets #83 | Mint did nothing from inside the Hub: `authenticateAtTap` races `Pi.authenticate` against 10 s and falls back to the Hub payment |

## Open PRs at the end of the session  *[Planned State]*

- **The 16 template apps** — Analytics #68 · Connection #97 · Fundx #45 · Nexus #52 · System #53 ·
  Estate #52 · Explorer #64 · Alert #56 · Dx #54 · Nx #49 · Titan #47 · Vip #47 · Elite #48 ·
  Insure #50 · Epic #57 · Legend #51: Pi sign-in once a day **and** the bottom-bar fix.
- **Assets #86 · Life #110 · Zone #72:** the bottom-bar fix (they already count once a day).
- **tec-template-base #55:** once a day (the template has no bottom bar).

Each app's `src/__tests__/safe-bottom.test.ts` fails on any bare `env(safe-area-inset-bottom)` left in
`src`, so a new bar cannot reintroduce the fault. Commerce and Ecommerce have no bottom bar.

## Left open (in this order)

1. Merge the PRs above; then a phone check after Vercel deploys (merged ≠ deployed): fresh Pi
   Browser → Hub → the campaign → three apps → `/pi-test` shows sign-in ok and arrival recorded → a payment.
2. Round 3 — the rotation that gated it is done. Later: the Upstash token; step 7 with its
   re-encryption code; a backup alert channel (a new Telegram bot or Discord webhook).
3. A Supabase (analytics) dump in backup-job.
4. From session 61: Healthcheck Path on the eight template services; the database decisions;
   lockfiles; NestJS 11. Then asymmetric JWT and a key per caller.
