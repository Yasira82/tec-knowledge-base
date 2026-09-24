# SESSION 34 — PEER COMPARISON SEGMENTATION (by app source) (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open). Extends Session 33's peer comparison with the category dimension — the honest, owned version of "category/region."

### What it is
The peer comparison (Session 33) gains a **segment toggle**: compare against **All** active
merchants, or just those on **your own app source** (e.g. Commerce). Each segment is
k-anonymized independently.

### The honest boundary call (category = app source; region = deferred)
"Category/region segmentation" was the recorded next step. Reading the data decided *which*
is honestly buildable:
- **Category → app SOURCE** (`payload.metadata.source`) — this is the **only category
  dimension Analytics genuinely OWNS**: it already lives in Analytics' own event payload
  (the `payment.completed.v1` event carries the payment's `metadata`, incl. `source`). So
  "vs other merchants on Commerce" is real, owned, no cross-service read.
- **Region / geography → DEFERRED (with reason)** — a merchant's location is **business-profile
  data Analytics does NOT own** (it belongs to Explorer / identity). Segmenting by region would
  need a governed cross-service signal (a bigger data model) — recorded, not faked.

### The design (per-segment k-anonymity)
- Backend `getCategoryComparison(userId, segment?)` **auto-detects** the caller's dominant
  source (bounded own read) → returns it as `ownSegment` so the UI can offer the toggle. When
  a segment is chosen, the cohort is restricted via a **JSON-path filter**
  (`payload.metadata.source == segment`), and the **same k-anonymity floor** applies **per
  segment** (a too-small segment cohort → suppressed, fail safe). Still counts (never π), still
  no per-user row leaves.
- Frontend: an "All / <your source>" toggle on the PeerComparison panel; the BFF forwards a
  **whitelisted** segment slug (a malformed value is dropped before it reaches the JSON filter).

### Honest gaps / follow-ups (still recorded)
- **Region segmentation** — needs a category/geo signal on the merchant profile (Explorer/
  identity) surfaced via a governed cross-service read; deferred.
- **Differential-privacy noise** — the k-anonymity floor remains the v1 guard.
- `[Code Verified]` → `[Runtime Verified]` after the Vercel redeploy.

### PR ledger
tec-core-backend **#199** (…+ segment, 74/74) · tec-analytics **#29** (…+ segment toggle, 41/41).
All local gates green (build · lint · tests · tsc).
