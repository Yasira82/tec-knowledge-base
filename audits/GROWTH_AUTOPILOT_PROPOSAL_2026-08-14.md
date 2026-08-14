# TEC Pioneer Growth Autopilot — Proposal & Deferral Decision

**Date:** 2026-08-14
**Truth State:** [Planned State] (the idea) / **Decision:** DEFER — do NOT build now
**Governance State:** [Draft]
**Verification:** [Documentation Verified] (against live Founding-100 metrics below)
**Author:** Growth/marketing layer — recorded during the Founding-100 pilot
**Numbering:** if promoted to a constitutional doc later, a human assigns the `C-number`
(RULE 6 — an AI must not mint one). This lives in `audits/`, outside the C-NN index.

---

## 1. What was proposed

A standalone **TEC Pioneer Growth Autopilot** layer above the ecosystem:

- **Content Engine** — auto-generates daily posts (AR/EN + per-channel: Telegram / X /
  Facebook / groups) with A/B CTA variants, honesty-rule constrained (no guaranteed
  returns / financial rewards — C-133).
- **Campaign Engine** — every campaign gets `campaign_id` + `source` + `variant`; tagged
  landing links → `/pioneers`.
- **Funnel Analytics** — `campaign → landing → Pi Browser → joined → quest_start →
  24/24 → founding_claimed`, reusing `tec-analytics-service` (NOT a new analytics stack).
- **Growth Controller / Decision Engine** — reads the funnel, decides *continue* vs
  *change CTA/content* (e.g. "high joins, low completion → conversion problem").
- **Daily AI Report** + **Human-in-the-loop approval queue** (Approve & Publish).
- Suggested home: a **separate repo/module `tec-growth-autopilot`** (growth/marketing,
  NOT `tec-core-backend` core infra).
- Proposed **event taxonomy:** `pioneer_landing_view`, `pioneer_pi_browser_open`,
  `pioneer_app_open`, `pioneer_quest_start`, `pioneer_quest_complete`,
  `founding_pioneer_claimed`, `campaign_cta_click`.
- **North Star:** Qualified Pioneer → Completed Quest → Founding Pioneer (not raw views).

## 2. Decision — DEFER (not now)

**Do not build the Autopilot at the current scale.** It is premature over-engineering.

### Rationale
1. **Scale mismatch.** Live metrics at decision time: **5 joined · 2 completed · 2
   founding claimed · 1 active campaign.** A new repo + content AI + decision engine +
   dashboard + deployment is weeks of work for a goal reachable by hand (need ~3 more
   completers).
2. **It optimizes the wrong end of the funnel.** Top-of-funnel (reach/interest) already
   works — the Reddit post hit #1 on r/PiNetwork and produced 2 tagged pioneers
   (`by_source: reddit = 2`). The real bottleneck is **completion** (join → open all 24 +
   KYC). More generated content does not fix completion; more posts ≠ more completers.
3. **Opportunity cost.** Effort spent building the autopilot is effort NOT spent getting
   the completers that unlock the `.pi` domains already won at real Pi cost (tec.pi claim
   pending; ~23 more each require ≥5 KYC pioneers engaged per app — Pi domain rule).
4. **No data to automate on.** A decision engine tuned on n=5 / 1 campaign fits noise, not
   signal. The "Growth Controller" thresholds need volume that does not exist yet.
5. **Same doctrine as C-104 (TEC AI).** The platform already rules that the
   intelligence/automation layer is built **on top of a running economy**, not before it
   (C-104 §10 "V1 now / V2 after launch"; C-121 "reasoning requires observation"). A
   "Growth Autopilot AI" before there is growth to automate is the same premature trap.

## 3. What to adopt NOW instead (cheap, no new repo)

- **Manual growth** to ~25 pioneers: personal WhatsApp/DM + Reddit follow-up + hand-holding
  through the full 24-app quest. Highest conversion at this stage; the "autopilot" now = a
  human + the ready templates.
- **Invest engineering in the real bottleneck = completion**, not a content factory: reduce
  quest friction on `/pioneers` (the `keepalive` fix that made server-side opens record was
  exactly this class of work — tec-app PR #143).
- **Lightweight tracking already exists:** first-touch `utm_*` capture → `tec_src` cookie →
  `pioneer/open` → `by_source` groupBy on `/api/bff/pioneer/stats`. Variant A/B is already
  possible via `utm_content`. No new system required to measure per-channel conversion.

## 4. Trigger to revisit (build it when TRUE)

Promote from DEFER to BUILD when the **manual** loop becomes the bottleneck, i.e. roughly:

- **~100+ pioneers** and **multiple active campaigns** running in parallel, AND
- enough funnel volume that per-channel conversion differences are statistically real
  (not n=5 noise), AND
- Analytics + Zone live enough to feed a decision engine honest signals (C-121).

At that point the **good** parts of the proposal are worth building — reusing
`tec-analytics-service`, the event taxonomy in §1, human-in-the-loop publishing first, and
keeping it in a growth module (not core). A full spec (DB schema + API + event taxonomy +
dashboard + decision rules + deploy) can then be promoted to a numbered C-doc (human assigns
the number, RULE 6).

## 5. Honest status

- The **North Star metric** (Qualified → Completed → Founding) is correct and already in use.
- The **defer decision** is a judgment call for the pilot phase (n=5), not a rejection of the
  concept. It is a **[Draft]** record; revisit at the trigger in §4.
