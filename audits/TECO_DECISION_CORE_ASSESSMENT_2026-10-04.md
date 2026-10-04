# TECO Decision Core and the Decision Platform map — assessed for TEC

**Date:** 2026-10-04 · **Session:** 56s
**Truth State:** [Current State] for what the two archives contain · [Future Vision] for TECO itself
**Governance State:** [Governance Approved] — the owner's decisions recorded in §3
**Verification:** [Documentation Verified] — both archives read in full; neither is in a TEC repository

---

## 1. What the owner brought

| Archive | What it is | What exists |
|---|---|---|
| `TECO_CURRENT_V0.1` | A decision product: Intent → Goal → Evidence → Decision, hero case "buy a used car in Egypt", on a domain-agnostic core (`@decision-core/*`) | Frozen constants (three Golden Rules, five evidence statuses, candidate status tiers, coverage thresholds), a frozen `source-evidence` schema, a draft `decision-input` schema, and a dependency-cruiser rule that keeps the core free of HTTP, DB, UI and LLM imports. **The decision engine, scoring and evidence packages are empty (`TODO`).** One deployable. |
| `DECISION_PLATFORM_MASTER` | A target map of **69 repositories** (foundation, hosting, identity, AI, decision, execution, UI, developer, operations, business, governance) | 69 two-line placeholder READMEs. No code. Its own map says it "should not be expanded into all master repositories prematurely". |

## 2. Assessment

- **TECO V0.1 is right-sized.** One deployable, a frozen contract, an enforced boundary, and one
  hero case. Keep it that way.
- **The 69-repository map is not for now.** One person already maintains 28 repositories
  (`audits/SINGLE_POINTS_OF_FAILURE_2026-10-04.md`). About twenty of the map's boundaries already
  run in TEC: auth, payments, notifications, subscriptions, gateway, analytics, governance
  (System), developer platform (DX), templates (`tec-template-base`), SDK, UI, audit. If TECO
  needs them, it uses TEC's; it does not rebuild them.
- **The three Golden Rules are what TEC needed.** TEC already followed them in places (Explorer's
  trust-first ranking and no-fixture fallback, Life refusing a projection from too little data,
  "absence is a no" for consent) but had never written them as one rule. A check of the fleet
  found one place that broke the first: Insure read a missing risk band as `MODERATE` (fixed,
  Tec-Insure #43). A search of every app's source for "no issues found"-style phrasing found none.

## 3. Decisions (owner, 2026-10-04)

1. **The three rules become platform law:** C-47 §10, E1–E3, with their enforcement points in
   C-47 §12.
2. **The five evidence statuses become TEC's shared vocabulary** (C-47 §10). The deferred
   Evidence Engine starts from them, not from its 19 stages.
3. **Name and domain: TEC.** TECO is TEC's decision product, not a separate brand. It lives under
   the TEC name and `tecosystem.app`, which its schemas' `$id` already use. It stays a
   [Future Vision]: TEC finishes first, and Phase 0 admits no new app. When it is built, every
   TEC rule applies to it: C-47, Hub SSO (C-123), payments through payment-service. Its
   domain-agnostic core is where TEC's evidence rules get a reusable implementation.
4. **Not adopted:** the 69-repository map, and anything car- or Egypt-specific. Those stay
   TECO's own concern.

## 4. Where these rules would apply next (not scheduled)

| TEC runtime | Rule |
|---|---|
| Elite (C-127) recognition | E3: every criterion must pass, so recognition is a hard-constraint filter, not a score. E2: recognition status before score. |
| NX (C-112) matching | E2: the trust tier first, the match score within it |
| Zone (C-120) / Insure (C-129) wording | E1: "not enough evidence to assess X", never "no known problems" |
| Round 3 reports | Declared evidence, with one of the five statuses |

## Related Documents

- `knowledge-base/C-47_Kernel_Spec_Architecture_Binding.md` — §10 E1–E3, §12 enforcement
- `audits/EVIDENCE_ENGINE_TARGET_SPEC_v1.0_2026-10-04.md` — starts from the §10 vocabulary
- `audits/ROUND_3_DISCOVERY_DECISION_2026-10-04.md` — the MVP whose reports are Declared evidence
- `audits/SINGLE_POINTS_OF_FAILURE_2026-10-04.md` — why not 69 repositories
