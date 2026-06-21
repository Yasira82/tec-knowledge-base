# C-90 — SECURITY & TRUST MODEL

## TEC Ecosystem — Threat Model, Trust Hierarchy & Security Verification

> Status: ACTIVE — Security Governance Layer
> Authority: Platform Security + Architecture
> Version: 1.1 — June 2026 (governance-approved)
> **Truth State:** [Current State] — controls implemented | [Planned State] — formal verification
> **Governance State:** [Governance Approved] — approved 21 Jun 2026 (Session 14.x); a live security model in production must be approved, not provisional
> **Verification State:** [Code Verified] — controls in codebase | [Unverified] — threat classifications
> **Authority Scope:** [Platform]

---

# PREAMBLE

```
C-15 defines security constants.
C-47 defines kernel invariants including Fail Closed (P6).
C-90 defines the formal threat model, trust hierarchy,
      and security verification framework for TEC.
```

Documentation Inflation Justification:
```
✅ New verification capability: security claims now verifiable against formal threat model
✅ New authority: security classification system (who decides what is a threat)
✅ New runtime behavior: Pi-specific threat vectors documented + mitigations verified
```

---

# 1. TRUST HIERARCHY

```
Level 0: Pi Network                    [Unconditional Trust]
         Blockchain consensus — final authority on Pi balances
         TEC cannot override Pi Network state

Level 1: Platform Governance           [Constitutional Trust]
         C-00 + C-67 + ADRs
         Defines what TEC may and may not do

Level 2: tec-auth-service              [Verified Trust]
         JWT HS256 + timingSafeEqual
         Single source of truth for Pi identity verification
         ALL other services defer identity claims to this service

Level 3: API Gateway                   [Enforced Trust]
         Every inbound request verified here
         x-internal-key on all inter-service calls
         Trust boundary between internet and internal services

Level 4: Backend Services              [Internal Trust]
         Services trust gateway-verified claims
         Services DO NOT re-verify Pi identity independently
         Services DO enforce their own business invariants

Level 5: BFF Layer (Next.js API Routes) [Session Trust]
         Cookie-based auth + CSRF validation
         Token refresh handled here
         Client NEVER receives internal service URLs

Level 6: Client Applications            [Minimal Trust]
         Client input validated at every layer
         Client NEVER authoritative for: userId, merchantId, amounts
         Client is UI only — no business logic trust

Level 7: External Developers           [Partner Trust — Gate B]
         API key + HMAC signature
         Scoped permissions
         Rate limited + monitored
```

## Constitutional Trust Rules

```
1. No service may grant itself trust above its assigned level.
2. Trust flows DOWN — never UP.
   (Client cannot claim Gateway trust)
3. Trust is verified — never assumed.
   (Missing verification = Level 6 treatment = Fail Closed)
4. Inter-service calls MUST use x-internal-key.
   Missing key = reject immediately (P6 Fail Closed)
```

---

# 2. THREAT MODEL (STRIDE)

## S — Spoofing

| Threat | Vector | Control | Status |
|--------|--------|---------|--------|
| Fake Pi identity | body.userId in request | Policy CI blocks body.userId | ✅ Mitigated |
| Stolen JWT token | JWT theft from storage | HttpOnly cookies only | ✅ Mitigated |
| Merchant impersonation | body.merchantId in request | Policy CI + session-only merchant ID | ✅ Mitigated |
| Service impersonation | Missing x-internal-key | Gateway rejects missing key | ✅ Mitigated |
| Session hijacking | Cookie theft | CSRF double-submit + SameSite | ✅ Mitigated |

## T — Tampering

| Threat | Vector | Control | Status |
|--------|--------|---------|--------|
| Payment amount modification | Client-sent amount | Backend validates with Pi Network | ✅ Mitigated |
| Balance manipulation | Direct DB access | Service layer only — no direct DB | ✅ Mitigated |
| Event replay | Duplicate event processing | Idempotency keys (Redis NX) | ✅ Mitigated |
| Pi amount precision loss | JS Number conversion | DECIMAL(20,8) + string API | ✅ Mitigated |
| Order state rollback | Terminal state transition | ALLOWED_TRANSITIONS enforcement | ✅ Mitigated |

## R — Repudiation

| Threat | Vector | Control | Status |
|--------|--------|---------|--------|
| Denied payment action | No audit trail | ActorContext required on all economic ops | ✅ Mitigated |
| Disputed merchant charge | No order record | Outbox pattern + LedgerEntry | ✅ Mitigated |
| Untracked admin action | Silent admin ops | AdminActor + audit trail required | ✅ Mitigated |
| Lost event causation | Missing causationId | Required field on all events | ✅ Mitigated |

## I — Information Disclosure

| Threat | Vector | Control | Status |
|--------|--------|---------|--------|
| Internal URLs in client | NEXT_PUBLIC_ env vars | Policy CI + BFF isolation | ✅ Mitigated |
| Railway URLs in API response | Response body leakage | NEW-A closed + audit | ✅ Mitigated |
| JWT secret exposure | Weak secret | HS256 + timingSafeEqual + env var | ✅ Mitigated |
| Cross-user data access | Missing auth check | req.user.id always from verified JWT | ✅ Mitigated |
| Error message leakage | Stack traces in prod | Structured error responses only | ⚠️ Partial |
| CORS wildcard | Misconfigured CORS | *.tecosystem.app only | ✅ Mitigated |

