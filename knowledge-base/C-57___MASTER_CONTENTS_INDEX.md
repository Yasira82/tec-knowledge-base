# C-57 — MASTER CONTENTS INDEX
## دليل سريع للـ 62 Content (C-00 → C-86)

**Last Updated:** June 2026

---

## TIER 1 — اقرأهم دايماً أول كل session

| Content | العنوان | جملة واحدة |
|---------|---------|----------|
| **C-00** | Platform Constitution v3.0 | قواعد الـ platform + governing principles |
| **C-01** | Project Identity | مين Yasser + الـ 9 repos + الـ packages |
| **C-02** | Current State | Score الحالي + violations + Portal checklist |
| **C-12** | Dual-Mode Payment ⭐ | أهم قاعدة — Mode 1 Hub + Mode 2 Direct |
| **C-67** | Source of Truth Matrix ⭐ | Authority map — من يملك الحقيقة في كل موضوع |
| **C-76** | Pi Payment Ownership (ADR-007) ⭐ | isHubNavigation + Ownership — مُلزم لكل payment |

---

## TIER 2 — Architecture + Governance (مرجع ثابت)

| Content | العنوان | جملة واحدة |
|---------|---------|----------|
| **C-10** | System Architecture | 3-Layer + BFF + Events |
| **C-11** | Repository Map | 9 repos + key files + patterns |
| **C-13** | Auth & SSO | Pi Login → JWT → Cookies → SSO flow |
| **C-14** | Shared Packages | tec-sdk + tec-auth (95% cov) + tec-ui + tec-shared |
| **C-15** | Security Rules | JWT + CSRF + timingSafeEqual + Policy CI |
| **C-16** | Database Rules | DECIMAL + balance>=0 + isolation + Prisma |
| **C-47** | Kernel Spec + Binding | Constitution — P6 Fail Closed + 10 Forbidden |
| **C-64** | Architecture ADRs | ADR-001→ADR-007 — قرارات معمارية مُلزمة |
| **C-77** | Strategic Analysis v5.0 ⭐ | Platform risks + roadmap + key learnings |
| **C-78** | Platform Operations (merged) | SLOs + incidents + ownership + ops |
| **C-82** | Platform Maturity & Evolution | Expansion gates + PRI + maturity stages |
| **C-83** | EVL/ESL Design System | Semantic colors + Phase 1 in tec-ui v1.2.0 |
| **C-84** | Runtime Constitution | Gates A→E + governance boundary |
| **C-85** | Infrastructure Stack | Layer identity + build sequence |
| **C-86** | Temporal Governance | Distributed temporal authority (Gate D+) |

---

## TIER 3 — Per-App (عند العمل على app معينة)

| Content | العنوان | جملة واحدة |
|---------|---------|----------|
| **C-20** | Backend Services | 12 services + ports + Railway URLs |
| **C-21** | Hub App | PaymentModal + SSO Provider |
| **C-22** | Commerce + Assets + Ecommerce | محتوى + payment status ✅ All apps ADR-007 |
| **C-23** | TEC-SDK | 7 clients + withRetry + Zod + usage rules |
| **C-51** | Cookie Architecture | httpOnly:false = INTENTIONAL + sameSite:none |
| **C-52** | Protected Files | ملفات لا تُعدَّل بدون طلب صريح |
| **C-63** | Pi Network Integration Rules | Pi Browser + Pi SDK + Mainnet — مرجع موحد |
| **C-66** | Hub Features Code Guide | KYC + Subscription + Notifications — كود جاهز |

---

## TIER 4 — Product Vision + Infrastructure

| Content | العنوان | جملة واحدة |
|---------|---------|----------|
| **C-30** | Vision + 24 Apps | Platform vs Apps + Infrastructure layers |
| **C-31** | Life + Connection + Fundx + Estate | Blueprints + متطلبات + backend |
| **C-32** | Nexus + Titan + DX + Others | متى + ليه + ترتيب |
| **C-85** | Infrastructure Stack | Layer 0→4 + build sequence + gates |

---

## TIER 5 — Operations

