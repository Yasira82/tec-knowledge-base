# Session 56x — Life becomes a personal life coach: from a questionnaire to a measured conversation (17–20 Oct 2026)

> Truth State: **[Current State]** for what is merged; **[Planned State]** for the quality eval
> (tec-core-backend #456, open). Verification: **[Runtime Verified]** for the deletion ledger (the
> owner's Railway log: "deletion ledger replayed (0 request(s)) — Life is ready", and a delete that
> worked) and the owner's own conversation tests on his phone; **[Code Verified]** for every PR —
> tests, tsc, lint, e2e. Same branch as 56s–56w (`claude/tec-knowledge-base-review-6wzngc`, KB PR
> #220). The reference for how it works now is `audits/LIFE_AI_AS_BUILT_2026-10-20.md`; this file is
> the story.

## 1. Where it started

On 17 Oct Life's first session was a fixed questionnaire. On the owner's phone it read as a form —
"I want someone to talk to me and understand me" — so it became a conversation: a stateless,
Groq-only talk route in tec-ai-service, a chat in Tec-Life, consent first, nothing kept unless the
person chose to keep a summary they confirmed (`audits/LIFE_FIRST_SESSION_SPEC_DRAFT_2026-10-17.md`).

## 2. The owner's tests shaped the conversation (18–19 Oct)

The owner talked to Life about smoking, a relapse, frustration, a mosque. Each reply he showed
became a fix:
- a relapse led the reply instead of a plan asked for earlier; options already given were not
  repeated; markdown stopped reaching the page as «**» (#449);
- every Arabic word in MSA even when he wrote in Egyptian; one question per reply; frustration
  brings something new, never "shall we change the subject" (#450);
- «اديني» is not «دين» and «محل» is not «حل» — whole-word matching for the cards;
- summaries speak *to* the person («أنت»), never about them (#452).

Gemini was considered and **rejected**: its free tier's privacy terms did not meet Life's bar.

## 3. Keeping, deleting, measuring (18–20 Oct)

- Deleting a kept conversation re-saved it on the next reply, and a DELETE with an empty JSON body
  was refused by Fastify (Tec-Life #90, #91).
- Before/after v1 — one thing the person counts, before and later, never turned into a claim of
  cause (#451, Tec-Life #92); a step can become a goal, with no π field for it, offered once
  (Tec-Life #93–#95).
- **Deletion ledger** in identity (#453): record → delete → confirm, replayed on every start so a
  restore cannot bring a deletion back; switched on by the owner (`LIFE_DELETION_LEDGER=on`),
  runtime-verified. Backup retention kept at 8 weeks ("the engineering-correct one"); the privacy
  text says so (Tec-Life #96).
- **"How will we know there is real use?"** — counters with no identity, and a bar set before any
  number: in the last two weeks, ≥5 conversations reached the end AND ≥5 "after" values; admin
  tokens not counted (#454, Tec-Life #97). The 20–30 pilot people come in Round 3.

## 4. From a conversation to a coach (20 Oct)

- **Round 3** (tec-app #320): Life's mission card tells a Pioneer what to try, in 12 languages, and
  that the report need not share what was said; Life's registry card no longer says "goals and
  preferences".
- **Twelve languages, no vendor** (Tec-Life #98): «عاوز life يبقى ال ١٢ لغه شغالين» · «مش شرط
  اليوزرز يعرف … ايه التقنيات».
- **Cards in 12 languages, then 27 cards** (#455): «ضيف كلمات البطاقات بال ١٠ لغات», then seven
  cards for "more professional and creative", then eleven more "so it covers the whole of life".
  Pushed back, and kept: a coach is **not a doctor, lawyer or financial adviser**; at most three
  cards a reply so a small free model still follows them.
- **"Your personal advisor"?** The owner asked; recommended **coach** instead (an adviser decides
  and is liable; a coach helps the person decide). Owner: «الصح هندسيا للمشروع احنا مشروع بناء
  الإنسان» → «مدرّبك الشخصي للحياة» in the prompt, the interface (12 languages) and the Hub.
- **Skills** (#455): told apart from cards — a card is *what* to know, a skill is *how* to work.
  Four, one per reply, by the stage: understand · options · commit · review.
- **Capabilities v1** (#455, Tec-Life #98): after a yes, Life proposes one goal or skill; the
  person's tap is the only thing that writes it. Reminders already come with a goal (the weekly
  check-in), so no second reminder was built.
- CI: two e2e jobs failed — one real (the session e2e still looked for "(Groq)"; it now also
  asserts the word is nowhere on the screen), one not ours (ubuntu-latest rolling to 26.04, where
  Playwright 1.59 cannot install chromium — pinned to ubuntu-24.04 in Tec-Life and tec-app).

## 5. "Not more skills — a loop that learns" (20 Oct)

The owner shared a review: seven capabilities (context, evidence, memory, adaptive planning,
outcome, intent, action) in one loop. Answered: most of it is built (the mapping is in the
as-built file §9), the direction is right — **and the one thing missing from the review comes
first: nothing measured the quality of a reply.** 27 cards and four skills had been added on
unit tests that prove plumbing only.

So the session ended on the **quality eval** (#456, open): 31 fixed conversations in 12 languages
through the real route to the real model; HARD checks (diagnosis, medicine, vendor, promise,
safety, grief, deciding for them, a ruling, a coin) fail the run, SOFT checks are compared between
runs; an optional judge for understanding and invented facts. By hand only — it spends the tokens
people use.

Also answered: **how Life's AI differs from TEC AI** (as-built §7) — and a gap found while
answering: TEC AI may send the Life categories a person shared to free Gemini/OpenRouter tiers,
the very tier rejected for Life. Left to the owner.

## 6. Left open

1. Merge #456, add `GROQ_API_KEY` as a repository secret, run the eval → the baseline.
2. The TEC AI ↔ Life privacy gap.
3. A native read of zh · ko · hi · vi · id.
4. Round 3: spread entry over days (~200–250 Life messages a day on the free tier).
5. Then, in order: the kind of problem in `understand` → evidence marking in the summary →
   outcome patterns once the real-use bar is met.
6. KB PR #220 still carries the first-session spec draft (marked do-not-merge) — this record and
   the as-built file ride on it until the owner decides.