## D — Denial of Service

| Threat | Vector | Control | Status |
|--------|--------|---------|--------|
| Payment service overload | Unbounded requests | Circuit breaker (3 failures → OPEN) | ✅ Mitigated |
| Pi Network outage | External dependency | Mode 1 fallback (Hub redirect) | ✅ Mitigated |
| Gateway saturation | Traffic spike | Rate limiting at gateway | ⚠️ Partial |
| Redis connection exhaustion | Connection leak | Connection pooling required | ⚠️ Partial |
| Event storm | Runaway event loop | Kill switch: PAYMENTS_ENABLED | ✅ Mitigated |

## E — Elevation of Privilege

| Threat | Vector | Control | Status |
|--------|--------|---------|--------|
| User accessing admin API | Missing role check | Role from JWT — never from body | ✅ Mitigated |
| Service accessing forbidden entity | No ownership check | Canonical entity ownership (C-47) | ✅ Mitigated |
| External app accessing internal API | No authentication | API Gateway + x-internal-key | ✅ Mitigated |
| JWT decode without verify | jwt.decode() usage | Policy CI blocks jwt.decode() | ✅ Mitigated |
| Docker root privilege | Container as root | USER appuser in all Dockerfiles | ✅ Mitigated |

---

# 3. PI-SPECIFIC THREAT VECTORS

Threats unique to Pi Network integration:

## Foreign Session Attack
```
Threat:   Attacker navigates user from a hub-like URL to trigger Pi SDK issues
Vector:   isHubNavigation() returns false incorrectly → Pi.authenticate() in wrong context
Impact:   Payment failure or silent error → user funds not processed correctly
Control:  ADR-007 — isHubNavigation() mandatory in every payment handler
Verify:   Policy CI: grep for payment handlers missing isHubNavigation()
Status:   ✅ Mitigated — 4 payment handlers verified
```

## Pi SDK Version Drift
```
Threat:   Pi Network updates SDK with breaking changes
Vector:   window.Pi.* API changes → existing payment handlers fail silently
Impact:   All payments fail platform-wide
Control:  PAL (Pi Abstraction Layer) — PiRuntime.* wraps ALL window.Pi.* calls
Verify:   grep -r 'window.Pi' src/ — should return 0 results
Status:   ✅ Mitigated — PiRuntime wraps all Pi calls
```

## Payment Double-Charge
```
Threat:   Network retry causes payment to be processed twice
Vector:   POST /payment/complete called twice for same payment
Impact:   User charged twice — INV-E2 violation
Control:  Idempotency keys (Redis NX) + Outbox deduplication (ADR-004)
Verify:   Integration test: duplicate complete request returns 409
Status:   ✅ Mitigated — idempotency middleware active
```

## Pi Sandbox Leakage
```
Threat:   Sandbox payments processed as real Pi
Vector:   PI_SANDBOX env var set to true in production
Impact:   Real Pi transactions treated as test — no settlement
Control:  PI_SANDBOX=false ALWAYS on production (Constitutional constant)
Verify:   Runtime check: process.env.PI_SANDBOX === 'false' on startup
Status:   ⚠️ Verified in code — production env vars need confirmation
```

## Hub URL Spoofing
```
Threat:   Malicious site claims to be hub.tecosystem.app in referrer
Vector:   Forged document.referrer to bypass isHubNavigation() check
Impact:   Mode 1 redirect to attacker-controlled URL
Control:  /hub?pay=1 URL validated — Hub validates return URL
          document.referrer check is defense-in-depth (not trust boundary)
Verify:   Hub validates all payment URLs before processing
Status:   ⚠️ Partial — Hub URL validation needs explicit test
```

---

# 4. SECURITY CONTROLS INVENTORY

## Implemented (Code Verified)

```
✅ JWT HS256 verify() — never decode()
   Location: tec-api-gateway/src/jwt-auth.ts
   CI enforcement: Policy CI blocks jwt.decode()

✅ timingSafeEqual for secret comparison
   Location: validateInternalKey() in gateway
   Prevents timing attacks on INTERNAL_SECRET

✅ CORS: *.tecosystem.app only
   Location: main.ts all services
   CI enforcement: Policy CI blocks wildcard CORS

✅ HttpOnly cookies (tec_refresh_token)
   Location: ADR-001 — intentional design
   Note: tec_access_token httpOnly:false (Pi Browser requirement)

✅ CSRF double-submit cookie
   Location: middleware.ts all frontend apps
   Applied to: all POST/PUT/DELETE BFF routes

✅ userId from req.user.id only
   Location: Policy CI blocks body.userId
   Prevents: client-controlled identity

✅ Non-root Docker containers
   Location: USER appuser in all Dockerfiles
   Reduces: container breakout blast radius

✅ INTERNAL_SECRET on inter-service calls
   Location: API Gateway + all services
   Note: NEW-B — must be set on Railway (ops task)

✅ Payment state machine enforcement
   Location: ALLOWED_TRANSITIONS in payment-service
   Prevents: terminal state transitions

✅ balance >= 0 DB constraint
   Location: schema.prisma + migration.sql
   Prevents: negative wallet balances
```

