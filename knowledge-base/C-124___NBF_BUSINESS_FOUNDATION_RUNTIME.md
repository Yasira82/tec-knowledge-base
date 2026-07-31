# C-124 — NBF BUSINESS FOUNDATION RUNTIME

## TEC Ecosystem — Business Foundation Layer

> **Truth State:** `[Future Vision]`
> **Governance State:** `[Draft]`
> **Verification:** `[Assumed]`
> **Authority Scope:** `[Domain]`
> **Build Gate:** Phase 2 (1k+ users — needs real merchants)
> **Full Name:** Network Business Foundation
> **Domain:** `nbf.tecosystem.app` (live pattern now) → `nbf.pi` (future)

---
## Deployment Status (2026-07-31)

> **Truth State:** `[Current State]` for the deployed app + live payment · `[Future Vision]` for the full runtime below
> **Verification:** `[Runtime Verified]` — deployed on Mainnet, real Pi payment live (SSoT: `architecture/app-fleet.yaml` → `live-verified`)

**NBF is deployed on Mainnet** with Hub SSO and dual-mode (ADR-007) Pi payment live:
- **Domain:** `nbf.tecosystem.app` · **Pi App ID:** `nbf-zutt` · **APP_SOURCE:** `nbf`
- **Payment:** real Pi subscription — Mode 1 (Hub) + Mode 2 (standalone); `PI_API_KEY_NBF` set on payment-service.
- **Hub SSO:** enabled (in `/api/auth/sso` ALLOWED_TARGETS + Hub domain registry).
- **Growth:** referral loop wired (C-133).

