# C-134 — Pioneer Runtime Charter

> **Truth State:** `[Planned State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`
> **Authority Scope:** `[Platform]`
> **Decision Authority:** CEO (C-47)

> **Status:** Design authority — the runtime's Phase A surface (Hub `/pioneers` + the
> `pioneer` module `stats`/`me`/`open` endpoints) is live; the full Passport / Journey /
> Certificate / event-contract runtime is planned (Phases B/C). The **rules** here are
> binding now (identity-from-principal, no fabricated counters, single event contract).
> **Owner:** Hub (`tec-app`) = Conductor · `tec-identity-service` = Pioneer state authority
> **Scope:** Hub `/pioneers` + `tec-identity-service` (`pioneer` module) + the 24 live domains (event producers) + Legend/Elite/Analytics/Alert/Explorer (owning domains)
> **Constitution:** Governed by C-47 (Kernel Spec). Nothing here may weaken a C-47 invariant.
> **Related:** `_registry.ts` (LIVE domain SSoT) · C-133 Platform Adoption & Growth Governance (the campaign/funnel layer that consumes this runtime) · C-76/ADR-007 (Pi payment) · C-126 Legend · C-127 Elite · C-128 VIP · C-105 Analytics · C-108 Explorer · C-111 Alert

> **TL;DR (عربي):** Pioneer **مش صفحة دعائية** — ده أول **Onboarding Runtime رسمي** للمنصّة.
> المستخدم بيعدّي رحلة: **Login → يكمّل Missions حقيقية في التطبيقات → يوصل Founding Pioneer → يتسجّل في Legend**.
> القاعدة الحاكمة: **الـ Hub بيعرض بس (Conductor)**، والحقيقة بتتملكها الخدمات — Reputation في Legend،
> Recognition في Elite، Statistics في Analytics، Activity Feed في Alert، Discovery في Explorer،
> وحالة الـ Pioneer نفسها في `tec-identity-service`. **ممنوع أي رقم مزيّف** (لو مفيش pioneers اعرض 0)،
> وهوية الـ Pioneer دايمًا من الـ **JWT principal** مش من أي param من العميل. كل تطبيق من الـ24 بيُصدر
> **event واحد** (`pioneer.mission.completed`) والـ identity-service بيسجّله بشكل idempotent وimmutable.

---

## 1. Purpose & Positioning

Pioneer is the **official onboarding runtime** of the TEC ecosystem — the canonical first
journey a Pi user takes after authenticating:

```
User → Pi Login → Pioneer → Hub → Life → Commerce → Assets → Explorer → … rest of the ecosystem
```

It is **not** a marketing page and **not** a standalone game. It is the coordinated path
that turns a curious visitor into an engaged, verified member with a permanent identity
inside TEC (the Founding Pioneer badge in the reputation layer).

**Design intent:** make usage *real* (complete an action in each app), make it *honest*
(every counter is server truth), and make it *composable* (each app contributes via a
single event contract, with zero duplication of reputation/XP/stats in the Hub).

> **Relationship to C-133:** C-133 (Platform Adoption & Growth Governance) governs the
> *campaign and funnel* — how a visitor is reached and moved through Adoption Levels.
> C-134 governs the *runtime* those campaigns drive users into — the missions, events,
> journey state machine, and Founding rules. C-133's "Founding 100" campaign is the first
> consumer of this runtime.

---

## Runtime Principles (what Pioneer is, and is not)

> These five lines are the philosophy the rest of the charter enforces. They exist so that
> no future session can quietly turn the onboarding runtime into a game or a growth-hack.

1. **Pioneer is NOT gamification.** Points/streaks/leaderboards are never the goal; they may
   only ever *represent* real evidence, and only via the owning domain (Legend/Analytics).
2. **Pioneer is NOT marketing.** The campaign that recruits a user lives in C-133; Pioneer is
   the *runtime* the user actually enters. No number here is ever promotional.
3. **Pioneer is NOT a reward system.** Nothing of value is *granted* for participation. The
   Founding badge is earned by completing real missions, not paid for or handed out.
4. **Pioneer IS the canonical onboarding runtime** — the one official path from Pi login to a
   permanent, evidence-based identity inside TEC.
