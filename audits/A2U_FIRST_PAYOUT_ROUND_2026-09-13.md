# The first time the platform tried to pay anybody, four things were wrong

**Date:** 2026-09-13
**Truth State:** [Current State]
**Governance State:** [Draft]
**Verification:** [Runtime Verified] — every defect below was read from a production
log, a Pi API response body, or a Horizon result code. Nothing is inferred from code
alone, and the one place I did infer, I was wrong (§7).

**Scope:** one payout round on Pi Testnet. Five recipients, five attempts, four distinct
defects, one transcription error of mine. Six merged PRs across two repos.

---

## 1 · The headline

The Pi Developer Portal would not grant the Mainnet App Wallet until the paired **Testnet**
app had sent App-to-User transfers to **five unique wallets**. That is a test of one
capability: *can this app pay people?*

It could not. Not on Testnet, and not on Mainnet either.

Four independent defects sat between the code and a completed payout, and **every one of
them was invisible until something actually tried to send money.** The platform had
shipped an A2U service, a campaign that advertises "claim real Pi" on the Hub's home
screen, and a reward payout path — none of which had ever moved a single Pi.

```
1. The app never asked users for the scope that lets it pay them   (tec-app #233)
2. One stuck payout blocks every later payout, app-wide            (#302)
3. The transaction fee came from the wrong network's constant      (#305)
4. Every failure threw away its own reason before reporting        (#302)
```

Defect 4 is why 1–3 took five attempts instead of one. It is listed last and it is the
one that cost the most time.

---

## 2 · `wallet_address` — the scope that was never asked for

Pi refused every create with:

```
401  missing_scope
User hasn't authorized "wallet_address" scope
```

`Pi.authenticate` asked for `['username', 'payments']`. Neither of those lets an app
learn where a user's wallet is, so Pi has nowhere to send to and refuses **before
anything is signed**.

### This was never only a Testnet problem

The Hub's home screen carries a reward campaign — *"Visit a few apps, claim real Pi"* —
paid through this exact A2U path. **It could never have paid a single person, on Mainnet
either**, and nothing would have said so until the first attempt.

A feature can be shipped, visible, advertised, and structurally incapable of working.
Nothing in CI, in review, or in the code tests for "this asks for the permission it
needs" — because permission is negotiated at runtime with a third party.

### The second half of the fix

Two call sites authenticate, and they are **coupled rather than merely similar**: after
login, `piSession.markAuthenticated()` suppresses the payment path's own authenticate,
*on the stated grounds that the scopes match*. Two lists that must be identical,
maintained separately, is how the next scope goes missing — and the failure mode is a
refusal from Pi with no local trace.

`src/lib-client/pi/scopes.ts` now holds the list and the reason; both call sites and the
pi-test page import it, and a test asserts no literal scope array remains.

### The cost, stated plainly

Every user now sees a wider consent prompt at login. That is a real cost. It buys the
ability to send them Pi, which the product already promises on its front page.
`wallet_address` lets the app **read** where to send; it grants no power over the user's
balance. **Existing users must sign in again** — Pi cannot widen a consent already given.

---

## 3 · One stuck payout stops the platform paying anybody

Pi allows an app **ONE open payment at a time — app-wide, not per user.**

The first recipient's payment was created, refused by the chain, and left open. The five
that followed were then refused a payment *they had nothing to do with*:

```
A2U payment created   identifier: bfmWF4Pl290eSNLpLFoFWVUXWbtg   (recipient 1)
A2U submit failed — no Pi has moved
A2U create failed     ongoing_payment_found
                      body.payment.identifier: bfmWF4Pl290eSNLpLFoFWVUXWbtg
```

**One failure produced six failure lines, and only the first was real.** Read quickly,
that is five broken recipients. It is one blocked queue.

Three changes, in the order they matter:

1. **Cancel on a chain rejection** — the payout releases its own payment when the submit
   fails, so the run degrades to "one person failed" instead of "the platform is stuck".
   Only when the CHAIN rejected it: `result_codes` exist only when the transaction was
   validated and not applied. A timeout leaves the outcome **unknown**, and cancelling
   then would claim a fact nobody has (P6).
2. **A way to release the ones already stranded** — one identifier at a time. There is
   deliberately no bulk cancel: cancelling a payout whose transfer *did* land destroys
   Pi's record of where the money went. Which payment is a decision, not a cleanup.
3. **The run stops instead of repeating itself** on `ongoing_payment_found`.

---

## 4 · The fee came from the wrong network's constant

```
tx_insufficient_fee
```

The transaction bid **`BASE_FEE`** — the Stellar SDK's 100 stroops, imported on the same
line as the `TransactionBuilder`.

