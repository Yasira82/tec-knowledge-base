# TEC Life — First Session Spec (Draft for review)

> Truth State: **[Planned State]** · Governance State: **[Draft]** · Verification: **[Code
> Verified]** for every "today" statement (§1, the backup defaults, the AI provider chain), read on
> `tec-core-backend` main on 2026-10-17; the production backup settings **[Runtime Verified]** the
> same day (§6.3). Everything else is not built.

> **Status: r4.5 — Final Review Draft, for the owner's review only.** Accepting it would approve
> the wording of the spec — **not** building it, and not any change to a repository or code. Its
> open decisions (§8, plus the backup retention period and the model provider's terms) are left for
> the owner, not chosen here.
> (After the review of r4.5: identity's ledger rules are written as its own contract, L1–L4, each
> tested in identity — wording only, the design is unchanged.)
> r4.5 makes "not recorded" **decisive** in §6.4: Life never trusts a lookup that found nothing; it
> asks identity to *resolve* the id, which either finds the row or seals it as `VOID` in the same
> transaction, so a late write can never turn it into a deletion — and the block is lifted only on
> VOID. The `request_id` is bound to the full scope (user, kind, entity, category).
> r4.4 added one case to §6.4: **the unknown outcome** — identity may record a deletion while its
> answer never reaches Life. A fixed `request_id` reused on every retry, an idempotent write, a
> status query before any "not deleted", and the scope blocked while the outcome is unknown.
> r4.3 clarified §6.4 only: what Life does
> when identity's ledger cannot be read (the whole service at start; only the blocked scope while
> running; the whole service after 5 minutes of failed sweeps), one read gate for every path, and a
> test that proves rows in scope are **unreadable by any path** — routes, export, internal routes,
> background jobs, model calls — until the replay and its verification finish.
> r4.2 changed §6.4 only: a deletion is
> **recorded in identity's ledger first**, before Life touches anything, so no request can be lost
> between two steps; a refusal happens before any change; a sweep on every start re-applies open
> requests before Life serves anyone.
> r4.1 was a limited clarification answering
> the fourth review: a refusal creates **no record tied to the person** (§2 S1, §5.2) · data asked to
> be deleted is **out of use at once**, and "deleted" is shown only once confirmed (§6.4) · M6's
> privacy claim is stated no stronger than it is, and small counts are not shown (§7) · G5 covers
> **the browser** too (§7) · the replay scope is fixed **per kind of request** (§6.4).
> r4 answered the third review:
> **storing the person's words needs its own consent** (`PROBLEM_RECORD`, separate from
> `PROBLEM_HYPOTHESES`) and without it nothing leaves the page (§2 S1, §5.1) · **G5 joins the
> stop guarantees** and its test covers application, error-reporting and monitoring output, error
> paths included (§7) · **the deletion ledger has a contract** — written first, replayed
> idempotently, and the service stays closed after a restore until a verification shows zero (§6.4) ·
> **minimisation before the model provider**, with a plain statement that it is not anonymity
> (§5.4) · **M6 is an aggregate counter** with no person attached (§7) · **the classifier is tested**
> in Arabic and English, direct and indirect, and drops on doubt (§4 rule 6).
> r3 answered the second review (Low only, derived level, link rationale, distinct occurrences,
> withdrawal vs deletion, INCONCLUSIVE, re-erasure after restore, testable never-infer list, M3 not
> a target); r2 the first (threshold, level rule, withdrawal, logs and provider, deletion over
> history, a useful session with no hypothesis).
> Saved to the knowledge base as a **[Draft]** on the owner's decision (2026-10-17), in a PR that is
> **not to be merged** until the owner says so. No code.
> Does not amend C-106 and does not build anything of the Islamic reference layer.
> Approved for writing by the owner on 2026-10-17. **Building: stage 1 only** ("Talk it through
> without saving", §8) was approved by the owner on 2026-10-17; stages 2 and 3 are not.
>
> **Grounded in:** the Core Model v1.0 with the five refinements of the owner's Report 8 (what the
> owner calls v1.1) — `audits/LIFE_HUMAN_DEVELOPMENT_REPORTS_2026-10-17.md` · the goals in
> `audits/LIFE_VISION_HUMAN_DEVELOPMENT_2026-10-17.md` · and Life as it exists on
> `tec-core-backend` main (2026-10-17), checked line by line where this spec says "today".
>
> **Decisions this spec does NOT settle:** Phase 0 (whether to build) · the C-106 charter change ·
> who reviews the Islamic foundation · the confidence formula of Core Model §7 (this spec uses a
> narrower rule table for v1 instead — §4 rule 3; nothing in it is left open) · the backup
> retention period · the model provider's data terms (§5.4). The reviewer's recommendations on the
> questions of §8 are recorded there **as recommendations, not decisions**.

---

## 0. What one session must prove

That in **one sitting** Life can help a person (1) put a recurring problem into words, (2) see
two or more possible explanations side by side — with how sure Life is of each, and what it does
not know — and (3) choose, if they want, one small experiment with its success measure fixed now.
Without Life claiming knowledge it does not have, and without keeping anything the person did not
agree to keep.

Out of scope for session 1: patterns, trajectory, state, gaps, decision scenarios, any religious
reference, anything shown to another person or app.

---

## 1. Where it starts from (today, Code Verified)

| Exists today | Used by this spec as |
|---|---|
| `life_goals` + `life_goal_progress` (append-only) | an experiment may become a goal with steps, **only if the person asks** |
| `LifeConsent` (per category; no row = no) | the gate for storage and for every inference (§5) — needs **two** new categories and two fields |
| `life_audit_logs` (counts, never content) | every consent change, correction, export and erasure |
| `eraseAccount` / `DELETE /identity/life/data` | extended to the new tables in the same change (§6) |
| TEC AI context door `GET /identity/life/context/:username` | does **not** serve the new tables in v1 (§5.6) |
| Weekly check-in (`CHECKIN` consent) | the only way Life may remind about a follow-up |
| **No export route** | a gap — §6.2 makes it a requirement |
| **No deletion ledger** | a gap — §6.4 makes it a requirement |

---

## 2. The session, step by step

Each step says **what Life says/asks**, **what it writes**, and **what it must not do**.

### S1 — Opening and two separate choices

- **Says:** what the session is (understand a recurring problem, compare explanations, optionally
  try a small change), what it is not (no diagnosis, no judgement, no advice it cannot ground), and
  that everything kept can be corrected, exported or deleted.
