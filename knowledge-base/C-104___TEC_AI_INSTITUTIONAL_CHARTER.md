# C-104 — TEC AI INSTITUTIONAL CHARTER
## TEC Economic Infrastructure Design Partnership — v1.0

**Truth State:** Planned State
**Governance State:** Draft
**Verification State:** Unverified
**Authority Scope:** Platform
**Decision Status:** Recommended

---

## 1. MISSION

TEC AI is the reasoning infrastructure layer of the TEC ecosystem — the system that transforms raw platform data (transactions, user behavior, economic signals) into actionable intelligence for users, merchants, and platform operators.

---

## 2. INSTITUTIONAL ROLE

**System of Reasoning** — Intelligence layer in the Economic Runtime.

```
Settlement → Record → REASONING → Access → Construction → Production → Economic Activity → Settlement
                          ↑
                        TEC AI
```

TEC AI occupies the reasoning position in the economic lifecycle: it sits between data capture (Record/Analytics) and access (Hub), transforming signals into decisions. It is not a chatbot — it is an economic inference engine.

---

## 3. ECONOMIC PURPOSE

TEC AI exists to create asymmetric economic advantages for TEC platform participants:

- **Merchants**: AI-driven product pricing recommendations, demand forecasting, inventory insights
- **Consumers**: Personalized product discovery, spending pattern analysis, Pi budget optimization
- **Creators (Assets)**: Asset valuation, trending category detection, optimal listing timing
- **Platform Operators**: Anomaly detection, fraud signals, ecosystem health scoring
- **FundX Pools**: Risk assessment for lending pool participants, credit scoring in Pi

AI reasoning turns raw economic data into competitive advantage. Merchants using TEC AI price better, sell more. Consumers using TEC AI find what they want faster. Platform operators using TEC AI catch fraud earlier.

---

## 4. AUTHORITY BOUNDARY

### Owns
- AI inference API: `/ai/recommend`, `/ai/analyze`, `/ai/score`
- Model selection and versioning for inference calls
- Prompt templates for economic reasoning tasks
- AI response caching strategy
- Feedback loop data collection (user ratings on AI outputs)

### Does NOT Own
- Raw platform data (tec-analytics-service owns — Port 4007)
- User identity (tec-auth-service owns)
- Financial decisions (humans approve — AI only recommends)
- Payment execution (tec-payment-service owns)
- Pi amounts, balances, or wallet state

### Interface Points
```
Exposes to ecosystem:
  - Recommendation API: POST /api/ai/recommend (product, asset, merchant)
  - Analysis API: POST /api/ai/analyze (spending, portfolio, market)
  - Scoring API: POST /api/ai/score (credit, reputation, risk)
  - Insight feed: GET /api/ai/insights (user-specific AI digest)

Consumed from:
  - tec-analytics-service (4007): event streams, aggregated metrics
  - tec-auth-service (4001): authenticated identity for personalization
  - tec-commerce-service (4003): product catalog, pricing, order history
  - tec-asset-service (4006): asset transaction history
  - External LLM API (Anthropic Claude / configurable): inference backend
```

---

## 5. TECHNICAL ARCHITECTURE

### Stack (Planned)
- Next.js 15 API Routes (BFF pattern) for AI endpoint exposure
- Node.js service: `tec-ai-service` (Port 4011 — to be provisioned)
- Anthropic Claude API (primary inference backend) via `@anthropic-ai/sdk`
- Redis: response caching for repeated AI queries (TTL: 5min for recommendations)
- PostgreSQL: AI output audit log (every AI decision is logged — Invariant 4)
- Deployment: Railway (backend) + Vercel (frontend BFF)

### Two-SDK Boundary
```
Client Components  →  packages/tec-core-sdk (useAiRecommend hook)
API Routes (BFF)   →  @yasser172/tec-sdk   (TecSdk.ai.* server-side calls)
```

### Inference Architecture
```
User action (browse product)
  → Event captured by tec-analytics-service (4007)
  → POST /api/bff/ai/recommend
    → tec-ai-service (4011)
      → Fetch user history from analytics
      → Build context prompt
      → Anthropic Claude API (inference)
      → Parse structured response
      → Cache in Redis (5min TTL)
      → Log to audit table
    → Return recommendations
  → Display in UI
```

### AI Audit Trail (Invariant 4 compliance)
```typescript
interface AiAuditRecord {
  id: string            // UUID
  userId: string        // actor from tec_user cookie
  requestType: string   // 'recommend' | 'analyze' | 'score'
  inputHash: string     // SHA256 of input (not stored raw)
  modelId: string       // e.g. 'claude-sonnet-4-6'
  outputSummary: string // first 200 chars of output
  latencyMs: number
  timestamp: string     // ISO 8601
  correlationId: string // traces full request
}
```

### Economic Reasoning Tasks (Phase 1 Implementation Targets)
```
1. Product recommendations: based on browse history + purchase patterns
2. Price sensitivity analysis: optimal Pi price point for merchant products
3. Portfolio insights: asset value trends for Assets users
4. Spending digest: weekly Pi spending summary for Hub users
5. Demand forecasting: predict category demand peaks for Commerce merchants
```

---

## 6. SECURITY MODEL

### Authentication
- All AI endpoints require authenticated session (tec_user cookie)
- AI inference calls are authenticated — no public inference endpoints
- Anthropic API key stored as Railway secret, never in client bundle

### Authorization
- Personalized AI only accesses the requesting user's own data
- Merchant AI accesses only that merchant's product/order data
- Platform AI (admin tier) requires AdminActor context + audit trail

