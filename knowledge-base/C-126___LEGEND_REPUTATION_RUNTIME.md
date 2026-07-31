# C-126 — LEGEND REPUTATION RUNTIME

## TEC Ecosystem — Reputation Layer

> **Truth State:** `[Future Vision]`
> **Governance State:** `[Draft]`
> **Verification:** `[Assumed]`
> **Authority Scope:** `[Domain]`
> **Build Gate:** Phase 2 (1k+ users + Zone operational)
> **Domain:** `legend.tecosystem.app` (live pattern now) → `legend.pi` (future)

---
## Implementation Status (2026-07-31)

> **Truth State:** `[Current State]` for the V0/V1 read layer + event ingestion · `[Future Vision]` for the full CV/badges
> **Verification:** `[Code Verified]` (merged) · deployment per app CLAUDE.md

Legend's V0/V1 is built in `tec-identity-service` (backend) + `tec-legend` (frontend),
merged to `main`:
- **Reputation read layer** (profile + achievements, owner-scoped) — Legend records
  OUTCOMES, never claims (the read-layer rule).
- **Event ingestion (write path):** `legend.consumer.ts` (group `identity-legend`)
  consumes `zone.badge.issued.v1` + `epic.project.completed.v1` from Redis Streams and
  records achievements **idempotently by `eventId`** (at-least-once safe, C-70).
  `[Code Verified]`; ingests at runtime only when `REDIS_URL` is set and the consumer runs.

**Still future:** Analytics-computed scores, the Pi Professional CV export, embeddable
badges, and the remaining source streams (fundx/connection). Score computation stays
Analytics' function — Legend serves, never computes.

---

## Institutional Identity

```
Reputation Runtime
System of Evidence (User Layer)
```

---

## Mission

Transform verified economic activity
into a permanent, portable, evidence-based reputation
that follows every Pi user across the ecosystem.

---

## Core Question

```
"What have you achieved?"
```

---

## Institutional Role

```
Legend is the institutional memory of individual achievement.

Where Life stores personal context,
Legend stores proven track record.

Where Zone verifies claims,
Legend records outcomes.

Where Elite grants recognition,
Legend provides the evidence that justifies recognition.

Reputation is not claimed in Legend.
Reputation is earned through verifiable activity
and permanently recorded.
```

---

## The Problem Legend Solves

```
In Pi ecosystem today:
  47M users
  No portable reputation layer
  No evidence-based professional identity
  No verifiable track record

When a Pi user says "I'm a trusted merchant":
  There is no system to verify this claim

When an investor asks "Is this founder reliable?":
  There is no system to answer this

When a partner asks "Has this person delivered before?":
  There is no system to confirm this

Legend answers all three questions
with verifiable evidence.
```

---

## Authority Boundary

### Legend OWNS

```
Achievement Records:
  Commerce achievements  → sales volume, completion rate, reviews
  Asset achievements     → NFTs created, trades completed
  FundX achievements     → investments made, returns achieved
  Epic achievements      → projects completed, milestones reached
  Connection achievements → relationships built, collaborations completed
  Zone badges            → verified milestones from Zone

Reputation Dimensions:
  Merchant Score         → from Commerce activity
  Creator Score          → from Epic + Assets activity
  Investor Score         → from FundX activity
  Collaborator Score     → from Connection activity
  Builder Score          → from Epic + DX activity
  Overall Trust Score    → composite (computed by Analytics)

Pi Professional CV:
  Verified timeline of economic activity
  Exportable professional record
  Embeddable reputation badge
  Public profile (user-controlled visibility)

Badges:
  Top Merchant           → Commerce milestone
  Verified Creator       → Epic completion
  Trusted Investor       → FundX milestone
  Community Builder      → Connection milestone
  Zone Pioneer           → Early Zone verification
  Pi Legend              → composite elite badge
```

### Legend DOES NOT OWN

```
Score computation      → Analytics computes scores from raw data
Verification           → Zone verifies before Legend records
Identity               → Hub owns identity
Elite recognition      → Elite makes official recognition decisions
VIP benefits           → VIP delivers premium experiences
Real-time activity     → Commerce/Assets/FundX own live data
```

---

## Critical Constitutional Rule

```
Legend records OUTCOMES — not CLAIMS.

A user cannot add achievements to Legend manually.
All Legend records originate from:
  Verified activity in Commerce/Assets/FundX/Epic/Connection
  Zone-verified milestones
  Analytics-computed scores

Legend = the read layer of economic achievement.
Every other app = the write layer.

This prevents gaming, fraud, and self-promotion.
Legend is only as trustworthy as the sources that feed it.
```

---

## Technical Architecture (Planned)

```
Pi Browser (WebView)
    ↓
legend.tecosystem.app (Vercel — Next.js 15)
    ↓
BFF /api/* routes (READ-HEAVY — mostly GET)
    ↓
API Gateway :3000 (Railway)
    ↓
legend-service (NEW — Phase 2)
analytics-service  → score computation
zone-service       → verified badges
commerce-service   → merchant achievements
epic-service       → creation achievements
fundx-service      → investment achievements
```

### Core Entities

