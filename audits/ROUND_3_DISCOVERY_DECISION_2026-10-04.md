# Round 3 — Product Discovery Experiment, not an Evidence Engine build

**Date:** 2026-10-04 · **Session:** 56s
**Truth State:** [Current State] (the code facts) / **Decision:** ACTIVE — the owner's, this session
**Governance State:** [Governance Approved] — Product/Growth governance (C-133 · C-134)
**Verification:** [Code Verified] for §1 (a search, see below) · the rest is a decision, not a result

> Read this before starting any Round 3 work. A specification written outside this repository
> calls most of a "Round 3 Evidence Engine" **SEALED**. None of it exists in code.

---

## 1. What is built and what is not

A specification, *TEC Round 3 Master Engineering Specification v1.1* (a .docx written in
another conversation), describes a 19-stage "Pioneer Evidence Engine" — task assignment,
session telemetry, observed/declared/derived evidence, reconciliation, friction detection,
canonical records, fingerprints, immutable snapshots, analytics and full replay. It labels
Phases 1–4.4 and 5.1–5.4 **SEALED / RUNTIME VERIFIED** and calls 5.5–5.7 the remainder.

**Checked on 2026-10-04:** every one of the 28 repositories on GitHub (`main` and every remote
branch) and this KB were searched for the spec's own names — `TaskEvent`, `AssignedTask`,
`ProductEvidenceRecord`, `EvidenceMapper`, `FrictionDetector`, `taskCatalogId`, the Phase 2
index `one_active_task_per_session_logical_task`. **No match anywhere.**

So "SEALED" there means *the design was closed*, not *the code exists and passed its gates*. The
spec says itself that a status label means nothing until its runtime gates pass. **The whole
Engine is unbuilt.**

## 2. The decision

```
1. Interview          (no code)  — the 2026-08-16 decision, still ACTIVE
2. Funnel             (small)    — Campaign Funnel Instrumentation
3. Round 3 MVP        (small)    — one mission (1–3 apps, the Pioneer's pick), then look at the data
4. Evidence Engine    (deferred) — only when real data shows the need
```

- **Round 3 is a Product Discovery Experiment.** It asks why a Pioneer enters, stops or
  finishes. It is not "Round 2 with more tasks". Three tasks × 1π adds friction and teaches
  nothing about why only 5 of 100 took part.
- **"They are afraid of a hacker" is a hypothesis, not a finding.** Nothing in the KB
  establishes it. `PIONEER_ACQUISITION_INTERVIEW_FIRST_2026-08-16.md` lists the candidate
  causes: too many apps / too long · confusing · technical · not enough value · other. A Trust
  Preview, if built, ships as an **A/B variable**, measured on start rate, completion rate and
  report rate. It is not built as a fix for an assumed cause.
- **The Engine spec is kept as the target architecture.** It is not deleted and not built now.
  Its implementation version is stored at `audits/EVIDENCE_ENGINE_TARGET_SPEC_v1.0_2026-10-04.md`.
- **Step 2 is built:** `CampaignEvent` and the funnel in tec-core-backend #366, the stop-reason
  card and the admin funnel in tec-app #275.

## 3. Step 2 — Campaign Funnel Instrumentation (not "Evidence Engine")

It answers the one question the Engine cannot: where did the people who never started go?
Someone who never starts a task has no task events at all.

```
CAMPAIGN_VIEWED → TRUST_PREVIEW_VIEWED → APP_SELECTED → SESSION_STARTED
               → TASK_COMPLETED → REPORT_SUBMITTED
```

One append-only table (`id · campaignId · participantId · eventType · occurredAt · metadata`).
It does not need fingerprints, snapshots, reconciliation or replay. It is shaped so that a later
Engine can read it, and that is the only nod to the Engine. It is built on what already runs:
the Round 2 campaign engine (identity-service), `ArrivalReport`, and Analytics.

## 4. Step 3 — Round 3 MVP

`Choose → (Trust Preview variant) → Discover → Report → reward after verification`

- **One mission to start, not three.** Whether the number of steps is itself the friction is
  not yet known — which is why the mission's size is the Pioneer's choice (below).
- **Built on what exists:**
  - missions, the claim form and the chain-checked `Mark sent` — the Round 2 campaign engine;
  - the report — the feedback module in identity-service;
  - Find — Explorer's real index.
- **The report is Declared evidence only.** "The Pioneer reported X" — never "the Pioneer
  proved X".
- **The reward is downstream.** It is not a score. There is no Pioneer level, rank or quality
  score (C-134).
- **Payouts go out by hand** (`Mark sent`) until TEC's A2U wallet is approved (C-02 row 6).
- **Mission scope is the Pioneer's choice: 1 to 3 apps**, rewarded per app whose report is
  accepted (owner, 2026-10-04). The owner thinks one app is too little; the only Round 2 comment
  asked to focus on one app instead of 24. The choice settles it as a measurement: how many
  pick 1 versus 3 is the answer.
