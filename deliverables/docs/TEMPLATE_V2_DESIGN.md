# TEC Template v2 — Design Document

> **Version:** v1.0 (design) — June 2026
> **Authority:** Track C (Scale Preparation) — 90-day roadmap
> **Truth State:** `[Planned State]`
> **Governance State:** `[Draft]`
> **Scope:** Next-generation app template for TEC platform expansion (Life, Connection, Analytics, etc.)

---

## Purpose

`tec-template-base` v1 (Session 14.4) is Portal-ready but minimal — it encodes the payment/SSO/CSRF correctness from Session 14. Template v2 goes further: it encodes the **operational readiness** needed for the next 20 apps (observability, health checks, A/B testing hooks, feature flags, and the C-92 Platform Health Model integration).

**v1 = "won't break payments."**
**v2 = "won't break payments + production-ready on day one."**

---

## Design Principles

```
1. Correctness by inheritance — new apps inherit ADR-009 + ADR-007 + CSRF rules
2. Observability by default — every app ships with health endpoint + Sentry + structured logging
3. Feature flags from day one — no retroactive flag injection
4. Test coverage floor — 60% minimum on new app creation
5. CI parity — same 10 gates as the platform + app-specific payment-policy
6. Documentation embedded — CLAUDE.md + new-app checklist generated from template
7. One-command scaffold — `npx create-tec-app my-app` (future)
```

---

## Architecture (v2)

```
tec-template-base v2/
├── src/
│   ├── app/
│   │   ├── (auth)/
│   │   │   ├── login/page.tsx          ← Pi SDK login (usePiAuth)
│   │   │   ├── callback/page.tsx       ← SSO callback (open-redirect-safe)
│   │   │   └── refresh/route.ts        ← Token refresh endpoint
│   │   ├── (payment)/
│   │   │   ├── create/route.ts         ← ADR-009 contract (from tec-sdk)
│   │   │   ├── approve/route.ts        ← Pi callback
│   │   │   ├── complete/route.ts       ← Pi callback
│   │   │   └── resolve-incomplete/route.ts  ← Orphan recovery
│   │   ├── api/
│   │   │   ├── bff/
│   │   │   │   ├── health/route.ts     ← NEW v2: /api/bff/health (C-92)
│   │   │   │   ├── wallet/balance/route.ts
│   │   │   │   └── metrics/route.ts    ← NEW v2: app metrics
│   │   │   └── admin/
│   │   │       └── reconcile/route.ts  ← Payment reconciliation
│   │   ├── privacy/page.tsx            ← Legal requirement
│   │   ├── terms/page.tsx              ← Legal requirement
│   │   ├── layout.tsx                  ← Root layout with Pi SDK init
│   │   └── page.tsx                    ← Homepage
│   ├── components/
│   │   ├── PaymentModal.tsx            ← From @yasser172/tec-ui
│   │   ├── PiPaymentProvider.tsx       ← ADR-007 dual-mode context
│   │   └── HealthBadge.tsx             ← NEW v2: visual health indicator
│   ├── lib/
│   │   ├── pi/
│   │   │   ├── PiRuntime.ts            ← PAL abstraction (Pi Abstraction Layer)
│   │   │   └── PiCircuitBreaker.ts     ← CLOSED→OPEN→HALF_OPEN
│   │   ├── bff/
│   │   │   └── gateway.ts              ← ADR-009 gateway helper (token-refresh + x-internal-key)
│   │   └── observability/
│   │       ├── sentry.ts               ← NEW v2: Sentry config
│   │       ├── logger.ts               ← NEW v2: structured Pino logger
│   │       └── health.ts               ← NEW v2: C-92 health check
│   └── middleware.ts                   ← CSRF (double-submit OR Origin) — from @yasser172/tec-auth v1.1.0
├── tests/
│   ├── payment.test.ts                 ← ADR-009 contract tests
│   ├── csrf.test.ts                    ← Middleware tests
│   ├── sso.test.ts                     ← SSO flow tests
│   └── health.test.ts                  ← NEW v2: health endpoint tests
├── .github/
│   └── workflows/
│       ├── ci.yml                      ← Typecheck + test + build + coverage gate
│       ├── codeql.yml                  ← Security analysis
│       └── payment-policy.yml          ← ADR-009 + CSRF regression guard
├── docs/
│   ├── PAYMENT_SYSTEM.md               ← App-specific payment runbook
│   └── NEW_APP_CHECKLIST.md            ← Post-scaffold checklist
├── CLAUDE.md                           ← AI assistant navigation
├── .env.example                        ← All required env vars documented
├── next.config.ts
├── package.json                        ← @yasser172/tec-sdk + tec-auth + tec-ui
└── README.md
```

