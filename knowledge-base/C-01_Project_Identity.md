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
> changes stage. This table is a human view of that file. **§4 is canonical for the
> Pi App IDs.** All 24 apps are **live on Mainnet** (16 Jul 2026); `live (… gated)`
> means the app is live but its high-risk financial mechanic stays read-only per charter.

| App | Repo | Domain | App ID | slug | Charter | Status | Hub SSO |
|-----|------|--------|--------|------|---------|--------|:------:|
| Hub | Tec-App | hub.tecosystem.app | ✅ | hub | C-21 | live | ✅ |
| Ecommerce | Tec-Ecommerce | ecommerce.tecosystem.app | ✅ | ecommerce | C-22 | live | ✅ |
| Commerce | Tec-Commerce | commerce.tecosystem.app | ✅ | commerce | C-22 | live | ✅ |
| Assets | Tec-Assets | assets.tecosystem.app | ✅ | assets | C-22 | live | ✅ |
| Analytics | Tec-Analytics- | analytics.tecosystem.app | ✅ | analytics | C-105 | live | ✅ |
| Life | Tec-Life | life.tecosystem.app | ✅ | life | C-106 | live | ✅ |
| Connection | Tec-Connection | connection.tecosystem.app | ✅ | connection | C-107 | registered-not-deployed | ✅ |
| Zone | Tec-Zone | zone.tecosystem.app | ✅ | zone | C-120 | live | ✅ |
| Nexus | Tec-Nexus | nexus.tecosystem.app | ✅ | nexus | C-109 | live | ✅ |
| FundX | Tec-Fundx | fundx.tecosystem.app | ✅ | fundx | C-113 | live (pools gated) | ✅ |
| Estate | Tec-Estate | estate.tecosystem.app | ✅ | estate | C-114 | live | ✅ |
| Explorer | Tec-Explorer | explorer.tecosystem.app | ✅ | explorer | C-108 | live | ✅ |
| System | Tec-system | system.tecosystem.app | ✅ | system | C-110 | live | ✅ |
| Alert | Tec-Alert | alert.tecosystem.app | ✅ | alert | C-111 | live | ✅ |
| NX | Tec-Nx | nx.tecosystem.app | ✅ | nx | C-112 | live | ✅ |
| DX | Tec-Dx | dx.tecosystem.app | ✅ | dx | C-115 | live | ✅ |
| Titan | Tec-Titan | titan.tecosystem.app | ✅ | titan | C-130 | live | ✅ |
| VIP | Tec-Vip | vip.tecosystem.app | ✅ | vip | C-128 | live | ✅ |
| Elite | Tec-Elite | elite.tecosystem.app | ✅ | elite | C-127 | live | ✅ |
| Insure | Tec-Insure | insure.tecosystem.app | ✅ | insure | C-129 | live (escrow gated) | ✅ |
| Epic | Tec-Epic | epic.tecosystem.app | ✅ | epic | C-125 | live | ✅ |
| Legend | Tec-Legend | legend.tecosystem.app | ✅ | legend | C-126 | live | ✅ |
| NBF | Tec-Nbf | nbf.tecosystem.app | ✅ | nbf | C-124 | live | ✅ |
| Brookfield | Tec-Brookfield | brookfield.tecosystem.app | ✅ | brookfield | C-131 | live (invest. gated) | ✅ |

> **Go-live per app** → `audits/PER_APP_LAUNCH_ENV_MATRIX.md` (env matrix + checklist).

---

## 4. PI APP IDENTITY

> **All 24 apps registered + live on Mainnet with real Pi (16 Jul 2026).** Every
> app has a Pi App ID, is deployed, and its Pro/subscription payment surface
> processes real Pi (Portal "Process a Transaction" passed). See the note below on
> which financial mechanics remain hard-gated.

| App | Pi App ID | Domain | PI_SANDBOX |
|-----|-----------|--------|------------|
| **Tec-App (Hub)** | `tec-app-923b947851f9dfe1` | `https://hub.tecosystem.app` | `false` |
| **Tec-Commerce** | `commerce-app-68aa99081fc1897a` | `https://commerce.tecosystem.app` | `false` |
| **Tec-Assets** | `assets-app-af2fb490e7b03db7` | `https://assets.tecosystem.app` | `false` |
| **Tec-Ecommerce** | `ecommerce-app-71ca4d3e462eaf54` | `https://ecommerce.tecosystem.app` | `false` |
| **Tec-Analytics** | `analytics-822d9810de66bc84` | `https://analytics.tecosystem.app` | `false` |
| **Tec-Life** | `life-app-c468e9eb5bf115fa` | `https://life.tecosystem.app` | `false` |
| **Tec-Connection** | `connection-aa9fba4f11664096` | `https://connection.tecosystem.app` | `false` |
| **Tec-Estate** | `estate-f4d67b390ff45ed6` | `https://estate.tecosystem.app` | `false` |
| **Tec-Fundx** | `fundx-55a3cb7bc6cf09fd` | `https://fundx.tecosystem.app` | `false` |
| **Tec-Zone** | `zone-xwc6` | `https://zone.tecosystem.app` | `false` |
| **Tec-Nexus** | `nexus-3x2v` | `https://nexus.tecosystem.app` | `false` |
| **Tec-Explorer** | `explorer-kxfp` | `https://explorer.tecosystem.app` | `false` |
| **Tec-Dx** | `dx-hqma` | `https://dx.tecosystem.app` | `false` |
| **Tec-Nx** | `nx-cahj` | `https://nx.tecosystem.app` | `false` |
| **Tec-system** | `system-qbz2` | `https://system.tecosystem.app` | `false` |
| **Tec-Alert** | `alert-3ag1` | `https://alert.tecosystem.app` | `false` |
| **Tec-Titan** | `titan-e1ta` | `https://titan.tecosystem.app` | `false` |
| **Tec-Epic** | `epic-4muf` | `https://epic.tecosystem.app` | `false` |
| **Tec-Insure** | `insure-ayh6` | `https://insure.tecosystem.app` | `false` |
| **Tec-Legend** | `legend-43xr` | `https://legend.tecosystem.app` | `false` |
| **Tec-Elite** | `elite-cfwh` | `https://elite.tecosystem.app` | `false` |
| **Tec-Vip** | `vip-vzge` | `https://vip.tecosystem.app` | `false` |
| **Tec-Nbf** | `nbf-zutt` | `https://nbf.tecosystem.app` | `false` |
| **Tec-Brookfield** | `brookfield-ftq4` | `https://brookfield.tecosystem.app` | `false` |

> ⚠️ **Real Pi = subscriptions, NOT gated financial mechanics.** All 24 process
> real Pi for their **Pro/subscription** surfaces. But the high-risk financial
> mechanics remain **hard-gated + read-only** by charter until legal + payment-service
> custody + SYSTEM: **FundX** pools (C-113), **Insure** escrow (C-129), **Brookfield**
> investment/REITs (C-131). Do NOT treat those as live — escrow/pool/REIT custody is
> Invariant-#8 gated.

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

## 4.1 USER-LAYER CHARTER APPS (C-124→C-131) — now LIVE

> The user-layer charter apps (NBF · Epic · Legend · Elite · VIP · Insure · Titan ·
> Brookfield) are **registered + live on Mainnet** — their Pi App IDs are in **§4**
> above (canonical). They ship as honest **read-only V1** surfaces + a real-Pi Pro
> subscription; their charters' Phase-2/3 features (and the FundX/Insure/Brookfield
> financial hard-gates) remain future work. NBF (C-124) graduates a business INTO
> Titan (C-130); Legend→Elite→VIP is the reputation→recognition→experience chain.

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
