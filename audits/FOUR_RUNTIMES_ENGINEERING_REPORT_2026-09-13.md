# DX · Analytics · Nexus · TEC AI — Engineering Report on the proposed updates

**PLACEHOLDER — no `C-NN` assigned.** Numbering is human authority (`.cursorrules` RULE 6).

**Date:** 2026-09-13
**Truth State:** [Current State] — an assessment of proposals against deployed code.
**Governance State:** [Draft]
**Verification:** [Code Verified], except §6 which says plainly what could not be verified.

**Companion to:** `audits/NEXUS_IIC_ENGINEERING_REPORT_2026-09-13.md`, which established
that of these four, only Nexus is a real engine, and that it does not yet call a service.
That report is not repeated here.

---

## 0 · Verdict in one table

| Proposal | Assessment |
|---|---|
| DX **Capability Registry** enriched with schemas, authority, risk | **Change the target.** The registry already exists **twice** and has **already drifted** (§1). Enriching the wrong copy makes it worse |
| DX **App Builder / generator** | **Solves the wrong problem, and makes the real one harder** (§2). This is the finding I would most want acted on |
| DX **Developer Console** (keys, usage, health) | **Sound.** It is C-115 Phase 1 as chartered. No objection |
| Analytics **Event / Reality / Intelligence layers** | **Sound**, and partly built |
| Analytics **Decision Signals** layer | **This is Alert's charter** (C-111), already implemented with the same fields (§3) |
| Analytics ← Pi Staking as a **signal**, not a VIP grant | **Correct**, and it matches C-128's own rule (§4) |
| Nexus **workflow engine** | **Already built.** See the companion report |
| TEC AI **Information / Recommendation / Action** split | **Correct decomposition.** Action is blocked on the same bottleneck as everything else (§5) |
| The four **bounded responsibilities** | **The strongest part of the report.** Keep it verbatim (§7) |

---

## 1 · The Capability Registry already exists twice, and has already drifted

This is not a risk. It is the current state of `main`.

**`dx/dx.service.ts`**
```ts
cap('payment',        'tec-payment-service',  DxCapStatus.CERTIFIED,
    'Accept Pi (U2A) via the dual-mode flow — createPaymentRecord → createU2APayment.'),
cap('authentication', 'tec-auth-service',     DxCapStatus.CERTIFIED,
    'Hub SSO — usePiAuth() + cookie session; never handle Pi tokens yourself.'),
```

**`system/system.service.ts`**
```ts
cap('payment',        'tec-payment-service',  SystemGovernanceStatus.CERTIFIED,
    'Pi payment lifecycle — outbox + state machine (ADR-004).'),
cap('authentication', 'tec-auth-service',     SystemGovernanceStatus.CERTIFIED,
    'Pi identity + JWT issuance (ADR-002).'),
```

Same five capability ids. **Two hand-maintained seed arrays, two separate Prisma models,
two separate enums** (`DxCapStatus` / `SystemGovernanceStatus`), and descriptions that
already say different things. Nothing keeps them in sync — no shared constant, no test,
no CI check.

C-115 states the intended boundary correctly: *"Capabilities MIRROR the System registry —
presented, never certified here."* **The code does not mirror. It re-types.** That is
**P2 — no rule defined differently in more than one layer** — and it is live today.

> **The proposal would make this worse in the most expensive way.** Adding input schema,
> output schema, authority-required, risk level and intent-compatibility to the DX copy
> gives the drifting duplicate five new fields to drift on — and these are the fields an
> agent would *act* on. A stale description is a bad doc. A stale `authority_required` is
> a security decision made from the wrong copy.

### 1.1 · Where each field actually belongs

There is already an owner for every field the proposal wants. None of them is DX.