## Partially Implemented

```
⚠️ Error message sanitization
   Current: structured errors in some places
   Needed: global error handler strips stack traces in production
   Priority: P2

⚠️ Rate limiting
   Current: basic rate limiting at gateway
   Needed: per-user + per-endpoint rate limits
   Priority: P1 (before Developer Platform)

⚠️ PI_SANDBOX=false production verification
   Current: code checks exist
   Needed: startup guard with process.exit(1) if sandbox in prod
   Priority: P1 (before Portal submission)

⚠️ Hub URL validation for Mode 1 payments
   Current: isHubNavigation() in all 4 payment handlers
   Needed: Hub explicitly validates return URLs to prevent open redirect
   Priority: P1
```

## Not Yet Implemented

```
❌ Formal penetration test
   Required: before external developer platform opens
   Gate: B prerequisite

❌ Security audit log centralization
   Current: logs per service (Pino)
   Needed: centralized security event stream
   Gate: C (Observability operational)

❌ API key anomaly detection
   Needed: when Developer Platform (C-89) opens
   Gate: B

❌ Webhook signature verification guide
   Needed: for external partners
   Gate: B
```

---

# 5. SECURITY VERIFICATION GATES

## Before Portal Submission (Current)

```
□ PI_SANDBOX=false startup guard on all 4 services
□ NEW-B: INTERNAL_SECRET set on Railway
□ Error message sanitization (P2 → P1 pre-audit)
□ Hub URL validation for Mode 1 open redirect
□ External security audit ≥ 9.5
```

## Before Developer Platform Opens (Gate B)

```
□ Rate limiting per-user + per-endpoint
□ Formal penetration test (external)
□ API key governance system live
□ Webhook signature specification published
□ Bug bounty program established
□ Security disclosure process published
□ Incident response runbook for security events
```

## Before TEC AI Ships (Gate D+)

```
□ AL-5 assurance for all TEC AI outputs
□ Adversarial input testing (prompt injection, data poisoning)
□ TEC AI kill switch tested under load
□ Governance board security review
□ ADR for TEC AI threat model accepted
```

---

# 6. SECURITY INCIDENT CLASSIFICATION

| Class | Example | Response | RTO |
|-------|---------|----------|-----|
| SEC-P0 | Pi theft / double-charge | Immediate circuit break + incident | < 15 min |
| SEC-P0 | Auth compromise | Force logout all sessions + rotate secrets | < 15 min |
| SEC-P1 | Internal URL exposure | Hotfix + audit | < 2 hours |
| SEC-P1 | JWT decode() in production | Hotfix + Policy CI update | < 2 hours |
| SEC-P2 | Rate limit bypass | Patch + log analysis | < 24 hours |
| SEC-P3 | Error message leakage | Patch in next sprint | < 1 week |

---

# 7. PI NETWORK COMPLIANCE CHECKLIST

For Pi Network portal submission:

```
□ No Pi amounts stored as JS Number (DECIMAL(20,8) only)
□ PI_SANDBOX=false on ALL production services
□ Pi App ID registered per app (Hub, Commerce, Assets, Ecommerce)
□ isHubNavigation() in all payment handlers
□ No localStorage for Pi-related tokens
□ Pi SDK version locked (no auto-upgrade in production)
□ Payment completion verified with Pi Network (outbox pattern)
□ User consent flow documented (payments require explicit confirm)
□ No silent payment failures (all errors surfaced to user)
□ Data handling declaration submitted to Pi Network
```

---

# 8. RELATIONSHIP TO OTHER CONTENTS

| Content | Relationship |
|---------|-------------|
| C-15 Security Constants | C-90 formalizes the threat model behind C-15 constants |
| C-47 Kernel Spec (P6 Fail Closed) | C-90 maps P6 to specific threat vectors |
| ADR-001 Cookie Design | C-90 documents why httpOnly:false is acceptable (Pi Browser requirement) |
| ADR-007 Payment Ownership | C-90 documents Pi-specific threats ADR-007 addresses |
| C-84 Runtime Constitution | C-90 gates (Pen test, AL-5) are prerequisites for TEC AI |
| C-89 Developer Platform | C-90 security gates must pass before Developer Platform opens |

---

# FINAL STATEMENT

```
Security is not a feature.
Security is a constitutional property of the platform.

A payment platform that is not secure is not a platform.
It is a liability.

TEC's security model is built on:
  Trust hierarchy        — who may claim what
  Threat classification  — what can go wrong
  Verified controls      — what is actually stopping it
  Governance gates       — when new capabilities are safe to open

The goal is not to pass an audit.
The goal is to be genuinely trustworthy —
for Pi users, for merchants, for partners, for Pi Network.
```
