# C-112 — NX OPPORTUNITY EXCHANGE INSTITUTIONAL CHARTER
## Opportunity Exchange — "What is the right opportunity for me now?" (ADR-010)

**Truth State:** `[Current State]` for what is built (below) · `[Planned State]` for matching
**Governance State:** `[ADR Approved]` — ADR-010 (C-64), July 2026
**Verification:** `[Code Verified]` — Tec-Nx + `tec-business-service` `src/modules/nx`. Last verified: 2026-11-14.
**Authority Scope:** [Platform]

> Rewritten 14 Nov 2026. Until then this charter's title and body described NX as **Cyber
> Security** — the role ADR-010 took away from it in July 2026 — under a banner saying so. The
> security material is kept, unchanged, in the **Appendix**: it is the source for System's
> Security Center (C-110), not NX's job.

---

## Deployment Status (2026-07-31)

> **Truth State:** `[Current State]` for the deployed app + live payment · `[Future Vision]` for the full runtime below
> **Verification:** `[Runtime Verified]` — deployed on Mainnet, real Pi payment live (SSoT: `architecture/app-fleet.yaml` → `live-verified`)

**NX is deployed on Mainnet** with Hub SSO and dual-mode (ADR-007) Pi payment live:
- **Domain:** `nx.tecosystem.app` · **Pi App ID:** `nx-cahj` · **APP_SOURCE:** `nx`
- **Payment:** real Pi subscription — Mode 1 (Hub) + Mode 2 (standalone); `PI_API_KEY_NX` set on payment-service.
- **Hub SSO:** enabled (in `/api/auth/sso` ALLOWED_TARGETS + Hub domain registry).
- **Growth:** referral loop wired (C-133).

