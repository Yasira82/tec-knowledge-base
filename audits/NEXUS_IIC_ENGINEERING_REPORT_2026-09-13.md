# NEXUS IIC — Engineering Report

**PLACEHOLDER — no `C-NN` assigned.** Numbering is human authority (`.cursorrules` RULE 6).

**Date:** 2026-09-13
**Truth State:** [Current State] — this is an inventory of what exists.
**Governance State:** [Draft]
**Verification:** [Code Verified] — every claim below is a file and a line you can open.
Where I could not verify something, it says so.

**Method:** I read the code, not the charters. The charters describe five runtimes; this
report says what is actually deployed behind each name, because a specification that
assumes a box can answer a question it cannot answer is a specification that fails in
integration, not in review.

---

## 1 · The five claims, checked

The strategy report describes DX, Nexus, Analytics, TEC AI and SYSTEM as five runtimes
that have each evolved. They have — but **not to the same kind of thing**, and the
difference decides the build order.

| Runtime | The report says | The code says | Gap |
|---|---|---|---|
| **Nexus** | Coordination Fabric | **A real state machine.** `NexusRun` + ordered `NexusStep[]`, saga compensation in reverse, honest halt at U2A, idempotent resume from `payment.completed.v1` | **Control plane only — see §2** |
| **DX** | Developer Infrastructure — API keys, rate limits, playground | **A read-only seeded catalog.** Its own header: *"Read-only catalog; API-key issuance + rate-limit tiers are Phase 1+ and NOT modeled here"* | No keys, no limits, no playground |
| **SYSTEM** | Constitutional Runtime — enforcement, activation, certification | **A read-only seeded catalog.** Its own header: *"READ-ONLY … there is NO write method here, by design"* | No write path, no activation, no runtime authority API |
| **Analytics** | Intelligence Runtime | **Real, and the most honest of the five.** `scoring.service.ts` computes from its own log and emits; C-105 is `[Current State]` and earned it | Closest to its charter |
| **TEC AI** | Reason → Orchestrate → Execute | **Advisory chat, read-only.** Multi-provider fallback and a signed context token are real. Its own comment: *"Nothing executes on these — the AI guides, it never acts (C-104 §4)"* | No orchestration, no execution |

**One engine, two catalogs, one advisor, one genuine runtime.** That is not a criticism —
a read-only projection of the constitution into a queryable table is a real and useful
thing, and both DX and SYSTEM say plainly in their own source what they are. The problem
is only that the strategy diagram treats all five as peers that can be composed.

### 1.1 · Which boxes in the proposed diagram cannot answer

```
              NEXUS IIC
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
     SYSTEM   ANALYTICS   NEXUS
    Authority   Signals   Execution
```

- **SYSTEM → Authority.** SYSTEM has no runtime authority API. It can tell you the
  ten Forbidden Behaviors and the FREE/PRO/ENTERPRISE map as *data*. It cannot answer
  *"may this actor spend 250π right now?"* — there is no endpoint, no actor activation
  table, no write path. **The gate cannot call SYSTEM in v0.1.** It must enforce against
  C-47 directly, which is fine, because C-47 is enforced in code and in CI already.
- **ANALYTICS → Signals.** Real, but eventual-consistency by charter and by design. A
  deterministic gate must not read an eventually-consistent input on the decision path.
  **Analytics informs the intent at compile time; it must not be consulted inside the
  gate.** (C-47 consistency model: never eventual for a financial decision.)
- **NEXUS → Execution.** See §2. This is the one that changes the plan.

---

## 2 · The finding that reverses the build order

`NexusStep.service` is documented in the schema as:

```prisma
service String // owning service that WOULD execute it
```

and the engine's own header says:

> *"Wiring each step to its owning service's real endpoint + the U2A payment hand-off is
> the next increment; the engine + its guarantees are real now."*

So the engine advances **its own state**. It does not yet make the call.

> **There is no external side effect for an execution gate to gate.**

The entire purpose of the gate is *"before any external side effect."* Building it now
means building a door that opens onto nothing — and worse, a door that would pass every
test, because nothing on the other side can fail.

**Therefore the order is:**

```
1. Wire Nexus steps to real service calls        ← C-109 §10 Phase 2, already chartered
2. THEN put the gate in front of them            ← NEXUS IIC v0.1
```

Not the reverse. A gate written first would be verified against simulated actions, and
this platform learned four days ago what a payment path verified against simulation is
worth: the A2U path passed every test it had and could not pay a single person.

### 2.1 · What "wire the steps" actually costs

Small, and mostly already decided:

- Each step already names its service and its action in `templates.ts`.
- The call pattern exists: the campaign service already calls
  `POST /api/payment/internal/a2u` through the gateway with `x-internal-key`.
- The U2A hand-off exists: the run halts, payment-service does the money, the consumer
  resumes on `payment.completed.v1` with `metadata.nexusRunId`.

