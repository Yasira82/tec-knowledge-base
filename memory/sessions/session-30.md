# SESSION 30 — ANALYTICS PRO = 90-DAY ACTIVITY HISTORY + CSV EXPORT (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open) — becomes `[Runtime Verified]` after the Vercel redeploy + a real Analytics Pro payment. Fourth app in the "make Pro real" line (Explorer · Zone · Legend · **Analytics**).

### The benefit — deeper/longer own data + export
Session 28 recorded Analytics Pro as the next "still just a supporter badge." Now it delivers
a **concrete service**: a deeper/longer **own-scope activity history** you can **export as
CSV**. FREE sees the live on-screen "Recent events" preview; **Pro exports the full 90-day
history (≤500 rows)** — for the merchant's own records, spreadsheets, or accounting.

### The constitutional line held (C-105 — same truth, more depth)
The numbers are **identical computed truth** — Pro unlocks **DEPTH + export**, never
different data. No new disclosure surface: `me/activity` was already **own-scope +
fail-closed** (C-105 §6 / C-122 §5.1). This only changes *how much* of the caller's OWN data
returns (rows + window) and adds a CSV download. Analytics still never presents aggregates as
financial truth (owning service is the source of truth).

### The gate (fail-closed, own-scope, P5)
- **Export is Pro-gated at the BFF** (`/api/bff/analytics/me/export`): no live subscription →
  **403**. Analytics never stores billing (P5) — `resolveProStatus` reads it **live** from
  commerce (`/api/commerce/subscriptions/status`). Downgrade → export 403s again.
- Strict own-scope: the BFF forwards only the session Bearer; identity is derived server-side
  by the analytics service (never a param). RFC 4180 CSV escaping + `attachment` disposition.

### Backend (analytics-service, no schema change)
- `getRecentEvents(limit, userId, sinceDays?)` gains an optional `created_at ≥ now − sinceDays`
  window — **backward-compatible** (no `sinceDays` → identical query as before). Only the DEPTH
  knob; still the caller's OWN events only.
- `me/activity` accepts `days` (clamped ≤365) + raises the limit cap **25→500** (the export data
  source). No `db push` — the window is a query filter, not a column.

### The Pro model now (5 real, honest benefits)
| App | Pro delivers |
|-----|--------------|
| **Life** | Unlimited goals (FREE = 3) |
| **Explorer** | ⭐ Featured — ranks higher in discovery |
| **Zone** | ⭐ Priority review — jumps the review queue (never the verdict) |
| **Legend** | 🔖 Embeddable reputation badge — your earned reputation, on any site |
| **Analytics** | 📁 90-day activity history + CSV export |

### Honest gaps / follow-ups (recorded)
- The remaining apps' Pro is still the supporter badge — each a follow-up with its own
  charter-sound benefit (the important five now deliver real value).
- `[Code Verified]` — `[Runtime Verified]` needs the Vercel redeploy + a real Pro payment.
- Backend `me/activity` allows depth (500/365d) to any authed caller of their OWN data; the
  *product* gate (export) is the BFF's 403. No leak — it is always the caller's own data.

### PR ledger
tec-core-backend **#198** (me/activity `days` window + 500 cap, 50/50) · tec-analytics **#28**
(Pro-only CSV export + ProHistory, 33/33). All local gates green (build · lint · tests · tsc).
