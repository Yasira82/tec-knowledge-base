# C-133 — PLATFORM ADOPTION & GROWTH GOVERNANCE

## TEC Platform — Adoption, Campaigns & Domain-Claim Strategy

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`
> **Authority Scope:** `[Platform]`
> **Decision Authority:** CEO (C-47)

> **TL;DR (عربي):** ده دستور **النمو والتبنّي** — مش وثيقة حملة واحدة. بيحكم: كيف المستخدم
> يتطوّر (Adoption Levels)، إزاي نقيس ده (Adoption Event Model)، وإزاي نطلق **حملات**
> (Founding 100 = أول حملة، وبعدها Merchant 500 · Builder · Ambassador...). الهدف الحقيقي:
> **استلام دومينات Pi للـ 24 app**. القاعدة الحاكمة: **ممنوع أي رقم مزيّف** (data حقيقية أو 0)،
> الـ **KYC بيفرضه Pi نفسه** (نعرض مش نتحقق)، والـ Growth **بيعرض** بس — الأرقام لـ Analytics،
> السمعة لـ Legend، حالة المستخدم لـ `tec-identity-service`. وأخطر خطر: تطبيقات فاضية بلا قيمة
> حقيقية — كل app لازم يقدّم قيمة مستقلة.

---

## 0. Why this document exists

Growth was scattered across chats and one-off assets. This makes it a **single source of
truth** and — critically — a **durable constitution**, not a campaign brief: it governs how
users adopt the platform, how that adoption is measured, and how *any* growth campaign is
run. **"Founding 100" is the first application of this governance, not its subject** — future
campaigns (Merchant 500, Builder Program, Ambassador Program, per-app launches) plug in
without rewriting C-133.

> Dated tactics (a specific calendar, a specific post) live in `audits/` or issues; the
> **rules, ladders, event model, and honesty laws** live here.

---

## 1. Positioning & Narrative

**TEC is the first full Pi-native economy** — not one app, but **24 live apps** sharing one
identity, one wallet contract, and real Pi payments.

| | |
|---|---|
| **One-liner** | "The first complete economy built on Pi — 24 apps, one identity, real Pi." |
| **Primary audience** | KYC-verified Pi Pioneers (the only actors who can transact on Pi). |
| **Secondary** | Pi merchants/builders (supply side), Pi community, Pi Core Team (credibility). |
| **Emotional hook** | Belonging + status ("be one of the first to shape it") — reused by every campaign. |

---

## 2. North-Star & Funnel

The **North-Star** is **claimed Pi domains** — proof of *real, KYC-verified engagement*,
which is exactly what a durable Pi economy needs. Growth is measured against that, not
vanity reach (downloads / visits / followers).

```
Discover  →  Open in Pi Browser  →  Log in with Pi  →  Engage  →  Advance the ladder (§3)
 (channels)     (per-App-ID)          (SSO once)       (missions)   (Pioneer → … → Legend)
```

---

## 3. Adoption Levels (the ladder)

Growth does not measure visits — it measures **how a user evolves**. Every campaign moves
users **up this ladder**; every KPI (§11) maps to a transition on it.

The ladder has **two parts** that must not be conflated:

**(A) Onboarding spine — linear & monotonic** (owned by the Pioneer Runtime, C-134):

```
VISITOR            browsing, not logged in
   │  Pi login
ACTIVE VISITOR     logged in, no engagement yet
   │  first mission
PIONEER            engaging (≥1 mission)
   │  sustained engagement
ACTIVE PIONEER     recurring across apps
   │  complete the journey (all live apps) within the cap
FOUNDING PIONEER   first-100 permanent recognition (materialized in Legend)
```

**(B) Role tracks — parallel, NOT sequential** (each owned by its domain). After Founding
Pioneer, a user branches into one or more *independent* economic roles — a user can become
a MERCHANT without first being a BUILDER, or be both:

```
                    ┌─ BUILDER    ships a project / business   (Epic · NBF)
FOUNDING PIONEER ──►├─ MERCHANT   sells / accepts Pi           (Commerce · Ecommerce)
   (spine end)      └─ PARTNER    org-level collaboration      (Titan · institutional)
                           │
                           ▼  (evidence from ANY track accrues)
                        LEGEND    evidence-based standing (C-126)
