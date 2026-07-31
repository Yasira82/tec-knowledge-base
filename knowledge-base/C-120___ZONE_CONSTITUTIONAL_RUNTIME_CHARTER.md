# C-120 — ZONE CONSTITUTIONAL RUNTIME CHARTER

## TEC Ecosystem — Verification Runtime

> **Truth State:** `[Future Vision]`
> **Governance State:** `[Draft]`
> **Verification:** `[Assumed]`
> **Authority Scope:** `[Platform + Ecosystem]`

---
## Implementation Status (2026-07-31)

> **Truth State:** `[Current State]` for V0/V1 (below) · `[Future Vision]` for V2→V4
> **Verification:** `[Code Verified]` (merged) · deployment per app CLAUDE.md

Zone's V0/V1 verification runtime is built in `tec-identity-service` (backend) +
`tec-zone` (frontend), merged to `main`:
- **Verified registry** (V1) + public entity detail — read layer live.
- **Verification workflow** (§7): submit → PENDING → human review (admin-gated),
  evidence append-only, no self-verify, no paid path to VERIFIED.
- **Value chain (verify → earn):** on a confirmed `VERIFY`, `reviewDecision` emits
  `zone.badge.issued.v1` (`stream-emitter.ts`) so Legend records the owner's
  "Earned a Zone verification" achievement. `[Code Verified]`; fires at runtime only
  when `REDIS_URL` is set.

**Still future (§5):** Evidence Registry (V2) → Dynamic Trust Graph (V3) → Ecosystem
Intelligence (V4). Trust-score computation stays Analytics/TEC AI (§4).

---

## PREAMBLE

Zone is NOT an app.

Zone is NOT a content platform.

Zone is NOT a community portal.

Zone is:

```
The Verification Runtime
of the Pi Ecosystem.
```

It answers one question:

```
"What can be trusted?"
```

---

## 1. THE PROBLEM ZONE SOLVES

Pi Network has 47M+ pioneers.
Pi ecosystem has thousands of projects, merchants, and builders.

But Pi ecosystem has NO:
- Verified project registry
- Institutional trust layer
- Evidence-based reputation system
- Unified source of verified truth

Today, when a Pi user asks:

```
"Is this project real?"
"Is this merchant trusted?"
"Is this builder verified?"
```

There is no authoritative answer.

Zone provides the authoritative answer.

---

## 2. CONSTITUTIONAL CLASSIFICATION

```
Tier:      TIER 1 — Constitutional Runtime
Question:  "What can be trusted?"
Domain:    zone.pi (strategic — never trade)
Level:     Same constitutional level as Hub
```

Zone is consumed BY other components.
Zone is NOT primarily consumed BY users directly.

```
Hub     provides identity.
Zone    provides verification of that identity's claims.
```

```
Connection provides relationships.
Zone    provides trust scores for those relationships.
```

```
Analytics provides intelligence.
Zone    provides the verified evidence that intelligence relies on.
```

```
TEC AI  provides recommendations.
Zone    provides the Pi-specific knowledge base that makes recommendations accurate.
```

---

## 3. WHAT ZONE OWNS

```
Verified Entities:
  Projects    → Pi ecosystem projects (TEC and non-TEC)
  Merchants   → Pi-accepting businesses
  Builders    → developers, founders, contributors
  Communities → Pi communities and organizations

Evidence Records:
  Verification evidence per entity
  Audit trail of verification decisions
  History of status changes

Institutional Memory:
  Record of Pi ecosystem activity over time
  Verified milestones and achievements
  Ecosystem-wide knowledge base

Trust Signals (from Connection, Phase C+):
  Relationship-based evidence
  Community endorsements
  Economic activity records
```

## 4. WHAT ZONE DOES NOT OWN

```
❌ Trust score computation → Analytics interprets signals
❌ Recommendations → TEC AI reasons from Zone data
❌ User relationships → Connection owns the graph
❌ Personal context → Life owns individual data
❌ Economic execution → payment-service + Nexus
❌ Governance decisions → System governs the platform
```

**Constitutional Rule:**
```
Zone records evidence.
Zone does NOT render judgement.

"Verified" = evidence confirmed.
"Trusted" = Analytics + TEC AI interpretation of evidence.

These are different functions.
Conflating them is an architectural violation.
```

---

## 5. BUILD SEQUENCE — VERSIONS

### Zone V0 — App Scaffold & Portal Readiness (2026-07)

**Truth State:** `[Current State]` for scaffold/key · `[Planned State]` for Zone Pro
**Verification:** `[Code Verified]` (payment key) · `[Assumed]` (frontend scaffold)
**Gate this satisfies:** the "**Portal submission complete**" gate that V1 depends on.

