# SESSION 32 — PI ECONOMY PULSE (Analytics' first PUBLIC surface) (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open) — becomes `[Runtime Verified]` after the Vercel redeploy. Second step of "Analytics serves the broader Pi community" (after Merchant Intelligence): a public board anyone can see, even logged out.

### What it is
A **public** `/pulse` page (no login) — **"is the Pi economy active?"** — showing platform-wide
**activity signals**: total transactions, 7-day count, week-over-week growth, active-merchant
count, and a 14-day daily-activity sparkline. This is the community-facing complement to
Merchant Intelligence (own-scope): Pulse is the *aggregate*, public view.

### The constitutional basis (C-122 §5.2 AGGREGATE disclosure) + the guards
Analytics may disclose de-identified AGGREGATE data publicly (§5.2). This is that — with
hard guards so it can never identify anyone:
- **Aggregate counts ONLY** — no per-user / per-merchant row ever leaves the service
  (the distinct-merchant query returns a COUNT; rows never leave the method).
- **k-anonymity floor** — an active-merchant cohort below **5** is suppressed to `null`
  (UI shows `—`), so a tiny early platform can't identify individuals.
- **Activity, NOT money-as-truth, NOT price** — no π volume, no market/price chart (the
  Session 31 decision holds). Analytics never presents a figure as financial truth (C-105).
  The page carries an explicit disclaimer ("de-identified aggregate signals · not investment
  information").
- **Served via a public BFF** that adds the internal key server-side; the backend `authorize()`
  still requires a valid actor (internal/user) and it is **never** platform-sovereign data.

### Backend / frontend (no schema change)
- `getEconomyPulse()` — built from the already-aggregated `dailyMetric` table + a distinct-
  merchant COUNT. `GET /analytics/pulse` (public-via-BFF). 6 backend tests (de-id shape / no
  user_id leak / k-anonymity / WoW).
- `/api/bff/analytics/pulse` (public, no token) + a themed public `/pulse` page (inline
  Pi-Browser-safe charts). 2 frontend tests.

### Honest gaps / follow-ups (recorded)
- **De-identified category comparison** ("you vs the average Pi café") — still the deliberate
  NEXT step; needs a cohort-safe AGGREGATE join (min cohort size), not faked.
- Pulse is only as populated as `dailyMetric` — if the daily-metric updater lags, it shows
  fewer days (honest, no fabrication).
- `[Code Verified]` → `[Runtime Verified]` after the Vercel redeploy.

### PR ledger
tec-core-backend **#199** (Merchant Intelligence + `getEconomyPulse`, 64/64) · tec-analytics
**#29** (MI dashboard + public `/pulse`, 38/38). All local gates green (build · lint · tests · tsc).