- **Asks two questions, one after the other, each with its purpose in one sentence (§5.1).
  Neither is pre-ticked, and neither implies the other:**
  1. **Keep what you tell me?** (`PROBLEM_RECORD`) — "Life keeps your description of the problem
     and of when it happened, so you can come back to it, correct it, export it or delete it."
  2. **Suggest possible explanations?** (`PROBLEM_HYPOTHESES`) — "Life sends what you wrote to an
     AI model to suggest possible explanations, and keeps them so you can test and correct them."
     Asked only if (1) is yes — an explanation cannot be kept about words that are not kept.
- **Writes — a grant only:** for each **yes**, a consent row with `purpose_version` and
  `granted_at`, and an audit row (counts and ids only). **A no writes nothing tied to the person** —
  no consent row, no audit row: absence is the denial, as for every Life category today (a
  `granted: false` row is never written). Refusals are counted **only** in the aggregate counter of
  §7 (`date · metric · value · count`), which holds no user id and no session id. If (1) is
  **no**, nothing at all is written about the person — see the next point.
- **Without `PROBLEM_RECORD` — "talk it through without saving":** the screen says so in one
  line: *"Nothing you write here will be saved. When you close this page it is gone."* S2–S3 run
  **in the page only**: the text is never sent to the server and never to the model provider. S4 is
  skipped. S6 offers the observation plan as text the person can copy for themselves; no experiment
  is stored. S7 shows the summary on screen only. The single trace is the aggregate session counter
  of §7 (a date and a step reached — **no user id, no session id, no text**).
- **Must not:** store any S2–S3 text without `PROBLEM_RECORD` · send any text to the model without
  both grants · start S4 without both grants · treat a grant for one as a grant for the other.
  With `PROBLEM_RECORD` but not `PROBLEM_HYPOTHESES`, S2–S3 are kept as declared and the session
  ends at S7 with no explanations formed.

### S2 — The problem, in the person's words

- **Asks:** "What keeps happening that you would like to change?" — one free-text answer.
- **Writes (only with `PROBLEM_RECORD`):** one `LifeEvent` — `kind: problem_statement`,
  `provenance: DECLARED`, the text as written.
- **Must not:** rephrase it into a trait ("you procrastinate"), name a cause, or store a label.

### S3 — Occurrences (clarify, at most 5 questions)

- **Says once, before the questions:** "When you mention other people, describe them by their role
  — *my manager*, *a friend* — rather than by name." (§5.4)
- **Asks** for the last two or three times it happened: roughly when, where/with whom/under what
  pressure (only what is relevant), what was done, what followed.
- **Writes (only with `PROBLEM_RECORD`):** one `LifeEvent` per occurrence — `kind: occurrence`,
  `provenance: DECLARED`, `occurred_at` (approximate allowed, marked `approximate: true`),
  `context` (a small object: only the fields the person gave), `recalled: true`,
  `distinct_confirmed`.
- **Distinct, not repeated:** for each occurrence after the first, Life asks "Was this a different
  time from the one you described before?" — only a **yes** sets `distinct_confirmed: true`. Two
  accounts of the same incident count as **one** occurrence.
- **Must not:** treat the person's account as an observed fact; ask about health, faith, family
  conflict or other sensitive matters unless the person brought them up; ask more than 5 questions.

### S4 — Possible explanations (only with both grants, only if one qualifies)

- **A count of occurrences is not the threshold.** An explanation may be shown only if it passes
  the evidence conditions in §4 rule 5 — at least two described occurrences that fit it, a stated thing
  that would count against it, and none of the drops in §4 rule 6.
- **With one occurrence** Life still explores: it asks about context and what happened, and helps
  the person describe it well — but forms no explanation.
- **If no explanation qualifies:** Life says so — "That is not enough yet to compare explanations"
  — and offers the observation plan in S6.
