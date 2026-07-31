# C-125 — EPIC CREATION RUNTIME

## TEC Ecosystem — Creation Layer

> **Truth State:** `[Future Vision]`
> **Governance State:** `[Draft]`
> **Verification:** `[Assumed]`
> **Authority Scope:** `[Domain]`
> **Build Gate:** Phase 2 (1k+ users)
> **Domain:** `epic.tecosystem.app` (live pattern now) → `epic.pi` (future)

---
## Implementation Status (2026-07-31)

> **Truth State:** `[Current State]` for V0/V1 (below) · `[Future Vision]` for the full creation runtime
> **Verification:** `[Code Verified]` (merged) · deployment per app CLAUDE.md

Epic's V0/V1 is built in `tec-identity-service` (backend) + `tec-epic` (frontend),
merged to `main`:
- **Project board** (read layer, owner-scoped P6) + `/project/[id]` detail.
- **Value chain (create → earn):** owner-scoped `completeProject` graduates a project to
  `LEGEND` and emits `epic.project.completed.v1`; a "Mark project complete → Legend"
  trigger on `/project/[id]` (the BFF derives the owner from the session cookie, never the
  body — P6). Legend records the "Completed an Epic project" achievement. Terminal-state
  safe; Epic records no reputation itself. `[Code Verified]`; fires at runtime only when
  `REDIS_URL` is set.

**Still future:** real project creation (STARTUP/COMMUNITY), team invitation, milestone
tracking, Zone verification request, FundX funding (Phase 2 gates).

---

## Institutional Identity

```
Creation Runtime
System of Construction (User Layer)
```

---

## Mission

Enable individuals and communities
to create, launch, and grow
new economic initiatives inside the Pi ecosystem.

---

## Core Question

```
"What are you building?"
```

---

## Institutional Role

```
Epic is the birthplace of new things in TEC.

Where Hub manages who you are,
Epic manages what you are creating.

Where Legend records what you achieved,
Epic is where the achievement begins.
```

---

## The Problem Epic Solves

Pi ecosystem has 47M+ pioneers.
Many have ideas, projects, initiatives, communities.

But Pi has no:
- Structured project launch infrastructure
- Community formation tools
- Challenge and hackathon platform
- Startup incubation layer
- DAO foundation framework

Epic solves this.

---

## Authority Boundary

### Epic OWNS

```
Project Creation:
  Startup         → Pi-native business idea
  Community       → people around shared interest
  Campaign        → fundraising or awareness
  Event           → Pi hackathon, meetup, conference
  Challenge       → competitive initiative
  Program         → training, education, mentorship
  Initiative      → open-source, non-profit, social impact

Project Structure:
  Name + Description + Category
  Team Formation (Members + Roles)
  Goal Definition (milestones + timeline)
  Public Launch (visible to Pi community)
  Funding Request (→ FundX integration)
  Community Joining (→ Connection integration)

Project Lifecycle:
  DRAFT → ACTIVE → FUNDED → COMPLETED → LEGEND
```

### Epic DOES NOT OWN

```
Project verification    → Zone verifies Epic projects
Capital execution       → FundX manages investment flows
Reputation recording    → Legend records Epic outcomes
Transaction processing  → Commerce / payment-service
Enterprise management   → Titan manages scaled organizations
Risk assessment         → Insure evaluates project risk
```

---

## Epic → Zone → Legend Pipeline

```
The critical value chain:

1. EPIC (Create)
   User launches a project
   → sets goals, team, timeline

2. ZONE (Verify)
   Zone validates the project
   → checks activity, team identity, evidence
   → issues "Zone Verified" badge

3. ACTIVITY (Execute)
   Project runs on Commerce, Assets, FundX, Connection

4. LEGEND (Earn)
   Successful completion recorded in Legend
   → permanent reputation evidence
   → trust signal for future initiatives
```

---

## Technical Architecture (Planned)

```
Pi Browser (WebView)
    ↓
epic.tecosystem.app (Vercel — Next.js 15)
[Clone from tec-template-base]
    ↓
BFF /api/* routes
    ↓
API Gateway :3000 (Railway)
    ↓
epic-service (NEW — Phase 2)
zone-service    → verification requests
fundx-service   → funding integration
connection-service → team + community
notification-service → launch alerts
```

### Core Entities

