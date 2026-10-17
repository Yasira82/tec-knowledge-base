# TEC Life — the vision as an independent app: building the human toward good (2026-10-17)

> Truth State: **[Future Vision]** · Governance State: **[Draft]** — the owner's direction
> (2026-10-17): Life is not about trade and not only about TEC; it grows as an **independent app**
> whose purpose is **بناء الإنسان للصالح** — building the human toward good, as the owner's reports
> describe (`audits/LIFE_HUMAN_DEVELOPMENT_REPORTS_2026-10-17.md`). Verification: §3 is
> **[Code Verified]** against `tec-core-backend` main and `Tec-Life`; the rest is not built.
> Life's charter is C-106; changing it is the owner's decision — this file proposes, it does not amend.

## 1. What Life is for — its goals

**الغاية:** أن يساعد Life الإنسان على أن يصبح أصلح — في نفسه، وفي قراراته، وفي معاملته للناس —
بفهمٍ صادق لحاله، وتجربةٍ في الواقع، وتعلّمٍ من النتائج عبر الزمن.

| # | Goal | What it means in practice |
|---|---|---|
| G1 | **يفهم الإنسان نفسه — بالأدلة، لا بالأحكام** | Life reflects what happened, in which context, and what the evidence supports and contradicts. It never labels a person ("أنت متردد") — it describes behaviour in a context, and says *unknown* when it does not know |
| G2 | **قرارات أصلح قبل أن تُتخذ** | Not only "will this reach the goal?" but how it is reached: the promises it makes, who it affects, the risks, what cannot be undone. A goal is examined, not just optimised |
| G3 | **التغيير يحدث في الحياة، لا في المحادثة** | Small, bounded experiments with a success measure fixed beforehand, followed up and read honestly — "encouraging, cause not settled" is an allowed answer |
| G4 | **التطور عبر الزمن** | A truthful memory: what the person believed, what proved true, what changed. History is never rewritten; interpretations are revised in the open |
| G5 | **الصلاح، لا الإنتاجية وحدها** | Keeping promises, honesty, fairness, responsibility toward others, using means that are sound — the qualities, not a score. The Qur'an and authentic Sunnah are the **foundation of the model** (through verified sources and scholarly interpretation), not content pushed at the user |
| G6 | **يحترم الإنسان** | No moral scores. No intention attributed that was not stated. Consent before any long-term inference; the person can see, correct, export and erase everything Life holds |
| G7 | **مستقل** | Useful on its own — no other TEC app is needed. Pi's community is where it starts, not its limit; it serves Muslims and non-Muslims alike, with its foundation stated openly in its methodology |

**What Life is not:** a habit tracker · a goals dashboard · an AI life coach that hands out advice ·
an Islamic chatbot or a feed of religious content · a commerce or TEC tool · a streak or reward game.
Habits and goals stay inside Life as kinds of behaviour and intent, not as its centre.

**How we will know it works** (from the owner's Report 7, sharpened in Report 8): the loop is
completed (problem → experiment → result) · the person confirms or corrects Life's interpretations
(the rate of *corrected* ones is a measure of honesty, not failure) · an observable change against a
measure set beforehand · the person comes back without reminders or rewards.

## 2. The first proof — one use case

A recurring problem the person wants to change, whose causes are not clear to them. Life records it,
offers competing explanations or says the information is not enough, the person chooses a small
experiment and its success measure, and Life follows up the result. Everything else waits until this
loop is shown to help real people (owner, Reports 7–8).

## 3. What Life already has toward this (Code Verified, 2026-10-17)

| Principle in the reports | Already in Life |
|---|---|
| LLM proposes; the system (and the person) validate | TEC AI proposes a goal and its steps; **nothing is saved until the person taps Add** (A3, tec-app #292 · Tec-Life #76) |
| Unknown stays unknown | The trajectory **refuses to project** with fewer than two entries on two days |
| History is immutable; the total is derived | `life_goal_progress` is append-only; a goal's total is a projection of it |
| Consent before use; absence is a no | `LifeConsent`, per category — no row means denied |
| Sensitive signals are not kept | Intent signals live 30 minutes in Redis, no durable copy |
| Experiments and follow-up | Goal steps (`- [ ] step`), the weekly check-in, the monthly review (C-106 §11b) |
| The right to erase | `DELETE /identity/life/data`, and since 2026-10-17 account erasure reaches Life, TEC AI and Connection (tec-core-backend #437) |

So the first proof does not start from zero. What it lacks: an **event** with its source
(declared / observed), a **claim** with its status (proposed → confirmed / refuted), an **experiment**
with its success measure set before it starts, and its **outcome** linked to it.

## 4. Review notes (to settle before the First Session Spec)

1. **Five entities, not nineteen, for the first proof:** Event (with context as a field), Claim,
   Experiment (Intervention), Outcome — on top of the person and goals Life already has. Pattern and
   Trajectory are computed from these later, not stored first.
2. **The Islamic reference layer needs a scholar before it is built.** The reports require every
   principle to pass verified sources and scholarly review. Building Source / Interpretation /
   Principle records without that review would be exactly the fabrication the reports forbid. Until a
   reviewer exists, G5 lives in how experiments and decisions are framed, and nothing is attributed to
   the Qur'an or Sunnah.
3. **Inferences about a person are sensitive data.** A new consent category before any claim is
   stored; every new table joins Life's erasure (`eraseAccount`) in the same change.
4. **The hard proof is people, not design.** C-02: effectively no external paying users yet; TEC AI's
   first reading had 24 of 25 asks matching nothing. The first proof should ship small and early.

## 5. Decisions that are the owner's

- **Phase 0** says no new features before Mainnet hardening is done — building the first proof is a
  decision to make explicitly.
- **C-106** (Life's charter) describes Life as TEC's *system of record (personal)*. An independent
  Life whose purpose is human development is a charter change — the owner decides; an AI does not
  amend a charter or assign a new C-number.
- **Who reviews the Islamic foundation** — a named scholar or reviewer, before §4.2 can start.
