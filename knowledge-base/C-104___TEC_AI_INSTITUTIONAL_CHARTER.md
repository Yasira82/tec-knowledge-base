# C-104 — TEC AI Intelligence Reasoning CHARTER
## TEC AI — The Intelligence Layer of the TEC Economy — v2.0

**Truth State:** [Planned State]
**Governance State:** [Governance Approved]
**Verification State:** [Assumed]
**Authority Scope:** [Platform]
**Decision Status:** [Approved]

> **v2.0 activation (CEO decision).** TEC AI is promoted from a Draft charter to one
> of the platform's **three constitutional pillars**. It is **NOT app #25** — it is the
> **intelligence layer ABOVE all 24 apps**. **V1 (the honest concierge) is SHIPPED**
> (Hub `/ai` — accurate app-guide + auth-gated); the full cross-app orchestrator is
> V2/V3 (§10), phased to fit the launch plan (**C-135**). This charter now carries the
> unified definition, the 3-pillar model, and the reason→orchestrate→execute law.

> **TEC AI — The Intelligence Layer.** The unified AI orchestrator that understands
> users, apps, workflows, and the Pi economy — delivering intelligent assistance and
> cross-domain automation across the entire TEC ecosystem.

---

## 1. MISSION

Transform the TEC Economic Runtime's institutional knowledge and real-time economic data into governed, auditable intelligence that assists every actor — user, merchant, investor, builder — in making better economic decisions.

---

## 1.5 THE THREE PILLARS + THE INTELLIGENCE-LAYER LAW

TEC's institutional moat is that it is not 24 apps — it is **one economy with three
constitutional pillars above the apps**:

| Pillar | Role | Question it answers | Charter |
|--------|------|---------------------|---------|
| **Nexus** | Orchestration | *"What should happen next?"* — runs the multi-step plan | C-109 |
| **TEC AI** | **Intelligence** | *"What should I do, and where?"* — understands + recommends | **C-104 (this)** |
| **Legend** | Trust | *"What actually happened?"* — records the outcome as evidence | C-126 |

### The reason → orchestrate → execute law (LOCKED)
```
TEC AI      REASONS   — understands intent, assembles context, proposes a PLAN
   ↓ hands the plan to
Nexus       EXECUTES  — runs the plan as a governed saga (C-109), with compensation
   ↓ each step calls
Owning svc  DOES THE WORK — payment-service moves Pi, Estate owns listings, etc.
   ↓ after the fact
Legend      RECORDS   — the outcome becomes reputation evidence (C-126)
```
TEC AI **never executes** a workflow itself and **never writes another service's truth**.
It proposes; Nexus orchestrates; the owning service acts; Legend records.

### Decision SUPPORT, not Decision Maker (C-47 P6 — non-negotiable)
For any **sensitive or financial** step the AI may **recommend and pre-fill**, but the
**human confirms inside the owning app**. The AI must never auto-buy, auto-move Pi, or
auto-commit capital. Missing/unknown actor context → the AI **denies by default**.

### Honesty (C-133 §7) — the AI inherits the platform's honesty rules
- Present **preview/gated** apps honestly. In a recommendation, if a step routes through
  **FundX / Insure / Brookfield**, the AI states they are **educational/preview — not live**.
- Never fabricate a number; never promise returns; a correct *"I don't know"* beats a
  confident wrong answer. (Enforced in the V1 system prompt already.)

### Worked example — "I want to buy land" (the target V2 experience)
1. TEC AI interprets → opens **Estate**, surfaces options from **Explorer**, prices from
   **Analytics**, verified status from **Zone** *(all reads)*.
2. Financing → routes to **FundX** — **stated as preview/not-live** until it's ungated.
3. Protection → routes to **Insure** — **stated as preview**.
4. The purchase itself happens **in Estate + payment-service, with the user confirming** —
   never the AI.