| Field | Owner today | Why |
|---|---|---|
| `status` (Designed/Verified/Certified) | **SYSTEM** | C-110/C-94 — SYSTEM certifies, DX distributes |
| `input` / `output` schema | **`@yasser172/tec-sdk`** | C-47 §14: *"Zod schemas: single source of truth for API response types."* `src/api/*Client.ts` already holds them |
| `authority required` | **C-47** — and see §1.2 | Sensitive-operation list + ActorContext rules |
| `risk level` | **SYSTEM** | It is a governance classification, not a doc field |
| `dependencies` | **`architecture/asset-registry.yaml`** | Auto-generated, DAG-guaranteed, already gated |
| `example` · `install` · `guide` | **DX** | This is genuinely DX's, and it is what DX has |

**So the fix is smaller than the proposal, and better:** delete DX's copy of the governed
fields and have DX *read* SYSTEM's registry, exactly as C-115 already says it should.
DX keeps what is truly its own — the install line, the example, the guide.

The platform has solved this exact shape before and the solution is on the shelf:
`manifests/events-catalog.yaml` + `evals/check-events-catalog.sh` — **one machine-readable
registry, one CI gate, sourced from real code.** A capability registry should be the same
artefact, not a second seeded table.

### 1.2 · The one field that has no owner yet

`authority_required` — *"may this actor invoke this capability, at this limit, now?"* —
has **no runtime owner**. SYSTEM is read-only with no write path and no activation table
(companion report §1). C-47 defines the rule; nothing serves it as an answer.

That is the real gap behind both this proposal and NEXUS IIC, and it is worth naming
plainly rather than assigning to a box that cannot answer.

---

## 2 · The App Builder solves the wrong problem

This is the finding I would most want acted on, and it comes entirely from this
platform's own recorded history.

**The premise is that 24 apps will diverge if they each start from their own
architecture.** But they did not each start from their own architecture. **All of them
were cloned from `tec-template-base`**, which already ships SSO, dual-mode payment,
CSRF-in-middleware, PiRuntime, flags, health, legal pages and CI policy guards. Day-1
standardisation is already solved, by a template, and it works.

**They diverged anyway — and not at birth.** From C-02 Session 46:

- **18 apps sat on `@yasser172/tec-ui@^1.1.0`**, a range that can never resolve to a 2.x.
  They were frozen out of the palette **from the day v2.0.0 shipped**, and `npm update`
  did exactly what it was told, forever, and nothing warned.
- The **one Dependabot policy** that fixed 112 unmergeable PRs existed in
  `tec-template-base` the whole time. *"the fleet never back-adopted it"* — it had to be
  hand-copied into 19 repos.
- **15 SSO landings still said `🔷 TEC App`**, the template's placeholder, on the screen
  where a user decides whether to trust the app they just tapped.

> **The fleet's problem is propagation, not generation.** Every one of those is a fix
> that existed, in the template, and could not travel to the apps that were made from it.

A generator makes day 1 marginally better than a template — and **day 400 strictly
worse**, because generated code is a fork the instant it is generated. There is no
`^3.0.0` for scaffolding. When the generator learns something, the 24 apps built by the
old generator do not.

### 2.1 · What to build instead, at a fraction of the cost

| Instead of | Build | Why |
|---|---|---|
| A generator | **A conformance checker** — `npx @tec/dx doctor` | Reads an existing app and reports drift from the current template: dep ranges that cannot resolve, missing CI guards, a placeholder app name, a hand-rolled Pro parser instead of the canonical one. **It works on the 24 apps that already exist**, which a generator never will |
| A generator | **Fleet-wide dependency-range audit in CI** | The `^1.1.0` trap, caught mechanically. Session 46's stated lesson — *"when a shared package takes a major, the consumers' ranges are part of the release"* — as a gate rather than a paragraph |
| A generator | **Keep the template; add `dx update`** | Reports what changed in the template since an app was cloned. Propagation, which is the actual gap |

`scripts/verify-palette.mjs` already exists and is exactly this idea for one concern.
Generalising it is a smaller job than a generator and it pays out on the fleet you have,
not the fleet you will build next.

**If a generator is still wanted later**, it should be the *last* thing DX builds, not
the first — after `doctor` has proven what conformance actually means, in code, against
24 real apps.

---

## 3 · Analytics "Decision Signals" is Alert, already built

