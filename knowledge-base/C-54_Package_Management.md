# C-54 — PACKAGE MANAGEMENT
## npm Publish Sequence + Update Protocol

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`


---

## 1. PACKAGE HIERARCHY

```
الـ packages مترتبة — الأسفل يعتمد على الأعلى:

Level 0 (Base):
  @yasser172/tec-shared ← backend فقط (shared/ في Tec-core-backend)

Level 1 (SDK):
  @yasser172/tec-sdk    ← BFF routes

Level 2 (Auth + UI):
  @yasser172/tec-auth   ← يعتمد على tec-shared (indirect)
  @yasser172/tec-ui     ← payment utils + components

Level 3 (Apps):
  tec-template-base     ← يعتمد على tec-auth + tec-ui + tec-sdk
  Tec-Commerce          ← يعتمد على tec-auth + tec-ui + tec-sdk
  Tec-Assets            ← نفس
  Tec-Ecommerce         ← نفس
  Tec-App (Hub)         ← يعتمد على tec-sdk
  [apps جديدة]         ← نفس
```

---

## 2. PUBLISH SEQUENCE — الترتيب الصح

```
1. @yasser172/tec-shared
   لما: تغيير في Backend middleware أو event-bus
   يأثر على: Backend services فقط
   مش محتاج: تحديث الـ frontend apps

2. @yasser172/tec-sdk
   لما: تغيير في BFF clients أو withRetry
   يأثر على: BFF routes في كل الـ apps
   محتاج: npm install في Hub + Commerce + Assets + Ecommerce

3. @yasser172/tec-auth
   لما: تغيير في middleware أو SSO أو hooks
   يأثر على: كل الـ apps (middleware + usePiAuth)
   محتاج: npm install في كل الـ apps + template

4. @yasser172/tec-ui
   لما: تغيير في components أو payment layer
   يأثر على: كل الـ apps
   محتاج: npm install في كل الـ apps + template

5. Apps (بالترتيب ده دايماً):
   Commerce أولاً → Assets → Ecommerce → template → [new apps]
```

---

## 3. PUBLISH COMMAND

```bash
# في كل package repo
npm version patch   # أو minor أو major
npm run build
npm publish

# تأكد الـ version اتضاف
npm info @yasser172/tec-ui version
```

---

## 4. UPDATE PROTOCOL — بعد الـ Publish

### لما تحدث tec-ui:
```bash
# STEP 1: Commerce أولاً (دايماً)
cd Tec-Commerce
npm install @yasser172/tec-ui@NEW_VERSION
npm run build
npm test

# STEP 2: اختبر يدوياً
# Mode 1: Hub redirect → PaymentModal → Success
# Mode 2: Pi.createPayment مباشر → Success
# FOREIGN_SESSION: Hub session → Commerce → Mode 2 شغال

# STEP 3: لو Commerce شغال → باقي الـ apps
cd Tec-Assets
npm install @yasser172/tec-ui@NEW_VERSION

cd Tec-Ecommerce
npm install @yasser172/tec-ui@NEW_VERSION

cd tec-template-base
npm install @yasser172/tec-ui@NEW_VERSION

# STEP 4: لو في مشكلة → Rollback
npm install @yasser172/tec-ui@OLD_VERSION
```

### لما تحدث tec-auth:
```bash
# نفس protocol بالظبط
# Commerce أولاً → اختبر SSO + login + CSRF → ثم باقي الـ apps
```

### لما تحدث tec-sdk:
```bash
# Hub BFF routes أولاً (Hub هو الأكثر استخداماً)
# ثم Commerce → Assets → Ecommerce
```

---

## 5. COMMERCE = INTEGRATION TEST

```
قانون ثابت:
  بعد أي package update → Commerce لازم يشتغل أولاً

لماذا Commerce:
  ✅ Reference Implementation للـ Dual-Mode Payment
  ✅ أكتر app بتستخدم كل الـ packages
  ✅ لو Commerce شغال → الـ package update آمن
  ❌ لو Commerce وقع → rollback فوراً

Commerce Integration Test Checklist:
  □ Login (Pi Browser auth)
  □ Mode 1: Hub redirect → PaymentModal → Success
  □ Mode 2: Pi.createPayment مباشر → Success
  □ Orders page يعرض الـ orders
  □ No console errors
```

---

## 6. VERSION MANAGEMENT

```
Semver rules:
  patch (1.1.0 → 1.1.1): Bug fixes — backward compatible
  minor (1.1.0 → 1.2.0): New features — backward compatible
  major (1.1.0 → 2.0.0): Breaking changes — NEEDS migration

Breaking changes في tec-ui → يأثر على كل الـ apps
  → عمل migration guide قبل publish
  → اختبر كل app يدوياً

تحديث tec-ui v1.2.0 (TODO):
  أضف: createPaymentRecord + createU2APayment + PaymentModal
  Type: minor (backward compatible — additions فقط)
```

---

## 7. npm LINK للـ Development المحلي

```bash
# بدل npm publish في كل تغيير صغير
cd Tec-ui
npm run build
npm link

cd Tec-Commerce
npm link @yasser172/tec-ui

# اختبر محلياً → ثم publish
npm unlink @yasser172/tec-ui
npm install @yasser172/tec-ui@VERSION
```

---

## 8. PUBLISH CHECKLIST

```
قبل npm publish لأي package:

□ npm run build ← بدون errors
□ npm test ← كل الـ tests بتعدي
□ version اتحدث في package.json
□ CHANGELOG.md اتحدث
□ README.md دقيق (examples صح)
□ .npmignore موجود (لا يضم __tests__)

بعد npm publish:
□ npm info @yasser172/[package] version ← تأكيد
□ Commerce npm install + اختبر
□ Deploy Commerce إن لزم
```