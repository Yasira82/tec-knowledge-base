# Pi Community Expansion Map — the engineering work to make TEC's apps serve the Pi community

**Date:** 2026-10-04 · **Session:** 56s
**Truth State:** [Planned State] · **Governance State:** [Governance Approved] — the owner asked for it, and approved saving it and splitting it into issues
**Verification:** [Documentation Verified] + [Code Verified] where a row says so (checked 2026-10-04)
**Last verified against code:** 2026-10-04

> The owner's rule (2026-10-04): *the apps must grow to serve the Pi community, not only each
> other inside TEC.* This map turns that into ordered, sized work. It is an execution layer over
> **C-135** (Focused-8 launch strategy) and **C-133** (growth governance); it changes no charter.
> Every item is a GitHub issue. The index is in §7.

---

## 1. Definition

An app **serves the Pi community** when a Pioneer who has never heard of TEC opens it, gets
something useful in under two minutes, and does not need any other TEC app to get it.

## 2. Three facts it starts from

1. **The approved strategy already says "focus".** C-135 chose a launch set of 8, later 9 to 11
   apps, and a marketing trigger on 30 Sep 2026. Campaign Round 2 ran on **all 24 apps**
   (C-02 row 2). The only Round 2 comment, "focus on one app instead of 24", restates C-135. The
   platform did not follow its own decision.
2. **No app can pay a Pioneer seller.** A sale settles into the app developer's wallet, and
   there is no payout step (`audits/MARKETPLACE_SELLER_PAYOUT_GAP_2026-08-19.md`; still true in
   code on 2026-10-04: no payout in commerce-service or asset-service). A community marketplace
   cannot exist until there is one.
3. **Pi counts differently from TEC.** For `.pi` domains, Pi counts KYC'd Pioneers who signed in
   with Pi *in that app*. TEC's coverage counts a page load (C-02 row 2). The domains deadline is
   Dec 2026 (C-135 §5).

## 3. Phase 0 — Foundations (now → end of October). Everything else waits on these

| ID | Item | Why | Size | Owner |
|---|---|---|---|---|
| **F1** | TEC's own **A2U app wallet** | Automatic rewards and seller payouts both need it (C-02 row 6) | Pi's review | Owner + Pi |
| **F2** | **Seller payouts** in Commerce and Assets: a settled sale creates an amount owed to the seller; payment-service pays it by A2U. Idempotent, with an audit trail (C-71). Until F1, the seller sees what is owed and it is paid by hand with `Mark sent`, the campaign's existing flow | The precondition of any marketplace for the community | 2–3 PRs (backend + Commerce + Assets) | Sessions |
| **F3** | **Count the way Pi counts:** send the arrival report only after a successful Pi sign-in, not on page load | The domains deadline; TEC's numbers must match Pi's | One template change, rolled out to the launch set only | Sessions |
| **F4** | The **SPOF actions** (`audits/SINGLE_POINTS_OF_FAILURE_2026-10-04.md` §4): one test restore, the secret-rotation runbook, npm Trusted Publishing (**before 25 Nov 2026**), backend CI minutes | Nothing opened to the community should stand on a base that falls | Docs + ops | Owner + sessions |

## 4. Phase 1 — Back to focus (one week, alongside Phase 0)

- **Round 3 offers the launch set only** (9–11 apps, C-135 §2.1), not 24. This is the existing
  `CAMPAIGN_APPS` variable on identity-service.
- The Pioneer picks 1–3 of them; the funnel measures it
  (`audits/ROUND_3_DISCOVERY_DECISION_2026-10-04.md` §4).
- The other apps stay deployed and honestly labelled "preview" (C-135 §3), outside the campaign.

## 5. Phase 2 — Community slices (Nov → Dec 2026). One in flight at a time, each ≤ 1 week

Ordered by value to the community against cost, and only where a real backend already exists.

