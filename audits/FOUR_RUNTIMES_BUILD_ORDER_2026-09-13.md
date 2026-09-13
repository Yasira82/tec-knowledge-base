# The build order for DX · Analytics · Nexus · TEC AI

**PLACEHOLDER — no `C-NN` assigned.** Numbering is human authority (`.cursorrules` RULE 6).

**Date:** 2026-09-13
**Truth State:** [Planned State]
**Governance State:** [Draft]
**Verification:** [Code Verified] for every "today" claim; the plan itself is a proposal.

**Consolidates:** `NEXUS_IIC_v0.1_SPEC` · `NEXUS_IIC_ENGINEERING_REPORT` ·
`FOUR_RUNTIMES_ENGINEERING_REPORT` · `SOLOHOST_TEC_AI_DX_ENGINEERING_REPORT`, all
2026-09-13. Those reports found things; this one puts them in an order.

---

## STATUS — update this table in the same PR as the work

This is the execution record. A plan with no state is a plan that gets re-derived.
Legend: ☐ not started · ◐ in progress (PR open) · ✅ merged · ⊘ dropped, with a reason.

| # | Step | Status | Evidence |
|---|---|---|---|
| **0.1** | Merge #306 · #234 · #137 · #138 | ✅ | all merged |
| **0.2** | Re-consent reaches Mainnet users | ✅ | backend #307 · Hub #235 · `db push` run. **Caused a ~20min login outage — C-02 Session 56c** |
| — | *Prevention from that outage* | ✅ | #308 — `npm run db:push` in all 10 services + runbook |
| **0.3** | `Implementation Status` on C-109 · C-115 · C-110 | ✅ | headers untouched — registry stable. **PHASE 0 COMPLETE** |
| **1.1** | Collapse the duplicate capability registry | ✅ | tec-core-backend **#309** — SYSTEM owns `status`/`owner`; DX serves them via the service API |
| **1.2** | `capability-registry.yaml` + CI gate | ✅ | KB **#141** — **20th KB gate**, single-authority rule. Preflight 21/21 |
| **1.3** | `/api/ready` separate from `/api/health` | ✅ | tec-template-base **#33**. **Fleet rollout to the 20+ apps still open** |
| **2.1** | **Nexus steps call their services** | ✅ | **#310** dispatcher + refusal · **#311** `subscription-renewal` real · **#312** the other two · **#313** the `/api` prefix. **THE BOTTLENECK IS CLOSED — and DEPLOYED** (C-02 Session 56f) |
| — | *What 2.1 actually cost* | — | 1 schema push (all 3 columns) · 4 new endpoints (2 of the "missing four" already existed) · 2 template corrections · 1 404 found only in the callee's boot log |
| **3.1** | Nexus workflow history + templates 2–3 | ✅ | Tec-Nexus **#33** — and the app's THIRD copy of the workflow definitions deleted |
| **3.2** | Analytics emits → Alert classifies | ✅ | tec-core-backend **#314** · KB **#143**. **Deployed** — sweep scheduled, `identity-alert` consumer live |
| **3.3** | TEC AI emits unused recommendation intents | ✅ | tec-core-backend **#315** (sink) · tec-app **#236** (compiler). **Every user turn, not only routed replies** — see below |
| **3.4** | DX console + `dx doctor` | ☐ | |
| **4.1** | `Intent` model + `intent_id` on `NexusRun` | ✅ | tec-core-backend **#316** — DRAFT authorizes nothing; a revision is a NEW ROW. Schema arrives with the deploy (identity self-migrates) |
| **4.2** | `intent.delta.ts` (pure, root-compared) | ✅ | tec-core-backend **#316** — 32 tests, no infrastructure. The asymmetry holds in both directions |
| **4.3** | Rules-first compiler, human confirms `v1` | ☐ | **still best after 3.3 has run a month** — the store's `confirm()` is the half that already exists |
| **4.4** | `intent.gate.ts` | ✅ | tec-core-backend **#316** — ships INERT (no run cites an intent yet); runs BEFORE the payment halt |
| **4.5** | Proof + HMAC | ☐ | |
| **5.1** | SoloHost edition = BYO-key, in writing | ☐ | |
| **5.2** | Secret-leak gate on package files | ☐ | **before the first publish, not after** |
| **5.3** | Dockerfile · config_options · publish one | ☐ | |
| **5.4** | `dx solohost` | ☐ | |

