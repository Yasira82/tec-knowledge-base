# Session 56l — one line was the whole Testnet failure, and six apps were taking Pi for nothing

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

Two findings. The first is a diagnosis method that cost most of a session by being
skipped; the second is money that was moving and granting nothing on Mainnet.

### 1. `ssoRedirect` returned to the Mainnet domain — NBF and Brookfield only

```ts
ssoRedirect(HUB_URL, `${APP_URL}/app`);     // APP_URL = the MAINNET domain
```

Signing in on the paired Testnet host asked the Hub to return the user to the
**canonical** domain. The Hub obliged, and from that redirect on the visitor was on
Mainnet while the address bar and their intent said Testnet. Every symptom followed
from that single fact:

| symptom | why |
|---|---|
| "★ You're on Pro" on the Testnet host | the subscription BFF gates on **its own Host header**; on the Mainnet host the Testnet gate never fires, so a real Mainnet subscription showed through |
| `source.testnet: false · network: mainnet` in payment-service | the payment genuinely WAS created on Mainnet |
| `Signing in to Pi…` hanging · `Pi auth (TIMEOUT)` | a **Test-Pi wallet cannot pay a Mainnet payment**, and Pi's bridge does not reject — it never answers |
| 6 payments `cancelled (never reached Pi)` | created, then unpayable |

**The fleet already had the fix.** A sweep of the `ssoRedirect` call in all 20 app
repos: **18 read `window.location.origin`**; only NBF and Brookfield carried the
constant. Both were built separately and never received it — the same shape as the
`^1.1.0` caret trap and the Dependabot config (Session 46): a rule the fleet has that
two repos never got.

> **The method lesson, and it is the expensive one.** Each symptom above was
> investigated as its own bug — the SDK, the API key, an unfinished payment, the error
> messages — and each cost the owner a merge, a deploy and a retest. **The sweep that
> found the cause took thirty seconds and should have been the first action, not the
> last.** When an app fails and it has working siblings, diff it against one before
> investigating anything. A fleet of working implementations is the cheapest oracle on
> the platform and it was sitting there the whole time.

Also fixed in those two while there: the Pi init script was a **SyntaxError** (the
sandbox `var` block pasted INSIDE `Pi.init({…})`), so the whole inline script failed to
parse, `__TEC_PI_READY` was never set, and the ADR-007 guard silently diverted every
purchase to the Hub — "it works, but from the wrong app". Verified by parsing the
generated script (`new Function`), then swept all 24 apps: these two were the only ones.

### 2. Six apps were taking real Pi on Mainnet and granting nothing

`planFromPaymentMetadata` resolves the plan with `/_pro(_(monthly|yearly))?$/` — it
requires an **underscore**. Audited every app's `item_id` on `main`:

| app | item_id | π | outcome |
|---|---|---|---|
| Epic · Insure · Legend | `<slug>-pro` ← hyphen | 10 | **DROPPED** — no plan resolved |
| NBF · Brookfield | `<slug>-pro` ← hyphen | 25 | **DROPPED** (fixed + merged) |
| Titan | `titan_enterprise_monthly` | 25 | **REJECTED** — below the 50π ENTERPRISE floor |
| VIP | `vip-standard` | 50 | **DROPPED** — matches nothing |
| Elite | `elite-certificate` | 5 | not a subscription — see below |
| the other 10 | `<slug>_pro_monthly` | — | ✅ activating |

All the hyphen cases are now merged. **Zone and Life were always correct**, which is
why they were the reference throughout.

> A Testnet test cannot detect this class of bug. The consumer returns at
> `if (!plan)` before it reaches `if (metadata.testnet)`, so a broken id and a correct
> one produce the **identical** Testnet outcome — both ignored, by different doors. Only
> a Mainnet purchase by an account that is not already Pro would show it. Running the
> real resolver over both payloads answers it for free, and that is what settled it.

### 3. ENTERPRISE is a label with no mechanism — so Titan maps to PRO

Titan charged 25π while claiming ENTERPRISE, whose activation floor is 50π, so every
purchase was rejected and recorded `PAST_DUE`. **Raising the price to 50π would have
cleared the floor and been the wrong fix.**

Nothing on this platform enforces ENTERPRISE. Every app reads
`plan === 'PRO' || plan === 'ENTERPRISE'` into **one boolean**; no service branches on
the tier. The capabilities listed against ENTERPRISE (custom domain · API access ·
white-label) are display strings in `PLANS` with no mechanism behind them. ENTERPRISE
therefore costs 50π and delivers what PRO delivers for 5π.

**Selling a tier the platform cannot enforce is the same failure as selling one that
never activates** — the buyer pays and receives nothing promised; only the shape of the
nothing differs. Titan now sends `titan_pro_monthly` at an unchanged 25π; "Titan
Enterprise" stays the product name on screen, which is this app's own tier and not the
platform plan. ENTERPRISE becomes sellable when per-tier capability gating exists
(SYSTEM owns the capability→tier map, C-110 P0-1) — an ADR, not a rename.

### Open, with reasons — decided deliberately, not overlooked

| # | item | why it is open |
|---|---|---|
| 1 | **VIP** — `vip-standard`, 50π, resolves to nothing | Naming the **entry** tier (STANDARD→PARTNER) `_enterprise` is wrong, so the key should become `vip_pro_monthly`. But the price is the real question: **50π buys the same PRO entitlement Life sells for 5π**, and C-128's premise — VIP grants eligibility, owning apps enforce the value (P5) — is not yet honoured by any owning app. Pricing is the CEO's call; recording it rather than quietly shipping a tenfold price for an identical entitlement. |
| 2 | **Elite** — `elite-certificate`, 5π, **has no fulfilment at all** | Commerce ignoring it is CORRECT: a certificate is not a subscription, and C-127 forbids selling recognition. The defect is elsewhere — there is **no issuance, no download, no record, no backend** anywhere in the repo. The buyer pays 5π and receives a status line. This is not a regex bug to patch; it is a buy button in front of an unbuilt product. Two honest paths: stop the button, or build the issuance. |
| 3 | **The Testnet checklist** (Portal "Process a Transaction") | Epic completed a real Test-Pi payment this session, so the path works. NBF/Brookfield now have the SSO fix and should follow. Not blocking revenue: all 24 apps are live on Mainnet. |

### Removed: the Renew button (NBF · Brookfield)

Added earlier this session so a Portal payment could be made while the card showed Pro
— the subscription row is ONE PER USER platform-wide (`user_id String @unique`, no app
column), so buying Pro in any sibling app lights the card in all 24 and leaves an app
with no payment surface of its own. **Reverted**: no other app has such a button, and
Zone passed the same Portal step the ordinary way — by paying while still on FREE. The
sequence is what matters, not an extra control. Trading fleet consistency for one
checklist step is the wrong trade, and fleet consistency is exactly what this platform
keeps losing by letting one repo solve something its own way.
