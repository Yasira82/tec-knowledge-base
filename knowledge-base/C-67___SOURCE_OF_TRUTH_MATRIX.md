# C-67 — SOURCE OF TRUTH MATRIX

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`


Architecture Authority Map + Cross-Reference Constitution

## ⚠️ PURPOSE

هذا الملف هو المرجع الأعلى لتحديد:
  - أين توجد الحقيقة الأساسية (Source of Truth)
  - أي content يملك authority النهائي
  - أي content مجرد reference أو implementation detail

❌ ممنوع وجود authority مزدوجة لنفس الموضوع
❌ ممنوع تعديل rule في secondary reference بدون تعديل source الأصلي

✅ التعديل يبدأ دائماً من Source of Truth
❌ NEVER تعدّل secondary reference فقط

---

## 1. CONSTITUTIONAL HIERARCHY

```
Tier                    Authority Level

Kernel Spec             الأعلى — الدستور الأساسي
ADR                     قرارات معمارية مُلزِمة
Core Rules              قواعد تنفيذية رسمية
Templates               implementation patterns
Guides                  operational references
Violations              audit + tracking only
```

Hierarchy:
```
C-47 (Kernel Spec)
  ↓
C-64 (ADRs)
  ↓
Core Rule Contents
  ↓
Templates / Guides
  ↓
Violations / Checklists
```

⚠️ لو حصل conflict:
- Kernel Spec يفوز دائماً
- ثم ADR
- ثم Rule Content
- ثم Template
- ثم Guide

---

## 2. SOURCE OF TRUTH MATRIX

| Domain / Concern | Source of Truth | References |
|---|---|---|
| Kernel Constitution | C-47 | كل الملفات |
| Architecture Decisions | C-64 | C-40, C-58 |
| Violations Registry | C-40 | C-55 |
| Payment Architecture | C-12 | C-63, C-66 |
| Pi SDK Rules | C-63 | C-12, C-51 |
| Pi Browser Constraints | C-63 | C-51 |
| Authentication & SSO | C-13 | C-51, C-63 |
| Cookie Architecture | C-51 | C-13, C-63 |
| Security Rules | C-15 | C-47 |
| Environment Variables | C-44 | C-63, C-65 |
| New App Protocol | C-53 | C-63 |
| Database Rules | C-16 | C-65 |
| Backend Services | C-20 | C-65 |
| Redis Streams | C-56 | C-65, C-70 |
| Event Governance | C-70 | C-56 |
| Domain Ownership | C-68 | C-16, C-20 |
| Code Templates | C-60 | C-65, C-66 |
| Hub Completion Plan | C-58 | C-66 |
| Unified Error Format | C-59 | C-66, C-69 |
| Backend Service Scaffold | C-65 | C-20, C-60 |
| Hub Features Integration | C-66 | C-58, C-63 |
| API Contracts | C-69 | C-59 |
| Financial Integrity | C-71 | C-16, C-12 |
| Release Governance | C-75 | C-43, C-54 |
| Incident Response | C-73 | C-45, C-62 |

---

## 3. PI NETWORK OWNERSHIP

| Concern | Source of Truth |
|---|---|
| Pi.init() rules | C-63 |
| FOREIGN_SESSION behavior | C-64 ADR-003 |
| Mainnet enforcement | C-63 |
| Pi App ID isolation | C-63 |
| Dual-Mode Payment | C-12 + ADR-002 |
| Pi authenticate flow | C-63 |
| Incomplete payments | C-63 |
| Payment source-of-truth amount | C-63 |
| Pi Browser navigation | C-63 |
| Pi Browser cookie constraints | C-51 + C-63 |

⚠️ أي تغيير في Pi payment behavior:
ابدأ دائماً من: C-63 أو C-12 أو ADR-002

---

## 4. SECURITY OWNERSHIP

| Concern | Source of Truth |
|---|---|
| JWT architecture | C-15 |
| CSRF architecture | C-15 |
| CSRF payment exclusion | ADR-006 (C-64) |
| Cookie flags | C-51 |
| httpOnly:false rationale | ADR-001 (C-64) |
| BFF-only architecture | ADR-004 (C-64) |
| Internal service auth | C-15 + C-20 |
| Secrets handling | C-44 |
| Rate limiting | C-15 |
| XSS mitigations | C-15 |

⚠️ ممنوع تعريف security rule في guide فقط.
لازم rule الأساسية تكون في C-15 أو ADR رسمي.

---

## 5. BACKEND OWNERSHIP

| Concern | Source of Truth |
|---|---|
| Service boundaries | C-20 |
| Service creation policy | C-65 |
| Database ownership | C-16 + C-68 |
| Prisma conventions | C-16 |
| Redis Streams architecture | C-56 |
| Event ownership | C-70 |
| Gateway integration | C-20 |
| Healthcheck rules | C-20 |
| Docker patterns | C-65 |

قاعدة دستورية:

- ✅ كل service تملك database الخاصة بها فقط
- ❌ ممنوع direct DB access بين services
- ✅ inter-service communication: API أو Redis Streams events

---

## 6. FRONTEND OWNERSHIP

| Concern | Source of Truth |
|---|---|
| BFF architecture | ADR-004 (C-64) |
| Next.js route patterns | C-60 |
| Payment frontend flows | C-12 + C-63 |
| Hub integrations | C-66 |
| KYC frontend integration | C-66 |
| Notification realtime | C-66 |
| SPA vs full reload | C-63 section 7 |
| CSRF frontend patterns | C-51 + C-60 |

---

## 7. ADR OWNERSHIP

| ADR | Governs |
|---|---|
| ADR-001 | httpOnly:false policy |
| ADR-002 | Dual-Mode Payment Architecture |
| ADR-003 | FOREIGN_SESSION handling |
| ADR-004 | BFF-only architecture |
| ADR-005 | Redis Streams decision |
| ADR-006 | CSRF exclusion on payment BFF routes |

⚠️ أي behavior معماري مغطى بـ ADR:
- ❌ لا يُناقش داخل PR comments
- ❌ لا يُعاد تفسيره
- ✅ التعديل يكون عبر ADR جديد فقط

Lifecycle: PROPOSED → ACCEPTED → DEPRECATED

---

## 8. VIOLATION MAPPING RULES

كل violation لازم يرتبط بـ:

```
□ Source of Truth
□ Related ADR
□ Severity
□ Fix path
```

مثال:
```
NEW-A → ADR-004 → C-60 → BFF-only violation
NEW-B → C-65 → payment-service env.ts
NEW-D → C-42 → tec-auth no tests
NEW-I → ADR-002 → C-12 → Missing Mode 2
NEW-J → ADR-002 → C-12 → Missing Mode 1
NEW-C → ADR-006 → Documented exception (P2)
```

---

## 9. TEMPLATE AUTHORITY RULES

Templates لا تُنشئ قواعد جديدة.

C-60 / C-65 / C-66:
- تطبق القواعد
- لا تعيد تعريفها

❌ ممنوع: تغيير architecture داخل template

✅ الصحيح:
  - غيّر Source of Truth أولاً
  - ثم حدّث template

---

## 10. ANTI-DRIFT RULES

لمنع documentation drift:

✅ أي تعديل معماري:
  1. حدّث Source of Truth
  2. حدّث references المرتبطة
  3. حدّث checklist لو لزم
  4. حدّث violations لو متأثرة

❌ ممنوع:
- stale duplicated rules
- conflicting snippets
- multiple authorities

---

## 11. QUICK LOOKUP

```
لما تشتغل على Pi SDK:
  → C-63 + C-12 + C-51

