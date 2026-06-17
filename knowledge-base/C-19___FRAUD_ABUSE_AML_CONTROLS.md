# C-19 — FRAUD, ABUSE & AML / SANCTIONS CONTROLS

**Version:** 1.0.0

**Truth State:** `[Planned State]`

**Governance State:** `[Draft]`

**Verification:** `[Documentation Verified]`

**Domain:** Operations | Payment | Identity

**Related Documents:** C-00, C-12 (Dual-Mode Payment), C-13 (Auth & SSO), C-15 (Security Rules), C-17 (Data Privacy), C-71 (Financial Integrity), C-73 (Incident Response), C-76 (Pi Payment Ownership), C-90 (Security & Trust Model), C-57 (Master Index)

---

## Purpose

This document defines TEC's controls against **economic abuse** — payment fraud, account abuse,
money laundering, and sanctioned-party activity. It is distinct from C-90, which models **technical
security threats (STRIDE)**: C-90 protects the system from attackers; C-19 protects the **economy**
from misuse by otherwise-authenticated actors. For a Pi-native financial platform with KYC, this is
required for both integrity and Pi mainnet / Developer Portal readiness.

## Scope

**Covered:** fraud vectors, transaction risk signals, velocity/rate controls, KYC-tiered limits,
AML monitoring & suspicious-activity handling, sanctions screening, and abuse response.

**NOT covered:** STRIDE technical threats & trust hierarchy (C-90), payment correctness/idempotency
mechanics (C-71), auth mechanics (C-13), or privacy/retention of the data these controls produce (C-17).

---

## 1. Threat Surface (Economic Abuse, not STRIDE)

| Vector | Description | Primary control |
|--------|-------------|-----------------|
| **Payment fraud** | Stolen/again-used approval, double-charge attempts | Idempotency + Pi verification (C-71 §6, §8) |
| **Account farming** | Many fake identities to exploit promotions | KYC tiers + device/velocity signals |
| **Money laundering** | Layering value through apps to obscure origin | AML monitoring + thresholds (§4) |
| **Sanctioned parties** | Prohibited actor transacting | Sanctions screening (§5) |
| **Refund/chargeback abuse** | Exploiting reversal paths | Reversal authority + audit (C-71 §10) |
| **Collusion / wash activity** | Self-dealing between controlled accounts | Graph/velocity anomaly detection |

## 2. Transaction Risk Signals

Every financial operation carries ActorContext (C-47 §7A). Risk scoring consumes:

- **Identity signals:** KYC tier, account age, prior violations.
- **Velocity signals:** count/value of transactions per user per window.
- **Device/network signals:** IP, origin, device fingerprint (C3 data — handle per C-17).
- **Relationship signals:** repeated counterparties, circular flows.

Risk score drives an action: `allow` · `step-up (re-verify)` · `hold (review)` · `deny`.
Unknown/insufficient signal ⇒ **fail closed toward review**, never silent allow (C-47 §3, P6).

## 3. KYC-Tiered Limits & Velocity Controls

| KYC Tier | Identity assurance | Per-tx limit | Daily limit | Notes |
|----------|--------------------|--------------|-------------|-------|
| **T0 — Unverified** | Pi login only | Minimal | Minimal | Onboarding/browse |
| **T1 — Basic KYC** | Pi + basic verification | Standard | Standard | Default active user |
| **T2 — Full KYC** | Full document verification | High | High | Merchants / power users |

- Limits are **enforced server-side** at the wallet/payment service — never trusted from the client (C-15).
- Velocity counters reset per rolling window and are auditable (C-71 §10).
- Exceeding a limit triggers `step-up` or `hold`, not a hard silent failure.

## 4. AML Monitoring & Suspicious Activity

- **Continuous monitoring** of flows for structuring/layering patterns above defined thresholds.
- A flagged flow generates a **Suspicious Activity Record (SAR)** — an immutable, access-controlled
  entry (C4 data, C-17) — and routes to manual review.
- AML decisions (`clear` / `restrict` / `escalate`) are **sensitive operations**: full ActorContext +
  audit trail (C-47 §7B), and emit governance events (C-56).
- Thresholds and typologies are governed (changes require governance approval, C-99).

## 5. Sanctions Screening

- Parties are screened against applicable sanctions/prohibited lists at onboarding and on material changes.
- A positive/again-confirmed match ⇒ **block + escalate** (fail closed); funds actions are halted per
  payment ownership authority (C-76).
- Screening results are C4 data (retain/justify per C-17); false-positive handling is documented and audited.

## 6. Abuse Response

| Action | Trigger | Authority |
|--------|---------|-----------|
| Step-up verification | Elevated risk score | Automated |
| Transaction hold/review | Limit breach / AML flag | Automated → Review |
| Account restriction | Confirmed abuse | Hub control plane (C-100) |
| Funds freeze | Sanctions/AML escalation | Payment authority (C-76) + Governance |
| Reversal / clawback | Proven fraud | Per reversal authority (C-71) + audit |

All actions are reversible-with-audit where lawful, and every action is logged immutably.
Severe cases (active fraud, sanctioned funds movement) follow the **P0 path in C-73**.

---

## Implementation Status

| Item | Status | Notes |
|------|--------|-------|
| Payment idempotency + Pi verification (anti double-charge) | ✅ Done | C-71 §6, §8 |
| Immutable financial audit trail | ✅ Done | C-71 §10 |
| Server-side enforced limits | ⚠️ Partial | Wallet authority exists; tiered limits to formalize |
| KYC tiers (T0/T1/T2) wired to limits | ❌ Not Started | KYC service exists (:5008); tier→limit mapping pending |
| Velocity / risk scoring | ❌ Not Started | Requires signal pipeline (C-56) |
| AML monitoring + SAR workflow | ❌ Not Started | New capability |
| Sanctions screening | ❌ Not Started | New capability |

## Constraints & Invariants

- **I1:** Insufficient risk signal ⇒ fail closed toward review, never silent allow.
- **I2:** All limits enforced server-side; client values are advisory only.
- **I3:** AML/sanctions decisions are sensitive operations (ActorContext + immutable audit).
- **I4:** SAR and screening results are C4 data (C-17) — access-controlled, retained, justified.
- **I5:** Funds freeze/clawback honor payment ownership authority (C-76).

## Open Questions

- [ ] Which sanctions/PEP data source(s) and update cadence? (owner: Governance)
- [ ] Concrete numeric limits per KYC tier for mainnet launch? (owner: Governance + Payment)
- [ ] Build vs. integrate a third-party AML/screening provider? (owner: Architecture)

## Change Log

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0.0 | 2026-06-17 | Initial draft — fraud vectors, risk signals, KYC limits, AML, sanctions | Cloud Agent Engineering |

## Cross-References

- **Upstream:** C-00 (Constitution), C-47 (Kernel constraints), C-90 (technical threat model — complementary)
- **Downstream:** C-57 (master index — registered)
- **Related:** C-71 (financial integrity), C-76 (payment authority), C-13 (auth/KYC), C-17 (data class of fraud signals), C-73 (P0 abuse → incident)
