# SESSION 26 — SUBSCRIPTION ACTIVATION + PRO ENTITLEMENT (fleet-wide) (7 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Code Verified]** (merged to `main`) platform-wide · **[Runtime Verified]** for **Life only** (a real 5π Life Pro payment → ★ PRO shown live in prod after redeploy). The other 18 Pro apps are `[Code Verified]`, pending each app's Vercel redeploy + one real payment. Verification: **[Code Verified]** + **[Runtime Verified]** (Life).

### The gap (why a paying user got nothing)
Every app's in-app **"Pro" button** took a real Pi U2A payment but activated **no
subscription** — commerce-service had **no consumer** linking a completed payment to a
subscription. The old `OrderConsumer` is registered in **no module** (dead code). Only
the Hub's `/hub/subscription` flow ever activated a plan. So across ~19 Pro apps, a paid
user received **no entitlement**. This was the single largest pre-campaign risk (people
pay, get nothing).

### The fix — one backend consumer, both modes, whole fleet (tec-core-backend #188)
New **registered** `SubscriptionConsumer` (commerce-service) consumes
**`payment.completed.v1`** (which already carries the payment's metadata, Session 25) and,
when the payment is a Pro/Enterprise buy, activates the plan via
`SubscriptionService.subscribe` — the **same path the Hub uses** (no parallel system, P2).
- Detection (`planFromPaymentMetadata`): PRO/ENTERPRISE from a `<slug>_pro_monthly`
  **`item_id`** (Mode 2) / **`product_id`** (Mode 1 via Hub), or explicit `metadata.plan`.
- **Idempotent** (upsert by user; an "already subscribed" redelivery is a no-op —
  at-least-once delivery); a genuine failure rethrows so the message retries.
- **No payment-service change** — `payment.completed.v1` already carries `metadata`.
- New consumer group **`commerce-subscription`** added to the consumer-liveness sensor
  (`stream-health.service.ts`) + `verify-runtime.mjs` EXPECTED for `payment.completed.v1`.
- 8 unit tests (detection both modes + none + idempotency + rethrow). `Subscription` stays
  a commerce-owned Canonical Entity (C-47); no Pi is moved here (payment already completed).

### The hidden second half — the read path (`/me` never carried the plan)
`tec-auth-service` `getMe` selects **no** subscription field and its login response
**hardcodes `subscriptionPlan: null`**, so `usePiAuth().user.subscriptionPlan` was always
empty — the badge could never show even after activation. Since Subscription is
commerce-owned and `/me` is a hot path, apps now read the plan **directly from commerce**:
new BFF **`GET /api/bff/subscription`** → gateway `/api/commerce/subscriptions/status`
(session-scoped, P6, read-only). Fixed in tec-life first, then rolled to every Pro app.

### Display + expiry (19 apps, all merged)
Each Pro component shows **"★ You're on Pro"** (Life also: a header ★ PRO badge + the
concrete **unlimited-goals** benefit, FREE capped at 3 active goals) while the subscription
is **live** — gated on `isActive` + not `isExpired` (with a `current_period_end` fallback).
Because Pi U2A has **no auto-renewal**, Pro is a **30-day pass** and the badge/benefit
**end when the month lapses**. Apps: **Life · Zone · Nexus · Vip · Connection · Estate ·
Explorer · Nx · Alert · Analytics · Dx · FundX · Insure · Elite · Epic · Legend · Titan ·
NBF · Brookfield** (Life deepened; the other 18 via the identical patch, canary-built clean
on Zone + Vip).

### Runtime-verified on Life (first end-to-end proof)
A real **5π Life Pro payment** → after commerce + Life redeploy, the **★ PRO** badge +
unlimited-goals unlocked live, and the code correctly ends it after 30 days. Full loop
proven: **activate → read → show → expire.**

### Also this session (adjacent, merged)
- **Nexus run-resume fixed** (tec-nexus #18): a live workflow-payment flow was silently
  broken — Mode-1 sent no `return_url` (dumped the user on the Hub) + no restore/poll on
  return. Now returns to `/workflow/[id]` and resumes. Sensor extended to watch
  `identity-nexus` (tec-core-backend #186).
- **Life deepened** (tec-core-backend #187 + tec-life #17/#18/#19/#20): goals gained
  `target_amount` + `progress` + auto-complete → a real π **goal tracker** (Life moved from
  preview to advertise-ready).

### Honest gaps / follow-ups (recorded, not hidden)
- **[Runtime Verified] = Life only.** The other 18 apps are merged `[Code Verified]`; each
  needs its Vercel redeploy + one real payment. A user's **earlier (pre-consumer) payment
  does NOT back-activate** — only new payments after the consumer deploy.
- **No auto-renewal** — Pi U2A is one-time; Pro is a 30-day pass. A renewal *reminder* flow
  is a follow-up (Pi cannot auto-charge).
- **No server-side downgrade job** — expiry is enforced in the read (client) + backend
  `SubscriptionService.hasAccess()`. A commerce cron to flip expired → FREE server-side (so
  every consumer agrees without re-checking the date) is a follow-up.
- **System excluded — correctly.** `system_supporter` is a voluntary 1π contribution that
  grants nothing (C-110); there is no Pro to show. A persistent "Supporter ✓" ack would
  need payment-tracking (separate follow-up).
- **Price-vs-plan mismatch (hardening):** `PLANS.PRO.price = 10π` but some Pro surfaces
  charge less (Life 5π); the consumer activates PRO regardless of amount (`verifyPiPayment`
  is skipped when no `piPaymentId`). Follow-up: assert `amount == plan price` at activation.

### PR ledger
Backend: tec-core-backend **#186** (sensor→nexus), **#187** (Life goal tracker), **#188**
(SubscriptionConsumer). Frontend: tec-life **#17/#18/#19/#20**; **19** Pro-entitlement PRs
across the fleet (Zone #21 · Nexus #19 · Vip #16 · Connection #26 · Estate #18 · Explorer
#19 · Nx #16 · Alert #16 · Analytics #27 · Dx #16 · FundX #15 · Insure #16 · Elite #16 ·
Epic #16 · Legend #16 · Titan #16 · NBF #6 · Brookfield #4) — all merged.
