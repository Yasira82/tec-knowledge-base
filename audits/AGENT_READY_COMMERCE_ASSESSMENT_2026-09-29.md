# Agent-Ready Commerce & Pi-wide Discovery — Assessment

**PLACEHOLDER: no `C-NN` has been assigned.** Numbering is a human decision (`.cursorrules` RULE 6).
This file records a strategic proposal and checks it against the code. It is not a constitutional asset.

**Date:** 2026-09-29
**Truth State:**
- §2 is `[Current State]`: an inventory of what is already built.
- The rest is `[Future Vision]`: the proposal and a recommendation.

**Governance State:** `[Draft]`. Building anything beyond §6 needs an ADR (C-64).

**Verification:**
- `[Code Verified]` for each claim about TEC. Each cites a path on `tec-core-backend` main (`a8567e5`) or `tec-app` main.
- `[Documentation Verified]` for AP2 and ACP (sources are listed in §4).
- `[Assumed]` for anything marked as such.

**Builds on:** `NEXUS_IIC_v0.1_SPEC_2026-09-13.md` · `NEXUS_IIC_ENGINEERING_REPORT_2026-09-13.md` · `FOUR_RUNTIMES_BUILD_ORDER_2026-09-13.md`

---

## 0 · The proposal, as the owner brought it

The owner developed the proposal in a separate conversation and brought it here on 2026-09-29. Condensed:

1. **Agent-Ready Commerce Infrastructure.** Commerce that a human and an AI agent can both use, under the same rules and with different, verifiable authority.
   - The pipeline: Intent → Authorization → Discover → Evaluate → Select → Order → Pay → Execute → Proof.
   - Commerce capabilities are machine-readable primitives: `SearchProducts` · `CompareProducts` · `CheckAvailability` · `CreateOrder` · `RequestPayment` · `TrackOrder`.
   - Each primitive declares its input, output, authority, risk, version, owner and certification.
2. **Division of roles.**

   | Role | Owner |
   |---|---|
   | Understands the human | TEC AI |
   | Protects the intent | NEXUS IIC |
   | Orchestrates | Nexus |
   | Builds and distributes the capabilities | DX |
   | Governs authority | SYSTEM |
   | Owns products and orders | Commerce |
   | Observes | Analytics |

   Commerce keeps its sovereignty. The shared layers live in Core, Nexus and SYSTEM, not inside Commerce.
3. **Guardrails outside the model.**
   - Proposal of 52,000 against a budget of ≤ 50,000 → `Δbudget = CRITICAL` → `BLOCK`, or ask the human to re-authorize.
   - Additional controls: human approval above a threshold, a kill switch that revokes an agent's authority, and an audit chain that ends in an Execution Proof.
   - Escrow stays out of the MVP.
4. **Pi Network-wide, not TEC-only.**
   - Nexus becomes a discovery layer over all Pi apps. An app advertises itself through a capability manifest, and Nexus never owns that app's data.
   - The scope is everything discoverable: apps, services, commerce, content, communities, developers, opportunities.
   - Discovery is part of execution. Example: "the cheapest flight to Dubai next week" becomes discover → compare → pick → authorize → book → proof.
5. **Explorer and Nexus are separate layers.**
   - Explorer is *human* discovery: "what exists?"
   - Nexus is *machine* discovery: "who can do this, and how?"
   - Explorer can use Nexus as its engine.
6. **Pi Flash.** Time-limited, discounted offers under 100 π, answering the "Pi needs to move" problem that other Pi marketplaces are working on.
   - Built as a feature across Commerce, Ecommerce, Explorer and TEC AI, not as a new app.
   - TEC AI surfaces a matching offer and its deadline.

---

## 1 · Verdict

**The direction is sound.** The best idea in it is the constraint check that runs outside the model.

Three facts about Pi, and one fact about the market, change what can be built. They are covered in §3 and §4.

Most of the integrity machinery the proposal asks for **already exists** in `tec-identity-service` (§2). The honest description of the programme is therefore:

