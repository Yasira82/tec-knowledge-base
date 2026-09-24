# SESSION 28 — "DOES PRO GIVE REAL VALUE?" → 2 apps now do (7 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (merged/queued) — each becomes `[Runtime Verified]` after its Railway `db push` + Vercel redeploy + a real Pro payment.

### The honest finding (audited the code, not the copy)
The user asked the sharp question: *does the Pro subscription actually give a real service, or just a badge?* Reading the code, the honest answer was **mostly a badge**:
- **Life** — the only app with a real gated benefit (unlimited goals vs FREE's 3).
- **Explorer** — the copy claimed "premium visibility" but the ranking had **no Pro signal** — Pro changed nothing.
- **~18 other apps** — "★ You're on Pro — thanks for supporting TEC": a supporter badge, no gated feature.

This is a real pre-campaign risk (people pay, get nothing → churn + reputation damage). Recorded as the honest state; the fix is to give each Pro a **concrete, charter-sound benefit** — started with two.

### 1. Explorer Pro = FEATURED placement (C-108 §7) — a real discovery boost
- `ExplorerBusiness` gains `featured` + `featured_until`. Search ranks **featured-first WITHIN the trust tier**: `verification → featured → popularity → pi_accepted → name`.
- **Featured sits BELOW verification on purpose** — you can pay for *visibility*, never for *trust*. A KYC-verified free business always outranks an unverified Pro one. (Same principle as Zone: "speeds the queue, never the verdict.")
- The listings BFF re-syncs `featured` from the owner's **live** Pro subscription (commerce-owned, P5 — Explorer never stores subscription truth); lapsed Pro clears on the next owner visit. `⭐ Featured` tags on the listing + search results; honest pitch copy.
- PRs: tec-core-backend **#195** (22/22 tests) · tec-explorer **#20**.

### 2. Zone Pro = PRIORITY review (C-120 §7) — the charter's own sanctioned benefit
- The charter says exactly one thing Zone Pro may sell: *"speeds the review queue, never the verdict."* Implemented: `ZoneEntity.priority`; `listPending` orders **priority-first, then FIFO**; `submitRequest` accepts `priority`, set by the BFF from the caller's live subscription.
- **Queue speed ONLY** — the entity still starts PENDING and a **human still decides**. A spoofed priority buys queue order, never verification (low-stakes by design). Reviewer sees a `⭐ Priority (Pro)` tag.
- PRs: tec-core-backend **#196** (20/20 tests) · tec-zone **#25**.

### The Pro model now (3 real, honest benefits)
| App | Pro delivers |
|-----|--------------|
| **Life** | Unlimited goals (FREE = 3) |
| **Explorer** | ⭐ Featured — ranks higher in discovery |
| **Zone** | ⭐ Priority review — jumps the review queue (never the verdict) |

### Honest gaps / follow-ups (recorded)
- **Legend Pro · Analytics Pro** (and the rest) still give only the supporter badge — each needs its own concrete benefit (proposed: Legend = embeddable reputation badge; Analytics = deeper/longer merchant data + export). A follow-up per app, not a one-liner.
- **`featured`/`priority` lapse:** cleared on the owner's next visit via the BFF re-sync; a background sweep cron for owners who don't return is a follow-up — consistent with the existing "no server-side downgrade job yet" stance (Session 26).
- Both features are **`[Code Verified]`** — `[Runtime Verified]` needs each service's `prisma db push` (adds the columns, expand-only/non-destructive) + a Vercel redeploy + a real Pro payment.

### PR ledger
tec-core-backend **#195** (Explorer featured), **#196** (Zone priority) · tec-explorer **#20** · tec-zone **#25**. All local gates green (build · lint · tests · tsc).
