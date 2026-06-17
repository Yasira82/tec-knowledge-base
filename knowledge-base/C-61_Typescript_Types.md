# C-61 — TYPESCRIPT SHARED TYPES STRATEGY
## منع Type Drift بين الـ 9 Repos

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`


---

## 1. المشكلة الحالية

```
Payment type مكررة في:
  tec-payment-service/src/types/payment.types.ts
  Tec-Commerce/src/types/payment.ts
  Tec-Assets/src/lib/types.ts
  Tec-App/src/types/payment.types.ts

User type مكررة في:
  tec-auth-service/src/modules/auth/interfaces/
  src/types/pi.types.ts (في كل frontend app)
  @yasser172/tec-ui/src/types.ts (partial)

الخطر:
  backend يغير PaymentStatus → frontend مش عارف
  field يتغير اسمه → runtime error مش compile error
```

---

## 2. WHAT EXISTS في tec-ui ✅

```typescript
// @yasser172/tec-ui — موجود بالفعل ويُصدَّر

export type TecAppId = 'hub' | 'commerce' | 'assets' | 'ecommerce' | string;

export interface TecAppMeta {
  id:     TecAppId;
  name:   string;
  url:    string;
  icon:   string;
  color:  string;
}

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?:   T;
  error?:  { code: string; message: string; field?: string; requestId?: string; };
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  meta: { page: number; limit: number; total: number; };
}

export type PaymentStatus = 'created' | 'approved' | 'completed' | 'cancelled' | 'failed';

export interface PaymentRecord {
  id:         string;
  status:     PaymentStatus;
  amount:     string;     // DECIMAL string — مش number
  currency:   string;
  memo:       string;
  piPaymentId?: string;
  txid?:       string;
  createdAt:  string;
  updatedAt:  string;
}
```

---

## 3. TYPES يجب إضافتها لـ tec-ui (v1.2.0+)

```typescript
// Tec-ui/src/types/index.ts — يتوسع هنا

// ── User ────────────────────────────────────────────────────
export interface TecUser {
  id:               string;
  piId:             string;
  piUsername:       string;
  role:             'USER' | 'ADMIN';
  subscriptionPlan: 'FREE' | 'PRO' | 'ENTERPRISE';
  kycVerified:      boolean;
  createdAt:        string;
}

// ── Auth ────────────────────────────────────────────────────
export interface AuthTokens {
  accessToken:  string;
  refreshToken: string;
  expiresIn:    number;
}

export interface LoginResponse {
  success:   boolean;
  isNewUser: boolean;
  user:      TecUser;
  tokens:    AuthTokens;
}

// ── Wallet ──────────────────────────────────────────────────
export interface WalletBalance {
  userId:    string;
  balance:   string;  // DECIMAL(20,8) as string
  currency:  string;
  updatedAt: string;
}

export interface WalletTransaction {
  id:        string;
  type:      'CREDIT' | 'DEBIT';
  amount:    string;
  balance:   string;
  source:    string;
  reference: string;
  createdAt: string;
}

// ── Payment ─────────────────────────────────────────────────
export type PaymentSource = 'hub' | 'commerce' | 'assets' | 'ecommerce' | 'life';

export interface CreatePaymentRequest {
  amount:     string;  // DECIMAL string
  currency:   'PI';
  memo:       string;
  product_id: string;
  source:     PaymentSource;
}

export interface HubPayParams {
  amount:     number;
  memo:       string;
  productId:  string;
  returnUrl:  string;
  source:     PaymentSource;
}

// ── Notification ────────────────────────────────────────────
export type NotifType = 'PAYMENT' | 'WALLET' | 'KYC' | 'SECURITY' | 'SYSTEM';

export interface TecNotification {
  id:        string;
  type:      NotifType;
  title:     string;
  message:   string;
  read:      boolean;
  createdAt: string;
}

// ── KYC ─────────────────────────────────────────────────────
export type KycStatus = 'NOT_STARTED' | 'PENDING' | 'VERIFIED' | 'REJECTED';

export interface KycRecord {
  id:         string;
  userId:     string;
  status:     KycStatus;
  submittedAt?: string;
  verifiedAt?:  string;
  rejectedAt?:  string;
  reason?:    string;
}

// ── Subscription ────────────────────────────────────────────
export type SubscriptionPlan = 'FREE' | 'PRO' | 'ENTERPRISE';

export interface SubscriptionStatus {
  plan:              SubscriptionPlan;
  status:            'ACTIVE' | 'CANCELLED' | 'EXPIRED';
  currentPeriodEnd?: string;
  isExpired:         boolean;
}
```

---

## 4. USAGE RULES

```typescript
// ✅ Frontend BFF → import من tec-ui
import type { TecUser, PaymentRecord, WalletBalance }
  from '@yasser172/tec-ui';

// ✅ Backend (tec-shared) → define domain types here
// shared/src/types/payment.types.ts
export interface PaymentCompletedEvent {
  payment_id: string;
  user_id:    string;
  amount:     string;
  currency:   string;
  txid:       string;
  source:     string;
  timestamp:  string;
}

// ❌ لا تعرّف نفس الـ type في أكتر من repo
// ❌ لا تستخدم `any` للـ API responses
// ❌ لا تستخدم number لـ Pi amounts — string DECIMAL دايماً
```

---

## 5. TYPE DRIFT PREVENTION

```typescript
// Pattern: Zod schema = source of truth للـ validation

const PaymentSchema = z.object({
  id:       z.string().uuid(),
  status:   z.enum(['created', 'approved', 'completed', 'cancelled', 'failed']),
  amount:   z.string().regex(/^\d+\.\d{1,8}$/),
  currency: z.literal('PI'),
});

type Payment = z.infer<typeof PaymentSchema>;
// lو backend غيّر الـ schema → Zod بيرمي error فوراً في الـ SDK
```

---

## 6. MIGRATION PLAN

```
Phase 1 (tec-ui v1.2.0):
  □ أضف TecUser, AuthTokens, LoginResponse
  □ أضف WalletBalance, WalletTransaction
  □ أضف CreatePaymentRequest, HubPayParams
  □ أضف TecNotification, KycRecord, SubscriptionStatus

Phase 2 (بعد Mainnet):
  □ Hub: replace local types بـ tec-ui types
  □ Commerce: replace local types
  □ Assets: replace local types
  □ Ecommerce: replace local types

Phase 3 (post-Mainnet):
  □ tec-shared: export backend event types
  □ Zero type duplication across ecosystem
```

---

## 7. QUICK REFERENCE

```typescript
// Pi amounts: دايماً string مش number
amount: string  // "1.50000000"
// Parse: parseFloat(amount) للعرض فقط
// Store: DECIMAL(20,8) في DB

// User ID: UUID string
userId: string  // "550e8400-e29b-41d4-a716-446655440000"

// Timestamps: ISO 8601 string
createdAt: string  // "2026-05-25T10:30:00.000Z"

// Status enums: string union مش number enum
PaymentStatus = 'created' | 'approved' | 'completed' | 'cancelled' | 'failed'
```
