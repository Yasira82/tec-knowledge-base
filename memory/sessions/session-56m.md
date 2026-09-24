# Session 56m — the whole backend was on the open internet, and nine services had no door

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

Started as log noise on `identity-service`: a 500 reading `Body cannot be empty when
content-type is set to 'application/json'`. It fired at **06:37:29** on 14 September and
**06:37:29** on 17 September — the same second, three days apart. That is scheduled, and
nothing inside the service schedules anything.

Following the caller instead of the message is what opened the rest of this.

### What was actually true

| Question | Answer | How it was settled |
|---|---|---|
| Are the services reachable from the internet? | **Yes, all of them** | `identity-service-production-fe57.up.railway.app/health` answered JSON in a phone browser |
| Does the gateway call them publicly or privately? | **Publicly** (`up.railway.app`) | Read from the gateway's own Railway variable |
| Did nine services enforce `x-internal-key` globally? | **No** | Three had it; five checked per route; **three had nothing at all** |

So every internal call between the gateway and a service was leaving the platform and
coming back over the open internet, and on nine of eleven services the only thing
standing in front of a business route was whether that particular route remembered to
check. ADR-005 says *"Services must NOT be exposed directly to the internet."*

The 500 was a scanner walking the public domain. It was never the problem — it was the
symptom that happened to be visible.

### Why the exposure existed — and a WRONG answer, corrected the same session

The first explanation given here was confident and wrong, and the way it was wrong is
worth more than the finding it was attached to.

**What was claimed:** Railway's private network routes over IPv6 only; six services bound
`'0.0.0.0'` (IPv4 alone) and so were unreachable at their `*.railway.internal` address;
therefore the public URLs were the only ones that *could* have been configured; therefore
moving the URLs private before fixing the binds would take six services off the air.

**What the Railway console actually shows.** The private domain on `tec-auth-service` is
badged **`IPv4 & IPv6`**. Railway private networking resolves both. The six were reachable
privately all along.

So the real answer is the boring one: **nobody ever changed the variables.** No constraint,
no trap — just a default that outlived the reason for it.

**Where the wrong answer came from, which is the lesson.** `tec-identity-service`'s
`main.ts` carries this, and it is genuine:

> `'::' accepts BOTH IPv6 and IPv4 (public edge), so the public URL keeps working too.`

Somebody really did hit IPv6-only private networking and really did fix it that way. The
note was true when it was written. It was then read as a statement about **how Railway
works** rather than **how Railway worked on the day someone fought it**, and a months-old
in-repo comment was promoted to current platform behaviour without opening the console
that would have settled it in one screen.

> **Same family as the Wait-for-CI path in Session 56l.** There, a path written from
> memory read exactly like a path somebody had verified. Here, a comment describing the
> platform *as it was* read exactly like a comment describing the platform *as it is*.
> **A repo note is evidence about the past, not about the present** — and the console,
> the dashboard, the actual screen, is one tap away in both cases.

### The order still stands — for a weaker, honest reason

```
1. global x-internal-key guard        ← closes the door NOW, no risk
2. bind '::' on the six               ← correct and harmless; NOT a prerequisite
3. move *_SERVICE_URL to private      ← service by service
4. remove the public domains          ← last, only after 3 is proven
```

Step 2 shipped and stays: `'::'` covers IPv4 and IPv6, so it is right under either
behaviour and costs nothing. What it is **not** is the gate the first write-up made it —
step 3 would not have broken anything without it.

Steps 3 and 4 remain ordered for their own reasons: a variable change rolls back in
seconds, and removing a public domain does not — Railway issues a **new, differently
named** domain if you regenerate it.

### Shipped (tec-core-backend #320) — steps 1 and 2

| Service | Before | After |
|---|---|---|
| auth · payment · wallet | global guard already | unchanged |
| identity · commerce · analytics · asset · storage | per-route only | **global guard** |
| kyc · notification · realtime | **nothing** | **global guard** |
| commerce · kyc · asset · analytics · notification · storage | bound `0.0.0.0` | **bound `'::'`** |