```

- **LEGEND is not a fourth sequential step** — it is the **reputation apex**, a *cross-cutting*
  projection that reflects proven evidence from any role track (Builder/Merchant/Partner
  activity all feed it). One earns Legend standing *through* a role, not *after* Partner.
- The **spine (A)** is forward-only/monotonic (mirrors P3, enforced by C-134's state machine).
  The **role tracks (B)** are opt-in and composable — order is the user's, not the ladder's.
- Each level's *truth* is owned by a service (§8) — Growth only **presents** the level.
- Levels are the substrate campaigns target (e.g. Founding 100 targets the spine
  `PIONEER → FOUNDING PIONEER`; a future Merchant 500 targets the track `→ MERCHANT`).

---

## 4. Adoption Event Model

Adoption is driven by **events** (facts), not client claims (P4). Analytics (C-105) and the
Pioneer/identity layer consume this chain; Growth never computes it.

```
user.login
   ↓
app.opened            (per-App-ID — the domain-claim signal)
   ↓
mission.started
   ↓
mission.completed     (idempotent: principal:missionId — one per user per mission)
   ↓
achievement.earned    (owned by Legend/Elite — recognition)
   ↓
reputation.updated    (owned by Legend — the durable record)
```

- **Identity** on every event = the **verified JWT principal**, never a client param (P6 /
  Invariant #3).
- **Immutable + idempotent** (Invariant #5): a completion is append-only; re-emitting is a
  no-op.
- The concrete event contract + mission catalog live in the **Pioneer Runtime charter**
  (proposed — the `/pioneers` runtime design authority). C-133 governs *why* the chain
  exists and *who owns it*; the charter governs *the wire format*.

---

## 5. Campaigns (Founding 100 = the first)

Growth runs **campaigns** — bounded pushes that move users up the ladder (§3) toward the
North-Star (§2). Every campaign obeys the same governance: honest counters (§7), the
ownership map (§8), and a ladder transition it is responsible for.

### 5.1 Campaign register

| Campaign | Ladder transition | Status | Notes |
|----------|-------------------|--------|-------|
| **Founding 100** | Pioneer → Founding Pioneer | `[Current State]` | The flagship / first — detailed below |
| Merchant 500 | Builder → Merchant | `[Future Vision]` | Supply-side; onboards Pi-accepting sellers |
| Builder Program | Pioneer → Builder | `[Future Vision]` | Epic/NBF creators; ships real projects |
| Ambassador Program | any → Community leader | `[Future Vision]` | Referral + advocacy (needs the Ambassador Kit, §9) |
| Per-app launches | Visitor → Pioneer (per app) | `[Planned State]` | One push per app as it matures |

> A new campaign is added as a **row here + its own brief in `audits/`** — never by
> rewriting this constitution.

### 5.2 Founding 100 (the current campaign)

The flagship asset is the public **`/pioneers`** runtime (Hub —
`hub.tecosystem.app/pioneers`).

| Element | Rule |
|---------|------|
| **One link, all apps** | Lists every **LIVE** app (from `_registry.ts` SSoT — count derived, never hard-coded). |
| **Pioneer Quest** | Open each app in Pi Browser while logged in. ✓/progress gate on **login** (not a KYC flag TEC doesn't store). |
| **Founding Pioneer badge** | First **100** to complete the Quest earn a permanent recognition (Legend / VIP). Cap = 100, assigned atomically server-side, `remaining` never negative. |
| **Zero cost** | **No payment required** — earned by *completing the Quest*. Friction suppresses participation. |
| **Browsing open to all** | Anyone browses; only a logged-in visitor accrues progress. |

Backend authority: the `pioneer` module in `tec-identity-service` (Modules-First, C-132).

---

## 6. Domain-Claim Growth Strategy (the real objective)

Claiming a Pi domain for an app requires **≥ 5 unique KYC-verified Pioneers engaging** with
that app. Two facts shape everything:

1. **Engagement is per-App-ID.** Each app has its own Pi App ID → a Pioneer must open **that
   app at its own domain** in Pi Browser, not merely navigate inside the Hub. (Why
   `/pioneers` links each app to its **own** domain.)
2. **Pi Network enforces the KYC requirement itself.** Pi counts only KYC-verified Pioneers,
   using Pi's own data. **TEC does not — and need not — verify Pi KYC** (the wallet/payment
   simply doesn't function without it).

**Implication:** our layer must **not** duplicate Pi's KYC gate. We drive *engagement*; Pi
does the *filtering*. An in-house KYC gate using TEC's internal doc-KYC (a separate,
rarely-completed flow) is an anti-pattern — it breaks real Pi-verified users and buys nothing.

---

## 7. Honesty & Compliance Constraints (non-negotiable)

Credibility with the Pi Core Team is the platform's most valuable growth asset:

1. **No fabricated data — anywhere.** Counters (Founding, stats, feed, community) show
   **real service data or `0`/empty**. Never a marketing number. (Enforced in code.)
2. **KYC is Pi's, not ours.** Never claim to verify Pi KYC; present, never assert.
3. **Privacy.** No leaderboard/segmentation from data the user never consented to share (e.g.
   IP → country). Any geo/edu segmentation is opt-in, owned by Analytics (C-105).
4. **No false scarcity / no impersonation.** "Founding 100" is a *real* cap of 100 — not a
   rolling fake-urgency banner. Same rule binds every future campaign.
5. **Payment claims.** Any payment surface obeys ADR-007 (C-76) and states cost truthfully.

---

## 8. Ownership Map (P5) — Growth presents, it does not own

> The presenting surface is the **Conductor, not the Owner**. Duplicating owned truth into
> Growth = two sources of truth = forbidden.

| Concern | Owning domain / service | Growth's role |
|---------|-------------------------|---------------|
| User/Pioneer state (level, quest, founding number) | `tec-identity-service` | Read + present |
| Statistics / aggregate counters | **Analytics** (C-105) | Display real numbers |
| Reputation (permanent, evidence-based) | **Legend** (C-126) | Link the badge |
| Recognition / tiers | **Elite** (C-127) / **VIP** (C-128) | Display eligibility |
| Activity feed | **Alert** (C-111) | Embed |
| Discovery / recommendations | **Explorer** (C-108) | Route |
| Identity / KYC | Pi Network + `tec-auth-service` | Never re-derive |

---

## 9. Channels & Assets

| Asset | Purpose | Status |
|-------|---------|--------|
| **`/pioneers` onboarding page** | The one link — all live apps + guide + Quest + Founding badge | `[Current State]` — live |
| **Recruitment post (EN + AR)** | Short post for Pi/Telegram groups: what TEC is + the ask + the link | `[Current State]` — drafted |
| **Per-app launch posts** | One post per app for app-specific channels | `[Planned State]` |
| **Pioneer FAQ** | Friction answers (Why Pi Browser? What's KYC? Is it free?) | `[Planned State]` |
| **TEC Ambassador Kit** | Logos · media kit · press kit · screenshots · demo videos · community guide — the shared brand asset every campaign & ambassador draws from | `[Planned State]` |
| **Launch calendar** | Teaser → launch → spotlight → milestone (per campaign) | `[Planned State]` — lives in `audits/`/issues |

**Channels:** Pi community groups (Telegram/Discord), Pi ecosystem directories, TEC's own
apps (cross-link the active campaign), and word-of-mouth via the community layer (§10).

---

## 10. Community Layer (retention, not just acquisition)

Acquisition without retention is a leaky bucket. Growth owns a **loop**, not a one-way funnel:

```
RECRUIT   bring in Pioneers (campaigns, ambassadors)
   ↓