| ID | App | The community's question | Engineering | Depends on |
|---|---|---|---|---|
| **S1** | Explorer | "Where can I spend Pi near me?" | Search is **already public, no sign-in** ([Code Verified]: the search BFF needs only the internal key). Add OpenGraph link previews to `/business/[id]` (none today — [Code Verified]), because links travel through Pi groups on Telegram and Facebook. Put "Add a shop" (exists, 5 per owner) at the top | — |
| **S2** | Analytics Pulse | "How is the Pi network doing today?" | **Already live and public.** Add a shareable card, and "source: Pi Horizon" beside every number (E1) | — |
| **S3** | Commerce + Ecommerce + NBF | "Sell to Pioneers, buy from Pioneers" | The seller sees the amount owed; NBF becomes a new seller's first step | **F2** |
| **S4** | Zone | "Is this Pi app or project real, or a scam?" | Evidence registry readable without sign-in; every verdict worded per E1 ("not enough evidence", never "safe") | ⚠️ needs a human reviewer, and today that is the owner alone (SPOF H9) |
| **S5** | Alert | "What scams are going around now?" | The community feed is **demo seed data today** ([Code Verified]: `alert.service.ts` seed). Admin-entered warnings with a **mandatory source** per entry (E1). Phone push comes later | — |
| **S6** | DX + `tec-template-base` | Developers: "How do I build a Pi app that works?" | **Cheapest slice, largest value.** The template is **already public** ([Code Verified]). Publish guides for what TEC learned the hard way: Pi Browser cookie law (C-123), dual-mode payment (C-12), the foreign session (ADR-007) | — |
| **S7** | Life §10a | "If my phone were lost, would my Pi be lost?" | A yes / no / not sure checklist. **No passphrase, ever** | The Round 3 continuity question's answers |

## 6. Phase 3 — Open to other Pi apps (2027, after real users)

- Read-only, PII-free APIs: Zone verification status, Explorer listings as an embed, Pulse
  numbers.
- Each one is rate-limited, and `/internal` stays closed at the gateway (C17).
- **Not built:** "Sign in with TEC" for other Pi apps. Pi does not share a session between apps
  (ADR-007, C-123 §13).

## 7. Rules for any community-facing work

1. A page open without sign-in is **read-only**, rate-limited and carries no personal data (P6).
2. **E1–E3** (C-47 §10) on every verdict, rank or status.
3. The **Professional Bar** (C-135 §4) before a slice is promoted, plus one end-to-end run in
   production.
4. **One metric per slice** in the funnel (a shop added, a sale, a report), alongside the
   number of Pi sign-ins (Pi's own metric).
5. **Arabic and English** from day one; fast on a low-end Android phone inside Pi Browser.
6. **One slice in flight at a time.** One person does the work (SPOF audit).

## 8. Not in this map

- New apps. 24 is already too many.
- FundX, Insure escrow and Brookfield: gated on legal review and custody.
- Legend, Elite and VIP: they read an economy that is not yet running (C-135 §3).
- Pi-wide agent commerce (C-02 row 12).
- Web3, and the 69-repository map.

## 9. Order

```
F1 · F2 · F3 · F4  →  Round 3 on the launch set  →  S1 Explorer  →  S6 DX  →  S2 Pulse
  →  S3 marketplace (after F2)  →  S4 Zone · S5 Alert  →  S7 (if the numbers earn it)
```

## 10. Issue index

**Tracker: tec-knowledge-base #191.** It lists all 15 items with their links and states: F1 #189 · F2 Tec-core-backend #367, Tec-Commerce #78, Tec-Assets #70 · F3 tec-template-base #47 · F4 #190 · Round 3 Tec-core-backend #368, Tec-App #276 · S1 Tec-Explorer #56 · S2 Tec-Analytics- #61 · S3 Tec-Commerce #79 · S4 Tec-Zone #59 · S5 Tec-Alert #48 · S6 Tec-Dx #47 · S7 Tec-Life #67. The state
lives there, not here: this document holds the plan, and the issues hold the progress.

**Phase 0 as of 2026-10-06** (`memory/sessions/session-56t.md`): **F2 built** — tec-core-backend
#369 (one desk for both marketplaces; NFT sales swept in from asset-service) · Tec-Commerce #80 ·
#82; no Assets screen, and no fee (none decided). **F3 done in all 23 apps** — tec-template-base #48
and the app PRs (session 56t §2). **F1** waits on Pi; **F4** is the owner's. Round 3 opened on the
same 6 apps for everyone (`audits/ROUND_3_DISCOVERY_DECISION_2026-10-04.md` §4b).

## Related Documents

- `knowledge-base/C-135___LAUNCH_STRATEGY_FOCUSED_8.md` — the launch set and the Professional Bar
- `knowledge-base/C-133___PLATFORM_ADOPTION_GROWTH_GOVERNANCE.md` — growth rules
- `knowledge-base/C-47_Kernel_Spec_Architecture_Binding.md` — §10 evidence rules
- `audits/MARKETPLACE_SELLER_PAYOUT_GAP_2026-08-19.md` — F2
- `audits/SINGLE_POINTS_OF_FAILURE_2026-10-04.md` — F4
- `audits/ROUND_3_DISCOVERY_DECISION_2026-10-04.md` — Phase 1
- `knowledge-base/C-106___LIFE_INSTITUTIONAL_CHARTER.md` — §10a, S7
