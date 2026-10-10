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

## 5. Open at the end of the session

1. Read `/hub/admin/payment-networks` for magy888, `f2e3de66`, `gateway`, `current` and the owner's
   accounts; then the owner decides what happens to unbacked balances (proposal: reverse each with
   its own ledger row + audit, dry run first — a tool, never hand SQL).
2. Merge the duplicate accounts' references (products, payouts, subscriptions) into the oldest.
3. The Hub's Mainnet app wallet is again under Pi review (`GBXU6DHS…MIQQ3R`). On approval:
   `PI_A2U_WALLET_SEED` on payment-service, fund it, then `WITHDRAW_TO_PI_ALLOWLIST` on wallet-service.
4. An admin tool to resolve a pending withdrawal against Pi's incomplete list.
5. Turn on `SELLER_BALANCE_CREDIT` after reviewing the OWED queue (mark own sales DIRECT).
