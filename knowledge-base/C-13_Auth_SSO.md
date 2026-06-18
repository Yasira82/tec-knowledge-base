# C-13 — AUTH & SSO ARCHITECTURE
## Pi Login → JWT → Cookies → Cross-App SSO

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Code Verified]`

---

## 1. AUTH FLOW

```
Pi Browser
    │
    ▼
window.Pi.authenticate(['username','payments'], onIncomplete)
    │
    ▼ accessToken
POST /api/auth/pi-login (BFF)
    │
    ▼
auth-service: verify via Pi API /v2/me
    │
    ▼ JWT tokens
BFF sets 4 cookies:
  tec_access_token  (httpOnly:false, 24h)
  tec_refresh_token (httpOnly:true,  7d)
  tec_user          (httpOnly:false, 24h)
  tec_csrf          (httpOnly:false, 24h)
```

---

## 2. SSO FLOW (Cross-App)

```
User على commerce.tecosystem.app (مش logged in)
    │
    ▼
window.location.href = hub.tecosystem.app/api/auth/sso
                       ?target=https://commerce.tecosystem.app/app
    │
    ▼ Hub (لو logged in)
Hub: SignJWT({ accessToken, user }) → HS256 → 5min expiry
    │
    ▼
Redirect → commerce.tecosystem.app/api/auth/sso-callback?token=JWT
    │
    ▼
verify JWT + replay protection (JTI check)
Set cookies + Redirect → /app
```

---

## 3. SHARED COOKIE DOMAIN

```
COOKIE_DOMAIN = .tecosystem.app
→ كل app تشارك نفس JWT_SECRET + REFRESH_SECRET
→ SSO مطلوب فقط لو cookies مش موجودة
```

---

## 5. JWT VERIFICATION

```typescript
// Backend
jwt.verify(token, process.env.JWT_SECRET, {
  algorithms: ['HS256']  // ✅ ALWAYS specify algorithms
});

// ❌ NEVER
jwt.decode(token)  // Policy CI blocks this
```

---

## 6. @yasser172/tec-auth PACKAGE

```typescript
import { createAuthMiddleware } from '@yasser172/tec-auth/middleware';

export default createAuthMiddleware({
  protectedRoutes:    ['/app', '/dashboard'],
  csrfProtectedPaths: ['/api/auth/logout', '/api/bff/'],
  loginRedirectUrl:   '/',
});
```

---

## 7. CSRF PROTECTION

```
Pattern: Double-Submit Cookie

1. pi-login/route.ts → set tec_csrf = randomUUID()
2. Client reads tec_csrf from document.cookie
3. Client sends x-csrf-token header
4. middleware validates: cookie === header

Protected: POST/PUT/PATCH/DELETE على /api/bff/*
Excluded:  /api/bff/payment/* (JWT + Idempotency)
```

---

## 10. REDIS BLACKLIST

```typescript
blacklist.set(oldRefreshToken, 'used', { EX: 7 * 24 * 60 * 60 });

// Startup guard
if (!process.env.REDIS_URL && process.env.NODE_ENV === 'production') {
  throw new Error('REDIS_URL required for token rotation');
}
```