**Still `[Future Vision]`:** the advanced runtime described below (V2+ / the charter's later phases) — vision, not yet built.

---

## Institutional Identity

```
Business Foundation Runtime
System of Business Formation (User Layer)
```

---

## Mission

Enable any Pi user to establish, verify,
and launch a business identity in the Pi economy —
providing the foundational infrastructure
for commerce, funding, and enterprise growth.

---

## Core Question

```
"How do I start my business in the Pi economy?"
```

---

## The Critical Gap NBF Fills

```
Hub answers:    "Who are you as an individual?"
NBF answers:    "Who is your business?"

Pi ecosystem today:
  47M pioneers
  Many want to trade, serve, build
  But: no structured way to establish business identity
  Result: informal, unverified, unstructured commerce

NBF solves this:
  Individual (Hub identity)
      ↓
  Business (NBF identity)
      ↓
  Verified Business (Zone verification)
      ↓
  Active Business (Commerce/FundX/Estate)
      ↓
  Scaled Enterprise (Titan)
```

---

## Institutional Role

```
NBF is the starting point for every Pi business.

Where Hub creates personal identity,
NBF creates business identity.

Where Commerce enables transactions,
NBF establishes the entity that transacts.

Where Titan manages enterprise operations,
NBF is where those enterprises are born.

NBF = Business Day 1.
Titan = Business at Scale.
```

---

## NBF vs Titan — Constitutional Separation

```
NBF (Business Foundation):
  Establish       → create business identity
  Register        → formal business record
  Verify          → Zone verification
  Launch          → first product/service
  Connect         → first customers
  Timeline:       Day 1 → ~Year 1

Titan (Enterprise Management):
  Manage          → multi-team operations
  Scale           → process + workflow management
  Govern          → organizational governance
  Optimize        → efficiency + performance
  Timeline:       Year 1 → maturity

Graduation trigger (NBF → Titan):
  team_size > 5 people
  OR monthly_revenue > 1,000π
  OR active_projects > 3
  OR user_count > 500

NBF does not compete with Titan.
NBF graduates into Titan.
```

---

## Authority Boundary

### NBF OWNS

```
Business Identity:
  Business name
  Business type (Store | Service | Startup | Freelancer | NGO | Restaurant | Agency)
  Description + tagline
  Category + specialization
  Logo + visual identity (upload or generate)
  Pi payment credentials

Business Profile:
  Public business page (nbf.pi/biz/:handle)
  Product/service catalog (basic)
  Team members (linked Hub identities)
  Business hours + contact
  Location (optional, Pi-economy context)

Business Verification:
  Verification request → Zone
  Zone returns: VERIFIED_BUSINESS badge
  Legal registration upload (optional, for higher trust)

Business Toolkit:
  QR code (Pi payment + profile link)
  Business card (digital)
  Catalog share link
  Introductory offer builder
  Basic analytics (views, clicks, Pi received)

Business Templates:
  Pi Store Template      → retail/ecommerce
  Service Business       → freelancer/consulting
  Food & Beverage        → restaurant/cafe
  Digital Products       → creator/developer
  Non-Profit             → community/social impact
  Startup                → tech/innovation

Business Launch Checklist:
  ✓ Business profile complete
  ✓ Zone verification pending/complete
  ✓ Pi payment connected
  ✓ At least one product/service listed
  ✓ First customer contact ready
```

### NBF DOES NOT OWN

```
Transaction processing   → Commerce / payment-service
Investment capital       → FundX
Property transactions    → Estate
Enterprise operations    → Titan (after graduation)
Risk assessment          → Insure
Trust verification       → Zone (verification authority)
Reputation recording     → Legend (records outcomes)
Analytics intelligence   → Analytics (computes metrics)
```

---

## Business Identity vs Personal Identity

```
PERSONAL (Hub):                    BUSINESS (NBF):
  Pi username: @yasser               Business: TEC Commerce Store
  Pi wallet: personal                Pi wallet: business (separate)
  KYC: personal identity             Verification: Zone business badge
  Reputation: Legend personal        Reputation: Legend merchant score
  Subscription: Hub PRO              Subscription: NBF Merchant VIP

One user can have:
  1 personal identity (Hub)
  Multiple business identities (NBF)
  (e.g., a freelancer + a store + a non-profit)

Business wallets are linked to personal Hub identity
but maintain separate transaction records.
```

---

## Technical Architecture (Planned)

```
Pi Browser (WebView)
    ↓
nbf.tecosystem.app (Vercel — Next.js 15)
[Clone from tec-template-base]
    ↓
BFF /api/* routes
    ↓
API Gateway :3000 (Railway)
    ↓
nbf-service (NEW — Phase 2)
  Builds on top of:
    Hub         → owner identity
    Zone        → business verification
    Commerce    → product/service catalog
    storage-service → logo + assets
    analytics-service → business metrics
  Does NOT need separate DB initially:
    Business profiles stored in identity-service extension
    OR lightweight nbf-service (tec_nbf DB)
```

### Core Entities

```typescript
interface BusinessProfile {
  business_id:      string;
  owner_id:         string;           // Hub Pi identity (creator)
  team_ids:         string[];         // additional Hub identities
  handle:           string;           // @mybusiness (unique)
  name:             string;
  type:             BusinessType;     // STORE | SERVICE | STARTUP | FREELANCER | NGO | RESTAURANT | AGENCY
  description:      string;
  tagline?:         string;
  category:         string;
  logo_url?:        string;
  status:           BusinessStatus;   // DRAFT | ACTIVE | VERIFIED | SUSPENDED | GRADUATED
  zone_verified:    boolean;
  zone_badge_id?:   string;
  pi_wallet:        string;           // business Pi wallet address
  products:         ProductRef[];     // links to Commerce
  analytics: {
    profile_views:  number;
    pi_received:    PiAmount;
    customers:      number;
  };
  graduation_check: GraduationCheck;  // tracks if ready for Titan
  created_at:       string;
  launched_at?:     string;
}

interface BusinessTemplate {
  template_id:    string;
  type:           BusinessType;
  name:           string;
  description:    string;
  pre_filled: {
    categories:   string[];
    sample_products: SampleProduct[];
    checklist:    ChecklistItem[];
    pi_pricing:   PricingGuidance;
  };
}

interface GraduationCheck {
  team_size:          number;
  monthly_revenue_pi: number;
  active_projects:    number;
  customer_count:     number;
  titan_ready:        boolean;        // true if any threshold exceeded
  recommended_action: string;
}
```

---

## The Launch Funnel

```
STEP 1 — Choose Template (5 min):
  "What type of business?"
  → Pre-filled profile from template

STEP 2 — Complete Profile (10 min):
  Name + description + category + logo
  Team members (invite via Pi username)
  Pi payment connection

STEP 3 — Add Products/Services (10 min):
  Minimum 1 product/service
  Pi pricing
  Photos (optional)

STEP 4 — Zone Verification (async — 1-7 days):
  NBF submits verification request
  Zone reviews: Pi identity, activity, legitimacy
  Zone issues: VERIFIED_BUSINESS badge

STEP 5 — Launch (instant):
  Business page goes public
  QR code generated
  First products listed in Commerce
  Business appears in Explorer

TOTAL: 25 minutes to a verified Pi business.
```

---

## Security Model

```
Business ownership:
  Only owner_id (Hub creator) can modify core profile
  Team members can add products/edit catalog
  Zone verification cannot be self-granted

Business Pi wallet:
  Separate from personal Hub wallet
  Requires Pi identity re-verification for large transfers
  Multi-sig option for team businesses

Profile integrity:
  Business name uniqueness enforced
  Handle uniqueness enforced (same as Pi username rules)
  Logo content moderation (inappropriate content rejected)

Fraud prevention:
  Zone verification deters fake businesses
  Insure risk scoring applies to all business transactions
  Commerce dispute history visible to Zone
```

---

## Infrastructure Dependencies

```
Hub             → owner identity (REQUIRED)
Zone            → business verification (REQUIRED for VERIFIED status)
Commerce        → product/service catalog
payment-service → Pi business wallet
storage-service → logo + business media
Analytics       → business performance metrics
Insure          → business risk profile
Legend          → merchant achievement recording
Titan           → graduation target (scales from NBF)
Explorer        → business discovery listing
notification-service → verification status + business alerts
```

---

## Revenue Model

```
NBF Free:
  1 business profile
  Basic template
  Zone verification (standard queue — 7 days)
  Basic analytics

NBF Pro (25π/month):
  Unlimited business profiles
  Priority Zone verification (2 days)
  Advanced analytics
  Custom business domain
  Full product catalog
  Team collaboration (up to 10)

NBF Enterprise (100π/month):
  API access
  White-label business pages
  Dedicated Zone verification (24hr)
  Advanced business analytics
  Titan graduation support

Transaction contribution:
  NBF-verified businesses use Commerce
  Commerce takes 1-2% transaction fee
  NBF drives Commerce revenue indirectly

Ecosystem Revenue (Phase 3+):
  nbf.pi external business directory
  Pi Business Marketplace (list your business for Pi community)
  Pi Business Awards (annual recognition program)
```

---

## Key Metrics

```
Primary (Business Formation Quality):
  Business profiles created / month
  DRAFT → ACTIVE conversion rate
  Zone verification completion rate
  First Pi transaction within 30 days of launch

Secondary:
  Average time: profile creation → first sale
  Business profile completeness score
  Titan graduation rate (NBF → Titan)
  Business survival rate (active at 6 months, 1 year)
```

---

## Build Protocol

```
Prerequisites:
  ✅ Zone operational (business verification)
  ✅ Commerce operational (product catalog)
  ✅ 1,000+ verified Pi users

V1 (Phase 2 — 4 weeks):
  □ Business profile creation (STORE + SERVICE + FREELANCER)
  □ Team invitation (Hub identities)
  □ Zone verification request
  □ Basic product catalog (links to Commerce)
  □ QR code + business card generation
  □ Business page (nbf.tecosystem.app/@handle)

V2 (Phase 2 — 4 weeks):
  □ All BusinessType templates
  □ Advanced analytics dashboard
  □ Graduation check (NBF → Titan indicator)
  □ Business Pi wallet (separate from personal)
  □ Explorer integration (business discovery)

V3 (Phase 3+):
  □ nbf.pi external platform
  □ Pi Business Directory (public)
  □ NBF API (external Pi business formation)
  □ Business reputation API
```

---

## Ecosystem Contribution

```
NBF feeds:
  Commerce    → verified merchants to sell
  FundX       → verified startups to fund
  Zone        → businesses to verify
  Legend      → merchant achievements to record
  Titan       → businesses to graduate to enterprise
  Explorer    → businesses to discover
  Analytics   → business formation metrics

NBF generates for Pi:
  Structured Pi economy (verified businesses)
  Trust foundation for Pi commerce
  Business identity standard for Pi ecosystem
  Foundation for Pi economic growth
```

---

## Positioning Statement

```
NBF is not a business registration service.
NBF is the Business Foundation Runtime of TEC.

The difference:
  Registration services create paperwork.
  Business Foundation Runtimes create economic actors.

In 25 minutes, NBF takes a Pi pioneer
from "I have an idea" to
"I am a verified, discoverable, Pi-native business."

Hub tells Pi: "This is who I am."
NBF tells Pi: "This is what I am building."

Every Pi merchant started somewhere.
Every Pi startup had a day one.
Every Pi economy began with someone deciding to create value.

NBF is that beginning.
The moment a pioneer becomes a builder.
The moment an individual becomes a business.
The moment Pi becomes an economy.
```

---

## Related Documents

- **C-00** Platform Constitution · **C-47** Kernel Spec (P6 Fail Closed, ActorContext, custody Invariant #8)
- **C-70** Event Governance (`domain.action.version`) · **C-105** Analytics (score/metric computation)
- **C-120** Zone (verification) · **C-126** Legend (merchant score) · **C-130** Titan (graduation target)
- **C-12** Dual-Mode Payment (anti-regression) · **C-123** Pi Browser Session & Cookie Spec (login/cookies)
