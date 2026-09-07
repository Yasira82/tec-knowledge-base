# Pi Testnet gate — what actually broke, and the recipe for the fleet

**Date:** 2026-09-06 · **Scope:** `tec-payment-service` · every app frontend · Pi Developer Portal
**Companion to:** `audits/PI_PORTAL_TESTNET_GATING_2026-09-06.md` (the plan). **This is the outcome.**

**Truth State:** [Current State] · **Verification:** [Runtime Verified] (fleet-wide — step 10 complete) · **Governance:** [Draft]

> Read this before touching another app's testnet path. Four separate defects sat between
> "the plan is right" and "a Test-Pi payment completes" (§2), and a fifth surfaced only
> once those were fixed (§8). Not one was visible in the plan, in a code review, or in any
> log until the exact moment it was hit. Connection paid for the first four; the other apps
> should not have to.
>
> **Outcome: step 10 is complete across the fleet** — every app that took these six changes.
> The five that did not are listed in §9, with the reason.

---

## 1 · What is proven

| | Mainnet | Testnet |
|---|---|---|
| **Mode 2** — pay inside the app | ✅ working (verified after the change) | ✅ **working** |
| **Mode 1** — pay via the Hub modal | ✅ working | ❌ hangs — **by design**, see §4 |

**Checklist step 10 needs Mode 2 only.** Mode 1 on testnet is not a blocker for any domain.

---

## 2 · The four defects, in the order they surfaced

Each one hid the next. That is the important part: fixing one did not reveal progress, it
revealed the following wall. Anyone repeating this on another app will meet them in the same
order unless the fixes ship together.

### D1 — the login returned to the OTHER host

```ts
const APP_URL = process.env.NEXT_PUBLIC_APP_URL ?? 'https://<app>.tecosystem.app';
ssoRedirect(HUB_URL, `${APP_URL}${target()}`);
```

A visitor signing in on `tec-<app>.vercel.app` handed the Hub the **Mainnet** origin as their
return address. The Hub authenticated correctly and returned them to the other host, where the
session then lived. The Testnet host stayed `Unauthorized` — **with nothing in any log**,
because nothing failed.

**Fix:** `window.location.origin`. The Hub validates the target against its own
`ALLOWED_TARGETS`, so nothing is weakened.

> `FollowCta` in the same repo had used `location.origin` all along. **Two call sites in one
> app disagreed and the wrong one was the login.**

### D2 — the session cookie carried a Domain the host was not under

```ts
domain: process.env.COOKIE_DOMAIN ?? process.env.NEXT_PUBLIC_SSO_DOMAIN ?? undefined
```

A cookie's `Domain` must be the request host **or a parent of it**. `.tecosystem.app` is not a
parent of `tec-<app>.vercel.app`, so the browser **rejected every `Set-Cookie`** — silently.
`vercel.app` is on the Public Suffix List, so no wildcard cookie could be set there anyway.

**Fix:** `cookieDomainFor(host, configured)` — the configured domain only where it genuinely
covers the host, host-only otherwise. **On the Mainnet host this is a no-op.**

> Host-only is not a downgrade. The alternative is not a broader cookie — it is **no cookie**.

#### ⚠️ The second half of this fix was WRONG, and was reverted

The same change added `Partitioned` to the `document.cookie` fallback, reasoning that
C-123 LAW 3 requires it and the server response already sets it — so the fallback should
match. **That broke Mainnet.**

Assets went intermittent the moment it shipped (NFT upload and mint hanging, ~2 successes
in 12) and steady again the moment it was reverted. Same line, isolated, twice.

What the "consistency fix" actually removed was the **UNPARTITIONED duplicate** the
fallback had always written *beside* the server's partitioned one. In any context where
the partitioned copy is not sent — and Pi Browser is a custom WebView — that duplicate was
the only cookie left.

**The server half stays**: `partitioned: true` on the response is the half LAW 3 governs,
and nothing about the Testnet host depended on the fallback attribute — that host is
carried by the server cookie, which is why step 10 passed *with* it and passes *without*.

Reverted across all 21 repos that took it, each with a test pinning the **absence** and the
reason, so the same "obvious consistency fix" is not reapplied by someone who has not read
this.

**The lesson is not about cookies.** A redundant-looking duplicate can be load-bearing —
the same shape as the backend deploy defect recorded in C-02 §5, where a broken name lookup
was the access control for an unguarded production deploy. *Removing a redundancy without
asking what it was silently doing is how a tidy-up becomes an incident.*

### D3 — `sandbox: true` silenced the Pi bridge

The plan said "`*.vercel.app` → Testnet", and that was read as "so set `sandbox: true` there".
It is not the same switch. The result:

```
Pi auth failed: Messaging promise with id 1 timed out after 120000ms.
```

