# C-01 — PROJECT IDENTITY
## TEC Ecosystem — من هو + الـ Vision + الـ Repos

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---

## 1. WHO

| البند | القيمة |
|---|---|
| **الاسم** | Yasser |
| **GitHub** | Yasira82 (كل الـ repos بدون استثناء) |
| **npm** | @yasser172 (كل الـ packages) |
| **الدور** | CEO + Founder + Sole Developer |
| **الهدف** | Pi Mainnet submission → 9.5/10 |

---

## 2. VISION

> **"24 Apps — One Identity, One Wallet, One World"**
> Digital Economic Operating System for Pi Network

TEC مش مجرد collection of apps —
بل **اقتصاد رقمي متكامل** على Pi Network.

كل user عنده:
```
Identity → Wallet → Purchase History → Assets
Subscriptions → Connections → Investments → Reputation
```
= **Unified Economic Profile**

---

## 3. THE 9 REPOS (Current)

| Repo | Domain | Stack | Deploy |
|---|---|---|---|
| Tec-core-backend | Backend | NestJS+Express | Railway |
| Tec-App | Hub | Next.js 15 | hub.tecosystem.app |
| Tec-Commerce | Commerce | Next.js 15 | commerce.tecosystem.app |
| Tec-Assets | Assets | Next.js 15 | assets.tecosystem.app |
| Tec-Ecommerce | Ecommerce | Next.js 15 | ecommerce.tecosystem.app |
| TEC-SDK | SDK | TypeScript | npm @yasser172/tec-sdk |
| tec-auth | Auth Package | TypeScript | npm @yasser172/tec-auth |
| Tec-ui | UI Package | TypeScript | npm @yasser172/tec-ui |
| tec-template-base | Template | Next.js 15 | — |

---

## 4. PI APP IDENTITY

| App | Pi App ID | Domain | PI_SANDBOX |
|-----|-----------|--------|------------|
| **Tec-Ecommerce** | `ecommerce-app-71ca4d3e462eaf54` | `https://ecommerce.tecosystem.app` | `false` |
| **Tec-Commerce** | `commerce-app-68aa99081fc1897a` | `https://commerce.tecosystem.app` | `false` |
| **Tec-Assets** | `assets-app-af2fb490e7b03db7` | `https://assets.tecosystem.app` | `false` |
| **Tec-App (Hub)** | `tec-app-923b947851f9dfe1` | `https://hub.tecosystem.app` | `false` |
| **Tec-Analytics** | `analytics-822d9810de66bc84` | `https://analytics.tecosystem.app` | `false` |
| **Tec-Life** | `life-app-c468e9eb5bf115fa` | `https://life.tecosystem.app` | `false` |

> ⚠️ Domain مرتبط بالـ Pi.init() registration. لو اتغيّر الـ domain → لازم update Pi Developer Portal.
>
> ✅ **Reconciled (21 Jun 2026):** Commerce domain confirmed as
> `commerce.tecosystem.app` — this is the domain registered in the Pi Developer
> Portal for Pi App ID `commerce-app-68aa99081fc1897a`. C-01 (§3 + §4), C-101, and
> the PORTAL_SUBMISSION_RUNBOOK are all aligned to it. Assets App ID
> `assets-app-af2fb490e7b03db7` also confirmed. All App IDs/domains now consistent.
>
> ✅ **Analytics registered (3 Jul 2026):** Pi App ID `analytics-822d9810de66bc84`,
> domain `analytics.tecosystem.app`, Mainnet (`PI_SANDBOX=false`) — Portal shows
> "Completed Steps: 10 of 10" and the "Process a Transaction" step passed with a real
> Merchant Pro payment. Full ID = Vercel `NEXT_PUBLIC_PI_APP_ID`. payment-service must
> hold `PI_API_KEY_ANALYTICS` (approving under the default Hub key returns 502 — C-12 §11).
> ⚠️ Portal note: the **Linked App** still reads *Testnet* — confirm it points to the
> Mainnet linked app before relying on production Pi ledger flows.

---

## 5. PUBLISHED PACKAGES

| Package | Version | الدور | Source |
|---|---|---|---|
| @yasser172/tec-sdk | v1.2.2 | BFF → Backend API calls | Yasira82/TEC-SDK |
| @yasser172/tec-shared | v1.1.0 | Backend middleware + event-bus | shared/ جوه Tec-core-backend ⚠️ |
| @yasser172/tec-ui | v1.2.1 | Shared UI + PaymentModal + createU2APayment | Yasira82/Tec-ui |
| @yasser172/tec-auth | v1.0.0 | Auth middleware + SSO + cookies | Yasira82/tec-auth |

---

## 6. TECH STACK

```
Frontend:  Next.js 15 App Router + TypeScript strict
Backend:   NestJS 10 + Express (mixed) + Prisma 5.22
Database:  PostgreSQL 16 (per-service) + Supabase (analytics)
Cache:     Redis 7 (Streams + Rate limiting + Blacklist)
Events:    Redis Streams XADD/XREADGROUP/XACK
Storage:   Cloudflare R2
Auth:      Pi Network SDK + JWT HS256 + httpOnly cookies
Deploy:    Railway (backend) + Vercel (frontend)
Monitor:   Sentry (frontend) + Pino (backend) + Prometheus (payment)
```

---

## 7. COOKIE ARCHITECTURE (INTENTIONAL)

| Cookie | httpOnly | السبب |
|---|---|---|
| tec_access_token | **false** | Pi Browser يقرأه عبر document.cookie |
| tec_refresh_token | **true** | Secure — مش محتاج client-side |
| tec_user | **false** | Client يحتاج user data |
| tec_csrf | **false** | Double-submit CSRF pattern |

> ⚠️ `sameSite: 'none'` REQUIRED على كل الـ cookies — Pi Browser WebView
> ⚠️ httpOnly:false على tec_access_token = INTENTIONAL مش bug
