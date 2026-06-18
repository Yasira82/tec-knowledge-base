# C-17 — DATA PRIVACY, RETENTION & COMPLIANCE SPEC

**Version:** 1.0.0

**Truth State:** `[Planned State]`

**Governance State:** `[Draft]`

**Verification:** `[Documentation Verified]`

**Domain:** Operations | Identity | Engineering

**Related Documents:** C-00, C-15 (Security Rules), C-16 (Database Rules), C-47 (Kernel Spec), C-71 (Financial Integrity), C-73 (Incident Response), C-90 (Security & Trust Model), C-57 (Master Index)

---

## Purpose

This document defines how the TEC platform classifies, stores, protects, retains, and deletes
personal and economic data across all 12 backend services and 4+ live apps. Because TEC handles
**Pi Network identities, KYC documents, wallets, and payments**, data privacy is a constitutional
obligation — not an optional feature. It exists so any engineer, auditor, or Pi Developer Portal
reviewer can answer: *what data do we hold, where, for how long, and on what legal/governance basis?*

## Scope

**Covered:** data classification, PII handling, KYC data lifecycle, retention & deletion schedules,
data-subject rights (access/export/erasure), consent, cross-service data sharing, and breach handling
hand-off to C-73.

**NOT covered:** transport/auth security mechanics (see C-15), database isolation & financial
atomicity (see C-16, C-71), the threat model (see C-90), or incident execution steps (see C-73).

---

## 1. Data Classification

Every field persisted by any service MUST map to exactly one class. Class drives encryption,
access, logging, and retention rules.

| Class | Definition | Examples | Storage Rule |
|-------|------------|----------|--------------|
| **C1 — Public** | Safe to expose publicly | App IDs, public profile handle, public listings | No restriction |
| **C2 — Internal** | Operational, non-personal | Correlation IDs, service metrics, feature flags | Internal only |
| **C3 — Personal (PII)** | Identifies a person | Pi UID, email, display name, IP, device | Encrypted at rest; access-controlled |
| **C4 — Sensitive / Regulated** | Financial + identity-verification data | KYC documents, wallet balances, ledger, payment records | Encrypted; least-privilege; full audit trail (C-71 §10) |

**Rule:** If a field is unclassified, it is treated as **C4** by default (P6 Fail Closed, C-47 §3).

## 2. PII & KYC Data Lifecycle

```
collected → minimized → encrypted-at-rest → access-logged → retained (per schedule) → deleted/anonymized
```

- **Minimization:** collect only what a documented feature requires. No "collect just in case".
- **KYC documents** are C4. They are stored only by the KYC service (port :5008, see C-20),
  never duplicated into other service databases (Database-per-Service, C-16 §1).
- **Cross-service references** use the Pi UID / entity ID only — never embedded PII (C-47 §4A).
- **Logging:** C3/C4 values MUST NOT be written to application logs. Log identifiers, not contents.

## 3. Retention & Deletion Schedule

| Data | Class | Retention | Basis |
|------|-------|-----------|-------|
| KYC verification documents | C4 | Duration of account + regulatory minimum, then delete | Compliance |
| Wallet ledger & payment records | C4 | Permanent (immutable audit trail) | Financial integrity (C-71 §10) — anonymize identity link on erasure, never delete the ledger |
| Identity profile (email, handle) | C3 | Until account deletion + grace window | Account lifecycle |
| Session / auth tokens | C3 | Short-lived (JWT TTL); purge on logout | C-13, C-15 §1 |
| Application / access logs | C2/C3 | Rolling window, then purge | Operations |
| Analytics aggregates | C2 | Indefinite (no raw PII) | Product |

**Erasure vs. financial records:** A data-subject erasure request MUST NOT delete immutable
financial ledger entries (required for integrity/audit). Instead, the **identity link is anonymized**
while the economic record is preserved. This boundary is non-negotiable (see C-71, C-16 §2).

## 4. Data-Subject Rights

| Right | How it is served | Owner |
|-------|------------------|-------|
| Access / Export | Provide a machine-readable export of the user's C3/C4 records | Identity service |
| Rectification | Update mutable profile fields (identity extends, never mutates core — C-47 §4) | Identity service |
| Erasure | Anonymize identity links; preserve immutable financial records | Identity + Wallet services |
| Restriction / Objection | Flag account; suspend non-essential processing | Hub (control plane) |

All rights requests are **sensitive operations** → require full ActorContext + audit trail (C-47 §7B).

## 5. Consent & Cross-Service Sharing

- Consent state is owned by the Identity domain (single write authority, C-68).
- A service may consume another domain's data only via published contracts (C-69) — never by
  reaching into another service's database (C-16 §1).
- Third-party processors (Railway, Vercel, Supabase analytics) are documented in C-44
  (Environment Variables) and must be limited to their stated class scope.

---

## Implementation Status

| Item | Status | Notes |
|------|--------|-------|
| Financial amounts as DECIMAL(20,8) + immutable ledger | ✅ Done | C-71 §2, C-16 §2 |
| Database-per-service isolation (no PII duplication) | ✅ Done | C-16 §1 |
| Field-level data classification catalog | ❌ Not Started | This spec defines the model; per-field tagging pending |
| Data-subject export/erasure endpoints | ❌ Not Started | Requires Identity + Wallet coordination |
| Retention/purge automation (logs, sessions) | ⚠️ Partial | Session TTL exists; log purge windows to formalize |

## Constraints & Invariants

- **I1:** Unclassified field ⇒ treated as C4 (Fail Closed).
- **I2:** C3/C4 values never appear in logs.
- **I3:** Erasure anonymizes the identity link; it never deletes immutable financial records.
- **I4:** No cross-service PII duplication; reference by ID only.
- **I5:** Every data-subject right is a sensitive operation (ActorContext + audit).

## Open Questions

- [ ] What is the exact regulatory retention minimum for KYC under Pi Network's mainnet requirements? (owner: Governance)
- [ ] Do we need region-specific residency (data localization) for any market? (owner: Architecture)
- [ ] Should consent receipts be event-sourced via Redis Streams (C-56)? (owner: Engineering)

## Change Log

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0.0 | 2026-06-17 | Initial draft — classification, lifecycle, retention, rights | Cloud Agent Engineering |

## Cross-References

- **Upstream:** C-00 (Constitution), C-47 (Kernel constraints), C-64 (ADR system)
- **Downstream:** C-57 (master index — registered)
- **Related:** C-15 (security mechanics), C-16 (DB rules), C-71 (financial integrity), C-73 (breach → incident), C-90 (threat model)