**Next action:** **3.4** (`dx doctor`) or the **`/api/ready` fleet rollout** — both are
conformance work across the 24 apps, and both are cheap to do and expensive to defer. 4.3
(the compiler) stays parked until 3.3 has collected a month of real asks; 4.5 (proof + HMAC)
is last by design, because it records what 4.1–4.4 decided.

> **4.4 is done, and the two decisions worth keeping are both about PLACEMENT.**
>
> The gate runs **before the payment halt**, not beside the dispatcher. Halting for payment
> is itself an act: it puts a request for real Pi in front of a person, and asking somebody
> to pay under a mandate that has lapsed or been revoked is not a neutral pause. Moving the
> call one branch later fails exactly one test and nothing else — which is what a placement
> test is for.
>
> And expiry is checked **per step**, not once at start. A run authorized at 10:00 by an
> intent lapsing at 12:00 must stop mid-saga at 12:01; checking only at `startRun` would
> make the expiry a formality that the longest runs always outlive — and a long run is
> precisely what an expiry is for.
>
> **A run citing no intent is ALLOWED, and that is not fail-open.** §6 property 3: this
> layer can only ever NARROW. It narrows what a HUMAN authorized; where nobody authorized
> anything through it, there is nothing to narrow and C-47 governs as always. Denying those
> would be the intent layer ADDING a restriction the constitution does not have. The
> fail-closed rule lives one step in — a run that DOES cite an intent, and cannot produce
> it, is refused.
>
> **Three absences, each pinned by a test:** no amount ceiling (no step declares an amount,
> so the check could never fire), no exclusions (the gate sees a service name, never the
> product), no delta (nothing proposes a revised intent yet). *A gate whose surface suggests
> it checks budgets is worse than one that says it doesn't.*

> **4.1 and 4.2 are done, and the plan under-described 4.2 in a useful way.** It reads
> *"pure, root-compared"* — which is right, and skips the part that took the thinking: the
> function has to be honest about what it CANNOT compare. A hard constraint whose value is
> a string has no ordering, so `zone_verified → any_seller` cannot be shown to be a
> tightening; a changed operator is a different relation, not a narrowing; `null` on a
> ceiling means unlimited, which is the largest widening there is. Each of those is
> CRITICAL by refusal rather than by comparison. A delta that only knew how to compare
> numbers would have passed every one of them.
>
> **`fingerprintOf` was hashing preferences** — TypeScript's structural typing accepted the
> whole normalized intent for a `BindingFields` parameter, so it compiled and quietly
> included them. Every legitimate re-ranking would have moved the fingerprint, and a drift
> signal that fires constantly is one nobody reads. §4.2 says preferences are excluded; the
> function now picks its five fields instead of trusting its parameter type.

> **2.1 is closed, and the plan was wrong about it in a way worth recording.** This table
> said "Nexus steps call their services" and the catalog named four missing endpoints.
> Adding those four alone would have changed nothing: a run carried no parameters and no
> step could see what an earlier step produced. *You cannot reserve inventory for an order
> that does not exist.* Two of the four turned out to already exist (`orders/checkout`,
> `marketplace/:id/buy`), and two of the things actually needed were engine capabilities
> (`NexusRun.input`, `NexusStep.output`) that appeared nowhere in this plan.
>
> A plan that names the visible half of a gap is still worth having — it got the order
> right, and the order is what mattered. But the size of a step is only knowable from
> inside it.

**Outstanding from earlier phases:** the `/api/ready` fleet rollout — **21 of the 22 apps
lack it** (counted 2026-09-13; only `tec-template-base` has it).

