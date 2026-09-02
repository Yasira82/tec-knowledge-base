# C-106 — LIFE INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** [Future Vision]
**Governance State:** [Draft]
**Verification State:** [Assumed]
**Authority Scope:** [Domain]
**Decision Status:** [Exploratory]

---
## Deployment Status (2026-07-31)

> **Truth State:** `[Current State]` for the deployed app + live payment · `[Future Vision]` for the full runtime below
> **Verification:** `[Runtime Verified]` — deployed on Mainnet, real Pi payment live (SSoT: `architecture/app-fleet.yaml` → `live-verified`)

**Life is deployed on Mainnet** with Hub SSO and dual-mode (ADR-007) Pi payment live:
- **Domain:** `life.tecosystem.app` · **Pi App ID:** `life-app-c468e9eb5bf115fa` · **APP_SOURCE:** `life`
- **Payment:** real Pi subscription — Mode 1 (Hub) + Mode 2 (standalone); `PI_API_KEY_LIFE` set on payment-service.
- **Hub SSO:** enabled (in `/api/auth/sso` ALLOWED_TARGETS + Hub domain registry).
- **Growth:** referral loop wired (C-133).

**Still `[Future Vision]`:** the advanced runtime described below (V2+ / the charter's later phases) — vision, not yet built.

---


## Verification Audit — NO CHANGE REQUIRED (2026-09-02)

> Truth State: **[Current State]** · Verification: **[Code Verified]** — audit only, no code
> changed. Session 50.

Life was audited alongside Connection, Explorer, Commerce, Ecommerce and Assets while five
dead verification badges were being fixed across the fleet.

**Life has no verification concept, and correctly so.** It is the System of Record for a
person's own context — goals, preferences, activity, trajectory. There is no *entity* to
verify: a goal is not a claim about the world that a reviewer could confirm or refuse, and
the identity behind it is already established by Hub SSO before any Life row exists.

Recorded here because a negative finding is still a finding: the next audit should not have
to re-derive that Life's lack of a Zone integration is a boundary, not a gap.

## 1. MISSION

Model each user's personal economic context — goals, skills, activities, spending, and trajectory — to create the foundational data layer that makes the entire TEC ecosystem personal and relevant.

---

## 2. INSTITUTIONAL ROLE

```
System of Record — Personal Economic Context Infrastructure
```

Life is the **memory** of the TEC economic identity. Without Life, TEC AI has no personal context, Connection has no relationship baseline, and Ecommerce has no personalization signal.

---

## 3. ECONOMIC PURPOSE

زيادة retention والذكاء الشخصي داخل النظام.

- بدون Life: كل user تجربته generic → churn
- بوجود Life: TEC يعرف كل user → relevant experience → retention
- اقتصادياً: 1 retained user = more lifetime Pi transactions than 5 churned users

---

## 4. AUTHORITY BOUNDARY

### Owns
- User goals and aspirations (self-declared)
- Skills inventory (self-declared + activity-inferred)
- Activity timeline (spending, trading, creating)
- Preferences and settings
- Personal trajectory (where user is headed)
- Intent signals (what user is trying to do now)

### Does NOT Own
- Payment history truth (owned by tec-payment-service)
- Asset ownership (owned by tec-asset-service)
- Identity verification (owned by tec-auth-service)
- Relationship graph (owned by Connection — C-107)
- Economic recommendations (owned by TEC AI — C-104)

### Interface Points
```
OUTBOUND:
  Personal context API  → TEC AI (C-104) — consent required
  Activity signals      → Analytics (C-105)
  User intent signals   → Nexus (C-109) for coordination

INBOUND:
  tec_user cookie      → identity anchor
  payment.completed.v1 → activity timeline (from analytics)
  order.created.v1     → spending history
  User self-declaration → goals, skills, preferences
```

---

## 5. TECHNICAL ARCHITECTURE

```
Planned Stack:
  Next.js 15 App Router + TypeScript strict
  @yasser172/tec-ui (shared design system)
  tec-identity-service (4004) — user profile storage
  tec-analytics-service (4007) — activity signals
  Redis — intent signal cache (TTL: 30min)

Data Architecture:
  Hot data (active goals, current intent): Redis
  Warm data (recent activity, preferences): tec-identity-service DB
  Cold data (historical timeline): tec-analytics-service archive

Consistency:
  Self-declared data: strong (user controls it)
  Activity-inferred data: eventual (from event stream)
  Intent signals: Redis with TTL (recalculated on context load)

Privacy Model:
  Life data is sovereign — user controls what TEC AI sees
  Explicit consent per data category before AI consumption
  Right to delete: purge all Life data while keeping payment records
  (payment records owned by payment-service — Life cannot delete those)
```

---

## 6. SECURITY MODEL

```
Data Sovereignty:
  Users OWN their Life data — TEC platform hosts, not owns
  Consent granularity: category-level (goals YES, skills NO, etc.)
  No Life data shared with external parties

Access Control:
  User: full read + write on own Life
  TEC AI: read-only, consent-gated, purpose-limited
  Analytics: aggregate signals only (anonymized)
  Other users: NO access (completely private)

P6 Fail Closed:
  Missing consent → TEC AI gets no Life context
  Expired consent → context revoked immediately
  Unknown actor → deny Life data access
```

---

## 7. REVENUE MODEL

**Indirect (Retention + Personalization)**

| Channel | Mechanism | Value |
|---------|-----------|-------|
| Retention | Personal experience → lower churn | Platform-level |
| Personalization | Better recommendations → more transactions | Platform-level |
| Premium Planning | Life coaching + goal tracking features | PRO subscription |
| Life Analytics | Personal economic reports | PRO subscription |

Life does not charge per feature — its economic value flows through retention and the intelligence it provides to TEC AI.

---

## 8. KEY METRICS

```
Profile Completion Rate:   Target ≥ 70% of active users
Context Load Latency:      < 200ms (Redis hot path)
Consent Coverage:          Track % of users granting AI access
Retention Impact:          Compare 30d retention: Life users vs non-Life
Data Sovereignty Actions:  Track delete requests, consent changes
Activity Timeline Lag:     < 5min (from event to Life timeline)
```

---

## 9. ECOSYSTEM CONTRIBUTION

- **Personalization Foundation** — makes Ecommerce, Commerce, and Hub relevant per user
- **TEC AI Context** — primary personal context source for reasoning
- **Trajectory Intelligence** — enables proactive suggestions (not reactive)
- **Retention Engine** — personal investment in TEC increases switching cost

---

## 10. FUTURE EVOLUTION

```
Phase 1 (MVP — post Phase 0):
  → Spending timeline (Pi transactions over time)
  → Budget tracking (user-set Pi budget categories)
  → Cash flow view (income vs spending)

Phase 2:
  → Goal setting + progress tracking
  → Skills inventory + marketplace matching
  → Life coaching (TEC AI integration)

Phase 3:
  → Personal Economic Operating System
  → Cross-app life context (all TEC apps contribute to Life)
  → Economic trajectory planning (5-year Pi wealth building)
```

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 (Pre-Launch Requirement):**
```
[P0-1] Privacy Architecture First
  Before any Life data is stored, define:
  - Consent schema (category-level, timestamped)
  - Deletion guarantees (what gets deleted vs archived)
  - Data classification (what is personal vs aggregate)
  Do not launch Life without legal/privacy review.

[P0-2] Identity Anchor Protocol
  Life data tied to tec_user.piUsername (permanent Pi identity)
  Not tied to internal TEC user ID (which could change)
  This ensures Life survives identity migrations.
```

**P1:**
```
[P1-1] Event Stream Consumer
  Life needs to consume: payment.completed.v1, order.created.v1
  from Redis Streams to build activity timeline automatically.
  (Without this, Life is purely self-declared — low adoption)

[P1-2] Consent Gateway
  Middleware layer that checks consent before any Life data leaves
  the service. NEVER bypass for TEC AI or any other consumer.
```

---

## 11a. IMPLEMENTATION STATUS (Session 18 — July 2026)

**Truth State:** [Planned State] · **Verification:** [Code Verified] — built and merged,
not yet deployed / Runtime Verified. (The charter header stays [Future Vision] until Life
is live at `life.tecosystem.app`.)

```
Phase 0 — app customized from tec-template-base (tec-life repo):
  ✅ Identity: APP_SOURCE 'life' · sso-callback audiences → life.tecosystem.app ·
     privacy/terms → TEC Life · NEW-A (no gateway URL in client bundle) ·
     hub-entry-aware Pi init (C-12 §3 / ADR-007). Domain life.tecosystem.app.
  ✅ Pi App ID REGISTERED: life-app-c468e9eb5bf115fa (C-01) · Vercel vars set.
  ✅ C-123 login: SSO callback migrated to the 200 HTML landing + verified entry
     (/api/auth/me) + none/secure/Partitioned cookies + hub-entry flag (LAW 2/3, §3).

FEATURE slice 1 — Goals & Preferences (self-declared → STRONG consistency):
  ✅ Store: tec-identity-service — LifeGoal (title/description/status/target_date) +
     LifePreference (key/value, unique per user+key). @Controller('identity/life') →
     served by the existing /api/identity/* gateway route (no gateway change).
  ✅ Isolation (P6 / §6): owner = the verified session identity resolved via
     findOrCreateUser from the JWT's Pi uid (P0-2 identity anchor — Pi identity, not a
     mutable internal id); never a query/body param. Ownership enforced in the WHERE
     clause (non-owner → 0 rows → 404). 8 service tests.
  ✅ Frontend: /api/bff/life/{goals,goals/[id],preferences} → gateway; interactive
     Goals (add/done/delete) + Preferences (focus, language) in /app.

FEATURE slice 2 — Activity timeline (eventual):
  ✅ /app "Activity" presents the caller's OWN recent events (payment/order/join)
     newest-first, read from Analytics (GET /analytics/me/activity, strict own-scope,
     fails closed on internal key) via /api/bff/life/activity. C-106 §4 realised: activity
     signals come FROM Analytics — Life PRESENTS, never stores/re-derives transaction truth.
     ARCHITECTURE NOTE — [P1-1] "event-stream consumer INSIDE Life" was NOT needed:
     Analytics already consumes payment.completed.v1 / order.created.v1 and stores them
     per-user, so Life reads that own-scope signal instead of duplicating the stream
     (no new consumer, no re-derivation — the cleaner path).

Pending (this slice → live):
  □ Deploy tec-identity-service (db push adds life_goals + life_preferences) BEFORE the
     frontend, then wire life.tecosystem.app on Vercel (API_GATEWAY_URL, INTERNAL_SECRET,
     SSO_SECRET). Backend-first per the release chain.
  □ P0-1 privacy: consent schema + [P1-2] consent gateway are NOT built. Not yet needed —
     Life data is self-declared and is NOT exposed to any other app (esp. TEC AI) yet.
     Required BEFORE any OUTBOUND Life-context API (C-106 §4 Interface Points) is opened.
```

---

## 12. INTEGRATION MAP

```
This charter (C-106) depends on:
  C-100 HUB       → SSO identity anchor
  C-105 ANALYTICS → activity signals from event stream
  C-110 SYSTEM    → consent governance policies

Other charters depend on this one for:
  C-104 TEC AI    → personal context (consent-gated)
  C-107 CONNECTION → relationship baseline (activity overlap)
  C-103 ECOMMERCE → personalized product recommendations
  C-101 COMMERCE  → merchant context (if merchant has Life profile)
```
