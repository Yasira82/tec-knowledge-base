# C-133 — GROWTH & GO-TO-MARKET GOVERNANCE

## TEC Platform — Marketing, Pioneer Campaign & Domain-Claim Strategy

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`
> **Authority Scope:** `[Platform]`
> **Decision Authority:** CEO (C-47)

> **TL;DR (عربي):** ده المرجع الرسمي الوحيد لشغل الـ **Growth / Marketing**. الهدف الحقيقي
> مش "تسويق" مجرّد — الهدف **استلام دومينات Pi للـ 24 app** (كل دومين محتاج ≥5 Pioneers مُوثّقين
> على Pi بيتفاعلوا). أداة الحملة: صفحة **`/pioneers` (Founding 100)** — لينك واحد يمشّي المستخدم
> على الـ 24 كلهم. **قاعدة حاكمة: ممنوع أي رقم مزيّف** (لو مفيش Pioneers اعرض 0) — مصداقيّتنا مع
> Pi Core Team هي الأصل. الـ **KYC بيفرضه Pi نفسه** (المحفظة/الدفع مبيشتغلوش من غير Pi KYC)، فإحنا
> **مابنتحققش منه** — بنعرض بس. الـ Growth **بيعرض** (Conductor)؛ الأرقام مملوكة لـ Analytics،
> السمعة لـ Legend، حالة الـ Pioneer لـ `tec-identity-service`.

---

## 0. Why this document exists

Growth was scattered across chats and one-off assets. This document makes it a
**single source of truth**: what we are selling, to whom, how a visitor becomes an
engaged member, and the **non-negotiable honesty rules** that protect our credibility
with the Pi Core Team. It governs the Pioneer campaign, the `/pioneers` runtime, the
domain-claim strategy, and every launch asset.

> This is a **governance** document, not a campaign calendar. Dated tactics live in
> `audits/` or issues; the *rules and strategy* live here.

---

## 1. Positioning & Narrative

**TEC is the first full Pi-native economy** — not one app, but **24 live apps** sharing
one identity, one wallet contract, and real Pi payments: commerce, assets, real estate,
reputation, opportunities, coordination, protection, and more.

| | |
|---|---|
| **One-liner** | "The first complete economy built on Pi — 24 apps, one identity, real Pi." |
| **Primary audience** | KYC-verified Pi Pioneers (the only actors who can transact on Pi). |
| **Secondary** | Pi merchants/builders (supply side), Pi community channels, Pi Core Team (credibility). |
| **Emotional hook** | "Be one of the first 100 to shape it" (scarcity + belonging). |

---

## 2. The North-Star & Funnel

The **North-Star** is **claimed Pi domains** — a claimed domain is proof of *real,
KYC-verified engagement*, which is exactly what a durable Pi economy needs. Marketing
is measured against that, not vanity reach.

```
Discover  →  Open in Pi Browser  →  Log in with Pi  →  Engage (Quest)  →  Founding Pioneer  →  Legend
 (channels)     (per-App-ID)          (SSO once)       (open the apps)     (badge, first 100)   (reputation)
