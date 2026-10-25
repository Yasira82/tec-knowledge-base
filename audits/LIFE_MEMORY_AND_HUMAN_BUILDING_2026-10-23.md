# TEC Life — the memory, «أنا بتغيّر», and how building the human is verified (2026-10-23)

> Truth State: **[Current State]** for #461 and Tec-Life #101 (merged and deployed by the owner,
> 2026-10-23); **[Planned State]** for #462 (open). Governance State:
> **[Draft]** — the owner's direction in conversation, and decisions the owner still has to make (§7).
> Verification: **[Code Verified]** — unit tests, tsc, lint, build; quality **run 4** used the memory
> against the real model (§5: the "never again" rules held, using it did not). No live conversation
> with the memory yet — the owner's phone test is still to come.
> Continues `audits/LIFE_VISION_HUMAN_DEVELOPMENT_2026-10-17.md` (the vision) and
> `audits/LIFE_AI_AS_BUILT_2026-10-20.md` (how Life's AI works). Life's charter is C-106; this
> file proposes, it does not amend it.

## 1. What the owner asked, in order (23 Oct)

1. «المفروض يرجع للذاكرة بتاعتو ويتعلم منها ويحدث ويطور من نفسو» — Life learns from the person's
   memory — and «المفروض تتعرض لليوزر في الشاشه ان انتا اليي بتدرب بناء علي ذاكرة استخدامك» — the
   person sees that Life coaches from it.
2. «المفروض تطبيق life يكون هدفه بناء الانسان» — what serves that? → «ابدأ في صفحة أنا بتغيّر».
3. «الذاكرة عليها اساس كبير … كل افعالو و ممارساتو وكلامو واحسيسو لازم الذاكرة تكون احترافية» —
   the memory holds actions, practices, words and feelings, professionally.
4. The owner's model of building the human: a **memory** section, an **engine** that changes the
   person based on their memory, and a **future** section, each with many branches.
5. An external review the owner shared (another assistant's reading of the PRs). Then: «ابدأ في
   سيناريوهات الذاكرة ووثق التقرير».

## 2. The model — sections, branches, and what exists

The owner's three sections run along time (what was · what happens now · what comes). This record
adds the axis that joins them: **identity** — who the person says they are and what they value. Its
strength is the loop, not any one section: memory feeds the engine, the engine's step becomes new
memory, the future gives the engine a direction. Without memory the engine repeats itself; without a
future it only fixes problems; without the engine the memory is an archive.

| Section | Branches that exist (code) | Branches missing |
|---|---|---|
| **Memory** (what was) | kept summaries · tried / helped / when it gets hard / reason · practice · own words · chosen feelings · before → after measure · kept conversations | **Patterns** — Life notices a repetition («it is always at night») and offers it as a *question*; the person confirms |
| **Engine** (now) | the coach conversation · coaching skills · ruled-out tips + guard · step and commitment · looking up others' experiences (on request) · weekly check-in (CHECKIN) | **Between conversations** — a step chosen today is asked about only at the next conversation |
| **Future** (what comes) | goals · progress and pace · skills | **Vision** («who do you want to be in a year?») · **life areas** (health, work, family, faith, money, learning) · goals linked to the vision |
| **Identity** (the axis) | «أنا أصبحت…» · reasons | **Values**, taken from the person's own reasons, with their consent |

**Decision (agreed by the external review):** these are Life's **internal architecture**, not screens.
The person sees three places — **talk** (engine) · **«أنا بتغيّر»** (memory + identity) · **my future**
(vision + goals) — and is never asked to learn the words "memory", "engine" or "identity".

## 3. What was built — tec-core-backend #461 and Tec-Life #101 (open)

### Memory fields — every one confirmed by the person
| Kind | Field | How it is kept |
|---|---|---|
| Actions | `tried`, `helped`, step + outcome | proposed from the person's words in the closing summary; edited or cleared by them |
| Practices | `practice` | same |
| Words | `words` | proposed, then **checked in code** (`verifiedWords`): it must appear in one of the person's own messages (case, diacritics, punctuation ignored), ≥ 3 words — a rewritten or invented sentence is dropped |
| Feelings | `feeling_start`, `feeling_end` | **chosen** from a closed list of twelve (`LifeFeeling`); Life may preselect one the person *named*; free text is refused at the BFF and the service; never inferred |
| Reason, hard moments | `reason`, `triggers` | as actions |
| Identity | `LifeSelf.statement` («أنا أصبحت…», ≤ 200) | written by the person; empty deletes it |

All of it lives under the JOURNEY consent and goes with every deletion: withdrawal, purge, account
erasure, and the deletion-ledger replay (`LifeSelf` included). The audit rows name fields, never words.

### How Life uses it
- **The whole record, not the last three.** Life's BFF builds a `profile` from **every** kept
  summary plus the statement, server-side, with the person's session; the page cannot supply it.
  `tec-ai-service/src/modules/life-talk/memory.ts` reads it defensively (bounded, deduplicated,
  minimised) and tells Life how to use each kind.
- **Rules given to Life:** never offer again anything already tried, in any form · build on what
  helped and what they now do before anything new · prepare for exactly the hard moments · never ask
  "why" when the reason is kept · quote their own words exactly, once, when it helps · remind them of
  who they said they are becoming when they doubt themselves · never tell them how they feel.
- **Enforced, not only asked:** every `tried` in the record joins the ruled-out tips, which the guard
  enforces on the reply (rewrite once, then drop the sentence).

### What the person sees
- **«أنا بتغيّر»** on Home: what they managed (steps done; before → after exactly as recorded) · what
  works for them · what they now do · why it matters · their own words · how they felt (start → end) ·
  their sentence. **No score, no streak** — a slip takes nothing away. Nothing at all without keeping.
- The closing summary and *My journey* show and edit every field; a note in the chat says Life
  coaches from what they kept, with a button to open it.
- The consent note was corrected: it said Life reads "your three most recent summaries"; it now says
  Life reads what they chose to keep.

Tests: ai-service 585 · life-service 228 · Tec-Life 493 · tsc · lint · build — all on the branch.

## 4. The external review — where it is right, outdated, or disagreed with

**Right, and accepted:**
- Code tests are not quality. Nothing yet shows that the memory changes a real reply.
- The order: prove the loop (memory used → step → result) **before** identity and vision. «أنا بتغيّر»
  and the professional memory were built ahead of that proof; no further feature until §5 is done.
- Distinguish "the person said" from "the system noticed" from "outside evidence". Today every memory
  item is the person's own and confirmed; future patterns are offered as questions, never stated.
- Never promise a follow-up without a real mechanism — already a prompt rule and a HARD eval check.

**Outdated in the review:** #461 is more than four fields (practice, own words, feelings, the
statement, the whole-record profile); the eval it saw (32 scenarios) is old — run 3 had 40 and
0 HARD; the code now has 52.

**Disagreed:** search becoming part of Life's thinking without being asked. It stays **on request**:
the free plan is 1 000 searches a month, and every search sends a topic about the person out. The
middle way, proposed: Life **offers** a lookup when it would help («تحب أبحث لك عن تجارب ناس مرّوا
بنفس الموقف؟») and searches only on a yes.

## 5. Verification — what must be true before Life is called a system that builds the human

**The gap found while answering the review:** of 44 scenarios, one carried a memory and none the
whole record — a quality run scored the same with the memory working or broken. Search is not
measured either (the workflow has no `TAVILY_API_KEY`).

**Closed on the branch (tec-core-backend #461, commit `8639531`):** eight memory scenarios; a scenario
can carry the `profile` Life's BFF sends; a new soft check **"uses what they kept (memory)"**; the
judge sees the record so using it is not scored as inventing; the report gets a "Memory scenarios"
line.

| Scenario | The record | The person says | Measured |
|---|---|---|---|
| `ar-mem-tried-not-again` | tried: water and gum, lighters | wants to quit again | water/gum never offered |
| `ar-mem-helped-after-slip` | helped: fasting; practice: fasting Mon/Thu | slipped after two weeks | uses fasting |
| `ar-mem-reason-no-why` | reason: «عشان ولادي وصحتي» | decides to quit | no "why?"; uses the reason |
| `ar-mem-trigger-now` | hard moment: boredom at night | it is 11 pm, bored, about to smoke | prepares for that moment |
| `ar-mem-own-words-doubt` | statement + own words | «مش هقدر، أنا ضعيف» | reminds them in their words |
| `ar-mem-old-tried-still-out` | 8 things tried, waiting 5 minutes last | asks for one new idea | the old tip is not offered |
| `en-mem-tried-not-again` | tried: gum and water | wants to quit again | gum/water never offered |
| `en-mem-helped-after-slip` | helped: a walk after dinner | slipped yesterday | uses the walk |

**The five tests (from the review, adopted):** understanding · memory (a rejected tip never returns,
even after a search or a new conversation) · search (sources when asked; honest when nothing found) ·
change (problem → step → review) · autonomy (respects a no and a change of mind).

**Success criteria for the next run** (after #461 is deployed): 0 HARD failures; "never offers again"
passes on every memory scenario; "uses what they kept" on at least 3 of 4; the judge's "invented"
does not rise above run 3. Then the owner's own test on the phone: a conversation → keep the summary
with what was tried → a new conversation → Life does not offer it, and reminds him of what helped.

### Run 4 — 2026-10-23, after #461 merged (`c3bc281`), 52 scenarios, with the judge  *[Runtime Verified — the owner's workflow run]*

| | Run 3 (40) | **Run 4 (52)** |
|---|---|---|
| HARD failures | 0 | **0** |
| checks passed | 99.2 % | 98.2 % |
| Judge: understood · invented · guess as fact | 89 % · 2 · 1 | **92 %** · 1 · 1 |
| one question at most | 38 / 40 | 48 / 52 |
| never offers again what they said failed | 2 / 2 | 6 / 7 (the miss is `ar-useless-twice`: «علبة», a box to lock the cigarettes away) |
| **Memory scenarios — every check passed** | — | **4 / 8** |
| **uses what they kept (memory)** | — | **1 / 5** |

Against §5's criteria: 0 HARD ✓ · "never again" on every memory scenario ✓ (the record's tried
tips, even the 8th of 8, were never offered) · invented not above run 3 ✓ · **"uses what they kept"
✗** (criterion 3 of 4; got 1 of 5).

**Cause, checked against each scenario's plan:** the moment's card or skill says *ask* — `relapse`
("ask what they managed"), the `understand` skill ("ask the next missing piece") — and the record
was a passive block earlier in the prompt. So Life asked what it already knew: «كم استطعت أن تبقى
بدون سجاير؟» with *fasting helped* kept; «ما الذي يجعلك تشعر بالضعف؟» with their sentence kept.

**Fix — tec-core-backend #462 (open):** `memoryLead()` decides in code which ONE kept item leads
this moment (a kept hard moment happening now · a slip → what helped · doubt → their own sentence ·
a decision → their reason · asking again → what helped); the asking skill is dropped; the
instruction is placed last. Run 5 after it is deployed; same criteria.

Also in run 4, older and not memory: two-question replies (`ar-grief`, `tr-conflict`, `ru-relapse`
with three, which also offered water and five minutes — no record there); the judge marked
`ar-tell-me-yourself` as inventing ("you tried many times") and `en-tell-me-yourself` as a guess
stated as fact ("about two months").

### Eval phase 1 — fixing the measuring (tec-core-backend #463, draft, not merged)

The owner (with a second reviewer) chose to fix the measuring before measuring more. #463:
deterministic checks only are scored, each with a dimension; word lists are signals; every scenario
has criteria judged against **Life's own policy** with a quote from the reply as evidence (a quote
not in the reply = a judge error, never a Life failure); the judge model is apart from Life's and
never falls back to them; critical failures first and apart (judged ones "need review" until the
judge is calibrated); repeats and unstable results; a suite-version hash — different suites are not
compared; a > 10-point regression gate; a blind 30-item calibration sample whose agreement names
missed failures apart from false alarms.

**Run 4 classified:** 9 real (4 fixed by #462) · 1 measuring error (`tr-conflict`: a question mark
inside a quoted sentence — fixed in #463) · 1 judge error (`en-vendor`) · 3 contestable. Correction:
`ar-useless-twice`'s «علبة» is a **real** repeat (the rejected tip was «ضع العلبة في الخزانة»), not
a false alarm as first said. A human's calibration labels are written by a person; a model's labels
are another judge.

## 6. The order from here

1. ✅ Owner: merged #461 and Tec-Life #101, deployed (2026-10-23).
2. ✅ Run 4 (above). → Owner: merge #462, deploy ai-service, run 5.
3. Owner: the end-to-end test on the phone (§5).
4. Only then: **my future** — the vision first, then life areas, then goals linked to the vision.
5. Then the engine between conversations: one tap after a step («did you do it?») that writes the
   outcome into the memory — only with a real mechanism and the person's consent.
6. Later, after real use: patterns offered as questions, with their uncertainty stated.

## 7. Open — for the owner

- Life offering a lookup (not searching unasked) — §4.
- Whether the quality workflow gets its own Tavily key, so search is measured (it would spend the
  same 1 000 a month).
- The ten non-Arabic, non-English translations of the new screens still need a native speaker's read.
- `LIFE_VISION_HUMAN_DEVELOPMENT_2026-10-17.md` §G5 (the Qur'an and Sunnah as the model's foundation,
  through a scholarly reviewer) is untouched by this work and still the owner's decision.

## 9. Paused (owner, 2026-10-25)

**Decision:** Life work stops here. No money goes to models until there is income. The owner's
reason: patching each misunderstanding by hand is not an engine of understanding.

**What is live** (merged 23–25 Oct, tec-core-backend #462, #464–#468), each read in code for every model:
- the memory lead, with the opener in the person's own words;
- safety, which always points to help;
- one question per reply;
- an opening sentence of understanding;
- honest durations;
- «بشرب» with cigarettes read as smoking;
- a restate step for Arabic;
- a correction owned.

**Where it stands:** run 10 (gpt-oss-120b, 52 scenarios) had 0 HARD failures. The owner's own phone
test, served by the same model (`life.talk 200 model=openai/gpt-oss-120b` in the log), still read
«عاوز ابطل سجاير بشرب كتير» as drinking and offered water — after the dialect note had been added.
**Egyptian dialect is beyond the free models; code around a model cannot add the understanding it
lacks.** The scripted eval passed what it was written to test and missed this. Real conversations
are the measure.

**What would reopen it:** a stronger model, when there is income. There are two routes:
- Groq's Developer tier (pay per token), when Groq reopens upgrades — "temporarily unavailable due
  to high demand" on 25 Oct;
- a provider strong in dialects. That one is a privacy decision first: today Life's words go to Groq
  only (`audits/LIFE_PRIVACY_TIERS_DECISION_2026-10-23.md`).

The first step is a side-by-side run on the eval's scripted conversations. That run sends no
person's words.

**Left as they are:**
- tec-core-backend #463 (eval phase 1, draft);
- the calibration sheet (https://claude.ai/artifact/24dq7UWLHh7S5T1fQFPaww, 30 replies from run 10, unlabelled);
- `LIFE_TALK_RESTATE` stays on. It costs one extra request for each Arabic message; set it to `off` on a short-budget day.
