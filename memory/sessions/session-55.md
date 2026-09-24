# SESSION 55 — the Commerce tile pointed off the platform, and the comment said it was verified

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

Full engineering record: `audits/PI_TESTNET_HOST_OWNERSHIP_2026-09-12.md`.

Session 54 left 21 apps unmerged. They merged, and **every app then worked from the
Testnet Hub except Commerce**, which returned a blank `500` — while opening fine when
typed directly.

### The cause was one line in the Hub

```
TESTNET_ORIGINS in the Hub grid — Testnet hosts only, never the Portal domain:
  commerce: 'https://commerce-app.vercel.app'       WRONG — a different Vercel account
  commerce: 'https://tec-commerce-app.vercel.app'   the Testnet host the project serves
```

> Commerce's **Portal / Mainnet** domain is unchanged and remains
> `commerce.tecosystem.app`. The host above is the Testnet pairing only.

The Commerce project's **Domains** page names the second. The first is somebody else's
deployment — alive enough to serve a favicon, and `500` for every function. The Testnet
grid had been handing every visitor to it. (tec-app **#231**)

**The security half is worse than the routing half.** That host was also in
`ALLOWED_APP_ORIGINS`. `/api/auth/sso` signs a token carrying the user's **access token**
and redirects to the target — so that line was standing permission to hand a foreign
origin a live session. Removed.

> An allowlist entry is not a hint about where an app might live.

### Three wrong diagnoses first, and why the third one matters

Broken deployment → expired token + an unbounded refresh hop → `crypto.randomUUID()` as a
Node-version global. The third explained **every** observation at once and was still
wrong, because a theory that explains everything about the wrong subject explains nothing
about the right one.

What ended it was a **negative** result: the Commerce project's Vercel logs showed
`Error 0 · Warning 0 · Fatal 0`, error rate `0%`. A healthy project cannot be the source
of a 500 someone is looking at. Then the Domains page named the host in one line.

### The lesson worth keeping — a comment that had already been believed

The wrong value was **documented as verified**. The file header cited it as proof that
hosts cannot be guessed: *"NOT invented, and not derived from a name … `commerce-app` has
no `tec-` prefix at all"*. The example offered as evidence **against** guessing was a
guess, and because it read as already-checked it survived every round intact — it is what
a reader consults **instead of** the source.

The fix is not a better guess but a **named source**: the only authority for a value in
that file is now the Vercel project's **Domains** page — explicitly not the app's
`ALLOWED_AUDIENCES` (the old rule, and an allowlist never answers "is this host ours?"),
not the project name, and not the comment.

**Third occurrence of this shape** — Zone (`tec-zone.vercel.app` → a stranger's pink
shop), Elite (caught pre-release), Commerce. Now guarded by a `NOT_OURS` list asserted
absent from both the Testnet maps and the SSO allowlist.

### Two fail-open defects found on the way — same shape, unrelated cause

Both were **a component answering "fine" while doing nothing**:

- **Reconciliation resolved nothing, on schedule.** `404 payment_not_found` was treated
  as "Pi unreachable" and retried hourly forever — 10 stale rows, 10 reads, 10 x 404,
  `reconciledCount: 0` — while the comment above it said a 404 cancels the payment. It is
  now final, with its reason in the audit log (Invariant #4), under three required facts
  so a 404 from *our* bug still retries. Sound **only** because `targetOf` carries the
  network: a Testnet payment read with the Mainnet key answers the same thing.
  (tec-core-backend **#295**)
- **A gateway routing NOTHING reported `status: "ok"`.** A stray Railway service ran a
  second gateway with no service URLs → zero routes, healthy `/health`. *"All 0
  microservice routes mapped"* reads like a status line. And **the isolation that
  protects the real gateway (NEW-W) is what hid this one** — liveness is deliberately
  decoupled from the pipeline, so a gateway serving nothing is indistinguishable from the
  working one by the only signal anyone checks. `/health` still returns 200 but now
  carries `routes` + `unroutedServices` and reports `degraded`; `/ready` says **no** at
  zero routes. (tec-core-backend **#296**)

### The login handoff could hang

`sso -> /api/auth/refresh -> gateway -> auth-service`, and **not one hop had a timeout**.
An unbounded fetch waits until the platform kills the invocation — and a killed function
never reaches its `catch`, so the route changed last session to *say why it failed* could
not say anything. Bounded now, degrading to the un-refreshed token rather than failing.
(tec-app **#230**)

> **Naming an error is worthless if the handler is the thing being killed.**

### Recorded honestly: the `crypto` fix was NOT the cause

Commerce's `sso-callback` used the bare `crypto` global (Node 19+) while its `pi-login`
imported it. Real latent defect, fixed on every **route handler** — `middleware.ts`
deliberately keeps the global, because Edge has Web Crypto and no `node:crypto`. But it
did **not** produce the 500, and this entry says so rather than letting a merged fix
imply a resolved cause (C-95). (Tec-Commerce **#65**)

### Also this session

Two stray Railway services deleted — `pacific-adaptation` (built the repo root, which is
unbuildable; failed from day one, never served a request) and `Tec-core-backend` (the
zero-route gateway above). Neither is a folder in the repo and neither needs to be: a
Railway service is `(repo) + (root directory) + (env vars) + a label`.

The **`-test.tecosystem.app` pairing was cancelled by the owner** — the fleet stays on
the `*.vercel.app` pairing, with the public-suffix consequences as recorded in Session 54.

### TEC AI — the assistant's picture of the user travelled through the browser

Asked what was left with no payment path, the answer was **TEC AI** — and C-104 §7
already settles that: FREE/PRO/API, monetized through the **Hub PRO subscription**,
not a payment of its own. Nothing missing there. What IS missing is the gate itself
(`requiresPro: false`; `/ai` treats FREE and PRO identically).

Scoping that gate found a defect underneath it that has nothing to do with money.

**`/api/bff/ai/context`** resolves the caller's real state from the gateway — Life
goals, focus, Analytics activity, KYC — server-side from the session identity, exactly
as C-106 sovereignty requires. It then returned that object to the **browser**, and the
browser posted it back to `/api/ai/chat`:

```
const userContext = body.userContext;   // taken whole, unvalidated
const systemPrompt = buildSystemPrompt(userContext);
```

Every platform **claim** about the user made a round trip through the one place that
cannot be trusted. Editing one fetch body was enough to tell the assistant you were
KYC-verified, or to hand it goals you do not have.

**Nothing executes on these** — the AI guides, it never acts (C-104 §4) — so no money
moves. It answers the user from premises the platform never asserted, **in the
platform's voice**. That is the damage, and it is enough: the whole value of the
assistant is that its picture of you is real.

**Fixed** (tec-app **#232**) with a token the server signs — three properties, each
load-bearing:

| Property | Without it |
|---|---|
| **Signed** (HS256 / `JWT_SECRET`) | the browser rewrites any field |
| **Subject-bound** (`sub` checked against the independently verified session) | a lifted token is a portable identity claim |
| **Short-lived** (15 min) | a user pins a stale KYC or an old goal list |

A **token rather than a second fetch**: `/api/ai/chat` runs on the **Edge** runtime
while context assembly is a Node BFF fanning out to three gateway endpoints —
re-resolving there would put that fan-out on *every message*. Same primitive the SSO
handoff already uses.

> **The boundary is CLAIMS vs PREFERENCES, not server vs client.** Reply language and
> length stay in the body: they are the user's own choice from the assistant's settings
> menu, assert nothing about them, and signing them would mean a round trip every time
> someone toggles "short answers". Stated that way, the next field added lands on the
> correct side on its own.

No fallback to the body when verification fails — failing closed costs a less personal
answer; falling open puts unchecked statements in the prompt (P6).

**Two things the fix surfaced:**
- **Two call sites, not one** — the Hub drawer hook and the `/ai` page each had their
  own copy of the body. Fixing only the drawer would have left the page open, and the
  page was worse: it also sent a `username` read from client state.
- **That username was never real anywhere.** The drawer's test mocked a BFF field the
  BFF never returned, so the greeting was personalized *in the test* and generic in
  production. It is now a signed claim from the `tec_user` cookie — so the feature both
  works and is trustworthy. *A test can be the only place a feature exists.*

**Deliberately NOT done — the FREE/PRO gate (C-104 §7).** It is a product decision (what
the FREE limits are), and it is a trade: the personal-context injection IS the
"advanced planning" the table sells, so gating it makes the FREE assistant noticeably
worse. #232 is what makes the gate *possible* — with claims verified server-side, a
`plan` field in the signed context is enforceable; without it any gate is bypassable by
editing one fetch body (C-110 §5 P0-1: gating is server-side, never client-trusted).

### A2U — the Mainnet App Wallet gate, and it is ONE app not twenty-four

The Pi Portal gates the Mainnet App Wallet on: *"The paired Testnet app needs App to
User transactions to 5 unique wallets."* Full record: `audits/PI_TESTNET_HOST_OWNERSHIP_2026-09-12.md` §11.

**A2U could not make those payouts.** `sendA2uPayment` took `source?: string`, which
`targetOf` widens to `{ source, testnet: false }` — so every payout resolved the
Mainnet key, Horizon, passphrase and wallet, whatever it was for. Same shape as
`APP_URL` / `sandbox` / `HUB_URL` / reconciliation's `targetOf` before it, except
**here it decides which chain gets signed**. Fixed: all four now come from ONE flag on
the payout (tec-core-backend **#297**, merged).

**The wallet rule, stated in the file:** `PI_A2U_WALLET_SEED_TESTNET` has **no
fallback** to the Mainnet seed. A missing *key* makes Pi reject a request; a missing
*seed* that fell back would load the wallet holding real Pi and sign with it. The
passphrase mismatch would reject it — so no money moves — but that would be an
accident of the chain, not a property of the code.

> The wallet that can spend real Pi is never reached by a payout that did not ask for it.

**Scope — answered from the code, not assumed.** The fear was that all 24 apps would
need this. They do not:

1. it is the **OUTGOING** wallet — the Mainnet TEC-APP reads `Connected Outgoing
   Wallet: None` while all 24 apps take real Pi today. **Receiving needs no wallet.**
2. A2U has **exactly one caller** in the whole backend — the campaign
   (`memo: 'TEC Pi Reward Campaign'`), sending no `source`, so it is the Hub's app.
3. every other reward is deliberately not Pi — the referral reward carries the comment
   *"A referral reward is a GIFT SUBSCRIPTION month — never raw Pi"*; the Founding-100
   gift is six months of PRO.

This agrees with platform law rather than convenience: **C-47 Invariant #8** and
**C-132** make `payment-service` the only Pi custodian, so 24 app wallets would be a
violation of the design, not an achievement inside it. **One round, for the Hub.**

**Honest caveat:** Pi's A2U *is* per-app (a `uid` is app-scoped), so an app that ever
pays its own users needs its own wallet and its own five-payout round. Only FundX,
Insure and Brookfield could reach that, and all three are hard-gated on **legal
review** — not on a wallet. If those gates open, C-132 routes distribution through
payment-service anyway.

**State:** #297 merged · `PI_API_KEY_HUB_TESTNET` + `PI_A2U_WALLET_SEED_TESTNET` set on
`tec-payment-service`. **Remaining, and it is not an engineering task:** five *distinct*
Pi accounts must authenticate with the paired **Testnet** app — a `uid` for an app
exists only once that account has signed into that app, so it needs four other people.

### Open after this session

`order.paid.v1` is still emitted fire-and-forget with no retry (`Stream isn't writeable`,
seen 05:16 — one Redis blip loses it permanently) · `commerce-app.vercel.app` is still in
Commerce's own `ALLOWED_AUDIENCES` (inert, but a foreign origin listed as acceptable) ·
the repo-root `package.json` in `tec-core-backend` is unused by every CI step and
unbuildable, and is what made Railway believe the root was deployable.