SUPPORT   answer, unblock (FAQ, community channels)
   ↓
FEEDBACK  capture what's missing / broken (structured, opt-in)
   ↓
IMPROVE   route feedback to the owning app/team (Growth never fixes in-place)
   ↓
RETAIN    bring users back (advanced challenges, new campaigns, reputation)
   ↺  (feeds RECRUIT via advocacy)
```

- The **Ambassador Program** (§5.1) operationalizes RECRUIT + SUPPORT at community scale.
- FEEDBACK is a *signal to owning teams*, never a Growth-owned backlog (P5).
- RETAIN routes Founding Pioneers into **Advanced Challenges** (become a Merchant → Commerce;
  publish a Project → Epic; become a Legend → Legend) — the Conductor role: routing, not owning.

---

## 11. Metrics & KPIs

Every KPI maps to a **ladder transition** (§3) and reads **real** service data (or `0`).

| Metric | Ladder transition | Owner |
|--------|-------------------|-------|
| **Domains claimed** | (North-Star — cumulative engagement) | Ops + Pi Portal |
| **Pioneers / app** | Visitor → Pioneer, per app (target ≥ 5) | Pi Portal + Analytics |
| **Activation rate** | Active Visitor → Pioneer | Analytics (C-105) |
| **Journey completion** | Pioneer → Founding Pioneer | `pioneer` module `/stats` |
| **Founding fill** | Founding numbers claimed / 100 | `pioneer` module `/stats` |
| **Supply conversion** | Builder → Merchant (future campaigns) | Commerce + Analytics |
| **Retention (7/30d)** | any → returning | Analytics |

---

## 12. Phasing

| Phase | Deliverable | State |
|-------|-------------|-------|
| **G0 — Foundation** | `/pioneers` live + honest counter + Founding badge (no payment) | `[Current State]` |
| **G1 — Recruit** | Recruitment post + FAQ; seed the first Founding cohort | `[Planned State]` |
| **G2 — Amplify** | Per-app launch posts; Ambassador Kit; cross-link the active campaign | `[Planned State]` |
| **G3 — Claim** | ≥ 5 KYC'd Pioneers/app → claim domains → track renewals | `[Planned State]` |
| **G4 — Retain & Expand** | Community loop (§10) + next campaigns (Merchant 500, Builder, Ambassador) | `[Future Vision]` |

---

## 13. Risks & Mitigations

| # | Risk | Severity | Mitigation |
|---|------|----------|------------|
| R1 | A fabricated/estimated number reaches Pi Core Team | P0 | §7 rule #1 — counters are real or `0`, enforced in code |
| R2 | Broken/undeployed app link on the campaign page → bad first impression | P1 | Page lists only **LIVE** registry apps; count derived, never hard-coded |
| R3 | Over-gating (KYC/payment) suppresses participation | P1 | §6 — Pi enforces KYC; campaigns stay free + login-only |
| R4 | Privacy misstep (IP-derived geo leaderboard) | P1 | §7 rule #3 — opt-in only, owned by Analytics |
| R5 | Growth re-implements stats/reputation (two sources of truth) | P2 | §8 ownership map (P5) |
| **R6** | **Users open 24 apps without understanding TEC** — empty or valueless landings read as a hollow "app farm" to the Pi Core Team | **P0** | **Every app MUST deliver real standalone value — no empty landing pages.** A campaign never drives traffic to an app that isn't genuinely usable. Adoption is judged on the *value delivered*, not the *count of apps opened*. |

---

## 14. Open Questions

1. **Founding cohort scope** — keep the cap at 100, or add tiers (next 500 = "Early")?
2. **Referral / Ambassador mechanic** — attribution + anti-abuse before any invite reward.
3. **Per-app mission depth** — v1 "open" vs. richer per-app missions (Pioneer Runtime charter, Phase C).
4. **Next campaign trigger** — what platform readiness gates Merchant 500 / Builder Program?
5. **Incentive budget** — any Pi-denominated reward obeys ADR-007 + §7 (no false scarcity); default = none.

---

## Related Documents

- **Pioneer Runtime charter** (proposed) — the `/pioneers` runtime + event/mission contract
- **C-105** — Analytics Constitutional Runtime (owns all growth statistics + the event chain §4)
- **C-126 / C-127 / C-128** — Legend / Elite / VIP (reputation & recognition surfaces)
- **C-108 / C-111** — Explorer / Alert (discovery & activity feed)
- **C-123** — Pi Browser Session & Cookie Spec (why login works the way it does)
- **C-76 / ADR-007** — Pi payment ownership (any payment surface)
- **C-132** — Modules-First (the `pioneer` module lives in `tec-identity-service`)
- **C-47** — Kernel Spec (P3 · P4 · P5 Layer Responsibility · P6 Fail Closed · honesty)
