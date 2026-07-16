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

## 3. FOUNDING REPOS (core platform + packages)

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

## 3.1 FULL APP FLEET (single source of truth)

> **Machine-readable:** `architecture/app-fleet.yaml` — update it whenever an app
> changes stage. This table is a human view of that file. **Portal identity (§4) is
> canonical for registered App IDs**; `pending` here = NOT yet Portal-ready.

| App | Repo | Domain | App ID | slug | Charter | Status | Hub SSO |
|-----|------|--------|--------|------|---------|--------|:------:|
| Hub | Tec-App | hub.tecosystem.app | ✅ | hub | C-21 | live-verified | ✅ |
| Ecommerce | Tec-Ecommerce | ecommerce.tecosystem.app | ✅ | ecommerce | C-22 | live-verified | ✅ |
| Commerce | Tec-Commerce | commerce.tecosystem.app | ✅ | commerce | C-22 | live-verified | ✅ |
| Assets | Tec-Assets | assets.tecosystem.app | ✅ | assets | C-22 | live-verified | ✅ |
| Analytics | Tec-Analytics- | analytics.tecosystem.app | ✅ | analytics | C-105 | live-verified | ✅ |
| Life | Tec-Life | life.tecosystem.app | ✅ | life | C-106 | registered-not-deployed | ✅ |
| Connection | Tec-Connection | connection.tecosystem.app | ✅ | connection | C-107 | registered-not-deployed | ✅ |
| Zone | Tec-Zone | zone.tecosystem.app | ⏳ | zone | C-120 | scaffold-v1 | ✅ |
| Nexus | Tec-Nexus | nexus.tecosystem.app | ⏳ | nexus | C-109 | scaffold-v1 | ✅ |
| FundX | Tec-Fundx | fundx.tecosystem.app | ⏳ | fundx | C-113 | scaffold-v1 | ✅ |
| Estate | Tec-Estate | estate.tecosystem.app | ⏳ | estate | C-114 | scaffold-v1 | ✅ |
| Explorer | Tec-Explorer | explorer.tecosystem.app | ⏳ | explorer | C-108 | scaffold-v1 | ✅ |
| System | Tec-system | system.tecosystem.app | ⏳ | system | C-110 | scaffold-v1 | ✅ |
| Alert | Tec-Alert | alert.tecosystem.app | ⏳ | alert | C-111 | scaffold-v1 | ✅ |
| NX | Tec-Nx | nx.tecosystem.app | ⏳ | nx | C-112 | scaffold-v1 | ✅ |
| DX | Tec-Dx | dx.tecosystem.app | ⏳ | dx | C-115 | scaffold-v1 | ✅ |
| Titan | Tec-Titan | titan.tecosystem.app | ⏳ | titan | C-130 | scaffold-v1 | ✅ |
| VIP | Tec-Vip | vip.tecosystem.app | ⏳ | ⏳ | C-128 | template-raw | ❌ |
| Elite | Tec-Elite | elite.tecosystem.app | ⏳ | ⏳ | C-127 | template-raw | ❌ |
| Insure | Tec-Insure | insure.tecosystem.app | ⏳ | ⏳ | C-129 | template-raw | ❌ |
| Epic | Tec-Epic | epic.tecosystem.app | ⏳ | ⏳ | C-125 | template-raw | ❌ |
| Legend | Tec-Legend | legend.tecosystem.app | ⏳ | ⏳ | C-126 | template-raw | ❌ |
| NBF | *(no repo)* | nbf.tecosystem.app | ⏳ | nbf | C-124 | charter-only | ❌ |

> **Go-live per app** → `audits/PER_APP_LAUNCH_ENV_MATRIX.md` (env matrix + checklist).

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

## 4.1 EXTENDED APP ROSTER — User-Layer Charter Apps (C-124→C-130)

> **Truth State:** `[Planned State]` / `[Future Vision]` — these are the charter-defined
> user-layer apps. Pi App IDs here are **pending registration** (⏳) and are deliberately
> kept OUT of §4 (Pi App Identity = only Portal-registered apps with a real App ID).
> Do not treat a ⏳ row as Portal-ready.

| App | Repo | Charter | Domain (planned) | Pi App ID | Status |
|-----|------|---------|------------------|-----------|--------|
| **NBF** | *(no repo yet)* | C-124 | `nbf.tecosystem.app` | ⏳ pending | Charter only — Business Foundation (Day-1) |
| **Epic** | Tec-Epic | C-125 | `epic.tecosystem.app` | ⏳ pending | Template scaffold (V0) — Creation Runtime |
| **Legend** | Tec-Legend | C-126 | `legend.tecosystem.app` | ⏳ pending | Template scaffold (V0) — Reputation Runtime |
| **Elite** | Tec-Elite | C-127 | `elite.tecosystem.app` | ⏳ pending | Template scaffold (V0) — Excellence Runtime |
| **VIP** | Tec-Vip | C-128 | `vip.tecosystem.app` | ⏳ pending | Template scaffold (V0) — Experience Runtime (V1 = Hub PRO/ENTERPRISE exists) |
| **Insure** | Tec-Insure | C-129 | `insure.tecosystem.app` | ⏳ pending | Template scaffold (V0) — Risk Protection (escrow custody hard-gated) |
| **Titan** | Tec-Titan | C-130 | `titan.tecosystem.app` | ⏳ pending | V0/V1 enterprise console built — Enterprise OS |

> **Build gates:** all are Phase 2/3 (see each charter's Build Gate header). The repos
> stay compliant scaffolds until their gate opens. NBF (C-124) needs a repo created before
> it can be scaffolded. Titan (C-130) is the graduation target for NBF (team>5 / rev>1kπ / …).

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
