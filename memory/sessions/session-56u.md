# Session 56u — one Pioneer was ten accounts, and the TEC balance had nothing behind it (8–10 Oct 2026)

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** where the owner's phone or
> Railway showed it (the duplicate accounts, 206π after #303, a purchase that no longer credits the
> buyer, the refunded 1π withdrawal, the wallet census in §4); **[Code Verified]** for every PR —
> each with its tests, tsc and lint. Same branch as 56s/56t (`claude/tec-knowledge-base-review-6wzngc`).

## 1. TEC AI — the second reading, and a mentor (8–9 Oct)

| PR | What |
|---|---|
| tec-app #294 · #295 · #296 | Candid answers, real products, what TEC AI sees. OpenRouter's free models read from its catalogue and the walk goes past a 403; Life goals reach the chat; a recommendation ask searches the product catalogue (tec-core-backend #390: `q` and `max_price` on `GET /commerce/products`); Android Back closes the drawer instead of signing out. |
| tec-app #297 · Tec-Life #77 | **The mentor, step 1** (owner: "a guide who builds the person, in everything"): a plan arrives with up to five steps, kept inside the goal as `- [ ] step` lines; Life saves nothing until Add. Arabic product asks also search the English word. The mentor's limits (not a doctor, lawyer or adviser; danger → emergency help) are in the prompt. |
| tec-core-backend #391 · Tec-Life #78 | **Step 2 — the weekly check-in.** `CHECKIN` is a consent category (absence is a no). When on, identity-service files at most one TEC Alert per ISO week about an active goal with no step for 7 days, naming its next unticked step, in the person's Life language. |
| tec-core-backend #392 · Tec-Life #79 | **Step 3 — the monthly review.** Same switch; in the first 7 days of a month, one Alert about the month just ended: goals finished, new, π logged, days with a step. Counts only what Life can vouch for (ticks carry no date and are not counted). |
| tec-core-backend #393 | Every app's BFF sends `Content-Type: application/json` on a DELETE with no body; Fastify refused it, so deleting a goal (or all Life data) answered 400 and did nothing. identity-service now reads an empty JSON body as no body. |
| tec-app #298 · #299 · #300 | Photos: attach once and they stay with the chat; up to six, as a row of thumbnails; a total-size cap and 20 distinct attachments per day; the health check (`?images=1`) answers inside Vercel's limit. Gemini is the only provider that sees images. |

C-106 §11b M1 carries the mentor as the charter's own text.

## 2. One Pioneer was ten accounts (9 Oct)

**Symptom (owner):** "the wallet had over 2000π, now it shows 5". Read-only SQL on auth-db and
wallet-db found `yas55eR82` as **ten** user rows and five wallets (2762 · 206 · 54 · 25 · 5π).

**Cause.** A Pi `uid` is app-local. Every one of the 24 apps signs itself in (C-123 §3), and
auth-service keyed accounts on `pi_uid` — so each new app made a new account (Invariant #3). The
Hub showed the newest. This is why the duplicate-identity problem "came back" after earlier fixes:
they resolved one app's uid and never asked which account a *person* is.

| PR | What |
|---|---|
| tec-core-backend #394 | An unknown uid with a known Pi username (from Pi's own `/v2/me`) signs into the account with that name instead of creating one. |
| #395 | **Always the oldest** account with the name — also when this app's uid already has its own duplicate row (#394 missed that case, so the ten stayed ten). The canonical rule: oldest by `created_at`. Its `pi_uid`/`pi_scopes` are never rewritten. |
| #396 | A refresh moves a session that sits on a duplicate to the oldest account (a signed-in Pioneer never signs in again). |
| tec-app #301 | The refresh route rewrites `tec_user.id` to the account auth-service returned. |
| tec-app #302 | One request, one identity: the BFF called the gateway with a stale cookie while reading the context from the in-memory token. |
| tec-app #303 | **Why it still showed 5π:** Vercel's log had no POST to `/api/auth/logout` or `/api/auth/pi-login`, and auth-service saw no request — Sign out navigated before the request went, and `/` read the still-present cookie. Now: once per tab the Hub asks for one refresh and reloads onto the account it names; every sign-out awaits the server. **Result: 206π, account `afa10fec` (owner's phone).** |

Lesson recorded: a Railway **Redeploy** reruns the same commit; check the deployment's commit.

## 3. The TEC balance had nothing behind it (10 Oct)

**Found in the code** (`payment.controller.ts` → `payment.completed.v1` → wallet-service): the
event's `userId` is the **payer**, and wallet-service credited it. Every purchase took real π from
the buyer's Pi wallet (into the app's wallet) **and** added the same amount to the buyer's TEC
balance. Owner's query: 462 payments → exactly 2762π on one account; 57 → 232.5π on another.

**The model the owner set (2026-10-10):** the buyer pays from their Pi wallet; the seller's share
goes to the seller's TEC wallet; from TEC the seller withdraws to their Pi Network wallet.

