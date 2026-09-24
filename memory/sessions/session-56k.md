# Session 56k — Three credentials out of CI, and a uniqueness assumption that would have paid the wrong person

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

Follow-on from 56j. That session removed `RAILWAY_TOKEN` as a side effect of
deleting a racing deploy job; this one went looking on purpose and found two more
things in the same shape.

### What was in GitHub Secrets, and what is left

| Secret | Was | Now |
|--------|-----|-----|
| `RAILWAY_TOKEN` · `RAILWAY_PROJECT_ID` | production-write, on every push (56j) | **deleted** |
| **`AUTH_DATABASE_URL`** | a connection string to the **identity authority's database**, injected into a GitHub Actions runner | **deleted** (#317 → #318) |
| `API_GATEWAY_URL` · `INTERNAL_SECRET` · `NPM_TOKEN` | in use | kept — each verified to have exactly one consumer |

**Three credentials left CI in one day, two of them production access.** The audit
that found them was four greps: for each secret, which workflow actually references
it. A secret nothing references is pure attack surface; a secret ONE workflow
references tells you where to look.

### The Testnet A2U payout read auth-service's database from a runner

`list-pi-uids.mjs` resolved usernames → Pi uids with `prisma.user.findMany` over
`AUTH_DATABASE_URL`. Read-only, and still two violations: reading that table from
outside the service is **Forbidden Behavior #1**, and auth owns Identity
(**Invariant #8**), so the lookup was in the wrong place.

Replaced by `GET /api/auth/uids-by-usernames` behind `x-internal-key`. **No new
secret** — the gateway accepts a matching internal key in place of a user JWT
(`jwt-auth.ts`, `timingSafeEqual`), which is the sanctioned service-to-service
path, so the two secrets the payout already held were enough.

### It is not a relocation of the query. It is a better one.

| | the DB script | the endpoint |
|---|---|---|
| Read scope | **every** row with a uid, filtered in memory | only the names asked, capped at 50 — **cannot become a dump** |
| A name on two accounts | — | **every** matching row |
| A row with no `pi_uid` | returned | omitted |
| Cost of one query | `npm ci` + `prisma generate` | Node built-ins, no install |

> **THE FINDING, and it was hiding in the schema:**
>
> ```prisma
> pi_uid       String?  @unique
> pi_username  String?            ← no @unique
> ```
>
> **A Pi username can belong to two accounts.** `findFirst` — the natural shape
> for "resolve a name to a uid", and what any reasonable person writes — would
> have picked one **by row order** and paid a person the operator never looked at.
> Silently. With real Pi.
>
> The payout script already had a `duplicate` marker for exactly this, and it only
> works if both rows reach it. The endpoint returns all of them and a test pins it,
> with the reason written next to the code so nobody "simplifies" it later.

### The distinction the database could not make

A DB query that returns nothing and a network that never answered look identical
to a caller — an empty list. On a run about to pay people, those are opposite
facts. The resolver separates them:

```
a named person with no account  → exit 1, "NOT FOUND: ghost … has not signed in yet"
wrong INTERNAL_SECRET           → exit 1, "that is a KEY mismatch, not a missing user"
gateway unreachable             → exit 1, "this says nothing about whether these accounts exist"
```

Same family as C-135 §4 (Explorer returns `source:'unavailable'` rather than a
fixture) and the Session 46 `exit 0` deploy: **an absence must never be reported
as a finding.**

### Order, and why it was three PRs and not one

`expand → migrate → contract`, the sequence used for the `user.created.v1` rename
(Sessions 23–24):

| | PR | Gate before the next step |
|---|---|---|
| expand | **#317** — endpoint added, nothing calls it | merged **and deployed** — proven by auth-service's boot log: `Mapped {/uids-by-usernames, GET}` |
| migrate | **#318** — the payout calls it; the DB step is gone | verified on `main` itself (not the branch) that no step still consumes the secret |
| contract | — | `AUTH_DATABASE_URL` deleted from repository secrets |

**#317 was split out of #316 onto its own branch, deliberately.** #316 migrates
`identity-service`'s schema and is waiting for an attended window; the auth change
had no such constraint. Bundled, one merge would have deployed the schema migration
AND the platform's login authority together — and left no way to tell which caused
a problem.

> **A deploy that does NOT happen can be the correct outcome.** #318 touched only
> the workflow and a payment-service script, so auth-service did not redeploy —
> its Watch Path (`/tec-auth-service/**`) saw nothing. Reading that as "the merge
> failed" would have been the wrong conclusion; it is the Watch Paths working.

### Honest status

- `[Runtime Verified]` for the endpoint (it is answering in production).
- `[Code Verified]` for the payout switch: the resolver was exercised against a
  **stub** gateway, not prod. It becomes Runtime Verified the next time a real
  `step: list` is run.
- auth 77/77 · payment 295/295 · both typecheck clean · mutation-tested (dropping
  the uid filter fails exactly one test; removing the cap fails exactly one other).
  All local — Actions has not run since 13:20 on 2026-09-13.


### The sweep continued across the fleet — and Tec-App was the only real exposure

Having found one, the same question was asked of every repo: **for each stored
secret, which workflow actually references it?** Workflows are readable from the
repo; the stored list is a Settings page, so this was CEO-screenshot + local grep.

| Repo | Stored | Verdict |
|------|--------|---------|
| **`Tec-App`** | 6 | 🔴 **`INTERNAL_SECRET`** · `AUTH_SERVICE_URL` · `PAYMENT_SERVICE_URL` + 3 public — **CI referenced exactly one of the six**. All deleted. |
| `tec-core-backend` | 4 → 3 | `AUTH_DATABASE_URL` deleted (above); the rest each verified to have one consumer |
| `Tec-Assets` | 2 | `NEXT_PUBLIC_API_GATEWAY_URL` dead in BOTH workflow and source → deleted |
| `Tec-Commerce` · `Tec-Ecommerce` | **0** | Correct as-is — every reference has a written fallback |

**`INTERNAL_SECRET` in the Hub's CI was the find.** The platform generates ONE value
for the gateway and every service (`CLAUDE.md`: *"generate once, same value for ALL 4
services"*), and the gateway accepts it **in place of a user JWT** — verified this same
session in `jwt-auth.ts`. A copy in a frontend repo's CI is a copy of the key to the
entire backend. It had sat there five months, referenced by nothing.

> **A correction to something claimed earlier in this session.** `Tec-Ecommerce`'s
> `ci.yml` *references* `secrets.INTERNAL_SECRET`, which was read as "the one frontend
> repo where the master key is used in CI". Its secret store is **empty** — the workflow
> has always fallen through to `'ci-test-secret-minimum-32-chars!!'`, which is the
> correct shape for a build. **A reference is not a possession.**

**The pattern:** every one of these dates to repo creation ~5 months ago — added
"just in case" before anyone asked what CI needed. The runtime consumer is **Vercel**,
a separate store. Deleting from GitHub cannot affect a running app, and saying so was
what made the deletions safe to do from a phone.

### NEW-A: a false alarm, settled by a build rather than a grep

The sweep surfaced `NEXT_PUBLIC_API_GATEWAY_URL` read by source in **17 repos**, and a
hardcoded Railway host committed in **32 source files**:

```ts
// src/lib/sdk.ts — in tec-template-base, therefore in every app cloned from it
const gatewayUrl = process.env.NEXT_PUBLIC_API_GATEWAY_URL
  ?? 'https://api-gateway-production-6a68.up.railway.app';
```

`NEXT_PUBLIC_*` is inlined into the browser bundle at build time, so this read as
**NEW-A reopened across 17 apps live on Mainnet** — a finding recorded as ✅ CLOSED.
It was raised as exactly that, and then checked instead of reported:

```
Tec-Explorer (has the literal, reads the var in 3 files, build newer than source)
  grep -rl  "railway.app"       .next/static/  →  0
  grep -rhoE "https://…"        .next/static/  →  hub.tecosystem.app ×5 · explorer.tecosystem.app ×1
  grep -rl  "gatewayUrl"        .next/static/  →  0
  grep -rl  "resolveIncomplete" .next/static/  →  0
  (control: "hub.tecosystem.app" →  3 files, so client strings DO survive)
```

**No gateway URL of any kind reaches the browser. NEW-A is genuinely still closed.**

`resolveIncomplete` is the load-bearing zero: it is a property name on `sdk.payment`,
and minifiers do not rename external property names — had that code been bundled, the
string would be there. The control line matters as much: a grep returning 0 across a
build proves nothing unless you first show the build contains strings you expect.

> **The lesson, and it generalises past this file:** a `grep` over SOURCE proves the
> line exists. It does not prove the line ships. **Only the build knows** — and the
> check cost one command against an artifact that was already on disk.
>
> This is the mirror of the same session's other trap (reading a red run beside a
> change as caused by it). Both are answered the same way: measure the thing you are
> actually claiming, not the thing that is easy to measure.

#### A correction: `src/lib/sdk.ts` is NOT dead code

This block first called it dead and proposed deleting it from the template and the 17
apps. **Reading it before acting showed three live call sites in `pi-auth.ts`:**

```
sdk.clearAuthToken()                    pi-auth.ts:67
sdk.payment.resolveIncomplete(id)       pi-auth.ts:131
sdk.payment.resolveIncomplete(id)       pi-auth.ts:230   ← a PAYMENT path
```

The file is absent from the *client bundle*; that is not the same as being unused.
**Deleting it would have broken incomplete-payment resolution.** The word "dead" came
from one grep (`who imports it`) that returned a single file, and the reflex was to
treat a short answer as a complete one.

#### What was actually wrong, and it was P6 rather than NEW-A

```diff
- const gatewayUrl = process.env.NEXT_PUBLIC_API_GATEWAY_URL
-   ?? 'https://api-gateway-production-6a68.up.railway.app';
+ const gatewayUrl = '';
```

The fallback made a **missing configuration silent**. An app that does not know where
its gateway is would quietly talk to a hardcoded Railway host instead of failing —
doubt about configuration must deny, not guess. Now a stray client→gateway call fails
loudly. Nothing regresses: every real gateway call already goes through the server-only
BFF (`/api/bff/*` → `API_GATEWAY_URL`).

**And the fix already existed.** Six repos (Connection · Life · Zone · Estate · FundX ·
Nexus) carried `gatewayUrl = ''` with a comment citing NEW-A; **fourteen did not,
including `tec-template-base`** — which is why every app cloned from it was born with
the fallback. The correct version was copied **verbatim** rather than rewritten.

> **Fourth instance this session of one rule, solved in one repo, never back-adopted**
> — after the `^1.1.0` caret trap, the Dependabot policy, and CI `concurrency`. Three
> of the four were fixed in the template only after the fleet had already diverged.
> The pattern is no longer a coincidence worth noting; it is the platform's
> characteristic failure, and the template is where it starts every time.

Applied by a fail-closed script that refused any file not byte-identical to the
known-bad version: 14/14 changed, typecheck clean, zero `railway.app` left in any
`src/lib/sdk.ts` in the fleet. Shipped as a second commit on the 14 already-open CI
PRs rather than 14 new ones.

### npm token expiry — not mandatory, and the workaround is to remove the token

Session 46 left "npm Trusted Publishing" open with a deadline: `NPM_TOKEN` in
`Tec-ui` · `TEC-SDK` · `tec-auth` expires **25 Nov 2026**. The question asked was
whether that expiry can simply be made longer. It can be removed instead.

**The objection that had to be checked first** is written in the repos' own
`publish.yml`:

> *npm provenance is intentionally NOT used — this source repo is PRIVATE, and npm
> provenance only supports PUBLIC source repos (422 "Unsupported source repository
> visibility: private").*

That comment is correct, and it is about **provenance**. **Trusted Publishing is a
different mechanism and is available for private and public packages alike** — so the
constraint that blocks one does not block the other. Confirmed against npm's docs
rather than assumed, because if the restriction had been shared the whole plan was void.

**The gap is one line per repo:** Trusted Publishing needs npm CLI ≥ 11.5.1 and Node
≥ 22.14.0; all three `publish.yml` pin `node-version: '20'`. `permissions: id-token:
write` is already present in all three.

**Order matters — npmjs.com FIRST:**

```
1. npmjs.com → each package → Trusted Publisher → GitHub Actions + repo + publish.yml
2. PR: node-version 20 → 22, drop NODE_AUTH_TOKEN / NPM_TOKEN from the workflow
3. after one successful publish → delete NPM_TOKEN from the three repos
```

Doing 2 before 1 fails the publish with 401. And from the record: when the token last
lapsed (26 Aug) the failure was **`E404`** — on a scoped package, `E404` on `PUT` means
**auth failure**, not "package not found". If that appears again, it is the token.
