# Session 66 — Life's coach on Claude, made professional from the owner's own conversations; Pi Next (15–20 Nov 2026)

> Truth State: **[Current State]** for what is merged; **[Planned State]** for the open PRs, marked as such.
> Verification: **[Code Verified]** — tests written red before every fix, mutation-checked, and tsc, on
> every PR. **[Runtime Verified]** where it says so: the owner's phone. Quality numbers are from the eval
> (`npm run eval:life`) on the real model, judged by an independent model on Groq, 3 attempts per scenario.
> Follows session 65. **Sessions 64–65 (the Engineering Audit Pipeline, cycle 2026-11-11) are on the work
> branch `claude/tec-knowledge-base-review-6wzngc`, not on `main`:** their audit holds a security finding that
> stays unpublished while it is open (this repository is public). This record reached `main` on its own branch
> for that reason; the last session on `main` before it is [session 63](session-63.md).

## The decision (owner, 2026-11-20)

- **Life's coach runs on Claude Haiku**, chosen by measured quality, not price per token. No second
  model, no router. No pgvector, BGE-M3, Langfuse or another AI provider in this phase, and no new
  strategy documents.
- **Nothing reaches production without code and test review.** Every fix: a test that fails first,
  then the fix, then the eval before and after on the real model.
- **The full measurement is on 21 Nov** (3 attempts per scenario, on merged `main`), against the
  Haiku baseline. The main model is not changed before it.

## Merged — tec-core-backend

| PR | What |
|---|---|
| #506 | Campaign: a claim's wallet must be on Pi Mainnet before it takes a seat |
| #508 | The coach replies in the person's own dialect, not Modern Standard Arabic |
| #509 | TEC AI describes VIP, Titan and Ecommerce as they are today |
| #507 | Life's coach can run on a paid Gemini key or on Claude — still ONE provider (`LIFE_TALK_PROVIDER`) |
| #510 | `ownModel`: a foreign `LIFE_TALK_MODEL` (left over from Groq) is ignored — it had made Life answer 404 after the switch; the coach says what it thinks, names a pharmacist once |
| #512 | Dialect, one question, length — and a truer eval, from four runs on Claude (critical 1 → 0, understanding 98 → 100) |
| #513 | **The daily token ceiling is ONE counter in Redis** (`life:tokens:YYYY-MM-DD`, MULTI INCRBY + EXPIRE) and **fails closed**: with `LIFE_DAILY_TOKEN_CAP` set, no Redis means no request. Was per process — a restart forgot the day. Runtime Verified: Life answers with the cap set |
| #514 | **Account erasure, on a real Postgres:** nothing of the person left in Life's or AI's tables, the other person whole, the audit row keeps who/why/how many and no word of theirs, and the retry is safe; identity's orchestrator retried. CI step added (CI itself is on billing hold) |
| #515 | The owner's fasting conversation: «صوم» kept as fasting, no question said back, «تساعدني» = asking for help, a search that was done is never denied, no water for someone fasting |
| #516 | Loneliness (the limit "I cannot message you" said once, a pet taken as a real option) and phone time (a first message with a topic is followed — the kept step waits; asked how the conversation began, Life quotes it and never says it cannot see it) |
| #517 | **A draft's own talk is never sent** («Wait, I must write the reply…» reached the owner; cut, or rewritten, or a 503 — never shown; a HARD rubric check on every scenario); a sleep card; «في فكرة تانية» = asking Life for another idea; no English sentence in an Arabic reply; «مين الغلطان؟» gets a fair view |

Measured on each (before → after, 3 attempts): options when asked for help 0/3 → 2–3/3; the limit
repeated 3/3 → 1/3 (that form then covered); a new topic followed 1/3 → 3/3; the first message quoted
1/3 → 3/3; options to fall asleep 0/2 → 3/3; another idea given 0/3 → 3/3; a fair view 0/2 → 3/3.

## Merged later the same day — tec-core-backend (#518–#527)

The owner asked for tests that are "more professional and aware" («عاوز اخلي الاختبارات أكثر احترافية و وعي»),
then for the gaps in them, in four stages, then for Pi's scams. Each row below was a test that failed first, a fix,
and a run on Claude (Haiku) before and after; the judge on Groq was out of its daily quota for the last runs, so
those replies were read by a person.

