---
name: security-reviewer
description: "When reviewing any code change, BFF route, auth flow, or payment handler — enforce P6 Fail Closed, check forbidden patterns, and validate against Platform Security Binding."
metadata:
  version: 1.0.0
  tier: CRITICAL
  domain: security
---

# TEC Security Reviewer

P6 Fail Closed is non-negotiable. Every review starts here.

## P6 Fail Closed (C-47 — Highest Priority)

```
If doubt in identity / permission / state → DENY by default

Unknown actor context     → 401 Unauthorized
Missing session           → Redirect to Hub login
Invalid CSRF              → 403 Forbidden
Terminal state transition → 409 Conflict
Missing required field    → 400 Bad Request
Contract mismatch SDK↔BE → 500 + Alert
```

## Security Checklist (run on every PR)

```
Auth:
  □ No jwt.decode() — only verify() (Policy CI blocks decode)
  □ No localStorage for tokens — HttpOnly cookies ONLY
  □ userId ALWAYS from session/cookie — NEVER from req.body
  □ ActorContext present on all sensitive operations

Payment:
  □ ADR-007 isHubNavigation() guard present in every payment handler
  □ Payment state machine — no transitions from terminal states
  □ Pi amounts as string in API — NEVER JS Number
  □ Idempotency key on all payment gateway calls

API Security:
  □ CORS not wildcard (*) — Policy CI enforces
  □ CSRF double-submit on all POST/PUT/DELETE BFF routes
  □ x-internal-key sent only when INTERNAL_SECRET is SET (not empty string)
  □ No internal Railway URLs in response bodies or client bundle
  □ No NEXT_PUBLIC_* for internal service URLs (except gateway URL fallback)

Merchant / User Identity:
  □ Merchant identity from tec_user cookie — never from request body
  □ Policy CI blocks body.userId / body.merchantId

Infrastructure:
  □ Non-root Docker USER in all Dockerfiles
  □ .dockerignore present in all services
  □ No secrets in git history
```

## Forbidden Patterns (10 — C-47 §4)

```
1.  Direct DB mutation bypassing service layer
2.  Payment completion without event verification
3.  Cross-service shared database logic
4.  Business logic inside API Gateway
5.  Divergent SDK contracts vs backend behavior
6.  Silent failure in financial flows
7.  Reading another user's wallet/payment without authorization
8.  Sensitive operation with missing ActorContext
9.  Transitioning from terminal payment states
10. Ad-hoc system recovery without audit trail
```

## Sensitive Operations (ActorContext REQUIRED — C-47 §8)

```
→ login, logout, refresh, token issuance
→ deposit, withdraw, transfer, balance mutation
→ payment create, approve, complete, cancel, fail
→ KYC state changes
→ Asset ownership transfer
→ Any admin action
→ Identity profile mutations

Rule: if NOT listed as non-sensitive → treat as sensitive (P6)
```

## Violation Response Matrix

| Violation | HTTP Response |
|-----------|---------------|
| Invariant violation | 400/403 |
| Unknown actor context | 401 |
| Bad request / contract mismatch | 400/422 |
| SDK↔backend mismatch | 500 + alert |
| Missing required field | 400 (Zod layer) |
| Terminal state transition | 409 Conflict |
| Orphan payment | cron reconciliation (60min) |