The SDK's **first** message to Pi Browser was never answered. Same host, same build, that one
flag `false` → the wallet opened.

**Three different axes, and they had been collapsed into one:**

| | decides |
|---|---|
| **the HOST** | which Pi **app** the visitor is in |
| **the app's API KEY** | which **network** Pi processes the payment on |
| **`sandbox`** | that the SDK talks to Pi's **Sandbox environment** — a third thing |

A paired Testnet app in Pi Browser is a **normal app on its own domain**. It is not the sandbox.

**Fix:** default `sandbox: false` everywhere; `?pi_sandbox=1` on the Testnet host only.

### D4 — approve was posted to a blockchain node

With the Testnet key finally wired (`apiKeyLength: 64`), the call went out and returned:

```
url: https://api.testnet.minepi.com/v2/payments/…   status: 404
body: { "type": "https://stellar.org/horizon-errors/not_found", ... }
```

A **Horizon** error. The Platform API answers in its own shape
(`{"error":"payment_not_found","error_message":…}`) — visible in the same service's Mainnet
logs. `api.testnet.minepi.com` is Horizon for Pi Testnet, and approve was being posted to a node
that has never heard of a payment id.

**The repo already knew this.** `pi-tx.ts` and `pi-a2u.ts` both resolve
`api.(mainnet|testnet).minepi.com` as `PI_HORIZON_URL` and both keep the Platform base at
`api.minepi.com`. A third file contradicted two that were already right.

**Fix:** the Platform host does not vary by network. The **key** does.

---

## 3 · The recipe for one app

Six changes. They must ship together — each one only exposes the next.

| # | File | Change |
|---|---|---|
| 1 | `src/lib/pi-network.ts` *(new)* | `isTestnetHost` (anchored to the end of the host) + `networkMetadata` — present **only** when true |
| 2 | `src/app/api/bff/payment/create/route.ts` | drop the client's `testnet` **before** the spread; add `...networkMetadata(req.headers.get('host'))` |
| 3 | `src/lib/cookie-domain.ts` *(new)* + `sso-callback` | `cookieDomainFor(req.nextUrl.hostname, …)` **only**. Do NOT add `partitioned` to the `document.cookie` fallback — see D2: it broke Mainnet and was reverted fleet-wide |
| 4 | `src/app/layout.tsx` | `sandbox` from the host, **default false**, `?pi_sandbox=1` override confined to the Testnet host |
| 5 | `src/app/page.tsx` (login) | SSO return address → `window.location.origin` |
| 6 | `src/lib/pi-payment.ts` | Hub `return_url` → `location.origin`; `onError` must not read `.message` off a non-Error |

Backend, once for the fleet:

| | |
|---|---|
| `getPiApiKey` | `PI_API_KEY_<SLUG>_TESTNET`, **no fallback** to the Mainnet key — a fallback turns a missing env var into a 502 that names nothing |
| `getPiBaseUrlFor` | network-**independent**; a test refuses any `api.(testnet\|mainnet).minepi.com` from it |
| `SubscriptionConsumer` | refuses to activate a paid plan from a payment marked `testnet` — Test-Pi clears any amount floor, so the floor cannot catch it |

Ops, per app: **`PI_API_KEY_<SLUG>_TESTNET`** on `tec-payment-service`, then redeploy.
**That is the pacing item** — 24 keys created by hand in the Portal.

---

## 4 · Mode 1 on testnet is a boundary, not a bug

```ts
const HUB_URL = process.env.NEXT_PUBLIC_HUB_URL ?? 'https://hub.tecosystem.app';
```

Mode 1 hands the payment to the **Hub** — a *different Pi app*, on a *Mainnet host*, approved
with the Hub's Mainnet key. A Test-Pi wallet cannot pay it, so it hangs.

Making it work needs the Hub to take changes 1–5 **and** `redirectToHubPayment` to send a
Testnet visitor to the Hub's Testnet host. That is **the same build-time-constant bug a third
time** (`APP_URL`, `sandbox`, now `HUB_URL`).

**Deliberately not done.** It is not on the Portal checklist and blocks no domain.

---

## 5 · What the instrumentation was worth

The Pro card gained a stage line — `⚙ approving · sandbox=false` — shown only on the Testnet
host or with `?debug=1`, plus a seconds counter.