| PR | What |
|---|---|
| tec-core-backend #397 | A purchase credits nobody. Verified live: a 1π payment from System, log `no balance credited`, Hub still 206π. |
| #398 · Tec-Commerce #86 | The seller's share (commerce's `OWED` payout rows) is credited to the seller's TEC balance exactly once (`payout:<id>`), the row becomes `CREDITED` and Mark sent refuses it. **Off until `SELLER_BALANCE_CREDIT=on`** on commerce-service (+ `WALLET_SERVICE_URL`). |
| **#399 — P0** | Found while preparing withdrawals: wallet-service's user routes never checked whose wallet they touched — any signed-in user could **deposit any amount to any wallet**, empty any wallet, or **transfer anyone's balance to themselves** (the Hub's `/api/wallet/transfer` forwards the body). Deposit removed; withdraw/transfer require the caller's own wallet; transfers between currencies refused. |
| #400 · tec-app #304 | **Withdraw to Pi Network.** The recipient is the uid Pi gives for a Pi sign-in made in the Hub at that moment (uids are app-local), refused unless Pi names the signed-in TEC user. Closed unless on `WITHDRAW_TO_PI_ALLOWLIST`; ≤10π each, ≤50π a day, one open at a time; the amount is held first; sent → completed with the hash; refused with nothing moved → returned; no answer → **pending, never retried or refunded automatically**. Runtime: one 1π attempt failed (no approved payout wallet) and was refunded correctly. |
| #401 · tec-app #305 | **Which network each payment moved on, asked of the chain** — admin, read-only, `/hub/admin/payment-networks`. Needed because the `metadata.testnet` marker exists only since September (§4). |

## 4. The census (owner's read-only SQL, 10 Oct)

- Ledger types: `CREDIT` (buyer credits) 876 rows / 5559.5π · `transfer` 169π · `deposit` 1.3 **TEC**
  (the legacy 0.1-TEC conversion) · **`SALE` 0** · one failed withdrawal + its refund.
- Every positive balance (≈5,590π) came from its owner's own purchases, transfers between users, or
  nothing at all. **None came from a sale.** `gateway` (2380π) and `current` (28π) are not people:
  payment-service's `SERVICE_ACTOR` fallback recorded 248 payments without a user.
- **magy888 (`ddb41531`)**: balance 89.5π, ledger 60π. Audit rows show the balance jump from 10π to
  36.5π on 18 Apr with no ledger or audit row; how is not knowable from the data. Some audit rows
  read `"35.51"` — an old audit bug (a string concatenated), not a balance error.
- **Test-Pi:** the owner noted magy888 has no Mainnet wallet, yet his 13 April payments were
  credited. payment-db confirms no payment before September carries a network marker. Only the
  chain can classify them — #401 / #305.

## 4b. The unbacked balances were reversed (10 Oct, evening)

