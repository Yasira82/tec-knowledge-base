# Session 59 — Life's last fixes measured, the GitHub bill explained, CI cut, development frozen (4–5 Nov 2026)

> Truth State: **[Current State]**. Everything below is merged to `main` unless it says otherwise.
> Verification: **[Code Verified]** — tests, tsc and lint on every PR. **[Runtime Verified]** where it
> says so: eval runs #17–#22 ran in GitHub Actions against Groq. The bill was read from the owner's
> invoices and billing screens.
> Same branch as sessions 57–58 (`claude/tec-knowledge-base-review-6wzngc`).

## Development is frozen (owner, 2026-11-05)

Everything stays live as it is: the 24 apps, the backend and Life. No new work is planned. To
resume, read C-02 §2 rows 29 and 31 first (the rotation, the bill), then **Left open** below.

## What happened

### Life — the eight 1 Nov scenarios, run by run (qwen/qwen3.8-27b serving, gpt-oss-120b judging)
- **#481 (run #17):**
  - A feeling is never made stronger than they said. `softenFeelings` takes «جدًا / كثيرًا / شديد» out in
    code unless the person used one.
  - A request for what to do («المفروض اعمل ايه») is answered with numbered options (`asksWhatToDo`).
  - The rest reply was given its shape.
- **#482 (run #19):**
  - The echo check fired on five replies of seven, because Arabic spells "I yelled" and "you yelled" alike
    («صرخت»). A reply that addresses them is never an echo now (`addressesThem`).
  - The optional understanding step waits 5 s, once.
  - The eval asks a timed-out attempt once more.
- **#483 (run #18):** «يضايقك كثيرًا» — «يضايق» and «كثيرًا» are on the lists.
- **Runs #17, #19, #20 and #21 together:** all eight 1 Nov scenarios pass.
- **#484 (run #21: `streak=dropped` three times of three):**
  - Told to ask nothing, the rewrite came back the same length to the token, question and all, and the
    fallback left one sentence.
  - The draft is now **edited**, not written again: one small request (temperature 0) with the draft and
    the latest eight turns.
  - The report lists every reply, passed or not, folded.
- **Run #22 (on #484):**
  - `streak=edited` 3/3, at 2,983 tokens a reply instead of 4,713.
  - The reply: «أفهم أنك صرخت عليهم. فكرة قد تفيد: …» — no question and an idea, but it said back only the
    last message.
- **#485:**
  - The edit begins with the whole situation, in their words.
  - A new scenario, `ar-question-streak-recap`, judges that.
  - **Not yet measured.**

### The GitHub bill (Runtime Verified from the owner's invoices, 5 Nov)
- **Unpaid:** the 28 Oct invoice, $141.08.
  - Actions usage for September: $77.00, the Actions budget's cap.
  - Copilot usage for September: $60.08.
  - GitHub Pro: $4.
- **Usage is billed a month after it happens:**
  - July's Actions ($58.04) on 28 Aug.
  - August's Actions ($63.59) and Copilot ($29.36) on 14 Sep.
  - Nothing was billed twice.
- **Copilot:** Copilot Pro ended on 14 Sep (the 13 Sep Pro+ upgrade was closed without a charge). The
  account is on Copilot Free, and Copilot usage has been $0 since October.
- **Why July–September cost so much:** every repository was private until 24 Sep, so every CI run
  counted.
- **October:** since 24 Sep only `Tec-core-backend` is private.
  - October's Actions were $74.36 consumed.
  - $72.85 was discounted: the public repositories plus the included $18 (3,000 minutes).
  - **$1.52 is billable**, all of it the backend's (≈ $19.5 of private use).
- **CI cut, #485:**
  - **CodeQL** on the private backend never delivered anything: "Code scanning is not enabled for this
    repository … Uploading failed SARIF file". `continue-on-error` showed those runs green, at about five
    minutes a pull request from the start. It is skipped now unless run by hand or `CODEQL_ON=true`.
  - **Docker** builds only the services whose image inputs changed.
  - A push that changes one service's code went from about 12 billed minutes to about 3. On #485's own
    run CodeQL was skipped in a second.
- **Budgets (owner's screen):** Actions $77, Git LFS $0, nothing for Copilot. A product with no budget is
  unlimited.

### The public repositories' history, scanned again (5 Nov)
- **Scope:** the 27 public repositories, every branch, over 5,000 commits. The scanner prints a kind,
  a place and a hash, never a value; it was first proved on a throwaway repository with fake keys.
- **Clean:** 22 repositories.
- **Known:** the Hub's key in `clear-payment`, found on 24 Sep and already rotated.
- **Harmless:** a Firebase web key (public by design), `.env.local` files with public settings only
  (App ID, sandbox, the public gateway URL), and a test value.
- **A second Pi API key literal in an app repository's history (June 2026).** As far as is known it has
  not been rotated. The owner has the details; they are not written here, because this repository is
  public.

## Corrections
- Session 56p says the 23 apps' history held no real key. It held this second literal; the 24 Sep scan
  missed it because the variable name was lower-case.
- In this session, the bill was first read as October's usage; it is September's. The knowledge base
  was said to be "likely still private" in October; it was public — the October discounts show the
  backend as the only private use.

## Left open (frozen — in this order when work resumes)
1. **The bill:** pay the $141.08. Set budgets of $0 with "Stop usage" for Actions and Copilot. The next
   invoice (28 Nov) should be about $5.52 ($4 Pro + $1.52).
2. **The rotation** (`audits/RAILWAY_SECRET_ROTATION_2026-10-22.md` §4), Pi API keys first, including the
   key found in public history.
3. **This repository is public**, and it says which secrets are not yet rotated. Finish the rotation, or
   make it private until then.
4. **Life:**
   - run `ar-question-streak,ar-question-streak-recap`;
   - the phone tests (the step card, a conversation at night, the vision);
   - label the 30 calibration replies.
5. **What runs out while frozen:** the npm tokens on **25 Nov** (publishing stops; nothing is published
   while frozen), and Node 20 on the backend before **Jan 2027** (C-02 rows 3–4).
