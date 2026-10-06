# Session 56t — the seller gets paid, Round 3 as it runs, and a door on every app (4–6 Oct 2026)

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** for the Round 3 bugs
> (each was seen on the owner's phone, §3) and the storage outage (§1.3); **[Code Verified]** for
> every fix and for the sign-in door (§4) — each PR's tests, tsc, lint and build, the door not yet
> opened on a phone. Same session as 56s (the same branch, `claude/tec-knowledge-base-review-6wzngc`);
> 56s closed at 4 Oct's Expansion Map, this record starts the same evening.

## 1. 4 Oct, evening — the marketplace's missing half, and a table that never existed

### 1.1 F2: one payout desk for Commerce and Assets — tec-core-backend #369 · Tec-Commerce #80 · #82

A sale's π settles into the app developer's wallet (that is what a U2A payment is), and nothing
passed the seller's share on (`audits/MARKETPLACE_SELLER_PAYOUT_GAP_2026-08-19.md`). While the
owner was the only seller that was harmless; a Pioneer seller handed over the goods and received
nothing. The owner chose **one desk for both marketplaces** (2026-10-04): one address per seller,
one screen, one admin queue.

- A paid order records what each seller is owed **in the same transaction** (`recordPayoutsOwed`
  inside the PAID transaction of `checkout` and `createOrder`). If the row cannot be written the
  order does not become paid (Invariant #4, Forbidden #6). One row per (order, seller), exact
  decimals, **no fee** because none has been decided.
- Assets' NFT sales reach the same desk: asset-service exposes `GET /marketplace/internal/sold`
  (read-only, no schema change, internal key **and** `x-tec-caller` = service), and commerce-service's
  `AssetSalesSweeper` copies new sales every 5 min (`ASSET_PAYOUT_SWEEP_MS`), idempotent on
  `(source, source_id, seller_id)`, resuming from the last sale it recorded, loud when
  `ASSET_SERVICE_URL` is unset.
- `SellerPayout` (`OWED · SENT · DIRECT`) + `SellerPayoutAccount` (checksum-validated address; a
  secret key is refused loudly). **Mark sent** is the campaign's `markPaid` applied to sellers: a
  64-hex hash, one transfer pays one payout, the chain checked by payment-service's
  `POST /payments/internal/tx/verify` (R1 — only payment-service talks to Pi). `direct` lets an admin
  mark their **own** rows as settling into their own wallet, never another seller's.
- Migration `20261004000000_add_seller_payouts` — applied by `migrate deploy` at start, and
  confirmed applied on deploy (the backend `CLAUDE.md` schema table cites it).
- Commerce's Sales tab: **Your payouts** (owed · sent, the last 10, a SENT row shows its hash; an
  unsent payout is worded as owed, never paid — C-47 §10 E1), the Pi address form ("never your
  passphrase"), and for an admin the **Payouts to send** queue with address, hash field and Mark
  sent. #82: the panel reloads when the desk changes it (`tec-payouts-changed`).
- Not built: an Assets screen. An Assets seller sees their NFT sales in Commerce's desk.

### 1.2 Two old Sales-tab bugs — tec-core-backend #364 · #365

The Sales tab listed the seller's own **purchases** (`?role=seller` was never read) and "Mark
Shipped" called a route that did not exist. Now `GET /commerce/orders/seller` returns only the
caller's items and subtotal of each paid order, and `PATCH /orders/:id/status` allows
PAID → SHIPPED → DELIVERED and nothing else (seller of every item, conditional write, timeline
entry; **no cancel here** — a refund belongs to payment-service). #365: an admin can switch the
Founding gift off in one app to test it as FREE (`legacy: false` for an admin, so the existing
Cancel button appears; Re-grant restores it).

### 1.3 Reconciliation closed payments Pi would not cancel; storage had no `files` table — #370 · #371 · #372

From the owner's Railway screenshots:

- **payment-service** reconciled two `approved` Ecommerce payments (3 Oct 21:00): Pi refused the
  cancel (403) and the reconciler closed them locally anyway. Pi refuses to cancel a payment that
  carries a transaction, so that refusal is exactly the case where closing loses money (Invariant
  #7, Forbidden #6 and #9). Now a refused cancel or an unverified `txid` leaves the payment open,
  retried and logged as an error. The two rows already closed (`2IhXtvMK…`, `Q0kIoAOJ…`) are the
  ones to check if a buyer reports paying on 3 Oct and receiving nothing.
- **storage-service** had failed every upload since 1 Oct: `public.files does not exist`. It shipped
  no `prisma/migrations` at all. #370 added the migration; the deploy still showed no `[storage]`
  line, because **Railway starts the service with `npm start`, which skips the Dockerfile's
  `ENTRYPOINT`** (#371: `start` now runs the entrypoint). Then a 500 on the same key twice — the
  Assets BFF re-posts the image key on every poll of a pending mint (#372: same owner gets the row
  back, another owner gets 409). The lesson is written into the backend `CLAUDE.md` schema table:
  **payment · kyc · analytics are started the same way, so a new migration there would not apply on
  deploy.**

### 1.4 Round 3 MVP — tec-core-backend #373 · tec-app #277

Behind `CAMPAIGN_MODE=pick`: pick 1–3 launch-set apps, a report on each (accepted only after the
app itself reported the arrival — E1), one continuity question (counts only), reward × picks frozen
on the claim. Superseded the next morning (§2).

## 2. 5 Oct, morning — F3 everywhere, then Round 3 as the owner wants it

| PRs | What |
|---|---|
| tec-core-backend #374 | Claims are per round; `CAMPAIGN_TARGET=short` points a round at the domains Pi has not opened |
| Nexus #44 · FundX #39 · Insure #44 · Estate #46 · NX #42 · System #47 · VIP #41 · Titan #41 · DX #48 · Elite #42 · Epic #50 · Legend #45 | **F3** (count the way Pi counts: the arrival waits for this app's own Pi sign-in) in the 13 remaining template apps — with tec-template-base #48 and the earlier ten, **all 23 apps** |
| #375 · tec-app #278 | The per-app suggestion replaces the lost-phone question (C-106 §10a stays unmeasured) |
| tec-app #279 | A pick round claims on a tap, so the Pioneer can still add apps |
| **#376 · tec-app #280** | **Round 3 as it runs:** 3 apps **assigned** by the service (never one the Pioneer holds or tested before; fewest open assignments first; `CAMPAIGN_ASSIGN_CAP`) → a report each (what happened · problem yes/no · the problem or what was clear · optional suggestion) → the owner **approves** or asks for a **revision** with a note (never a rejection) → all approved = the reward. Swap for a technical problem, reason required, 2 per round. 8 additive columns on `campaign_missions` |
| KB #194 · #195 | Decision §4b; **as opened: the same 6 apps for everyone, 0.85 π each, 5.1 π** (5 does not divide by six) |
| #377 · tec-app #281 | Payment history names the app (`source`); the Hub wallet card shows the last 3 payments by app; the apps grid gains a List view with descriptions |

## 3. 5 Oct, afternoon — the first real test, and why no mission ticked

The owner opened the round on the phone: **five of six missions stayed on "sign in there with
Pi"** although Commerce's new `/pi-test` (Tec-Commerce #83) showed the Pi sign-in `ok` and the
arrival `HTTP 200 · recorded true`. Each fix below answers one link of the chain.

| What the phone showed | Cause | Fix |
|---|---|---|
| The arrival reached identity and vanished | The Hub re-sends a tap it thinks was lost; for a row first tapped in an earlier round the restamp set `confirmed_at = null`, erasing the arrival made seconds before. And "arrived" was read off the tap date, so an arrival on last round's row never counted | restamp keeps a confirmation made this round; arrived = `confirmed_at ≥ CAMPAIGN_VISITS_FROM`; in a pick round the assignment counts as the tap — tec-core-backend #378 |
| The app never sent the arrival again | it marked the report done for the life of the tab, and a Pi Browser tab lives for days | remembered for **10 minutes**, key renamed so an old tab reports once more — Commerce #84 · Ecommerce #76 · Assets #73 · Life #69 · Zone #61; `/pi-test` arrival trace in Ecommerce #77 · Assets #74 · Zone #62 |
| 40 Pioneers could work six apps each and the last 15 find the round full after writing every report | a seat was taken at the claim | **a seat is held from the assignment**: refused at "Get my apps" past `CAMPAIGN_SEATS` (25); a holder is anyone with a claim, or with apps assigned who sent a report or was assigned under `CAMPAIGN_HOLD_HOURS` (48) ago — #379 |
| Still no mission opened on a real phone | Round 3 waited for the app's own report of a Pi sign-in, and every link (Pi Browser's new tab, a deploy, a re-sent tap) failed somewhere; Founding ticks on the **tap** | **a mission opens on the tap, like Founding**; the report stores the evidence for the reviewer — `partial` (the app saw the Pi sign-in this round) or `declared` (it did not) — and the review shows it (tec-app #282). The owner's review is the gate before any π moves — #380 |
| "null π each" after the reward was changed on Railway | `Number()` cannot read `0,85` or `٠٫٨٥` | `parsePiAmount` (Arabic-Indic and Persian digits, the Arabic decimal mark, a comma, a trailing π); still invalid → `campaign.reward_invalid` and the round stays closed — #380; two more spellings and a fresh build after Railway marked the #380 deploy failed with an Infrastructure Error and nothing in the logs — #381 |
| *"I never opened Ecommerce, wrote the report, and it was ticked"* | the report checked the visit row against the **round**, so a tap made hours before the assignment, or one the Hub re-sent from what the phone saved on an earlier day, opened it | `CampaignMission.tapped_at` — the first campaign tap **after** the assignment; `/campaign/me` returns `assigned_at` and the Hub re-sends only a tap made after it (saved taps now carry a time) — #382 · tec-app #283 |
| Two approved reports had the same Hub text word for word, on apps never opened; an approval was final | — | **Send back**: `reopen` moves APPROVED → NEEDS_REVISION with a note, audited, refused once the Pioneer has claimed (#383 — the commit meant for #382, merged after it; the Hub button in #283) |

Process notes. **#383 exists because #382 was merged before its last commit was pushed** — check
what `main` has, not what the PR says (the 56q rule, in the other direction). **Railway's
Infrastructure Error** left a deploy "failed" with a built image and an empty log; a PR that touches
only the service's watch path (#381) is the way to start a new build when the dashboard's Redeploy
will not.

## 4. 6 Oct — Life's consent door gets its first reader, and every app gets a door

### 4.1 TEC AI reads Life through the consent-gated door — tec-app #284 · Tec-Life #70

`/api/bff/ai/context` read Life's goals and preferences **as the user** and put the goal titles
into the assistant's prompt, never looking at the grants the person set on Life's Privacy screen
— a goal switched off for TEC AI still reached the model (C-106 §5). Life's door for exactly this
reader, `GET /identity/life/context/:username` (C-106 §11b: served categories only, the consent
map in the payload, every read audited with the reader's name), had **zero consumers**. Now the
Hub reads it once as `tec-app-ai`: goals when GOALS is granted (titles only, active, max 5), focus
when PREFERENCES is granted; a denied or absent category yields nothing. Life #70 (the repo
review): `next` 15.5.27 (request-smuggling advisory), a client-side `TecSdk` with an empty gateway
URL and three unimported packages removed, `forwardLife` sends the session token as the only
identity (the `x-internal-key` it added would have marked every signed-in user a **service**
caller), the coverage gate was declared and never measured (now 73 % statements against 60), the
1,004-line page split into screens, real E2E, `/pi-test`, and **"Ask TEC AI" on a goal** → the Hub
assistant with the question prefilled (`/ai?q=`), because C-104 gates a Life assistant of its own.

### 4.2 The door — `/app` opens on a Sign in with Pi button (21 PRs)

Owner, 6 Oct: *"there should be a login button at the very start, before I enter any app."* Life's
`/app` showed the whole app with **Not signed in · no_token** in Settings and nothing to press:
`no_token` means the browser sent no `tec_access_token`; the cookies live 24 h, and the automatic
re-sign-in (C-123 §10) refuses to run when the tab still carries a stale `__tec_hub_entry`.
Either way the person needed a button.

**`SignInGate`** (`src/components/pi`) wraps `/app`. Three states: no session → a **Sign in with
Pi** button and nothing of the app; session unknown → neither (no gate flashed at a member on every
load); signed in → the app as before. The button runs the app's **own** Pi sign-in (C-123 §10),
**forced past the 10-minute attempt window** — that window stops a loop, not a person pressing a
button. When Pi cannot answer on this page (a Hub-owned session, no SDK, a refusal) the Hub signs
them in and sends them back to this exact page; a secondary link goes through the Hub directly.
**A visit from the Hub never sees it**: the Hub signs the link (§12), so the app arrives with a
session. It is **not** a redirect guard — that was tried and rolled back (§7/§9/§11). English and
Arabic by `<html lang>`; fleet tokens only. Recorded as **C-123 §14**.

| | PRs |
|---|---|
| Origin | Tec-Life #72 (12 locales under `life.gate`; E2E: `/app` without a session shows the button and none of the app) |
| Template | tec-template-base #49 |
| 17 template apps | Zone #63 · Analytics #63 · Connection #92 · FundX #40 · Nexus #45 · System #48 · Estate #47 · Explorer #58 · Alert #50 · DX #49 · NX #43 · Titan #42 · VIP #42 · Elite #43 · Insure #45 · Epic #51 · Legend #46 |
| Commerce #85 | This app sent a session-less visit straight to the Hub's SSO — a sign-in nobody chose, counted for the Hub. New: the app's own sign-in (`lib/pi/visit-sign-in` keeps Pi's token → `POST /api/auth/pi-self-login`, the template's `pi-login` ported → the existing `sso-callback`), so Pi counts the visit **for this app**. `TEC_COLORS`, no token CSS |
| Assets #75 | same shape as Commerce |
| Not changed | **Ecommerce** — a public shop; the door would stand between a Pioneer and the catalogue. NBF and Brookfield are outside this session's branch set |

All 21 merged 09:37–09:38 UTC on 6 Oct. Six PRs read `blocked` at merge time with every check
green (CodeQL · Verify · Playwright · Vercel) and merged on the first try — a stale mergeability
flag, not a rule.

**How it was rolled out.** One script applied the template's files per repo and ran the four gates
locally (vitest · tsc · lint · `next build`) before pushing; a summary line per repo. 18 fresh
`npm ci` filled the session's disk — Legend's install died on ENOSPC and left a partial
`node_modules` (458 entries, no `vitest` binary), which the gate read as `vitest: not found`.
Deleting the finished repos' `.next` directories and reinstalling fixed it (134 tests). **A
`node_modules` left by a failed install is not a cache; delete it before the retry.**

## 5. Left open

- **Round 3 on a phone, end to end** — the morning's six missions were the bugs above. The owner
  reads the review queue: a `declared` row means the app never saw the Pi sign-in this round.
- **The door on a phone** — Code Verified only. First standalone visit to any of the 21 apps
  without a session should show the button; a Hub-grid or campaign visit never should.
- **Merged ≠ deployed** — 21 Vercel builds against the daily quota (56q); check READY before a test.
- **F1** (the A2U app wallet, Pi's review) and **F4** (SPOF actions) unchanged; **F2** has no Assets
  screen; **Ecommerce** has no door and no app-counted sign-in on a visit beyond the one from 56s.
- The two Ecommerce payments reconciliation closed on 3 Oct (§1.3) — only matter if a buyer reports.
- KB #196's "a seat is taken at the CLAIM" was overtaken by #379 the same afternoon — corrected in
  this record's PR.