5. **Every mission must produce real value; completion is evidence; recognition follows
   evidence.** A mission that isn't a real action does not belong in the catalog (§6). This is
   the same law C-133 R6 states for apps: no empty steps.

---

## 2. Constitution Alignment (C-47)

| Principle / Invariant | How Pioneer honors it |
|---|---|
| P1 Single Source of Truth | Missions defined once in the registry; Pioneer state owned once by `identity-service`; reputation once by Legend |
| P2 No Rule Duplication | Hub never re-implements XP / badges / reputation / stats — it displays what owning domains expose |
| P3 Strict State Transitions | The Journey is a forward-only state machine, evaluated server-side (§8) |
| P4 Event-Driven Truth | Progress is driven by immutable `pioneer.mission.completed` events, not client claims (§7) |
| P5 Layer Responsibility | SDK = contracts, Gateway = orchestration, Services = execution; Hub = presentation (§3) |
| **P6 Fail Closed** | Identity from verified principal only; unknown/absent principal ⇒ no progress accrues (§5) |
| Invariant #3 Identity → ONE principal | Pioneer identity == verified JWT `sub`, never a client param (§5) |
| Invariant #4 Audit trail | Every mission completion is a recorded event with actor context |
| Invariant #5 Events immutable | A recorded completion is never mutated or deleted |
| Invariant #6 No mutation without actor | Every write carries the ActorContext (the principal + source service) |

---

## 3. Ownership Map (P5) — the most important rule

> The Hub is the **Conductor**, not the **Owner**. If the Hub starts to *own* XP, badges,
> reputation, leaderboards, or activity, you get **two sources of truth**. Forbidden.

| Concern | Owning domain / service | Hub's role |
|---|---|---|
| Pioneer state (missions, journey, founding number) | `tec-identity-service` → `pioneer` module | Read + present |
| Reputation (permanent, evidence-based) | **Legend** (C-126) | Link + display badge |
| Recognition / Status tiers | **Elite** (C-127) / **VIP** (C-128) | Display eligibility |
| Statistics / aggregate counters | **Analytics** (C-105) | Display real numbers |
| Activity Feed | **Alert** (C-111) | Embed feed |
| Discovery / Recommendations | **Explorer** (C-108) | Embed / route |
| Per-app mission completion | The owning app (its BFF) emits the event | Show ✓ |

---

## 4. Domain Model (definitions)

| Term | Definition |
|---|---|
| **Pioneer** | A verified Pi user on the onboarding journey. Identified by the JWT `sub` (§5). |
| **Mission** | A single, real, completable action inside one app (not "open"). One canonical mission per app in v1; richer per-app missions later. Defined in the registry (SSoT). |
| **Event** | An immutable fact that a mission was completed: `pioneer.mission.completed` (§7). |
| **Journey** | The forward-only state machine over completed missions (§8). |
| **Passport** | The Pioneer's identity object: Identity + Journey + History + Founding Number + Certificate (§10). |
| **Founding Pioneer** | One of the first 100 pioneers to complete all live missions. Server-assigned, capped, un-fakeable (§9). |
| **Certificate** | A server-issued, signed proof of completion (§13). |

---

## 5. Identity Resolution (P6 · Invariant #3) — normative

- The Pioneer principal is **always** the verified JWT `sub` extracted at the BFF / gateway.
- **Never** derive the owner from a client-supplied value (`tec_user` cookie, request body,
  or a URL param). Those are hints, not authority.