5. After completion, **Legend** records the outcome — the AI does not write Legend.
All inside one conversation, but every action stays constitutional.

---

## 2. INSTITUTIONAL ROLE

```
System of Reasoning
```

TEC AI sits between the Record Layer (Life, Connection, Explorer, Analytics) and the human interface (Hub, Apps). It interprets economic reality — it does NOT create it, govern it, or own it.

```
Record Layer → TEC AI → Recommendations → Users/Apps
```

---

## 3. ECONOMIC PURPOSE

زيادة جودة القرارات الاقتصادية داخل النظام.

- بدون TEC AI: users يعملوا قرارات على معلومات ناقصة
- بوجود TEC AI: relevant intelligence في السياق الصح في الوقت الصح
- اقتصادياً: better decisions → more transactions → more Pi velocity

---

## 4. AUTHORITY BOUNDARY

### Owns
- Reasoning and recommendation generation
- Capability selection and combination (from Governed Capability Registry)
- Context assembly (from Life, Connection, Analytics, Nexus)
- Explanation and assistance output
- AI session context and memory

### Does NOT Own
- Institutional truth (owned by Verification layer — C-93)
- Governance authority (owned by SYSTEM — C-110)
- Payment execution (owned by tec-payment-service)
- Identity verification (owned by tec-auth-service)
- Capability certification (owned by Governance — C-94)

### Interface Points
```
OUTBOUND:
  Recommendations    → Hub dashboard + all apps
  Analysis reports   → Analytics (C-105)
  Coordination plans → Nexus (C-109)
  Builder assistance → DX (C-115)

INBOUND:
  Life context       → goals, skills, preferences (C-106)
  Connection graph   → relationships, trust signals (C-107)
  Analytics signals  → trends, anomalies (C-105)
  Capability registry → governed skills + workflows (C-94)
  SYSTEM policies    → what AI is allowed to do (C-110)
```

---

## 5. TECHNICAL ARCHITECTURE

```
Planned Stack:
  Claude API (claude-sonnet-4-6 or higher)
  Next.js 15 API Routes (BFF pattern — same as all TEC apps)
  @yasser172/tec-sdk (for all service calls)
  Governed Capability Registry (C-94 — to be built)
  Context Engine (C-97 — to be built)
  Redis (session + context cache)
  tec-analytics-service (4007) for real-time signals

Key Architectural Decisions:
  1. TEC AI consumes capabilities — does NOT create them
  2. Every AI action traceable to a governed capability
  3. Context isolation per user session (P6 Fail Closed)
  4. AI reasoning auditable — all inputs/outputs logged
  5. TEC AI + DX = future Institutional Construction Runtime

LLM Integration Pattern:
  Tool Use (function calling) → TEC service calls
  Context Window = Life + Connection + Analytics signals
  System Prompt = C-47 Kernel Spec + C-94 Capability Registry
  No direct DB access — all data via governed BFF routes

Constitutional Boundaries (C-94):
  AI MAY:  Select, combine, recommend, explain capabilities
  AI MAY NOT: Create certified capabilities, approve capabilities,
              govern capability execution, bypass audit trail
```

### 5.1 V1 runtime — what is actually deployed

**Truth State:** [Current State] · **Verification:** [Code Verified] (`tec-app`
`src/app/api/ai/chat/route.ts` + the two client surfaces)

The stack above is the **planned V2 target**. V1 shipped on a different — deliberately
more defensive — shape, and the difference matters operationally, so it is recorded here
rather than left as drift.

| Aspect | Planned (§5, V2 target) | V1 as deployed |
|--------|------------------------|----------------|
| Model | Claude API, single model id | **Three providers in a fallback chain**: Claude → Groq → Gemini, first configured key wins |
| Model id | pinned (`claude-sonnet-4-6`) | **No single id trusted** — per-provider candidate lists + `GROQ_MODEL`/`GEMINI_MODEL` env override + last-known-good memory |
| Runtime | Next.js API route | Next.js API route, **`runtime = 'edge'`** |
| Session/context cache | Redis | Redis for **rate limiting only** (Upstash REST when configured, bounded in-memory fallback) |
| Context | Context Engine (C-97) | **Own-scope BFF context** (`/api/bff/ai/context`) — username · balance · KYC · goals · activity. An honest partial slice, NOT C-97 |