Before V1's verification registry, Zone ships the same Portal-ready app skeleton
every TEC app uses (from `tec-template-base`) — Hub SSO (C-123), dual-mode Pi
payment (ADR-007), CSRF, legal pages — plus a real Pi payment surface so the Pi
Developer Portal "Process a Transaction" step can be completed (the last Portal
gate). Mirrors the proven Life / Analytics / Connection path.

```
Identity:  app = TEC Zone · domain zone.tecosystem.app · slug/APP_SOURCE = 'zone'
           · Pi App ID (registered) · PI_SANDBOX=false. Frontend cloned from
           tec-template-base (repo: tec-zone).
Payment:   APP_SOURCE='zone' in src/lib/pi-payment.ts + payment/create route.
           ✅ payment-service: PI_API_KEY_ZONE registered (env schema +
              PI_KEY_SOURCES) so a Zone payment approves under Zone's OWN Pi App
              ID, never the default Hub key (the Analytics/Life/Connection
              approve→502 lesson). Ops sets PI_API_KEY_ZONE on Railway.
Portal:    Zone Pro — a real Pi User-to-App payment (ADR-007 dual-mode) — is the
           surface that turns the Portal "Process a Transaction" step green.
NEW-A:     no NEXT_PUBLIC_API_GATEWAY_URL / Railway host in the client bundle.
```

> **Runtime-governance note:** V0 completion is asserted by the Portal Readiness
> Engine (`evals/check-portal-readiness.sh`) once Zone's C-01/C-02/runbook rows
> exist. Until the `tec-zone` frontend is wired, this section is the placeholder
> of record; the payment-service half (`PI_API_KEY_ZONE`) is already in code.

---

### Zone V1 — Static Verified Registry (post-Portal)

**Gate:** Portal submission complete
**Data source:** Manual curation + Hub Pi identity
**No algorithms required**

```
Entities:
  □ Verified Projects (TEC apps + major Pi projects)
  □ Verified Merchants (Commerce merchants)
  □ Verified Builders (registered Pi developers)

Interface:
  zone.pi/project/:id  → project verification page
  zone.pi/merchant/:id → merchant verification page
  zone.pi/builder/:id  → builder verification page

API:
  GET /api/v1/zone/verify/:entity_id
    → { verified: true/false, evidence: [...], verified_at: date }

Verification criteria (V1):
  ✓ Pi identity verified (Hub)
  ✓ Active Pi wallet
  ✓ App/project accessible and functional
  ✓ No reported fraud
```

---

### Zone V2 — Evidence Registry (1k+ users)

**Gate:** 1,000+ verified Pi users in TEC
**Data source:** Commerce + Assets activity + user reports

```
Additions:
  □ Evidence workflow (submit + review + approve)
  □ Verification history (timeline)
  □ Merchant performance data (from Commerce)
  □ Basic dispute resolution

API additions:
  POST /api/v1/zone/evidence      → submit evidence
  GET  /api/v1/zone/history/:id   → verification timeline
  POST /api/v1/zone/dispute/:id   → raise dispute
```

---

### Zone V3 — Dynamic Trust Graph (Connection ready, 5k+ users)

**Gate:** Connection operational + 5,000+ users
**Data source:** Connection trust signals + economic activity

```
Additions:
  □ Trust signal ingestion from Connection
  □ Economic activity signals from Commerce/Assets/FundX
  □ Community endorsement system
  □ Trust score API (produced BY Analytics, served BY Zone)

Constitutional Rule (V3):
  Trust scores are computed by Analytics.
  Zone stores and serves them.
  Zone does not compute trust scores internally.
```

---

### Zone V4 — Ecosystem Intelligence Layer (Analytics ready, 10k+ users)

**Gate:** Analytics operational + TEC AI ready
**Data source:** All TEC data layers

```
Additions:
  □ Ecosystem reports (Pi growth, market trends)
  □ Opportunity intelligence (verified opportunities)
  □ Pi Knowledge Base (curated ecosystem knowledge)
  □ External API access (Pi developers outside TEC)

This is the point at which zone.pi
becomes a Pi ecosystem standard — not just a TEC feature.
```

---

## 6. zone.pi — THE STRATEGIC ASSET

`zone.pi` is one of TEC's most strategically valuable assets.

### Why

