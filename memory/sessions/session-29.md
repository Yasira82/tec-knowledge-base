# SESSION 29 — LEGEND PRO = EMBEDDABLE REPUTATION BADGE (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open) — becomes `[Runtime Verified]` after `tec-identity-service` `db push` + Vercel redeploy + a real Legend Pro payment. Continues Session 28's "make Pro real" — third app after Explorer + Zone.

### The benefit — reputation that travels the Pi economy
Session 28 flagged Legend Pro as still "just a supporter badge." Now it delivers a
**concrete, shareable service**: a public **embeddable reputation badge** — a live SVG a
member drops on their own website / Pi store / marketplace listing
(`<img src="https://legend.tecosystem.app/badge/<handle>.svg">`) that always reflects their
current earned reputation. This is Legend's outward reach into the whole Pi ecosystem (like
Zone's `/badge` — reputation, not verification).

### The constitutional line held (C-126 — earned, never bought)
Legend's rule is that reputation comes from source-app outcome events + Analytics-computed
scores — a user can never author it. This change respects that **completely**: a single
`showcase` flag gates **only the marketing surface** (the badge). It never touches an
achievement record, never changes a score, never mints verification. **You pay to
DISTRIBUTE a reputation you already earned, not to buy one.** Same shape as Explorer
(featured = visibility, below trust) and Zone (priority = queue, never verdict).

### The gate (fail-safe, leaks no score)
The `/badge/<handle>.svg` endpoint renders the overall score (or the earned achievement
count while Analytics scores are still pending) **only** for a `PUBLIC` profile with
`showcase` on (a live-Pro entitlement). Every other case — not Pro, not public, not found,
backend unreachable — degrades to a neutral "Pi reputation" wordmark that **leaks no
score**. Public, no-auth, edge-cached (`s-maxage=300`).

### Sync pattern (identical to Explorer/Zone — P5)
- Backend: `LegendProfile.showcase` (one boolean) + `setShowcase(owner,on)` + `PATCH
  /api/identity/legend/own/:owner/showcase` (owner-scoped, P6; never creates a profile —
  reputation is earned, not toggled). **22/22 backend tests.**
- Frontend: the profile BFF reads the caller's **live** subscription from commerce
  (`/api/commerce/subscriptions/status`) and reconciles `showcase` to match — Legend never
  stores billing truth (P5, commerce-owned). Lapsed Pro → badge falls back on next visit.
- UI: a Pro-only `ShowcaseCard` (live badge preview + copy-embed HTML/Markdown snippets;
  nudges Public when needed; honest upsell when not Pro). **29/29 frontend tests · +5 badge-gate tests.**

### The Pro model now (4 real, honest benefits)
| App | Pro delivers |
|-----|--------------|
| **Life** | Unlimited goals (FREE = 3) |
| **Explorer** | ⭐ Featured — ranks higher in discovery |
| **Zone** | ⭐ Priority review — jumps the review queue (never the verdict) |
| **Legend** | 🔖 Embeddable reputation badge — your earned reputation, on any site |

### Honest gaps / follow-ups (recorded)
- **Analytics Pro** (and the rest) still give only the supporter badge — Analytics next
  (proposed: deeper/longer merchant data + export). A follow-up per app.
- **`showcase` lapse:** reconciled on the owner's next profile load via the BFF (same as
  Explorer/Zone `featured`/`priority`); a background sweep cron is the shared follow-up.
- `[Code Verified]` — `[Runtime Verified]` needs `tec-identity-service` `prisma db push`
  (one boolean column, expand-only/non-destructive) + Vercel redeploy + a real Pro payment.

### PR ledger
tec-core-backend **#197** (LegendProfile.showcase + PATCH endpoint, 22/22) · tec-legend
**#19** (embeddable badge + sync + ShowcaseCard, 29/29). All local gates green (build · lint · tests · tsc).
