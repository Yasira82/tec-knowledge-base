# C-10 — SYSTEM ARCHITECTURE
## 3-Layer Architecture + Services Map

---

## 1. THE 3 LAYERS

```
Pi Browser (WebView)
    │
    ├── hub.tecosystem.app     (Next.js 15 — Vercel)
    ├── commerce.tecosystem.app (Next.js 15 — Vercel)
    ├── assets.tecosystem.app  (Next.js 15 — Vercel)
    └── ecommerce.tecosystem.app (Next.js 15 — Vercel)
         │
         │ BFF /api/* (Next.js API Routes)
         │ cookies: tec_access_token + tec_csrf
         ▼
    API Gateway :3000 (Railway)
    Helmet → CORS → JWT → Rate Limit → Proxy → Health
         │
         │ x-internal-key (timingSafeEqual)
         ▼
    12 Microservices (Railway — PostgreSQL per-service)
```

---

## 2. SHARED COOKIE DOMAIN

```
COOKIE_DOMAIN = .tecosystem.app
→ كل app تشارك نفس الـ cookies
→ SSO يشتغل تلقائي بين الـ apps
```

---

## 3. BFF PATTERN — القاعدة الذهبية

```
Client Components → /api/* (BFF) → API Gateway → Services
                ❌ NEVER → Railway URLs مباشرة
```

BFF هو trust-transformation layer:
- Cookie boundary
- Token mediation
- Topology hiding

---

## 4. EVENT ARCHITECTURE

```
Redis Streams (XADD/XREADGROUP/XACK)

Payment Complete → XADD payment.completed
  ├── wallet-consumer  → credit wallet
  ├── notification-consumer → push notification
  ├── analytics-consumer → record event
  └── realtime-consumer → update UI

Outbox Pattern:
  completePayment() → DB transaction → Worker (5s) → XADD
```

---

## 5. GATEWAY MIDDLEWARE ORDER

```
Helmet → CORS → requestIdMiddleware → Cache → Swagger →
JWT Auth → Rate Limiting → Proxy → Health → 404
```

---

## 6. RATE LIMITING

| Type | Limit | Store |
|---|---|---|
| Global | 100 req/15min | Redis (distributed) ✅ |
| Auth | 20 req/min | Redis ✅ |
| Payment | 30 req/min | Redis ✅ |

---

## 7. INTER-SERVICE AUTH

```typescript
// Gateway → Services
headers: {
  'x-internal-key': process.env.INTERNAL_SECRET,
  'x-request-id':   uuid,
  'Authorization':  `Bearer ${jwtToken}`,
}

// Services validation
validateInternalKey(key) {
  return crypto.timingSafeEqual(
    Buffer.from(key),
    Buffer.from(process.env.INTERNAL_SECRET)
  );
}

// Startup guard
if (!process.env.INTERNAL_SECRET) process.exit(1);
```

---

## 8. HYBRID FEDERATED ARCHITECTURE (LOCKED)

```
Independent Pi App Identity (subdomain + Pi SDK per app)
+ Shared Platform Runtime (12 services + gateway)
+ Shared Packages (@yasser172/tec-auth + tec-ui + tec-sdk)
= Hybrid Federated Platform Architecture
```

---

## 11. OBSERVABILITY (Current State)

```
✅ Sentry    — Frontend errors + breadcrumbs
✅ Pino      — Backend structured logging + redaction
✅ Prometheus — payment-service فقط
✅ Railway   — CPU + Memory metrics
❌ Distributed Tracing — غير موجود بعد
❌ Centralized Logging — غير موجود بعد
```