**Still `[Future Vision]`:** the advanced runtime described below (V2+ / the charter's later phases) — vision, not yet built.

---

## 1. MISSION

Connect people in the Pi economy to opportunities — jobs, partnerships, grants, hackathons,
investments, co-founders and mentorship — on one board, ranked so that what has been verified
comes first. ADR-010: no unified opportunity marketplace existed for the Pi community; NX is it.

## 2. INSTITUTIONAL ROLE

`NX = opportunity` in ADR-010's no-overlap map: Hub = identity · Life = personal · Connection =
relationships · Zone = verification · Analytics = insight · TEC AI = reasoning · Nexus =
orchestration · System = operations + security governance · Alert = notifications.

## 3. AUTHORITY BOUNDARY

### Owns
- The opportunity index (`NxOpportunity`) and the board: search, kinds, the detail page.
- Its own ranking: **verified first, then featured, then title** — trust is ranked above paid reach.
- Posting by a signed-in member (owner = the session, never the body — P6).

### Does NOT Own
- **Verification** — Zone (C-120) / KYC. NX presents `verified`; it never mints it.
- **Capital** — payment-service and FundX (C-113). An "investment" on the board is indicative; NX moves no Pi.
- **The relationship graph** — Connection (C-107). **Security** — System's Security Center (ADR-010).

## 4. TECHNICAL ARCHITECTURE

| Part | Where | What |
|---|---|---|
| App | `Tec-Nx` (Next.js, from the template) · `nx.tecosystem.app` | board · `/opportunity/[id]` · NX Pro · BFF routes |
| Backend | `tec-business-service` (`:5018`, C-20) · `src/modules/nx` | mounted at `identity/nx` so the gateway's `/api/identity/*` route reaches it |
| API | `GET search?q=&kind=` · `GET opportunity/:handle` · `GET mine/:owner` · `POST opportunity` · `PATCH featured` | reads public; writes owner-scoped (`OwnerMatchGuard`) |
| Data | `nx_opportunities` — handle · owner · kind (JOB · PARTNERSHIP · GRANT · HACKATHON · INVESTMENT · COFOUNDER · MENTORSHIP) · title · org · summary · location · reward · verified · featured · tags | |

## 5. SECURITY MODEL

Hub SSO (C-123) · CSRF in middleware only · ADR-007 guard before every Pi call · NX Pro paid
through payment-service under `PI_API_KEY_NX` (ADR-009). Reads are public board information;
every write takes its owner from the session.

## 6. REVENUE MODEL

**NX Pro** — featured placement: more reach, never trust. A featured posting still ranks below
any verified one, and buying Pro never sets `verified`.

## 7. ENGINEERING UPDATES REQUIRED

| Item | State |
|---|---|
| Board, detail, posting, NX Pro | ✅ live |
| Trust-weighted **matching** (Life intent + Connection graph) | `[Planned State]` — ADR-010 "Phase 1+" |
| A Zone verification flowing into `verified` | not wired — today every posting starts unverified |
| The entitlement behind `featured` | TEC-AUDIT-0048 (withheld while open) — fixed on the backend work branch, not deployed |

## 8. RELATED

C-64 ADR-010 · C-110 System (Security Center) · C-111 Alert · C-120 Zone · C-107 Connection ·
C-113 FundX · C-123 session law · C-12 payment

---

## Appendix — the original charter (Cyber Security), superseded by ADR-010

> Kept verbatim. Read it as **System's security-governance scope** (C-110), not as NX.

### 1. MISSION

Secure the cryptographic trust foundation of the TEC ecosystem — monitoring threats, enforcing identity protection, and ensuring that economic trust is never compromised by technical vulnerabilities.

---

### 2. INSTITUTIONAL ROLE

```
System of Security — Cybersecurity Infrastructure
```

NX is the **security operations layer** of the TEC economic runtime. While every service self-enforces P6 (Fail Closed), NX provides platform-level security monitoring, threat detection, and cryptographic enforcement across all 12 services.

---

### 3. ECONOMIC PURPOSE

Protect economic trust.

- Without NX: one security breach = user trust collapses
- With NX: security posture visible + threats contained before breach
- Economically: security investment ≈ insurance premium for the entire platform

---

### 4. AUTHORITY BOUNDARY

### Owns
- Platform-level security monitoring
- Threat detection and classification
- Cryptographic enforcement verification
- Vulnerability assessment and remediation tracking
- Security incident response coordination
- Identity protection monitoring (anomalous access patterns)

### Does NOT Own
- Application-level security (each service self-enforces)
- Governance authority (SYSTEM — C-110)
- Identity issuance (tec-auth-service)
- Incident resolution authority (affected service owns resolution)

### Interface Points
```
OUTBOUND:
  P0 threat signals    → ALERT (C-111) — security threat escalation
  Policy violations    → SYSTEM (C-110) — governance response
  Service lockdown     → API Gateway (4000) — block compromised routes
  Admin notifications  → tec-notification-service (4008)

INBOUND:
  All service logs     → security event stream
  auth.login.failed.v1 → brute force / credential stuffing signals
  policy-check CI results → code-level security violations
  JWT anomalies        → invalid tokens, replay attempts
  Rate limit violations → DoS pattern detection
```

---

### 5. TECHNICAL ARCHITECTURE

```
Planned Stack:
  SIEM Layer: log aggregation from all 12 Railway services
  Threat Detection: rule-based (initial) + ML-based (Phase 2)
  Scanning: dependency vulnerability scanning (npm audit, Snyk)
  Network: Railway service isolation + CORS policy enforcement
  Secrets: environment variable audit (no secrets in code)

Current Security Controls (already implemented):
  JWT HS256 verify()     → every auth check (never decode-only)
  timingSafeEqual        → INTERNAL_SECRET validation
  No CORS wildcard       → 5 explicit domains allowed
  Non-root Docker USER   → all 12 services
  .dockerignore          → all services
  Policy CI              → blocks jwt.decode(), body.userId, localStorage
  DECIMAL(20,8)          → Pi amounts (no float precision loss)
  balance >= 0           → DB constraint
  Idempotency-Key        → payment-service (Redis NX)

NX Adds:
  Real-time log scanning for threat patterns
  Automated dependency vulnerability tracking
  Security event correlation across 12 services
  Threat intelligence feeds (Pi Network known attack patterns)
```

---

### 6. SECURITY MODEL

```
Security of the Security System:
  NX is highest-value target — if NX is compromised, attacker has full view
  NX admin access: strictest controls in the platform
  NX audit logs: separate, air-gapped storage
  NX code: no external dependencies not audited by Yasser

Threat Coverage:
  Authentication attacks: brute force, credential stuffing, JWT replay
  Financial attacks:      double-spend, balance manipulation, payment replay
  Infrastructure attacks: service-to-service spoofing (missing INTERNAL_SECRET)
  Code attacks:           dependency injection, supply chain (npm audit)
  Identity attacks:       session hijacking, cookie theft

Response Protocols:
  P0 security breach:     immediate service isolation via Gateway
  P1 anomalous access:    rate limit + admin notification
  P2 vulnerability found: tracked, remediation SLA: 7 days for P1 vuln
```

---

### 7. REVENUE MODEL

**Indirect (Trust Asset)**

| Channel | Value |
|---------|-------|
| Platform Trust | Security posture enables Pi Network audit approval |
| Enterprise Security | Security certification for DX builders (Phase 3) |
| Compliance Reports | External audit evidence generation |

---

### 8. KEY METRICS

```
Mean Time to Detect (MTTD):  < 5min for P0 threats
Vulnerability Remediation:   < 7 days for P1 CVEs, < 24h for P0
False Positive Rate:         < 5% of security alerts
Policy CI Pass Rate:         100% (no PR merges with known violations)
Dependency Currency:         0 known critical CVEs in production
JWT Anomaly Detection:       ≥ 99% of invalid token attempts detected
CORS Policy Compliance:      100% (no wildcard domains)
```

---

### 9. ECOSYSTEM CONTRIBUTION

- **Pi Network Audit Enabler** — security posture is a submission gate
- **Trust Preservation** — prevents security incidents that would destroy user trust
- **Compliance Evidence** — generates audit-ready security documentation
- **Developer Confidence** — DX builders trust a platform with visible security infrastructure

---

### 10. FUTURE EVOLUTION

```
Phase 1 (Foundation):
  → Log aggregation from all 12 Railway services
  → Rule-based threat detection (JWT anomaly, brute force)
  → Dependency scanning automation (weekly npm audit)

Phase 2:
  → ML-based anomaly detection
  → Automated threat response (rate limit, temporary block)
  → Security dashboard (admin view of platform security posture)

Phase 3:
  → Pi-Native Security Operations Platform
  → External security certification for DX builders
  → Threat intelligence sharing with Pi Network
```

---

### 11. ENGINEERING UPDATES REQUIRED

**P0 (Pre-Mainnet):**
```
[P0-1] Security Audit Evidence Package
  Compile evidence of all existing security controls for Pi Network audit:
  - JWT HS256 implementation
  - CORS policy configuration
  - INTERNAL_SECRET enforcement
  - Policy CI results
  This is a documentation task but critical for portal submission.

[P0-2] Dependency Audit
  Run npm audit on all 12 services. Zero critical CVEs before Mainnet.
  Add automated npm audit to CI pipeline in all repos.
```

**P1:**
```
[P1-1] Log Aggregation Setup
  Railway services generate logs but they're not aggregated.
  Implement centralized log collection before NX threat detection works.
  Options: Railway Observability, Datadog, or self-hosted ELK.
```

---

### 12. INTEGRATION MAP

```
This charter (C-112) depends on:
  All 12 tec-core-backend services → security event sources
  C-110 SYSTEM   → governance response to security violations
  C-111 ALERT    → operational anomaly correlation

Other charters depend on this one for:
  C-110 SYSTEM   → security violation governance input
  C-111 ALERT    → threat signal context
  C-115 DX       → security certification for external builders
  C-104 TEC AI   → constitutional boundary enforcement verification
```
