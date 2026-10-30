# Session 57 — Life restarts on what a free model can do: dialect measured, a correction in one tap, the step day by day, a coach that knows the week (26–30 Oct 2026)

> Truth State: **[Current State]**. Everything below is merged to `main` unless it says otherwise.
> Verification: **[Code Verified]** — tests, tsc and lint on every PR. **[Runtime Verified]** only
> where it says so: the two quality-eval runs (#11, #12) ran in GitHub Actions against the real Groq
> models. Nothing of Life's new screens has been seen on a phone yet.
> Same branch as 56s–56z (`claude/tec-knowledge-base-review-6wzngc`).

## What happened

### Zone, and Zone's place among the apps (26–30 Oct)
- **Zone reviewed and translated.** Arabic throughout, the form overflow fixed, icons (Tec-Zone #67);
  the review row names the entity's kind in the reader's language (#68); Zone's own registry
  sentences — the TEC apps' summaries, evidence kinds, fixed notes — said in Arabic at display time,
  never rewritten in the database (#69).
- **A finding on the owner's phone:** the public evidence page printed the reviewer's name under the
  applicant's own application, so a verified entity read as reviewed by the person who applied —
  exactly what Zone forbids. Evidence rows carry no reviewer; the page now says «قدّمه صاحب الطلب»
  under an applicant's record (Tec-Zone #70). The owner verified TEC NBF the same day; its review
  note reads «Good» — public and permanent; the owner was asked to write what was checked next time.
- **Zone → Alert** (tec-core-backend #470, Tec-Alert #54): a new verification request files an
  owner-less alert that only an admin sees; the verdict files one to the applicant. Bilingual,
  Arabic first; filing is fail-safe and never changes the decision.
- **Zone → Ecommerce** (tec-core-backend #471, Tec-Ecommerce #84): `GET identity/zone/merchants?ids=`
  answers which sellers hold a VERIFIED MERCHANT; the product card, product page and store show
  «Zone Verified» linked to the evidence. Any error or timeout = no badge.

### CI: Playwright on Ubuntu 26.04
GitHub moved `ubuntu-latest` to 26.04, where Playwright 1.60 cannot install Chromium; every E2E job
failed before a test ran. 20 repos pinned to `ubuntu-24.04` with a comment saying when to move back
(Tec-App and Tec-Life already were). Merged by the owner.

### Round 3 (still not open)
- The owner reviewed his own test round: one paragraph was sent for all six apps and every copy was
  approved. **Each round app now names one real thing to try**, in 12 languages, none asking for a
  payment (tec-app #321); **a report whose words the same pioneer already sent for another app is
  refused** — on the page in their language, and by tec-platform-service (#472).
- `PI_A2U_WALLET_SEED` stays unset. The Hub's Mainnet wallet is under Pi review and its seed was in
  Railway during the breach — treat it as burnt; the owner has four more wallets under review and
  will **not** put a seed in Railway. Round 3 pays by hand + `Mark sent`.
- **The owner will not open Round 3 before the key rotation is finished.**

### Life — «نطوّر Life» (30 Oct)
Life had been paused (56y) because the free model misread Egyptian dialect. The owner restarted it,
choosing four directions:

1. **Which free model understands Egyptian?** Ten dialect first messages added to the eval —
   shisha, «مخنوق», «مش لاقي نفس», «أخس», the salary, the boss, the brother's inheritance, and «شاي
   بشرب كتير» the other way round — each with one critical reading criterion (tec-core-backend #473).
   The owner ran them (my workflow dispatch was refused with 403):
   - **#11, qwen/qwen3.8-27b** (gpt-oss-120b judging): 12/12 answered, understanding 95 %; the one
     "critical" failure was the brother's reply not naming the inheritance — the estrangement was
     understood. Dialogue 100 %: understand first, one question.
   - **#12, gpt-oss-120b** (qwen judging): 12/12, understanding 96 %, no critical failure — but on
     the smoking message it lectured on benefits before asking (dialogue 50 %).
   - **Reading:** both read the dialect in scripted messages; gpt-oss also passed «سجاير بشرب كتير»
     here, the sentence it failed on the owner's phone on 24 Oct. **The scripted eval cannot tell
     them apart; the phone can.** qwen keeps Life's manner better. Recommended
     `LIFE_TALK_MODEL=qwen/qwen3.8-27b` on tec-ai-service (gpt-oss stays the fallback); the owner had
     set `LIFE_TALK_MODELS_EXTRA` instead, which only appends — corrected in the chat.
2. **«مش ده قصدي»** (Tec-Life #104, tec-core-backend #473): a button under Life's latest reply puts
   the phrase at the start of the box and asks the person to say it in other words; the tap sends
   nothing. The ten non-Arabic, non-English phrases were added to the AI service's CORRECTION list,
   so the reply owns the misreading. A bare "no" would only make the model guess again.
3. **Without AI — the step, day by day** (Tec-Life #104, tec-core-backend #473): `life_step_days`
   (one closed answer per entry per day, the person's own calendar day ±1); a Home card «هل قمت بها
   اليوم؟» with seven dots and the week said plainly — no score, no streak, a first week is never
   "fewer"; a weekly TEC Alert reminder only after three days without a tap, never after DONE or for
   a step over a month old, only with CHECKIN on. Erasure counts and deletes the new table by name.
   This is step 5 of `audits/LIFE_MEMORY_AND_HUMAN_BUILDING_2026-10-23.md` §6.
4. **Voice** — not started; worth it only once the model's understanding is settled.

Then **«وعي مدرّب Life»** (tec-core-backend #474, Tec-Life #105): while the journey is kept, the talk
BFF tells the coach the days since the last kept conversation, the step's last seven days, up to
three active goals (title, π progress, next step) and the person's part of the day — the page sends
only its clock. The coach is told to connect to one item at the start, only if it fits; never a
score; short at night (22:00–04:59 on the person's device); what they write now wins; nothing of it
in danger. The intro says so in 12 languages.

### Privacy decisions taken
- **TEC AI stays on Gemini** (owner: switching to Groq «هيتحول لغبي»). What a person shares from Life
  reaches TEC AI and from there mainly Google's free Gemini tier. **The sharing switch now says so,
  naming Google Gemini** (Tec-Life #105) — the owner approved naming this provider on screen; Life's
  own coach provider stays unnamed (`LIFE_PRIVACY_TIERS_DECISION` §8 decision 3 still holds for Life).
  This closes the "owner decision open" in C-02 row 28.
- **Rotation:** Groq (new key, the coach works again), Tavily (new key, old one deleted; 2 of 1,000
  credits used, no sign of misuse). `GEMINI_API_KEY` / `OPENROUTER_API_KEY` on tec-ai-service: the
  owner was asked to confirm they are the new ones.

## Corrections
- 56y said the next step was "a stronger model, when there is income". qwen3.8-27b — free, on the
  same Groq account — had never been tried as Life's coach; it is the one measured here.

## Left open
- Railway: confirm tec-ai-service and tec-life-service deployed after #473/#474 (the step-days
  migration runs on tec-life-service's start); set `LIFE_TALK_MODEL`, remove `LIFE_TALK_MODELS_EXTRA`.
- The owner's phone test of the new Life (dialect, «مش ده قصدي», the step card, the coach at night).
- The rest of the rotation (`JWT_SECRET`, `INTERNAL_SECRET` on Railway and every Vercel app, Pi API
  keys, database passwords, `BACKUP_PASSPHRASE`), then Round 3.
- The judge is still uncalibrated: 30 replies from run 10 wait for a human label.
- Voice (Groq whisper, transcript shown first) — decision 4 of the privacy-tiers doc.