Exempt everywhere, each for a stated reason rather than by habit: `/health` + `/ready`
(Railway's healthcheck has no header to give), `/metrics` (the C-78 Prometheus pull),
and `OPTIONS` (preflight carries no custom headers by definition).

Two exemptions were found by reading rather than by pattern, and either would have been
a silent outage:

- **`/health/streams` on identity** — the consumer-liveness sensor (C-96 / NEW-W). The
  gateway reads it with a bare `fetch` that sends **no headers at all**. Guarding it
  would not have failed loudly; it would have left the platform's nervous-system sensor
  permanently `'unavailable'` — the exact silent sensor death that sensor exists to
  detect.
- **`/socket.io/` on realtime** — the browser connects to it **directly**, because the
  gateway's proxy has no `ws: true` and `onProxyReq` (which injects the key) fires for
  HTTP only. A socket client has no key to present and no way to be given one. The same
  guard pasted in would have disconnected every live client on the platform.

> **The generalisable bit:** a fleet-wide rule applied uniformly is not the same as a
> fleet-wide rule applied correctly. Nine services took the same guard; two needed a
> carve-out that only reading them revealed, and in both cases the failure mode was
> silence, not an error.

Registered as a Fastify `onRequest` hook (Express middleware on realtime), so refusal
happens **before the body parser** — which is also what retires the daily 500: the
scanner's bodiless JSON POST is now answered 403 before Fastify is ever asked to parse
it. (`FST_ERR_CTP_EMPTY_JSON_BODY` is a 400, but it is not an `HttpException`, so Nest's
default filter was turning it into a 500.)

Neither guard imports its framework's types. Identity carries **two copies of fastify**
(`4.29.1` top-level, `4.28.1` under `@nestjs/platform-fastify`) which TypeScript treats
as unrelated nominal types; realtime has no `@types/express`. Both declare only the
surface they use — one hook, a path, a method, headers, and a way to answer 403.

**Verified per service, built and run, not taken on CI's word:** identity 1215/1215 ·
commerce 137/137 · analytics 117/117 · asset 48/48 · storage 34/34 · realtime 29/29 ·
notification 29/29 · kyc 27/27. `kyc` and `notification` had no `node_modules` in the
work environment and were installed to run them. No schema change.

### A correction recorded, because the method matters more than the finding

The first audit of this reported `payment-service` as unguarded. It was wrong: the guard
is in `app.ts`, not `main.ts`, and the grep only read `main.ts`. The table above is the
audited result, not the first guess. **A one-file grep is an answer about one file.**

### Still open — ops, and the decision is the CEO's

Steps **3** and **4** are Railway variable changes, service by service, and they are what
actually closes ADR-005. #320 makes deferring them materially safer; it does not replace
them. Nothing in the repo can do it — the variables live in Railway.


### Post-merge verification — and a deadline the deploy logs handed over

**The deploy scope was right, and that is a check, not a coincidence.** #320 + #321
touched exactly eight service directories — identity · commerce · analytics · asset ·
storage · kyc · notification · realtime — and exactly those eight redeployed. The four
that did not (**auth · payment · wallet · api-gateway**) still show the deployment from
`#316`, a day older, because not one byte in the change belonged to them: auth, payment
and wallet already carried the guard, and the gateway is the service that *sends* the
header rather than one that checks it.

That is Railway's per-service **Watch Paths** (`/tec-<service>/**`) doing its job. Worth
recording because the same screen, read without the file list beside it, looks exactly
like four services that failed to deploy. **"It didn't deploy" and "it had nothing to
deploy" are the same picture** — the diff is what tells them apart.

`storage-service` came up clean on the new bind (`📦 Storage Service running on port
5007` · `PrismaService Connected to database`), which is step 2 verified in production
rather than in a test.

> Its actual port is **5007**, while the code's fallback reads `PORT ?? 5010`. Railway
> sets `PORT` per service and the fallback is never reached, so a private URL built from
> the source would point at the wrong port. **Read the port off the Railway screen; the
> constant in `main.ts` is not it.**

### NEW — Node 20 vs the AWS SDK, January 2027 (open, dated, not urgent)

`storage-service`'s own boot log:

```
NodeVersionSupportWarning: The AWS SDK for JavaScript (v3) versions published
after the first week of January 2027 will require node >=22.
You are running node v20.0.2.
```

The whole backend is on **Node 20**, pinned in three places at once: the Dockerfiles, the
`node-version: '20'` in every workflow, and whatever Railway resolves at build time. So
this is a **fleet migration**, not a service upgrade — and the deadline is external and
fixed, which is the rare kind this platform cannot negotiate with.

Nothing breaks in January. What stops is *new* AWS SDK releases being installable — which
means the next security patch on the R2/S3 client is the first thing that cannot be
taken. That is the date that matters, not the one in the warning.

Not scheduled here. Recorded with its source (a real production log, not a changelog
someone remembered) so the next session finds it before a Dependabot PR fails for a
reason nobody connects to a Node version.


### ADR-005 steps 1 + 2 — `[Runtime Verified]`

Two real Pi payments went through after the guard deployed, on the two apps least
like the rest of the fleet, and neither was refused.

| App | What was paid | What SHOULD happen | What happened |
|-----|---------------|--------------------|---------------|
| **System** | `system_supporter`, 1π | Payment completes and **grants nothing** — C-110: SYSTEM sells no governance authority; the contribution exists for the Portal's "Process a Transaction" step | ✅ paid, no Pro |
| **Assets** | an NFT mint / marketplace buy | The **item appears** — Assets has no subscription at all | ✅ item appeared, no error |

The System result is the one worth spelling out: **"no Pro appeared" is the PASS**, and
Pro appearing would have been the failure — a leak in the activation pattern. A check
whose success looks like nothing happening is easy to read backwards.

This is what the test suites could not say. They proved the guard refuses what it should;
only production could prove **nothing legitimate was missing the header**. Steps 1 and 2
move from `[Code Verified]` to `[Runtime Verified]`.

Steps 3 (variables → private) and 4 (remove the public domains) are unchanged and remain
ops decisions.

### NEW — Assets has no repair path for a paid purchase (open)

Found while reading Assets to answer "did the payment work". All three of its buy flows
have the same shape:

```
pay with Pi  →  a SEPARATE follow-up fetch from the browser  →  the thing is recorded
```

| Button | Follow-up call |
|--------|----------------|
| Mint Domain as NFT | `POST /api/bff/assets/mint-as-nft` |
| Mint NFT (upload) | `POST /api/bff/nft/register` |
| Buy listing | `POST /api/bff/marketplace/buy` |

If that second call never lands — signal drops, the app is closed, anything returns an
error — **the π is gone and nothing was recorded**, and no consumer repairs it.
`tec-asset-service` consumes `payment.completed.v1` **nowhere**; the services that do are
commerce, identity, analytics, wallet and payment.

**This is Session 26's gap in a different app.** There, ~19 apps took real Pi and
activated no subscription because commerce had no consumer. The fix was an event
consumer, and it works. Assets never got the equivalent because its purchases are
one-off rather than subscriptions — which changes who pays for the failure, not whether
it can happen.

**How much of it is actually repairable, stated honestly rather than optimistically:**

- **Domain mint** (`asset_id`) and **marketplace buy** (`listing_id`) — the payment
  metadata already carries the identifier, so a consumer could complete these from the
  event alone.
- **NFT upload** — it **cannot**. The follow-up sends `name`, `description`, `imageUrl`,
  `key` and `mimeType`, and none of that is in the payment metadata; at the moment of
  payment it exists only in the browser. Repairing this one means persisting the draft
  BEFORE the payment, not adding a consumer after it.

So the fix is two-thirds a known pattern and one-third a design change. Not scheduled.
Recorded because the failure is **silent and financial**: nobody reports a purchase that
never appeared as loudly as they report one that failed.


### ADR-005 step 3 — all 11 services moved to the private network

The gateway's `*_SERVICE_URL` values now point at `*.railway.internal` instead of the
public `*.up.railway.app` hosts. Internal traffic stops leaving the platform.

```
auth          http://triumphant-spirit.railway.internal:5001
wallet        http://wallet-service.railway.internal:5002
payment       http://payment-service.railway.internal:5003
assets        http://tec-core-backend-a5f9.railway.internal:5004
identity      http://identity-service.railway.internal:5005
notification  http://notification-service.railway.internal:5006
storage       http://tec-core-backend-4aa8.railway.internal:5007
kyc           http://kyc-service.railway.internal:5008
commerce      http://commerce-service.railway.internal:5009
realtime      http://realtime-service.railway.internal:5010
analytics     http://analytics-service.railway.internal:5011
```

The same six that `tec-identity-service` calls directly (auth · commerce · payment ·
asset · kyc · notification) were updated in its variables too.

### The check that made this tractable — and it was free

**The gateway prints its entire routing table at boot.** Eleven
`[HPM] Mapped /api/<service> → <url>` lines, every deploy, already there:

```
[HPM] Mapped /api/kyc → https://kyc-service.railway.internal:5008
```

One screenshot of that log audits the whole migration at once — no guessing which
variable took, no checking eleven panes. When the eleven were changed in one sitting
rather than one at a time, this log is what turned "something is broken somewhere" into
a defect found in seconds.

**Record the log you already have before inventing a verification step.** The instinct
was to verify service by service through the UI; the answer was printed at boot the whole
time.

### The defect: one character

Ten entries read `http://`. One read **`https://`** — kyc.

The private network terminates no TLS, so every KYC call would have failed. And it would
have failed **only on the KYC screen** — login, payments, wallet, notifications all fine,
nothing in a health check, nothing anywhere until a user tried to verify. A typo with a
blast radius of one feature and a discovery time of "whenever somebody happens to look".

> Third time this session a single character was the whole fault: the trailing space in
> three Railway service names (August), the `var` inside an object literal that killed
> `Pi.init` in two apps, and now an `s`. **The platform's most common defect shape is one
> character in a string nobody re-reads** — which is exactly the class a printed routing
> table catches and a code review does not, because none of it is in the repo.

### A false alarm, recorded because the reasoning was wrong

Two entries use odd names — `tec-core-backend-a5f9` (assets) and `tec-core-backend-4aa8`
(storage) — where the rest are `<service>.railway.internal`. From that, the guess was
that one private domain had been pasted for several services with only the port changed,
which would have made ten of the eleven wrong.

It was **not** that. `a5f9` and `4aa8` are two different domains belonging to two
different services; Railway simply named them from the repo at a time when it named
things differently (`triumphant-spirit` on auth is a third generation of the same). The
inconsistency was cosmetic and the mapping was right.

**A pattern that looks wrong is a question, not a finding.** The log had the answer —
different suffixes, different services — and the guess was made before reading it
carefully.

### Verification status, stated per claim rather than as one word

| Claim | Status |
|---|---|
| Login over the private network | ✅ `[AuthService] Pi login: yas55eR82` — twice, after the switch |
| Payment + notification | ✅ `Created: PAYMENT for user …` → `Payment notification sent`, twice |
| Gateway routes all 11 privately | ✅ read from its own boot log |
| **KYC path** | ⚠️ corrected, **not yet exercised** — open `/hub/kyc` once |
| **identity-service's own 6** | ⚠️ applied, **not yet exercised**. Not risky while the public domains still exist: if one were wrong, identity would simply… still work, because the old hosts answer. That safety net disappears at step 4 |

### What is left

Step **4** — removing the public domains — and it is now the one that matters, because
until it happens the services remain reachable from the internet and step 3 has only
changed which door the gateway knocks on.

**Two domains stay, permanently:** `tec-api-gateway` (the Vercel apps call it) and
`tec-realtime-service` (the browser opens its WebSocket directly — the gateway proxies no
upgrades). Removing either is an outage, not a hardening.

And **before payment-service's domain is removed**, the Pi Developer Portal's webhook URL
must be confirmed to point at the gateway rather than at payment-service directly. The
gateway carries an explicit public exemption for `^/api/payments/webhook`, which is strong
evidence it does — but the Portal is the authority and has not been read.


### The guard found a service that was effectively unauthenticated

Step 3 finished with two screens broken: KYC (`502`) and Notifications (`500`). KYC was
the `https://` typo above. **Notifications was something else entirely, and it is the most
important thing this whole piece of work produced.**

`tec-notification-service`'s **`INTERNAL_SECRET` did not match the gateway's.**

It had presumably not matched for a long time. Nobody could know, because until the
guard shipped **that service never checked the key**:

```
gateway sends x-internal-key  →  notification ignores it, answers normally
anyone else sends anything    →  notification answers normally
```

The secret meant to authenticate the service was a **dead value** — present in its
variables, read by no line of code — while the service sat on a public Railway domain.
**It was open, and the thing documented as protecting it was decorative.**

> **The guard did not cause an outage. It ended one.**
>
> The `500` that cost four rounds of diagnosis was the first time this platform was
> *capable* of reporting that two secrets disagreed. Before it, there was no code path
> by which that fact could ever have reached anybody.

#320's PR body argued the per-route pattern "holds right up until one route forgets."
The real state was worse: **every** route had forgotten, on a service that checked
nothing at all.

**Where the fleet stands on this specific question:**

| Service | Before the guard | Secret verified against the gateway? |
|---|---|---|
| kyc | no check anywhere | ✅ matched — worked first try |
| **notification** | no check anywhere | ❌ **drifted — fixed 18 Sep** |
| realtime | no check anywhere | ⬜ **untested** — see below |
| the other 8 | per-route or global | ✅ implied: a drifted secret would already have been failing on the routes that did check |

**`realtime` is the one still unknown.** If its secret has drifted too, `/presence/*`
(who is online, who is typing) is failing right now — and failing **invisibly**, because
nobody reports "a contact didn't show as online" the way they report a red error box.
Worth one deliberate check.

### Why it took four rounds, and the fix so it doesn't next time

The Hub showed `500`. The gateway had relayed a `403`. Ten BFF routes did this:

```ts
if (!res.ok) throw new Error(`Gateway ${res.status}`);   // status discarded here
```

A plain `Error` carries no `status`, so `createHandler`'s final branch answered
`500 "Something went wrong"` — **the same code a gateway that cannot reach the service
at all produces.** Two unrelated causes, one number on screen, and the one fact that
separates them in seconds was thrown away one line before it was needed.

The mechanism to do it right already existed (a 4xx with `status` attached passes
through — added earlier for pioneer refusals). The call sites just never used it.
Fixed in **tec-app #239**: 13 throws across 10 routes now attach the status, so a
refusal reports **403** and an unreachable upstream still reports **500**.

> **A diagnostic that collapses two causes into one number is not a diagnostic.**
> This one was one line from being right, in code that already had the machinery.

### And a change that was written, tested, and deliberately backed out

Relaying a 5xx's *status* too (keeping the message generic) looked obviously better —
502 "cannot reach" vs 500 "something else" — and six tests went red.

One of them, `createHandler.errors.test.ts`, pins `expect(res.status).toBe(500)` for an
upstream 502, beside a comment saying a 5xx body may name hosts, drivers and stack
frames. The generic *message* satisfied that comment's stated reason; the *assertion*
said something narrower, and it was written on purpose.

**It was reverted.** The distinction that actually mattered — refused vs unreachable —
is won by the 4xx path alone.

> Rewriting another test's expectation to make new code pass is how a deliberate
> decision gets deleted by somebody who only read half of it. **Six red tests were the
> signal, not the obstacle** — the same rule as the August deploy fix, arriving from the
> other direction: there, a defect was load-bearing; here, an assertion was.


### ADR-005 step 4 — nine public domains removed. The violation is closed.

```
Before:  11 services reachable from the internet; every gateway→service call left
         the platform and came back over the open network.
After:    2 services reachable, both deliberately.
```

| Still public | Why it must be |
|---|---|
| `tec-api-gateway` | Every client enters here. The Vercel apps call it by name. |
| `tec-realtime-service` | **The browser opens its WebSocket DIRECTLY.** The gateway is configured without `ws: true`, so upgrades are never proxied and `onProxyReq` — which injects the internal key — fires for HTTP only. A socket client can neither reach it through the gateway nor be handed a key. Removing this domain is an outage, not a hardening. |

The other nine now return Railway's 404 and show **"Unexposed service"**.

### The canary earned its place

`storage` went first, alone, and was verified three ways before anything else moved:
the service stayed **Active without a redeploy**; Public Networking emptied while
**Private Networking was untouched** (`IPv4 & IPv6`, "Ready to talk privately"); and an
image loaded in a live app. Only then did the remaining eight follow.

That is the opposite of how step 3 was done — eleven variables changed in one sitting,
then hours spent separating a `https://` typo from a drifted secret from a gateway that
had not redeployed. **The same person, the same afternoon, two orders of operation, and
the difference was entire.**

### Removing the domain removes the port with it — and that is fine

The `→ Port 5007` shown beside the public domain disappeared when the domain did, which
looks alarming and is not: that number was part of the **edge forwarding rule**, not a
setting. The process still listens on 5007 because `PORT` is its own variable, untouched
— proved immediately by the image that loaded after the removal.

**Where the port lives when the domain is gone: `Variables → PORT`.** Not the code's
fallback (`PORT ?? 5010` on storage, which runs on 5007 and never reaches it).

### Pre-flight: what the search had to cover, and nearly didn't

Nothing depended on a service's public domain. But the first scan was scoped to
`tec-core-backend` alone, and reported "clean" — while **22 references in the app
repos' CI workflows** had not been looked at. A background job searching all repos,
started earlier and still running, surfaced them.

They turned out to be a build-time env fallback pointing at the **gateway**, which stays
public. Harmless — but harmless by luck, not by method. **"I searched" is a claim about
the search's scope, and a clean result from a narrow scope reads exactly like a clean
result from a complete one.**

### What is NOT proven, stated rather than implied

`payment`'s domain was removed before the Pi Developer Portal's webhook URL was read. A
**successful** payment does not exercise it — that path is create → approve → complete
through the gateway; the webhook is `/payments/webhook/incomplete`, which Pi calls for
payments left hanging.

**The exposure is small, and the reason is worth knowing:** `tec-payment-service` runs
its own hourly reconciliation cron (`RECONCILE_CRON`, default `0 * * * *`) that asks **Pi
itself** what happened to every stale `created`/`approved` payment and completes or
cancels accordingly. That is an OUTBOUND call needing no inbound domain. So if the
webhook is now dead, stale payments still settle — **within the hour instead of
immediately**. Slower, not lost.

The fix, when the Portal is read, is to point the webhook at the **gateway** (which
carries an explicit public exemption for `^/api/payments/webhook`) — **not** to restore
payment's domain.

> **SUPERSEDED the same session — the webhook route was removed instead.** The Portal
> question stopped mattering: the route had never settled a payment in its life
> (`PI_WEBHOOK_SECRET` was never set, so its HMAC could not be computed and every call
> was answered 401), while the exemption it carried was real. See *"A dead route that
> was still holding a door open"* below. The gateway's `^/api/payments/webhook`
> exemption is gone too — do not point anything at it.

### A naming trap that cost a wrong instruction

`tec-commerce` (the merchant app: products, orders) has **no Pro feature and never had
one** — it is the same generation as `tec-assets` and `tec-ecommerce`, all three of which
also sit outside the tec-ui v3 palette. `tec-commerce-service` is what owns `Subscription`
for the whole fleet.

The step-3 checklist told the operator to verify `COMMERCE_SERVICE_URL` by looking for the
★ Pro card "in Commerce". The *test* was right — that card in any app is served by
commerce-service — but the sentence named the app. **A service and an app one word apart
will be confused, and the checklist is where that costs someone an afternoon.**

### Docs reconciled (tec-core-backend)

The root README's "Live URLs" listed all eleven; nine of them now resolve to nothing. It
names the two that remain and why, and records the three facts that cost time in step 3
and are discoverable nowhere in the repo: `http` not `https`, the port comes from
`Variables → PORT`, and the private domain is frequently **not** `<service>.railway.internal`
(`auth` is `triumphant-spirit`; `storage` and `asset` are `tec-core-backend-<hash>`).

Three service READMEs said "Direct service URLs are internal only" — policy, and now
physics. The gateway README's deploy step said Railway exposes the service publicly: true
for that one service and for no other here.

### Two lines in one boot log, neither of them an error (tec-core-backend #323)

The payment-service boot on 18 Sep 2026 printed nothing that looked like a failure. It
printed two lines that read like housekeeping, and each described something worth acting
on. **A service that is not crashing is not the same as a service that is doing its job**,
and the only difference between those two states, that day, was whether anyone read the
warnings under the startup banner.

**`Rate-limit store error – allowing request`** — eight minutes after boot, immediately
before `Creating payment`. Every request that hit it landed in the catch and was waved
through. The limiter was not degraded — it was **absent**, on the service that moves real
Pi, with initiate/confirm/cancel (5/5/3 per window) all off simultaneously.

> **Correction, made the same day by the next deploy's log:** this section first said
> "when Redis was chosen and then stumbled", i.e. an occasional blip. **Wrong — it was
> deterministic, every boot, first request.** See *"The log that corrected the diagnosis"*
> below. The fix in #323 was right regardless; the causal story was not, and a wrong cause
> written in the source of truth is how the next session inherits a wrong mental model.

> The original `next()` was **right that a Pi payment must not be refused because Redis
> hiccuped, and wrong that this is a choice between refusing and not counting.** The
> in-memory store was already in that file, written, unused after boot. Falling back to it
> keeps the flood bounded AND lets the legitimate payment through. Per-instance, so the
> effective limit during an outage is (instances × max) instead of (max) — weaker than
> Redis, unboundedly stronger than nothing. **A fallback that is not written down as a
> fallback is a hole with a comment over it.**

The tests were then run against the **bug**, not only against the fix: reverting the catch
block to the old `next()` turns 2 of the 5 red. A test that stays green on the broken
version is not evidence about the fix — it is a green tick.

### A dead route that was still holding a door open

**`PI_WEBHOOK_SECRET not set — signature validation skipped`** was the second line, and it
said the opposite of what the code did: `validatePiSignature` returned `false` and the
caller answered **401**. Fail-closed and correct — but read alone, on a route the gateway
exempts from JWT, *"validation skipped"* describes a service accepting an unsigned webhook
from anyone. **Someone could reasonably have read that as a live P0 and acted on it.**

Investigating it produced a decision, and the CEO made it: **let the cron settle incomplete
payments — the webhook is not needed.** The route was removed.

What made that easy is what the investigation turned up. The route had **never settled a
payment**: no secret, no HMAC, 401 to everything. What it *did* have was an exemption —
`WEBHOOK_PATHS` skipped `validateInternalKey`, making those three paths the only ones on
the payment service that did not require `x-internal-key`, with two matching gateway
`PUBLIC_ROUTES` entries written as **prefixes**, five lines below a comment explaining why
a prefix under a money path is dangerous.

> **A capability that never worked still costs whatever it was granted.** The webhook
> delivered nothing for its entire life and held the only gap in the guard on the service
> that moves real Pi. Nothing had grown into that opening — which is the argument for
> closing it now rather than the argument for leaving it.

Nothing is lost operationally. Two paths settle an incomplete payment and both were
already doing the work: `POST /payments/resolve-incomplete`, which the browser's Pi SDK
triggers via `onIncompletePaymentFound` (immediate, and the path users actually hit), and
the hourly reconciliation cron, which asks **Pi itself** about anything stale and completes
or cancels from Pi's own answer. **The stated cost:** a payment Pi completed but whose
`complete` call we missed now waits for the sweep instead of seconds. That is the trade
that was chosen, not a detail that slipped through.

Also removed: 249 lines of integration test for that route which **had never run** — the
whole `__tests__/integration/` directory sits in `testPathIgnorePatterns`. **A test file
that no runner matches is documentation with a `.test.ts` extension**, and it had been
reading as coverage for years.

Kept deliberately: `PAYMENT_WEBHOOK_RECEIVED` in the audit event union. Nothing writes it
now, but audit rows are immutable (Invariant #5) and rows already in the table carry that
string — **dropping it would leave written history that the type system says cannot exist.**

### The log that corrected the diagnosis (tec-core-backend #324)

Deploying #323 produced the evidence that its own explanation was wrong. The new line
appeared exactly where the old one had been:

```
14:40:39  Payment Service running on port 5003
14:40:39  Using Redis idempotency store          ← Redis, healthy
14:40:39  ✅ Redis publisher connected            ← Redis, healthy
14:41:09  Rate-limit store error – falling back to in-memory counting
14:41:09  Creating payment
14:41:34  Payment completed successfully
```

Two facts in one boot: **Redis was fine**, and the rate-limit store failed anyway. One
error, at the first payment, never again that boot. Not a blip — **a race the first
command loses every single time**, by construction:

- the store was built LAZILY, so the ioredis client was constructed **by** the first
  request that needed it;
- `lazyConnect: true` leaves it in status `wait` until something is sent;
- ioredis writes only when the status is `ready`, and `enableOfflineQueue: false` rejects
  anything else on the spot (`Redis.js:376`).

Construct and command in the same tick and the command cannot win. **So the exposure
before #323 was worse than #323 itself claimed: the first payment after EVERY deploy ran
with the limiter switched off — not rarely, always.**

> **The control was in the same service the whole time.** `idempotency.middleware.ts` uses
> `enableOfflineQueue: true`, no `lazyConnect`, and is built at boot — and has never
> failed this way. Same service, same Redis, same file layout. **When one client fails and
> its sibling does not, the variable is not the dependency.** That comparison was available
> from the first log and would have produced the right answer immediately; "Redis
> stumbled" was reached instead because it is the explanation that needs no reading.

Fixed in #324 by both halves — `client.connect()` at construction and
`initRateLimitStore()` at boot — because either alone still loses the race.
`enableOfflineQueue: false` was KEPT, with the reason now written beside it: a queued
command makes a payment wait on an unhealthy Redis, and failing instantly is what lets the
in-memory fallback take over invisibly. **That is only the right trade because #323 made
the catch count instead of waving the request through** — the same option was a liability
before and is correct after, without changing.

### Runtime Verified — both fixes, and the path the webhook removal now leans on

Deploy `8ea0b06e`, 18 Sep 2026 14:56 GMT+3:

| Expected | Observed |
|----------|----------|
| `Rate-limit store initialised` at boot | ✅ 14:56:58, beside `Idempotency store initialised` |
| the error line GONE from the first payment | ✅ two real payments (12π, 1π) — **no `Rate-limit store error` anywhere** |
| the reconciliation cron actually runs | ✅ 15:00:00 on the hour — `Starting stale payment reconciliation`, cutoffs 11:30/11:00, `No stale payments found`, `reconciledCount: 0` |

That third row is the one that matters beyond this fix. Removing the Pi webhook put weight
on the hourly cron, and the log shows it **firing on schedule and completing** — so the
path chosen as the replacement is observed working, not assumed. `[Runtime Verified]`.

> A display detail worth knowing before it costs someone an hour: Railway's log pane does
> **not** always list lines in timestamp order — in this deploy `Payment completed
> successfully` (`.165`) is rendered ABOVE `Completing payment` (`.027`). The timestamps
> are the truth; the ordering is ingestion batching. **Read the times, not the rows.**