What is missing is a per-step dispatcher and the failure→`fail()` path. That is one
increment, and it is chartered work, not new scope.

---

## 3 · Four precedents in this codebase that constrain the design

These are not style preferences. Each is a decision the platform already made, with a
reason recorded, and each one directly answers a design question NEXUS IIC would
otherwise have to answer from first principles.

### 3.1 · An intent recorded from a client claim is not evidence

`tec-identity-service/src/modules/life/intent.store.ts` already implements intent
signals, and it states the rule:

> *"There is deliberately no 'report my intent' endpoint: a client-fed signal is a
> client-controlled claim about a person, and there is nothing to verify it against."*

**Consequence for IIC:** an Intent Object produced by a model from a user's sentence is a
*claim*, not a fact — including when the model is ours. It cannot become `v1` on the
model's say-so. The human confirms the compiled object, and the confirmation is what
signs it. This is the single most important constraint on the compiler, and the platform
already worked it out in a different domain.

### 3.2 · A closed set beats a free string, twice decided

Life's `INTENT_KINDS` is closed *"on purpose: an open string would let a future caller
write free text about someone into the one store nobody reviews."* Life's skills use a
LADDER rather than a score out of ten, because *"a number invites a precision nobody has."*

**Consequence:** `objective` is a closed set. Free text cannot be diffed, so drift on the
goal — the one thing that must never drift — would be unmeasurable.

### 3.3 · The TTL is a guarantee, not a cache

Life's intent signals live 30 minutes in Redis with no durable copy, because *"'until
something deletes it' is not a privacy property."*

**Consequence:** an Intent Object records what a person authorized, including a budget
and a purpose. `expires_at` is not housekeeping — it is the same guarantee. An intent
with no expiry is a standing authorization, and a standing authorization is the thing
this whole design exists to avoid.

### 3.4 · A failure must carry its reason

All four defects in this week's payout round were the same shape: a failure that
discarded its own reason (`audits/A2U_FIRST_PAYOUT_ROUND_2026-09-13.md`). Every one
passed code review, because a generic error message is not a failing test.

**Consequence:** `BLOCKED` is not an output. `BLOCKED: budget.hard, Δ=+40π, origin
Human@v1` is. A gate that says only *no* is a gate operators will route around.

---

## 4 · Truth State — the observation is right, the conclusion inverts

The strategy report notes that DX, Nexus and SYSTEM carry `[Future Vision]` headers while
having deployed sections, and proposes unifying them. Verified:

| Charter | Header |
|---|---|
| C-115 DX · C-109 Nexus · C-110 SYSTEM | `[Future Vision]` |
| C-122 Analytics Constitutional Runtime | `[Future Vision]` |
| C-105 Analytics | `[Current State]` |
| C-104 TEC AI | `[Planned State]` |

**The inconsistency is real. Unifying them upward would make the KB less honest, not
more.** §1 is why: what is deployed behind DX and SYSTEM is a read-only catalog, and the
charters describe runtimes with enforcement, certification and key issuance. `[Future
Vision]` is the *correct* header for those two — the deployed part is a slice, not the
claim.

Nexus is the one genuinely mis-stated, and in the opposite direction from the report's
reading: a persisted saga engine with compensation exists and the header does not say so.

**The fix is the pattern v3.12.0 already established** — a per-doc `## Implementation
Status` section naming exactly which slice is `[Code Verified]` while the header keeps
the grand claim as future. Six charters already carry one. Three more should:

- **C-109** — the run engine is `[Code Verified]`; execution wiring is not.
- **C-115** — the read catalog is `[Code Verified]`; keys/limits/playground are not.
- **C-110** — the read projection is `[Code Verified]`; enforcement and writes are not.

Cheap, mechanical, and it removes the architectural ambiguity the report correctly
identified — without overstating anything.

---

## 5 · Revised build sequence