**Why the fallback chain (an institutional lesson, not a preference).** A hardcoded model
id is a scheduled outage: the provider retires it and the endpoint answers
`404 "model does not exist or you do not have access to it"`, which reads to every user as
"the assistant is down". This happened **twice**. The chain + candidate lists convert a
retirement into one fast 404 and a transparent fall-through. A dead provider is also
remembered per edge instance (last-good-first ordering) so it is not re-probed — and
re-timed-out — on every request.

**Stream contract (both surfaces).** The route normalises all three providers into ONE
SSE shape, so a client never parses a vendor dialect:

```
data: {"text":"…"}        one delta of the answer
data: {"truncated":true}  the provider stopped at its output cap (max_tokens)
```

`AI_MAX_TOKENS` (default **2048**) caps the answer. The cap is **never silent**: each
provider's own stop signal (`stop_reason` / `finish_reason` / `finishReason`) is forwarded
as the `truncated` frame, and both clients append a visible "answer was cut" note — a
sentence that just ends is an invisible failure (C-96).

**Two surfaces, one implementation.** V1 is reachable in two places and they share their
plumbing on purpose:

| Surface | Entry point | Component |
|---------|-------------|-----------|
| `/ai` full page | Hub landing (nav + floating button) | `src/app/ai/AiClient.tsx` |
| Hub drawer | `/hub` floating button | `src/app/hub/components/AIDrawer.tsx` |

Both import the shared modules below. This is a **hard rule learned by repetition**:
while they were independent, every fix applied to one had to be re-discovered on the
other — the SSE chunk-boundary bug that silently truncated answers lived in **both** for
months, and the `[[go:…]]` marker leak lived in the drawer alone because only the page
called the parser. A third AI surface MUST import these, never re-implement them.

| Shared module | Owns |
|---------------|------|
| `src/lib/ai-stream.ts` | Line-buffered SSE reader + the light-markdown tokeniser |
| `src/components/ai/RichText.tsx` | Rendering that markdown (bold · code · bullets · headings) |
| `src/components/ai/NavChips.tsx` | Rendering a nav intent as a chip |
| `src/lib/ai/nav-intents.ts` | Parsing the `[[go:slug]]` marker out of the prose |
| `src/lib/ai-session.ts` | Transcript persistence (load · save · clear) |

### 5.2 The model-pinning law (P0 — earned by a self-inflicted outage)

**Truth State:** [Current State] · **Verification:** [Code Verified]
(`models-pinned.test.ts` enforces it in CI)

> **A model id that production has served traffic on must never be removed or demoted
> from the candidate list.** Add candidates BELOW it. Verify with `/api/ai/health`
> before reordering. Deleting one is a deliberate decision recorded in the same commit.

This is not a style preference. It is written because the platform broke itself with the
opposite behaviour:

1. A PR researched the then-current provider models and pinned `gemini-3.6-flash` and
   `llama-3.1-8b-instant`.
2. A later PR generalised those single pins into candidate **lists**, so a retired model
   id could no longer take the assistant down. The lists were filled from recollection —
   and `gemini-3.6-flash` was **not in them at all**, replaced by four ids that were all
   **older**. On a free tier the older models are the crowded ones.
3. Users then got *"This model is currently experiencing high demand"*. The change whose
   entire purpose was surviving model rotation is what removed the working model.

The trap generalises beyond this platform and beyond AI models: **a value released after
an author's knowledge cutoff looks wrong, so it gets "corrected" to a familiar older one.
Recognition is not evidence. Production traffic is.** Any list of external identifiers
(model ids, API versions, region codes) written from memory carries the same risk.