---

## New in v2 (vs v1)

### 1. Health Endpoint (`/api/bff/health`)

Per C-92 Platform Health Model — every app MUST expose a health endpoint:

```typescript
// src/app/api/bff/health/route.ts
import { NextResponse } from 'next/server';
import { checkPaymentHealth } from '@/lib/observability/health';

export async function GET() {
  const health = {
    app: process.env.NEXT_PUBLIC_APP_NAME,
    status: 'healthy' as 'healthy' | 'degraded' | 'unhealthy',
    timestamp: new Date().toISOString(),
    checks: {
      payment: await checkPaymentHealth(),
      sso: checkSSOHealth(),
      gateway: await checkGatewayHealth(),
    },
  };

  const status = health.status === 'healthy' ? 200 : 503;
  return NextResponse.json(health, { status });
}
```

**Why:** The C-92 Platform Health Model requires every app to report health. The Hub aggregates these into a composite PHS (Platform Health Score). Without this endpoint, the app is invisible to the health dashboard.

### 2. Structured Logging (Pino)

```typescript
// src/lib/observability/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  base: {
    app: process.env.NEXT_PUBLIC_APP_NAME,
    version: process.env.npm_package_version,
  },
  redact: ['req.headers.authorization', 'req.headers.cookie'],
});
```

**Why:** Structured logs are queryable. Sentry + Pino + Vercel logs = triad of observability. Unstructured `console.log` is not queryable.

### 3. Sentry Integration (pre-configured)

```typescript
// src/lib/observability/sentry.ts
import * as Sentry from '@sentry/nextjs';

export function initSentry() {
  if (process.env.NEXT_PUBLIC_SENTRY_DSN) {
    Sentry.init({
      dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
      environment: process.env.NODE_ENV,
      tracesSampleRate: 0.1,
      profilesSampleRate: 0.1,
      beforeSend(event) {
        // Filter out Pi Browser noise
        if (event.request?.url?.includes('pi-browser-internal')) return null;
        return event;
      },
    });
  }
}
```

**Why:** Every production app needs error tracking. Pre-configuring it in the template means no app ships without Sentry.

### 4. Pi Abstraction Layer (PAL) Stub

```typescript
// src/lib/pi/PiRuntime.ts
// PAL = Pi Abstraction Layer
// Insulates app from Pi SDK changes (R1 risk from C-77)

export class PiRuntime {
  private static instance: PiRuntime;
  private circuitBreaker: PiCircuitBreaker;

  static getInstance(): PiRuntime {
    if (!PiRuntime.instance) PiRuntime.instance = new PiRuntime();
    return PiRuntime.instance;
  }

  async init(appId: string): Promise<void> {
    // Never call window.Pi.* directly — always through PAL
    if (typeof window === 'undefined') return;
    const Pi = (window as any).Pi;
    if (!Pi) throw new Error('Pi SDK not loaded');

    Pi.init({ version: '2.0', sandbox: process.env.PI_SANDBOX === 'true' });
  }

  async createPayment(request: PaymentRequest): Promise<PaymentResult> {
    return this.circuitBreaker.execute(async () => {
      // ADR-009 contract enforcement
      if (typeof request.amount === 'string') {
        throw new Error('ADR-009 violation: amount must be number, not string');
      }
      // ... Pi.createPayment call
    });
  }
}
```

**Why:** C-77 identifies "Pi Network Black Box" as the #1 existential risk. PAL is the mitigation. v2 ships with a PAL stub so new apps never call `window.Pi.*` directly.

### 5. Feature Flag Hook

```typescript
// src/lib/hooks/useFeatureFlag.ts
import { useState, useEffect } from 'react';

export function useFeatureFlag(name: string, defaultValue = false): boolean {
  const [enabled, setEnabled] = useState(defaultValue);

  useEffect(() => {
    // Check env var: FEATURE_FLAG_<NAME>=true
    const envKey = `FEATURE_FLAG_${name.toUpperCase()}`;
    setEnabled(process.env[envKey] === 'true');
  }, [name]);

  return enabled;
}

// Usage: const showNewUI = useFeatureFlag('NEW_UI', false);
```

**Why:** Retroactive feature flag injection is painful. Shipping with the hook means feature flags are available from day one — no refactor needed when you want to A/B test.

### 6. Coverage Gate (60% minimum)

