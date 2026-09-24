# C-15 — SECURITY RULES
## Non-Negotiable — Policy CI Enforces

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Code Verified]`

---

## 1. JWT RULES

```typescript
// ✅ ALWAYS
jwt.verify(token, secret, { algorithms: ['HS256'] });

// ❌ FORBIDDEN — Policy CI blocks
jwt.decode(token);
```

---

## 2. SECRETS COMPARISON

```typescript
// ✅ ALWAYS — timing-safe
crypto.timingSafeEqual(Buffer.from(a), Buffer.from(b));

// ❌ FORBIDDEN
secret === userInput;
```

---

## 3. TOKEN SOURCE

```typescript
// ✅ Auth token من cookie
const token = req.cookies.get('tec_access_token')?.value;

// ✅ userId من JWT middleware
const userId = req.user?.id ?? ctx.userId;

// ❌ FORBIDDEN — Policy CI blocks
localStorage.getItem('tec_access_token');
body.userId;
```

---

## 4. CORS RULES

```typescript
// ✅ Explicit whitelist
const ALLOWED_ORIGINS = [
  'https://hub.tecosystem.app',
  'https://commerce.tecosystem.app',
  'https://assets.tecosystem.app',
  'https://ecommerce.tecosystem.app',
];

// ❌ FORBIDDEN — Policy CI blocks
origin: '*';
```

---

## 5. GATEWAY URL EXPOSURE

```typescript
// ✅ Server-only routes (BFF)
const GW = process.env.API_GATEWAY_URL        // server-only ✅
        ?? process.env.NEXT_PUBLIC_API_GATEWAY_URL;

// ❌ Client bundle exposure (حالي — NEW-A violation)
const GW = process.env.NEXT_PUBLIC_API_GATEWAY_URL;
```

---

## 6. INTER-SERVICE AUTH

```typescript
// ✅ كل request من Gateway للـ services
headers['x-internal-key'] = process.env.INTERNAL_SECRET;

// ✅ Startup guard
if (!process.env.INTERNAL_SECRET) process.exit(1);
```

---

## 9. POLICY CI CHECKS

```yaml
# policy-check job يرفض:
- jwt.decode(           # ← use jwt.verify
- localStorage.*token  # ← use cookies
- origin: '*'          # ← use whitelist
- continue-on-error: true  # ← على build/test/deploy
- body.userId          # ← use req.user?.id
```

---

## 10. FINANCIAL SECURITY

```sql
-- ❌ NEVER
FLOAT, DOUBLE PRECISION

-- ✅ ALWAYS
DECIMAL(20, 8)

-- ✅ DB-level constraint
CHECK (balance >= 0)
```

---

## 12. COOKIE SECURITY

```typescript
// ✅ All cookies — the locked contract is C-123 §2
{
  secure:      true,
  sameSite:    'none',  // REQUIRED for Pi Browser WebView (never 'lax' — C-123 §2 rule 1)
  partitioned: true,    // REQUIRED — C-123 LAW 3: 'none' without Partitioned is blocked in embedded contexts
  path:        '/',
}

// httpOnly per cookie type (intentional)
tec_access_token:  httpOnly: false  // Pi Browser reads via document.cookie
tec_refresh_token: httpOnly: true
tec_user:          httpOnly: false
tec_csrf:          httpOnly: false
```