لما تراجع قرار معماري:
  → C-64 + C-47

لما تصلح violation:
  → C-40 + الـ ADR المرتبط

لما تبني backend service:
  → C-65 + C-16 + C-20 + C-56

لما تعمل BFF route:
  → C-60 + ADR-004 (C-64)

لما تكمّل Hub:
  → C-66 + C-58

لما تراجع security:
  → C-15 + C-51 + C-64

لما تحدد مين يملك الـ domain:
  → C-68 + C-16 + C-20

لما تكتب event أو consumer:
  → C-70 + C-56

لما فيه incident مالي:
  → C-73 + C-71 + C-40
```

---

## 12. APP AUTHORITY — INSTITUTIONAL CHARTERS (C-100→C-115)

كل app عندها Charter هو مرجعها الأول:

```
App Institutional Charter (C-100→C-115)
  = Engineering Authority for that app's architecture, updates, and evolution

Authority order per app:
  C-00 → C-47 → C-64 → App Charter (C-100+) → App CLAUDE.md → Code

قبل أي تعديل على Hub    → اقرأ C-100
قبل أي تعديل على Commerce → اقرأ C-101
قبل أي تعديل على Assets  → اقرأ C-102
قبل أي تعديل على Ecommerce → اقرأ C-103
```

---

## 13. FINAL CONSTITUTIONAL RULE

```
إذا تكرر نفس rule في أكثر من content:
  Source of Truth wins دائماً.

إذا template تعارض مع ADR:
  ADR wins دائماً.

إذا guide تعارض مع Kernel Spec:
  Kernel Spec wins دائماً.

إذا App Charter تعارض مع App CLAUDE.md:
  App Charter wins — CLAUDE.md يتحدث.

⚠️ Architectural authority must always be singular.
```
