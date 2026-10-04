# Session 56s — a Portal listing pass that found the gateway's front door open (26–28 Sep 2026)

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** for C17 (a production
> request, §3) and the two data repairs (their audit lines, §2 · §5); **[Code Verified]** for the
> rest (each PR's tests). Backlog: `audits/PORTAL_LISTING_BACKLOG_2026-09-26.md` (items C1–C19).

## 1. What was asked

Configure all 24 Pi Developer Portal listings from the owner's screenshots — name, subtitle,
description, intro image, ≥3 previews, languages, category — and keep a list of every code fix the
screenshots exposed, to be done at the end. The listing work (copy, 24 logos, 24 intro images, the
cropped previews and their generators) is `marketing/portal-assets/` + the backlog, merged as #174.

Reading the screenshots against the code produced 19 items. Four were not cosmetic.

## 2. Invented "verified" data in production (C7 · C8 · C11) — tec-core-backend #343

NX, Alert, Epic, NBF, Legend and VIP's membership table seeded fixtures into **whatever database
they booted against**, production included, the first time a table was empty. The fixtures claimed
verification nobody issued: "live board · 6 verified" (NX), five "✓ Zone Verified" projects on
Epic's public Discover page, a VERIFIED "Pi Corner Store" (NBF), a public Legend profile of
"verified" achievements, and — in every user's inbox — a Pi scam warning about no real site.

- Seeding is dev-only (`SEED_DEMO_DATA=true` AND `NODE_ENV != production`, `demo/demo-seed.ts`),
  and a fixture never carries a badge — Explorer's rule, now shared.
- `npm run demo:purge` removes the rows already written: each table matched on an identifier the
  module invented AND the fixture owner, one transaction, dry run by default. A **command, not a
  route**: see §3 for why.
- Ran on production 2026-09-27 18:09 UTC via a Railway pre-deploy step (dry run reviewed first):
  8 NX · 12 Alert · 5 Epic · 1 NBF · 5 achievements + 4 badges + the profile · 1 VIP membership.
  `profileRemoved: true` confirmed no real achievement hung off the fixture profile.

## 3. The gateway's front door (C17 · C15) — tec-core-backend #345 · #346

The finding that mattered most came from asking why the purge had to be a command.
`proxy.service.ts` adds `x-internal-key` to **every** request it forwards. Every service trusted
that key as "the caller is a service". So a signed-in user calling the gateway directly with their
own token looked exactly like a BFF. By code reading:

| Route | What any signed-in user could do |
|---|---|
| `POST /api/payment/internal/a2u` (+ `resume`, `cancel`) | send up to `PI_A2U_MAX_PI` (10π) from the **app wallet** to any uid, repeatably |
| `POST /api/wallet/internal/add-funds` · wallet reads by id | credit a wallet; read anyone's balance and transactions |
| 10 identity-service modules (Alert, Elite, Epic, Insure, Intent, Legend, Nexus, NX, Titan, VIP) | act as any owner named in `body.owner` / `/:owner` |
| identity + storage `/internal/` routes | service-only maintenance (C15: Explorer purge-demo) |

Fix:
- **Gateway** (`jwt-auth.ts`): a request without `INTERNAL_SECRET` to any `/internal/` path → 403
  (path decoded, case-insensitive — Express routes `/INTERNAL/` to `/internal/`). The gateway also
  sets `x-tec-caller` = service | user | anonymous and strips caller-supplied identity headers.
- **Second locks**: payment-service `router.use('/internal', requireServiceCaller)`; wallet
  `InternalGuard`; identity `/internal/` refusal + `OwnerMatchGuard` on the 10 controllers (a `user`
  caller may name only itself). No app changed — all 40 app call sites go through a BFF with the key.
- **Verified in production** 2026-09-27: `GET /api/payment/internal/a2u/limits` with no credentials
  answers `403 Internal route`.
- **Abuse check**: payment-service logs hold no `payout` line (sent or failed) from 2026-09-24 18:16
  GMT+3 (the oldest line Railway retains) to the fix; a control query (`Outbox`) returned rows, so
  the search works. Earlier than that, only the payout wallet's on-chain history can answer — open.

The gateway did not deploy on merge: Railway's "Wait for CI" held it, because backend CI had been
red (§6). #346 touched the three services to redeploy them and records why the setting is off.

## 4. Reputation could be self-granted (C12) — tec-core-backend #344 · Tec-Epic #44

An owner could complete a minute-old DRAFT project → LEGEND; Legend recorded a **verified**
achievement, Analytics raised Creator, and three reached Elite's `PI_LEGEND` bar. Now: completion
needs every milestone done (422 says how many are open, 409 on terminal, conditional write); the
event carries `zoneVerified`; Legend marks it verified and Analytics scores it only when Zone did.

## 5. The rest of the backlog

| Item | Fix | PRs |
|---|---|---|
| C13 | VIP Tiers said 50π while the buy card charged 5π, and priced earned tiers. One price (5), earned tiers unpriced, catalog upserted every boot | backend #347 · Tec-Vip #37 |
| C9 | Alert filed each Analytics re-evaluation as a new entry, "now" for ever. One entry per metric + day, age computed at read. `npm run alert:dedupe` ran 2026-09-28 03:25 UTC: 32 rows → 4, 0 unparsed | backend #347 |
| C1 | FundX promised "earn within a compliant framework" / "always held securely" — gone, EN+AR, pinned by a test | Tec-Fundx #35 |
| C2–C6 | Ecommerce badge over the heading · Analytics chart drew 11 of 30 days · Assets "TOTAL PORTFOLIO" was assets only · Zone empty groups blamed "Commerce (V2)" · DX "(certified)" / "compliant" | #68 · #53 · #64 · #55 · #42 |
| C10 · C19 | A signed-in user told "Sign in with Pi" when there was no data or the backend failed — split in Titan, Insure, Elite, Epic, Estate, Legend | #37 · #39 · #37 · #45 · #42 · #41 |
| C14 | Brookfield's simulated assets wore "Verified · ✓ Zone · DECIDED" — one "Simulated" pill | Tec-Brookfield #21 |
| C16 | No app had an icon — `src/app/icon.png` + `apple-icon.png` in all 24, build-verified | 24 PRs |

## 6. Backend CI (C18) — cause found, fix is an account setting

CI on `main` failed in ~3 s from 2026-09-23 (last green 2026-09-20), with no change to `ci.yml` in
between and job logs returning 404. The job was never given a runner (`runner_id: 0`, no steps).
`Tec-core-backend` is the only active **private** repo; every public TEC repo stayed green. That is
the signature of exhausted Actions minutes on the private-repo allowance. Until it is resolved
(Billing → Actions budget, or the monthly reset), no backend merge is tested by CI, and Railway's
"Wait for CI" must stay off.

## 7. Left open

- C18: the Actions minutes (owner, Billing page); then turn "Wait for CI" back on.
- Whether platform findings ("Payments are 34% of normal") belong in every user's inbox (C-111).
- The payout wallet's on-chain history before 2026-09-24 (C17 abuse check).
- Portal: add Arabic where it applies, set the Hub's Mainnet app wallet, submit the listings,
  review the Testnet side of 22 apps, a third NX preview, and retake the screenshots the fixes
  changed (FundX home, Ecommerce home, Analytics payments, Assets portfolio, Zone registry).

## 8. The same day, after: campaign round 2 in production (28 Sep)

The owner opened round 2 and took it to Reddit, X and Fireside. Every fix below came
from something a real user hit that afternoon.

| What was reported | Cause | Fix |
|---|---|---|
| Round-2 missions never ticked for apps visited in round 1 | `campaign_visits` is one row per (owner, app) stamped at the FIRST tap; `CAMPAIGN_VISITS_FROM` filtered it out and a re-tap never restamped it | a new-round tap restamps a row below the floor — tec-core-backend #349 |
| "Reply" posted without the quote (TEC group) | the messages BFF zod schema named only `body`; zod drops unnamed keys, so `reply_to` never left the app | Tec-Connection #87 |
| "Delete for everyone" did nothing | Railway: `FST_ERR_CTP_EMPTY_JSON_BODY`. The Connection BFF sent `Content-Type: application/json` on every call and Fastify (4.28, inside `@nestjs/platform-fastify`) refuses it with no body — delete, mark-read, clear chat, join/leave, story-seen all failed | header only with a body — Tec-Connection #87 |
| A group owner could not take down a member's message | delete-for-everyone was sender-only | owner over anyone, admin over members, audited (`connection.message.moderated`) — tec-core-backend #350 + Tec-Connection #87 |
| Two Connection users invisible in Analytics | active users = distinct ids in the event log; nothing recorded opening an app | `app.arrived.v1`, once per user/app/day, active users only — tec-core-backend #351 |
| (found while checking the above) platform analytics exposed | an INVALID Bearer fell through to the internal key; the Analytics BFF checks only that a cookie exists and always adds the key | a present Bearer must verify — tec-core-backend #351 |
| "Testnet wallets also start with G" (a Pioneer on Reddit, twice) | the page asked for "your public address" | Mainnet named everywhere the address is asked, EN + AR — tec-app #263 |

Two process notes. **Rewards are paid by hand** (`Mark sent`): `PI_A2U_WALLET_SEED` is
unset, and A2U from another Pi app's wallet cannot work anyway — a `uid` is per app.
**One reward was sent before its claim existed** (seat for `GDPDTK…`); when that claim
arrives, `Mark sent` takes the same hash (`518b9d30…`) — the check matches the address,
the amount and an unused hash, not the order.

## 9. 29 Sep: why only 7 `.pi` claims opened, and the Agent-Ready Commerce proposal

**The 7 claims.** The Domains screen shows 7 claims pending: life · tec · connection · explorer · legend · elite · dx. The other 17 show "Requirements Not Met", even though `hub/admin/pioneers` puts every app at ≥ 5/5.

The owner sent screenshots of ASSETS-APP and EXPLORER-APP in the Portal, and the two setups are identical: Pi Sign-In Active, PiNet Active, Listing and Ads not set up. So the checklist is not what separates them.

The two tools count different things:
- **Our coverage** counts an arrival when the page loads. `ArrivalReport` posts on mount, once per session, and does not wait for `Pi.authenticate`.
- **Pi counts** KYC'd Pioneers who signed in with Pi *inside that app*. A participant rushing through 24 apps can close each one before allowing the sign-in prompt. Anyone without KYC never counts for Pi.

A third path is possible but not verified: if the signed hand-off link was not ready, the plain link bounces through the Hub's SSO. That can set `__tec_hub_entry`, which puts the app in foreign-session mode, so the Pi SDK never loads.

**Next steps:**
- Immediate: tell participants to allow the prompt in every app.
- Code fix: report an arrival only after a successful sign-in. It touches all 24 app repos, so it was offered but not started. The owner has not asked for it yet.

**Agent-Ready Commerce.** The owner brought a strategy proposal from another conversation. It is recorded and assessed in `audits/AGENT_READY_COMMERCE_ASSESSMENT_2026-09-29.md`. It covers:
- agent-ready commerce;
- Nexus as discovery for all of Pi;
- Explorer as the human layer and Nexus as the machine layer;
- Pi Flash.

Findings:
- Intent, Delta, Gate and Proof already exist (#316, #325). The build order's 4.5 row was stale and has been corrected.
- On Pi an agent cannot pay.
- TEC cannot execute inside another Pi app.
- AP2 and ACP already occupy the general concept.

Recommendation: one measured path inside TEC, on Commerce, first.

## 10. 29 Sep, later: the Hub's black screen, Pi sign-in on a visit, and where Analytics' data lives

| What was reported | Cause | Fix |
|---|---|---|
| Back from any app gave the Hub as grey cards, and the next Back left the tab | Pi Browser can reopen the Hub in a context without its cookies (C-123 §7). `/api/auth/me` returns 401, and a silent Pi sign-in could run up to 15 s + 45 s, with nothing on screen | bounded (8 s for `/me`, 20 s for the sign-in), then sign-in with the Hub remembered; "Signing you in with Pi…" shown while it runs. tec-app #264. The owner saw it once and not on the next try — it is intermittent |
| Commerce and Ecommerce show the username, yet their `.pi` claims stall | The username comes from the Hub's cookie. Ecommerce called `Pi.authenticate` only at payment, Commerce only on `/app`, Assets only when the cookie was readable (and ignored ADR-007) | a visit sign-in on every standalone visit, never in a Hub-owned session. Tec-Commerce #73 · Tec-Ecommerce #70 · Tec-Assets #66 |
| The Ecommerce menu showed no account | Every page but Home read `tec_user` from client JS, which Pi Browser hides | the drawer asks `/api/auth/me` itself. Tec-Ecommerce #71 |

**Where Analytics' data lives.** It is in Supabase, as C-105 says:
- project `tec-analytics`, organization Tec-Ecosystem;
- Free plan, 28 / 500 MB.

The organization is under a secondary GitHub login the owner had forgotten. The main account was invited as Owner.

**Pi Network Pulse.** A community developer's on-chain migration tracker raised the question of doing the same in Analytics. The answer: not the crawl; a small card of public numbers instead.
- Proposal: `audits/ANALYTICS_PI_NETWORK_PULSE_2026-09-29.md`.
- The supply endpoint is still unverified. This environment cannot reach `minepi.com`.

## 11. 29 Sep, evening: Analytics built, and why Hub-opened visits never count

**Analytics shows the Pi Network.**
- **The owner's decisions:**
  - Analytics may present public Pi Network numbers;
  - they go on the existing public `/pulse`.
- **Built:**
  - tec-core-backend #352: `pi-network.ts`, a Horizon read of the latest 200 ledgers, cached, with no writes;
  - Tec-Analytics- #55: the card on `/pulse`.
  - Both are merged.
- **Left out:**
  - `total_coins`, which on Pi may be the genesis supply;
  - any supply figure, because no source names Pi's supply endpoint and this environment cannot reach `minepi.com`.
- **Status at 18:40:** the card read "unavailable". The BFF response had no `network` field because #352's Railway deploy was stuck at "Publishing image" during a Railway incident. The next check is in the audit §3.
- **Records:** C-105 §4 now carries the scope. Before building, the question to the community developer, about which endpoint his tracker uses for supply, was drafted for the owner to ask on Reddit.

**Hub-opened visits never count at Pi.**
- **The finding:** a Hub grid tile goes through the Hub's SSO, so the app marks the tab Hub-entered, skips the Pi SDK (ADR-007) and never signs the visitor in. Pi credits the Hub.
- **What does count:** the campaign's standalone handoff links.
- **The proposal:** open grid apps the same way.
  - Payments inside the app become Mode 2, landing in each app's own wallet.
  - No new wallets are needed: each app already has one, because Pi requires it for U2A.
  - The Hub's own payments are unchanged.
- **Status:** the owner has not decided. Proposal: `audits/HUB_GRID_VISITS_NOT_COUNTED_2026-09-29.md`.

**Claims.** commerce.pi (999 π bid) and analytics.pi (400 π) went to Claim Pending, making nine. commerce.pi opened within hours of Commerce's visit sign-in (#73).

**Rewards.** One more was paid by hand: 1 π to `GBLGT…LUBAY` (tx `967b6b8f…0afba68`, block 28963744), to be recorded with `Mark sent`.

## 12. 2 Oct: payments from Hub-opened apps, the grid, Back, and stock

**Payment failing after "Hub first".**
- A Mainnet "Show details" trace (tec-app #265) showed the Hub modal's `Pi.authenticate` silent for 89.5 s, in a tab Pi Browser said was Ecommerce's. That is C-123 §9.
- "App first" worked because it paid Mode 2, inside the app.

**The grid (owner approved).**
- #266: apps open standalone (signed handoff, new tab). The payment worked.
- #268: switched to the same tab, so Back would work. Four grid payments then timed out, because Pi stays with the tab's first app.
- #269: reverted to the new tab, and added HubContinue for a session-less `/hub`.
- #270: Back was landing on `/`, not `/hub`, so a grid tap now remembers `/hub`. **Phone-verified:** signed-in app, payment completes, Back lands on `/hub`.

**Stock.** Ecommerce took 12π for an out-of-stock Cap, because commerce refuses the order only after payment. Ecommerce #72 checks status, stock and price before any π moves. It also closes a price-tamper hole.

**commerce-service.**
- #354: Ecommerce orders, seller sales, the first subscription read.
- #355: the first `order.paid.v1` after a restart is no longer dropped.

**Wallets (owner).**
- No TEC app has a Mainnet app wallet. The audit's claim that each did was corrected.
- Mode 2 payments land in the owner's own Pi wallet.

**Process lessons.**
- The tec-app script is `npm run typecheck`. `type-check` does not exist, and a pipe hid the failure for several runs. CI ran it correctly.
- Vercel logs and deployments answer 403 to this session's connector, so the owner's screenshots were the evidence.

**Records:**
- `audits/HUB_GRID_PAYMENTS_AND_BACK_2026-10-02.md`
- C-123 §13
- C-02 row 15

**Later, 2 Oct: Pro from the grid.**
- Every template app opened from the grid timed out at Pro, while the same app opened from Pi's own list paid. The owner tested both ways.
- The cause: the tap joined the load-time warm-up, which Pi does not answer in a handoff-opened tab.
- The fix: tec-template-base #45 plus 18 app PRs (`ensureAuth({ fresh })` when `__tec_handoff_entry`). Verified on NX (#39).
- Found in the same logs: Connection's `purge-stories` cron had never run (empty JSON body). Tec-Connection #88.

**Later, 2 Oct: per-app Pro.**
- **The report.** NX Pro had switched on the Hub plan and every app's Pro. commerce kept one plan per user, and every app Pro payment activated it.
- **The owner's decision.** Each app's Pro card is its own, with a cancel. The Hub plan is a separate benefit.
- **The backend.** tec-core-backend #356 adds `AppSubscription`, `?app=` on status and cancel, and a legacy rule for a Pro bought before the split.
- **The apps.** Template #45 and 17 app PRs.
- **What bit.** A raw-colour theme test in Connection and Explorer; the button now paints from the palette.
- **Record.** `audits/HUB_GRID_PAYMENTS_AND_BACK_2026-10-02.md` §2.8.
- **A wrong deploy step.** I asked for a `db:push` pre-deploy step on commerce-service, and Railway refused it: it wanted unique constraints on `orders` plus `--accept-data-loss`. commerce-service runs `migrate deploy` at start, so the table became a migration and the backend CLAUDE.md now maps each service's schema path.

**3 Oct.**
- **NX Pro had no Cancel.** It was the owner's pre-split Pro, honoured everywhere as legacy. Owner: "a Cancel button, like the other apps." tec-core-backend #357 moves a pre-split Pro to the app it was bought in and closes the Hub plan.
- **The Hub plan page showed "Pro" after a cancel.** It read `plan` and not `status`. tec-app #271 adds `effectivePlan`; Profile and the dashboard page had the same bug.
- **Commerce and Assets.** `usePiAuth` no longer starts a Pi handshake on load (#74, #67). Assets now has the ESLint config it never had, and its CI lint step blocks.
- **NBF and Brookfield.** Both were outside the earlier rollouts: #28, #24.
- **Record.** Audit §2.9.
- **Later on 3 Oct.**
  - A FREE user minted a 66th asset: the cap lived only on Hub routes. Fixed by Assets #68 and tec-app #272.
  - "Upgrade to Pro" failed in Pi Browser: no payment record without a readable `tec_user`, plus `Bearer null`. Fixed by tec-app #273, which also makes the plan hook return the plan in force.
  - A paid NFT was missing until the app was reopened: a single refresh on the 202. Fixed by Assets #69, which re-sends until delivery.
- **Founding gift.**
  - Owner: the Founding gift covers the Hub and every app (#358).
  - The Re-grant left 3 Pioneers "unresolvable". The real cause was a wrong auth path, `/auth/user-by-username`, which had never worked; fixed by #360.
  - The owner's two SQL queries in Railway proved the accounts existed.
  - Result: 2 lost gifts recovered, 0 unresolvable.

**The last unit (3 Oct).**
- Owner: "fix the last unit in stock."
- The pre-check (#72) only told buyers the unit was there. The new hold actually takes it: the stock is reserved atomically before Pi opens, and the payment's own event settles the order.
- Found along the way, both fixed:
  - the order consumer had never run;
  - `checkout` marked orders PAID on an unverified `payment_id`.
- Hub-paid Ecommerce purchases now get an order.
- PRs: tec-core-backend #361, Tec-Ecommerce #73, tec-app #274.
- Audit §2.10.

**Round 3 (4 Oct).**
- The owner brought reports from another conversation. They describe a 19-stage Evidence
  Engine and call most of it SEALED.
- A search of all 28 repos (every branch) and the KB found none of its code.
- Decided with the owner:
  1. the interview first, still active from 2026-08-16;
  2. a small funnel table;
  3. a one-mission MVP;
  4. the Engine only when the data asks for it.
- The "fear" theory is a hypothesis, to be tested A/B.
- Record: `audits/ROUND_3_DISCOVERY_DECISION_2026-10-04.md`.
