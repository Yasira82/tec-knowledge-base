# C-68 — DOMAIN OWNERSHIP MATRIX

Authority + Write Ownership + Read Rules

⚠️ هذا الـ content دستوري
أي service تكتب في domain لا تملكه = P1 violation

---

## 1. CORE PRINCIPLE — SINGLE WRITE AUTHORITY

كل domain داخل الـ ecosystem له:

- ✅ Owner واحد فقط
- ✅ Database authority واحدة فقط
- ✅ Write authority واحدة فقط
- ✅ Event publisher واحد فقط

- ❌ ممنوع multiple ownership
- ❌ ممنوع shared writes
- ❌ ممنوع cross-service DB access

القاعدة:
```
Owner Service = الوحيد المسموح له يكتب مباشرة

باقي الـ services:
→ تقرأ عبر API
→ أو عبر Redis Stream events
→ أو عبر replicated projections
```

---

## 2. DOMAIN OWNERSHIP TABLE

| Domain | Owner Service |
|---|---|
| Authentication | auth-service |
| User Identity | auth-service |
| Pi Account Binding | auth-service |
| KYC Status | auth-service |
| Subscription State | auth-service |
| JWT Blacklist | auth-service |
| Payments | payment-service |
| Payment Lifecycle | payment-service |
| Payment Approval | payment-service |
| Pi Transactions | payment-service |
| Outbox Events | payment-service |
| Wallet Balance | wallet-service |
| Ledger Entries | wallet-service |
| Transfers | wallet-service |
| ProcessedEvents (idempotency) | wallet-service |
| Notifications | notification-service |
| Notification Preferences | notification-service |
| Realtime Delivery | realtime-service |
| WebSocket Connections | realtime-service |
| Product Catalog | commerce-service |
| Commerce Orders | commerce-service |
| Merchant Stores | commerce-service |
| Asset Metadata | asset-service |
| Asset Ownership | asset-service |
| NFT Registry | asset-service |
| Media Uploads | storage-service |
| R2 File Registry | storage-service |
| Analytics Aggregation | analytics-service |
| Metrics Snapshots | analytics-service |

---

## 3. WRITE AUTHORITY RULES

✅ ONLY owner service writes directly

مثال:

```
Wallet balance:
  ✅ wallet-service
  ❌ payment-service
  ❌ auth-service
  ❌ commerce-service

KYC status:
  ✅ auth-service
  ❌ storage-service
  ❌ gateway
  ❌ frontend apps

Payment state:
  ✅ payment-service
  ❌ wallet-service (يستقبل event فقط)
  ❌ gateway
```

---

## 4. CROSS-SERVICE ACCESS RULES

✅ مسموح:
```
Service → API Gateway → Owner Service
أو:
Service → Redis Stream → Projection (read-only)
```

❌ ممنوع:
```
Direct database access بين services
Prisma cross-service imports
Shared tables بين services

// ❌ WRONG
payment-service → يقرأ auth DB مباشرة

// ✅ CORRECT
payment-service → GET /api/v1/auth/user/:id
```

---

## 5. EVENT OWNERSHIP

| Event | Owner |
|---|---|
| payment.completed | payment-service |
| auth.user.created | auth-service |
| wallet.balance.updated | wallet-service |
| subscription.upgraded | auth-service |
| notification.created | notification-service |

⚠️ فقط owner service يقدر ينشر الـ event
⚠️ باقي الـ services تستمع بس — لا تنشر

---

## 6. DATABASE OWNERSHIP

كل service تملك database منفصلة

| Service | Database |
|---|---|
| auth-service | tec_auth |
| payment-service | tec_payment |
| wallet-service | tec_wallet |
| commerce-service | tec_commerce |
| asset-service | tec_asset |
| storage-service | tec_storage |
| notification-service | tec_notification |
| kyc-service | tec_kyc |
| identity-service | tec_identity |
| realtime-service | tec_realtime |
| analytics-service | Supabase (exception) |

❌ ممنوع:
- shared schemas
- shared migrations
- shared Prisma clients
- cross-service direct queries

---

## 7. CACHE OWNERSHIP

Redis cache keys لازم تبقى namespaced بالـ service:

```
✅ CORRECT:
auth:user:123
wallet:balance:123
payment:status:pi_abc
notification:unread:123

❌ WRONG:
user:123          ← أي service ممكن تحذفه
balance:123       ← تعارض مع service تانية
```

---

## 8. FRONTEND AUTHORITY RULES

Frontend NEVER owns truth.

```
Frontend state:
✅ UI only
✅ optimistic rendering
✅ temporary display cache

Authority دائماً Backend:
❌ ممنوع balance calculations في frontend
❌ ممنوع payment approval في frontend
❌ ممنوع subscription authority في frontend
❌ ممنوع KYC authority في frontend
```

---

## 9. PAYMENT DOMAIN — الأكثر حساسية

| Authority | Owner |
|---|---|
| Payment Amount | payment-service |
| Payment State | payment-service |
| Pi Payment Verification | payment-service |
| Wallet Credit | wallet-service (via event) |

```
Client metadata:
→ tracking فقط — ليست authority
→ amount في metadata مش بيُصدَّق
→ amount في DB هو source of truth
```

---

## 10. SUBSCRIPTION DOMAIN

| Authority | Owner |
|---|---|
| Current Plan | auth-service |
| Billing Status | auth-service |
| Upgrade Validation | auth-service |
| Payment Proof | payment-service |

---

## 11. CONFLICT RESOLUTION

لو حصل conflict:
1. C-47 — Kernel Spec
2. C-64 — ADRs
3. هذا الـ content
4. Owner Service يفوز دائماً

---

## 12. VIOLATION CLASSIFICATION

| Violation | Severity |
|---|---|
| Cross-service direct DB access | P1 |
| Multiple write owners على نفس الـ domain | P1 |
| Frontend authority على payment amount | P1 |
| Wrong service ينشر foreign event | P1 |
| Shared mutable database بين services | P1 |
| Frontend calculates financial truth | P1 |

---

## Related Contents

- C-10 — System Architecture
- C-16 — Database Rules
- C-20 — Backend Services
- C-47 — Kernel Spec
- C-56 — Redis Streams
- C-67 — Source of Truth Matrix
