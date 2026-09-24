# Session 56o — the campaign paid a real pioneer, and the chain agreed

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

The previous session closed with *"the next question is what gets the first real user."*
This one answered a smaller version of it: **the reward campaign ran end to end, on
Mainnet, and the payout was verified against the chain.** Seat #1 of 100 is taken and
paid. The claimant was the CEO testing his own flow — which is the honest description,
and it is also how three defects were found before a stranger met them.

### 1. The campaign page spoke only English, on the one screen that asks for trust

The Hub card advertising the campaign is translated. The page it opens was not. A
pioneer who reads Arabic tapped an Arabic card and met a wall of English on the screen
where they decide whether a stranger offering free Pi is real.

~47 strings moved into `hub.campaignPage` (`en.ts` + `ar.ts`); the page reads them via
`useTranslation()` with `dir`. Two dead ends went with it: a subtitle that could render
`undefined π · undefined of undefined seats left` before the status loaded, and a
signed-out state that said sign-in was required while offering nothing to tap (now a
real button that remembers `/hub/campaign` through `rememberReturn`). tec-app #240.

> **The anti-phishing warning was the sharpest case.** *"We will never ask for your
> passphrase or secret key"* existed in English only. **A guarantee that reaches one
> audience is not a guarantee.** Every copy assertion in `campaign-ui.test.ts` now checks
> BOTH locales for exactly that reason.

### 2. A test that could not fail, and the real defect underneath it

`campaign-ui.test.ts` pinned the warning's position with `page.indexOf('never')`. That
matched a **source comment on line 17** and therefore passed no matter where the warning
sat. Moving the copy to the locale files forced the anchor to become real (`c.neverAsk1`)
— and it failed.

The warning was down beside the claim, while the **Connection mission above it** is the
thing that says *"post your Pi wallet address there."* **The warning was arriving after
the moment it exists to protect.** It now sits above the missions, read first by everyone
the round is open to rather than only by whoever already finished the list.

> A test whose anchor can match a comment is not a weak test. It is a test that reports
> success for a property nobody has checked — which is worse than not having one.

### 3. The address had exactly one route in, and it was a dead end

The Connection mission's bar was *"posted a valid Pi address in the TEC group"*, because
the group was the only way the campaign could learn one. That turned a chat mission into
an address form with extra steps: somebody who joined the group, used it as asked, and
did not paste 56 characters into it finished every mission and was then refused, with
nothing on screen to do about it. **The CEO hit this himself at 7/8.**

Two changes (tec-core-backend #326 · tec-app #240):

| | |
|---|---|
| **The mission** | now asks for a MESSAGE, not an address. A tab that opened is still not enough — that half is unchanged. One query (`groupMessages`) behind both bars so "a message that counts" cannot mean two things. |
| **The claim** | takes a typed address as a FALLBACK. The group still wins when both exist — it was written in public under their own name, where a wrong one is visible. Both get the same checksum. |

**Why a typed address became acceptable again, stated exactly rather than dropped
quietly.** The group was made the only route when the address was also the payout
destination, and a request that could name where real Pi goes is the one thing a payout
path must never accept (P6). **That reasoning expired: A2U pays a Pi UID and Pi resolves
the wallet itself** — in `sendPayout` the recipient comes back FROM Pi and the caller
never supplies a destination. An address in the request cannot redirect a single π. P6 is
intact; the thing it protected moved.

**Why not drop the field entirely, since Pi does not need it.** Because of what having
one MEANS: a Pi account is KYC-verified or it has no wallet at all, so an address is the
evidence that a claimant is a distinct verified person rather than one of five accounts.
`wallet_address @unique` is the campaign's real anti-sybil rule. Nothing else available
says that.

A third copy fix followed from the second: the mission had promised *"That is where we
send the reward"* — never literally true, and with a second route it stopped being true
in the ordinary sense too.

### 4. Runtime Verified — the whole path, including the chain lookup

Seat #1, 1 π, sent by hand from the CEO's wallet to the address on the claim, hash pasted
into `Mark sent`:

```
identity-service → payment-service → Horizon (Pi Mainnet)
    the hash names a successful transaction?   ✅
    paid to the address on THIS claim?         ✅
    for at least the amount owed?              ✅
    hash already recorded on another seat?     ❌
```

It passed, and the claimant's own screen now carries `tx: 38d2d088…`. **This is the first
time the payout path has been exercised against the real chain** — `markPaid`'s
`verifyTransfer` had never run in production before.

**A2U remains unconfigured, deliberately.** `PI_A2U_WALLET_SEED` is unset because the
app wallet is still pending from Pi, so the gold "Send now" is disabled and the screen
says why, in the service's own words, with the green `Mark sent` promoted in its place.
Nothing was faked to make a button look alive.

> **Do not `unpaid` seat #1.** The π moved on chain. Retracting the record would make it
> disagree with the chain — the one thing this ledger exists to prevent.

### 5. Open after this session

| # | Item | Note |
|---|------|------|
| 1 | `CAMPAIGN_APPS` → all 24 | Env var + restart on `tec-identity-service`. The round ran on 8. |
| 2 | **The payout queue shows no evidence of qualification** | Found by the CEO while looking at his own claim. `listClaims` returns the raw row — seat, owner, amount, address — and nothing about WHY the reward is owed. The service genuinely enforces it (`claim()` refuses with `Still to visit: …`), but "the service checked" is not the same as "I can see the check", and it will not be the same at fifty claims. **The fix must record the evidence AT CLAIM TIME, not re-derive it**: raising `CAMPAIGN_APPS` from 8 to 24 would make an already-qualified claim render as "7 of 24" and look unearned. Needs an additive nullable column. |
| 3 | A2U wallet | Pending from Pi. When it arrives, set the seed — no code changes. |
