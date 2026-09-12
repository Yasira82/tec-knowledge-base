# The Commerce tile pointed off the platform — and the comment said it was verified

**Date:** 2026-09-12
**Truth State:** [Current State]
**Governance State:** [Draft]
**Verification:** [Runtime Verified] — every finding below was read from production logs,
a Vercel Domains page, or a Railway dashboard. Nothing here is inferred from code alone.

**Scope:** one session. Six merged PRs across four repos. One root cause, three wrong
diagnoses before it, and two unrelated fail-open defects found on the way.

---

## 1 · The headline

Entering **Commerce** from the Testnet Hub returned a blank `500 Internal Server Error`.
Every other app worked. The app itself worked when opened directly.

The cause was one line in the Hub:

```ts
// tec-app/src/domains/testnet-hosts.ts
commerce:   'https://commerce-app.vercel.app',      // WRONG — someone else's account
commerce:   'https://tec-commerce-app.vercel.app',  // the project's actual host
```

The Commerce Vercel project's **Domains** page reads `commerce.tecosystem.app` and
`tec-commerce-app.vercel.app`. The prefix-less spelling belongs to a **different Vercel
account**. The Testnet grid had been handing every visitor to a stranger's deployment,
which was alive enough to serve a favicon and answered **500** for every function.

Fixed in tec-app **#231**.

### The security half, which is worse than the routing half

`commerce-app.vercel.app` was **also** in `ALLOWED_APP_ORIGINS` — the Hub's SSO
allowlist. `/api/auth/sso` signs a token carrying the user's **access token** and
redirects to the target. That line was standing permission to hand a foreign origin a
live session.

> An allowlist entry is not a hint about where an app might live. Every line in it is
> permission to hand over a session.

---

## 2 · Why it took three wrong diagnoses

Each theory fitted the evidence available at the time, and each was about the wrong host.

| # | Theory | Why it looked right | Why it was wrong |
|---|--------|---------------------|------------------|
| 1 | Commerce's Vercel deployment is broken | `/api/health` returned 500, and that route catches everything and *cannot* 500 from its own code | it was a different project's `/api/health` |
| 2 | The access token had expired, so the Hub's unbounded refresh hop hung | explained the timing exactly: 21 apps tapped with a fresh token worked, Commerce came last | merging the timeout fix changed nothing for Commerce |
| 3 | `crypto.randomUUID()` as a bare global — a Node-version dependency | explained **every** observation at once: works standalone (`pi-login` imports it), fails from the Hub (`sso-callback` did not), other apps fine (newer projects) | it was diagnosing a route on a host that was never ours |

**Theory 3 is the instructive one.** It was internally consistent, matched a real
asymmetry inside the repo, and was *still* wrong — because a theory that explains
everything about the wrong subject explains nothing about the right one.

### What actually settled it

The Vercel logs for the Commerce project showed **no 500s at all**: `Error 0 · Warning 0
· Fatal 0`, error rate `0%`. A healthy project cannot be the source of a 500 someone is
looking at. That single negative result ended the hunt — after three positive-sounding
theories had not.

Then the Domains page named the host in one line.

> **Three plausible theories are worth less than one piece of evidence.** This is the
> second time this session's record has had to write that sentence down.

---

## 3 · The part that generalises: a comment that had already been believed

The value was not merely wrong. It was **documented as verified**. The file's own header
cited it as proof that hosts cannot be guessed:

> *"NOT invented, and not derived from a name … `commerce-app` has no `tec-` prefix at
> all"*

The example offered as evidence **against** guessing was a guess. And because it read
like someone had already done the checking, it survived every round of this intact —
it is what a reader consults **instead of** the source.

**The fix is not a better guess. It is a named source.** The header now says the only
authority for a value in that file is the **Vercel project's Domains page** — explicitly
not the app's `ALLOWED_AUDIENCES`, not the project name, and not the comment itself.

That matters because the original rule *was* "read it from the app's own
`ALLOWED_AUDIENCES`". An allowlist answers *"may this host sign in?"*, never *"is this
host ours?"*, and it happily lists names we wanted and do not own.

