# SESSION 52 — the Pioneer campaign has a commercial objective, and it was not written down

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

**The finding, and it reframes the campaign:** Pi will not accept a `.pi` domain claim
until the connected app has **"at least 5 unique KYC'd approved Pioneers engage with the
app"**. Twenty-four `.pi` domains were **won at auction and paid for** (vip.pi 2.8K π ·
nexus.pi and explorer.pi 1.4K π each · commerce.pi 999 π · estate.pi 750 π …), and
**`tec.pi` is the only claim accepted** — every other app returns *"Requirements Not Met"*.

So the Founding badge and the PRO gift are **incentives**, not the objective. The
objective is 5 verified pioneers × 24 apps, before the domains lapse. Recorded in full as
**C-134 §20** (it also closes §19 Open Question 2, from outside).

> This was rediscovered from a phone screenshot, not from the KB — the exact failure mode
> C-95 exists to prevent. The campaign had been engineered for two sessions without its
> own purpose written anywhere.

**Shipped this session (all merged unless noted):**

| # | What | Where |
|---|------|-------|
| 1 | **The Quest was forgeable.** `app` was any string ≤40 chars, so 24 POSTs of `'a'..'x'` earned a permanent Founding number in seconds. Closed by a campaign-owned roster; `QUEST_TARGET` is now its length, not a literal. | tec-core-backend #274 · tec-app #192 |
| 2 | **Audited campaign reset** (admin token + confirmation phrase, audits before it deletes) — Founding numbers are non-recyclable by design, so test runs permanently consume advertised places. Also removed a seeded demo pioneer that the public counter was serving as real. | tec-core-backend #274 |
| 3 | **Founding gift = 6 months PRO, not Pi.** PRO is unsellable, which collapses the incentive to farm the badge, and it reuses the referral grant rule rather than adding a second one. ⚠️ **The reason originally recorded here — "payment-service speaks only the U2A half; there is no A2U path, so Pi cannot be paid out at all" — is NO LONGER TRUE** (see the correction below). The decision still stands on its own merits; the justification does not. | tec-core-backend **#275 — open** |
| 4 | **Per-app coverage** (`GET /identity/pioneer/coverage`, admin) — which apps are still short of 5 verified pioneers, and by how many. | tec-core-backend **#275 — open** |
| 5 | **Feedback inbox** — a form in `/hub/profile` and an admin reader at `/hub/admin/feedback`; the table had no reader before. Runtime-verified, including a message from a real external user. | tec-core-backend #273 · tec-app #191 |

**Three comments in `pioneer.service.ts` claimed a KYC gate the code never had.** The code
was right and the sentences were wrong. There is deliberately **no KYC gate**: Pi has
already verified the account, and asking a first-time visitor for documents to earn a badge
reads as a scam.

**Honest limits, recorded rather than smoothed over:**
- `coverage` counts **TEC's** KYC register; Pi checks its own, which this platform cannot
  read. Below the threshold is reliable; at or above it is **not** a confirmation from Pi.
- Pi counts *engagement*; the Quest records an *open*. Closing that gap is the highest-value
  unbuilt work (C-134 §20.6) — a completed Pi **Mainnet** payment is the strongest available
  proxy for Pi KYC and is currently unused.
- **5 Founding places are already consumed by test runs**, and 2 of the 10 pioneers came
  from a real Reddit link — so a reset is not obviously free. Decide before launch.
