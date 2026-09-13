# NEXUS IIC v0.1 — Intent Integrity Compiler

**PLACEHOLDER — no `C-NN` assigned.** Numbering is human authority (`.cursorrules`
RULE 6). This is a specification proposal, not yet a constitutional asset.

**Date:** 2026-09-13
**Truth State:** [Planned State] — §2 is `[Code Verified]` (it already runs); §4–§9 are
the proposal.
**Governance State:** [Draft] — needs an ADR before any of §4–§9 is built.
**Verification:** [Code Verified] for every claim about what TEC already has. Each is a
file path you can open.

---

## 0 · The finding that should reshape the plan

The proposal describes a pipeline:

```
Human → Intent → Authorization → AI Agent → Trust Verification → Execution → Proof
```

**The right-hand half of that is already built and running in this platform.** Not
chartered, not planned — merged, deployed, with a Redis consumer in production.

`tec-identity-service/src/modules/nexus/nexus.service.ts` is a persisted saga engine:

| Proposal calls it | TEC already has | Where |
|---|---|---|
| Multi-agent graph | `NexusRun` + ordered `NexusStep[]`, each naming its owning service | `nexus.service.ts` · `templates.ts` |
| Execution gate | `advance()` — a step runs only from `PENDING`/`RUNNING`, at the exact cursor | `nexus.service.ts:71` |
| Rollback on drift | `fail()` — compensations replayed in **reverse**, run ends `COMPENSATED` | `nexus.service.ts:110` |
| Human-in-the-loop | A U2A payment step **halts** the run at `AWAITING_PAYMENT`. The engine never fakes a payment | `nexus.service.ts:85` |
| Resume after the human acts | `payment.completed.v1` consumer, state-guarded and idempotent | `nexus.consumer.ts` |
| Proof | `AuditLog` + the step history; Invariant #4 makes it non-optional | C-47 |
| Deterministic verifier outside the model | **C-47 policy precedence + P6 fail-closed, enforced in Policy CI** | `ci.yml` policy-check |

The last row is the one worth pausing on. The proposal's central architectural claim —
*"the LLM may interpret, plan and propose; it must never authorize, verify or execute"* —
is not a thing to invent here. **It is the platform's constitution, written down in C-47
and enforced by a CI job that fails a build.** Most teams pitching an agent-trust layer
are proposing to build that. This one has it, and has had it since before there was an
agent to govern.

> So the honest position is not *"here is a new layer to add."* It is:
> **the platform is roughly 60% of the way into this design already, and the missing 40%
> is the part that is actually novel.**

That is better news than it sounds, in two directions. Architecturally it means a v0.1
is an increment, not a programme. And for the patent question it means the claim can be
narrow and specific — which is the only kind worth filing — instead of the broad
*"AI understands user intent"* that certainly has prior art.

### On the name

There is no collision to resolve. **C-109 Nexus is already chartered as exactly this
runtime** — *"What should happen next?"*, saga pattern, ActorContext propagated from the
original human actor, `REJECT` on unknown workflow type or missing actor context. The
engine above is its §5. So:

> **NEXUS IIC is Nexus V2, not a new app.** It is C-109 §10 Phase 2 with an intent
> object at the front. No new service (C-132 Modules-First: no T1–T4 trigger exists),
> no 25th app, no ADR fight about what to call it.

---

## 1 · What is genuinely missing

Six things. Each is small; together they are the invention.

| # | Missing | Why it matters | Today |
|---|---|---|---|
| 1 | **The Intent Object** | A run starts from a `templateId` the user picked. Nothing records *what the human actually authorized* — no budget, no exclusions, no expiry | `startRun(owner, templateId)` |
| 2 | **Intent Delta** | Steps advance by cursor. Nothing compares a proposed action against the original intent | `advance()` just increments |
| 3 | **Constraint lineage** | `correlationId` traces the *request*. Nothing traces where a *constraint* came from | C-47 ActorContext |
| 4 | **Authority limits as data** | There is a global payout ceiling (`a2uCeiling`). There is no per-intent budget | `pi-a2u.ts` |
| 5 | **Proof as an object** | Audit rows exist and are queryable. There is no portable, signed artefact the human can hold | `AuditLog` |
| 6 | **The compiler** | Natural language → a constraint set. Nothing does this | — |

---

## 2 · The design rule this platform earned the hard way