- Any read of another owner's Passport/quest MUST be authorized to the same principal, or
  require an explicit `AdminActor` (Invariant #6). A `by-owner/{owner}` lookup that is not
  bound to the caller's principal is a **fail-closed defect** (potential IDOR).
- Absent or unverifiable principal ⇒ browsing is allowed, but **no progress accrues** and
  no Passport is returned.

> This section supersedes any current BFF behavior that passes `owner` from the `tec_user`
> cookie. The gateway/guard MUST bind `owner` to the JWT principal. *(Enforced 2026-07: the
> `pioneer/me` BFF forwards the token only, and identity-service resolves the owner from the
> verified JWT — the earlier `by-owner/:owner` path was removed.)*

---

## 6. Mission Catalog (v1 = now, no XP / no leaderboard / no reputation)

v1 missions are intentionally simple: a single real touch per app, tracked as a checkbox.
They need **no** XP, leaderboard, or reputation — but they make usage real and are the
seed the richer missions grow from.

> **The canonical mission catalog is NOT defined in this charter.** It lives in code —
> the mission registry derived from `_registry.ts` (the LIVE-domain SSoT). This charter
> defines the **rules** a mission must satisfy; the concrete per-app list is data, and the
> constitution must not have to change every time an app ships, is renamed, or is delisted
> (P1 — one source of truth). Treat any table reproduced in a doc as *illustrative only*.

**Rules every catalog entry MUST satisfy** (this is the normative part):

1. **One canonical mission per app in v1** — a single, real, completable action (never merely
   "open" once richer missions exist), owned by that app's service.
2. **Real value** — the mission must correspond to genuine use (Runtime Principle §5 / C-133 R6).
   A no-op does not qualify.
3. **Derived from LIVE domains** — the mission set size is `LIVE_DOMAINS.length`; a domain going
   live or being delisted changes the catalog automatically, with no charter edit.
4. **Emitted by the owner** — completion is reported by the app's own BFF via the §7 event; the
   Hub never fabricates or infers a completion.

*Illustrative* (non-normative — the registry is authoritative): `tec → log in`,
`commerce → browse the marketplace`, `explorer → run one search`, `zone → open Zone`,
`epic → browse the project board`. Phase-C richer missions (e.g. `commerce → first checkout`,
`epic → create a project`) are confirmed per app with each domain team (§19).

---

## 7. Event Contract (P4) — the cross-repo interface

Each app (or its BFF) emits **one** event when a mission is genuinely completed. The
`identity-service` `pioneer` module is the sole recorder. This is the contract every one of
the 24 repos implements — it is the Orchestra boundary.

```json
{
  "type": "pioneer.mission.completed",
  "occurredAt": "2026-07-19T16:40:00.000Z",
  "pioneer": { "principal": "<JWT sub — resolved from the verified token>" },
  "app": "commerce",
  "missionId": "commerce.browse_marketplace",
  "source": { "service": "commerce-bff", "requestId": "<x-request-id>" },
  "idempotencyKey": "<principal>:<missionId>"
}
```

**Rules:**
- **Identity** (`pioneer.principal`) is resolved from the verified token, never the body (§5).
- **Idempotent:** `idempotencyKey = principal:missionId`. Re-emitting a completed mission is a
  no-op — one completion per mission per pioneer (no double counting).
- **Immutable** (Invariant #5): a recorded completion is append-only; never edited/removed.
- **Actor context** (Invariant #6): `source.service` + principal are mandatory.
- **Fail closed** (P6): malformed / unauthenticated events are rejected, not "best-effort accepted".
- Events are **facts** (already happened), not commands (P4) — an app emits *after* the action.
- Event name is versioned per C-70 when it materializes: `pioneer.mission.completed.v1`.

---

## 8. Journey State Machine (P3) — the definition of success

The journey is forward-only and evaluated **server-side** from recorded events. Thresholds
reuse the existing tiers, reframed from "apps opened" to "missions completed".

```
VISITOR
  │  (Stage 1) Pi login
  ▼
AUTHENTICATED
  │  (Stage 2) ≥ 5 missions completed
  ▼
EXPLORER
  │  (Stage 3) ≥ 12 missions completed
  ▼
BUILDER
  │  (Stage 4) ALL live missions completed  (currently 24)
  ▼
PIONEER_COMPLETE
  │  if within the first 100 to complete  → assign Founding number (§9)
  ▼
FOUNDING_PIONEER
  │  materialize permanent record in Legend (C-126)
  ▼
LEGEND_LINKED   → then: Advanced Challenges (§14) — the journey continues
```

- Transitions are **monotonic** — a pioneer never regresses (P3).
- Stage thresholds derive from `LIVE_DOMAINS.length` (5 / 12 / all), not literals.
- `PIONEER_COMPLETE` and beyond are **terminal-ish**: completion is permanent (Invariant #7 spirit).

---

## 9. Founding Rules

- **Cap:** `FOUNDING_CAP = 100` (the real "Founding 100" limit).
- **Assignment:** atomic, server-side, on the transition into `PIONEER_COMPLETE`, and only
  if `claimed < 100`. `remaining` MUST never go negative (mirrors Invariant #1's spirit).
- **Server-authoritative & un-fakeable:** completion requires recorded events tied to the
  verified principal — a client cannot fabricate a Founding number.
- **No payment required:** the Founding badge is earned by *completing the journey*, not by a
  Pi payment. (Aligns the UI copy, the comment, and the current service — no payment logic.)
- **Honesty (C-133 §7):** public stats show *real* `claimed` / `remaining`. If zero
  pioneers exist, show **0** — never a marketing number.

---

## 10. Passport (identity, not just UI)

The Passport is the Pioneer's identity object inside TEC — a **read model** owned by
`identity-service`, presented (not owned) by the Hub:

```
Pioneer Passport
├── Identity        (pi username, principal, join date)
├── Journey         (current stage, missions completed / total)
├── History         (timeline of completed missions, with timestamps)
├── Founding Number (if FOUNDING_PIONEER — else null)
└── Certificate     (link, if PIONEER_COMPLETE)
```

- Fully derived from recorded events → no separate writable state to drift.
- The Hub renders it; Legend/Elite provide the reputation/recognition surfaces it links to.

---

## 11. XP Rules (defined now, **deferred** to Phase B — owned by Legend)

XP is **not** active in Phase A. It is specified here so the event contract (§7) is
forward-compatible: the `missionId` is enough — the XP weight table lives server-side
(single source), so turning XP on later needs **no** contract change.

> ⚠️ **The table below is ILLUSTRATIVE DEFAULTS — NOT NORMATIVE. Future Phase (B+).** These
> numbers are examples of shape, not committed values, and are **not part of the system today**.
> The authoritative weights are set by **Legend** (C-126) server-side when XP ships; final
> values are an open question (§19). Do not build against these figures.

| Action | XP *(illustrative)* | Notes |
|---|---|---|
| Visit | 5 | lowest signal |
| Login | 10 | |
| First action (mission) | 20 | the core signal |
| Pi payment | 50 | must go through payment-service contracts (ADR-007) |
| Invite (referral) | 40 | requires attribution + anti-abuse (§ referral) |

- XP is a **reputation-adjacent** value ⇒ owned by **Legend**, displayed by the Hub.
- XP math never runs in the frontend (P2/P6).

---

## 12. Badge / Achievement Rules

- Achievements (Explorer=5, Builder=12, Trader=first payment, Connector=first connection,
  Founder=all) are **recognition** ⇒ owned by **Legend** (evidence) + **Elite** (tiers).
- The Hub **displays** them; it does not define or grant them (P2).
- The single Pioneer-specific recognition — the **Founding Pioneer badge** — is materialized
  in Legend on `FOUNDING_PIONEER` and surfaced everywhere via the reputation layer.

---

## 13. Certificate Rules

Issued only for a real `PIONEER_COMPLETE` / `FOUNDING_PIONEER` state:

| Field | Source |
|---|---|
| Display name | profile |
| Pi username | verified identity |
| Founding number | identity-service (§9) — may be null for non-founding completers |
| Completion date | timestamp of the completing event |
| Verification hash | server signature over the above |

- Server-generated + signed (un-forgeable). The Hub renders and enables Share (§ share).
- Never issued for an incomplete or unverified journey (P6).

---

## 14. After the 24 — Advanced Challenges (retention)

Completion is not the end. Post-`FOUNDING_PIONEER`, the Hub routes into the ecosystem
(this is exactly the Conductor role — routing, not owning):

| Challenge | Routes to |
|---|---|
| Become a Merchant | Commerce |
| Publish a Project | Epic |
| Verify a Business | Zone / NBF |
| Create an Opportunity | NX |
| Join DX | DX |
| Become a Legend | Legend |

---

## 15. Honesty & Privacy constraints

- **No fabricated data — anywhere.** Feed, stats, leaderboards, community missions, founding
  counters: all must be real service data or show `0`/empty. Credibility with Pi Core Team is
  the whole point. (Same law as C-133 §7.)
- **Leaderboards (country / city / university):** TEC does **not** currently collect
  country/city/university, and Pi does not expose them. A geo/edu leaderboard therefore
  requires a **privacy-reviewed, opt-in** data source owned by **Analytics** — it must NOT be
  silently derived from IP. **Deferred** until that source is decided (open question §17).

---

## 16. API / Contract Surface

| Surface | Status | Notes |
|---|---|---|
| `GET /api/bff/pioneer/stats` → `/api/identity/pioneer/stats` | exists | Public, honest counter; must return real 0 when empty |
| `POST /api/bff/pioneer/open` → `/api/identity/pioneer/open` | exists | v1 mission = "open"; principal from token |
| `GET /api/bff/pioneer/me` → `/api/identity/pioneer/me` | exists | Resolves owner from JWT, not `tec_user` (§5) — IDOR fix shipped 2026-07 |
| `POST /api/bff/pioneer/mission/complete` | **proposed** | Generic mission event ingress (§7) — supersedes `open` |
| `GET /api/bff/pioneer/passport` | **proposed** | Passport read model (§10) |
| `GET /api/bff/pioneer/certificate` | **proposed** | Certificate issuance/read (§13) |

---

## 17. Phasing → concrete deliverables

**Phase A — Hub frontend, now, Phase-0-safe (polish, not a new subsystem)**
- Simple per-app **missions** (checkbox, no XP) sourced from `_registry.ts` (§6).
- **Passport** read view (Identity · Journey · History · Founding · Certificate placeholder).
- **Honest** zero-safe counters (show 0).
- **Certificate** render + **Share** for a *real* completion only.
- Uses existing `pioneer` endpoints; no backend contract change required.

**Phase B — `tec-identity-service` `pioneer` module**
- `mission/complete` event ingress with idempotency + immutability (§7).
- Server-side **Journey state machine** (§8) + atomic **Founding** assignment (§9).
- **Passport** + **Certificate** read models (§10, §13).
- **Referral** attribution + anti-abuse. XP **defined but off** (§11).

**Phase C — Orchestra (all 24 apps + owning domains)**
- Each app emits `pioneer.mission.completed` for its richer mission (§6, §7).
- Achievements/XP → **Legend/Elite**; Stats/Leaderboards → **Analytics**;
  Feed → **Alert**; Discovery/Recommendations → **Explorer**.

---

## 18. Forbidden (Pioneer-specific)

1. Fabricating any counter (feed, stats, founding, community) — show real data or 0.
2. Resolving the Pioneer identity from a client param (`tec_user`, body, URL).
3. Duplicating XP / badge / reputation / stats logic inside the Hub.
4. Mutating or deleting a recorded mission event.
5. Assigning a Founding number beyond `FOUNDING_CAP`, or letting `remaining` go negative.
6. Issuing a Certificate for an unverified or incomplete journey.
7. Deriving a leaderboard from data the user never consented to share (e.g. IP → country).

---

## 19. Open Questions (need a decision before Phase B/C)

1. **Leaderboard data source & privacy** (§15) — opt-in geo/edu, owned by Analytics? Or drop?
2. ~~**Founding gate** — completion only vs. a KYC/Pi-payment gate?~~ → **Answered in §20.5**: completion-only stands; the gate that decides anything is Pi's own, on its own records.
3. **Richer missions (§6)** — confirm the "Phase C" mission per app with each domain team.
4. **XP weights (§11)** — final values + whether invite/payment XP ship with Phase B.
5. **Certificate signing** — key custody + verification endpoint owner.

---

## 20. The Commercial Objective — why this runtime exists at all

> **Truth State:** `[Current State]` · **Verification:** `[Runtime Verified]` — read from the
> Pi Developer Portal's own claim dialogs, 2026-09-05.

Sections 1–19 describe Pioneer as an onboarding runtime. That is what it *is*. This
section records what it is **for**, which was not written down anywhere and was
rediscovered from a phone screenshot mid-session — the exact failure mode C-95 exists
to prevent.

### 20.1 Pi's claim requirement

Every `.pi` domain must be claimed against a connected Pi app, and the Portal refuses
the claim until:

```
The connected app must have:
  • Completed the app setup checklist
  • At least 5 unique KYC'd approved Pioneers engage with the app
  • Meet all utility and compliance requirements
```

The dialog also states the claim is **tentative** and "subject to periodic compliance
and utility purpose reviews that could lead to the domain being revoked", and that
ownership "will need to be renewed before it expires". A cleared threshold is therefore
not a permanent state.

### 20.2 What is at stake

Twenty-four `.pi` domains were **won at auction and paid for** — including `vip.pi`
(2.8K π), `nexus.pi` and `explorer.pi` (1.4K π each), `commerce.pi` (999 π),
`estate.pi` (750 π), `elite.pi` (686 π), `titan.pi` (650 π), `life.pi` (561 π).

**`tec.pi` is the only claim accepted so far** (Claim Pending). Every other app returns
*"Requirements Not Met"*.

So the campaign's objective is not a badge and not a gift:

> **Get 5 KYC'd Pioneers to genuinely engage with each of the 24 apps, so 24 paid-for
> domains can be claimed before they lapse.**

The Founding badge and the PRO gift are **incentives in service of that**, not the point.
Anything that raises total sign-ups without raising *per-app verified engagement* is
motion, not progress.

### 20.3 The KYC word is the whole rule

"5 unique **KYC'd** approved Pioneers". An opened link from a non-verified account moves
Pi's counter not at all. This is what makes per-app *verified* engagement the only metric
that matters, and it is why the campaign deliberately does **not** ask users for identity
documents (see §20.5) — Pi has already verified them; asking again buys nothing and costs
trust.

### 20.4 Measurement, and its honest limit

`GET /identity/pioneer/coverage` (admin-gated) reports, per roster app: verified
pioneers, total openers, and how many are still needed.

**It is not Pi's verdict.** `kyc_verified` is TEC's own KYC register (tec-kyc-service);
Pi checks *its* records, which this platform cannot read. The two are different registers
of the same word. So:

| Reading | Meaning |
|---|---|
| ours **< 5** | Pi's count is very probably below 5 — **reliable, act on it** |
| ours **≥ 5** | Pi *might* agree — **not a green light** |

Only the first direction is safe to act on. A consumer that mistakes the second for a
confirmation will declare a domain ready and then watch the claim get refused.

### 20.5 This answers §19 Question 2, from outside

§19 asks whether the Founding gate should be "completion only, or a KYC / Pi-payment
gate". The Portal requirement settles the shape of the answer:

- **The gate on the badge stays completion-only.** Demanding identity documents from a
  first-time visitor to earn a badge reads as a scam and suppresses exactly the
  participation the domains depend on. Pi has already done the KYC.
- **The gate that matters is not ours at all** — it is Pi's, applied to its own records,
  and no rule written here can move it.

What the platform controls is *cost of participation*, not identity: the Quest requires
twenty-four real visits (enforced by the roster, see the code), which is what makes an
engagement plausibly real rather than asserted.

### 20.6 Known gap — engagement ≠ opening

Pi counts "engage", which is its own definition and is almost certainly stronger than
"followed a link". The Quest currently records an **open**. Closing that distance — a
recorded action inside each app, drawn from the events already in
`manifests/events-catalog.yaml` rather than new per-app instrumentation — is the highest
-value remaining work on this runtime, and it is not yet built.

**A stronger signal exists and is unused:** a completed Pi **Mainnet** payment implies the
payer holds a Mainnet wallet, which Pi grants only after its own KYC. Payment records
already exist in `tec-payment-service`. Wiring that into coverage would turn an inferred
count into a near-certain one. Recorded here as a candidate, not a claim — the exact Pi
KYC/Mainnet coupling should be confirmed against Pi's documentation before it is relied on.

---

## Related Documents

- **C-133** — Platform Adoption & Growth Governance (the campaign/funnel that drives this runtime)
- **C-47** — Kernel Spec (the constitution this runtime is governed by)
- **C-126** — Legend Reputation Runtime (owns reputation + the Founding Pioneer badge)
- **C-127 / C-128** — Elite / VIP (recognition + premium eligibility)
- **C-105** — Analytics (owns all aggregate counters + any future leaderboard)
- **C-108 / C-111** — Explorer / Alert (discovery + activity feed the Passport links to)
- **C-76 / ADR-007** — Pi payment ownership (any payment XP routes through payment-service)
- **C-132** — Modules-First Architecture Policy (the `pioneer` module lives in `tec-identity-service`)