> **A correction worth carrying, because it contradicts this repo's own runbook.**
> `tec-core-backend/CLAUDE.md` says a schema change needs a Custom Start Command of
> `npm run db:push && node dist/main`. That is right for **nine** of the ten services with a
> schema — and **wrong for `tec-identity-service`**, the one this phase keeps touching. Its
> Dockerfile CMD is already `node scripts/migrate.cjs && node dist/main.js`: a wrapper with a
> wall-clock deadline and a Postgres `lock_timeout`, written after a 2026-09-01 deploy hung
> on a migration lock and failed the healthcheck at 04:44 **with no error message**.
>
> Setting the Custom Start Command on that service **overrides the CMD** and reinstates the
> unbounded push — which is exactly what happened on 2026-09-13: `Network › Healthcheck ✗
> (04:41)`, same shape, same silence. Production was unaffected only because the wrapper's
> non-zero exit leaves the previous version serving.
>
> **For identity-service: leave the start command empty and let the image migrate itself.**

**Phase 2.1 is deployed** (C-02 Session 56f): schema pushed, all three services live on
the right paths, verified from the dashboard rather than inferred from a merge. What
remains is **execution** — no run has been driven end to end in production yet.

---

## 0 · The order is forced, not chosen

Four facts, each verified in the previous reports, remove almost all the freedom:

1. **Nexus does not call any service.** `NexusStep.service` is *"the owning service that
   WOULD execute it."* So there is no external side effect — nothing to gate, nothing for
   TEC AI to act through, no workflow that does anything.
2. **The capability registry exists twice and has already drifted.** Anything that reads
   a capability today reads a coin flip.
3. **`/api/health` can never fail.** It is correct as liveness and unusable as readiness.
4. **The Hub's front page advertises a reward it cannot pay** until each Mainnet user
   signs in again.

Everything below follows from those. Where a step could go in two places, it is placed by
what it unblocks, never by how interesting it is.

### The two rules this plan obeys

> **1. Fix what lies before you add what impresses.** A platform is not strong because it
> has an intent-integrity layer. It is strong because nothing it displays is untrue. (4)
> is the whole argument.
>
> **2. Every step must be independently useful, and independently abandonable.** If the
> programme stops after any step, what shipped still works and nothing is half-built.

### One constraint this plan is shaped by

**One person builds this, with an AI, merging from a phone.** That is not a limitation to
work around — it is the design input. So: small serial PRs with one verification each,
never four parallel workstreams. A roadmap written for a team of twelve would be the
wrong plan, correctly formatted.

---

## PHASE 0 — Make every live claim true

*Roughly a week. Nothing here is new work; it is closing what is open.*

| # | Step | Why first |
|---|---|---|
| 0.1 | Merge tec-core-backend **#306**, tec-app **#234**, KB **#137** | Written, tested, green. Unmerged work is invisible work |
| 0.2 | **Get the `wallet_address` re-consent to Mainnet users** | The front page says *"claim real Pi."* Until each user signs in again, it cannot pay them. #306 now records the reason and #234 shows it — but a passive message only reaches people who look. A notification, or a one-time interstitial at login, is what closes it |
| 0.3 | `## Implementation Status` on **C-109 · C-115 · C-110** | One hour. The KB currently understates Nexus and would mislead anyone planning against it |

**Done when:** no live surface makes a claim the code cannot keep.

> This phase is the answer to *"how do we make the project strong."* The other four phases
> make it capable. This one makes it honest, and it is the cheaper of the two.

---

## PHASE 1 — One source per fact

*One to two weeks. Four runtimes that read different copies of the same fact cannot be
composed, so this is the precondition for the whole architecture, not housekeeping.*

| # | Step | Detail |
|---|---|---|
| 1.1 | **Collapse the duplicate capability registry** | Delete the governed fields from DX's copy. SYSTEM owns `status`; `@yasser172/tec-sdk` owns input/output schemas (C-47 §14); `asset-registry.yaml` owns dependencies. DX keeps install line, example, guide — what is genuinely its own |
| 1.2 | **Make it a manifest + CI gate** | `manifests/capability-registry.yaml` + `evals/check-capability-registry.sh`, exactly like `events-catalog.yaml`. Code-sourced, one artefact, gated. The pattern is proven on 13 events |
| 1.3 | **`/api/ready`, separate from `/api/health`** | Health stays fail-safe and never 500s (NEW-W). Ready is allowed — required — to fail. Template first, then the fleet |

**Done when:** there is exactly one answer to *"which capabilities exist, and what is each
one's status?"*, and a gate fails if a second appears.