**Diagnostic:** `GET /api/ai/health` (auth-gated — probes cost money) probes every
configured provider/model with a one-token request and reports which answer, with the
failure reason for each that does not. `GROQ_MODEL` / `GEMINI_MODEL` pin a winner without
a deploy. It exists because the same outage class hit three times, and each time the only
way to learn which model still answered was to ship a guess and wait for a user to fail.

### 5.3 Failure classification — the server decides, the client words it

Three distinct facts used to be indistinguishable to a user:

| Fact | Was | Now |
|------|-----|-----|
| Not signed in | 401 | `code: SIGN_IN` |
| Too many messages | 429 | `code: RATE_LIMIT` |
| No provider key configured | **503** | `code: NOT_CONFIGURED` |
| Every provider momentarily busy | **503** | `code: BUSY` + `Retry-After` |
| Providers failed for another reason | 502 | `code: PROVIDERS_FAILED` |

Both 503s mapped to one client message, so a **busy** assistant told the user it was
**switched off**. HTTP status could not carry the distinction; an explicit `code` does.
The split of responsibility is the point: **the server classifies, the client words it**
— which also keeps the wording in the reader's own language.

Two related rules, both from the same outage:

- **Read an error body exactly once.** A `Response` body is single-use. The failure
  reason was read to classify the error and read AGAIN to build the log line; the second
  read returned an empty string, and production logged `groq 400:` with nothing after it.
  The one thing needed to diagnose the outage was the one thing destroyed. The reason is
  now read once, at the point of failure, and carried — with the failing **model named**,
  since "groq 400" is not actionable across eight candidates.
- **Overload is not fatal.** `429`/`503`/quota wording means *try the next candidate*,
  not *give up* — and if every candidate is overloaded, retry the list once. Treating
  "high demand … usually temporary" as fatal left three healthy fallback models unused.

**Never show the provider's raw payload to a user.** A wall of vendor JSON in a chat
bubble is not something anyone can act on, and it leaks vendor internals into the
product. The full reason goes to the log and a `detail` field; the bubble gets a sentence.

**Security posture (V1, matches §6).** Auth-gated with the same HS256 session JWT the BFF
verifies (no session → 401 — the AI providers cost real money, so an open endpoint is a
drain). Rate limit: **20 req/min keyed by the VERIFIED user id**, never by IP. Context is
own-scope only, assembled server-side, and fail-soft — a missing context degrades the
answer, never blocks it. Text only: V1 executes nothing, so §6's "cannot initiate
financial transactions" holds **by construction**, not by policy.

### 5.4 Conversation state — `sessionStorage`, and why not `localStorage`

The transcript survives closing the drawer and reloading the page
(`src/lib/ai-session.ts`, shared by both surfaces). Without it, asking a question,
following the app the assistant recommended, and coming back lost the thread — for an
assistant, the single largest quality gap.

**`sessionStorage`, deliberately.** A transcript is personal content: it can name goals,
balances, and what the user is trying to do. `sessionStorage` dies with the tab, so a
borrowed or shared device does not hand the next person a history. It is **not** a token,
so ADR-001 (session tokens are cookie-only, never storage) is untouched — but it sits
close enough to that line that the reasoning is recorded rather than assumed.

Three rules the implementation enforces, each from a way this can go wrong:

- **Every access is wrapped.** Pi Browser and private modes can make storage throw on
  read *or* write. An assistant that crashes because it could not save a draft is worse
  than one that quietly forgets — fail-soft, never fail-loud.
- **The stored tail is capped**, so a long-lived tab cannot grow into the storage quota.
- **A reply still streaming is never saved.** A restored half-sentence reads as a broken
  answer.