The proposed output:

```
Signal:      High payment failure rate
Severity:    Medium
Affected:    Commerce Apps
Recommended: DX capability investigation
```

`alert.service.ts` already stores exactly this shape: `AlertCategory`, `AlertSeverity`,
`app`, `title`, `body`, owner-scoped or global, with a seeded inbox and a detail route.
C-111 gives Alert *"signal collection + aggregation, classification (category +
severity), the unified inbox, escalation routing."*

**The proposal is right that the signal should exist. It is in the wrong runtime.**

```
Analytics  computes the finding          "payment failures are 4× baseline in Commerce"
   ↓ emits an event (C-70)
Alert      classifies + routes it        severity · affected · who is told
```

That split is not pedantry — it is the difference between one inbox and two. The platform
already learned this with the C-96 dual-poller (NEW-K): two components asking the same
question independently is how a user gets contradictory answers from one system.

**Keep** the Event, Reality and Intelligence layers in Analytics — those are its charter,
and `scoring.service.ts` already does the third. **Emit** the fourth to Alert.

### 3.1 · The Event Layer is half-built already

The proposal's unified event schema largely exists: `manifests/events-catalog.yaml`,
13 events, code-sourced, with a CI gate, `eventId` on every event, and consumer liveness
monitored by `stream-health.service.ts`. The proposed new names (`AI_ACTION_PROPOSED`,
`CAPABILITY_USED`, `MISSION_COMPLETED`) should be **added to that catalog under C-70
naming** — `ai.action.proposed.v1` — not defined as a parallel vocabulary.

The catalog has been through three corrections this year (a phantom event with no
producer, a legacy rename, an unversioned pair). It is the platform's most carefully
maintained manifest. New events belong in it.

---

## 4 · Staking as a signal, not a grant — correct, and it is already the rule

```
Pi Staking → effectiveStake → Analytics signal → (one input among many)
```

rather than

```
effectiveStake → VIP tier
```

**This matches C-128 exactly**, which already states that VIP grants *eligibility* and the
owning app enforces *value* (P5), and that earned tiers are *"unlocked by recognition or
verification elsewhere."* It also keeps Invariant #8 intact: reading a stake is not
custody, and nothing here moves Pi.

One engineering note: `effectiveStake` is a **third-party, eventually-available** number.
Per C-47's consistency model it must never sit on a financial decision path. As a
reputation input, weighted alongside others, it is fine. As a gate on a payment, it is not.

---

## 5 · TEC AI — the three modes are right, and Action has one bottleneck

Information / Recommendation / Action is the correct decomposition, and the boundary is
already enforced in code today: `api/ai/chat/route.ts` says *"Nothing executes on these —
the AI guides, it never acts (C-104 §4)."*

**Information and Recommendation can be improved now.** They need better context, not new
architecture, and the signed context token (`lib/ai/context-token.ts`) is the right
mechanism — it already binds context to a verified user before any provider is called.

**Action cannot be built yet**, and not for a reason about AI:

```
TEC AI Action  →  needs a gate
                     ↓
             gate needs a side effect to gate
                     ↓
        Nexus steps do not call services yet
```

Same stage-0 bottleneck as NEXUS IIC. Any Action-mode work before Nexus is wired will be
verified against simulated effects — the exact condition under which the A2U payout path
shipped unable to pay anyone.

**One addition worth making now, cheaply:** when TEC AI produces a *Recommendation*, have
it emit the structured object it would later hand to the gate — and do nothing with it.
Zero risk, and after a month you have real data on what intents users actually express,
which is the input the compiler's closed objective set (`NEXUS_IIC_v0.1_SPEC` §4.1) has
to be designed from. Designing that set from imagination is the avoidable mistake here.

---

## 6 · What I could not verify

The report leans repeatedly on new Pi platform capabilities — **App-specific Staking
(whitelisted), Local/App Storage, File & Video Sharing, Pi Sign-in outside Pi Browser,
PiVerify**. I have no way to check Pi's developer documentation from this environment, so
every one of them is `[Assumed]` in this report and none should enter a capability
registry on my word.