```typescript
interface LegendProfile {
  user_id:          string;        // Hub Pi identity
  display_name:     string;
  joined_at:        string;

  scores: {
    merchant:       number;        // 0-100
    creator:        number;
    investor:       number;
    collaborator:   number;
    builder:        number;
    overall:        number;        // composite
  };

  achievements:     Achievement[];
  badges:           Badge[];
  timeline:         ActivityRecord[];
  pi_professional_cv: PiCV;
  visibility:       VisibilitySettings;
}

interface Achievement {
  achievement_id:   string;
  type:             AchievementType;
  title:            string;
  description:      string;
  evidence_source:  string;        // commerce | epic | fundx | zone | assets
  evidence_id:      string;        // reference to source record
  verified:         boolean;       // Zone-verified?
  earned_at:        string;
  pi_value?:        PiAmount;      // economic value of achievement
}

interface PiCV {
  summary:          string;        // AI-generated from achievements
  highlights:       Achievement[]; // top 5 user-selected
  total_pi_volume:  PiAmount;
  years_active:     number;
  exported_at?:     string;
}
```

---

## Redis Streams (C-56 — Event Consumption)

```
Legend consumes (read-only — never primary producer):
  payment.completed.v1   → merchant/buyer achievement
  epic.project.completed.v1 → creator achievement
  fundx.investment.closed.v1 → investor achievement
  zone.badge.issued.v1   → verified milestone
  connection.milestone.v1 → collaborator achievement
  asset.transferred.v1   → asset achievement

Legend publishes:
  legend.score.updated.v1 → notify Elite + TEC AI
  legend.badge.earned.v1 → notify user + Connection
```

---

## Security Model

```
Profile visibility:  User controls (PUBLIC | CONNECTIONS | PRIVATE)
Achievement records: Read-only for user — written by source apps
Score computation:   Analytics computes — Legend serves
Export:             User-controlled PDF/JSON export
Deletion:           Scores can be hidden — records are immutable
                    (append-only — constitutional rule)
```

---

## Infrastructure Dependencies

```
Analytics       → score computation (REQUIRED for scores)
Zone            → verified badges (REQUIRED for trust signal)
Commerce        → merchant achievements
Epic            → creation achievements
FundX           → investment achievements
Assets          → ownership achievements
Connection      → collaboration achievements
Hub             → identity (required for all records)
```

---

## Revenue Model

```
Legend Free:
  Basic profile (scores + top 5 achievements)
  Public page (legend.tecosystem.app/@username)

Legend Pro (Hub PRO — 10π/month):
  Full achievement timeline
  Pi Professional CV (exportable)
  Custom profile design
  Achievement badges (embeddable)
  Analytics insights on reputation

Legend Enterprise (Hub ENTERPRISE — 50π/month):
  Organization reputation profile
  Team reputation dashboard
  B2B reputation API access
  Verified Partner badge

External Pi Ecosystem (Phase 3+):
  Reputation API for Pi apps
  Embed Legend score in external Pi platforms
  Pi Professional ID (cross-ecosystem reputation)
```

---

## Key Metrics

```
Primary (Reputation Quality):
  Active Legend profiles
  Achievement records / user (average)
  Zone-verified achievements %
  Profiles with Pi Professional CV exported
  External embeds of Legend badges

Secondary:
  Reputation-to-outcome correlation
    (do high Legend scores lead to better outcomes?)
  Score distribution (Gini coefficient — healthy ecosystem)
  Time to first achievement (new user → first record)
```

---

## Relationship to Elite + VIP

```
Legend → Elite → VIP

Legend provides EVIDENCE:
  "This user has 500 verified commerce transactions"
  "This creator completed 12 Epic projects"
  "This investor has 95% FundX success rate"

Elite uses Legend EVIDENCE to grant RECOGNITION:
  "Based on Legend evidence, this user is Top 100 Merchant"

VIP uses Elite STATUS to grant EXPERIENCE:
  "Elite merchants receive VIP commercial privileges"

The chain:
  Evidence (Legend) → Recognition (Elite) → Experience (VIP)
  is what separates TEC from arbitrary status systems.
```

---

## Positioning Statement

```
Legend is not a leaderboard.
Legend is not a social profile.
Legend is the Reputation Runtime of TEC.

In the Pi economy, reputation is capital.
Capital without reputation cannot be trusted.
Reputation without evidence cannot be verified.
Evidence without permanence cannot be relied upon.

Legend provides permanent, verifiable, portable
evidence of economic achievement
across the entire TEC ecosystem.

Your Legend is not what you say you did.
Your Legend is what the ecosystem confirms you did.

This is the difference between reputation
and a verified economic identity.
```

---

## Related Documents

- **C-00** Platform Constitution · **C-47** Kernel Spec (P6 Fail Closed, ActorContext, custody Invariant #8)
- **C-70** Event Governance (`domain.action.version`) · **C-105** Analytics (score/metric computation)
- **C-120** Zone (verified badges) · **C-127** Elite (recognition) · **C-128** VIP (experience)
- **C-12** Dual-Mode Payment (anti-regression) · **C-123** Pi Browser Session & Cookie Spec (login/cookies)