- **One optional suggestion per app, with the report** (owner, 2026-10-05): *"What update would
  you suggest for this app?"* (≤ 500 characters). It pays nothing and is read with each report
  before payout. It **replaced** the continuity question that shipped first ("If your phone were
  lost today, would your Pi be safe?"). The owner chose to spend this round's question on the
  apps themselves. C-106 §10a is therefore undecided, and no measurement is running for it.

## 4a. Step 3 is built (2026-10-04) — and off until the owner opens it

tec-core-backend #373 (identity-service campaign module) and tec-app #277 (the Hub page).

- **Switch:** `CAMPAIGN_MODE=pick` on identity-service. If it is unset, the campaign runs exactly
  as Round 2 did.
- **The apps:** `CAMPAIGN_APPS` limited in code to the launch set (C-135 §2.1: commerce,
  ecommerce, explorer, zone, connection, nbf, analytics, assets). Hub is not a mission.
- **Pick:** 1 to 3. The latest choice stands until claim, but an app already reported on stays
  picked.
- **Report:** 10–1000 characters, accepted only after the app itself reported the arrival this
  round (ArrivalReport, after that app's own Pi sign-in — F3). Its C-47 §10 status is `partial`:
  declared plus one observation. An unobserved arrival is refused, not stored as `unknown` (E1).
- **Where the report lives:** with its mission (`campaign_missions`), not in the feedback inbox.
  It is campaign evidence that is read before a payout (`GET /identity/campaign/reports`, admin).
  This deviates from §4's "the feedback module".
- **Reward:** `CAMPAIGN_REWARD_PI` × picked apps. It is frozen on the claim, so `Mark sent`'s
  chain check asks for that amount. Budget = seats × reward × 3 at most.
- **The round serves the domains Pi has not opened (owner, 2026-10-05)** — `CAMPAIGN_TARGET=short`
  (tec-core-backend #374). This replaces "the launch set only" for this round:
  - **Pi's word decides, not our count.** Every app stays on the list until the owner adds it
    to `PI_CLAIMED_APPS` (the domains Pi has accepted, from Pi's Domains screen). Our arrival
    count only orders the list, fewest first. Until F3 it counted page loads, so it reads 5/5
    for apps Pi still calls "Requirements Not Met" (C-02 row 2).
  - A Pioneer is not excluded from apps they "visited" before. Those records were page loads,
    and the people they would exclude are the ones Pi never counted.
  - The arrival is the moment Pi counts: this app's own Pi sign-in (F3), now in all 23 apps.
    The last 13 are dx, elite, epic, estate, fundx, insure, legend, nexus, nx, titan, vip,
    system and brookfield.
- **A claim is per round** (tec-core-backend #374, 2026-10-05). Until then a claim was for
  life (`owner` and `wallet_address` were unique across all rounds), so Round 2's claimants could
  not take part in Round 3, and their old claims held seats. Claims now carry a `round`, and the
  uniques are per round. A claim from before this change is `legacy` and belongs to the round
  it was made in. One transfer still pays one claim across all rounds.
- **Suggestion:** an optional field beside every report, stored with its mission
  (tec-core-backend #375, tec-app #278). The continuity question and its counts were removed.

To open the round:

```
CAMPAIGN_MODE=pick
CAMPAIGN_TARGET=short          # the domains Pi has not opened, read live
CAMPAIGN_APPS=                 # empty; or a list, to narrow it
CAMPAIGN_VISITS_FROM=<the round's start, ISO>
CAMPAIGN_REWARD_PI=1          # per app
```

## 4b. The round as it runs — three assigned apps, reviewed (owner, 2026-10-05)

The owner tested the pick MVP (§4a) and changed it. The decision, with the owner's own three
corrections:

| Stage | Decision |
|---|---|
| Assignment | **Exactly 3 apps, assigned by the service, not chosen.** The service skips apps the Pioneer already holds or tested in an earlier round, spreads the round (fewest open assignments first, a cap per app), and works through the domains Pi has not opened. A swap is allowed for a technical problem, with the reason kept as evidence (2 per round). |
| Report | **What happened** (required) · **a problem? yes / no** (required) · **the problem** (where, what you did, what you saw) **or what was clear or useful** (required) · a suggestion (optional). |
| Why that shape | A report that found nothing wrong is evidence too. The round looks for **product evidence, not bugs only**. Requiring a problem would bias every report toward finding one. |
| Review | The owner reviews each report: **APPROVED**, or **NEEDS_REVISION** with a note the Pioneer reads and answers. **NEEDS_REVISION ≠ REJECTED.** The goal is better evidence, not catching Pioneers out. |
| Acceptance bar | Shown before anyone writes: *"A report is approved when it describes a real experience specifically. If you hit a problem, say where it happened and what you saw. If you did not, say what you tried and what was clear or useful. General words like 'nice' are not enough. We are not asking you to criticise TEC: try it, and tell us what happened."* |
| Reward | **3/3 approved → 3π**, claimed on a button, then the same `Mark sent`. |

```
ASSIGNED → SUBMITTED → (NEEDS_REVISION → SUBMITTED)* → APPROVED
3/3 APPROVED → claim 3π → Mark sent
```

- **The round as opened (owner, 2026-10-05): the same 6 apps for everyone, 0.5 π each, 3 π in all.**
  The 6 are **tec · commerce · life**, domains Pi opened but still under Core Team review, and
  **ecommerce · assets · zone**, domains not opened. The review is taking long, perhaps because Pi
  asks for real utility beyond the 5 KYC'd users, so the round collects product evidence on
  opened and unopened domains alike. The service assigns the whole list, offers no swap (there is
  nothing to swap to), and treats the Hub as arrived (the Pioneer is signed in to it).
  Settings: `CAMPAIGN_TARGET` unset · `CAMPAIGN_APPS=tec,commerce,ecommerce,assets,life,zone` ·
  `CAMPAIGN_APPS_PER_PIONEER=6` · `CAMPAIGN_REWARD_PI=0.5`.
- **Reward raised before the announcement (owner, 2026-10-05): 0.85 π each, 5.1 π for all six.**
  3 π was judged low for six reports. 5 π does not divide into six (0.8333… × 6 = 4.9999998), so
  the per-app reward rounds up to 0.85: the page shows a clean number and nobody receives less than
  5 π. Budget ceiling: 100 seats × 5.1 π = 510 π. Raised before any claim of the round, because the
  amount is frozen on each claim. If the stop reasons show "too many apps / too long", the lever is
  `CAMPAIGN_APPS_PER_PIONEER`, not the reward. Setting: `CAMPAIGN_REWARD_PI=0.85`.
- **25 seats per round, then the next six apps (owner, 2026-10-05).** `CAMPAIGN_SEATS=25`: the
  budget is 25 × 5.1 π = 127.5 π a round, and the next round is six other apps at the same reward.
  Seats are counted per round (claims carry the round), so a new round is a new
  `CAMPAIGN_VISITS_FROM` and a new `CAMPAIGN_APPS`; a Pioneer of this round may take the next one.
  A seat is taken at the CLAIM, after all six are approved — so Pioneers still working when the
  25th claim lands find the round full.
- **Coverage arithmetic (for a `short` round):** 13 domains × 5 Pioneers ≈ 65 sign-ins ≈ 22 Pioneers at 3 each. That is a
  target, not a guarantee: assignments overlap, and the Pioneers who drop out leave gaps.
- **Built on the campaign engine,** as §4 required (tec-core-backend #376, tec-app #280). It
  replaces the pick-1-to-3 flow and the one-question MVP (§4a). Still not the Evidence Engine
  (§5): if the reports prove their value, the Engine is built from them, step by step.

## 5. When the Engine earns its build

When the MVP's real data raises questions only it can answer: did the Pioneer do what they said
(observed vs declared)? Then retries, friction, lineage, reproducibility. It is built
incrementally from the funnel table, and never as 19 stages ahead of the need.

## 6. Ownership (unchanged, recorded once)

| Layer | Owner | Does NOT |
|---|---|---|
| Pioneer Runtime | C-134 — onboarding / journey | carry research evidence |
| Round 3 campaign | C-133 — growth layer | score Pioneers |
| Evidence (when built) | its own layer | own rewards or analytics |
| Analytics | measurement | collect or rule on evidence |
| TEC AI | interpretation (C-104) | own or write evidence |

## 7. Open — the owner

- **Were the 3 verified non-completers ever sent the interview DM** (2026-08-16 §4 — the message
  is written there, EN + AR)? If they were, their answers decide step 2's shape. If not, sending
  them is step 1.

## Related Documents

- `audits/EVIDENCE_ENGINE_TARGET_SPEC_v1.0_2026-10-04.md` — the Engine's target spec, stored with
  its three adjustments for this platform (a module in identity-service, not a new service; it
  starts from `CampaignEvent`; the trigger in §5 above)

- `audits/PIONEER_ACQUISITION_INTERVIEW_FIRST_2026-08-16.md` — the active interview-first decision
- `audits/CAMPAIGN_SURFACES_ENGINEERING_REPORT_2026-09-19.md` — the Round 2 engine this builds on
- `C-133` growth governance · `C-134` Pioneer runtime · `C-104` TEC AI
