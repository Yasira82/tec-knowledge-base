# CORRECTION — A2U EXISTS. Two recorded reasons for not building it are stale.

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **historical record**, not current state — for current state read C-02.

Found while reviewing "the A2U plan" on request. There is no plan to review: **the
payout path is built, merged and wired.** Two documents say otherwise, and one of them
was used as the justification for a product decision.

### 1. C-02 said there is no A2U path. There is.

| | |
|---|---|
| `tec-payment-service/src/services/pi-a2u.ts` | create → **sign + submit on Stellar** → complete |
| `controllers/a2u.controller.ts` | `POST /payment/internal/a2u` · `GET /payment/internal/a2u/limits` |
| `routes/payment.routes.ts` | both mounted behind `validateInternalKey` |
| `__tests__/pi-a2u.test.ts` | covered |
| Consumer | the Pioneer campaign — self-withdrawal, payout queue, **and a chain lookup before a payout is recorded as paid** |

It is not a sketch. The bounds are written as reasons, not decoration:

1. **One dedicated wallet** (`PI_A2U_WALLET_SEED`) holding only what payouts need — explicitly *not* the wallet that holds the platform's Pi.
2. **A hard per-payment ceiling** (`PI_A2U_MAX_PI`, default 10 π), enforced **inside the code that signs** — not by the caller, because the caller is the thing that might be wrong.
3. **Idempotent by the caller's own key**, so a retry that already sent cannot pay twice.
4. **Never silent**, and the `txid` is returned even when `complete` fails — the chain is the truth, and a failed bookkeeping call must never look like a failed payment.

> **This is a custody change, not a feature.** To sign an outgoing transfer the service
> must hold the app wallet's PRIVATE SEED. Every other flow in that service moves Pi a
> user authorised, holding no key that can spend. A2U is the first time the platform
> holds one (C-71 · Invariant #8).

### 2. The Portal audit's "why it has not simply been done" is stale

`audits/PI_PORTAL_TESTNET_GATING_2026-09-06.md` §3 records the blocker as
`tec-payment-service` choosing the Pi network **globally** from `PI_SANDBOX`, so a
Testnet payment could not be approved without taking every live payment down.

**That was fixed** — the network is now chosen **per payment**, from the target that also
picks the key (tec-core-backend #290 · #291). The constraint that paragraph describes no
longer exists.

### 3. What IS still blocking — and it is not code

Pi grants a **Mainnet App Wallet** only after **5 A2U payouts to 5 distinct Pi accounts**
from the paired **Testnet** app's wallet. A2U pays by `uid`, and a `uid` for an app only
exists once that account has **authenticated with that app**. So it needs **four other
people** to open the Testnet app. No amount of engineering removes that.

### Why this correction matters more than the two lines

The stale sentence was not inert — it was **used**. The Founding gift was made PRO
instead of Pi *because* "Pi cannot be paid out at all". The decision still stands on its
own merits (PRO is unsellable, so it cannot be farmed), but it was taken for a reason
that was already false. That is precisely the failure C-95 exists to prevent: a document
that lags the code does not sit quietly, it gets built on.
