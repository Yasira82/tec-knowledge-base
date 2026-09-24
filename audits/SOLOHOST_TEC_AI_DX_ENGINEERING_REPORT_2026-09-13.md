# SoloHost × TEC AI × DX — Engineering Report

**PLACEHOLDER — no `C-NN` assigned.** Numbering is human authority (`.cursorrules` RULE 6).

**Date:** 2026-09-13
**Truth State:** [Current State] — assessment of a proposal against a verified external
contract and deployed TEC code.
**Governance State:** [Draft]
**Verification:** [Documentation Verified] for the SoloHost contract — read from
`github.com/pi-node/solohost` (`README` + `SOLOHOST.md`), quoted below.
[Code Verified] for every claim about TEC.

**Companion to:** `NEXUS_IIC_ENGINEERING_REPORT` and
`FOUR_RUNTIMES_ENGINEERING_REPORT`, both 2026-09-13.

---

## 0 · The verified contract

My previous report marked Pi's new capabilities `[Assumed]` because I could not check
them. The SoloHost repository is public, so this part is now verified:

| Fact | Source |
|---|---|
| A package is **exactly two files** — `docker-compose.yml` + `config_options.yml` | *"the set of files SoloHost needs to install and run your app on someone's computer"* |
| The package contains **no application code** | *"these files do **not** contain your app's design, screens, or code. Your app already lives inside a **Docker image**"* |
| The image must be **public** | compose points at an already-published public image |
| `config_options.yml` declares what the **end user** answers at install | users answer *"in plain language"* about features *"like API keys"* |
| Answers become **environment variables via a plaintext `.env`** | *"Each field's `name` is the `.env` key it writes"*; install *"writes the answers to the file named by `output_file` (e.g. `.env`), and runs `docker compose up -d`"* |
| Field types | `text` · `password` · `number` · `select` · **`hidden`** — *"written but never shown to the operator"* |
| Validation | `validate_api.py`, must return `Result: OK` |
| Publishing | copy-paste both files into the web interface |
| **Healthchecks are NOT required** | *"healthchecks are not required"* in v0; *"healthcheck presence/quality"* sits in the **"Not enforced yet"** column |

Two of these contradict assumptions in the proposal, and one of them is a security
finding. They are §1 and §3.

---

## 1 · 🔴 TEC AI as it exists today cannot be containerised for SoloHost

This is the finding that decides the whole plan, and it is not a difficulty — it is a
statement about what the product is.

`tec-frontend/src/app/api/ai/chat/route.ts` needs, server-side:

```ts
process.env.ANTHROPIC_API_KEY
process.env.GROQ_API_KEY
process.env.GEMINI_API_KEY
process.env.JWT_SECRET        // verifies the signed context token
```

Every one is **TEC's secret**, and three of them are **billed to TEC**. Now place that
against the verified contract:

```
the Docker image is PUBLIC
        +
config_options answers land in a PLAINTEXT .env on the Pioneer's own machine
        +
the container runs on hardware TEC does not control
```

> **There is nowhere in a SoloHost package to put a TEC secret.** Not the image — it is
> public and pullable by anyone. Not `config_options.yml` — it writes a plaintext file
> on someone else's computer. A shipped `ANTHROPIC_API_KEY` is a key given away to every
> installer, with TEC paying for every token any of them spends.

### 1.1 · The `hidden` field is the trap, and it reads like the answer

`hidden` is documented as *"written but never shown to the operator."* That phrasing
invites exactly the wrong conclusion. **`hidden` hides a value from the installer UI. It
does not hide it from the user.** The value is still written into the plaintext `.env` on
their disk, next to a public image they can pull and read.

`hidden` is for a derived or fixed value nobody needs to type. **It is not a secret store,
and anyone reaching for it to ship a provider key has misread the contract.** Writing this
down is most of the value of this report.

### 1.2 · What the SoloHost edition therefore is

Not a copy of the hosted product. A different one:

| | Hosted TEC AI | SoloHost TEC AI |
|---|---|---|
| Model | TEC's providers, TEC's keys, TEC's bill | **The user's own key**, or a local model |
| Identity | Hub SSO cookies + signed context token | No Hub session — it is not on a `tecosystem.app` origin |
| Context | The user's live TEC data via BFF | Nothing, unless the user authenticates outward |
| Cost to TEC | Per token | **Zero** |