| Content | العنوان | جملة واحدة |
|---------|---------|----------|
| **C-40** | Violations Map | Zero P0. Zero P1. ✅ P2 deferred |
| **C-41** | Engineering Roadmap | Phase 0 DONE → tec-ui → audit → Portal |
| **C-42** | Testing Strategy | Jest + Vitest + Playwright + k6 |
| **C-43** | CI/CD & DevOps | GitHub Actions + Railway + Vercel + Docker |
| **C-44** | Environment Variables | كل الـ env vars في الـ 9 repos |
| **C-45** | Observability | Sentry + Pino + Prometheus + health checks |
| **C-46** | Commercial Strategy | Revenue model + Growth phases |
| **C-68** | Domain Ownership | Write authority map |
| **C-69** | API Contracts | HTTP contracts + versioning + decimal rules |
| **C-70** | Event Governance | Redis Streams ownership + dead-letter |
| **C-71** | Financial Integrity | Balance + ledger + settlement + P0 rules |
| **C-72** | Frontend State | Client boundaries + auth rules + routing |
| **C-73** | Incident Runbook | P0/P1 flows + payment + auth + rollback |
| **C-74** | Scalability Spec | Growth triggers + scaling thresholds |
| **C-75** | Release Governance | Deploy gates + package releases + migration |

---

## TIER 6 — Engineering Protocols

| Content | العنوان | جملة واحدة |
|---------|---------|----------|
| **C-48** | Audit Report May 2026 | 9-repo full audit + discoveries |
| **C-49** | Engineering Work Map | خريطة عمل شاملة — Phase 0 DONE |
| **C-50** | Session Log | آخر session + decisions + ما تم |
| **C-53** | New App Protocol | Day 1 → Launch خطوة بخطوة |
| **C-54** | Package Management | npm publish sequence + update protocol |
| **C-55** | Scoring & Audit | Score history + gap pattern + path to 9.5 |
| **C-56** | Redis Streams Events | Event bus map + consumers + payloads |
| **C-58** | Hub Completion Plan | KYC + Subscription + Notifications |
| **C-59** | Unified Error Format | TecErrorResponse + error codes |
| **C-60** | Code Templates | 8 templates جاهزة |
| **C-61** | TypeScript Types Strategy | Shared types + منع drift |
| **C-62** | SLO Definitions | Payment 99.9% + SLO targets |
| **C-65** | New Backend Service | NestJS scaffold + Service Creation Gate |

---

## DELETED / MERGED

| Content | الحالة | ملاحظة |
|---------|--------|-------|
| **C-79** | ❌ MERGED → C-78 | Platform Operations Model |
| **C-80** | ❌ MERGED → C-78 | Incident & Postmortem Governance |
| **C-81** | ❌ MERGED → C-78 | Runtime Ownership & Accountability |

---

## QUICK LOOKUP

```
Payment:         C-12 + C-76 (ADR-007) + C-40 + C-63
Security:        C-15 + C-47 + C-51 + C-64
Architecture:    C-64 + C-47 + C-67 + C-77
New app:         C-53 + C-63 + C-12 + C-44 + C-83
Backend service: C-65 + C-20 + C-56 + C-16
Package update:  C-54 + C-22 + C-12 (test first)
Incidents:       C-73 + C-71 + C-78
Deploy:          C-75 + C-43
Vision:          C-30 + C-85 (infrastructure) + C-82 (maturity)
Design:          C-83 + C-84 (runtime gates)
Strategic:       C-77 + C-85 + C-82
Conflicts:       C-67 (Source of Truth) — ابدأ هنا دائماً
```

---

## CONSTITUTIONAL HIERARCHY

```
C-00   Platform Constitution v3.0
  ↓
C-47   Kernel Spec + Binding
  ↓
C-64   ADRs (ADR-001→ADR-007)
  ↓
C-77   Strategic Analysis v5.0
  ↓
C-15 / C-12 / C-16 / C-63
  ↓
C-78   Platform Operations (merged)
  ↓
C-82   Platform Maturity
  ↓
C-83→C-86  Design + Runtime + Infra
```

⚠️ لو حصل conflict: C-00 → C-47 → C-64 → C-67 → Rule Content