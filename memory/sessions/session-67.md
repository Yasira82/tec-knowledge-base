# Session 67 — Life's full measurement on Claude; an outside engineering audit of Life, checked and fixed across the fleet (21 Nov 2026)

> Truth State: **[Current State]** for what is merged; deploys are marked where the owner confirmed them.
> Verification: **[Code Verified]** — a test that fails first, then the fix, on every PR; where a mock cannot show
> the bug (concurrency, a restore), the test runs on a **real Postgres 16 or Redis** in the session. Quality numbers
> are from `npm run eval:life` / `eval:simulate` on Claude Haiku, the model in production.
> Follows [session 66](session-66.md). Sessions 64–65 stay on the work branch (their audit's finding is open).

## 1. Life's coach — the rest of Pi's topics, then the full measurement

**Owner, 21 Nov:** «كل اللي هيدخل تطبيق Life هو مجتمع باي» — the people Life meets are Pi's community: they ask
about the coin, about goals, whether the project is real, a late KYC, problems in the app, growing their Pi, other
apps. Owner's decisions: the facts about Pi as they are (real, since 2019, open Mainnet in 2025, priced; founded by
Stanford PhDs, not a Stanford project; the price fell; **Life is built on Pi, so it is not neutral, and says so**);
other apps = **TEC's apps only**; the law = **no ruling of any kind, a lawyer**; selling Pi = **only on an exchange
that passed Pi's own KYB, none named** («الكور تيم عمل kyb لمنصات المعترف بيها»).

| PR (tec-core-backend) | What |
|---|---|
| #528 | Four cards for Pi's community: is Pi real (the facts, and that Life is built on Pi), the price (what moves it, never where), the app's problems (only the app; nothing invented), TEC's apps (the registry's own lines) |
| #529 | The rest: selling via KYB-checked exchanges, no legal ruling, the team, a wrong address, Pi Node, building an app, a shop |
| #530 | What the judge found in simulated conversations: a doubling promise was told it was a daily return; the warning was repeated after the person stepped back (now: only while they still lean toward it); money needed within a year never goes where it can fall; a GCV buyer is told plainly nobody pays that price |
| #531 | What the full eval found: a doctor for any medicine or drug taken every day (a `substances` card; a reply without one is written once more); «نصب في الغالب» — a hedge after the word — no longer passes as plain; «هذا نصب» to an Egyptian → «ده نصب»; two eval checks that read a denial («ما يوجدش ربح مضمون», «محدش يعرف إمتى السعر هيطلع») as a promise or a forecast |
| #532 | What the independent judge (qwen) found: cards for a child (a parent named — rewritten once if not), harassment (her options, her choice), revenge (a complaint, a lawyer), spying on a phone (may break the law); purging gets a doctor; a bullied child is listened to first; feeling fine on prescribed pills is often the treatment; a «recovery» scam → report it inside the Pi app; an apology does not make abuse safe; Commerce is for sellers, Ecommerce for shoppers |