This specification exists in the same week the platform discovered that **its own reward
campaign could not pay anybody** — and had never been able to, on Mainnet either
(`audits/A2U_FIRST_PAYOUT_ROUND_2026-09-13.md`). Four production defects, found only by
trying, three of which would have waited for the first real Mainnet reward to announce
themselves.

Every one of the four was the same shape:

> **A failure that discarded its own reason.**

Pi's `error_message` never reached a log. Horizon's `result_codes` never reached a
caller. A refused payout wrote nothing to the row and nothing to the claimant's screen.
Each passed code review, because a generic error message is not a failing test.

That is not a digression. It is the **design constraint for this entire specification**,
and it produces one rule that everything below obeys:

> **R-0 — A verdict must carry its reason, and a refusal must name the constraint that
> refused it.** `BLOCKED` is not an output. `BLOCKED: budget.hard, Δ = +40π, from
> Human@v1` is an output. An integrity layer that says only *no* is a layer whose
> operators will learn to bypass it — the same way a CI gate that fails on a clean tree
> teaches people to ignore CI.

A second rule follows from the same week:

> **R-1 — Distinguish "no" from "I do not understand the answer."** The payout tooling
> returns `[]` for *"Pi is holding nothing"* and `null` for *"Pi answered in a shape I do
> not recognise."* Collapsing those two would let an unfamiliar answer read as a clear
> queue. In the verifier, the equivalent collapse is fatal: an unparseable delta must
> never evaluate as a compatible one.

---

## 3 · Scope of v0.1

**In:** the Intent Object, the compiler that produces it, the delta, the deterministic
verifier, the execution gate, and a proof record. One template, end to end.

**Out, deliberately:**

- **No blockchain.** The proposal says so, and it is right. The proof needs to be
  *verifiable*, not *decentralized*. A signed record in the audit log is verifiable today.
- **No new service.** C-132 Modules-First — a new service needs a documented T1–T4
  production trigger, and none exists. This is a module in `tec-identity-service`, beside
  the engine it extends.
- **No new custodian.** Invariant #8 — `tec-payment-service` remains the only thing that
  holds Pi. The intent layer *authorizes*; it never *moves*.
- **No autonomous spend.** v0.1 keeps the existing halt at every U2A step. An intent may
  narrow what a human is asked to approve; it may not remove the asking.

---

## 4 · The Intent Object

The proposal's Intent Genome, with one change: **every field carries its own origin**,
because lineage that is bolted on later is lineage nobody can trust.

```jsonc
{
  "intent_id":      "uuid",
  "version":        1,
  "owner":          "piUsername",          // from the session, never the body (P6)
  "objective":      "find_product",        // a CLOSED set, not free text — see §4.1
  "entities":       { "category": "laptop" },

  "constraints": [
    { "key": "budget_pi",   "op": "lte", "value": 250, "class": "hard",
      "origin": { "actor": "human", "at": "...", "quote": "under 250 pi" } },
    { "key": "seller_trust","op": "gte", "value": "zone_verified", "class": "hard",
      "origin": { "actor": "human", "at": "...", "quote": "no untrusted sellers" } }
  ],

  "preferences":    [ { "key": "delivery_days", "op": "lte", "value": 7, "weight": 0.5 } ],
  "exclusions":     [ "auction", "pre_order" ],

  "authority": {
    "max_total_pi":      250,
    "max_single_pi":     250,
    "services":          ["tec-commerce-service", "tec-payment-service"],
    "requires_human_at": ["payment"]        // v0.1: always non-empty
  },

  "temporal":  { "created_at": "...", "expires_at": "..." },
  "risk":      { "max_counterparties": 1, "reversible_only": true },

  "fingerprint": "sha256(canonical(objective, entities, constraints, exclusions, authority))"
}
```

### 4.1 · Why `objective` is a closed set

A free-text objective cannot be compared between versions, so drift on the *goal* — the
one thing that must never drift — becomes unmeasurable. A closed set makes `Δobjective`
a boolean, and a boolean is something a deterministic gate can act on.

This is the same reasoning that put a **LADDER** on Life's skills instead of a score out
of ten (C-106 slice 4), and a **CLOSED set** on Life's intent-signal kinds (slice 6). The
platform has made this call twice already and both times it was right.

### 4.2 · The fingerprint is over the *binding* fields only

Preferences are excluded. A preference that shifts is not drift — it is an agent doing
its job. A constraint, an exclusion, an authority limit or the objective moving **is**
drift, and the fingerprint is what makes that detectable without trusting anyone's report.

---

## 5 · Intent Delta, and what makes it verifiable