- **If explanations qualify:** the text, minimised (§5.4), goes to the LLM, which proposes up to 4
  candidates; each is validated (§4) before it is shown. **Only those that qualify are shown — one,
  two, or more. Life never invents a second one to make a comparison.** Each is shown with:
  - the explanation, as behaviour in a context ("when the information is incomplete, the decision
    waits") — never as a trait;
  - **which described occurrences fit it**, and which do not;
  - **what would count against it** (so the person can test it);
  - its **level: Low** (§4 rule 3 — in v1 always Low);
  - for each fitting occurrence, **why it fits** in one line (the link's rationale) — the person
    can remove a link they think is wrong (S5);
  - and always a last line: **"Something else / I don't know yet"** — so a single shown
    explanation is never presented as the only possibility.
- **Writes:** one `LifeClaim` per shown explanation — `status: PROPOSED`, `provenance: INFERRED`,
  `model_version`; and its links (`SUPPORTS` / `CONTRADICTS`) to occurrence events, each with a
  `rationale` and `proposed_by: MODEL`. No level is stored — it is derived (§4 rule 3). Dropped
  proposals are **not** stored; only their count, by drop reason, goes to the audit row.
- **Must not:** show one explanation as *the* cause · name a psychological cause the person did not
  raise (fear, trauma, laziness) · attribute an intention · infer anything in §5.3 · rank by
  anything but the visible support.

### S5 — The person's reading

- **Asks:** for each explanation — "Sounds like me / Doesn't fit / Not sure"; and "Is there an
  explanation you'd add?"
- **Asks** also, per link: "Does this occurrence really fit?" — the person may remove a link.
- **Writes:** on each claim, `person_reading: PLAUSIBLE | DOES_NOT_FIT | UNSURE`; a removed link is
  marked `rejected_by_person` and stops counting. If removing links leaves an explanation below the
  conditions of §4 rule 5, it is withdrawn from view at once. An explanation the person adds becomes
  a `LifeClaim` with `provenance: DECLARED`.
- **Must not:** turn "sounds like me" into validated knowledge. **A person's agreement is evidence
  about plausibility, not about cause** — the claim stays `PROPOSED`.

### S6 — One small step (optional): an experiment, or an observation plan

**A. Observation plan — available even when no explanation was shown, and without any grant.**
"Next time it happens, note when, where, and what you were waiting for." With `PROBLEM_RECORD`,
Life records nothing until the person notes an occurrence (S3's shape); without it, the plan is
text on screen for the person to copy. Its value: the person leaves with a clearer description of
the problem, a timeline of what they recalled, and a way to see it more clearly next time —
without Life claiming anything. This is what makes a session with no explanation still useful.

**B. Experiment — only to test a shown explanation (so only with both grants).**

- **Asks:** whether they want to test one explanation. If yes, designs it **with** them:
  - the change to try (one, concrete, small);
  - duration: **≤ 14 days**;
  - the baseline: what the described occurrences showed — labelled **recalled baseline**;
  - the success measure, fixed **now** (e.g. "decisions taken within 2 days of having the
    information", counted by the person);
  - what result would count **against** the explanation;
  - things that could confound the result, named in plain words.
- **Writes:** one `LifeExperiment` — `status: AGREED`, `tests_claim`, the fields above,
  `starts_on`, `ends_on`. Nothing is written if the person declines.
- **Must not:** start an experiment the person did not explicitly accept · change its success
  measure after it starts (a new measure = a new experiment) · promise an outcome.
- **Optional:** if the person asks, the experiment's change can become a Life goal with its steps,
  through the existing goal flow (nothing saved until they tap Add).

### S7 — Close

- **Says:** a short summary in three parts — **what you told me** (declared), **what we think might
  explain it** (hypotheses, with their levels), **what we don't know**. What was kept and what was
  not. How to correct, export or delete any of it. The follow-up date, if there is an experiment.
- **Asks (optional, skippable):** M6 — "Do you see the problem more clearly than before?"
  (Yes / Somewhat / No). Stored only as described in §7.
- **Writes:** with `PROBLEM_RECORD`, an audit row `life.session.closed` with counts; without it,
  only the aggregate counter.
- **Reminder:** only with `CHECKIN` consent; otherwise the person returns on their own.

### After the experiment (defined now so session 1 can promise it honestly)

- The person records what happened → `LifeEvent kind: outcome, provenance: DECLARED` linked to the
  experiment, with two answers: the **measure** as counted, and **adherence** — "Did you do it as
  agreed? Fully / Partly / Not really".
- The experiment gets one **reading** — never a level change:

  | Reading | When |
  |---|---|
  | `ENCOURAGING_NOT_SETTLED` | adherence **Fully**, the measure moved in the expected direction, `counts_against` not met |
  | `NOT_SUPPORTED` | adherence **Fully**, and the measure did not move or `counts_against` was met |
  | `INCONCLUSIVE` | adherence **Partly** or **Not really** · no outcome recorded by `ends_on` + 7 days · the measure missing or changed |

  The claim's status follows: `ENCOURAGING_NOT_SETTLED` → stays `PROPOSED`, shown as "the result is
  encouraging, but the cause is not settled"; `NOT_SUPPORTED` → `NOT_SUPPORTED`; `INCONCLUSIVE` →
  stays `PROPOSED`, shown as "we can't tell from this". **The level stays Low in v1** — an upgrade
  needs a rule built on independent evidence, which the Core Model has not settled yet.

---

## 3. What is written — minimal entities

Four new tables in **tec-life-service**, all keyed by identity's `users.id` like every Life table,
and written **only with `PROBLEM_RECORD`** (claims, links and experiments also need
`PROBLEM_HYPOTHESES`).

| Table | Fields (v1) | Immutable? |
|---|---|---|
| `life_events` | `id · user_id · kind (problem_statement · occurrence · outcome) · provenance (DECLARED · OBSERVED) · text · occurred_at · approximate · recalled · distinct_confirmed · context (json) · experiment_id? · adherence? (FULLY · PARTLY · NOT_REALLY) · measure_value? · created_at · retracted_at?` | **Yes** while kept — corrected by retraction + a new event (§6.1); deleted for real on request (§6) |
| `life_claims` | `id · user_id · statement · provenance (INFERRED · DECLARED) · status (PROPOSED · NOT_SUPPORTED · WITHDRAWN) · person_reading? · hidden_at? · hide_until? · model_version · supersedes? · created_at` | Revised by a **new version** (`supersedes`), the old one kept |
| `life_claim_links` | `id · claim_id · event_id · relation (SUPPORTS · CONTRADICTS) · rationale · proposed_by (MODEL · PERSON) · rejected_by_person · created_at` — **unique (claim_id, event_id)**, so one occurrence cannot both support and contradict the same claim | link rows |
| `life_experiments` | `id · user_id · tests_claim · change · baseline_text · success_measure · counts_against · confounders · starts_on · ends_on · status (AGREED · RUNNING · DONE · ABANDONED) · reading? (ENCOURAGING_NOT_SETTLED · NOT_SUPPORTED · INCONCLUSIVE) · hidden_at? · hide_until? · created_at` | measure fields frozen once `RUNNING` |

Plus two small non-personal tables: the aggregate counter of §7 (`date · metric · value · count` —
no user id, no session id) and, in **identity's** database, the deletion ledger of §6.4.

**Derived, not stored:** a claim's `level` and the kind of evidence behind it are computed when read,
from its non-rejected links, the distinctness of their events, and its experiments' readings — so
the stored data and what the screen says cannot drift apart.

**Not created in session 1:** Pattern · Trajectory (beyond today's) · State · Gap · Source /
ScholarlyInterpretation / Principle · SimulatedScenario. Context is a field, not an entity.

---

## 4. Rules that stop Life from claiming what it doesn't know

1. **No pattern from a session.** Session 1 never creates a Pattern. (Core Model: a single event
   never creates one; Report 8: recalled accounts of the same kind are not independent occurrences.)
2. **Declared ≠ observed.** Everything from S2/S3 is `DECLARED` and `recalled`. Nothing the person
   says becomes an objective fact.
3. **The level is a fixed label chosen by a rule table — not a formula, not the LLM's estimate.**
   Two things are kept apart: **evidence strength** (what kind of evidence exists) and the
   **person's reading** (whether it sounds right to them). Only evidence strength sets the level:

   | Claim state | `level` shown |
   |---|---|
   | `PROPOSED`, with or without an `ENCOURAGING_NOT_SETTLED` or `INCONCLUSIVE` experiment | **LOW** |
   | `NOT_SUPPORTED` · `WITHDRAWN` · hidden | not shown |
   | MEDIUM · HIGH | **not reachable in v1** |

   In v1 the only evidence is the person's recollection and their own report of an experiment —
   both declared, one person, short time. That is never enough to raise the level, so v1 does not
   pretend to. `person_reading` and experiment readings are shown beside the level and **never
   change it**. Raising a level needs a rule built on independent evidence; the Core Model's §7
   formula stays open for that later version.
4. **Absence is not evidence.** An occurrence the person did not mention neither supports nor
   contradicts anything. "Not enough" is an allowed, expected answer.
5. **Evidence conditions for showing an explanation** (all required — a minimum, not a proof):
   (a) at least two **distinct** (`distinct_confirmed`), non-retracted occurrences that fit it, each
   link with its rationale; (b) a stated, observable thing that would count against it **and could
   happen within an experiment's window** — an explanation that fits any result is dropped;
   (c) it is phrased as behaviour in a context; (d) it passes rule 6. Two occurrences that look alike
   do not mean one cause — which is why the level stays Low and the person can test it. Explanations
   are shown only if they qualify; **Life never pads the list** — a single qualifying explanation is
   shown with "Something else / I don't know yet", and zero is an allowed result.
6. **LLM proposes, rules validate — and a doubt is a drop.** A proposal is dropped before display if
   it: names a trait, diagnosis or character judgement · rests on no described occurrence · touches
   §5.3 · attributes an intention or a hidden motive. Checked in code, not left to the prompt:
   - (i) every link must point to an occurrence event of this person from this Life record;
   - (ii) a **separate classification call** labels each proposal against the §5.3 list and a fixed
     list of trait/diagnosis terms. **Any label drops it — and so does an uncertain answer, a
     malformed answer, a timeout or a failed call.** The classifier can only remove a proposal,
     never let one through on its own;
   - (iii) **a fixture suite, in Arabic and English**, run in CI and before every change to the
     prompt, the term list or the model: for each §5.3 item and each trait/motive kind, **direct**
     phrasings ("you are anxious" · «إنت قلقان») and **indirect** ones ("this may go back to how you
     were raised" · «يمكن ده راجع لخوفك من الفشل» · a diagnosis described without its name), each
     of which must be dropped; and acceptable behaviour-in-context explanations, each of which must
     pass (so the filter is not just "drop everything"). A release needs **every must-drop fixture
     dropped**. Fixtures are synthetic — written for the test, never taken from a real person;
   - (iv) results are logged as **counts only** (fixtures run · dropped · passed, by label; in
     production, proposals dropped by reason) — never the text of a fixture or a proposal;
   - (v) a human-reviewed sample of shown explanations feeds G3.

   **What this does not guarantee:** a classifier and a term list are a filter, not a proof — a
   phrasing nobody thought of can pass. That is why doubt drops, why the suite grows with every miss
   found in review, and why G3 is a stop condition, not a target. If the LLM fails or every proposal
   is dropped, Life says it cannot compare explanations yet.
7. **No outcome is a proof.** An experiment can support or fail to support an explanation; it is
   never shown as establishing the cause.

---

## 5. Consent and privacy

### 5.1 Two new categories — storing is not the same as analysing

| Category | Purpose (shown verbatim) | Needed for |
|---|---|---|
| `PROBLEM_RECORD` | *"Life keeps your description of the problem and of when it happened, so you can come back to it, correct it, export it or delete it."* | storing any event of S2–S3, S6, outcomes |
| `PROBLEM_HYPOTHESES` | *"Life sends what you wrote to an AI model to suggest possible explanations, and keeps them so you can test and correct them. What is sent is reduced first, but it may still identify you."* | S4, S5, experiments — and only together with `PROBLEM_RECORD` |

Added the way `INTENT`, `BUDGET` and `CHECKIN` were: no row anywhere → off for everyone until
granted. **Consent to analysis is never read as consent to storage, nor the reverse**; the code
checks each category by name at the point of use.

### 5.2 A gap in today's consent row, and what withdrawal does

`life_consents` holds `category · granted · timestamps` — no **purpose** and no **text version**.
For consents that permit storing and inferring about a person, the spec requires two fields:
`purpose_version` (which wording the person agreed to) and `granted_at`. A purpose change = a new
version = asked again. Only grants are rows; a refusal leaves no row (§2 S1), and a withdrawal
deletes the grant row (with an audit row of the withdrawal, ids only — the person had a record
already).

| The person does | What happens |
|---|---|
| **Withdraws `PROBLEM_HYPOTHESES`** | At once: no new explanation is formed; no stored claim is used or shown anywhere. The withdrawal screen asks for one of two choices — there is no third path: **"Withdraw and delete my explanations and experiments"** or **"Withdraw and keep them hidden until ‹date›"** |
| **Chooses hidden** | Claims and experiments get `hidden_at` and `hide_until` (N proposed: 30 days, an owner decision). **The screen shows the exact deletion date.** Granting again before then restores them; at `hide_until` they are deleted for real (and recorded in the ledger, §6.4). **The date is never extended** — only a new grant by the person stops it |
| **Withdraws `PROBLEM_RECORD`** | Consent to *keeping* ends, so what was kept goes: the screen shows the counts, offers the export first, then deletes events, claims, links and experiments for real. `PROBLEM_HYPOTHESES` is withdrawn with it. There is no "hidden" option here — keeping words hidden is still keeping them |
| **Asks to delete** (any item or all) | Deleted for real, now — never turned into hiding |

Withdrawing `PROBLEM_HYPOTHESES` alone does not delete what the person said: their own events stay
while `PROBLEM_RECORD` stands, unless they delete them too.

### 5.3 What Life may never infer or show — even with consent

Health or medical conditions · mental-health labels or diagnoses · religious standing or piety ·
blame of specific other people · sexual matters · political views · finances beyond what the
person stated · a person's identity or hidden motives read from their behaviour · a description of
a situation turned into a diagnosis or a judgement of character · a sensitive state inferred from
indirect details. If the person raises one of these, Life records **their words** (with
`PROBLEM_RECORD`) and forms no explanation about it — **saying it is theirs; inferring it is never
Life's.** The list is enforced by §4 rule 6 and is **not considered complete** until its fixture
suite has been run and reviewed (§8 Q4).

**Only this session's material:** explanations are formed from the person's own Life events only —
never from data held by another service (payments, Connection, TEC AI conversations), unless a
separate consent is added later. Testable: the hypothesis step reads one table, for one person.

### 5.4 What is sent to the model provider — minimised, and not called anonymous

Only with both grants, and only for S4 (and the classifier call of §4 rule 6):

- **What is sent:** the problem statement and the occurrences' text and context fields — nothing
  else. No username, no user id, no Pi uid, no session or app metadata; dates as relative wording
  ("about two weeks ago"), not timestamps.
- **Minimised first, in code, deterministically** (the same input always gives the same output,
  no model involved): email addresses, phone numbers, URLs, @handles, Pi wallet addresses, and any
  run of 6+ digits (ids, account and card numbers) are replaced by placeholders (`[EMAIL]`,
  `[PHONE]`, …) — in Arabic and English text, Arabic-Indic digits included.
- **Names of people** cannot be found reliably by a pattern, so the spec does not pretend to: S3
  asks the person to use roles instead of names, and a name they still type may be sent.
- **Tested:** fixtures in Arabic and English for each placeholder kind (asserted replaced), and a
  test that the request body built for the provider contains no user id, username or uid.
- **Said plainly:** *minimisation reduces what is sent; it does not make it anonymous.* What a
  person writes about their own life can identify them. The consent purpose (§5.1) says so.
- **One provider, no fallback.** TEC AI's chat today tries **Claude, then Groq, then Gemini**
  when one fails (Code Verified, `tec-ai-service/src/modules/chat/chat.handler.ts`, 2026-10-17) —
  so a chat message may reach any of three providers, on paid or free tiers with different data
  terms. **S4 does not inherit that chain.** It uses **one named provider and model** — Anthropic
  Claude, one pinned model, without the `anthropic-beta: server-side-fallback-*` header the chat
  sends today (owner, 2026-10-17, §8 Q10) — on a tier
  whose terms were checked, and **never falls back to another**: if that provider fails, Life says
  it cannot compare explanations yet (§4 rule 6). The classifier call follows the same rule. A
  test asserts the S4 and classifier calls reach only the approved provider's host.
- **Owner check before building:** for the chosen provider, the terms **of the account and tier
  actually used** — whether API data is used for training, how long it is kept and why
  (including abuse-monitoring exceptions), deletion, sub-processors and transfer — read, dated and
  recorded in the build PR, with who checked them. If they cannot be confirmed, S4 is not built.

### 5.5 Logs, error reporting, monitoring, analytics

- **Every output path — application logs, error reporting (`reportError` / Sentry), monitoring and
  traces, and the gateway's request logging — carries ids and counts only, never the person's
  text, a claim statement, an experiment's content or a fixture.** Error objects that may carry a
  request body (validation errors, provider errors, database errors) are logged by type and code,
  not by message. The test is G5 (§7).
- **Analytics:** none of the new tables is read by analytics in v1; the measures of §7 are counted
  from Life's own audit rows and the aggregate counter.

### 5.6 Who else sees it

Nobody. The new tables are **not** served by the TEC AI context door in v1, not by any `/internal/`
route, not in analytics. A later decision may add a separate consent category for that.

---

## 6. Correction, export, deletion — from day one

**Deletion wins over history.** "Events are immutable" means Life never *rewrites* what happened
while the data is kept. It never means Life keeps personal data after the person asked to delete it:
every delete below is a real delete.

### 6.1 Correction

- An **event** is never edited: the person can **retract** it (`retracted_at`) and add a corrected
  one. Retracted events count for nothing.
- A **claim** can be withdrawn by the person (`WITHDRAWN`) or revised (a new version with
  `supersedes`); its links are re-checked.
- Every correction writes an audit row (counts and ids only).

### 6.2 Export

A new own-scope route — `GET /identity/life/export` — returns everything Life holds for the caller:
goals, progress, skills, preferences, budgets, consents, **events, claims, links, experiments**, and
the audit rows about them, as JSON. Session-only identity; no `/internal/` variant. **Hidden claims
and experiments are included, marked hidden, with their deletion date** — the right to see what
Life holds does not depend on consent to inference, and export works the same before and after a
withdrawal.

### 6.3 Deletion — no orphans

- **Per item:** an event, claim or experiment the person deletes is removed with its links (FK
  cascade inside the Life database).
- **Per category:** withdrawing a category deletes as §5.2 says.
- **All Life data:** `purgeLifeData` gains the four new tables.
- **Account erasure:** `eraseAccount` (the participant route identity calls) gains the four tables;
  its dry run counts them; the real-Postgres test asserts **zero rows remain** for the person and the
  other person's rows are untouched — the same proof `erasure-db.spec` gives Connection.
- Audit rows stay (counts, never content), as everywhere else.
- **Proof, safely:** the zero-rows assertion runs against an **isolated test database** (as
  `erasure-db.spec` does), never against real users' data; the one production check is a dry run
  after a real erasure, which writes nothing.
- **Backups:** deletion removes the rows from the **live** database at once; the nightly encrypted
  backups (R2) still hold them until those backups expire. **What the code sets (Code Verified,
  `tec-backup-job/src/config.ts`, 2026-10-17):** `RETAIN_DAILY` default **14** daily sets and
  `RETAIN_WEEKLY` default **8** weekly sets (taken on Sundays) — so a deleted row can remain in an
  encrypted backup for **up to about 8 weeks**. **Production uses those defaults** (Runtime
  Verified, 2026-10-17: the owner's screenshot of Railway → `backup-job` → Variables shows no
  `RETAIN_DAILY` or `RETAIN_WEEKLY`). The setting is one for **every** database the job backs up,
  not Life's alone — a shorter period for Life only would need a per-database setting in the job's
  code. Accepting 8 weeks
  for Life data, or shortening it — which also shortens how far back a restore can reach — is an
  owner decision (§8 Q3). The privacy text states the period that is actually in force, and the
  replay of §6.4 is what keeps a restore from bringing deleted rows back meanwhile.

### 6.4 The deletion ledger — so a restore cannot bring deleted data back

A backup of Life's database taken before a deletion still holds the deleted rows. The ledger lives
in **identity's** database (a different server from Life's), so it survives a restore of Life.

**The record** — one row per deletion, ids only, never content:

| Field | Meaning |
|---|---|
| `request_id` | unique; the idempotency key |
| `kind` | `LIFE_ITEM_DELETED` · `LIFE_HIDDEN_EXPIRED` · `LIFE_CATEGORY_DELETED` · `LIFE_DATA_PURGED` · `ACCOUNT_ERASED` |
| `service` | `life` (the contract is the same for any service that joins later) |
| `entity_type` · `entity_id` | for the two item kinds: `life_event` · `life_claim` · `life_claim_link` · `life_experiment`, and the row's id; empty otherwise |
| `category` | for `LIFE_CATEGORY_DELETED` only: `PROBLEM_RECORD` or `PROBLEM_HYPOTHESES` |
| `user_id` | whose data |
| `requested_at` · `deleted_at` | when asked · when Life confirmed the delete (empty until then) |

**Recorded first, then out of use, then deleted, then confirmed** — so no request the person made
can be lost, whatever is restored and whenever:

1. **Life writes the ledger row in identity** (service-only route, `isServiceCaller`) — before it
   touches anything of its own. **If identity is known not to have recorded it, the request is
   refused with a visible "not deleted — try again", and nothing in Life changes.** No "in progress"
   is ever shown for a request that is not yet recorded.

   **A fixed `request_id`, and the unknown outcome.** The id is made once, when the person confirms
   the deletion (the page sends it with the request; for deletions Life starts itself, it is derived
   from the item and its `hide_until`, so a retry produces the same id). Every retry of that action
   reuses it. **The id is bound to the request's full scope** — `user_id · kind · entity_type ·
   entity_id · category` — stored with it in the ledger. Identity's write is idempotent on it: the
   same id with the same scope returns the existing row, never a second one; the same id with **any**
   difference in scope is refused (409) and changes nothing.

   **"Not recorded" must be final, not a snapshot.** A plain lookup that finds nothing could be
   overtaken by the original write, still in flight, committing a moment later. So Life never asks
   "is it there?"; it asks identity to **resolve** the id (`POST` the ledger's resolve route with the
   `request_id` and its scope), and identity answers in one transaction on the id's unique key:
   - the row exists → **RECORDED** (and its scope must match, else 409);
   - the row does not exist → identity **inserts it as `VOID`** and answers **VOID**.

   Whichever of the original write and the resolve commits first wins the unique key; the other
   sees it. A late original write that meets a `VOID` row is refused and records nothing. So VOID
   is decisive: that id can never become a deletion afterwards. A new attempt by the person gets
   a **new** `request_id`.

   **These are identity's guarantees, tested in identity** — not assumptions Life makes about it.
   Identity's ledger contract, each rule with its own test in `tec-identity-service`:
   - (L1) the resolve finds-or-inserts `VOID` in **one transaction on the unique key** — never a
     read followed by a separate write;
   - (L2) `VOID` is **final**: a write meeting it is refused however late it arrives, and no route
     changes a `VOID` row;
   - (L3) **there is one way into the ledger**: the write and the resolve both go through the same
     unique-key insert; no other route, job or script creates or edits a ledger row (a CI check
     fails the build if one does);
   - (L4) a `RECORDED` row keeps its original scope for ever; the same id with a different scope is
     refused (409), never read as a new request.

   A call to identity ends in one of three ways, and Life treats them differently:

   | Outcome of the write | How Life knows | What Life does · what the person sees |
   |---|---|---|
   | **Recorded** | identity answered 200 to the write, or the resolve answered RECORDED | steps 2–4 · "Deletion requested — in progress" |
   | **Not recorded** | identity refused the write, or the resolve answered **VOID** | nothing changes in Life (the block, if any, is lifted) · "Not deleted — try again" (a new attempt, a new id) |
   | **Unknown** — the connection broke or timed out after the write was sent, and the resolve cannot be made either | no answer to either | **the data in the request's scope is blocked at once** (503 for it, as for a known open request) · "We couldn't confirm your request yet — your data is held back while we check." The minute sweep repeats the resolve until it answers RECORDED or VOID. The block is lifted **only** on VOID |

   Life never shows "not deleted" while the outcome is unknown: a request that might be recorded
   is treated as recorded until identity says otherwise. If Life restarts while an outcome is
   unknown, the start sweep reads the ledger anyway (below), so a recorded request is still applied.
2. **Life marks the rows `deletion_pending_at`** (one local transaction). From that moment they are
   **out of every use**: not shown on any screen, not sent to the model, not counted by a rule, not
   linked. The export lists them only as "deletion pending" (type and count, no content). From step
   1 on, the screen says **"Deletion requested — in progress"**.
3. Life deletes, in one transaction.
4. Life sets `deleted_at` in the ledger. **Only now does the screen say "Deleted".**

**If a step after 1 fails,** the ledger row is already there with `deleted_at` empty, and it is
the reference from then on:

- Life retries steps 2–4 at once; while they have not succeeded, Life answers **503 for that
  person's session data** — it never serves it as if no request existed.
- A **sweep** runs every minute and **on every start of Life, before `/ready` answers 200**: it
  reads every ledger row for `service = life` with `deleted_at` empty and applies steps 2–4 for it.
  So a restart, a crash or a restore between any two steps cannot bring the data back into use —
  the next start re-applies the request before Life serves anyone.
- The person keeps seeing "in progress" until step 4; a request is never shown as done before it
  is, and never forgotten.

**If identity's ledger cannot be read — the isolation boundary.** Rows already marked in step 2
stay out of use whatever happens: the mark is local to Life. What Life cannot know without the
ledger is whether a request was recorded (step 1) but not yet marked (step 2). So:

| When the ledger cannot be read | Life does | Why this boundary |
|---|---|---|
| **At start** (and after a restore) | **The whole service stays not-ready**: `/ready` 503, every Life route 503, for everyone. Retries; an ERROR alert after 2 minutes | After a start, Life knows nothing about recent requests — any person's data might be under one |
| **While running**, the minute sweep fails | People with a request Life itself saw fail keep getting 503 for the data in that request's scope; **everyone else is served**. ERROR alert | The running process knows every request it accepted and could not finish |
| **While running, the sweep has failed for 5 minutes in a row** | **The whole service goes not-ready**, as at start, until a sweep succeeds | Another instance (or a request lost to a crash) may hold a recorded request this process never saw. v1 runs one instance; this keeps the rule correct if that changes |

The data blocked is always **the request's scope** (§6.4 replay table) — an item, a category, all
of Life for that person — never more, so the 503 for one person does not hide another's goals.

**One read gate.** Every read of a Life table — the person's own routes, the export, the TEC AI
context door, every `/internal/` route, every background job (the weekly check-in, the monthly
review, the hidden-expiry job, the intent window), every call that builds text for the model, and
the counters of §7 — goes through **one repository layer** that drops rows marked
`deletion_pending_at` and refuses data in the scope of a blocked request. No other code reads those
tables directly; a lint/CI check fails the build if any file outside that layer queries them.

Deletions Life starts itself — a hidden item reaching `hide_until` (`LIFE_HIDDEN_EXPIRED`) — follow
the same four steps.

**Replay is idempotent, only deletes, and has a fixed scope per kind** — it never reaches further
than the original request did:

| `kind` | Replay deletes exactly | Never touches |
|---|---|---|
| `LIFE_ITEM_DELETED` · `LIFE_HIDDEN_EXPIRED` | the one row by `entity_type` + `entity_id` (its links by FK cascade) | any other row |
| `LIFE_CATEGORY_DELETED` + `PROBLEM_HYPOTHESES` | that user's claims, links and experiments | their events, goals, skills, preferences, budgets, other consents |
| `LIFE_CATEGORY_DELETED` + `PROBLEM_RECORD` | that user's events, claims, links and experiments | goals, skills, preferences, budgets, other consents |
| `LIFE_DATA_PURGED` | `purgeLifeData(user)` — Life's tables for that user | anything outside Life's database |
| `ACCOUNT_ERASED` | Life's own part of the erasure — the same rows Life's `eraseAccount` removes | other services (each replays its own ledger rows after its own restore), identity's `users` row, payments, orders, KYC |

A Life replay runs inside Life against Life's database only; it never calls another service. A
missing row is success with count 0. Rows are replayed in `requested_at` order; replaying twice
gives the same result; replay never creates or changes anything else.

**After a restore, Life stays closed until the check is clean:**

1. Life starts in **restore mode**: `/health` answers 200 (it is alive), `/ready` answers 503, and
   every Life route answers 503 — the person sees "Life is being restored", not old data.
2. The replay runs for every ledger row with `requested_at` after the backup's time, minus a
   margin of 24 hours — **completed or still open** (an open row is applied by the sweep's steps
   2–4 as above).
3. A **verification dry run** counts, for every replayed row, whether anything in **that row's
   scope** (the table above) is still present. It must be **0**.
4. Only then does the operator open the service. **If the replay or the verification fails, the
   service stays closed and an ERROR alert names the failing rows** — it is never opened partly
   cleaned.

**Tested on an isolated database:** create rows for two people across every Life table → take a
snapshot → make one request of **each kind** (ledger written) → restore the snapshot → replay →
assert, per kind, that exactly its scope is gone and everything outside it — the other categories,
goals and budgets, the other person — is intact; replay again → the same. **Fail each step in
turn:** identity unreachable at step 1 → refused, nothing in Life changed; **the response lost
after identity committed** → Life does not show "not deleted", the resolve answers RECORDED and
steps 2–4 run; the same with the resolve also failing → the scope is blocked and the screen says
"couldn't confirm yet" until a sweep resolves it; **the original write delayed until after a
resolve answered VOID** → the write is refused, no deletion happens, the block is lifted; the two
racing in parallel (many runs) → exactly one of RECORDED or VOID, never both, never neither; **a
retry with the same `request_id`** → still exactly one ledger row; the same id with any field of
the scope changed (user, kind, entity, category) → 409 and nothing changed; a crash after step 1,
after 2 and after 3 → on the next start the sweep completes the request before `/ready` is 200, and
no read in between returns the rows; a restore of a snapshot taken before step 1 of a recorded
request → the replay removes it. A failing replay → the service stays closed.

**"Deleted" means unreadable before it means zero.** Success is not only zero rows at the end:
the test also proves that **from step 1 until replay and verification finish, no path can read a
row in the request's scope.** For each pending request and each restore case, it calls **every**
read path listed under "One read gate" — the person's routes, the export, the TEC AI context door,
each `/internal/` route, and each background job run by hand — and asserts none returns, sends to
the model, or counts a row in scope, while data outside the scope (the other person, the other
categories) is still served. The list of paths in the test is checked against the read gate's
callers, so a new path without a test fails CI. Ledger unreachable: at start → every route 503;
while running → only the blocked scope 503 and the other person served; after 5 minutes → every
route 503.

---

## 7. Measures — hypotheses to test, not facts

All thresholds below are **starting guesses to be checked against real sessions**, chosen so a
failure is visible early. The first reading is a baseline, not a verdict.

**Where the numbers come from:** M1–M5 from Life's audit rows (sessions with `PROBLEM_RECORD`) plus
the **aggregate counter** (sessions without it: started, reached S7). M6 **only** from the aggregate
counter: one row per day per answer (`2026-11-03 · M6 · Somewhat · 4`). **The answer is stored
with no identifier of the person or the session, and no text** — it is never kept as a rating of
anyone. That lowers the chance of linking an answer to a person; it does **not** make it
impossible: with few sessions, someone who knows a person used Life on a given day might guess.
So the counter is **reported by week, not by day, and any count below 5 is shown as "fewer than
5"** — for M6, M7 and the refusal counts alike. A skipped question writes nothing.

| # | Measure | Proposed bar | Failure signal |
|---|---|---|---|
| M1 | Sessions that reach S7, of those that start S2 | ≥ 50 % | < 30 % → the session is too long or unclear |
| M2 | Of sessions that showed an explanation: the person marks at least one `PLAUSIBLE` | ≥ 40 % | `DOES_NOT_FIT` on > 70 % of shown explanations → the explanations are poor |
| M2b | Sessions that showed **no** explanation and ended with an observation plan | tracked, no bar yet | a high share → the threshold may be too strict, or the questions too few |
| M3 | Sessions that end with an agreed experiment | **tracked, not a target** — declining can be the right choice | — |
| M4 | Experiments with an outcome recorded within 7 days of `ends_on` | ≥ 50 % | < 25 % |
| M5 | People who return within 30 days **without** a reminder (sessions with `PROBLEM_RECORD` only) | ≥ 20 % — a signal of use, not proof of value | < 10 % |
| M6 | Optional question at S7: "Do you see the problem more clearly than before?" (Yes / Somewhat / No) — aggregate counter only | ≥ 50 % Yes or Somewhat | > 50 % No |
| M7 | Sessions that chose "talk it through without saving" | tracked, no bar | a very high share → the storage consent is not trusted, or not understood |

**Stop guarantees — G1 to G6.** These are not targets: **one breach of any of them stops the
rollout** until the cause is found and a test for it added.

| # | Guarantee | Checked by | Must be |
|---|---|---|---|
| G1 | Explanations formed or shown, or text sent to the model, without **both** grants | consent check at the point of use + a test per route | **0** |
| G2 | Patterns created | schema (no table) + test | **0** |
| G3 | Explanations shown that touch §5.3 or name a trait or motive | §4 rule 6 suite + the reviewed sample | **0** |
| G4 | Rows left after an account erasure, a purge, or a restore replay | isolated-database tests (§6.3, §6.4) + a dry run after a real erasure | **0** |
| G5 | The person's free text (or a claim, an experiment's content, a fixture) in **any** output: application logs, error reporting, monitoring/traces, gateway request logs — **on success and on error paths** — **and, on the browser side, anywhere the text could leave the page** | **Server:** a test session with a unique marker string, run through success **and** forced failures (provider error, provider timeout, database error, validation error, classifier failure); every captured output — stdout/stderr, the `reportError` sink, trace exports — is searched for the marker. **Browser** (a Playwright run of the page): every outgoing request is captured — fetch, XHR, `sendBeacon`, WebSockets, image/script loads — with URL, headers and body. In the **"without saving"** path the marker must appear in **none** of them; in the saving path, **only** in the body of Life's own `/api/bff/life/*` requests. The page's own `localStorage`, `sessionStorage` and IndexedDB must not hold it after the page closes (no-save path). A listed inventory of every client-side script on the page (analytics, session replay, client error reporting) is checked in the same PR: none may record form input, and the client `reportError` sends error type and code only | **0** occurrences |
| G6 | Session text stored without `PROBLEM_RECORD` | test: a session without the grant leaves no row but the aggregate counter | **0** |

Read after the first **20–30 real people** (an owner's choice, not a statistical claim). A reading
this small finds problems of **understanding and use**; it cannot show that the explanations are
right or that the experiments cause the change. M1–M5 below their failure signal → revise the
session before building anything further. M6 is asked whether or not an explanation was shown — it
is what tells us a session with none was still worth having.

---

## 8. Questions for the owner (before any building)

The third review gave a recommendation on each of the first eight. They are written here so the
owner can see them — **none is decided until the owner says so.**

| # | Question | Reviewer's recommendation (not a decision) |
|---|---|---|
| 1 | The level rule (§4 rule 3): **Low only in v1, no upgrade** — accept? | Accept |
| 2 | The hidden period after a withdrawal, **N = 30 days** (§5.2) — right? | Accept, if the deletion date is shown and never extended without a new grant — r4 does both |
| 3 | Backup retention (§6.3): production keeps 14 daily + 8 weekly sets (deleted data up to ~8 weeks) — accept, or shorten? | **Owner decision, 2026-10-17: a shorter period for Life's databases only**; every other database keeps 14 + 8. Needs a per-database setting in `tec-backup-job` — its own build approval. Life's exact period is set then, with a restore test. Until it ships, 8 weeks is in force and the privacy text says so |
| 4 | The never-infer list and the session-only rule (§5.3) — complete? | Not complete until the classifier suite (§4 rule 6) has been run and reviewed |
| 5 | Experiment duration **≤ 14 days** — right length? | Acceptable for a first version |
| 6 | The measures and the 20–30-person first reading (§7) — accept as the starting bar, knowing it finds problems of understanding and use, and does **not** prove the explanations are right? | Accept as a usability test |
| 7 | Language of the session: Arabic and English first, or all twelve of the Hub's languages? | Arabic and English first |
| 8 | Phase 0 — when the spec is accepted, is building it approved, and in which order (backend tables + consent + erasure + ledger first, then the session UI)? | **Owner decision, 2026-10-17: stage 1 only is approved** ("Talk it through without saving", below). Stages 2 and 3 are **not** approved; each needs its own approval |
| 9 | **New in r4:** two consents — `PROBLEM_RECORD` (keep) and `PROBLEM_HYPOTHESES` (analyse) — and a "talk it through without saving" path that keeps nothing (§2 S1, §5.1) — accept? | — |
| 10 | **New in r4:** S4 uses **one** provider with no fallback (§5.4) — which provider, and who reads and records its terms before building? | **Owner decision, 2026-10-17: Anthropic Claude, one pinned model**, for S4 and the classifier — no `server-side-fallback` header, no other model, no other provider. **The owner reviews the account's terms** and records them (name, date, result) before S4 is built; until then the review is not done |
| 11 | **New in r4:** the deletion ledger in identity's database, refusing a deletion when identity is unreachable (§6.4) — accept that a deletion can fail visibly rather than proceed unrecorded? | — |

**A proposed order for Q8 — a proposal, not a build approval.** Each stage needs its own explicit
approval; passing one stage does **not** approve the next.

| Stage | What it builds | It tests | To move on |
|---|---|---|---|
| **1. "Talk it through without saving"**, 20–30 people | S1–S3, S6-A, S7 in the page only — no tables, no model, no ledger | one hypothesis only: **do structured questions alone help a person see their problem more clearly?** | G5 (browser side) passed; M1 and M6 read against the stage-1 rule below, fixed **before** the first session |
| **2. Keeping and deleting** | `PROBLEM_RECORD`, the four tables, the ledger, replay and restore (§6) | that deletion and restore behave as §6.4 says | its own approval; every §6.4 acceptance test green |
| **3. Explanations** | S4–S6-B with Claude, one pinned model, no fallback | whether explanations help | its own approval; the owner's review of the provider's terms recorded (Q10) |

**Stage 1 decision rule** (owner-approved wording, 2026-10-17; the numbers are §7's, fixed before
the first session and **not changed after seeing the results**):

| Result | Condition |
|---|---|
| **Encouraging** — ask for stage 2's approval | M1 ≥ 50 % **and** M6 ≥ 50 % "Yes" or "Somewhat" — **both** |
| **Failure** — redesign the session | M1 < 30 % **or** M6 "No" > 50 % — **either one** |
| **In between** — retest | neither of the above: the questions are revised and the reading is repeated with a **new group** before any decision |
| **Immediate stop** | any G5 breach — any network request carrying the person's text — whatever M1 and M6 show |

- **M1 and M6 keep their §7 definitions exactly.** M1 = sessions reaching S7 ÷ sessions starting
  S2. M6 = shares of "Yes", "Somewhat" and "No" among the sessions that **answered** the question
  (a skipped question writes nothing, so it is not in the denominator). Nothing is redefined here.
- **M7 is not used in stage 1:** every session there is unsaved, so it would always be 100 % and
  tell us nothing. It returns in stage 2, when saving is a real choice.
- **The unit is the session, not the person.** 20–30 people are invited; the counter has no
  identifier, so it counts sessions, and one person's repeated sessions cannot be told apart or
  removed. That is the price of not identifying anyone, and the reading is interpreted with it.

Limits of stage 1, said now so its result is not over-read:
- **Not saving is not the same as not sending.** The text stays in the browser: no request to
  TEC AI, to any API or to Life's own routes carries it, and no server log holds it. G5's browser
  test (§7) is the proof; one request carrying the text means the path is not local and stage 1
  stops.
- **M6 measures an immediate impression, not lasting help.** Stage 1 uses only the measures
  already in §7 — no new ones — with what counts as encouraging fixed before the first session.
- **20–30 people find problems of use and give an early signal; they prove nothing
  statistically.** Success in stage 1 justifies the next test. It does not show that explanations
  help, or that Life is worth paying for.

**Before any building, whatever the answers above:** the backup retention period is set (the
final privacy text waits for it), and the model provider's data terms are confirmed (S4 waits for
them). Accepting this spec is **not** approval to build: until the owner approves Phase 0
explicitly, it stays a draft under review, with no change to any repository or code.