```

Every stage maps to an owning surface (§6). The funnel is **honest by construction** —
each counter is real service data or shows `0`.

---

## 3. The Pioneer Campaign — "Founding 100"

The campaign's flagship asset is the public **`/pioneers`** runtime (Hub —
`hub.tecosystem.app/pioneers`). Its design evolution is governed by the **Pioneer
Runtime charter** (proposed — the `/pioneers` runtime design authority; to be adopted
into the KB with a free C-number).

| Element | Rule |
|---------|------|
| **One link, all apps** | The page lists every **LIVE** app (from `_registry.ts` SSoT — count is derived, never hard-coded). One link replaces 24. |
| **Pioneer Quest** | Open each app in Pi Browser while logged in. The ✓/progress track engagement and gate on **login** (not on a KYC flag TEC doesn't store). |
| **Founding Pioneer badge** | The first **100** to complete the Quest earn a permanent recognition in their TEC reputation (Legend / VIP). Cap = 100, assigned **atomically server-side**, `remaining` never negative. |
| **Zero cost** | **No payment required.** The badge is earned by *completing the Quest*. Requiring payment adds friction that suppresses participation. |
| **Browsing open to all** | Anyone may browse the apps; only a logged-in visitor accrues progress. |

Backend authority: the `pioneer` module in `tec-identity-service` (Modules-First, C-132) —
public honest `/stats`, own-scoped quest, atomic Founding assignment.

---

## 4. Domain-Claim Growth Strategy (the real objective)

Claiming a Pi domain for an app requires **≥ 5 unique KYC-verified Pioneers engaging**
with that app. Two facts shape the whole strategy:

1. **Engagement is per-App-ID.** Each app has its own Pi App ID, so a Pioneer must open
   **that app at its own domain** in Pi Browser — not merely navigate inside the Hub.
   This is why `/pioneers` links each app to its **own** domain.
2. **Pi Network enforces the KYC requirement itself.** Pi counts only KYC-verified
   Pioneers toward a domain's engagement, using Pi's own KYC data. **TEC does not — and
   need not — verify Pi KYC** (the wallet/payment simply doesn't function without it).

**Implication (a real time-saver):** our layer must **not** try to duplicate Pi's KYC
gate. We drive *engagement*; Pi does the *filtering*. Attempting an in-house KYC gate
using TEC's internal doc-KYC (a separate, rarely-completed flow) is an anti-pattern —
it breaks real Pi-verified users and buys nothing.

**Playbook per app:** recruit ≥ 5 KYC'd Pioneers → each opens the app in Pi Browser +
logs in + does one action → claim the domain → track renewals.

---

## 5. Honesty & Compliance Constraints (non-negotiable)

Credibility with the Pi Core Team is the platform's most valuable growth asset. It is
protected by hard rules:

1. **No fabricated data — anywhere.** Counters (Founding, stats, feed, community) show
   **real service data or `0`/empty**. Never a marketing number. (Enforced in code: the
   Founding counter renders only from the backend `/stats`.)
2. **KYC is Pi's, not ours.** Never claim to verify Pi KYC; never gate on a KYC signal
   TEC does not hold. Present, never assert.
3. **Privacy.** No leaderboard or segmentation derived from data the user never
   consented to share (e.g. IP → country). Any geo/edu segmentation is opt-in and owned
   by Analytics (C-105).
4. **No impersonation / no false scarcity.** "Founding 100" is a *real* cap of 100 — not
   a rolling fake-urgency banner.
5. **Payment claims.** Any payment surface obeys ADR-007 (C-76) and states cost
   truthfully; the campaign itself requires no payment.

---

## 6. Ownership Map (P5) — Growth presents, it does not own

> The same rule as the rest of the platform: the presenting surface is the **Conductor,
> not the Owner**. Duplicating owned truth into Growth = two sources of truth = forbidden.

| Concern | Owning domain / service | Growth's role |
|---------|-------------------------|---------------|
| Pioneer state (quest, journey, Founding number) | `tec-identity-service` → `pioneer` module | Read + present |
| Statistics / aggregate counters | **Analytics** (C-105) | Display real numbers |
| Reputation (permanent, evidence-based) | **Legend** (C-126) | Link the badge |
| Recognition / tiers | **Elite** (C-127) / **VIP** (C-128) | Display eligibility |
| Activity feed | **Alert** (C-111) | Embed |
| Discovery / recommendations | **Explorer** (C-108) | Route |
| Identity / KYC | Pi Network + `tec-auth-service` | Never re-derive |

---

## 7. Channels & Assets

| Asset | Purpose | Status |
|-------|---------|--------|
| **`/pioneers` onboarding page** | The one link — all 24 apps + the 3-step guide + Quest + Founding badge | `[Current State]` — live |
| **Recruitment post (EN + AR)** | Short post for Pi/Telegram groups: what TEC is + the ask + the link | `[Current State]` — drafted |
| **Per-app launch posts (24)** | One post per app for app-specific channels | `[Planned State]` |
| **Pioneer FAQ** | Answers the friction questions (Why Pi Browser? What's KYC? Is it free?) | `[Planned State]` |
| **Launch calendar** | Teaser → launch → per-app spotlight → milestone posts | `[Planned State]` — lives in `audits/`/issues, not here |

**Channels:** Pi community groups (Telegram/Discord), Pi ecosystem directories, TEC's own
apps (cross-link `/pioneers`), and word-of-mouth via the Founding cohort.

---

## 8. Metrics & KPIs

| Metric | Definition | Owner |
|--------|------------|-------|
| **Domains claimed** | # of the 24 apps with a claimed Pi domain (North-Star) | Ops + Growth |
| **Pioneers / app** | Unique KYC'd Pioneers engaging per app (target ≥ 5) | Pi Portal + Analytics |
| **Activation rate** | Logged-in visitors who open ≥ 1 app / total visitors | Analytics (C-105) |
| **Quest completion** | Pioneers who open all live apps / logged-in visitors | `pioneer` module `/stats` |
| **Founding fill** | Founding numbers claimed / 100 | `pioneer` module `/stats` |
| **Retention** | Pioneers returning to ≥ 1 app after 7 / 30 days | Analytics |

> All figures are **real** service reads. A KPI with no data source shows `0`, not an
> estimate (§5).

---

## 9. Phasing

| Phase | Deliverable | State |
|-------|-------------|-------|
| **G0 — Foundation** | `/pioneers` live + honest counter + Founding badge (no payment) | `[Current State]` |
| **G1 — Recruit** | Recruitment post + FAQ; seed the first Founding cohort in Pi groups | `[Planned State]` |
| **G2 — Amplify** | Per-app launch posts; cross-link `/pioneers` from every app | `[Planned State]` |
| **G3 — Claim** | Reach ≥ 5 KYC'd Pioneers/app → claim domains → track renewals | `[Planned State]` |
| **G4 — Retain** | Advanced challenges route Founding Pioneers deeper (Commerce/Epic/Legend…) | `[Future Vision]` |

---

## 10. Risks & Mitigations

| # | Risk | Severity | Mitigation |
|---|------|----------|------------|
| R1 | A fabricated/estimated number reaches Pi Core Team | P0 | §5 rule #1 — counters are real or `0`, enforced in code |
| R2 | Broken/undeployed app link on `/pioneers` → bad first impression | P1 | Page lists only **LIVE** registry apps; count derived, never hard-coded |
| R3 | Over-gating (KYC/payment) suppresses participation | P1 | §4 — Pi enforces KYC; campaign is free + login-only |
| R4 | Privacy misstep (IP-derived geo leaderboard) | P1 | §5 rule #3 — opt-in only, owned by Analytics |
| R5 | Growth re-implements stats/reputation (two sources of truth) | P2 | §6 ownership map (P5) |

---

## 11. Open Questions

1. **Founding cohort scope** — keep the cap at 100, or add tiers (next 500 = "Early")?
2. **Referral mechanic** — attribution + anti-abuse before any invite reward.
3. **Per-app mission depth** — v1 "open" vs. richer per-app missions (Phase C of the
   proposed Pioneer Runtime charter).
4. **Incentive budget** — if any Pi-denominated reward is ever added, it obeys ADR-007
   and §5 (no false scarcity); default = no paid incentive.

---

## Related Documents

- **Pioneer Runtime charter** (proposed) — the `/pioneers` runtime this campaign rides on
- **C-105** — Analytics Constitutional Runtime (owns all growth statistics)
- **C-126 / C-127 / C-128** — Legend / Elite / VIP (reputation & recognition surfaces)
- **C-108 / C-111** — Explorer / Alert (discovery & activity feed)
- **C-123** — Pi Browser Session & Cookie Spec (why login works the way it does)
- **C-76 / ADR-007** — Pi payment ownership (any payment surface)
- **C-132** — Modules-First (the `pioneer` module lives in `tec-identity-service`)
- **C-47** — Kernel Spec (P5 Layer Responsibility · P6 Fail Closed · honesty)