That is not a formality. **A registry whose entries are labelled CERTIFIED is a trust
signal**, and the platform has already been burned twice this month by treating an
unverified external claim as fact: the phantom `wallet.update` event that had no producer,
and this week's `payment_not_found` theory built on a mistyped identifier. The rule that
came out of both:

> A capability enters the registry as `DESIGNED` on documentation, and reaches `VERIFIED`
> only when something in this repo has called it and kept the response.

That rule alone makes the registry worth having, and it costs nothing to adopt now.

---

## 7 · The part to keep verbatim

| Runtime | Question it answers |
|---|---|
| TEC AI | What do you want? |
| Nexus | How do we do it? |
| Analytics | What is happening? |
| DX | How do we build it? |

This is the strongest paragraph in the report and it survives every check I made. The
codebase's own module headers independently arrived at the same boundaries — DX
*"DISTRIBUTES; it does NOT certify"*, SYSTEM *"DEFINES + audits; it does not enforce"*,
Alert *"PRESENTS + routes; it does NOT resolve"*, Analytics *"presents; never re-derives
transaction truth."* Four different authors, one boundary discipline, and it is why this
platform can absorb a layer like NEXUS IIC at all.

The accompanying rule — *"Same Foundation ≠ Same Business"* — is C-132 Modules-First
stated in product language. Worth putting in a charter in exactly those words.

---

## 8 · Sequencing

Four platform-layer programmes proposed at once, during Phase 0, on a platform whose
front page still advertises a reward it cannot pay until each user signs in again.
Stated once, and then the ordering:

| Order | Work | Cost | Unblocks |
|---|---|---|---|
| **1** | Collapse the duplicate capability registry (§1) | Small | Everything that reads a capability, including IIC |
| **2** | `dx doctor` — conformance over generation (§2) | Small | The 24 apps you already have |
| **3** | Wire Nexus steps to services (companion §2) | Medium | The gate · TEC AI Action · real workflows |
| **4** | Analytics → Alert signal edge (§3) | Small | The fourth layer, in the right runtime |
| **5** | TEC AI emits recommendation intents, unused (§5) | Tiny | The compiler's objective set, from evidence |
| **6** | Developer Console (keys, usage, health) | Medium | C-115 Phase 1 as chartered |
| **7** | NEXUS IIC stages 1 + 3 | Small | The invention, and both are pure/additive |

**1, 2, 4 and 5 are each under a week and none of them blocks another.** 3 is the real
allocation decision. A generator does not appear on this list at all, and §2 is why.

---

## Related Documents

- `audits/NEXUS_IIC_ENGINEERING_REPORT_2026-09-13.md` — the five-runtime inventory; §2
  there is the stage-0 bottleneck this report keeps referring to
- `audits/NEXUS_IIC_v0.1_SPEC_2026-09-13.md` — §4.1's closed objective set, which §5 here
  proposes to derive from evidence rather than imagination
- `C-115___DX_INSTITUTIONAL_CHARTER.md` — *"Capabilities MIRROR the System registry"*, the
  boundary §1 shows the code does not hold
- `C-110___SYSTEM_INSTITUTIONAL_CHARTER.md` · `C-94` — where capability status belongs
- `C-111___ALERT_INSTITUTIONAL_CHARTER.md` — §3, the runtime that already owns
  classification and routing
- `C-105___ANALYTICS_INSTITUTIONAL_CHARTER.md` · `C-104___TEC_AI_INSTITUTIONAL_CHARTER.md`
- `C-128___VIP_PREMIUM_EXPERIENCE_RUNTIME.md` — §4, eligibility vs value (P5)
- `C-132___SERVICE_EXTRACTION_MODULAR_ARCHITECTURE_POLICY.md` — §7's *"Same Foundation ≠
  Same Business"*
- `C-02___CURRENT_STATE_.md` **Session 46** — §2's entire evidence base: the caret trap,
  the 112 PRs, the placeholder app name
