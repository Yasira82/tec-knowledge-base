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

## Left open

1. **Owner, in Pi Browser once Life is deployed:** sign in from the Hub, sign in in Life itself, one payment. Then
   read Life's Vercel logs: `auth.sso_callback_unusable` only for a link opened twice; `csp.would_block` — none
   means the named `connect-src` can be enforced in Life.
2. Owner: deploy tec-ai-service (#528–#532) and tec-life-service (#533 — its migration only adds a column).
3. Owner: confirm `LIFE_DELETION_LEDGER=on` on tec-life-service, and `LIFE_DAILY_TOKEN_CAP` + `REDIS_URL` on
   tec-ai-service.
4. **tec-core-backend #535** (open): a bug of #533 found the same day — an error answer (a 529 during an outage, a
   429) carries no token count, and the estimate it took stayed counted (one 529 left 4535 tokens); after an
   outage Life could say "busy" before the real ceiling. An error now gives it all back. Deploy with #533.
5. tec-core-backend #520 (Groq as a fallback): brought up to date with `main` (the fallback reserves and settles
   like any request). Its measurement on Groq stopped on 21 Nov — Groq's daily quota was spent (429); it runs when
   the quota resets.
6. Owner: remove `LIFE_EVAL_ANTHROPIC_KEY` and `GROQ_API_KEY` from the session's environment and revoke the eval key
   once the measurements are over. The `tec-life` key on Railway stays.
7. The Pi facts in the `pi` and Pi-community cards: the owner checks them against the Pi app as it is today.
