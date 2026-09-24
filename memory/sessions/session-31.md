# SESSION 31 — MERCHANT INTELLIGENCE (Analytics → the broader Pi community) (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open) — becomes `[Runtime Verified]` after the Vercel redeploy. Answers the strategic question "how does Analytics serve Pi merchants OUTSIDE TEC?" — the first step: give any Pi merchant real insight into their own business.

### The strategic frame (a deliberate NO to price charts)
The user asked whether Analytics could serve the wider Pi community — e.g. "analyze a coin
price chart." **Recorded decision: NO to market/price charts** (for now). A price/market
chart is (1) **not our data** — market price is owned by external exchanges, not
payment-service; presenting it as truth breaks C-105; (2) **legal risk** — a price chart
with any trend/buy signal reads as financial advice (same reason FundX/Insure/Estate are
hard-gated); (3) accuracy liability. If ever built, it must be an *external, clearly-labelled
indicative source* with **no buy/sell signal** — a separate governed decision, not a feature.

**The right first step (shipped): Merchant Intelligence** — Analytics' CORE value ("understand
your own activity") surfaced for **any Pi merchant**, from OUR real data, fully within the
constitution.

### What it is (C-105 §6 own-scope — same truth, real insight)
A dashboard computed **only from the caller's own event log**:
- **When you're busiest** — UTC peak hour + a 24-bucket hour-of-day histogram.
- **The trend** — week-over-week change (▲/▼ %).
- **Daily activity** — a zero-gap-filled sparkline.
- **Activity mix** — top event types as % bars.

Never cross-merchant, never financial truth (the owning services own the money). No new
disclosure surface — own-scope + fail-closed, same rule as `me/overview` / `me/activity`.

### Freemium (draws the community in, then Pro depth)
FREE merchants get the full intelligence on a **14-day** window (real value → a reason to
show up); **Merchant Pro** widens it to **90 days** + the CSV export (Session 30) — *same
trusted numbers, more depth*. Window chosen server-side from the live subscription (P5 —
Analytics never stores billing).

### Backend (no schema change — all derived from the existing event log)
- `getMerchantIntelligence(userId, sinceDays)` — own-scope, bounded compute (scans ≤5000 own
  events; honest `sampled` flag), UTC-deterministic hour histogram, WoW math, zero-gap daily
  series, top activity. `peakHour = null` on no activity (honest empty state).
- `me/intelligence` — own-scope, fail-closed (401), `days` clamped ≤365.

### Honest gaps / follow-ups (recorded)
- **De-identified category comparison** ("you vs the average Pi café") is a deliberate NEXT
  step — it needs an AGGREGATE disclosure (C-122 §5.2) with real de-identification, not faked.
- **Pi Economy Pulse** (a public, de-identified "is the Pi economy active?" board) — proposed.
- `[Code Verified]` → `[Runtime Verified]` after the Vercel redeploy.

### PR ledger
tec-core-backend **#199** (getMerchantIntelligence + me/intelligence, 58/58) · tec-analytics
**#29** (Merchant Intelligence dashboard, 36/36). All local gates green (build · lint · tests · tsc).