**A greeting is not worth a conversation.** The `/ai` welcome was seeded inside an effect
keyed on `[user, locale]` that replaced the whole message array — so changing language,
or the session resolving a beat late (the C-123 server path in Pi Browser flips `user`
from `null` to an object), **silently wiped the thread**. It is now seeded once, and a
restored thread suppresses it.

### 5.5 Interaction contract (both surfaces)

| Capability | Rule |
|-----------|------|
| **Streaming** | The reply bubble is created empty and filled per delta — the answer visibly types out. Never buffer the whole answer and render it at the end. |
| **Stop** | Cuts the stream via `AbortController` and **KEEPS the partial answer**, marked stopped. Stopping is a user decision, not a failure; replacing a useful partial reply with an error throws away what the user already read. It also guarantees a new question cancels a stream still arriving from the previous one. |
| **Retry** | An error bubble must never be a dead end. The failed question is remembered and resent verbatim. |
| **New chat** | Clears the screen **and** the stored transcript, and restores the greeting. |
| **Bidirectional text** | `dir="auto"` on inputs, bubbles, and **every rendered line** — per line, not per bubble, so an Arabic sentence containing `Pi` or `NX` still resolves. A reply follows the **question's** language, not the UI locale. |
| **Machine markers** | `[[go:slug]]` is a machine channel. It MUST be parsed out before render — it reached users as literal text on the surface that skipped the parser. |
| **Accessibility** | `role="log"` + `aria-live="polite"` on the transcript; `aria-label` on every icon-only control; focus the field on open; Escape closes the drawer. |

---

## 6. SECURITY MODEL

```
Context Isolation:
  Each user session has isolated context — no cross-user leakage
  Context assembled from authorized sources only
  Personal data (Life) requires explicit user consent

Governance Boundaries:
  AI recommendations tagged with governing capability
  All AI actions logged with actor context
  AI cannot initiate financial transactions without user confirmation
  AI cannot bypass SYSTEM (C-110) governance policies

P6 Fail Closed:
  Unknown actor context → AI denies by default
  Capability not certified → AI does not execute it
  Missing SYSTEM policy → AI escalates to governance

Auditability:
  Every AI output → capability_id + version + context_hash
  Full input/output logging for financial reasoning
  Reasoning audit trail preserved for 90 days
```

---

## 7. REVENUE MODEL

**Premium Intelligence (Freemium)**

| Tier | Features | Price |
|------|----------|-------|
| FREE | Basic recommendations | Included in Hub |
| PRO | Advanced analytics + planning | Hub PRO subscription |
| ENTERPRISE | Business agents + custom automation | Enterprise tier |
| API | AI capabilities for external builders | DX API pricing |

---

## 8. KEY METRICS

```
Recommendation Relevance:  Target ≥ 80% user acceptance rate (Phase 2)
Latency (P95):             < 3s for standard recommendation
Latency (P99):             < 8s for complex analysis
Context Assembly Time:     < 500ms
Hallucination Rate:        < 1% (verified against Capability Registry)
Audit Coverage:            100% of financial recommendations logged
Governance Compliance:     100% (no uncertified capabilities executed)
Availability:              ≥ 99.5% (graceful degradation — not P0 down)
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Intelligence Multiplier** — makes every app smarter without changing the app
- **Decision Quality** — reduces poor economic decisions that lead to churn
- **DX Enabler** — AI + DX = Institutional Construction Runtime (future)
- **Knowledge Activation** — transforms C-documents from static docs to active reasoning

---

## 10. FUTURE EVOLUTION (phased to the launch plan — C-135)

```
V1 — Honest Concierge  ✅ SHIPPED (Hub /ai)
  → Bilingual chat that understands intent and routes to the RIGHT app + page
  → System prompt = the real 24-app registry (SSoT) + honesty rules (C-133)
  → Auth-gated (logged-in TEC users only; protects the paid AI budget)
  → Text-only guide — it recommends + explains; it does NOT execute
  → Does NOT require the full C-94 Capability Registry (that gate is a V2 prerequisite)

