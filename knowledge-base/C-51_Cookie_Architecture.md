# C-51 — COOKIE ARCHITECTURE
## Pi Browser WebView Requirements + Intentional Decisions

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`
> **Law:** the locked cookie contract is **C-123 §2** (Runtime Verified). This file explains
> the *why* of each attribute; if the two ever differ, C-123 wins.

---


---

## ⚠️ Rule one: do not flag httpOnly:false as a bug

> httpOnly:false on tec_access_token = **INTENTIONAL DESIGN DECISION**
> The Pi Browser WebView reads the cookies via `document.cookie`
> If you change it to httpOnly:true → Pi Browser cannot read the token → auth breaks

---

## 1. COOKIE MAP

| Cookie | httpOnly | maxAge | Purpose |
|---|---|---|---|
| tec_access_token | **false** ✅ | 24h | Pi Browser reads it + server-side in req.cookies |
| tec_refresh_token | **true** ✅ | 7d | Secure — not needed client-side |
| tec_user | **false** ✅ | 24h | The client needs the user data |
| tec_csrf | **false** ✅ | 24h | Double-submit CSRF |

---

## 2. REQUIRED SETTINGS — every cookie

```typescript
// ✅ REQUIRED على كل cookie — C-123 §2 (LOCKED)
{
  secure:      true,
  sameSite:    'none',  // ← Pi Browser WebView لا يبعت cookies بدون ده
  partitioned: true,    // ← C-123 LAW 3: في الـ embedded context، none من غير Partitioned بيتقفل برضه
  path:        '/',
}
```

> ⚠️ `partitioned` is not optional: without it the cookie is blocked in the webview/embedded context
> (Chrome third-party phaseout) — this was part of the July login incident (C-123 §6).

> ⚠️ If `sameSite` is not `none` → the Pi Browser WebView does not send the cookies
> This is not optional — it is a Pi Network requirement

---

## 7. CSRF FLOW

```
Generation: pi-login → randomUUID() → set tec_csrf (httpOnly:false)
Reading: getCsrfToken() ← document.cookie
Sending: headers['x-csrf-token'] = getCsrfToken()
Validation (middleware.ts ONLY — C-12 §11):
  trusted if  tec_csrf cookie === x-csrf-token header  (timing-safe)
         OR   Origin host === Host, or Origin host ends with .tecosystem.app

Protected: POST/PUT/PATCH/DELETE على الـ paths المحمية
Payment routes: مش مستثناة — الـ first-party rule هو اللي بيعدّيها
❌ ممنوع تعمل الـ check جوّه route handler — كان بيعمل 403 لدفعات Mode-2 في Pi Browser
```

---

## 9. COMMON MISTAKES

```
❌ httpOnly:true على tec_access_token → Pi Browser لا يقدر يقراه
❌ sameSite:strict أو lax → Pi Browser لا يبعت الـ cookies
❌ sameSite:none من غير partitioned → بتتقفل في الـ embedded context (C-123 LAW 3)
❌ refresh بيجدّد tec_access_token لوحده → tec_user بيخلص بعد يوم = half session (لازم الاتنين مع بعض)
❌ secure:false → Cookies لا تُرسَل على HTTPS
❌ httpOnly:false على tec_refresh_token → XSS يسرق refresh token
```