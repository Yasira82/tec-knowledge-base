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
