# SESSION 35 — ANALYTICS PROD REVIEW FIXES (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** (found from live prod screenshots) + **[Code Verified]** (fix PR open). Two fixes + one operational finding from reviewing the deployed Analytics dashboard.

### Fix 1 — admins were locked out of the new community features
The dashboard branched `admin ? PlatformSections : MerchantIntelligence…`, so an **admin
never saw** Merchant Intelligence / peer comparison (found: logged-in-as-admin screenshots
showed only the platform view). But those are **own-scope** (an admin is a merchant too) —
now they render for **everyone**; only the platform aggregates stay admin-only (C-122 §5
SOVEREIGN). An admin sees both from one login.

### Fix 2 — misleading flat charts → honest empty state
The platform `BarChart` drew a row of equal 2px bars (screenshots) that read as *broken*.
Now: all-zero → an honest "No daily totals for this period yet"; nonzero bars get a visible
6px floor (small days don't vanish next to an outlier); NaN coerced. No fabricated data.

### The root cause + Fix 3 (backend — charts now read the event log)
The flat charts surfaced a real gap: **the platform charts read the `dailyMetric` aggregate,
which lags the live event counts.** Prod showed **Overview = 716 payments** (from
`analyticsEvent.count`) while the daily chart's `dailyMetric` totals were **~0** — the
`updateDailyMetric` path (on the `payment.completed` consumer) under-populates in prod
(historic days never aggregated). **Fixed at the source:** `getPaymentAnalytics` +
`getUserAnalytics` now build their daily series from the **event log** (bounded scan), the
same source as Overview + Merchant Intelligence — so the charts match reality regardless of
the aggregate. `getPaymentAnalytics`: `total_payments`/`total_volume` from
`payment.completed(.v1)` (amount coerced from the Decimal→string payload).
`getUserAnalytics`: `new_users`/`kyc_verified`/`active_users` (distinct/day) from one scan.
Same response shape → frontend unchanged. Eventual-consistency + admin-only + bounded → an
acceptable event scan (tec-core-backend #200, 74/74).
> The `dailyMetric` backfill is now an **optional** ops nicety, not a blocker — the dashboard
> no longer depends on it.

### PR ledger
tec-analytics **#30** (admin MI visibility + honest BarChart, 41/41) · tec-core-backend
**#200** (platform charts read the event log, 74/74). No schema change.