**That reframing is not a downgrade — it is a better product, and it is the one Pi is
actually building toward.** SoloHost's own showcase is OpenClaw and an MCP server; the
direction is local AI on a Pioneer's machine. A "bring your own key / bring your own
model" TEC AI fits that exactly, costs TEC nothing per user, and is the only version that
can be published honestly.

It also has to be said plainly on the package: **this is TEC AI's interface and reasoning
scaffold running on your machine with your model. It is not signed in to your TEC
account.** A user who installs it expecting their wallet and goals will file the bug that
this sentence prevents.

### 1.3 · If the SoloHost edition should reach TEC data later

It cannot use the Hub cookie contract — different origin, no SSO. It would need a
**user-issued, scoped, revocable token** the person pastes into a `password` field. That
is a new auth path with real design (scope, expiry, revocation, audit) and it is
**explicitly out of scope for a first package**. Ship the local-only version first.

---

## 2 · The readiness probe: the spec and TEC disagree with the proposal, differently

**The spec:** healthchecks are *"not required"* in v0 and sit in *"Not enforced yet."* So
readiness is not part of the package contract today. Pi Desktop 0.6.3 may well have added
host-side readiness behaviour — that is a different layer and I could not verify it — but
**nothing in the package spec obliges a publisher to provide one.**

**TEC's side is the more interesting half.** Every app from the template ships
`/api/health`, described in its own source as *"fail-safe, public, never 500s."* Verified
in the Hub: when the gateway is not even configured it returns

```ts
NextResponse.json({ online: false, ... })   // HTTP 200
```

That is **correct for a health endpoint** — a liveness signal that can fail under load is
what caused the false "Backend Offline" (NEW-W), and this one deliberately cannot.

> **And it is precisely wrong as a readiness probe.** A readiness probe's entire job is to
> return **not-ready** so traffic is withheld. An endpoint that always answers 200 reports
> READY while the app is broken — which is the exact 502-to-the-user problem readiness
> exists to prevent.

**Do not point a readiness probe at `/api/health`.** If TEC adds readiness, it is a
separate `/api/ready` that returns a non-200 when a dependency it truly needs is absent.
Two endpoints, two opposite contracts, and the platform already has the naming precedent —
the gateway registers `/health` **and** `/ready` as its first two routes.

---

## 3 · Running counts must not become a trust signal

SoloHost now ranks apps by how many people are running them. The proposal suggests
Analytics consume that.

**As an adoption metric: fine, and interesting.** As anything that feeds trust,
reputation or ranking: no — and the platform's own law already says so. C-107 Connection:

> Trust signals derive from **real economic activity** (completed payments, fulfilled
> orders, repeated collaboration) — **never vanity metrics.**

A running count on a permissionless host is the definition of a vanity metric: it costs
nothing to inflate and it measures processes, not people. Explorer already made the
harder version of this call correctly — **featured ranks BELOW verified, because
visibility is purchasable and trust is not.**

Record it as `PI_SOLOHOST_RUNNING_COUNT` in the Reality layer. Keep it out of Legend,
Elite, Zone and Explorer ranking.

---

## 4 · The permissionless publisher flow is a name risk, and the fix is cheap

Publishing is copy-paste and the flow is open. **Anyone can publish a package called
"TEC AI".** TEC has 24 live apps taking real Pi and a Hub that is the identity authority
for all of them; a package impersonating that brand on Pioneers' machines is a credible
harm, and TEC would learn about it from a user.

**Publishing a minimal, honest TEC package early is the cheapest insurance available** —
it costs two files. That is an argument for shipping *something* soon, and it is a
different argument from shipping the full product soon.

---

## 5 · A generator here is fine — and it is worth saying why, given §2 of the last report

My previous report argued against a DX App Builder. **That objection does not apply to a
SoloHost package generator**, and the distinction is the whole point rather than an
exception:

| | DX App Builder | SoloHost package generator |
|---|---|---|
| Output | An application | A deployment descriptor |
| Lifetime | Edited from day one | **Regenerated, never edited** |
| On template change | The generated app is a fork and cannot receive it | Regenerate, done |
| Failure mode | 24 forks nobody can update | none |

The rule underneath: **generate what is thrown away; template what is lived in.** Two
files that are always regenerated from the image name and the option list are a build
artifact. Rebuilding them is free, so they can never drift.

