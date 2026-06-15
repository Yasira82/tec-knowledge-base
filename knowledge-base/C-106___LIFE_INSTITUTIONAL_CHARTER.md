# C-106 — LIFE INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** Future Vision
**Governance State:** Draft
**Verification State:** Unverified
**Authority Scope:** Domain
**Decision Status:** Exploratory

---

## 1. MISSION

Life is the personal economic record system of the TEC ecosystem — the system that transforms a user's Pi transaction history into a living financial timeline: spending patterns, budget tracking, cashflow visualization, and personal economic health scoring.

---

## 2. INSTITUTIONAL ROLE

**System of Record (Personal Layer)** — The individual economic memory.

```
Settlement → RECORD → Reasoning → Access → Construction → Production → Economic Activity → Settlement
               ↑
             LIFE
        (Personal Record)
```

Life sits at the Record position for the individual user. Where Analytics (C-105) records the platform's economic activity, Life records the individual's economic story. It is the personal finance layer of the Pi economy.

---

## 3. ECONOMIC PURPOSE

Life exists to give Pi users financial awareness and planning capability:

- **Spending Timeline**: Chronological view of every Pi transaction — what was bought, when, from whom
- **Budget Tracking**: Set Pi budgets by category (food, entertainment, services) and track against them
- **Cashflow Visualization**: Pi inflow (earnings, received) vs outflow (purchases, transfers) over time
- **Personal Economic Health**: Score based on saving rate, spending diversity, wallet stability
- **Financial Goals**: Set Pi savings targets, track progress, get milestone alerts

Without Life, Pi transactions are isolated events in wallet history. Life transforms them into a coherent personal financial narrative — giving users the economic self-awareness to participate more intentionally in the Pi economy.

---

## 4. AUTHORITY BOUNDARY

### Owns
- Personal spending timeline UI
- Budget creation and tracking (per-user, stored in tec-life-service)
- Cashflow visualization (derived from transaction history)
- Personal economic health score algorithm
- Category classification of Pi transactions (food, services, assets, etc.)
- Financial goals and milestone tracking

### Does NOT Own
- Pi transaction records (tec-payment-service is the source of truth)
- Wallet balance (tec-payment-service owns)
- Pi price in fiat (external Pi Network API)
- Identity (tec-auth-service)
- Transaction initiation (Hub payment modal)

### Interface Points
```
Exposes to ecosystem:
  - Personal economic health score (consumed by FundX C-113 for credit assessment)
  - Spending category data (consumed by TEC AI C-104 for recommendations)
  - Budget status (consumed by Hub notifications C-100)

Consumed from:
  - Hub (C-100): SSO identity, payment history via BFF
  - tec-payment-service (4002): transaction history (read-only)
  - tec-analytics-service (4007): aggregated category benchmarks
  - TEC AI (C-104): AI-powered spending insights and category suggestions
```

---

## 5. TECHNICAL ARCHITECTURE

### Planned Stack
- Next.js 15 App Router + TypeScript strict
- New backend service: `tec-life-service` (Port 4012 — to be provisioned)
- PostgreSQL: personal budget records, goals, category mappings
- @yasser172/tec-auth: SSO cookies
- @yasser172/tec-ui: TEC_COLORS, shared components
- Deployment: Vercel (life.tecosystem.app)

### Data Architecture
```typescript
// Budget record (owned by tec-life-service)
interface Budget {
  id: string
  userId: string        // from tec_user cookie — never from request body
  category: string      // 'food' | 'services' | 'assets' | 'entertainment' | 'other'
  limitPi: string       // DECIMAL(20,8) string
  periodDays: number    // 7 | 30 | 365
  createdAt: string
}

// Transaction category classification
interface CategoryMapping {
  paymentId: string     // references tec-payment-service record
  userId: string
  category: string
  classifiedBy: 'user' | 'ai'  // manual or TEC AI auto-classification
  confidence: number    // 0-1 for AI classifications
}
```

### Spending Timeline Architecture
```
GET /api/bff/life/timeline
  → tec-payment-service (4002): fetch user's payment history
  → tec-life-service (4012): fetch category classifications
  → Merge + sort chronologically
  → Return enriched timeline with categories, budgets, running totals
```

### Privacy-First Design
```
Life data is the most sensitive in the platform:
- Never aggregate across users for Life-level data
- Budget data stays in tec-life-service (not shared with analytics raw)
- Only anonymized signals shared with TEC AI for recommendations
- Account deletion → immediate cascade delete of all Life data
```

---

## 6. SECURITY MODEL

