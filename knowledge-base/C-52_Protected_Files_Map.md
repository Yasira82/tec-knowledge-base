# C-52 — PROTECTED FILES MAP
## ملفات لا تُعدَّل بدون طلب صريح

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---


---

## القاعدة

> **لو مش فيه طلب صريح من Yasser → لا تمس الملفات دي**

---

## 1. Hub PaymentModal

```
File: tec-frontend/src/app/hub/page.tsx

لماذا محمي:
  - Cross-app payment logic (Commerce + Assets + Ecommerce)
  - URL params parsing (pay=1, amount, memo, product_id, return_url)
  - redirect logic بعد النجاح أو الإلغاء
  - أي تغيير هنا يكسر الدفع في كل الـ apps
```

---

## 2. Hub Middleware

```
File: tec-frontend/middleware.ts

لماذا محمي:
  - CSRF validation على كل الـ mutations
  - JWT injection من tec_access_token → Authorization header
  - Page protection
  - أي خطأ هنا → كل الـ authenticated pages تنكسر
```

---

## 4. Payment Outbox Worker

```
File: tec-payment-service/src/services/outbox.worker.ts

لماذا محمي:
  - ينقل events من DB → Redis Streams
  - لو كسر → wallet لا تتحدث بعد payment
  - Reconciliation بيصلح لكن بتأخير 60 دقيقة
```

---

## 7. متى يجوز التعديل

```
✅ عند إضافة خاصية جديدة لـ PaymentModal (بطلب صريح)
✅ عند إصلاح bug موثق في C-40 Violations Map
✅ عند إضافة app جديدة في Gateway CORS
✅ عند تحديث PI_API_KEY_[SOURCE] في env.ts

❌ Refactoring بدون سبب
❌ "تحسين" الكود بدون طلب
❌ تغيير structure الـ middleware
```