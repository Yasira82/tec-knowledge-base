# SESSION 56 — the first time the platform tried to pay anybody, four things were wrong

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

Full engineering record: `audits/A2U_FIRST_PAYOUT_ROUND_2026-09-13.md`.

Session 55 left one thing outstanding, and it was not an engineering task: five distinct
Pi accounts had to sign into the paired **Testnet** Hub so the app would have five `uid`s
to pay. Five people did. Then the payouts ran — and **every one of the five attempts
failed, for a different reason each round.**

### The gate is closed

```
FAARSS876  ·  mord886  ·  gzer0023  ·  YAs5er2030  ·  magy888
5 unique wallet(s) paid, of 5 the Portal wants.
```

Counted off **Horizon**, not off successful API calls — the Portal counts *wallets*, and
five payouts to one person count once. Mainnet App Wallet applied for the same night, as
an Individual; `Connected Outgoing Wallet: None` until Pi answers.

### The four defects, each found only by trying

| # | Defect | Why nothing caught it |
|---|--------|-----------------------|
| 1 | `Pi.authenticate` asked for `['username','payments']`. **`wallet_address` was never requested**, so Pi refuses every create with `401 missing_scope` before anything is signed. | Permission is negotiated at runtime with a third party. No test, lint or review asks "does this request the permission it needs?" |
| 2 | Pi allows **one open server payment per APP**, not per user. One payout left hanging blocked every other payout the platform could make. | A single-recipient test never produces a second recipient to be blocked. |
| 3 | The transaction fee came from Stellar's `BASE_FEE` constant (100 stroops). **Pi is not Stellar** → `tx_insufficient_fee`. | Only visible in Horizon's `extras.result_codes`, which the error handling was discarding — see 4. |
| 4 | Failures threw away their own reasons: Pi's `error_message` and Horizon's `result_codes` never reached the log or the caller. | A generic message is not a failing test. It reviews fine. |

> **The one worth carrying past this session is #1.** The Hub's home screen advertises a
> reward campaign — *"visit a few apps, claim real Pi"* — paid through this exact path.
> **It could never have paid a single person, on Mainnet either.** A feature can be
> shipped, visible, advertised, and structurally incapable of working, and nothing says
> so until the first real attempt. Three of the four defects would have waited for the
> first real reward on Mainnet to announce themselves.

### And one error of mine

I read a payment identifier off a screenshot and transcribed a `0` as an `O`. Pi answered
`payment not found`, and I built an architectural theory on it — *"app payments live in a
different namespace"* — which cost two rounds and two PRs. What ended it was making the
tooling print **Pi's own raw response, unreshaped**: the correct identifier was in it. The
audit records this as §7 rather than quietly dropping it, because the fix is structural —
`resume` should take the identifier from Pi's list, not from a person's eyes.

### The tooling is a button, because the CEO works from a phone

`workflow_dispatch` in `tec-core-backend`, with four guards, because it moves money:
owner-only · an explicit `step` (`preflight`/`list`/`dry-run`/`incomplete` send nothing) ·
`confirm: SEND` typed in capitals · and `usernames` as an explicit allowlist that **fails**
when a named person has no uid rather than quietly paying four. Two boundaries held:
`pi_uid` is read by auth's own script (Forbidden Behavior #3), and the payout goes over
HTTP to the running service — never by importing `sendA2uPayment` into a script, which
would be a second unreviewed way to move Pi.

**Merged:** tec-app **#233** · tec-core-backend **#298 · #299 · #300 · #301 · #302 ·
#303 · #304 · #305**. **Open:** tec-core-backend **#306** · tec-app **#234**.

### The follow-up, same day — and the check that could not be built

Both remaining code items were taken immediately. **tec-core-backend #306 · tec-app #234**
(open at time of writing). Audit §13.

**`resume` reads the id from Pi's own listing.** The step that produced the transcription
error no longer exists. The design decision worth keeping: the extractor returns `null`
for a shape it does not recognise and `[]` only for a shape it does — collapsing those two
would let an unfamiliar answer read as *"nothing is open"*, the exact state a blocked queue
must never be mistaken for.

**The planned claim-time scope check was abandoned, on evidence.** Reading the code first
showed that **nothing records what Pi granted** — auth keeps `uid` and `username` from
`/v2/me` and no column holds a scope. Gating on a field whose presence had not been
verified would have been the §7 mistake again, in a place where it decides whether a
person gets paid.

Reading further found something certain, and worse:

> A payout refused by Pi threw a sentence at whichever admin tapped the button, and then
> it was gone. Nothing on the row, nothing on the claimant's screen — a seat that never
> moved, under the words *"a person sends the Pi by hand, so this is not instant."*

True, and for everyone who signed in before 13 Sep, misleading: the wait has no end unless
they act. **Forbidden Behavior #6 — silent failure in a financial flow — in a form that had
passed review.** Now Pi's own reason is written onto the claim, translated into one
instruction the person can act on (and **null** for anything they cannot — a failure notice
with no action just makes someone think they did something wrong), shown only from a note
the service wrote so an admin's rejection wording can never reach the person it is about,
and the Hub renders it above the reassurance rather than under it.

> **The generalisable half:** the check that was planned could not be built on evidence,
> and the check that could be built was better — it fires on Pi's **actual refusal**
> instead of on a prediction of one, so it needs no assumption about a field nobody has
> seen.

Also moved earlier: `claim()` refuses someone with no Pi identity on record. Pi pays a uid,
so that claim could never be addressed — caught at payout time it cost a person a seat and
a silent wait.

### Open after this session

- **Mainnet App Wallet under review** — nothing to do but wait for Pi.
- **The `wallet_address` re-consent is still uncollected.** The platform now *asks* for it
  (above), but a consent is a fact about people, not about code. Until each user signs in
  again the campaign cannot pay them, and Pi cannot widen a consent already given.
- **`PI_A2U_FEE` is unset**, so every payout costs one extra Horizon round trip to ask
  the network its fee. Correct, and only worth revisiting at volume.