**Pi is not Stellar.** It runs its own chain with its own minimum, and every payout was
refused for offering a fee from a different network entirely.

### Why it survived four rounds

It *looked* deliberate. A named constant, from the SDK, sitting in a fee field, doing
exactly what its name says.

> **A default imported alongside the thing that needs it is the hardest kind of wrong
> value to see: nobody chose it, so nobody re-examines it.**

That generalises past this file. Any value that arrives with a dependency — a base fee, a
timeout, a retry count, a page size — has never been a decision. It is worth asking, once,
whether it was ever right for *this* system.

### The fix

`fetchBaseFee()` — ask the network. It reports the minimum the last ledger accepted, which
is right by construction on either chain, and adds no dependency: `loadAccount` has
already talked to the same Horizon one line above. `PI_A2U_FEE` still wins when set.

And when Horizon will not say, it **refuses**. A fee is an amount of money. A guess either
fails again for the same reason or silently overpays on Mainnet.

---

## 5 · The failures threw away their own reasons

This is the defect that turned three bugs into five rounds.

**On create:** `logWarn('A2U create failed', { status, body })` captured Pi's own
classification — and the thrown error kept only the status. `missing_scope` sat in a log
the caller could not read, while the caller was told "HTTP 401".

**On submit:** `submitTransaction` throws an **axios** error, so `err.message` is always
`"Request failed with status code 400"` — a sentence that names the transport and says
nothing about the transfer. Horizon's verdict lives in `extras.result_codes`.

Both had the answer in hand and dropped it. Each failed round therefore cost a round trip
through the Railway log viewer to recover a sentence the error had already been given.

> **A diagnostic that cannot express the thing being diagnosed is worse than none: it is
> believed.** This platform has written that sentence before — the `network: mainnet`
> label on Testnet payments, recorded in `env.ts`. It recurred here in a different shape.

Both now carry the reason, bounded, and the two Horizon codes a first payout round
actually hits are translated into plain words — a bare `op_underfunded` sends the reader
to a search engine mid-incident.

Also fixed: the workflow's job summary used `| tee`, which captures stdout. Every failure
in the script is `console.error` — **stderr**. So the summary box was empty for exactly
the runs worth reading.

---

## 6 · What the diagnostics were worth

Round five reported `tx_insufficient_fee` and the fix took ten minutes. Rounds one to four
reported `400` and took hours.

**Nothing about the fee changed to make it findable.** The value was wrong from the first
attempt; only the error's ability to say so changed.

---

## 7 · My own error, and what saved it

Two rounds were spent on a theory that was wrong, and the theory was mine.

`GET /v2/payments/{id}` and `POST /v2/payments/{id}/cancel` both answered
`payment_not_found` for an identifier Pi had just printed in full while refusing the next
create. I concluded that app-created payments live in a namespace the single-payment
endpoints cannot reach, and built a listing endpoint on that reasoning.

The endpoints were fine. **I had transcribed the identifier from a log screenshot and read
a `0` as an `O`.** Same wrong id, twice, presented as two independent data points.

```
Pi:    bfmWF4Pl290eSNLpLFoFWVUXWbtg
Sent:  bfmWF4Pl29OeSNLpLFoFWVUXWbtg
                 ↑ eleventh character
```

Two things are worth keeping from that.

**One.** Three observations that are the same mistake repeated are one observation. I
counted them as corroboration and built an architecture on top.

**Two, and it is the useful one.** The listing printed **Pi's raw response**, unreshaped —
on the explicit grounds that reformatting an answer you are consulting *because you do not
understand its shape* is editing the evidence. That decision is the only reason the
character was visible at all. A summarised or prettified view would have normalised the
glyph and the round would still be running.

The listing was built for the wrong reason and earned its place immediately.

---

## 8 · The result

```
FAARSS876    GBEYUF7V…VE6   1.0000000
mord886      GDF2KWGI…736T  1.0000000
gzer0023     GCE4LOXY…4SYX  1.0000000
YAs5er2030   GBWCIM5P…EXSZ  1.0000000
magy888      GBDU4NPJ…4JZK  1.0000000

5 unique wallet(s) paid, of 5 the Portal wants.
```

Read off Horizon, not counted from successful calls — the Portal counts **wallets**, and
five payouts to one person count once. The verification step reads each txid back and
counts distinct destinations for exactly that reason.

Mainnet App Wallet application submitted the same night, as an Individual.

---

## 9 · The tooling, and why it is shaped this way

The scripts need Node, the internal secret and a route to the services. That is a laptop,
and the person who runs this works from a phone. So it is a `workflow_dispatch` button —
but one that moves money, and shaped by that:

| Guard | What it is for |
|---|---|
| Repository owner only | Anyone with write access can dispatch a workflow; not everyone should be able to send Pi |
| Explicit `step` | `preflight`, `list`, `dry-run`, `incomplete` send nothing, and are where the time is meant to go |
| `confirm: SEND` typed in capitals | A button that spends on one tap gets tapped by accident |
| `usernames` allowlist | `--since` and the duplicate signal are *heuristics*; a payout must not be addressed by inference, and the listing **fails** if a named person has no uid rather than quietly paying four |

Two boundaries held and are worth recording:

- **`pi_uid` is auth's column.** The payout service never reads that database
  (Forbidden Behavior #3). Auth answers *who has a uid*, payment answers *pay this uid*,
  and the hand-off between them is a file.
- **The payout goes over HTTP to the running service**, exactly as the campaign service
  calls it. Importing `sendA2uPayment` into a script would be a second, unreviewed way to
  move Pi — the thing the controller's own comment says must never exist.

### The honest weakness

The idempotency ledger is a file, and every CI run starts on a clean machine. It is
restored from the Actions cache, which is best-effort by design. **The cache is not the
protection** — `confirm: SEND` and the on-chain `verify` are.

---

## 10 · What a `uid` is, because it keeps being assumed

A Pi `uid` is scoped to **one Pi app**. The same person on the Mainnet Hub and on the
paired Testnet Hub has **two different uids**, and appears as two rows in auth with the
same username. There is no column recording which app a uid came from.

Consequences that cost time here:

- A username cannot be turned into a uid. Nobody can obtain a uid for somebody else —
  it exists only after that account authenticates with **that** app.
- Re-logging in does **not** create a new row (`upsert` on `pi_uid`), so `created_at`
  stays at the first login. A `--since` filter will never find an older account's
  Testnet row.
- Paying a Mainnet uid on the Testnet app returns `user_not_found`. Expected, and it
  appeared in the final successful run as one red line among five green ones.

---

## 11 · Merged this session

| Repo | PR | What |
|---|---|---|
| tec-app | #233 | `wallet_address` scope + one shared scope list |
| tec-core-backend | #298 | Payout tooling: the two scripts and the limits preflight |
| tec-core-backend | #299 | The script could only run from inside Railway |
| tec-core-backend | #300 | The button (`workflow_dispatch`) |
| tec-core-backend | #301 | Naming the Railway url that cannot work from CI |
| tec-core-backend | #302 | Errors carry their reason · cancel-on-rejection · stop when blocked |
| tec-core-backend | #303 | An open payout is finished, not cancelled |
| tec-core-backend | #304 | Ask Pi what it is holding · stderr reaches the summary |
| tec-core-backend | #305 | The fee is asked of the network |

---

## 12 · Open after this session

- **The Mainnet App Wallet application is under review.** `Connected Outgoing Wallet:
  None` until Pi answers.
- **`resume` still takes a hand-typed identifier.** It should take the one open payment
  from Pi's own list — the transcription error in §7 is a step that should not exist.
- **`PI_A2U_FEE` is unset**, so every payout now costs one extra Horizon round trip to
  read the fee. Correct, and worth revisiting if payout volume ever makes it matter.
- **The `wallet_address` re-consent has not reached Mainnet users.** Until they sign in
  again, the reward campaign still cannot pay them — the fix is deployed, the consent is
  not collected.

---

## Related Documents

- `C-47_Kernel_Spec_Architecture_Binding.md` — P6 fail closed (the cancel-only-on-
  definite-rejection rule, and refusing to guess a fee); Forbidden Behavior #3 (the
  auth/payment database boundary in §9); Forbidden Behavior #6, silent failure in
  financial flows — §5 is that, in a form that passed review
- `C-96___PLATFORM_RUNTIME_CONSTITUTION.md` — no silent failure; a failure with no
  alternative path must name itself. §5 is the same principle applied to an error's
  own message rather than to a route
- `C-71___FINANCIAL_INTEGRITY_SPEC.md` — Invariant #8: `tec-payment-service` is the only
  Pi custodian, which is why there is one payout wallet and not one per app
- `C-133___PLATFORM_ADOPTION_GROWTH_GOVERNANCE.md` — campaign governance. §5.2 states the
  rule that a *referral* reward is a gift subscription month and never raw Pi, precisely
  because only `payment-service` custodies Pi. The Hub's visit-apps campaign is the one
  surface that does send raw Pi, and §2 above is the defect that silently disabled it
- `C-123___PI_BROWSER_SESSION_COOKIE_SPEC.md` — the other place where a Pi runtime
  behaviour had to be learned from production rather than documentation
- `audits/PI_TESTNET_HOST_OWNERSHIP_2026-09-12.md` — §11 scoped this work; this document
  is what happened when it ran
