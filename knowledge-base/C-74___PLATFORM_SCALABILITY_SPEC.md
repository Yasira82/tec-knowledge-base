# C-74 — PLATFORM SCALABILITY SPEC

> **Truth State:** `[Planned State]`
> **Governance State:** `[Draft]`
> **Verification:** `[Documentation Verified]`


Growth Limits + Scaling Thresholds + Evolution Triggers

⚠️ هذا الملف reference للمستقبل
التطبيق الفعلي بعد Portal Submission + growth

---

## 1. CURRENT ARCHITECTURE TARGET

```
Phase 1 (Now → 10k users):
  → Architecture الحالية كافية بدون تغييرات
  → 12 Railway services مع PostgreSQL per-service
  → Redis Streams للـ events
  → لا horizontal scaling مطلوب حالياً
```

---

## 2. SCALING TRIGGERS — متى تتصرف

| Trigger | Action Required |
|---|---|
| Gateway p95 > 200ms consistently | Railway scale up |
| Payment error rate > 1% | Circuit breaker + review |
| Redis memory > 80% | Increase Railway Redis plan |
| DB connections > 80% | Connection pooling (PgBouncer) |
| Redis Streams lag > 30s | Add consumer instances |
| Users > 100k active | Evaluate Kafka migration |

---

## 3. STATELESS SERVICES — جاهزين للـ scale

```
✅ يقدروا يتـ scale horizontally:
  api-gateway, auth, payment, wallet, commerce, asset

Requirements:
  - no local filesystem state
  - shared Redis للـ rate limiting + blacklist
  - shared PostgreSQL
```

---

## 4. DATABASE SCALING PLAN

```
حالياً:
  → PostgreSQL per-service (Railway)

عند 50k+ users:
  → read replicas للـ analytics + commerce
  → connection pooling (PgBouncer)

عند 200k+ users:
  → evaluate table partitioning

❌ لا sharding قبل 500k+ users
```

---

## 5. REDIS SCALING

```
حالياً:
  → shared Redis cluster
  → rate limits + streams + blacklist + cache

Redis Streams acceptable حتى:
  → 100k active users
  → 10k events/minute

بعده:
  → evaluate Kafka/Redpanda
```

---

## 6. EVENT SCALING DECISION POINT

```
Redis Streams → Kafka triggers:
  □ > 100k active users
  □ > 50k events/minute
  □ consumer lag consistently > 30s
  □ dead-letter rate > 1%

الـ migration مش قرار واحد —
محتاج ADR جديد عند trigger
```

---

## 7. WEBSOCKET SCALING

```
realtime-service:
  → sticky sessions غير مطلوبة حالياً (single instance)

عند > 10k concurrent connections:
  → distributed pub/sub bridge
  → Redis pub/sub كـ message relay بين instances
```

---

## 8. PAYMENT SCALING

```
حالياً:
  → sync Pi API calls
  → Outbox pattern (5s polling)

عند > 1000 payments/minute:
  → async queue workers زيادة
  → batch Pi API verification
```

---

## 9. FILE STORAGE

```
Cloudflare R2:
  ✅ primary object storage — scalable by design
  ✅ CDN via Cloudflare edge
  لا scaling concerns حتى petabytes
```

---

## 10. COST GOVERNANCE RULES

```
قبل إضافة أي infrastructure:
  □ prove bottleneck بـ metrics
  □ measure current utilization
  □ estimate ROI

❌ premature infrastructure complexity ممنوع
❌ over-engineering قبل الحاجة
```

---

## 11. PERFORMANCE TARGETS

```
API p95:      < 200ms
Payment:      < 3s end-to-end
Realtime:     < 500ms delivery
Auth:         < 1s
```

Raajع C-62 للتفاصيل

---

## 12. VIOLATIONS

| Violation | Severity |
|---|---|
| Premature infra complexity | P2 |
| Local filesystem dependency في service | P1 |
| Stateful app instances | P1 |
| Cache as financial authority | P0 |
| Single point of failure في critical path | P1 |

---

## Related Contents

- C-10 — System Architecture
- C-43 — CI/CD & DevOps
- C-45 — Observability
- C-56 — Redis Streams
- C-62 — SLO Definitions