---

## PHASE 2 — The bottleneck

*The real work, and the one allocation decision worth deliberating.*

| # | Step |
|---|---|
| 2.1 | **Nexus steps call their owning services.** One template (`checkout-saga`), behind a flag, with the failure path wired to `fail()` so compensation actually runs |

Everything downstream is blocked here — the execution gate, TEC AI Action, real workflows,
the whole IIC. The engine, the saga guarantees, the U2A halt and the resume consumer all
exist; what is missing is the dispatcher.

**Done when:** a `checkout-saga` run completes end to end against real services with a
real Pi payment, and a deliberately failed step rolls the earlier ones back.

> **Do not skip ahead of this.** A gate built before it would be verified against
> simulated effects — the exact condition under which the A2U payout path shipped unable
> to pay anyone. Three of that path's four defects were invisible until something real was
> attempted.

---

## PHASE 3 — The four runtimes become what they claim

*After Phase 2. These four are genuinely independent of each other — take them in any
order, one at a time.*

| # | Runtime | Step | Cost |
|---|---|---|---|
| 3.1 | **Nexus** | Workflow history API + status; the second and third templates | Medium |
| 3.2 | **Analytics** | Compute the finding, **emit it**; Alert classifies and routes. The "Decision Signals" layer, in the runtime that already owns severity and routing | Small |
| 3.3 | **TEC AI** | On every *Recommendation*, emit the structured intent object it would later hand to a gate — **and do nothing with it** | Tiny |
| 3.4 | **DX** | Developer Console (keys, usage, health) + **`dx doctor`** | Medium |

**3.3 is the highest value-per-hour step in this document.** Zero risk, no new surface, and
after a month it is the only honest way to design the compiler's closed objective set —
from intents users actually expressed, rather than from imagination.

> **3.3 shipped, and the trigger changed on purpose.** This row said *"on every
> Recommendation"*. A recommendation is a reply carrying a nav marker — which means
> filtering to them would have sampled **only the objectives the system prompt already
> knows how to route**. That is precisely the wrong sample for discovering which ones are
> MISSING, and the missing ones are the entire reason this step exists. The trigger is
> every user turn: the ask is the intent; the reply is the platform's answer to it.
>
> Two more things the build settled, neither of which was in this plan:
>
> - **The sink cannot hold the vocabulary.** `tec-analytics-service` validates shape and
>   bounds only; the closed set lives in the Hub's compiler alone. A server-side allowlist
>   would be a second definition of one rule (P2) **and** would reject exactly the rows
>   that prove the set incomplete. `objective: null` is a first-class, accepted answer.
> - **Research is not activity.** `ai.intent.observed` had to be excluded from
>   `getRecentEvents`, or an inference about what somebody ASKED would appear in Life's
>   timeline as something they DID.

**3.4's `dx doctor` is conformance, not generation.** It reads the 24 apps that already
exist and reports drift from the current template — unresolvable dependency ranges,
missing CI guards, a placeholder app name, a hand-rolled Pro parser. A generator would
serve only apps not yet written; the fleet's problem is propagation, and Session 46 is the
evidence.

---

## PHASE 4 — The invention

*IIC 4.1 and 4.2 are pure functions with no dependencies. **They can be written at any
point from today onward**, including during Phase 0, because they touch nothing live.*

