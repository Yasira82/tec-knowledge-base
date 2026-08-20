# Competitive Teardown — Reputa Score (Pi app) — 2026-08-19

**Scope:** a live Pi Network app, "Reputa Score," reviewed screen-by-screen (onboarding,
dashboard, earn-points, analytics, wallet, referrals, install).
**Question:** what does it do well that TEC should adopt — and what is a trap dressed as
success that TEC must NOT copy?
**Verification:** `[Observed]` — from the owner's live screenshots of the app on Pi Mainnet
(2026-08-19). Prompted while fixing TEC's top-of-funnel campaign problem (0.4% Reddit
conversion + scam skepticism).

---

## What Reputa Score actually is

Positioned as "the reputation/trust layer for the Pi economy" (reads public on-chain
history → a single Reputa Score 0–1M + trust level + risk signals). **But its real engine
is a points economy with pay-for-points monetization**, wrapped in reputation language:

- **RP Store** — buy points with real Pi (1π→100 RP … **500π→55,000 RP "BEST VALUE"**).
- **Pi Staking → earn RP** (lock Pi for points; "non-custodial").
- **Earn Points** — daily claim, streaks (+40→+120/7d), daily/weekly/journey/challenge
  tasks, check-ins, merges, 300k-pt milestones, ad bonus.
- **Social tasks that pay points** — "Share on Fireside +300", "Subscribe YouTube +250",
  "Like & Comment" → it pays points for users to market it (a free growth loop).
- **Referrals** — invite code, tiered RS + instant RP, friend welcome bonus.

**Honest read:** it looks alive and busy because that model *manufactures* activity. The
points monetize belief, not underlying utility.

---

## ✅ ADOPT — real value, NOT the farming trap

These are decoupled from the points economy and genuinely worth building in TEC.

| # | Takeaway | Why it fits TEC's real problem | TEC home | Priority |
|---|----------|-------------------------------|----------|----------|
| A1 | **Guest / Demo mode** ("GUEST VIEW · READ-ONLY", a `Demo_Pioneer` account with populated sample data) | Directly attacks **top-of-funnel + scam-fear + empty-after-login**: a skeptic sees the ecosystem *populated and alive* before connecting anything. | Hub landing + a demo Hub session | **HIGH** |
| A2 | **Public free-utility hook** ("Search any Pi wallet" — on-chain lookup, no login) | A useful, curiosity-driven tool anyone can use with zero commitment = a real acquisition magnet. TEC's version must use *TEC's* value (explore the ecosystem / browse the real store) — not copy wallet-analysis. | Public `/explore` or store preview, no auth | **HIGH** |
| A3 | **"Install App" → home-screen PWA** ("get a real icon … one tap opens straight in Pi Browser") | Low-risk, real retention: an icon that brings users back. Pure craft, no farming. | Hub PWA install prompt | **MEDIUM** |
| A4 | **Explicit trust/safety badges** ("100% READ-ONLY", "No passphrase", "No private keys", "Powered by Pi Network Blockchain", Terms/Privacy/Support) | Kills the "is this a scam?" objection *before it's asked* — TEC's exact Reddit bottleneck. | Landing + Hub | **HIGH · cheap** |
| A5 | **UI/UX polish + personality** — glass cards, a hero **gauge/ring** for the headline metric, tier ladder viz (Bronze→Diamond), glow, a mascot/brand character, "pts to next" progress | The craft bar is genuinely high and attractive. TEC's Hub can feel more *alive/premium* using these patterns (with TEC's gold/dark EVL palette, not purple). | Hub dashboard visual pass | **MEDIUM** |

> A4/A5 confirm and sharpen the earlier `PIONEER_ACQUISITION_INTERVIEW_FIRST` takeaways
> (trust messaging + first-30-second value). A1/A2 are the concrete mechanisms for them.

---

## 🔴 REJECT — the points economy (a deliberate decision, not an oversight)

**Do NOT copy:** RP points · RP Store (pay Pi for points) · staking-for-points · task
farming · referral point bonuses.

Why this is a trap *for TEC specifically*:

1. **It destroys the campaign's core message.** TEC's whole credibility play is "this is
   real, not a scam." "Pay Pi → get points with no clear utility" is exactly what makes
   people call Pi apps scams. Bolting it on kneecaps the differentiator.
2. **It attracts farmers, not users.** TEC's KPI is *Independent + KYC + genuinely
   Completed* users. A points economy optimizes for the opposite — people grinding tasks
   for points, not people who value the product.
3. **It risks the `tec.pi` claim.** Pi ties domain claims to **organic usage**;
   manufactured points activity can read as *inauthentic* to Pi's review — a downside, not
   an upside.

**TEC's moat is the inverse of Reputa's model:** Reputa sells *points* for Pi; **TEC sells
real things for Pi** — real products (store), NFTs you own, subscriptions with actual
features. That is the honest, defensible position. Keep it.

---

## Decision

- **Build A1–A5** (guest/demo · public utility hook · PWA install · trust badges · UI
  polish) — they serve the documented top-of-funnel bottleneck and carry no farming risk.
  Start order by effort/safety: **A4 (trust badges) → A3 (PWA install) → A1 (guest/demo) →
  A2 (public hook) → A5 (polish pass).**
- **Reject the points economy** as above — recorded so no future session "adds engagement"
  by regressing into pay-for-points.
- Consistent with `PIONEER_ACQUISITION_INTERVIEW_FIRST_2026-08-16` (interview-first, KPI =
  Independent+KYC+Completed, pause reward/referral machinery) and
  `MARKETPLACE_SELLER_PAYOUT_GAP_2026-08-19`.

---

## Related

- `audits/PIONEER_ACQUISITION_INTERVIEW_FIRST_2026-08-16.md`
- C-105 Analytics (TEC already owns real analytics — the honest basis for any "insight" hook)
- C-120 Zone / C-126 Legend (TEC already owns a real, evidence-based reputation layer —
  the honest alternative to a bought score)