### Authentication & Authorization
- All Life endpoints require authenticated session
- User A cannot access User B's budget or timeline — P6 Fail Closed
- Budget and category data served only to the owning user
- Health score can be shared (opt-in) with FundX for credit assessment

### Threat Vectors
| Threat | Mitigation |
|--------|------------|
| Unauthorized timeline access | userId always from tec_user cookie (server-side) |
| Budget data leak | User-scoped queries only — no cross-user joins |
| Health score gaming | Score inputs from tec-payment-service (immutable) — not self-reported |
| Financial advice liability | Clear disclaimer: "Personal spending insights only" |

---

## 7. REVENUE MODEL

### Direct
1. **Life PRO**: Advanced analytics, AI-powered insights, unlimited budget categories
2. **FundX Integration**: Health score shared with FundX pools (user opt-in, earns platform fee)
3. **Financial Goals Coaching**: AI-powered Pi savings coaching (TEC AI integration)

### Indirect
- Spending awareness → users spend more intentionally → higher-value Pi transactions
- Budget discipline → users stay in Pi economy longer (retention)
- Health score → FundX access → platform financial inclusion

---

## 8. KEY METRICS

### SLOs
| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| Life service availability | ≥ 99.0% | < 98.0% |
| Timeline load latency | < 1s P95 | > 3s P95 |
| Budget alert delivery | < 5min from threshold | > 30min |

### KPIs
| Metric | Target | Frequency |
|--------|--------|----------|
| Active budget users | ≥ 30% of DAU | Monthly |
| Budget adherence rate | ≥ 60% of budgets met | Weekly |
| Timeline sessions/week | ≥ 2 per active user | Weekly |
| Health score improvement (3-month cohort) | +5% average | Quarterly |

---

## 9. ECOSYSTEM CONTRIBUTION

1. **Financial Literacy**: Life turns Pi transaction data into financial self-awareness — users become more intentional economic participants
2. **FundX Credit Layer**: Life's health score is the primary input for Pi-native credit assessment (no external credit bureaus needed)
3. **Retention Driver**: Users with budgets and goals check the platform more frequently — higher engagement
4. **AI Training Signal**: Category classifications from Life improve TEC AI recommendation accuracy
5. **Pi Savings Culture**: Financial goals create a Pi-denominated savings culture — users hold Pi longer, reducing sell pressure

---

## 10. FUTURE EVOLUTION

### Phase 1 (MVP — Month 1–2 post-Mainnet)
- Spending timeline: chronological Pi transaction history with categories
- Basic budgets: monthly spending limits per category
- Simple cashflow: inflow vs outflow weekly chart

### Phase 2 (Month 3–4)
- AI-powered category classification (TEC AI integration)
- Budget alerts via tec-notification-service (4008)
- Savings goals with milestone celebrations
- Spending peer comparison (anonymized: "you spend X% more on services than similar users")

### Phase 3 (Month 5–8)
- FundX health score integration (opt-in)
- Multi-wallet tracking (if Pi Network adds multiple wallets)
- Life → Estate connection: property purchase savings goals
- Shared household budgets (Connection C-107 integration)

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Critical (Before Life MVP)**
1. **Provision tec-life-service** (Port 4012) on Railway
2. **Payment history BFF route**: `/api/bff/life/timeline` — secure proxy to tec-payment-service with user scoping
3. **Account deletion cascade**: Life data must be completely deleted on account closure

**P1 — High Priority**
4. **Category classification schema**: Prisma migration for category_mapping table
5. **Budget alert integration**: tec-notification-service (4008) webhook for budget threshold events
6. **Health score algorithm**: Define scoring formula using payment history inputs

**P2 — Medium Priority**
7. **TEC AI classification**: Automatic category assignment via TEC AI service
8. **FundX health score API**: Opt-in endpoint for FundX credit assessment
9. **Export feature**: Download personal transaction history as CSV

---

## 12. INTEGRATION MAP

```
C-106 (LIFE) depends on:
← C-100 (HUB)        : SSO identity, payment history
← tec-core-backend   : tec-payment-service (4002), tec-notification-service (4008)
← C-104 (TEC AI)     : Category classification, spending insights

C-106 (LIFE) contributes to:
→ C-104 (TEC AI)     : Category data for recommendation training
→ C-113 (FUNDX)      : Personal health score for credit assessment
→ C-100 (HUB)        : Budget alert notifications
```

---

*Charter issued by TEC Economic Infrastructure Design Partnership*
*Version 1.0 — 2026-06-15*