```
Commerce.tecosystem.app → competes with Pi marketplaces
Assets.tecosystem.app   → competes with Pi asset platforms
Life.tecosystem.app     → competes with Pi personal apps

zone.pi                 → does NOT compete
                         zone.pi can BECOME THE STANDARD
                         for Pi ecosystem verification
```

### The Standard Scenario

```
Year 1 (post-Portal):
  zone.pi lists and verifies TEC apps + major Pi projects
  First movers get "Zone Verified" badge

Year 2:
  Pi developers outside TEC request Zone verification
  "Zone Verified" becomes credibility signal in Pi ecosystem
  zone.pi becomes the reference for Pi project legitimacy

Year 3:
  Pi Core Team recognizes Zone as the de-facto registry
  zone.pi = Pi's institutional memory
  Every Pi project — TEC or not — seeks Zone verification
```

### Network Effect

```
More verified entities → more credibility of Zone verification
More credibility → more projects seek verification
More projects → more data for Analytics + TEC AI
Better AI → more value for TEC users
More TEC value → more zone.pi credibility

This is a compounding network effect
that does not depend only on TEC user growth.
```

---

## 7. SECURITY MODEL

```
Verification authority:
  Human reviewers required for all verifications
  No automated verification without human sign-off
  Two-reviewer rule for institutional verifications

Evidence integrity:
  All evidence records are append-only
  No evidence may be deleted (only superseded)
  Every decision logged with reviewer + timestamp

Dispute resolution:
  Any entity may dispute a verification
  Disputes require evidence submission
  Resolution requires human review panel

Anti-gaming:
  Verification is evidence-based only
  Paid listings do not affect verification status
  "Zone Verified" cannot be purchased — only earned
```

---

## 8. REVENUE MODEL

```
Zone Free (always):
  Browse verified entities
  Basic verification status
  Public evidence records

Zone Pro (for builders and merchants):
  Priority verification review
  Detailed evidence report
  Verification certificate
  Zone Verified badge (embeddable)

Zone Enterprise (for Pi projects):
  API access
  Custom verification workflows
  Ecosystem intelligence reports
  Co-branded verification

Zone External (Pi ecosystem — Phase V4):
  Pi developer API access
  Ecosystem intelligence subscriptions
  Verification as a service
```

---

## 9. INFRASTRUCTURE DEPENDENCIES

```
Hub          → Pi identity (required for all verifications)
Commerce     → merchant activity data (V2+)
Assets       → ownership records (V2+)
Connection   → trust signals (V3+)
Analytics    → trust score computation (V3+)
TEC AI       → knowledge reasoning (V4+)
```

---

## 10. KEY METRICS

```
Primary (Verification Quality):
  Entities verified / month
  Evidence submissions / entity
  Dispute rate (should be < 5%)
  Time to verification (target: < 7 days V1)

Secondary (Ecosystem Impact):
  Pi projects outside TEC seeking verification
  zone.pi external traffic
  API calls from non-TEC developers
  "Zone Verified" badges embedded externally
```

---

## 11. CONSTITUTIONAL POSITION

```
Zone sits between Hub and Analytics in the pipeline:

Hub (identity) → Zone (verification) → Analytics (intelligence)

Zone is the bridge between
"who someone claims to be" (identity)
and "what intelligence is valid about them" (analytics).

Without Zone:
  Analytics processes unverified claims
  TEC AI reasons on untrusted data
  FundX matches investors with unverified opportunities
  Estate connects buyers with unverified sellers

With Zone:
  Analytics processes verified evidence
  TEC AI reasons on trusted institutional knowledge
  FundX matches verified investors with verified opportunities
  Estate connects verified buyers with verified sellers

Zone is the trust foundation
of the entire TEC economic stack.
```

---

## FINAL STATEMENT

```
Pi ecosystem has wallets.
Pi ecosystem has apps.
Pi ecosystem does not have trust.

Zone provides trust.

Not by claiming authority —
but by verifying evidence,
recording history,
and serving as the institutional memory
of the Pi economy.

Explorer discovers what exists.
Connection connects what matters.
Zone verifies what can be trusted.
Analytics explains what is happening.
Nexus coordinates what should happen.
TEC AI reasons about what to do.

Zone is where information
becomes institutional knowledge.
```

---

## Related Documents

| Doc | Relationship |
|-----|--------------|
| C-119 | Economic Operating System Model — Zone is a Tier-1 Constitutional Runtime defined by it |
| C-121 | Institutional Knowledge Pipeline — Zone is the Verification stage of the chain |
| C-84 | Runtime Constitution — governs runtime constraints Zone must honor |
| C-68 | Domain Ownership — Zone owns exactly one question: "What can be trusted?" |
