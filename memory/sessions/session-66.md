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

## Open

- **tec-core-backend #518 — simulated people** *[Planned State — open, awaits the owner's merge]*.
  The owner asked, «هو انا هقعد ادرب فيه»: no. `npm run eval:simulate` has 13 invented people (work,
  marriage, kids, exam, debt, grief, weight, a skeptic, Franco…) played by a model on Groq (gpt-oss —
  never qwen, the judge: Groq's daily token limit is per model, and one run spent qwen's 200K for the
  day), each with the moments that caught Life before; Life answers through the real route; a person
  reads `eval-report/life-simulate.md`. Its first runs found, and the PR fixes: an unknown word guessed
  and built on («الفرقاي» → «الفرائض»); Life taking a woman's gender for its own («أنا آسفة»); «مين عمل
  Life؟» answered as a secret (now: the coach TEC built — the model still never named); Egyptian in
  Latin letters answered in English. The full run after: 73 replies, no HARD failure.
- **#511** — the eval as a GitHub workflow; waits for Actions (billing hold).
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

## Life Pro — what it should sell (proposal, 20 Nov)

> Truth State: **[Planned State]**. Governance State: **[Draft]** — the owner asked for it to be documented;
> the numbers wait for his final yes. Implementation: after Round 3, so the experience does not change mid-round.

**What Life Pro sells today (read from Tec-Life `main`):** 5π a month, paid once (no auto-renewal). It
unlocks only unlimited active goals (free: 3) and Goal Insights. **The coach is free and unlimited per
person** — the one thing of value, and the one thing that costs money (Claude tokens); only the day's
platform-wide token cap stands in front of it.

**Cost of one coach reply, measured 20 Nov on Claude (10 real conversations):** 2.1 model requests,
~4,150 tokens in and ~475 out — **about $0.00065 a reply** (~$0.65 per 1,000), web search not included.

**π price, 20 Nov (the Hub's card, PI/USDT on OKX): $0.0513** (−10.5% that day). At that price 5π covers
~13 replies a day for a month, 6π ~16, 7π ~18.

**The proposal:**

| | Free | Life Pro **7π / month** |
|---|---|---|
| Coach replies | **10 a day** — the same model and quality all day | **40 a day** (a fair-use limit) |
| Full memory · monthly review · Goal Insights · unlimited goals | — | ✅ |
| Worst case per person per month | ~$0.20 | ~$0.78 |

- After the limit, a warm message: what was said is kept; continue tomorrow, or Life Pro now. **A person in
  danger is never cut off** — the safety reply and help numbers always go through.
- A typical Pro user (one conversation of 6–8 replies, not every day) costs ~$0.10–0.15 a month: profit
  at 7π. A user who hits 40 every day costs more than he pays; the rest cover him, and the platform's
  daily token cap stays the last guard.
- **Rejected: falling back to the free Groq model after the free replies.** Groq's free limit is per
  model for the whole account (~200K tokens a day ≈ 50 replies for everyone together, and the same
  quota the eval's judge uses); the person would find Life suddenly weaker mid-conversation, in the
  dialect Groq handles worst; and their words would go to another company without the privacy page
  saying so. Groq stays a candidate only as a fallback when Claude itself is down — a separate decision.
- **Limits fixed and reviewed monthly**, not tied to the π price automatically: the price moves 10% in a
  day, and a person's limit should not.
- **How:** a per-person daily counter in Redis inside tec-ai-service (as the cost cap, #513), never in the
  app; Pro read server-side from the live subscription; if Pro cannot be read, the person is treated as
  free — never locked out by an outage.

## Left open

1. Owner: deploy tec-ai-service after each merge (#517 merged 20 Nov); merge #518.
2. 21 Nov: the full eval, `LIFE_EVAL_REPEAT=3`, on merged `main`, against the Haiku baseline.
3. After Round 3: the hackathon — Console sign-in from a second device, register, then the demo video,
   the English listing and "PiNet integration".
4. After Round 3: Life Pro as proposed above, once the owner confirms the numbers.
5. Later: a "this reply wasn't good" button for real users (with their consent) — a feature, after Phase 0.
