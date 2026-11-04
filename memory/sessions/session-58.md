# Session 58 — Life: the eval's one-in-three misses enforced in code, «مستقبلي», a review, the real cost of a reply (31 Oct – 4 Nov 2026)

> Truth State: **[Current State]**. Everything below is merged to `main` unless it says otherwise.
> Verification: **[Code Verified]** — tests, tsc and lint on every PR. **[Runtime Verified]** where it
> says so: eval runs #13–#16 ran in GitHub Actions against Groq; the cost lines and the «مستقبلي»
> screens were read from the owner's phone and Railway logs.
> Same branch as session 57 (`claude/tec-knowledge-base-review-6wzngc`).

## What happened

### The coach, run by run (qwen/qwen3.8-27b serving, gpt-oss-120b judging)
- **Railway:** `LIFE_TALK_MODEL=qwen/qwen3.8-27b` is set; the logs show `life.talk 200 model=qwen/qwen3.8-27b`.
- **The owner's phone, 30 Oct → tec-core-backend #475:** a rejected option named by its number
  («رقم ٣ مش هتنفع») came back; «بتجري في الدم» (the body's pull) was misread and got no pharmacist;
  Life defended a wrong word it wrote («الأشواك»). Fixed: numbered options are parsed and a rejection
  by number rules out that option only; a `withdrawal` card names a pharmacist or doctor plainly
  (nicotine replacement, no brand or dose); the correction note says a wrong word is Life's mistake.
- **Run #13 → #476:** the guard's rewrite returned the conversation's opener verbatim; qwen swapped
  «الأشواك» silently. Fixed: a rewrite that copies an earlier Life reply is refused; the correction
  note names the exact word Life wrote.
- **Run #15 → #477:** one miss in three per scenario — the first draft was the old options list, one
  reply asked "why quit?" with no pharmacist, one swap stayed silent. Fixed: a first draft that copies
  is rewritten; withdrawal without a pharmacist is rewritten; the word must be named and owned.
- **Run #16 (5 scenarios × 3, on #477):** no critical failure, understanding 100 %, help 14/14,
  nothing unstable between attempts.
- **#479:** two questions joined by «أو / أم / و» under one question mark count as two (Arabic, English,
  Spanish, French; a choice inside one question is left alone); the eval counts the same.

### The cost of a reply (#479, Runtime Verified 1 Nov)
Every reply logs `life.talk cost calls= tokens= retries= skipped= ms=` — numbers only. Rewrites after
the first answer are capped (`LIFE_TALK_MAX_RETRIES`, default 2); safety is never capped. **Read from
Railway, 21 replies of one conversation:** 2 requests per reply (understanding + reply) in 19 of 21,
one rewrite in 21; ~2,900 tokens at the start to ~4,100 at the 30-message window (mean ~3,700);
0.5–0.75 s. ~2,400 tokens are the fixed prompt and cards (1,400 on 18 Oct); the understanding step is
~13 %. **One 429** came from the per-minute limit (4 replies in 77 s), not the daily one; the chain
answered from gpt-oss-120b in 0.7 s. At 200K tokens a day per model, qwen alone carries ~54 replies a
day. The eval uses the repository's `GROQ_API_KEY` — if it is the same Groq account, it spends the
same daily budget.

### The owner's phone, 1 Nov — the workers on his site → #480 + Tec-Life #108
Seven things: «الصناعيه» (craftsmen) read as industry and «دمغهم مضلمة» (closed-minded) as «ظلم»;
«المفروض اعمل ايه» read as what the other man should have done, so no help came; Life said back the
person's meaning in its own voice («لا أعرف من…»); «انتا بتخترع» not read as a correction; a question
in fifteen replies running; asked «انتا شايف انا اتصرفت صح» after cursing a worker, Life praised it as
"firmness"; feelings added and made stronger, a fact assumed, an apology after a plain «لا». And
Life's own opener asked two questions joined by «أو». Fixed: dialect hints in the understanding step
(and who is speaking is kept); a reply that echoes the restatement is rewritten; «بتخترع / مش لدرجة»
are corrections and a three-letter word is named; after three replies that each asked, the next asks
none (not in danger, not when they asked for help); a `judged` card — asked "was I right?", Life is
honest and kind and never praises an insult as firmness; three core rules; the opener asks one
question in twelve languages; eight eval scenarios and a `rest` expect. **Not yet measured.**

### «مستقبلي» — my future (tec-core-backend #478 · #479, Tec-Life #106 · #107)
§6 step 4 of `audits/LIFE_MEMORY_AND_HUMAN_BUILDING_2026-10-23.md`. A one-year vision in the person's
words, the life areas they choose (health · work · family · faith · money · learning) each with an
optional line, and an optional area on every goal. `life_vision` + `life_areas` + `life_goals.area`
(migration `20261031000000_add_future`, applied — tec-life-service logs, 1 Nov). Self-declared, not
gated, never served by the context door; purge, erasure and the deletion replay cover it. The coach
knows the vision and areas while the journey is kept, told it is a direction, never preached. The
Goals tab is now «مستقبلي» (12 languages); Home shows the vision and each area with its active goals
counted («الصحة · هدفان», «لا هدف بعد»); the monthly review names the areas that moved and those with
no goal. The π target is asked only for a money goal. **Seen on the owner's phone** (vision, areas,
a goal linked to an area); Save sat under the bottom bar — fixed in #107.

### A review of Life (1 Nov)
The owner asked for a full review. Rated 7/10: privacy and architecture 9, code and tests 8.5, coach
quality 6.5, UX 6.5, readiness and verification 5.5, product focus 6. The two quickest items were done
the same day: the last English on the Goals screen (Tec-Life #107) and the cost meter (#479).

## Left open
- Run the eval on the eight 1 Nov scenarios (`ar-eg-craftsmen,ar-eg-dark-minds,ar-eg-what-should-i-do,
  ar-eg-echo,ar-eg-was-i-right,ar-eg-own-words-feeling,ar-eg-no-is-an-answer,ar-question-streak`),
  when no one is using Life (shared Groq budget).
- The phone: the step card after a kept summary; a conversation after 22:00; the coach linking to the vision.
- From the review, still open: label the 30 calibration replies; an admin page of real use (coach
  users, steps, returns); declutter Home (owner's call); naming Groq on the privacy page (owner's call).
- Later Life work: values from the person's reasons (with consent), voice, patterns.
- Outside Life: the rest of the key rotation, then Round 3.