V2 — Cross-App Orchestrator  (AFTER the economy is running; not before the C-135 launch)
  → Tool/function-calling → navigation + pre-filled intents into owning apps
  → Reason → hand plan to Nexus (C-109) → owning services execute → Legend records
  → Personal economic advisor: Life + Connection context, CONSENT-gated (C-106)
  → Governed Capability Registry (C-94) + Context Engine (C-97) come online here

V3 — Institutional Intelligence
  → Institutional Construction Runtime (TEC AI + DX)
  → External Pi-ecosystem AI services (via DX API)
  → Economic forecasting + market intelligence
```

> **Sequencing discipline (C-135 + C-121):** the Intelligence Layer is the moat, but it
> is built **on top of a running economy** — C-121 requires Analytics + Zone live first
> ("reasoning without observation / from unverified claims" otherwise). V1 ships now; V2
> waits until the Focused set is live and adopted. Do NOT let V2 block the month-9 launch.

---

## 11. ENGINEERING UPDATES REQUIRED

> **Scope correction (v2.0):** the P0 items below are prerequisites for **V2 (the
> orchestrator)**, NOT for V1. V1 (the honest concierge) shipped **without** C-94/C-97 —
> it recommends + routes + explains from the app registry, executes nothing, and needs no
> capability registry. Keep V2 gated on these; do not retrofit them onto V1.

**P0 — Pre-V2 Requirement (the orchestrator):**
```
[P0-1] Governed Capability Registry (C-94)
  Must be built before TEC AI V2 (tool-calling / execution) launches.
  AI cannot execute actions without certified capabilities to consume.
  Dependency: C-110 SYSTEM for governance approval flows.

[P0-2] Context Engine (C-97)
  User context assembly from Life + Connection + Analytics.
  Required for relevant (non-generic) recommendations.
  Privacy: explicit consent model before Life data consumed (C-106).
```

**P1:**
```
[P1-1] Constitutional Boundaries Enforcement
  CI check: AI code cannot call tec-payment-service directly.
  All financial actions must go through user-confirmed BFF routes.

[P1-2] Audit Logging Schema
  Define structured log format: capability_id, version, context_hash,
  user_id, input_summary, output_summary, latency_ms.
```

**P2:**
```
[P2-1] Hallucination Detection
  Every factual claim cross-referenced against Capability Registry.
  Flagged claims require human review before surfacing to user.
```

---

## 12. INTEGRATION MAP

```
This charter (C-104) depends on:
  C-94  CAPABILITY REGISTRY → governed capabilities to consume
  C-97  CONTEXT ENGINE      → context assembly (to be built)
  C-106 LIFE               → personal context
  C-107 CONNECTION         → relationship context
  C-105 ANALYTICS          → economic intelligence signals
  C-110 SYSTEM             → governance policies
  C-115 DX                 → future: Institutional Construction Runtime

Other charters depend on this one for:
  C-100 HUB       → dashboard recommendations
  C-101 COMMERCE  → merchant intelligence
  C-103 ECOMMERCE → product recommendations
  C-115 DX        → AI builder assistance
```

---

## Related Documents

- **C-121** Institutional Knowledge Pipeline — positions TEC AI at the **apex** of the
  intelligence chain (Hub → Life → Connection → Zone → Analytics → Nexus → **TEC AI**);
  the source of the "reason from observation + verified evidence" rule.
- **C-109** Nexus (Coordination Runtime) — the **Orchestration** pillar; TEC AI hands it
  the plan, Nexus executes the saga.
- **C-126** Legend (Reputation Runtime) — the **Trust** pillar; records the outcome TEC AI
  never writes.
- **C-135** Launch Strategy — the V1-now / V2-after-launch sequencing this charter follows.
- **C-133** Adoption & Growth Governance — the honesty rules the AI inherits.
- **C-47** Kernel Spec — P6 (Decision Support, fail closed) + P5 (layer responsibility).