**The full measurement (21 Nov, before #531/#532):** 190 scenarios × 3 = **570 replies, all answered**; judged
critical: none; 5 strict checks failed once in 3 — 2 real (fixed in #531), 3 the checks' own mistakes (fixed in
#531). **The judge's pass** (qwen, 1 attempt each): 11 judged critical + 2 strict — 12 real, fixed in #532; on
Claude after the fix, **0 critical, judged or strict**. Simulated people (#530): 2 critical → 0. Life now has
**51 cards**, each with words in 12 languages.

## 2. An outside engineering audit of TEC Life — three reports, each checked against the code

The owner brought three reports from an outside reviewer (static reading, no tests run). Every finding was checked
on `main` before anything was built. Verdicts:

| Finding | Verdict | Done |
|---|---|---|
| Goal progress: lost updates; the total drifts from its log | **Real — worse than reported.** On Postgres: 8 taps at once kept 40π of 80. A lowering, and a total set through `updateGoal`, never reached the log | #533: the goal row locked for the read and the write; every move logged as a **step** or a **correction** (new column `kind`, additive migration); pace, active days and the monthly review read steps only |
| Consent written half when one category is unknown | Real, small | #533: every category checked first; one transaction |
| The replay after a restore deletes by id only | Real for conversations (their id is chosen by the page); the other kinds use database ids | #533: every item replay also requires `created_at ≤ requested_at`, as the category replays did. Proved on Postgres |
| The conversation key cannot be changed | Real (a plan missing, not a fault) | #533: `LIFE_CONVERSATION_KEY_PREVIOUS` is tried; a row opened with it is written again under the current key |
| The day's token ceiling passed by requests at once | Real, small (bounded by concurrency) | #533: each request takes its estimate in one Redis script, settles to what it spent on the day it was taken. Proved on Redis: 20 at once, room for 5 → 5 |
| The SSO token's "used" list lives in one instance | Real; also: a token with no `jti` skipped the check | #534 (auth-service `POST /sso/consume`, SET NX) · template #59 · Hub tec-app #331 · 23 apps (below) |
| The access token is readable by script | **A decision** (ADR-001, Pi Browser). The real gap: the template's `connect-src` was `https:` | A named list now runs **Report-Only** beside the proven policy (below) |
| CSRF trusts every `*.tecosystem.app` | True, little value: the session cookies already live on `.tecosystem.app` | **Not changed, on purpose** — a named list would need every legitimate cross-origin caller, which the code cannot show |
| The deletion ledger is off by default | **Wrong in fact** — switched on 2026-10-20, Runtime Verified (`LIFE_FIRST_SESSION_SPEC_DRAFT_2026-10-17.md`) | Owner re-checks `LIFE_DELETION_LEDGER=on` on Railway |
| "No test was run" | The reviewer's own limit — this session ran them | — |

One further finding in auth-service was left unchanged on purpose: changed alone it would have signed Pioneers out
of a second open tab. It is recorded on the work branch, not here (this repository is public).

## 3. connect-src — the way to a named list without breaking Pi sign-in

A named `connect-src` broke Pi sign-in in the Hub on 15 Nov (#324, TEC-AUDIT-0051: the Pi SDK reaches a host
nobody could name). So the enforced policy stays `'self' https: wss:` in every app, and a
**`Content-Security-Policy-Report-Only`** with the named list (`'self'` + Pi's hosts) runs beside it;
`/api/csp-report` logs `csp.would_block` with the **host only**, never a path or a query. After a Pi Browser
sign-in and payment, the logs say whether the named list can be enforced — app by app.

## 4. The fleet rollout (all merged 21 Nov, after the owner confirmed auth-service was deployed with #534)

tec-template-base #59 · #60 · tec-app #331 · Tec-Life #115 · Tec-Zone #77 · Tec-Alert #61 · Tec-Analytics- #73 ·
Tec-Connection #101 · Tec-Dx #59 · Tec-Elite #53 · Tec-Epic #62 · Tec-Estate #57 · Tec-Explorer #69 · Tec-Fundx #50 ·
Tec-Insure #55 · Tec-Legend #56 · Tec-Nexus #57 · Tec-Nx #54 · Tec-Titan #54 · Tec-Vip #54 · Tec-system #58 ·
Tec-Nbf #35 · Tec-Brookfield #31 · Tec-Commerce #97 · Tec-Assets #90 · Tec-Ecommerce #89.

Every app's whole suite passed before its push, with no TypeScript error more than on `main`. Commerce, Assets and
Ecommerce (older than the template) gained its `observability/logger.ts`. Nothing changes for a Pioneer: Pi counts
a visit at `Pi.authenticate`, before any of this; the app's own `pi-login` token and the Hub's both carry a `jti`.

**Order kept:** auth-service deployed first — an app landing that cannot check a token refuses the sign-in (P6).

## 5. The engineering-audit pipeline

None of this touches it: its only open PR, tec-core-backend #505 (draft), merges cleanly with #533 and #534 in
either order (tried with a real merge).

## 6. Later on 21 Nov — deployed, and checked in Pi Browser

- **Deployed** (owner's Railway screenshots, 13:27–13:28 GMT+2): tec-life-service with #533 — its migration ran on
  start, and the boot log shows `deletion ledger replayed (2 requests) — Life is ready`, so `LIFE_DELETION_LEDGER` is
  on — and tec-ai-service with #528–#535 (`migrate` found the schema up to date). #535 merged the same hour.
- **Pi Browser (owner):** a sign-in and a payment in Life succeeded. Life's Vercel logs then showed:
  - `csp.would_block` — ten reports, **one host only: `socialchain.app`**, Pi's own. Had the named list been enforced
    without it, sign-in or payment would have broken, as in the Hub on 15 Nov (TEC-AUDIT-0051).
  - `auth.sso_callback_unusable reason=replayed` once — the same sign-in link opened twice; the sign-in went through.
- **`socialchain.app` added to the Report-Only list** — template #61 and all 23 apps (merged 21 Nov). The enforced
  policy is unchanged (`'self' https: wss:`). Next: a few days of real use with no new report, then enforce.

## 7. Does Life help? (owner: «النفع يتحقق»)

The evals until now asked whether Life does **no harm**. Three pieces now ask whether it **helps**:

| PR | What |
|---|---|
| #536 · Life #117 (merged) | `GET /identity/life/admin/outcomes` and its screen in Settings: counts of what people chose — the step and their answer, the daily taps, before/after (moved or not, never "better"), the feelings they picked, who came back after a week. No text is read; every count under 5 is null; the reader's own entries are left out; admin only, audited. Tested on a real Postgres |
| #537 (merged) | Four usefulness criteria in the simulator (their own situation · small and specific · ready for the hard moment · varied) and what they found: a plan written in English was cut to empty lines (now rewritten in their dialect); a tried idea came back (now refused, unless the owner's `resolve` card answers); the named hard moment got no plan. On 12 simulated people, hard-moment failures 3 → 1; the 190-scenario run on Claude matches `main` |
| #538 (open) | The coach already saw the week's taps but only noticed them. Now, when the step comes up: stuck (≥3 "not yet", none done) → offered smaller or moved; holding (≥5 done) → offered a little more. On Claude, 3 attempts each: 3/6 → 6/6 and 1/6 → 6/6 |

## 8. Models — what a reply costs, and the orchestra

- **Haiku, measured:** ~4,840 tokens per reply over ~2 requests (190 replies) — about **$1.3 a month** for 100
  people × 20 messages.
- **Sonnet for the plan replies** was proposed and **declined by the owner on cost**; its run was stopped after
  two requests.
- **Owner's decision:** phase 1 — an orchestra of **Claude Haiku + GPT Luna + GPT Terra**; phase 2 — Sonnet and Opus.
- **OpenAI set up:** a restricted key (Chat Completions + list models only), saved as a network secret for
  `api.openai.com` `/v1/`, auto-reload off. The API lists `gpt-6-luna` and `gpt-6.1-terra`. The provider is on branch
  `claude/life-openai-provider` (no PR yet): Chat Completions only, `store: false`, no `temperature` (refused by these
  models), Life's own `LIFE_OPENAI_API_KEY`. In this cloud session the evals need `NODE_USE_ENV_PROXY=1`.
- **First result — Luna, 190 scenarios:** 190/190 answered; safety 623/624. The one flag is a reply that called the
  "3% a day" platform a scam and said not to put money in it — the check read the refusal as a promise; to be
  classified (real · the check's mistake · needs a person) with an independent judge. Tokens are not comparable
  across providers (different tokenizers): the comparison is in dollars per reply.
- **Pending:** Terra on the simulated people, then the comparison and the orchestra plan.

## 9. Privacy — who keeps the words

- **No zero-data-retention agreement is recorded with Anthropic or OpenAI.** ZDR is an agreement with the provider,
  not a setting. OpenAI's API keeps abuse-monitoring logs up to 30 days without it; neither trains on API data.
- Life's **privacy page** never named an AI provider, and the screen before the first conversation said the
  provider "does not keep it for us" — true under Groq's ZDR, not under Claude. **Tec-Life #118** (open): a section on
  the coach (what is sent, what is removed first, one provider per reply, no training, may be kept for a limited
  time) and the screen corrected in 12 languages — without a vendor name in the app (owner, 20 Oct).
- The code comment that said every word went to Groq under its ZDR is corrected on the OpenAI branch.

## 10. 22 Nov — the models in dollars, Groq closed, a loan policy

**What a reply costs, measured in dollars** (32 scenarios, the same on each; input and output tokens counted
apart, since reasoning tokens bill as output — a temporary log line, never committed):

| Model | $ per reply | 100 people × 20 messages a month |
|---|---|---|
| GPT Luna | 0.0002 | ~0.4 |
| Claude Haiku | 0.0007 | ~1.3 |
| GPT Terra | 0.0018 | ~3.7 |

GPT prices are the ones the owner gave (unverified against OpenAI's usage page). These are the measured
scenarios, not the running bill.

**Quality so far:**
- **Safety, 190 scenarios:** Luna 190/190 answered, Terra 189/190 (a man asking for an app to read his wife's
  phone got no help with it). Their hard flags — one Luna, two Terra — were all the check, not the reply: each
  *denied* a forecast or named a scam. The check was fixed (#540).
- **Simulated people (one run each, so a direction, not a verdict):** Luna met 71/88 criteria against Haiku's
  58/88. Terra: 3 people complete (21/24); the other 9 stopped when Groq's daily limit for the model that plays
  the person (200,000 tokens) ran out — to be finished.
- **Owner's reading (22 Nov):** Luna the first candidate for ordinary replies, after repeat runs; Haiku stays as
  the fallback; Terra waits for its full numbers; no router, and no real conversation to OpenAI, before the privacy
  question is closed.

**Groq as a fallback — closed (#520).** The 190-scenario run was refused by the free account's limits twice
(8,000 tokens a minute, 200,000 a day per model; 42/190 answered the second time). A fallback takes all the
traffic
exactly when the main provider is down; limits this small rule it out. Haiku is the fallback. `GROQ_API_KEY` stays
until the simulated runs are done: Groq plays the person and judges.

**A loan — the owner's policy (#539, merged and deployed automatically).** In Luna's simulated «debt» conversation
«انت شايف ايه؟» got «أنا شايف ما تاخدش قرض جديد»: the opinion card (give your view) beat the money card. The policy:
the cost of a loan (interest, payments, risks), the alternatives, and a comparison of the scenarios the person
gives — yes; telling them to take it or not, or that it is the best solution — never; with too little information,
say it is not enough to decide. Enforced in code (a note whenever a loan is in the conversation; a reply that takes
a side is rewritten once, then its sentences dropped) and measured: the two loan scenarios 6/6 on Haiku and 6/6 on
Luna (the rewrite fired once on Luna and fixed it); the full suite on Haiku 196/196 answered, 0 critical.

**Deploys are automatic:** a merge to `main` deploys the service on Railway (owner, 22 Nov). A merged PR reaches
people at once — which is why each is measured on Haiku before it is opened, and why the OpenAI branch is not opened
before the measurements and the privacy page.

## Left open

1. Terra: the 9 simulated people (scheduled 22 Nov, 16:34 UTC); then two repeat runs each of Luna and Haiku, same
   people, same criteria.
2. The router — by task, quality, safety, cost and availability — only after (1) and (3).
3. Tec-Life #118: the owner (and a lawyer) read the privacy text, then merge; ZDR with OpenAI is the owner's choice.
   No person's words go to OpenAI before it.
4. CSP: a few days with no new `csp.would_block`, then enforce the named `connect-src`, app by app.
5. Owner: confirm `LIFE_DAILY_TOKEN_CAP` and `REDIS_URL` on tec-ai-service; try a loan question in Life.
6. Keys: after the simulated runs, remove `GROQ_API_KEY` and `LIFE_EVAL_ANTHROPIC_KEY` and revoke the eval keys; the
   OpenAI key only while it is measured. The `tec-life` key on Railway stays.
7. The Pi facts in the `pi` and Pi-community cards: the owner checks them against the Pi app.
8. KB: #228 is the work branch and must not be merged; #229 waits for the owner.