> **Done (tec-core-backend #316).** The "touch nothing live" claim held for 4.2 exactly —
> it is a pure function with 32 tests and no infrastructure. It was *nearly* true for 4.1:
> the schema is additive and `NexusRun.intent_id` is nullable, so every existing run is
> unaffected — but the column is inert unless something enforces what may be written into
> it, so `startRun` now asks the store whether a cited intent is the caller's own,
> CONFIRMED and unexpired, and creates nothing if it is not. **A nullable foreign key with
> no rule is a comment in a table.**
>
> What the store deliberately does NOT do is decide anything: `/check` returns a verdict,
> it does not enforce one. Enforcement is 4.4, in front of the dispatcher, and putting it
> in two places is the duplication the last several sessions were spent removing.

| # | Step | Note |
|---|---|---|
| 4.1 | `Intent` model + `intent_id` on `NexusRun` | Additive schema |
| 4.2 | **`intent.delta.ts`** — pure, compared against the human-signed **root** | **This is where the invention actually lives.** 100% unit-testable with no infrastructure. If the programme were cancelled after this, the cost is one unused file |
| 4.3 | Rules-first compiler → `v0`; human confirms → `v1` | Life's intent store already settled this: a client-fed intent is a claim, not evidence |
| 4.4 | `intent.gate.ts` in front of the Phase-2 dispatcher | Needs 2.1 |
| 4.5 | Proof record + HMAC | Last — it records what 4.1–4.4 decided |

---

## PHASE 5 — Distribution

| # | Step |
|---|---|
| 5.1 | Settle in writing that the SoloHost edition is **bring-your-own-key / local model** |
| 5.2 | **Secret-leak gate** — fail if any TEC env name appears in either package file |
| 5.3 | Dockerfile (must build with no network — the `bcrypt` lesson), `config_options.yml` with a `password` field, publish one package, claim the name |
| 5.4 | `dx solohost` — generate + validate + 5.2's checks |

5.1 and 5.2 are the entire risk. **A SoloHost package can hold no TEC secret**: the image
is public and the answers land in a plaintext `.env` on someone else's machine.

---

## What this plan deliberately does not build

Stating these once is worth more than a backlog nobody reads.

| Not building | Why |
|---|---|
| **A DX App Builder / code generator** | The 24 apps were all cloned from one template; they diverged because fixes could not *travel*, not because they started differently. A generator improves day 1 and worsens day 400 — generated code is a fork at birth |
| **24 SoloHost packages** | One, prove it, then decide (C-132) |
| **A `tec-governance-service`** | No T1–T4 trigger. SYSTEM's write path is a chartered increment, not a service |
| **A 25th app for IIC** | It is Nexus V2 — C-109 §10 Phase 2 |
| **Blockchain-anchored proof** | The proof must be *verifiable*, not decentralized. HMAC is verifiable today |
| **SYSTEM on the gate's decision path** | It has no runtime authority API. The gate enforces against C-47 directly until SYSTEM has one |

---

## How to tell the project actually got stronger

Not by how much shipped. By whether these become true, in order:

1. **Nothing on a live screen is untrue.** (Phase 0)
2. **Every fact has exactly one owner, and a gate proves it.** (Phase 1)
3. **A workflow does something real, and rolls back when it fails.** (Phase 2)
4. **Each of the four runtimes answers its own question and no one else's.** (Phase 3)
5. **An agent cannot widen what a human authorized — and can prove what it did.** (Phase 4)

Phases 1–5 are capability. **Phase 0 is credibility, and it is the only one where being
late costs something today.**

---

## The shape of it

```
PHASE 0   truth            ── merge · re-consent · 3 status sections
   │
PHASE 1   one source       ── capability registry · CI gate · /api/ready
   │
PHASE 2   the bottleneck   ── Nexus steps CALL their services        ◄── everything waits here
   │
   ├── PHASE 3  the four   ── Nexus · Analytics→Alert · AI intents · DX console
   │
   ├── PHASE 4  invention  ── 4.1/4.2 can start TODAY, in parallel, zero risk
   │
   └── PHASE 5  SoloHost   ── BYO-key, secret gate, one package
```

---

## Related Documents

- `audits/NEXUS_IIC_ENGINEERING_REPORT_2026-09-13.md` — §2, the Phase-2 bottleneck
- `audits/FOUR_RUNTIMES_ENGINEERING_REPORT_2026-09-13.md` — §1 registry drift, §2 the
  generator argument
- `audits/SOLOHOST_TEC_AI_DX_ENGINEERING_REPORT_2026-09-13.md` — Phase 5's constraints
- `audits/NEXUS_IIC_v0.1_SPEC_2026-09-13.md` — what Phase 4 builds
- `audits/A2U_FIRST_PAYOUT_ROUND_2026-09-13.md` — Phase 0.2, and why Phase 2 precedes 4.4
- `C-109` · `C-115` · `C-110` — the three charters Phase 0.3 corrects
- `C-132___SERVICE_EXTRACTION_MODULAR_ARCHITECTURE_POLICY.md` — no new service in any phase
