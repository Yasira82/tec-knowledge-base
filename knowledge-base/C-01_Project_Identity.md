# C-01 — PROJECT IDENTITY
## TEC Ecosystem — من هو + الـ Vision + الـ Repos

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

## 4. PUBLISHED PACKAGES

| Package | Version | الدور | Source |
|---|---|---|---|
| @yasser172/tec-sdk | v1.2.2 | BFF → Backend API calls | Yasira82/TEC-SDK |
| @yasser172/tec-shared | v1.1.0 | Backend middleware + event-bus | shared/ جوه Tec-core-backend ⚠️ |
| @yasser172/tec-ui | v1.1.0 | Shared UI + types + payment utils | Yasira82/Tec-ui |
| @yasser172/tec-auth | v1.0.0 | Auth middleware + SSO + cookies | Yasira82/tec-auth |

---

## 5. TECH STACK

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

## 6. COOKIE ARCHITECTURE (INTENTIONAL)

| Cookie | httpOnly | السبب |
|---|---|---|
| tec_access_token | **false** | Pi Browser يقرأه عبر document.cookie |
| tec_refresh_token | **true** | Secure — مش محتاج client-side |
| tec_user | **false** | Client يحتاج user data |
| tec_csrf | **false** | Double-submit CSRF pattern |

> ⚠️ `sameSite: 'none'` REQUIRED على كل الـ cookies — Pi Browser WebView
> ⚠️ httpOnly:false على tec_access_token = INTENTIONAL مش bug