Each stage is independently useful and independently abandonable. Nothing here needs a
new service (C-132 Modules-First: no T1–T4 trigger), a new custodian (Invariant #8), or a
25th app.

| # | Stage | Why here | Depends on |
|---|---|---|---|
| **0** | Nexus steps call their services for real | §2 — the gate needs a side effect to gate | chartered (C-109 §10 Phase 2) |
| **1** | `Intent` model + `intent_id` on `NexusRun` | The object has to exist before it can be enforced | 0 |
| **2** | Rules-first compiler → `v0`, human confirms → `v1` | §3.1 — a model's output is a claim | 1 |
| **3** | `intent.delta.ts` — pure, compared against the **signed root** | The heart. 100% unit-testable with no infrastructure | 1 |
| **4** | `intent.gate.ts` in front of the step dispatcher | Now there is something to gate | 0, 3 |
| **5** | Proof record + HMAC | Last, because it records what 0–4 decided | 4 |
| **6** | `@tec/nexus-intent` published through DX | Only after it has governed one real run | 5 |

**Stages 1 and 3 can start today** — they touch nothing that is live, and stage 3 is a
pure function with no dependency on any of this. If the whole programme were cancelled
after stage 3, the cost would be one unused file.

---

## 6 · Blast radius

| Change | Reaches | Risk |
|---|---|---|
| Stage 0 — steps call services | payment · commerce · asset | **Highest.** First time Nexus causes an external effect. Gate it behind a flag, one template |
| Stage 1 — schema | `tec-identity-service` only | Low. Additive; `prisma db push` |
| Stage 3 — delta | nothing | None. Pure function |
| Stage 4 — gate | Nexus runs only | Medium. Fails closed, so a bug **blocks** rather than permits |
| Stage 6 — SDK | any consumer | Deferred until one real run has been governed |

**The asymmetry is deliberate and worth naming:** a bug in this layer refuses a valid
action. It cannot authorize an invalid one, because the gate can only ever *narrow* C-47
and never widen it. That is the correct direction for the failure to point, and it is
what makes the layer safe to build on a live platform.

---

## 7 · What is genuinely novel, stated narrowly

The strategy report is right that the broad ideas are occupied. Filed against `[Assumed]`
— **I have not run a patent search and cannot**; this is an engineering opinion about
which mechanisms are *specific*, which is a precondition for a search being worth paying
for, not a substitute for one.

| Mechanism | My read |
|---|---|
| Intent understood by AI | Occupied. Not worth filing |
| Agent authorization / permissions | Occupied |
| Intent drift detection | Occupied — the report says so and I agree |
| **Delta compared against the human-signed ROOT, not the previous step** | **Specific.** It is what catches five widenings of 30 that no per-step comparison sees |
| **Declared-vs-computed delta disagreement as a first-class misbehaviour signal** | **Specific.** The agent's own report is treated as a claim to be checked, not as input |
| **Per-field constraint origin carried in the object from compile time** | **Specific.** Lineage that is bolted on later is lineage nobody can trust |
| **A gate that can only narrow a pre-existing, independently-enforced constitution** | **Specific, and it is TEC's actual moat.** It only means something because C-47 exists and is enforced in CI. A competitor would have to build the constitution first |

The last row is the strategic point. The defensible thing is not the intent layer. It is
**an intent layer bound to a constitution that was already enforced before there was an
agent to govern** — and that took this platform two years and is written into its CI.

---

## 8 · Honest risks

1. **Stage 0 is the real work, and it is not glamorous.** Wiring Nexus to services is
   plumbing. The temptation is to build the interesting layer first, and §2 is why that
   fails.
2. **A gate with nothing to gate passes every test.** Simulated verification is what let
   the A2U path ship broken. If stage 4 lands before stage 0, it will be green and wrong.
3. **The compiler is where a model will creep back in.** §3.1 is the guard, and it will
   be under pressure the first time a human confirmation feels like friction.
4. **Phase 0.** The platform is still pre-Mainnet-hardening, and a reward campaign on the
   front page still cannot pay a Mainnet user until each of them signs in again. Stages 1
   and 3 cost nothing and block nothing. **Stage 0 is a real allocation decision and
   should be made deliberately, not absorbed.**

---

## 9 · Recommendation

1. **Reframe as Nexus V2** — C-109 §10 Phase 2. No new app, no new service, no ADR fight
   about the name.
2. **Do stage 0 first.** It is chartered, it is the prerequisite, and it is the honest
   bottleneck.
3. **Start stages 1 and 3 in parallel** — zero risk, and stage 3 is where the invention
   actually lives.
4. **Fix the three `Implementation Status` sections** (§4). One hour, removes the
   ambiguity, and it is the kind of drift that compounds.
5. **Commission the prior-art search on §7's four specific mechanisms**, not on "intent
   integrity." A broad search will come back occupied and tell you nothing.
6. **Do not put SYSTEM on the gate's decision path in v0.1** (§1.1). Enforce against
   C-47 directly. SYSTEM becomes the authority source when it has a write path and an
   activation table — which is its own chartered increment, not a dependency to assume.

---

## Related Documents

- `audits/NEXUS_IIC_v0.1_SPEC_2026-09-13.md` — the specification this report grounds
- `C-109___NEXUS_INSTITUTIONAL_CHARTER.md` · `C-115___DX_INSTITUTIONAL_CHARTER.md` ·
  `C-110___SYSTEM_INSTITUTIONAL_CHARTER.md` — the three needing `Implementation Status`
- `C-105___ANALYTICS_INSTITUTIONAL_CHARTER.md` · `C-104___TEC_AI_INSTITUTIONAL_CHARTER.md`
- `C-47_Kernel_Spec_Architecture_Binding.md` — the constitution the gate narrows and
  never widens; §7's moat
- `C-132___SERVICE_EXTRACTION_MODULAR_ARCHITECTURE_POLICY.md` — why this is a module
- `audits/A2U_FIRST_PAYOUT_ROUND_2026-09-13.md` — §3.4, and the evidence for §8.2