Each agent submits `ACTION + INTENT_DELTA`. **The delta is a claim, not evidence.** The
verifier recomputes it from `Iₙ₋₁` and `Iₙ` and compares. An agent whose declared delta
disagrees with the computed one is not merely wrong — it is the single strongest
misbehaviour signal in the system, and it is recorded as such.

```
Δ = {
  objective:   CRITICAL if changed, else 0
  constraint:  CRITICAL if a hard constraint is loosened, removed, or re-classed soft
               INFO     if a hard constraint is TIGHTENED
  exclusion:   CRITICAL if removed;  INFO if added
  authority:   CRITICAL if any limit is raised;  INFO if lowered
  preference:  INFO always
  temporal:    CRITICAL if expiry extended
}
```

**Asymmetry is the whole point.** Narrowing is always allowed; widening never is. An
agent may spend less, exclude more, or finish sooner without asking. It may not spend
more, trust a wider set, or buy itself time. Every CRITICAL is `BLOCK +
RE-AUTHORIZATION`, and re-authorization means a **new human signature on a new intent
version** — not an agent's assertion that it is fine.

> **The failure mode this closes is gradual.** No single step widens the budget from 250
> to 400. Five steps widen it by 30 each, and every one looks reasonable beside the step
> before it. Comparing against `I₁` rather than `Iₙ₋₁` is what makes that visible — so
> **the verifier always evaluates against the human-signed root, never against the
> previous agent's output.**

---

## 6 · The Execution Gate

```
                    proposed action
                          │
       ┌──────────────────┼──────────────────┐
       ↓                  ↓                  ↓
  Intent            Authority          Constraint
  compatibility     within limits      integrity
  (Δ has no         (service, amount,  (lineage intact,
   CRITICAL)         human-required)    no orphan)
       └──────────────────┼──────────────────┘
                          ↓
                   Risk policy (C-47)
                          ↓
                 ┌────────┴────────┐
              ALLOW              DENY
                 │                 │
        execute + proof    reason + constraint
                           + recompile path
```

Four properties, each of which is a rule the platform already holds:

1. **Deterministic.** No model call in the gate. Given the same intent and the same
   action, the same verdict, forever. Testable.
2. **Fail closed.** An unparseable delta, an unknown objective, a missing origin → DENY.
   P6, and R-1 above.
3. **It cannot be the last word.** The gate sits *above* C-47, never in place of it.
   Policy precedence is unchanged: an intent that permits something the Kernel forbids
   is refused by the Kernel. **The intent layer can only ever narrow.**
4. **Every verdict names its reason.** R-0.

---

## 7 · Proof

```jsonc
{
  "proof_id":        "uuid",
  "intent_id":       "...",
  "intent_version":  1,
  "fingerprint":     "sha256:...",
  "run_id":          "nexus run id",
  "decisions":       [ { "step": 0, "verdict": "ALLOW", "delta": {...}, "at": "..." } ],
  "external_effects":[ { "service": "tec-payment-service", "ref": "payment_id", "txid": "..." } ],
  "human_approvals": [ { "at": "...", "for_step": 1, "shown": "250 π to X" } ],
  "signature":       "hmac(INTENT_PROOF_SECRET, canonical(above))"
}
```

`shown` is the field that matters and the one that is easy to leave out. A proof that
records *what was approved* but not *what the human was looking at when they approved it*
cannot settle the only dispute that ever arises. This is the same lesson as the campaign's
`posted_address` — *"a payout destination that a person never saw is a payout nobody can
catch being wrong."*

HMAC, not a chain. The verifier is the platform; the audience is the platform's own
users and its own operators. A signature they can check is proof. If an external party
ever needs to verify without trusting TEC, that is when this becomes a public commitment
— and that is a v2 decision with a real trigger, not a v0.1 default.

---

## 8 · MVP — one template, end to end

Not the travel example. **`checkout-saga`**, because it already exists in `templates.ts`,
already halts at a real U2A payment, and already compensates in reverse. The intent layer
can be added to a working saga instead of a hypothetical one.

```
/tec-identity-service/src/modules/intent
   intent.types.ts        the object, the delta, the verdict
   intent.compiler.ts     text → Intent Object   (rules first; a model later)
   intent.delta.ts        pure: (I₁, Iₙ) → Δ     ← the heart, 100% unit-tested
   intent.verifier.ts     pure: (I₁, Δ, action) → ALLOW | DENY + reason
   intent.gate.ts         verifier + C-47 authority + risk → decision
   intent.proof.ts        record + sign
   intent.service.ts      binds an Intent to a NexusRun
```