The chain check (#401, `/hub/admin/payment-networks`) settled who paid what:

| Payer | Mainnet (real π) | Testnet (Test-Pi) |
|---|---|---|
| Owner's five accounts | 2795.2π | 548.5π |
| `gateway` | 2412π — every product name and date matches the owner's launch-day "Process a Transaction" tests (19 Jun – 12 Jul) | 0 |
| magy888 · `f2e3de66` · `current` | **0** | 316π |

No outside customer has paid real π yet. Every real π is the owner's, sitting in the apps' Pi wallets.

**Reversed** with the tool built for it (tec-core-backend #402 · tec-app #306, `/hub/admin/void-balances`):
the dry run listed 10 wallets — 5589π + 1.3 TEC, exactly the census — the owner typed `VOID-UNBACKED`,
and the run answered **"Reversed 10 wallet(s)"**, none skipped; a second dry run shows **0 wallets**.
Each wallet has one `VOID_UNBACKED` ledger row with its breakdown (purchase echoes, transfers,
deposits, and magy888's 29.5π with no ledger row) and one `void_unbacked` audit row. Only a `SALE`
(a seller's share, #398) is backed from here on. **Runtime Verified** (owner's phone).

## 4c. Duplicate accounts merged — commerce (10 Oct, evening)

| PR | What |
|---|---|
| tec-core-backend #403 · tec-app #307 | auth-service `GET /admin/duplicate-accounts` (admin, read-only); commerce-service `GET/POST /commerce/admin/account-merge` — the accounts come from auth-service by exact name, oldest canonical, never from the request; the dry run executes the real code in a rolled-back transaction; the merge is one transaction + one `account_merges` row. Needs `AUTH_SERVICE_URL` on commerce-service. |
| #404 | The owner's live PRO (to 2026-11-03) sat on duplicate `cbc4bb46` while the oldest had a FREE row, and the first rule ("the oldest keeps its own") left the owner on FREE. The oldest now keeps the **better** plan (live paid > FREE, then later end); the rows swap, nothing deleted. |

**yas55eR82 (Runtime Verified, owner's phone):** first run moved 13 products · 71 orders · 3 seller payouts ·
the payout address · 5 app Pros · 1 referral; the re-run after #404 moved `subscription 1`. Six rows stay on
duplicates as reported conflicts (three Hub plan rows, including the old FREE one, and three referral codes).

### Assets · KYC · notifications (same evening)

| PR | What |
|---|---|
| tec-core-backend #405 · tec-app #308 | asset-service merge: each asset owned moves with an `AssetHistory` row; listings sold and bought re-point; payment receipts stay. asset-service has no JWT secret, so the admin check is auth-service `/me` with the caller's token. |
| #406 · tec-app #309 | kyc: the oldest keeps the most advanced record (VERIFIED > PENDING > REJECTED > NOT_STARTED, then level, then later update), swapped with a `KycAuditLog` row each. notification: inbox and devices move; settings only into an empty place. |

**Runtime (owner's phone):** yas55eR82 — 158 assets · 35 listings · KYC 1 · 506 notifications; the other nine
names — KYC 1 each for gzer0023 · magy888 · luckypat00 · zbieracz, a few notifications, nothing in assets.
The Founding 100 page is unchanged (it keys on the Pi username in identity-service): #1, 8 of 100.

## 4d. Who sent the π and who received it (10 Oct, late)

The owner's Pi wallet `GAKCH…PXFAX` showed the System 1π payment as **"Payment Received — From:
GAKCH…PXFAX"**: paid and received by the same wallet. He has created exactly one app wallet — the Hub's
(`GBXU6…MIQQ3R`, under Pi review); no other app has one.

| PR | What |
|---|---|
| tec-core-backend #407 · tec-app #310 | The Payment networks report reads each transaction's transfer operation (Horizon `/transactions/{hash}/operations`) and shows sender → receiver per payer, summed by route; `(same wallet)` when they match. |
| #408 · tec-app #311 | Horizon refuses a burst (429): 473 of 499 payments came back "chain did not answer". 429 / 5xx / timeout are now retried with a short wait; concurrency 8 → 4; 25 payments per request. |

**Runtime (owner's phone):** every **Mainnet** payment the chain answered for — `afa10fec` 5 · 17π,
`cbc4bb46` 77 · 323.2π — went `GAKCH…PXFAX → GAKCH…PXFAX`. **The real π of the owner's test purchases
never left his wallet.** Mainnet U2A payments of an app with no app wallet land in the developer's
wallet ([Assumed] — Pi's rule is not documented to us; the chain shows the result). **Testnet** payments
went from `GAKCH…` to many different addresses — each app's Test wallet.

Consequence: until each app has its own app wallet, a real customer's payment lands in the owner's
personal wallet. The seller-share model (#398) and withdrawals (#400) assume π held by the platform's
app wallet; they stay off until that wallet exists.

## 4e. Owed to sellers, and the app wallets (10 Oct, night)

| PR | What |
|---|---|
| tec-core-backend #409 · tec-app #312 | `/hub/admin/seller-liabilities`, read-only: **owed** = π in TEC balances (only sellers' shares since the void) + withdrawals not yet sent + sales not yet credited (`OWED`), next to the Hub app wallet's balance on the chain, and the difference to move in by hand. A part that cannot be read makes the total *incomplete*, never smaller (P6). Endpoints: wallet `GET /wallets/admin/liabilities`, commerce `GET /commerce/payouts/summary`, payment `GET /payments/admin/app-wallet`. |
| #410 · tec-app #313 | The same view reads every other app's Mainnet wallet from `PI_APP_WALLETS="app=G…,…"` (public addresses; never paid out from — their seeds are not on the server). |

**Runtime (owner's phone):** owed 0π; the Hub wallet reads **"the payout wallet (seed set)"** at
`GBXU6…MIQQ3R` — the seed on payment-service derives exactly the wallet under Pi review — and is
"not on the chain yet" (not approved, not funded).

**App wallets — the owner's decision (2026-10-10):** a wallet for each app where people sell to people,
because those payments are mostly owed to sellers — **Ecommerce first** (created:
`GA52Q4CNC6Z6AMP5GBPPEWNIK5F4FHYNUQG4CW545XSYZ4MHN6EJD364`, under Pi review), then Commerce and Assets.
Explorer and Life later: their payments are the platform's own revenue. Withdrawals are sent from the
Hub wallet only, so π is moved from the app wallets into it by hand, by the owner; no app-wallet seed
goes on a server.

## 5. Open at the end of the session

1. ~~Unbacked balances~~ — reversed (§4b).
2. ~~Merge duplicate accounts~~ — done in commerce · assets · kyc · notifications (§4c).
3. The Hub's Mainnet app wallet is again under Pi review (`GBXU6DHS…MIQQ3R`). On approval:
   `PI_A2U_WALLET_SEED` on payment-service, fund it, then `WITHDRAW_TO_PI_ALLOWLIST` on wallet-service.
4. An admin tool to resolve a pending withdrawal against Pi's incomplete list.
6. Set `PI_APP_WALLETS` on payment-service (Ecommerce now; Commerce and Assets as created).
5. Turn on `SELLER_BALANCE_CREDIT` after reviewing the OWED queue (mark own sales DIRECT).