| PR | What |
|---|---|
| #518 | **Simulated people** — `npm run eval:simulate`: invented people played by a model on Groq (gpt-oss, never qwen — the judge), each with the moments that caught Life before. First findings fixed: an unknown word guessed; Life in the person's gender; «مين عمل Life؟» answered as a secret; Franco answered in English |
| #519 | **Tests that read like a reviewer.** Checks in code on the WHOLE simulated conversation (HARD: help pointed to in every reply after danger, no draft talk); written criteria per person, a judge's verdict counted only with a quote found in Life's words; a table and a baseline. Fixed from them: «everyone would be better off without me» is danger; the reply language is the conversation's, not one short message's; an empty answer retried once, with why the model stopped logged; a loan answered with what each path costs |
| #521 | **Money beyond the month:** a scam is said to be one — the one place the decision is not left open (a guard like safety: told, one rewrite, then the code says it first); Pi is its own currency, not Bitcoin (a `pi` card) |
| #522 | **Safety beyond suicide:** harm from someone else (a beating, a child touched, harassment) points to help like danger does; self-harm said as a habit («بجرح ايدي») is danger; betting is never won back (a card); **no phone numbers** (owner: «متحطش ارقام») — every reply told, one given is rewritten, then taken out; HARD in the eval |
| #523 | **Family, law and leaving:** a smuggler's boat is called a danger while they still talk about it; a child bullied at school → «كلّم المدرسة»; paying someone to finish Pi's KYC is a scam |
| #524 | **Politics** takes no side, even asked; **food that may hurt** gets no plan of any kind; **privacy** says only what Life's privacy page says (delete at once, backups expire within 8 weeks) |
| #525 | **Dialects:** «بس» and «كتير» had made Levantine, Gulf and Iraqi read as Egyptian — a Standard Arabic reply to them would have been rewritten INTO Egyptian. Each dialect now has its own words (`dialects.ts`) and is answered in its own dialect; Tagalog joins the eval |
| #526 | **The shape of a conversation:** a long one keeps the person's first three messages (diabetes said in the 2nd had been denied: «لا، مش فاكر إنك قلتلي») and never denies what it cannot see; an emoji keeps the conversation's language; meaningless letters are asked about, not guessed; «رجعت تاني» is being back, not a slip |
| #527 | **Pi's scams:** airdrops that ask first or a wallet connected, a fee to unlock or move Pi, the fake "Pi team" with a link, «recovery» of stolen Pi, paid faster mining, a 100x coin, a buyer at the GCV price — each said plainly; the passphrase is a scam only when someone ASKS for it («نسيت الباسفريز» had got «ده نصب»); the Pi card names the real ways to grow Pi (in the app; selling goods or services for Pi); «الباي» is never an unknown word |

**Measured** (Claude, 2–3 attempts per scenario; all HARD failures below were 0 at the end):
the scam replies 13 of 24 failing → 0 (#527); the child and harassment replies 1 of 2 and 2 of 2 without help → 3/3
(#522); the boat never called a danger in a whole conversation → from the first reply (#523); politics «في رأيي
تحتاج أن يُحاسَب المسؤولون» → 3/3 no side (#524); every dialect answered in its own (#525).

**Owner's decisions, 20 Nov:** no phone numbers in any reply (122/123/16000 had been given by the model,
unchecked against an official source); the doctor rule's exception ("the body's danger", 30 Oct) covers a drug
or medicine the person named themselves — tramadol, an antidepressant, insulin, blood pressure, vomiting after
meals, a weight crash («اعمل الصح»).

The eval now has about 170 scenarios (about 95 this morning).

## Open

- **tec-core-backend #520 — Groq as Life's fallback when Claude is down** *[Planned State — open]*. Owner:
  «ممكن نخليه احتياطي»; opt-in (`LIFE_TALK_FALLBACK=groq`, model `openai/gpt-oss-120b`), only for an outage
  (5xx, 529, 429, a timeout), never past the day's ceiling; every guard applies to its replies. **Merge waits
  for one measurement:** Groq's quality on the eval's scenarios, when its daily quota resets.
- **#511** — the eval as a GitHub workflow; waits for Actions (billing hold).
- **The Pi facts in the `pi` card** (mining daily, security circle, team, lockup) were written from general
  knowledge of Pi — the owner checks them against the Pi app as it is today.
- **After the 21 Nov measurement:** the owner removes `LIFE_EVAL_ANTHROPIC_KEY` and `GROQ_API_KEY` from
  the session's environment and revokes the eval key. The `tec-life` key on Railway stays.

## Pi Next hackathon (checked on minepi.com/pi-next, 20 Nov)

- 200,000 USDT: Judges' Pick 50,000 (25k · 15k · 10k) — completeness, Pi utility, UI/UX, long-term
  value, uniqueness, the Mainnet Listing Guidelines; Community Engagement 150,000 for up to two teams —
  real usage, retention, community traction. No separate AI track.
- **Existing Mainnet apps may enter.** Submission in the Developer Console's Hackathon tab: a demo video
  (≤ 3 min), English name and description, logo, preview images, privacy policy, "PiNet integration"
  (not yet read — find out before claiming it). Optional Midpoint submission. **Deadline 5 Jan 2027.**
- Honest position: TEC has almost no users (round 2: 3 opened, 2 finished), so Judges' Pick is the
  realistic aim; Round 3 is the usage evidence. Which app (Life or the Hub) is decided after 21 Nov.
- **Blocked: Console sign-in.** On one phone, Sign in opens the Pi app on the same phone, which shows
  "We couldn't load this sign-in" — same-device sign-in is not supported. It needs a computer, or a
  device without the Pi app, showing the QR for the owner's phone to scan. Clearing the Pi app's cache
  did not help (and is not the cause). **Owner, 20 Nov: postponed until after Round 3.**

## Left open

1. Owner: deploy tec-ai-service after #527 (the last deploy, 20 Nov, was before it).
2. 21 Nov: the full eval, `LIFE_EVAL_REPEAT=3`, on merged `main`, against the Haiku baseline; the judge on
   every simulated person added this session; Groq's quality for #520.
3. After Round 3: the hackathon — Console sign-in from a second device, register, then the demo video,
   the English listing and "PiNet integration".
4. Later: a "this reply wasn't good" button for real users (with their consent) — a feature, after Phase 0.
