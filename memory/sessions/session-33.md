# SESSION 33 — DE-IDENTIFIED PEER COMPARISON (you vs the field) (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open) — becomes `[Runtime Verified]` after the Vercel redeploy. Third step of "Analytics serves the broader Pi community" — the recorded next step from Sessions 31–32.

### What it is
Inside Merchant Intelligence: **"how am I doing vs other active Pi merchants?"** The caller's
OWN metric (transactions, last 30d) next to a **de-identified cohort baseline** — cohort mean,
median, and the caller's **percentile** ("top X%" / "ahead of Y%"), over all active merchants.

### The privacy design (this is the whole point)
A comparison against "the average" is the classic place a naive analytics feature leaks. The
guards:
- **Distribution only** — the backend `groupBy`s per-merchant counts but uses ONLY the sorted
  distribution; **no `user_id` and no other merchant's value ever leaves the method**.
- **k-anonymity, fail-safe** — if the active-merchant cohort is below the floor (**5**), the
  **entire comparison is suppressed** (`available:false`) — never a mean/median over too few
  peers. The UI then says, honestly, "not enough active merchants to compare privately yet."
- **What leaves:** the caller's own count, the cohort mean/median (aggregates over ≥K), the
  percentile, and the cohort size (already public via the Pulse).
- **Counts, never money** — transactions per merchant, never π volume (C-105 — activity, not value).

Constitutional basis: C-105 §6 (own-scope for the caller) + C-122 §5.2 (de-identified aggregate
for the cohort). Both allowed; the cohort side is k-anonymized.

### Backend / frontend (no schema change)
- `getCategoryComparison(userId)` + `GET /analytics/me/comparison` (own-scope, fail-closed).
  6 backend tests incl. **suppression below floor** + **no-user_id-leak** + percentile.
- `/api/bff/analytics/me/comparison` (own-scope forward) + a `PeerComparison` panel inside the
  Merchant Intelligence block (renders nothing when unavailable; honest small-cohort message).

### The three community surfaces now (Sessions 31–33)
| Surface | Scope | Who sees it |
|---------|-------|-------------|
| **Merchant Intelligence** | own-scope (§5.1) | any signed-in Pi merchant |
| **Peer comparison** | own + de-identified cohort (§5.2) | any signed-in merchant (when a cohort exists) |
| **Pi Economy Pulse** | de-identified aggregate (§5.2) | the whole Pi community (public, no login) |

### Honest gaps / follow-ups (recorded)
- **Category/region segmentation** — "vs other Pi *cafés* near you" needs a category signal on
  the merchant profile + a per-segment cohort ≥K (a bigger data model); the current comparison
  is platform-wide-cohort. Recorded as the next step.
- **Differential-privacy noise** — the k-anonymity floor is the v1 guard; adding small noise to
  the mean is a future hardening against differential attacks as the platform grows.
- `[Code Verified]` → `[Runtime Verified]` after the Vercel redeploy.

### PR ledger
tec-core-backend **#199** (MI + Pulse + comparison, 70/70) · tec-analytics **#29** (all three
frontends, 40/40). All local gates green (build · lint · tests · tsc).