Honestly: **it did not find D3.** The app's own existing error text did (`Pi auth failed:
Messaging promise…`). What it changed is that the answer now arrives **by default rather than
by luck** — "Confirm in Pi…" covered both `Pi.authenticate` and `Pi.createPayment`, and neither
tells any server anything until the SDK calls back. Without a clock, a stall and a slow network
look identical.

---

## 6 · Rules that generalise beyond Pi

1. **One build cannot hold a per-host fact.** `NEXT_PUBLIC_*` is baked once; two hosts served by
   one deployment need the value read at request time. This bit three separate constants.
2. **A silently rejected cookie leaves no trace anywhere.** When "logged in but unauthorized"
   has no error on either side, suspect the cookie attributes before the auth logic.
3. **Read the files that already solved it.** D4 was contradicting two correct files in the same
   service.
4. **A fallback that hides which input was missing is worse than a hard failure** — the reason
   the Mainnet key is not used when the Testnet one is absent.
5. **Fix them together or you learn one per round trip.** Each defect masked the next, and each
   round trip is a human with a phone.

---

## 7 · Answered — this section is now the record, not the open list

Every question this section opened has been closed **by the fleet finishing step 10**,
not by argument.

| | |
|---|---|
| Is `api.minepi.com` correct for a **Testnet app's** Platform calls? | ✅ **[Runtime Verified].** A testnet approve returns 200 against `api.minepi.com` under the app's **Testnet key**. The host does not carry the network; the key does. This was the one claim the doc rested on and could not prove. |
| Does `sandbox: false` on the Testnet host hold generally? | ✅ **Held across the fleet**, not only in the single A/B it was decided on. |
| The remaining apps | ✅ **Checklist-complete**, except the five in §9. |
| Mainnet regression | ✅ **None.** Reasoned from the code paths, then confirmed by live Mainnet payments after the change. `testnet` is *absent* from a Mainnet payment rather than `false`, and every consumer tests `=== true`. |

---

## 8 · D5 — the host an app is served from is not the one its name implies

Found **after** the six changes shipped, and only because of them.

Vercel appends a random suffix when a project name is already taken. Two of the
first apps checked were affected, with **unpredictable** suffixes:

```
Zone      → tec-zone-mu.vercel.app       (not tec-zone.vercel.app)
Elite     → tec-elite-bvzb.vercel.app    (not tec-elite.vercel.app)
Commerce  → commerce-app.vercel.app      (no `tec-` prefix AT ALL)
```

Commerce is the one that settles the argument. Zone and Elite at least *look* like
the pattern with something appended; Commerce does not begin with `tec-`. There is
no rule to infer — **a host is read off the deployment or it is not known.**

The Hub's `ALLOWED_TARGETS` had been written **from the naming pattern rather than
from the deployments**, so those apps answered `{"error":"invalid_target"}`.

**It did not appear today — it stopped being silent today.** Before D1 was fixed, the
login sent the build-time constant `<app>.tecosystem.app`, which *is* allowlisted: the
check passed and the visitor was quietly returned to the **Mainnet** host while the
Testnet one never got a session. The fix converted a silent wrong-host login into a
loud refusal.

**The allowlist must never become a pattern.** Anyone can deploy
`tec-<app>-<anything>.vercel.app` on their own Vercel account, and `/api/auth/sso`
hands the target a signed token carrying the user's access token. A wildcard there is
an account-takeover primitive. **Explicit hosts, read off the deployments.**

What made the rest cheap: the rejection now **names the origin it refused** and says
what to do. A screenshot of the error became the fix — the same lesson as this repo's
`E404`-on-publish note: *an error that sends the next person the wrong way costs more
than the bug it reports.* The allowlist itself is deliberately not echoed.

Both hosts stay listed per app. An allowlist entry that resolves to nothing is inert,
and the unsuffixed name may become the project's alias later.

---

## 10 · The variant D1 hid: a bounce with no return address at all

Commerce and Ecommerce did not have D1 in the form the other apps had it. Their
landing page's "no session" branch was not a *wrong* return address — it was **no
return address**:

```
window.location.href = 'https://tec-app-frontend.vercel.app';   // Commerce, /
ssoRedirect(HUB_URL, `${APP_URL}/`)                              // Ecommerce, /
```

The first hands the Hub nothing to sign a token back to. The user signs in, lands on
the Hub, and the app they tapped is never reached again — a one-way trip.

**Why it never showed on Mainnet.** The shared `.tecosystem.app` cookie means a
visitor almost always arrives already carrying a token, so that branch is almost
never taken. On a `*.vercel.app` host cookies are host-only, so a visitor **never**
arrives with one and **every** visit took it. The bug had been there the whole time;
the Testnet host is simply the only place it is reachable.

> **A branch that is nearly unreachable in production is not a tested branch.**
> Both of these had shipped for months.

Ecommerce carried the worse shape of it: `APP_URL` was a module constant **redeclared
in eight files**, serving both the login bounce *and* the `return_url` of a Mode-1
payment. So the same constant that stranded a login also landed a buyer on the wrong
host after the π had moved.

And the drift is not hypothetical. In Commerce, `/app` was fixed in the first pass and
the landing page was not — the two copies of one rule diverged inside a single repo,
in a single session. Both apps now read the origin from **one** file
(`lib/sso.ts` · `lib-client/app-origin.ts`) and every call site imports it.

---

## 11 · The network flag is a claim, and a claim needs an owner

`metadata.testnet` is not decoration. Two live systems branch on it:

| Reader | Behaviour when `testnet === true` |
|---|---|
| `payment-service` `getPiApiKey` | selects `PI_API_KEY_<SLUG>_TESTNET` — i.e. which network the π settles on |
| `commerce` `SubscriptionConsumer` | **refuses** to activate PRO |

So whoever sets that field decides whether a payment is free. It must be derived from
the **request host**, server-side, and a client-sent value must be **removed** — not
merely overwritten.

> **Overwriting is not removing, and on Mainnet it is nothing at all.** The
> host-derived value is *absent* on a Mainnet host (present only when true, by
> design — a `testnet: false` on 100% of real payments is a field about the test
> network sitting on real money, wrong the first day someone writes it backwards).
> `{ ...clientMetadata, ...networkMetadata(host) }` therefore overwrites **nothing**
> there, and the caller's claim survives intact. Strip it *before* the spread, so a
> later edit that reorders the object cannot hand the network back.

Fleet audit at the close of this session — every app's payment-create route read, not
inferred:

| Group | Marker derived from Host | Client claim stripped |
|---|---|---|
| 22 domain apps + template (incl. NBF · Brookfield · Ecommerce) | ✅ | ✅ |
| **Assets · Commerce** | ✅ | n/a — their schema accepts **no** client metadata, so there is nothing to strip |
| **Hub (`tec-app`)** | ❌ **absent** | ❌ **absent**, and its schema is `.passthrough()` |

---

## 12 · The Hub is the last app with none of this — and one consumer below it is worse

Recorded here rather than fixed, because it is a separate change on a financial path.

**In `tec-app`.** `grep -ri testnet src/` returns **zero**. Three consequences:

1. Its BFF create sets no marker, so a payment made on the Hub's own Testnet host is
   approved with the **Mainnet** key — a real payment made from a Testnet host, not a
   Testnet payment.
2. Its `metadata` is `.passthrough()` with no strip, so a caller *can* set the flag —
   and the Hub is the Mode-1 path for **all 24 apps**.
3. Its sandbox default is **inverted** relative to the entire fleet:
   `NEXT_PUBLIC_PI_SANDBOX !== 'false'` defaults to **true**, where every other app
   reads `=== 'true'`. Unset or misspelled, the Hub comes up in sandbox — D3 by
   default rather than by mistake.

**Below it, the one that moves money.** `tec-wallet-service` consumes
`payment.completed` and credits a real balance —
`balance: { increment: amount }` plus a ledger row and an audit row — with **no
`testnet` check**. All eight consumers of that event were read: exactly one
(`subscription.consumer.ts:135`) has the guard.

> So the guard the platform *thinks* it has is one consumer wide. A Test-Pi payment
> is refused a PRO subscription and credited to a real wallet in the same breath.

The `.v1` outbox payload does carry `metadata` (`payment.controller.ts:519`), so the
guard is implementable. The open question is the **legacy** direct-publish path, which
carries none: refusing there fails closed against real Mainnet credits, and allowing
there leaves the hole open. That is a decision, not a patch — which is why it is
written down here instead of being guessed at.

---

## 9 · Closed — all 24 apps carry the port

The five that were open at the time of writing are done.

| App | How |
|---|---|
| **Assets · Commerce · Ecommerce** | Hand-written. Older than the template: different `layout.tsx`, different BFF create route, different login call sites. The anchored script had stopped at them rather than guessing — which was the right outcome, because each needed a genuinely different edit (see §10). |
| **NBF · Brookfield** | Attached to the session, then ported from the reference app. Structurally identical to the template, so the six-file recipe applied unchanged. |

**Their guard suites were rewritten, not the code bent to fit them.** The copied
tests asserted the template's inline layout script; Ecommerce has no such script
(`Pi.init` lives in `PiSdkLoader`) and Commerce's create route accepts no client
metadata. In each case the assertion was rewritten against the shape the app really
has. *A test copied along with a fix is a claim about a file that may not exist.*

Each app still needs its own `PI_API_KEY_<SLUG>_TESTNET` on `tec-payment-service`
before step 10 — there is **no fallback** to the Mainnet key by design, so a missing
Testnet key fails loudly rather than quietly charging real π.

Remaining, and tracked in §12 rather than here: the **Hub itself**, and the
**wallet-service credit guard** below it.

---

## Related

`audits/PI_PORTAL_TESTNET_GATING_2026-09-06.md` (the plan) ·
`C-12_Dual_Mode_Payment.md` §11 (per-app Pi key · approve→502) ·
`C-123___PI_BROWSER_SESSION_COOKIE_SPEC.md` (LAW 3 — `none+secure+Partitioned`) ·
`C-76___ADR-007.md` (dual-mode payment)
