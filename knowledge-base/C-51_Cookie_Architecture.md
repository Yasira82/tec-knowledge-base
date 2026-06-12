# C-51 — COOKIE ARCHITECTURE
## Pi Browser WebView Requirements + Intentional Decisions

---

## ⚠️ القاعدة الأولى: لا تفلاج httpOnly:false كـ bug

> httpOnly:false على tec_access_token = **INTENTIONAL DESIGN DECISION**
> Pi Browser WebView يقرأ الـ cookies عبر `document.cookie`
> لو غيّرته لـ httpOnly:true → Pi Browser مش هيقدر يقرأ الـ token → الـ auth ينكسر

---

## 1. COOKIE MAP

| Cookie | httpOnly | maxAge | الهدف |
|---|---|---|---|
| tec_access_token | **false** ✅ | 24h | Pi Browser يقرأه + server-side في req.cookies |
| tec_refresh_token | **true** ✅ | 7d | Secure — مش محتاج client-side |
| tec_user | **false** ✅ | 24h | Client يحتاج user data |
| tec_csrf | **false** ✅ | 24h | Double-submit CSRF |

---

## 2. REQUIRED SETTINGS — كل الـ cookies

```typescript
// ✅ REQUIRED على كل cookie
{
  secure:   true,
  sameSite: 'none',  // ← Pi Browser WebView لا يبعت cookies بدون ده
  path:     '/',
}
```

> ⚠️ لو `sameSite` مش `none` → Pi Browser WebView مش بيبعت الـ cookies
> ده مش اختياري — ده requirement لـ Pi Network

---

## 7. CSRF FLOW

```
Generation: pi-login → randomUUID() → set tec_csrf (httpOnly:false)
Reading: getCsrfToken() ← document.cookie
Sending: headers['x-csrf-token'] = getCsrfToken()
Validation: req.cookies.tec_csrf === req.headers['x-csrf-token']

Protected: POST/PUT/PATCH/DELETE على /api/bff/*
Excluded:  /api/bff/payment/* (JWT + Idempotency)
```

---

## 9. COMMON MISTAKES

```
❌ httpOnly:true على tec_access_token → Pi Browser لا يقدر يقراه
❌ sameSite:strict أو lax → Pi Browser لا يبعت الـ cookies
❌ secure:false → Cookies لا تُرسَل على HTTPS
❌ httpOnly:false على tec_refresh_token → XSS يسرق refresh token
```