- build the two missing pieces, the compiler and the discovery surface;
- measure one number;
- only then widen the scope.

---

## 2 · What already exists `[Code Verified]`

| Proposal names it | Already built | Where |
|---|---|---|
| Orchestrator | Nexus saga engine: `NexusRun` + ordered steps, compensation in reverse, halt at a U2A payment, idempotent resume from `payment.completed.v1` | `tec-identity-service/src/modules/nexus/*` |
| Commerce workflow | `checkout-saga` template: order → payment → confirm | `nexus/templates.ts:69` |
| Intent Object | `Intent` model; a revision is a new row; a DRAFT authorizes nothing | `modules/intent/intent.service.ts` · #316 |
| Intent Delta | Pure function, compared against the human-signed **root** rather than the previous step | `modules/intent/intent.delta.ts` · #316 |
| Execution Gate | Runs **before** the payment halt; checks expiry per step | `modules/intent/intent.gate.ts` · `nexus.service.ts:116` · #316 |
| Execution Proof | HMAC proof. Refuses to build a proof without `shown` (what the human was looking at when they approved) | `modules/intent/intent.proof.ts` · #325 |
| Human discovery index | Explorer listings: search with an Arabic normalizer on both write and read, trust-first ranking, owner-scoped writes | `modules/explorer/*` (`GET identity/explorer/search`) |
| Intent signals from chat | TEC AI emits unused recommendation intents on every user turn | tec-core-backend #315 · tec-app #236 |
| Advisory interface | TEC AI chat. Its own comment says "the AI guides, it never acts" | `tec-frontend/src/app/api/ai/chat/route.ts` |

**Still missing:**
- **4.3, the rules-first compiler** (text → Intent `v0`, which the human confirms as `v1`). It is still parked in the build order.
- **A machine-readable capability surface** that an agent can call.
- **Anything outside TEC.**

> Correction to the build order's STATUS table: step **4.5 (Proof + HMAC)** is marked ☐.
> It was merged as tec-core-backend #325. That table is updated in the same change as this file.

---

## 3 · Three facts about Pi that reshape the design

### 3.1 · On Pi, an agent cannot pay

- Every U2A payment is approved by the user in the Pi wallet. There is no API that lets a third party sign on the user's behalf.
- "Delegated purchase authority", "auto-buy under X" and the "≤ 1,000 automatic" tier therefore **cannot exist on Pi**.
- The consequence is good news. Pi enforces human-in-the-loop for free, and IIC v0.1 already refused autonomous spend (spec §3).
- The Execution Gate reduces to one job: **stop a proposal that does not match the intent before the wallet opens.**
- This is exactly where #316 placed it.

### 3.2 · TEC cannot execute inside another Pi app

- A Pi payment belongs to the app that created it, under that app's API key and that app's per-app `uid`. TEC's own A2U work proved the `uid` is per app (C-02, campaign row).
- Across external Pi apps, "execution" can only mean a **handoff**: a deep link into their app, where the user pays that app directly.
- A TEC proof can cover what the user was shown and chose. It cannot cover the external payment.

### 3.3 · Pi-wide discovery depends on other apps opting in

- A capability manifest works only if external apps publish one. They will publish once they see traffic arriving from it, and not before.
- Until then the only sources are:
  - TEC's own apps;
  - public listing information, which Explorer may index only as public business info (C-108 §6).
- A protocol does not bring developers; users do. Per C-02 there are **effectively no external paying users yet**.

---

## 4 · The novelty claim

"Agent commerce" with intent-bound authority is already an occupied, public space `[Documentation Verified]`:

- **AP2 (Agent Payments Protocol)** from Google, with Coinbase and more than 60 partners. It chains signed mandates:
  - an **Intent Mandate** (price cap, time window, merchant allowlist);
  - a **Cart Mandate** (a specific cart at a specific price);
  - a Payment Mandate.
  
  This is the same shape as Intent → Delta → Gate.
- **ACP (Agentic Commerce Protocol)** from OpenAI and Stripe. It standardizes discovery, checkout and payment between agents and merchants, and powers Instant Checkout in ChatGPT.