### Third occurrence of one shape

| App | Wrong host | What it served |
|---|---|---|
| Zone | `tec-zone.vercel.app` | a stranger's pink shop, then 404 |
| Elite | `tec-elite.vercel.app` | (caught before release; real host is `tec-elite-bvzb`) |
| **Commerce** | `commerce-app.vercel.app` | a favicon, and 500 for every function |

Now guarded: a `NOT_OURS` list — hosts disproved by reading a Domains page — is asserted
absent from both Testnet maps **and** the SSO allowlist, and every Testnet target must
be allowlisted so an entry cannot drift into an `invalid_target` 400 the grid gives no
hint about.

---

## 4 · Two fail-open defects found on the way

Neither caused the Commerce failure. Both are the same shape: **a component answering
"fine" while doing nothing.**

### 4a · The reconciliation cron resolved nothing, on schedule

Production, 12:00:04:

```
Stale payments found: 10
Pi API get payment failed  status: 404  "payment_not_found"   x10
Reconcile: Pi read failed — skipping (will retry)             x10
Reconciliation complete   reconciledCount: 0  skipped: 10
```

The catch treated *"Pi says there is no such payment"* and *"Pi is unreachable"* as one
event. Those rows were re-read hourly, forever — the orphan-payment path C-47 requires
ran on time and resolved nothing — while the comment directly above it read *"a 404 here
CANCELS the payment"*.