**The compiler is rules-first, and that is not a shortcut.** A model in the compiler on
day one makes every subsequent bug ambiguous — was the constraint wrong, or was the
extraction wrong? A deterministic compiler over a closed objective set and a fixed
constraint vocabulary is testable, and it establishes the schema the model must later
produce. The model goes in when the schema is proven, behind the same gate as everything
else: **it proposes an Intent Object; the human confirms it before it becomes `v1`.**

### Acceptance — v0.1 is done when

1. A `checkout-saga` run carries an `intent_id`, and `startRun` refuses without one.
2. A step that would exceed `authority.max_total_pi` is **blocked**, and the block names
   the constraint, the delta, and its origin.
3. Five steps that each widen the budget by 30 are blocked at the one that crosses the
   root limit — proving §5's compare-against-root rule with a test, not a diagram.
4. An agent whose declared delta disagrees with the computed delta is blocked and the
   disagreement is recorded.
5. A completed run emits a proof whose signature verifies and whose `shown` matches what
   the Hub displayed.
6. An expired intent blocks. A tightened constraint does not.

---

## 9 · Threat model (v0.1)

| Threat | Control |
|---|---|
| Agent widens a constraint | Δ vs the **human-signed root**, not the previous step (§5) |
| Agent lies in its declared delta | Verifier recomputes; disagreement is blocked **and recorded** |
| Gradual drift below any single threshold | Same as above — root comparison is the answer to both |
| Compromised agent invents an intent | `intent_id` binds to `owner` from the session; a `v1` needs a human signature |
| Replay of an old intent | `expires_at` + version monotonicity; the run holds one `intent_id` |
| Proof forged after the fact | HMAC over canonical form; `AuditLog` is append-only (Invariant #5) |
| Intent permits what the Kernel forbids | Policy precedence — the intent layer can only narrow (§6.3) |
| **A model in the compiler is prompt-injected** | The compiler does not authorize. Its output is `v0` until a human confirms it into `v1`. The gate reads `v1` |

---

## 10 · What this does **not** claim

- **Not novelty.** Intent-based authorization, intent chains and intent-drift detection
  are live research areas with filings against them. Nothing here should be described as
  unprecedented without a professional prior-art search — and the honest reading is that
  the *general* idea is already occupied. If anything here is defensible it is the
  specific mechanism: **compare-against-root delta + per-field constraint origin +
  declared-vs-computed delta disagreement as a signal + a deterministic gate that can
  only narrow a pre-existing constitutional policy.** That is narrow enough to search
  properly, which is the point.
- **Not [Runtime Verified].** §2's inventory is code-verified. Everything from §4 on is
  a proposal that has not been built.
- **Not a Phase-0 exception.** C-109 §10 Phase 2 already chartered this work. If it
  proceeds it proceeds as that increment, or it needs an ADR saying why not.

---

## 11 · The one caution worth stating once

The payout path proved fragile **this week** — four defects, and a reward campaign that
still cannot pay a Mainnet user until each of them signs in again. An intent-integrity
layer sits *above* execution. Building it while the floor below is still being repaired
is a real risk, and the mitigation is not to delay: it is §8's choice of `checkout-saga`,
a path that already works, and §3's refusal to add a custodian, a service, or an
autonomous spend.

Stated once, and then the recommendation stands: **build it, as Nexus V2, on the engine
that is already running.**

---

## Related Documents

- `C-109___NEXUS_INSTITUTIONAL_CHARTER.md` — the charter this is Phase 2 of; §5 saga,
  §6 fail-closed, P1-1 ActorContext propagated from the original human actor
- `C-47_Kernel_Spec_Architecture_Binding.md` — the deterministic verification layer that
  already exists: policy precedence, P6, Invariants #4/#5/#8, Forbidden Behavior #6
- `C-132___SERVICE_EXTRACTION_MODULAR_ARCHITECTURE_POLICY.md` — why this is a module and
  not a 12th service
- `C-104___TEC_AI_INSTITUTIONAL_CHARTER.md` — the reasoning layer that would produce
  intents; it proposes, it does not authorize
- `C-70___EVENT_GOVERNANCE_SPEC.md` — `eventId`, at-least-once, idempotent consumers;
  what the run's resume path already obeys
- `audits/A2U_FIRST_PAYOUT_ROUND_2026-09-13.md` — where R-0 and R-1 come from