### Threat Vectors & Mitigations
| Threat | Mitigation |
|--------|------------|
| Prompt injection via user data | Sanitize all user-provided input before LLM context |
| Data exfiltration via AI output | Output filter: strip any wallet IDs, payment tokens |
| API key exposure | Railway secret — never NEXT_PUBLIC_* |
| AI output as financial advice | Clear disclaimer: "AI recommendations only — not financial advice" |
| Cost runaway (LLM API) | Per-user rate limit: 100 AI requests/day on FREE, 500 on PRO |
| Inference data leakage | User A's data never in User B's prompt context |

---

## 7. REVENUE MODEL

### Direct
1. **PRO/ENTERPRISE AI Features**: Advanced analytics, unlimited recommendations, custom insights (PRIMARY)
2. **Merchant AI Tier**: Demand forecasting, pricing optimizer, inventory AI (premium merchant feature)
3. **FundX Risk Scoring**: AI credit scoring for lending pool access (Phase 3)

### Indirect
- Better recommendations → higher purchase conversion → more platform transaction fees
- Fraud detection → reduced chargebacks → healthier platform economics
- Merchant success via AI insights → merchant retention → ecosystem growth

---

## 8. KEY METRICS

### SLOs
| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| AI service availability | ≥ 99.0% | < 98.0% |
| Inference response time | < 3s P95 | > 8s P95 |
| Recommendation cache hit rate | ≥ 60% | < 40% |
| AI audit log completeness | 100% of inferences logged | Any gap |
| LLM API error rate | < 2% | > 5% |

### KPIs
| Metric | Target | Frequency |
|--------|--------|----------|
| Recommendation click-through rate | ≥ 15% | Weekly |
| AI feature adoption (PRO users) | ≥ 60% using at least 1 AI feature | Monthly |
| Merchant pricing accuracy (AI vs actual sale) | ±15% | Monthly |
| FREE → PRO conversion attributed to AI | ≥ 20% of upgrades | Monthly |

---

## 9. ECOSYSTEM CONTRIBUTION

1. **Economic Intelligence**: Transforms raw transaction data into actionable merchant/consumer insights
2. **Conversion Amplifier**: Better product recommendations → higher purchase rates across Ecommerce
3. **Fraud Prevention**: Anomaly detection protects payment integrity platform-wide
4. **PRO Upgrade Driver**: AI features are the primary value proposition for PRO tier subscription
5. **FundX Enabler**: Risk scoring makes Pi-native lending possible without traditional credit bureaus

---

## 10. FUTURE EVOLUTION

### Phase 1 (Post-Mainnet, Month 1–2) — Foundation
- Deploy tec-ai-service (4011) on Railway
- Product recommendations via Anthropic Claude API
- Weekly spending digest for Hub PRO users
- Merchant pricing insights dashboard

### Phase 2 (Month 3–4) — Personalization
- Real-time recommendations in Ecommerce product listings
- Asset portfolio AI analysis in Assets app
- Connection-aware recommendations (what your network is buying)
- Natural language Pi budget advisor

### Phase 3 (Month 5–8) — Economic Intelligence
- FundX credit scoring: Pi-native credit assessment for lending
- Ecosystem health scoring: real-time platform economic health index
- Market intelligence: Pi economy trends, category forecasting
- Autonomous risk alerts: proactive ALERT (C-111) integration

---

## 11. ENGINEERING UPDATES REQUIRED

**P0 — Critical (Before any AI deployment)**
1. **Provision tec-ai-service**: New Railway service (Port 4011) — add to infrastructure map
2. **Anthropic API key**: Set as Railway secret on tec-ai-service — NEVER expose client-side
3. **Rate limiting**: Per-user daily AI request quota before any public endpoint goes live

**P1 — High Priority (Phase 1)**
4. **AI audit log table**: Prisma migration to add `ai_audit_log` table before first inference
5. **Output sanitizer**: Strip wallet IDs, payment tokens from all LLM outputs
6. **Prompt injection defense**: Input sanitization for all user-provided data in LLM context
7. **Cache layer**: Redis caching for repeat recommendations (5min TTL)

**P2 — Medium Priority (Phase 2)**
8. **Feedback loop**: Thumbs up/down on recommendations → improve model prompts over time
9. **A/B testing infrastructure**: Test recommendation strategies against conversion metrics
10. **Cost monitoring**: Daily Anthropic API spend dashboard — alert if > $X/day threshold

---

## 12. INTEGRATION MAP

```
C-104 (TEC AI) depends on:
← C-100 (HUB)           : Authenticated session for AI personalization
← C-105 (ANALYTICS)    : Event streams + aggregated data for AI context
← C-101 (COMMERCE)     : Product catalog, pricing, merchant data
← C-102 (ASSETS)       : Asset transaction history
← C-103 (ECOMMERCE)    : Purchase history, browse behavior
← External: Anthropic Claude API (inference backend)

C-104 (TEC AI) contributes to:
→ C-100 (HUB)           : AI-powered spending digest in Hub dashboard
→ C-101 (COMMERCE)     : Merchant pricing + demand insights
→ C-102 (ASSETS)       : Asset portfolio analysis
→ C-103 (ECOMMERCE)    : Product recommendations in marketplace
→ C-111 (ALERT)        : Anomaly detection signals
→ C-113 (FUNDX)        : Credit scoring for pool access
```

---

*Charter issued by TEC Economic Infrastructure Design Partnership*
*Version 1.0 — 2026-06-15*
