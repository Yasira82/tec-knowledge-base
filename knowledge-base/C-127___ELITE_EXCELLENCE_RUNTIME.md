# C-127 — ELITE EXCELLENCE RUNTIME

## TEC Ecosystem — Excellence Layer

> **Truth State:** `[Future Vision]`
> **Governance State:** `[Draft]`
> **Verification:** `[Assumed]`
> **Authority Scope:** `[Domain]`
> **Build Gate:** Phase 3 (Legend operational + 5k+ users)
> **Domain:** `elite.tecosystem.app` (live pattern now) → `elite.pi` (future)

---
## Implementation Status (2026-07-31)

> **Truth State:** `[Current State]` for the recognition read layer + the criteria engine · `[Future Vision]` for full multi-signal scoring
> **Verification:** `[Code Verified]` · deployment per app CLAUDE.md

Elite's V0/V1 recognition read layer is built in `tec-identity-service` + `tec-elite`,
merged to `main` (programs · tiers · criteria-met status · `/recognition/[id]`).

**Downstream edge LIVE — Elite → VIP:** VIP checks an owner's ACTIVE Elite recognition
live and surfaces the VIP `ELITE` tier (C-128). `[Code Verified]`.

**Upstream edge WIRED — Legend → Elite (criteria engine):** `EliteService.evaluateOwner`
reads the owner's Legend evidence via `LegendService.getStatsForOwner` — the
Analytics-computed `score_*` (relayed, never recomputed) + real verified-achievement /
Zone-verified counts — and grants recognition on transparent thresholds. The Legend
outcome consumer triggers it after each recorded achievement. `[Code Verified]`
(tec-core-backend #159). **Constitutional guarantees:** recognition is **earned, not
sold** (no grant endpoint — the engine is the only automated path); **GOLD/PLATINUM are
never auto-active** — they land as `CANDIDATE` for a human `PANEL`; a dropped criterion
`EXPIRES` an automated grant (never deleted); a human PANEL decision is never downgraded.
Elite compares thresholds only — Analytics owns the scores, Legend owns the evidence.

**Still `[Future Vision]`:** richer multi-signal criteria (weighted composites, decay,
cross-program rules) as Analytics' scoring matures — the V1 engine grants on one metric
per program.

---

## Institutional Identity

```
Excellence Runtime
System of Recognition (User Layer)
```

---

## Mission

Officially recognize the top performers,
most trusted builders, and highest contributors
in the Pi ecosystem — based on verified evidence,
not self-promotion or paid placement.

---

## Core Question

```
"Are you among the best?"
```

---

## Institutional Role

```
Elite is the institutional recognition layer of TEC.

Where Legend records what you achieved,
Elite officially recognizes that you are exceptional.

Where VIP delivers benefits,
Elite is the credential that justifies those benefits.

Elite recognition is:
  Evidence-based (from Legend)
  Institutionally granted (not self-claimed)
  Time-bounded (renewed periodically)
  Publicly verifiable (anyone can check)
```

---

## The Critical Distinction

```
Legend answers: "What have you done?"
Elite answers:  "Are you officially recognized as exceptional?"
VIP answers:    "What privileges do you receive?"

A user can have a strong Legend without Elite recognition.
Elite recognition requires crossing a threshold
that TEC governance defines and enforces.

Elite is NOT a popularity contest.
Elite is NOT a payment tier.
Elite is NOT a social status.

Elite is an institutional certification
of verified exceptional performance.
```

---

## Authority Boundary

### Elite OWNS

```
Recognition Programs:
  Top Merchants        → Commerce performance leaders
  Top Creators         → Epic + Assets creation leaders
  Top Investors        → FundX capital deployment leaders
  Top Builders         → Developer contribution leaders
  Top Community Leaders → Connection community builders
  Pi Legends           → Overall ecosystem leaders
  Zone Pioneers        → First movers in Zone verification
  Founding Members     → Early TEC contributors

Recognition Tiers (per program):
  ELITE_BRONZE    → top 10% (entry recognition)
  ELITE_SILVER    → top 5% (established excellence)
  ELITE_GOLD      → top 1% (peak performance)
  ELITE_PLATINUM  → top 0.1% (exceptional rarity)

Recognition Records:
  Official certification per user per program
  Renewal cycles (quarterly / annually)
  Historical record (past Elite periods retained)
  Revocation records (if criteria violated)

Recognition Artifacts:
  Elite certificate (verifiable on-chain proof)
  Embeddable Elite badge
  Elite profile page (elite.pi/@username)
  Ecosystem recognition announcement
```

### Elite DOES NOT OWN

```
Score computation       → Analytics computes from Legend data
Achievement recording   → Legend records outcomes
Benefit delivery        → VIP delivers premium experiences
Identity verification   → Hub + Zone own identity
Governance authority    → System governs the platform
Economic execution      → payment-service executes
```

---

## Recognition Criteria Model

```
Constitutional Rule:
  Elite recognition is criteria-based only.
  No exceptions. No overrides. No paid recognition.

Criteria are defined by:
  Platform Governance (System) — sets thresholds
  Analytics — computes whether criteria are met
  Legend — provides the evidence
  Human review — final approval for GOLD + PLATINUM

Criteria dimensions (per program):
  Volume threshold    → minimum activity level
  Quality threshold   → minimum success rate / score
  Time threshold      → minimum period of activity
  Zone verification   → must be Zone-verified
  Legend score        → minimum Legend composite score

Example — Top Merchant (BRONZE):
  ✓ 100+ completed Commerce transactions
  ✓ 95%+ completion rate
  ✓ Zone verified merchant
  ✓ Legend Merchant Score ≥ 70
  ✓ Active in last 90 days

Example — Pi Legend (PLATINUM):
  ✓ Top 0.1% across 3+ dimensions
  ✓ Zone verified (highest tier)
  ✓ Legend composite score ≥ 95
  ✓ 2+ years of consistent Pi activity
  ✓ Human review panel approval
```

---

## Technical Architecture (Planned)

```
Pi Browser (WebView)
    ↓
elite.tecosystem.app (Vercel — Next.js 15)
    ↓
BFF /api/* routes
    ↓
API Gateway :3000 (Railway)
    ↓
elite-service (NEW — Phase 3)
analytics-service → criteria evaluation
legend-service    → achievement evidence
zone-service      → verification status
system-service    → criteria governance
```

### Core Entities

```typescript
interface EliteRecognition {
  recognition_id:     string;
  user_id:            string;
  program:            EliteProgram;     // TOP_MERCHANT | TOP_CREATOR | PI_LEGEND...
  tier:               EliteTier;        // BRONZE | SILVER | GOLD | PLATINUM
  status:             RecognitionStatus;// ACTIVE | EXPIRED | REVOKED
  criteria_snapshot:  CriteriaResult;   // evidence at time of recognition
  granted_at:         string;
  valid_until:        string;           // renewal required
  granted_by:         string;           // SYSTEM (auto) | PANEL (manual)
  certificate_hash:   string;           // on-chain verification proof
  public:             boolean;
}

interface CriteriaResult {
  program:            EliteProgram;
  tier:               EliteTier;
  evaluated_at:       string;
  dimensions: {
    volume:           { value: number; threshold: number; passed: boolean };
    quality:          { value: number; threshold: number; passed: boolean };
    zone_verified:    { value: boolean; passed: boolean };
    legend_score:     { value: number; threshold: number; passed: boolean };
    activity_days:    { value: number; threshold: number; passed: boolean };
  };
  overall_passed:     boolean;
  next_evaluation:    string;
}
```

---

## Recognition Lifecycle

```
1. EVALUATION (automated — Analytics + Legend):
   System evaluates all users against criteria
   Runs: daily for BRONZE/SILVER, weekly for GOLD, monthly for PLATINUM

2. CANDIDATE (criteria met — automated):
   User meets all criteria
   System flags as CANDIDATE
   Notification sent to user

3. REVIEW (human required for GOLD + PLATINUM):
   GOLD:     1 reviewer approval
   PLATINUM: 3 reviewer panel consensus
   Timeline: 7 days max

4. RECOGNITION (granted):
   Certificate issued
   Badge activated
   Legend record updated
   VIP tier updated (if applicable)
   Announcement (user-consent required)

5. RENEWAL (periodic):
   BRONZE/SILVER: quarterly evaluation
   GOLD:          semi-annual evaluation
   PLATINUM:      annual evaluation
   If criteria no longer met → EXPIRED (not REVOKED)

6. REVOCATION (governance decision only):
   Zone verification revoked
   Fraud detected
   Platform governance violation
   Requires System authority approval
```

---

## Security Model

```
Recognition integrity:
  Criteria are immutable per evaluation period
  No retroactive criteria changes
  All recognitions cryptographically signed
  Certificate hash verifiable independently

Anti-gaming:
  Criteria evaluated on rolling periods (not single points)
  Volume spikes investigated before GOLD/PLATINUM
  Suspicious patterns trigger manual review

Revocation authority:
  BRONZE/SILVER: Analytics + Zone (automated)
  GOLD:          Platform Governance (human)
  PLATINUM:      CEO authority (highest level)
```

---

## Infrastructure Dependencies

```
Analytics       → criteria evaluation (REQUIRED)
Legend          → achievement evidence (REQUIRED)
Zone            → verification status (REQUIRED)
System          → criteria governance (REQUIRED)
VIP             → benefit delivery (consumes Elite status)
Connection      → recognition announcement network
notification-service → recognition alerts
```

---

## Revenue Model

```
Elite recognition itself:
  FREE — recognition cannot be purchased
  Recognition is earned, never bought

Elite-adjacent revenue:
  Elite verification API (for external Pi apps)
    → "Is this user Elite verified?"
    → API calls: 0.01π per call (enterprise)

  Elite profile customization (VIP feature)
    → Enhanced Elite page
    → Included in VIP Pro

  Elite certificate (physical/digital premium)
    → Printable certificate: 5π
    → NFT certificate on Assets: 10π

  Elite events (Phase 3+):
    → Annual Pi Elite Summit
    → Private investment rounds (FundX)
    → Elite networking events (Connection)
```

---

## Key Metrics

```
Primary (Recognition Quality):
  Ratio of Elite to total users (target: < 10% for BRONZE)
  Recognition accuracy (% retained through renewal)
  Revocation rate (should be < 1%)
  Time from criteria met to recognition (target: < 7 days)

Secondary:
  Elite → VIP conversion rate
  Elite status effect on Legend score growth
  Elite user retention vs non-Elite
  External verification API calls (ecosystem adoption)
```

---

## Relationship Chain

```
Legend (evidence)
    ↓
Elite (recognition)
    ↓
VIP (experience)

This chain is constitutionally ordered:
  No Elite without Legend evidence
  No VIP elite tier without Elite recognition
  No recognition without criteria satisfaction
  No criteria without System governance

Breaking this chain
= arbitrary status system
= loss of institutional credibility.
```

---

## Positioning Statement

```
Elite is not a premium subscription.
Elite is not a social rank.
Elite is not a popularity metric.

Elite is the Excellence Runtime of TEC —
the institutional layer that officially recognizes
those who have demonstrably earned recognition.

In a world where status is often purchased,
Elite status in TEC is earned.

Evidence before recognition.
Performance before privilege.
Achievement before acknowledgment.

This is what makes Elite recognition
meaningful — in TEC and across Pi.
```

---

## Related Documents

- **C-00** Platform Constitution · **C-47** Kernel Spec (P6 Fail Closed, ActorContext, custody Invariant #8)
- **C-70** Event Governance (`domain.action.version`) · **C-105** Analytics (score/metric computation)
- **C-110** System (criteria governance) · **C-126** Legend (evidence) · **C-128** VIP (consumes status)
- **C-12** Dual-Mode Payment (anti-regression) · **C-123** Pi Browser Session & Cookie Spec (login/cookies)