A `payment_not_found` is now **final**: the row is cancelled with its reason in the audit
log (Invariant #4). Narrow by construction — three facts required, each a different way
to be wrong without the others: a `PiApiError`, `PI_FETCH_ERROR` + HTTP **404**, and Pi's
own `payment_not_found` in the body. A 404 from a moved endpoint is *our* bug and must
keep retrying.

**Recorded in the code as a safety dependency:** this is sound *only* because `targetOf`
carries the **network** as well as the source. Reading a Testnet payment with the Mainnet
key also answers `payment_not_found` — indistinguishable from here — and would cancel a
payment the user really made. (tec-core-backend **#295**)

### 4b · A gateway routing NOTHING reported itself healthy

A second Railway service, built from the repo **root**, ran a copy of the gateway with
no service URLs:

```
[env] Gateway environment failed validation ... STILL RUNNING
  - AUTH_SERVICE_URL: Required
  - WALLET_SERVICE_URL: Required
  - PAYMENT_SERVICE_URL: Required
[ProxyService] All 0 microservice routes mapped
```

…and `/health` answered `status: "ok"`.

Every line is true and not one is an alarm. *"All 0 microservice routes mapped"* reads
like a status line. `buildServiceRegistry` skips any service whose env var is unset —
correct, since a fallback URL is the NEW-A violation that file exists to avoid — but it
skipped **silently**.

**And the isolation that protects the real gateway is what hid this one.** NEW-W
registers `/health` before every middleware so a load blip can never cause a false
"Backend Offline" (C-96). That same isolation means a gateway with zero routes reports
perfectly healthy while 404-ing the platform — the broken copy and the working one are
indistinguishable by the only signal anyone checks. That is fail-**open** (P6): up and
useless.

- the registry now **names** what it skipped (warn for some, error for none);
- `/health` still answers **200** — NEW-W untouched — but the body carries `routes`,
  lists `unroutedServices`, and reports `degraded` unless auth + payment + wallet are
  routable;
- `/ready` is allowed to say **no**, gated strictly on **zero** routes so it can never
  affect the real gateway. (tec-core-backend **#296**)

---

## 5 · The login handoff could hang

`/api/auth/sso` is the only way into every app in the fleet, and it makes an outbound
call of its own. The chain is three hops deep and **not one had a timeout**:

```
sso  ->  /api/auth/refresh  ->  gateway  ->  auth-service
```

An unbounded `fetch` does not fail, it **waits**, and the invocation waits with it until
the platform kills it. A killed function never reaches its `catch` — so the route that
had just been changed to *say why it failed* could not say anything at all.

Bounded now (6s inner, 8s outer, inner shorter so this route decides what the user sees).
The SSO hop **degrades** — it carries on with the un-refreshed token exactly as it already
did when the refresh returned `!ok`, because a stale token produces a login screen a user
can act on and a hung handoff produces a blank page nobody can read. The refresh hop
answers **502 `gateway_unreachable`** with the reason. (tec-app **#230**)

> **Naming an error is worthless if the handler is the thing being killed.** The bound
> has to exist before the message can ever be written. (C-96)

This was merged before the real Commerce cause was found, and it did **not** fix
Commerce. It is kept because the defect is real: the gateway's own logs show
`socket hang up` / `ECONNRESET` against services it proxies.

---

## 6 · Commerce's `crypto` global — merged, correct, and NOT the cause

Recorded plainly so the causal claim does not drift (C-95).

Commerce's two login paths disagreed:

```
/api/auth/pi-login       import { randomUUID } from 'crypto'    works everywhere
/api/auth/sso-callback   crypto.randomUUID()   (bare global)    needs Node >= 19
```

`globalThis.crypto` only exists from Node 19. CI never sees it — CI runs a current Node —
so the exposure lives only on the deployed runtime.

Fixed on every **route handler** (Node runtime). **`middleware.ts` deliberately keeps the
global**: middleware runs on the **Edge** runtime, where `crypto` is the standard Web
Crypto global and `node:crypto` is not available — applying the same fix there breaks
*every* request instead of one. Two runtimes, opposite rules; the test pins **both**
halves. (Tec-Commerce **#65**)

> It is a real latent defect and worth keeping. It was **not** what made Commerce return
> 500, and this record says so rather than letting a merged fix imply a resolved cause.

---

## 7 · Two stray Railway services, deleted

| Service | What it was | Risk |
|---|---|---|
| `pacific-adaptation` | Railway's random name generator; no root directory, so it built the repo **root** — which has no `src/`, no `nest-cli.json`, no Prisma schema, and a leftover `package.json` that can never build | noise only — the build failed from day one, so it never served a request |
| `Tec-core-backend` | Railway's default name when a GitHub repo is connected; root directory set to `tec-api-gateway` → a **second gateway**, with no env vars → zero routes, `/health: ok` | the §4b case, live |

Neither is a folder in the repo, and neither needs to be: a Railway service is
`(repo) + (root directory) + (env vars) + a label`. The label is chosen in Railway.

---

## 8 · What is still open

| Item | State |
|---|---|
| `order.paid.v1` emitted fire-and-forget, no retry — one Redis blip loses it permanently (`Stream isn't writeable and enableOfflineQueue options is false`, seen 05:16) | recorded, not fixed |
| `commerce-app.vercel.app` still listed in Commerce's own `ALLOWED_AUDIENCES` | inert without `SSO_SECRET`, but a foreign origin as an acceptable audience |
| The repo-root `package.json` in `tec-core-backend` | unused by every CI step (all run under `working-directory: ${{ matrix.service }}` or `shared/`) and unbuildable; it is what made Railway believe the root was deployable |
| `-test.tecosystem.app` pairing | **cancelled by the owner.** The fleet stays on the `*.vercel.app` pairing, with the public-suffix consequences recorded in `PI_TESTNET_PAYMENT_LATENCY_2026-09-11.md` |

---

## 9 · Merged this session

| PR | Repo | What |
|---|---|---|
| **#295** | tec-core-backend | `payment_not_found` is final — reconciliation stops retrying an answer |
| **#296** | tec-core-backend | a gateway with zero routes no longer reports healthy |
| **#230** | tec-app | every hop in the login handoff is bounded |
| **#231** | tec-app | **the Commerce host — the actual cause** + a foreign origin removed from the SSO allowlist |
| **#65** | Tec-Commerce | `crypto` imported rather than assumed (Node-version exposure) |

---

---

## 10 · TEC AI — claims about the user travelled through the browser

Separate thread, same day, and a different class of defect: not a wrong value, a
**wrong trust boundary**.

### How it came up

The question was which domain still has no payment path. Answer: **TEC AI** — and
C-104 §7 already settles that as intended (FREE / PRO / API, monetized through the
**Hub PRO subscription**, no payment of its own). What is genuinely missing is the
*gate*: `requiresPro: false`, and `/ai` treats FREE and PRO identically.

Scoping that gate is what surfaced the defect. It has nothing to do with money.

### The defect

`/api/bff/ai/context` resolves the caller's real state from the gateway — Life goals,
stated focus, Analytics activity, KYC — **server-side, from the session identity**,
exactly as C-106 sovereignty requires.

It then returned that object to the **browser**, and the browser posted it back to
`/api/ai/chat`:

```ts
const userContext = body.userContext;          // whole, unvalidated
const systemPrompt = buildSystemPrompt(userContext);
```

Every platform **claim** about the user made a round trip through the one place that
cannot be trusted. Editing one fetch body was enough to assert KYC verification, or to
hand the assistant goals the user does not have.

**Nothing executes on these.** The AI guides and never acts (C-104 §4 — decision
SUPPORT, not decision maker), so no money moves and no state changes. What it does is
answer the user from premises the platform never asserted, **in the platform's voice**.
That is the damage, and it is sufficient: the entire value of the assistant is that its
picture of the user is real.

### The fix (tec-app #232)

Claims come only from a token the server signs. Three properties, each load-bearing:

| Property | What it prevents |
|---|---|
| **Signed** — HS256 over `JWT_SECRET` | the browser rewriting a field |
| **Subject-bound** — `sub` checked against the independently verified session | a lifted token becoming a portable identity claim |
| **Short-lived** — 15 minutes | pinning a stale KYC status or an old goal list |

**A token rather than a second fetch.** `/api/ai/chat` runs on the **Edge** runtime
while context assembly is a Node BFF fanning out to three gateway endpoints; having the
route re-resolve would put that fan-out on *every message*. The same primitive the SSO
handoff already uses — `jose`, Edge-safe via Web Crypto.

**Audience matters more than it looks.** The session cookie is signed with this same
`JWT_SECRET`. Without an `aud` check, an access token would verify here and its payload
be read as context.

### The rule worth keeping

> **The boundary is CLAIMS vs PREFERENCES — not server vs client.**

Reply language and length stay in the request body: they are the user's own choice from
the assistant's settings menu, they assert nothing *about* the user, and signing them
would mean a round trip every time someone toggles "short answers". Preferences are
narrowed against a closed set so the body cannot introduce a field the prompt renders.

Drawing the line as "server vs client" would have signed the preferences too — more
ceremony, no more safety, and a worse experience. Drawing it as "claims vs preferences"
means **the next field added lands on the correct side without anyone having to decide
again.**

There is deliberately **no fallback to the body** when verification fails: failing
closed costs a less personal answer, falling open puts unchecked statements into the
prompt (P6).

### Two findings from the fix itself

- **Two call sites, not one.** The Hub drawer hook and the `/ai` page each carried their
  own copy of the request body. A fix applied to the drawer alone would have left the
  page wide open — and the page was the worse of the two, because it also sent a
  `username` read from client state.
- **That username was never real anywhere.** The drawer's test mocked a BFF field the
  BFF never returned, so the greeting was personalized *in the test* and generic in
  production. It is now a signed claim sourced from the `tec_user` session cookie.

> **A test can be the only place a feature exists.** This one asserted a behaviour the
> product never had, and it passed for as long as nobody looked — the mirror image of
> §3, where a comment asserted a fact the platform never had.

### Not done, and why

The **FREE/PRO gate** (C-104 §7) is deliberately out of scope. It is a product decision
— what the FREE limits are — and a real trade: the personal-context injection **is** the
"advanced planning" the table sells, so gating it makes the FREE assistant noticeably
worse.

#232 is what makes the gate *possible*. With claims verified server-side, a `plan` field
inside the signed context is enforceable. Without it, any gate is bypassable by editing
one fetch body — which **C-110 §5 P0-1** forbids: subscription gating is checked
server-side in BFF routes, never on the client.

---

## 11 · A2U — the Mainnet App Wallet gate, and how many apps it actually applies to

The Pi Developer Portal gates the **Mainnet App Wallet** on one sentence, shown on
the Mainnet app's own "Apply for Mainnet App Wallet" form:

> *"The paired Testnet app needs App to User transactions to 5 unique wallets."*

### 11a · A2U could not make those payouts (tec-core-backend #297)

`sendA2uPayment` took `source?: string`. `targetOf` widens a bare string to
`{ source, testnet: false }` — so **every** payout resolved the Mainnet key, Mainnet
Horizon, the Mainnet passphrase and the Mainnet wallet, whatever it was for. The
Testnet half of the question had no way to be asked.

Same shape as `APP_URL`, `sandbox`, `HUB_URL`, the Hub's app-grid routes and
reconciliation's `targetOf` before it — a value fixed at build or process scope
answering a question only the individual payment can answer. **Here it decides which
chain gets signed.**

Four decisions now come from ONE flag on the payout, resolved once:

| Decision | Source |
|---|---|
| Pi API key | the `{source, testnet}` pair → `getPiApiKey`, which already refuses to fall back from Testnet to the Mainnet key |
| Horizon node | per-network (`PI_HORIZON_URL_TESTNET` beside the existing override) |
| Network passphrase | per-payout — it is part of what gets **signed** |
| Payout wallet | `PI_A2U_WALLET_SEED_TESTNET`, **no fallback** |

**The wallet rule is the sharpest, and it is stated in the file.** A missing *key*
makes Pi reject a request. A missing *seed*, if it fell back, would load the wallet
that holds real Pi and sign with it. The passphrase mismatch would get that rejected
— so no money moves — but the guarantee would be an accident of the chain rather than
a property of the code.

> The wallet that can spend real Pi is never reached by a payout that did not ask
> for it.

Also folded in: the Pi **Platform host** is the one thing that does *not* vary with
the network, and this file carried its own copy of that derivation — the same rule in
two places (P1). It now uses the shared `getPiBaseUrlFor`, where the reasoning lives.

`testnet` is strictly `=== true` at the controller boundary, as on the U2A path. A
bare source string, and no target at all, still mean Mainnet: every existing caller is
unchanged by construction.

### 11b · The scope question, answered from the code

The reasonable fear was: *"every one of the 24 apps will need this."*

**No — one app does.** Three pieces of evidence, none of them an assurance:

1. **The wallet is the OUTGOING wallet.** The Mainnet TEC-APP shows
   `Connected Outgoing Wallet: None` and `Completed Steps: 10 of 10` — and all 24 apps
   are taking real Pi on Mainnet today. **Receiving Pi needs no app wallet at all.**
2. **A2U has exactly one caller.** Across the whole backend,
   `POST /api/payment/internal/a2u` is invoked from one place —
   `tec-identity-service/.../campaign.service.ts`, `memo: 'TEC Pi Reward Campaign'` —
   and it sends **no `source`**, so it resolves to the Hub's Pi app.
3. **Every other reward is deliberately not Pi.** The referral reward carries its own
   comment: *"A referral reward is a GIFT SUBSCRIPTION month — never raw Pi"*. The
   Founding-100 gift is six months of PRO, for the same reason. The other 23 apps sell
   Pro — the money flows **in**.

This also agrees with platform law rather than merely with convenience: **C-47
Invariant #8** and **C-132** make `tec-payment-service` the only Pi custodian. Two
dozen app wallets would be a violation of the design, not an achievement inside it.

**So: one round of five payouts, for the Hub. Not twenty-four.**

### 11c · The honest caveat

Pi's A2U **is** per-app: a `uid` is app-scoped, and a payout is created under that
app's key from that app's wallet. So **if** a specific app ever needs to pay its own
users, it needs its own wallet and its own five-payout round.

Only three apps could ever reach that, and all three are hard-gated today:

| App | Outgoing flow | Blocked on |
|---|---|---|
| FundX | pool distributions | legal review · payment-service custody · SYSTEM (C-113) |
| Insure | escrow release | the same three (C-129) |
| Brookfield | investment returns | the same three (C-131) |

Their blocker is a **legal review**, not a wallet. And if those gates ever open, C-132
routes the distribution through `payment-service` — not through three new wallets.

### 11d · Where the Testnet seed comes from, and the rule about it

From the Pi Developer Portal, on the **paired Testnet app** (the form is on the
Mainnet app; the wallet it asks about is the Testnet one). `payoutKeypair` accepts
either form the Portal hands out:

- a **24-word passphrase** — derived at Pi's own path `m/44'/314159'/0'` (the digits
  of π, which is how you can tell it is the right path);
- a **secret key** — `S…`, exactly 56 characters.

Anything else is refused with a sentence naming what was expected, because
`Keypair.fromSecret` throwing *"invalid encoded string"* at somebody who pasted
exactly what the Portal gave them tells them nothing about what to do next.

> **A wallet seed is never pasted into a chat, a log, a screenshot or a commit.** It
> goes straight into the service's environment. If it appears anywhere else, treat it
> as burned and make a new wallet.

And the setup error is built to be the diagnosis: a seed that resolves to a wallet
that does not exist prints the **public key it resolved to**, so it can be compared
against the wallet that was actually funded — a seed cannot be read back, a public key
can.

### 11e · State, and the part no code removes

**Done:** #297 merged. `PI_API_KEY_HUB_TESTNET` and `PI_A2U_WALLET_SEED_TESTNET` set
on `tec-payment-service`.

**Remaining, and it is not an engineering task:** five *distinct* Pi accounts must have
authenticated with the paired **Testnet** app. A2U pays by `uid`, and a `uid` for an
app exists only once that account has signed into **that** app — so it needs four other
people to open the Testnet app. No amount of code removes that, and this record says so
rather than leaving it to be rediscovered.

## Related Documents

- `C-47_Kernel_Spec_Architecture_Binding.md` — P6 fail closed; Invariant #4 audit trail;
  Invariant #7 terminal states; the orphan-payment reconciliation path
- `C-96___PLATFORM_RUNTIME_CONSTITUTION.md` — no silent failure; a failure with no
  alternative path must name itself
- `C-92___PLATFORM_HEALTH_MODEL.md` — what a health signal is allowed to claim
- `C-95___INSTITUTIONAL_KNOWLEDGE_CONSTITUTION.md` — a document that lags reality gets
  built on; §3 above is an instance of exactly that
- `C-76___ADR-007.md` · `C-12_Dual_Mode_Payment.md` — the Hub/app payment boundary
- `C-104___TEC_AI_INSTITUTIONAL_CHARTER.md` — §4 the AI guides and never acts; §7 the
  FREE/PRO/API revenue model, monetized through the Hub subscription (§10 above)
- `C-106___LIFE_INSTITUTIONAL_CHARTER.md` — own-data sovereignty: the context the AI
  reads is the caller's own, derived from the session, never from a param or body
- `C-110___SYSTEM_INSTITUTIONAL_CHARTER.md` — §5 P0-1: subscription gating is checked
  server-side in BFF routes, never client-trusted
- `C-71___FINANCIAL_INTEGRITY_SPEC.md` · `C-132___SERVICE_EXTRACTION_MODULAR_ARCHITECTURE_POLICY.md`
  — Invariant #8 and the Financial Hard-Gate: `tec-payment-service` is the only Pi
  custodian, which is why §11b's answer is one wallet and not twenty-four
- `C-113___FUNDX_INSTITUTIONAL_CHARTER.md` · `C-129___INSURE_RISK_PROTECTION_RUNTIME.md`
  · `C-131___BROOKFIELD_INFRASTRUCTURE_RUNTIME.md` — the three apps with an outgoing
  flow, all hard-gated on legal review (§11c)
- `audits/PI_TESTNET_PAYMENT_LATENCY_2026-09-11.md` — the session this one continues
