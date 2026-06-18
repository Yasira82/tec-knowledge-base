# C-1XX — [APP NAME] INSTITUTIONAL CHARTER

> **Truth State:** `[Future Vision]`
> **Governance State:** `[Draft]`
> **Verification:** `[Documentation Verified]`
> **Version:** 1.0.0 | Created: YYYY-MM-DD

---

## 1. Mission

**[App Name]** is the **[System Role]** within the TEC Economic Coordination Infrastructure.

**Economic Function:**
[One sentence: what economic stage does this app serve in the Runtime Lifecycle?]

```
Economic Runtime Lifecycle position:
Settlement → Record → Reasoning → Access → Construction → Production → Economic Activity
                                     ↑
                              [App Name sits here]
```

**Value Proposition:**
[What does this app enable for Pi users / merchants / the ecosystem?]

---

## 2. Authority Boundary

### This App OWNS
```
□ [Domain 1] — e.g., user profiles, product listings, asset records
□ [Domain 2] — e.g., specific UI/UX decisions
□ [Domain 3] — e.g., specific business logic
```

### This App CONSUMES (from platform)
```
□ Identity / SSO    → Hub (C-100) — tec_user cookie, tec_access_token
□ Payment runtime   → tec-payment-service (C-101 pattern)
□ Design system     → @yasser172/tec-ui
□ Auth package      → @yasser172/tec-auth
□ BFF SDK           → @yasser172/tec-sdk
□ [Other services]  → [list what this app reads from other services]
```

### This App NEVER
```
□ Implements custom auth (Hub SSO is the authority)
□ Calls Pi SDK without isHubNavigation() check (ADR-007)
□ Stores tokens in localStorage (HttpOnly cookies only)
□ Derives user identity from request body (tec_user cookie only)
```

---

## 3. Technical Architecture

### Stack
```
Frontend:    Next.js 15 App Router + TypeScript strict
Design:      @yasser172/tec-ui (inline styles — Pi Browser compatible)
Auth:        @yasser172/tec-auth (Hub SSO cookies)
BFF SDK:     @yasser172/tec-sdk (server-side only)
Deployment:  Vercel
```

### Backend Services Used
```
[Service name] :[port] — [what this app needs from it]
e.g.:
tec-api-gateway   :4000 — all BFF proxied through here
tec-auth-service  :4001 — identity verification
tec-payment-service :4002 — Pi payment processing
```

### Key Routes
```
[Route]         — [purpose]
e.g.:
/[app-name]     — main page
/api/bff/[...]  — BFF routes (server-side only)
```

### Pi App Identity
```
Pi App ID: [to be registered]
Domain:    [app].tecosystem.app
```

---

## 4. Security Model

### Authentication
```
Pattern:  Hub SSO — cookies set by hub.tecosystem.app
Cookies:  tec_access_token (JWT), tec_csrf, tec_user (JSON profile)
Storage:  HttpOnly cookies ONLY — never localStorage
CSRF:     x-csrf-token header required on all POST/PUT/DELETE BFF routes
Fail:     Missing session → deny, redirect to Hub login (P6 Fail Closed)
```

### Pi Payment Mode
```
Mode 1 (Hub redirect) — triggered when:
  - isHubNavigation() === true (navigated from hub.tecosystem.app)
  - !window.Pi (SDK not loaded)
  - !piReady

Mode 2 (direct Pi Browser) — triggered when:
  - Not a Hub navigation
  - Pi SDK initialized and ready

ADR-007 guard (REQUIRED in every payment handler):
  const isHubNavigation = () =>
    document.referrer.toLowerCase().includes('hub.tecosystem.app')

  if (isHubNavigation() || !window.Pi || !piReady) {
    redirectToHubPayment(...)  // Mode 1
    return
  }
  // Mode 2: proceed with Pi.createPayment()
```

### Authorization
```
[App-specific auth rules — e.g.:]
- [Resource] owner: always from tec_user cookie — never from request body
- [Resource] access: only authenticated users with [role]
```

---

## 5. Engineering Updates Required

### P0 — Blocking (must fix before Phase [N] ships)
```
□ [ID]: [Description] — [status: OPEN / IN PROGRESS / CLOSED]
```

### P1 — Critical (fix within current phase)
```
□ Tests ≥ 60% coverage — [current: ?%]
□ ADR-007 guard on all payment handlers — [status]
□ [Other P1 items]
```

### P2 — Important (next phase)
```
□ Analytics integration with tec-analytics-service
□ [Other P2 items]
```

---

## 6. Integration Map

### Upstream Dependencies
| Service / Package | What This App Needs |
|-------------------|---------------------|
| Hub (C-100) | SSO cookies (tec_access_token, tec_user) |
| tec-core-backend | [specific services] |
| @yasser172/tec-ui | Design system, TEC_COLORS |
| @yasser172/tec-auth | getStoredUser(), ssoRedirect() |
| @yasser172/tec-sdk | BFF proxy to gateway |

### Downstream (apps that depend on this app)
| App | What They Need From This App |
|-----|------------------------------|
| None | (end-user-facing app) |

### Cross-Charter Events
```
Emits:   [events this app sends, e.g., order.created.v1]
Listens: [events this app receives, e.g., payment.completed.v1]
```

---

## 7. Phase Gating

| Phase | Milestone | Gate |
|-------|-----------|------|
| Phase 0 | MVP launch | Tests ≥ 60%, ADR-007 compliant, no P0 violations |
| Phase 1 | After Mainnet | [specific deliverables] |
| Phase 2 | [future] | [specific deliverables] |

**Do NOT implement Phase [N+1] features until Phase [N] gate passes.**

---

## 8. Governing Principles

```
P6 Fail Closed:    missing session or invalid state → DENY
ADR-007:           isHubNavigation() before every Pi payment — NEVER remove
BFF-first:         all client data fetches via /api/bff/* only
Ownership:         [app entity] always resolved server-side, never client-sent
DECIMAL(20,8):     all Pi amounts in DB, string in API responses
```

---

*Charter Authority: Yasser (CEO/Founder) | GitHub: Yasira82*
*For platform authority hierarchy → C-67 Source of Truth Matrix*
*For platform constitution → C-00*