So the general concept is not new. What can be distinctive is narrow:
- **the application to Pi**, where human approval is structural;
- the specific mechanism already named in IIC spec §10: compare-against-root, per-field constraint origin, declared-vs-computed delta disagreement as a signal, and a gate that can only narrow C-47.

Nothing here should be called an invention without a professional prior-art search. Read AP2 first.

Sources: [Google Cloud — Announcing AP2](https://cloud.google.com/blog/products/ai-machine-learning/announcing-agents-to-payments-ap2-protocol) · [Stripe — Agentic Commerce Protocol](https://docs.stripe.com/agentic-commerce/acp) · [ACP spec on GitHub](https://github.com/agentic-commerce-protocol/agentic-commerce-protocol)

---

## 5 · Placement, if it proceeds

- **No 25th app. No new service.** C-132 (ADR-011) Modules-First applies, and no T1–T4 trigger exists.
- **Nexus + IIC:** NEXUS IIC is Nexus V2 (C-109 §10 Phase 2). Discovery is a Nexus capability.
- **Explorer:** remains the human surface. It may call the same search.
- **Pi Flash:** a field set on existing listings and products, meaning price, discount and `ends_at`. It lives in Commerce and Explorer.
  - Featured and flash visibility may be sold.
  - Verification may not (C-108 §7, C-120 §7).
  - The ranking order stays: trust first, then promotion.
- **DX:** publishes the capability schema once there is a capability worth publishing. Today DX is a read-only catalog (IIC engineering report §1).
- **SYSTEM:** remains read-only. Authority for v1 is the confirmed Intent, not a SYSTEM write path.

---

## 6 · Recommended smallest proof

This runs inside TEC only, on Commerce only, and each step reuses what §2 lists.

1. **Compiler (4.3), rules-first.** A sentence becomes `{category, max_total_pi, trusted_only, expires_at}` as `v0`. The human confirms it, and it becomes `v1`.
2. **Search.** Explorer and Commerce return **three** options, each with a one-line reason, trust first.
3. **Start the run.** Picking an option starts `checkout-saga` with the `intent_id`. The gate checks the *current* price against the root before the payment halt.
4. **Pay.** The normal Mode 1 or Mode 2 payment. The wallet signature is the human approval.
5. **Prove.** The proof records `shown` and ties intent → order → payment.

**The one number:** the share of confirmed intents that end in a completed payment.
- If it is near zero, Pi-wide discovery is not the next problem.
- If it is not, the next step is a published capability manifest that one external Pi app agrees to try.

**Deliberately out:**
- autonomous spend;
- escrow;
- a Pi-wide crawler;
- agent-to-agent negotiation;
- any external app before one TEC path is measured.

---

## 7 · Open decisions for the owner

1. Is §6 the next build, or does it wait behind the campaign and Portal work (C-02 rows 2 and 13)?
2. Should an ADR name "Nexus Universal Discovery" as a Nexus capability, so that it never becomes a new app?
3. Should Pi Flash ship first, on its own, as the lever that moves Pi? It needs no AI.

---

## Related Documents

- `C-104___TEC_AI_INSTITUTIONAL_CHARTER.md`: TEC AI proposes and does not execute
- `C-108___EXPLORER_INSTITUTIONAL_CHARTER.md`: the human discovery layer; §6 privacy; §7 trust cannot be bought
- `C-109___NEXUS_INSTITUTIONAL_CHARTER.md`: saga, fail-closed; §10 Phase 2
- `C-115___DX_INSTITUTIONAL_CHARTER.md`: capability distribution
- `C-132___SERVICE_EXTRACTION_MODULAR_ARCHITECTURE_POLICY.md`: modules first
- `audits/NEXUS_IIC_v0.1_SPEC_2026-09-13.md`: the integrity layer this proposal rests on
- `audits/FOUR_RUNTIMES_BUILD_ORDER_2026-09-13.md`: the execution record (4.3 is still open)
