# C-44 — ENVIRONMENT VARIABLES REFERENCE
## كل الـ env vars في الـ 9 repos

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`


---

## 1. SHARED (كل الـ apps)

| Variable | NEXT_PUBLIC_ | Value | Notes |
|---|---|---|---|
| PI_SANDBOX | ✅ | false | ✅ Mainnet — دايماً false |
| PI_APP_ID | ✅ | per-app ID | منفصل لكل app |
| API_GATEWAY_URL | ❌ server-only | Railway URL | مش NEXT_PUBLIC_ |
| JWT_SECRET | ❌ | ≥ 32 chars | shared across apps |
| SSO_SECRET | ❌ | ≥ 32 chars | لـ SSO JWT |

---

## 2. HUB (Tec-App)

```env
NEXT_PUBLIC_PI_APP_ID=hub_app_id
NEXT_PUBLIC_PI_SANDBOX=false
NEXT_PUBLIC_APP_NAME=TEC Hub
NEXT_PUBLIC_APP_URL=https://hub.tecosystem.app
NEXT_PUBLIC_HUB_URL=https://hub.tecosystem.app
API_GATEWAY_URL=https://api-gateway-production-6a68.up.railway.app
JWT_SECRET=
REFRESH_SECRET=
SSO_SECRET=
SENTRY_DSN=
```

---

## 8. BACKEND — PAYMENT SERVICE (:5003)

```env
PORT=5003
NODE_ENV=production
DATABASE_URL=postgresql://...tec_payment
REDIS_URL=
INTERNAL_SECRET=    # ≥ 32 chars — required (NEW-B fix)
PI_API_URL=https://api.minepi.com
PI_API_KEY_COMMERCE=
PI_API_KEY_ASSETS=
PI_API_KEY_ECOMMERCE=
PI_API_KEY_HUB=
PI_SANDBOX=false    # ✅ Mainnet — القيمة الوحيدة المقبولة في production
PI_WEBHOOK_SECRET=
JWT_SECRET=
```

---

## 12. RULES

```
✅ NEXT_PUBLIC_* → client bundle → لا secrets
✅ API_GATEWAY_URL → server-only → خبيه
✅ JWT_SECRET → نفس القيمة في كل الـ apps
✅ INTERNAL_SECRET → ≥ 32 chars + required
✅ PI_SANDBOX → explicit true/false — no default
❌ NEXT_PUBLIC_API_GATEWAY_URL في server routes (NEW-A)
```