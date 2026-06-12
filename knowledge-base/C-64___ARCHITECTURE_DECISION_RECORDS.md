# C-64 — ARCHITECTURE DECISION RECORDS

## ADR Index + 7 Core Decisions

ليه ADRs موجودة?
كل قرار معماري غير تقليدي لازم يكون مبرر رسمي مكتوب.
External auditor يشوف httpOnly:false → "bug"
External auditor يشوف ADR-001 → "intentional — مبرر"
الفرق: -0.5 نقطة vs +0.2 نقطة في الـ score.

## ADR LIFECYCLE

```
PROPOSED → ACCEPTED → DEPRECATED
⚠️ ACCEPTED = لا يُعاد النقاش فيه إلا بـ ADR جديد
```

## INDEX

| ADR | العنوان | Status |
|-----|--------|--------|
| ADR-001 | httpOnly:false على tec_access_token | ACCEPTED |
| ADR-002 | Dual-Mode Payment Architecture | ACCEPTED |
| ADR-003 | FOREIGN_SESSION Detection Pattern | ACCEPTED |
| ADR-004 | BFF-Only Architecture | ACCEPTED |
| ADR-005 | Redis Streams over Kafka/RabbitMQ | ACCEPTED |
| ADR-006 | CSRF Exclusion على Payment BFF Routes | ACCEPTED |
| ADR-007 | Pi Payment Ownership Authority | ACCEPTED (تفاصيل في C-76) |

---

## ADR-001 — httpOnly:false على tec_access_token

**Status:** ACCEPTED | **Date:** April 2026

**السياق:** Pi Browser هو WebView — Pi SDK يحتاج يقرأ الـ token من `document.cookie`

**القرار:** `tec_access_token` يُعيَّن بـ `httpOnly: false`

**مخاطر مُدارة:**
- CSRF double-submit protection
- CSP + HTTPS + Token TTL 24h
- tec_refresh_token = httpOnly:true دايماً

**البدائل المرفوضة:** httpOnly:true → Pi Browser مش يقدر يقرأه | localStorage → Policy CI يبلوكه

---

## ADR-002 — Dual-Mode Payment Architecture

**Status:** ACCEPTED | **Date:** April 2026

**السياق:** Pi.createPayment() يشتغل فقط لو Pi.init() اتعمل على نفس الـ domain. لو user جه من Hub → الـ app لا تقدر تعمل Pi.init() تاني.

**القرار:** كل app تدعم وضعين:

- **Mode 1 — Hub Redirect:** app → `hub.tecosystem.app/hub?pay=1&...` → Hub يعمل Pi.createPayment()
- **Mode 2 — Direct Payment:** Pi.init() على domain الـ app → Pi.createPayment() مباشر

**قواعد دستورية:**
- ✅ كل app لازم تدعم Mode 1 (Hub fallback) — إلزامي
- ✅ Commerce = Reference Implementation
- ❌ App بـ Mode واحد = P1 violation

---

## ADR-003 — FOREIGN_SESSION Detection Pattern

**Status:** ACCEPTED | **Date:** April 2026

**السياق:** Pi Browser بيخلي كل الـ apps تشارك نفس Pi session.

**القرار:** `window.__TEC_PI_FOREIGN_SESSION = true` لما Pi.init() يرمي "already initialized".

**قاعدة ثابتة:**
❌ NEVER تمنع payment بسبب FOREIGN_SESSION=true — Pi.createPayment() يشتغل في الحالتين

---

## ADR-004 — BFF-Only Architecture

**Status:** ACCEPTED | **Date:** March 2026

**السياق:** Railway URLs يجب إخفاؤها عن الـ client.

**القرار:** Client Components → /api/* (BFF) → API Gateway → Services

```typescript
const GW = process.env.API_GATEWAY_URL;              // ✅ server-only
const GW = process.env.NEXT_PUBLIC_API_GATEWAY_URL;  // ❌ violation NEW-A
```

---

## ADR-005 — Redis Streams over Kafka/RabbitMQ

**Status:** ACCEPTED | **Date:** March 2026

**السياق:** Event bus موزع مطلوب. Redis موجود بالفعل.

**القرار:** Redis Streams (XADD/XREADGROUP/XACK)

**الأسباب:** Zero additional infrastructure + At-least-once delivery + Message persistence

⚠️ Kafka يُعاد النظر فيه بعد 100k+ active users

---

## ADR-006 — CSRF Exclusion على Payment BFF Routes

**Status:** ACCEPTED | **Date:** April 2026

**السياق:** Payment callbacks من Pi SDK مش بيدعم CSRF headers.

**القرار:** `CSRF_EXCLUDED = ['/api/bff/payment/']`

**التبرير:** JWT verification في كل route + Idempotency-Key يمنع replay + HTTPS only

**قاعدة ثابتة:** ✅ كل BFF payment route لازم JWT verify — إلزامي

---

## ADR-007 — Pi Payment Ownership Authority

**Status:** ACCEPTED — تفاصيل كاملة في C-76