```yaml
# .github/workflows/ci.yml (excerpt)
- name: Coverage gate
  run: |
    npm test -- --coverage --coverageThreshold='{
      "global": {
        "lines": 60,
        "branches": 50,
        "functions": 60,
        "statements": 60
      }
    }'
```

**Why:** v1 has no coverage gate. New apps can ship with 0% tests. v2 enforces 60% from creation — matches the platform's C-42 Testing Strategy.

### 7. New-App Checklist (auto-generated)

```markdown
# New App Checklist — [APP_NAME]

## After scaffold
- [ ] Update package.json name
- [ ] Set env vars (see .env.example)
- [ ] Register Pi App ID in Pi Developer Portal
- [ ] Set PI_SANDBOX=false in production
- [ ] Configure Sentry DSN
- [ ] Add domain to Gateway CORS (C-13)
- [ ] Add app to C-01 Project Identity
- [ ] Create App Charter (C-100→C-115 template)
- [ ] Run smoke test (Mode 1 + Mode 2)
- [ ] Verify /api/bff/health returns 200
- [ ] Submit to Pi Developer Portal
```

**Why:** The checklist is generated during scaffold — developers don't have to remember what to configure.

---

## Migration Path (v1 → v2)

### For existing 4 apps (Hub, Ecommerce, Assets, Commerce)

**DO NOT migrate immediately.** Wait until Phase B2 is complete (P2/P3 items closed). Then:

```bash
# Per app:
1. Create a branch: git checkout -b refactor/template-v2
2. Diff against tec-template-base v2
3. Cherry-pick the new files (health endpoint, logger, sentry, PAL stub)
4. Test locally
5. Deploy to staging
6. Run smoke test
7. Deploy to production
8. Merge branch
```

### For new apps (Life, Connection, Analytics, etc.)

**Start from v2 directly:**

```bash
# Future (when CLI is built):
npx create-tec-app life --template v2

# Until then:
cp -r tec-template-base tec-life
cd tec-life
# Edit package.json, env vars, Pi App ID
# Follow NEW_APP_CHECKLIST.md
```

---

## Timeline

| Week | Milestone | Deliverable |
|------|-----------|-------------|
| W5 (Track C start) | Design review | This document approved |
| W6 | Template v2 scaffold | Base structure + health endpoint + logger |
| W7 | Template v2 payment/SSO | ADR-009 contract + ADR-007 dual-mode + CSRF from package |
| W8 | Template v2 observability | Sentry + Pino + health check + PAL stub |
| W9 | Template v2 CI | ci.yml + codeql.yml + payment-policy.yml + coverage gate |
| W10 | Template v2 docs | CLAUDE.md + NEW_APP_CHECKLIST + PAYMENT_SYSTEM.md |
| W11 | Template v2 testing | Unit tests + integration tests + smoke test script |
| W12 | Template v2 review | Code review + security review |
| W13 | Template v2 release | Published as tec-template-base v2.0.0 |

---

## Success Metrics

| Metric | v1 baseline | v2 target |
|--------|-------------|-----------|
| Time to scaffold new app | ~4 hours (manual) | ~30 minutes (template + checklist) |
| Health endpoint | Not included | Included by default |
| Structured logging | Not included | Pino pre-configured |
| Sentry | Manual setup | Pre-configured |
| PAL stub | Not included | Included (R1 mitigation) |
| Coverage gate | None | 60% minimum |
| Feature flags | Not available | useFeatureFlag hook |
| New-app checklist | External doc | Auto-generated |

---

## Open Questions

1. **Should v2 include a CLI (`create-tec-app`)?** Nice to have but not urgent — can defer to Q4 2026.
2. **Should v2 include i18n?** Pi Network is global, but i18n adds complexity. Defer to v3.
3. **Should v2 include a design system storybook?** tec-ui already has one — link to it, don't duplicate.
4. **Should v2 include e2e tests (Playwright)?** Yes — add in W11 alongside unit tests.

---

## Related Documents

```
tec-template-base (v1)                   — Current Portal-ready template
knowledge-base/C-12_Dual_Mode_Payment.md — ADR-009 contract
knowledge-base/C-76___ADR-007.md         — Pi Payment Ownership
knowledge-base/C-92___PLATFORM_HEALTH_MODEL.md — Health model
knowledge-base/C-77___STRATEGIC_ANALYSIS___RISK_ASSESSMENT.md — R1 Pi risk
knowledge-base/C-42_Testing_Strategy.md  — Coverage targets
knowledge-base/C-43_CI_CD_DevOps.md      — CI rules
```