```typescript
interface EpicProject {
  project_id:    string;
  creator_id:    string;         // Hub Pi identity
  type:          ProjectType;    // STARTUP | COMMUNITY | CAMPAIGN | EVENT | CHALLENGE | PROGRAM
  name:          string;
  description:   string;
  category:      string;
  team:          TeamMember[];
  goals:         Milestone[];
  status:        ProjectStatus;  // DRAFT | ACTIVE | FUNDED | COMPLETED | ARCHIVED
  zone_verified: boolean;
  funding_goal?: PiAmount;       // optional FundX integration
  launched_at:   string;
  completed_at?: string;
}

interface Milestone {
  milestone_id: string;
  title:        string;
  target_date:  string;
  completed:    boolean;
  evidence?:    string;          // proof of completion → feeds Legend
}
```

---

## Security Model

```
Authentication:  Hub SSO (all actions require Pi identity)
Project access:  Creator + invited team members
Public view:     Any Pi user can browse active projects
Verification:    Zone validates — Epic cannot self-verify
Funding:         FundX controls — Epic cannot move Pi directly
```

---

## Infrastructure Dependencies

```
Hub             → Pi identity (creator + team members)
Zone            → project verification
FundX           → funding flows
Connection      → team formation + community joining
Commerce        → product/service launching from project
Legend          → achievement recording on completion
Analytics       → project performance metrics
notification-service → launch + milestone alerts
```

---

## Revenue Model

```
Epic Free:
  1 active project
  Basic project page
  Public launch

Epic Pro (Hub PRO — 10π/month):
  Unlimited projects
  Priority Zone verification
  FundX integration
  Analytics dashboard
  Custom project domain

Epic Enterprise (Hub ENTERPRISE — 50π/month):
  API access
  Incubator program access
  Co-branded launch support
  Dedicated project support

Ecosystem Revenue (Phase 3+):
  Epic API for Pi hackathon organizers
  Pi Startup Incubator program fees
  Event hosting fees
```

---

## Key Metrics

```
Primary (Creation Quality):
  Projects launched / month
  Projects reaching COMPLETED status
  Projects that received Zone verification
  Projects that received FundX funding

Secondary:
  Team size per project (average)
  Time from DRAFT to ACTIVE
  Community members joined per project
  Legend records generated from Epic completions
```

---

## Build Protocol

```
Phase 2 Prerequisites:
  ✅ Zone operational (verification layer)
  ✅ FundX V1 operational (funding integration)
  ✅ Connection operational (team formation)
  ✅ 1,000+ verified Pi users

V1 (MVP — 4 weeks):
  □ Project creation (STARTUP + COMMUNITY types)
  □ Team invitation (Pi identity required)
  □ Milestone tracking
  □ Zone verification request
  □ Public project listing

V2 (Phase 2 — 4 weeks):
  □ CAMPAIGN + EVENT + CHALLENGE types
  □ FundX integration (funding goal + contribution)
  □ Connection community formation
  □ Analytics dashboard

V3 (Phase 3+):
  □ DAO foundation framework
  □ Epic API (external Pi hackathons)
  □ Incubator program
  □ Pi Startup acceleration
```

---

## Ecosystem Contribution

```
Epic feeds:
  Zone      → projects to verify
  FundX     → investment opportunities
  Commerce  → products launched from projects
  Legend    → achievements to record
  Analytics → creation activity metrics
  TEC AI    → project success patterns for recommendations

Epic generates for Pi:
  New economic initiatives
  Community formation
  Collaborative value creation
  Pi-native startup culture
```

---

## Positioning Statement

```
Epic is not a project management tool.
Epic is the Creation Runtime of TEC.

Every economic achievement begins with creation.
Every reputation is built on completed initiatives.
Every investment is made in something someone built.

Epic is where the Pi economy
creates new things.

Where others have wallets,
TEC has builders.
Epic is where building begins.
```

---

## Related Documents

- **C-00** Platform Constitution · **C-47** Kernel Spec (P6 Fail Closed, ActorContext, custody Invariant #8)
- **C-70** Event Governance (`domain.action.version`) · **C-105** Analytics (score/metric computation)
- **C-120** Zone (project verification) · **C-126** Legend (outcomes) · **C-129** FundX/Insure gates
- **C-12** Dual-Mode Payment (anti-regression) · **C-123** Pi Browser Session & Cookie Spec (login/cookies)
