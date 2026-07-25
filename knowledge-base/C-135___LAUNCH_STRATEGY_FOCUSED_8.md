# C-135 — Launch Strategy: The Focused-8 & the Month-9 Marketing Trigger

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`
> **Authority Scope:** `[Platform]`
> **Decision Authority:** CEO (C-47)

> **TL;DR (عربي):** ده **قرار استراتيجي نافذ الآن**: بدل ما نروّج 24 app متوسطة، نعمّق **8 apps**
> لحد مستوى **احترافي عليه مصداقية** لغاية **شهر 9 (سبتمبر 2026)**، وبعدها **يبدأ التسويق
> فورًا — حتى لو الـ apps مش خالصة 100%**. العمق قبل الاتساع؛ المصداقية قبل الضجيج. مُحفّز
> شهر-9 **إجباري** عشان الكمال ما ياكلش الوقت كله.

---

## 0. Why this document exists

The platform has **24 apps deployed** (per `architecture/app-fleet.yaml` — 21 live, 3
gated). The temptation is to market all 24 now. The CEO decision recorded here rejects
that: on Pi, the **first impression is a single shot** with a skeptical community, and a
broad push over shallow apps **burns credibility permanently** (the core risk C-133 §7
exists to prevent). Instead we **deepen a focused set to a professional bar, then launch**.

This doc does not change any charter or the C-30 build sequence. It is an **execution
focus layer**: *which* apps get depth first, *what "done" means*, and *when marketing
starts no matter what.*

---

## 1. Strategic thesis

1. **Depth over breadth.** 8 apps a user *loves* create word-of-mouth; 24 apps a user
   *tolerates* create noise that's forgotten. Retention before acquisition.
2. **Credibility before campaign.** We market only what delivers real, obvious value —
   so the Pi community's first experience is "this is real," not "another empty Pi app."
3. **A time-box beats a quality target.** "Professional" without a deadline becomes a
   moving goal that eats the whole calendar. So development is **hard-capped at month 9**;
   after that, **marketing starts unconditionally** — we launch what's ready and keep
   polishing in parallel (rolling launch).
4. **The assets are already built.** The full marketing kit (`marketing/`) — posts,
   FAQ, proof sheet, launch plan, outreach — is done and CI-guarded. Phase 2 has **zero
   lag**: flip the switch.

---

## 2. The Focused-8 (chosen)

Selected to tell **one coherent story — "you can run a real economy on Pi"** — where each
app has standalone, first-minute value *and* reinforces the others. All 8 are already
deployed + verified, so month-9 depth is achievable.

| # | App | Role in the story | Why it's in the 8 |
|---|-----|-------------------|-------------------|
| 1 | **Hub** | The spine — one login, one wallet, real Pi payments | Everything depends on it; it IS the platform's front door |
| 2 | **Commerce** | Sell on Pi — merchant orders + checkout | Clearest B2B value; real Pi revenue |
| 3 | **Ecommerce** | Buy on Pi — storefronts + checkout | Clearest consumer value; the demand side of Commerce |
| 4 | **Explorer** | Discover who accepts Pi near you | The bridge to the real world; drives traffic to the others |
| 5 | **Zone** | Verify what's trustworthy — evidence, not claims | Trust is the #1 Pi barrier; Zone is the answer |
| 6 | **Connection** | Your trusted network + reputation baseline | Turns one-off use into a graph → retention |
| 7 | **NBF** | Start a verified Pi business in minutes | Converts a Pioneer into a *producer* (supply for Commerce) |
| 8 | **Analytics** | See the real numbers behind your Pi activity | The proof layer — makes the economy legible + credible |

**The loop the 8 create:** NBF (start a business) → Commerce/Ecommerce (transact) →
Explorer (get discovered) → Zone (get verified) → Connection (build trust) → Analytics
(see it working) — all on **Hub** identity + payments. That's a self-reinforcing economy,
not eight islands.

---

## 3. Deliberate exclusions (the other 16 are NOT abandoned)

They stay **deployed + honestly labelled "preview"** (`whats-live.md`) and graduate into a
later focus wave. They wait for a reason, not by neglect:

- **Reputation/experience trio — Legend · Elite · VIP:** need the economy *running* first
  (they read outcomes the Focused-8 produce). No data yet → nothing to show.
- **Capital-gated — FundX · Insure · Brookfield:** hard-gated on legal + custody +
  governance (C-113/C-129/ADR-012). Cannot be a launch centrepiece.
- **Infra / B2B / niche — DX · System · Titan · Nexus · Alert · Epic · NX · Estate · Life:**
  real, but either developer/enterprise-facing or second-order value; they amplify a
  running platform rather than prove it cold.

---

## 4. The Professional Bar (definition of "done" per app)

"Professional" is **objective**, not a feeling. An app is launch-ready only when **all**
are true — this is the checklist that stops perfectionism *and* prevents a weak launch:

```
□ First value in < 2 minutes for a brand-new Pioneer (no manual, no dead ends)
□ Zero defects in the ONE core happy path (the thing the app is for)
□ Real data end-to-end in the primary flow — NO sample/placeholder fallback on screen
□ Works in Pi Browser (not just Chrome), mobile-first, no blank/broken render
□ Login solid per C-123 (verified entry; session cookies none/secure/Partitioned)
□ Honest empty states — "nothing yet", never a fabricated number (C-133 §7)
□ Privacy + Terms live; Pi Portal listing uses current copy (pi-portal-copy.md)
□ ONE real end-to-end run verified in production (e.g. Commerce: list → buy → order)
```

> A future PR may turn this bar into a per-app CI checklist (like the Drift Detection
> gate) so "launch-ready" is machine-checked, not asserted.

---

## 5. Timeline & phases

**Anchor dates:** today ≈ **late July 2026** · development hard-cap **30 Sep 2026 (month 9)**
· domains deadline **Dec 2026 (month 12)**.

### Phase 1 — DEEPEN (now → 30 Sep 2026, ~9 weeks)
Take the Focused-8 to the Professional Bar, in dependency order. Suggested sprints:

| Sprint | Window | Apps to the Bar | Note |
|--------|--------|-----------------|------|
| A | wks 1–2 | **Hub** (harden the spine) | everything depends on it — do it first |
| B | wks 3–4 | **Commerce** · **Ecommerce** | the transaction core (buy + sell) |
| C | wks 5–6 | **Explorer** · **Zone** | discovery + trust |
| D | wks 7–8 | **Connection** · **NBF** | graph + producer onboarding |
| E | wk 9 | **Analytics** + **soft-validation** across all 8 | freeze + real-user test |

### Phase 2 — LAUNCH (from month 9, unconditional → Dec 2026)
Marketing **begins at the month-9 boundary regardless of app completeness**. Rolling
launch per `marketing/launch-plan.md`: Wave 1 (Hub · Commerce · Ecommerce · Analytics)
first, then Explorer · Zone · Connection · NBF as each clears the Bar. Development
continues **in parallel**, now serving the funnel (fix friction that blocks engagement),
not adding features.

---

## 6. The Month-9 Marketing Trigger (non-negotiable)

> **On 30 Sep 2026, marketing starts — even if the Focused-8 are not 100% done.**

This is the **forcing function** against the single biggest failure mode (perfectionism
eating the calendar until month 12 arrives with zero distribution). At the trigger:
- Launch every Focused-8 app that clears the Professional Bar. If an app is at ~80%,
  launch it as **preview** (honest) rather than delay the campaign.
- The domains deadline (month 12) leaves only ~3 months for adoption to compound —
  adoption is the **slowest, least-controllable** variable, so its clock must start on time.

---

## 7. What "start marketing" means (Phase 2, day 1)

The kit is ready — no new copy needed. Day-1 actions (all assets exist in `marketing/`):
1. **Self-verify** the referral loop end-to-end (invite → first subscription → both get
   the PRO month) — confirm the growth engine before promoting it.
2. **Soft-validate**: 5–10 real Pioneers on each launched app; watch, fix friction.
3. **Post Wave 1** (`launch-plan.md`) + pin **Founding 100** + **Invite & Earn**.
4. Answer "is this real?" with `whats-live.md`; objections with `faq.md`; DM merchants /
   developers / Pioneers with `outreach.md`.
5. Tag every link (UTM + `?ref`) to measure what works.

---

## 8. Risk register

| # | Risk | Severity | Mitigation |
|---|------|----------|------------|
| R1 | "Professional" becomes a moving target → month 12 with no marketing | **P0** | The **month-9 hard trigger** (§6) + the **written Bar** (§4) |
| R2 | Domain claim actually requires *active users per app*, not just "app done" | **P0** | **CONFIRM the exact Pi Core Team requirement.** C-133 §6's "≥5 KYC Pioneers/app" is TEC's *internal* doc, not a verified Core-Team rule. If users ARE required → start micro-distribution on the Focused-8 **now**, don't wait for month 9 |
| R3 | Weak first impression burns Pi credibility | P1 | The Professional Bar + **soft-validation before** any broad push |
| R4 | The other 16 apps read as "abandoned" | P2 | Keep them deployed + honestly **"preview"** (`whats-live.md`); frame as phased |
| R5 | Marketing lead-time underestimated | P1 | Assets **pre-built** (done); Wave 1 ready; trigger is a fixed date |
| R6 | Focus set is wrong / a Focused-8 app underdelivers | P2 | Soft-validation surfaces it; swap in a runner-up (Life / Alert) before its push |

> **R2 is the one open question that can invalidate the whole timeline.** Resolve it first.

---

## 9. Definition of done (for THIS plan)

```
□ By 30 Sep 2026: the Focused-8 each pass the Professional Bar (§4)
□ Each Focused-8 app soft-validated with ≥5 real Pioneers before its public push
□ Marketing Wave 1 live at the month-9 trigger (§6) — unconditional
□ Referral loop self-verified end-to-end before it's promoted
□ By Dec 2026 (month 12): the Focused-8 on track for their Pi domains
□ The other 16 remain deployed + honestly labelled "preview" throughout
```

---

## Related Documents

- **C-133** Platform Adoption & Growth Governance — the growth *rules* this plan executes
- **C-134** Pioneer Runtime Charter — the onboarding runtime (Founding 100)
- **C-30** App Blueprints / build sequence — this plan is a focus layer over it, changes nothing
- `architecture/app-fleet.yaml` — per-app deployment status (the Focused-8 are all deployed)
- `marketing/` — the launch kit executed in Phase 2 (`launch-plan.md` · `whats-live.md` ·
  `faq.md` · `outreach.md` · `launch-posts.md`)
- **ADR-012** (C-64) — referral reward = gift subscription (the growth engine, verified before promotion)