So `dx solohost` is a good idea, and it is small. Its real value is not writing YAML — the
Pi repo's own assistant already does that. It is **the checks TEC would put around it**,
which nobody else can: does the image build without network (the `bcrypt` lesson)? Does
every `${VAR}` in compose exist in `config_options`? Is any TEC secret name present in
either file? **That last check is §1 turned into a gate**, and it is the one that should
exist before the first package is published, not after.

---

## 6 · Where the proposal is right, verbatim

These need no argument, and two of them are the reason the rest is tractable:

- **`Nexus ≠ SoloHost`.** Nexus stays orchestration; SoloHost is one execution
  environment among others. Moving an orchestrator onto hardware you do not control
  would put run state where it cannot be recovered.
- **Do not move the database.** Same reason, higher stakes.
- **Do not make 24 SoloHost packages.** Each is a public artifact with a support
  surface. C-132's logic applies unchanged: one, prove it, then decide.
- **SoloHost as an additional distribution channel, never the base infrastructure** —
  and the proposal cites Pi's own beta labelling for it. Correct.
- **TEC AI first, not Nexus.** Correct, and §1 sharpens the reason: TEC AI is the one
  component whose SoloHost edition can be genuinely useful with **no TEC secret at all**.

---

## 7 · Sequence

| # | Step | Cost | Note |
|---|---|---|---|
| 1 | Decide the SoloHost edition is **BYO-key / local model** and write that on the package | Zero | §1. Everything else depends on this being settled first |
| 2 | Secret-leak gate: fail if a TEC env name appears in either package file | Tiny | §5. Before the first publish, not after |
| 3 | Dockerfile for the TEC AI UI + its own model client | Small | Must build with no network — the `bcrypt` lesson (C-02 Session 46 §7c) |
| 4 | `config_options.yml`: `password` field for the user's key, `select` for the provider | Tiny | Never `hidden` for anything secret |
| 5 | Publish one package. Claim the name | Small | §4 |
| 6 | `/api/ready` — separate from `/api/health`, allowed to fail | Small | §2. Useful platform-wide, not only here |
| 7 | `dx solohost` — generate + validate + the §5 checks | Small | Only after one package exists by hand |
| 8 | Record `PI_SOLOHOST_RUNNING_COUNT` in Analytics' Reality layer | Tiny | §3 — adoption only, never trust |

**Steps 1 and 2 are the whole risk.** Everything after them is ordinary work.

---

## 8 · What is still unverified

- **Pi Desktop 0.6.3 host behaviour** — running counts, My Apps, the readiness probe,
  Docker Compose improvements. I read the package spec, not the desktop client. The
  spec's *"healthchecks are not required"* is about the **package contract**; it does not
  prove the desktop lacks a probe.
- **Distributed compute / compensation for node operators** — beta, and nothing in the
  package spec speaks to it. No TEC design should assume it.
- **The other Pi capabilities** (Local Storage · Sharing · Staking · PiVerify · Sign-in
  outside Pi Browser) remain `[Assumed]`, as in the previous report. The rule proposed
  there applies: a capability enters the registry as `DESIGNED` on documentation and
  reaches `VERIFIED` only when something in this repo has called it and kept the response.

---

## Related Documents

- `audits/FOUR_RUNTIMES_ENGINEERING_REPORT_2026-09-13.md` — §2 there is the App Builder
  argument §5 here distinguishes itself from
- `audits/NEXUS_IIC_ENGINEERING_REPORT_2026-09-13.md` — the stage-0 bottleneck
- `C-104___TEC_AI_INSTITUTIONAL_CHARTER.md` — *"Decision Support, not Decision Maker"*,
  unchanged by anything here
- `C-107___CONNECTION_INSTITUTIONAL_CHARTER.md` — §3, trust from real economic activity
  and never vanity metrics
- `C-108___EXPLORER_INSTITUTIONAL_CHARTER.md` — featured below verified: the same call,
  already made
- `C-92` · `C-96` — health as a liveness signal; §2 is why readiness is a second contract
- `C-132___SERVICE_EXTRACTION_MODULAR_ARCHITECTURE_POLICY.md` — §6, one then decide
- `C-02___CURRENT_STATE_.md` **Session 46 §5c** — the auth image that could not build
  without the network; step 3's constraint
