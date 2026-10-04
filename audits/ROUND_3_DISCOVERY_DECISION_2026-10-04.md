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
3. Round 3 MVP        (small)    — one mission, then look at the data
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
  not yet known.
- **Built on what exists:**
  - missions, the claim form and the chain-checked `Mark sent` — the Round 2 campaign engine;
  - the report — the feedback module in identity-service;
  - Find — Explorer's real index.
- **The report is Declared evidence only.** "The Pioneer reported X" — never "the Pioneer
  proved X".
- **The reward is downstream.** It is not a score. There is no Pioneer level, rank or quality
  score (C-134).
- **Payouts go out by hand** (`Mark sent`) until TEC's A2U wallet is approved (C-02 row 6).

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

- `audits/PIONEER_ACQUISITION_INTERVIEW_FIRST_2026-08-16.md` — the active interview-first decision
- `audits/CAMPAIGN_SURFACES_ENGINEERING_REPORT_2026-09-19.md` — the Round 2 engine this builds on
- `C-133` growth governance · `C-134` Pioneer runtime · `C-104` TEC AI
