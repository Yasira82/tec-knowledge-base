# Hub app grid: a visit opened from the Hub does not count at Pi

**PLACEHOLDER: no `C-NN` assigned.** Numbering is a human decision (`.cursorrules` RULE 6).

**Date:** 2026-09-29

**Truth State:**
- §1 is `[Current State]`.
- §2–§3 are `[Planned State]`, a proposal the owner has not yet approved.

**Governance State:** `[Draft]`. It touches the Hub-entry path, a shared ADR-007 concern (C-76).

**Verification:** `[Code Verified]`, on `tec-app` main and a template app's main (Tec-Zone). Pi's counting rule is inferred from its own claim screen ("5 unique KYC'd Pioneers engage") and from the 29 Sep claims. Pi does not document it.

---

## 1 · What happens today `[Code Verified]`

1. **The grid links to SSO.** A Hub grid tile links to `/api/auth/sso?target=<app>` (`tec-frontend/src/app/hub/page.tsx`), which redirects to the app's `/api/auth/sso-callback`.
2. **The app marks the tab as Hub-entered.** The callback page sees a Hub referrer and sets `sessionStorage.__tec_hub_entry = '1'` (for example, `Tec-Zone/src/app/api/auth/sso-callback/route.ts`).
3. **The layout skips the Pi SDK.** It reads that flag and sets `__TEC_PI_FOREIGN_SESSION`, so the Pi SDK is not initialised. ADR-007 requires this: in a Hub-owned Pi session `Pi.authenticate()` never answers and poisons the Hub's payment modal.
4. **The app never signs the visitor in with Pi.** Every app's visit sign-in (template `PiWarmup`; Commerce · Ecommerce · Assets `PiVisitSignIn` since #73 · #70 · #66) skips a foreign session. The flag lasts for the tab, so later pages in that visit are skipped too.

**Consequence.** A visit opened from the Hub grid is, at Pi, engagement with the **Hub**, not with the app. It never counts toward the app's `.pi` claim ("5 unique KYC'd Pioneers engage").

**It also inflates our own coverage.** `ArrivalReport` still fires on such a visit, which is a second reason `hub/admin/pioneers` reads higher than Pi does (C-02 row 2).

**What does count.** The campaign's mission links open each app **standalone**: a signed one-time link straight to the app's own `sso-callback`, with `rel="noreferrer"` (`useHandoffLinks`, C-123 §12, since 2026-09-26). No Hub referrer means no flag, so the app signs the visitor in and Pi counts it.

**Interim instruction to participants:** open apps from the campaign page, not from the Hub grid.

---

## 2 · Proposal: open grid apps the way the campaign does

The Hub grid would use the same signed handoff links, in a new tab, as the campaign page.

- **Change scope:** only `tec-app`. None of the 24 apps changes.
- **Effect:** the app opens standalone, signs the visitor in with Pi, and Pi counts the visit.
- **A side benefit:** the Hub tab stays open behind the app. Coming back is closing a tab, not a Back navigation that can reopen the Hub without its cookies. That navigation caused the grey skeleton that tec-app #264 bounded.

---

## 3 · What it changes for payments

| | Opened from the Hub grid today | After the change |
|---|---|---|
| Payment inside the app | **Mode 1**: redirected to the Hub's modal (`/hub?pay=1`) | **Mode 2**: paid inside the app with the Pi wallet |
| Where the π lands | the **Hub's** side (the Hub creates the payment) | the **app's** side. **Which wallet that is is not verified (below)** |
| Fallback | — | if Pi is not ready in the app, it falls back to Mode 1 (existing code in every buy handler) |

- **The Hub's own payments do not change.** Subscriptions and `/hub?pay=1` are untouched, because the Hub tab and its Pi session stay as they are.
- **Correction (owner, 2026-10-02): no TEC app has a Mainnet app wallet.** The first draft said every app had one, because "Pi does not let an app receive a U2A payment without its own app wallet". That was `[Assumed]`, and it was wrong. **The only Mainnet app wallet** is the Hub's, and it is still under Pi's review (the A2U wallet, C-02 row 6). Every payment so far was paid from the buyer's own Pi wallet.
- **Open: where a Mode 2 payment's π lands today.** It has to land somewhere: Ecommerce's Sales shows 65π from completed Mode 2 orders. **How to settle it:**
  1. Open one completed app payment in the payer's Pi Wallet history (for example the 12π Ecommerce order of 2026-10-02 09:08), or its txid in the Pi Block Explorer.
  2. Read the recipient address.
  3. Compare it with a Hub payment's recipient.
  
  Until then, this proposal's revenue effect is unknown.
- **Mode 2 itself works.** All 24 apps passed Pi's "Process a Transaction" step on Mainnet with a real Mode 2 payment, and `PI_API_KEY_<APP>` is set on payment-service for each. Mode 2 is what every standalone visit uses: the campaign page, and Pi Browser's own app list.
- **No wallet is created or changed by this proposal.** The owner's rule stands: no new app wallet without asking.
- **What changes is the revenue split.** π paid by grid visitors goes to the app's side rather than the Hub's. Where that is exactly is the open question above.
- **A2U is unaffected.** Campaign reward payouts use a separate wallet (C-02 row 6).

**Risk.** An app whose Mode 2 has silently broken would now be met by Hub-grid visitors instead of being masked by the Hub's modal. **Mitigation:** after the change, run one small test payment in two or three apps opened from the grid.

---

## 4 · Open decision (owner)

Should the Hub grid switch to standalone handoff links? The revenue split in §3 is the trade-off to accept. **It waits on the recipient check in §3**, because the trade-off cannot be judged before anyone knows where the π goes.

---

## Related Documents

- `C-76___ADR-007.md`: Pi foreign session; why a Hub-entered app must not call `Pi.authenticate`
- `C-12_Dual_Mode_Payment.md`: Mode 1 / Mode 2
- `C-123___PI_BROWSER_SESSION_COOKIE_SPEC.md` §12: the signed handoff links the campaign uses
- `audits/ANALYTICS_PI_NETWORK_PULSE_2026-09-29.md`: the same day's Analytics work
