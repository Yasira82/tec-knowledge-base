---
name: bff-patterns
description: "When writing or modifying any BFF route (/api/bff/*) in any TEC app — enforce BFF-first rule, createHandler pattern, auth cookie reading, CSRF protection, and proper gateway proxying."
metadata:
  version: 1.0.0
  tier: HIGH
  domain: engineering
---

# TEC BFF Route Patterns

All client data fetching goes through /api/bff/* — no exceptions (BFF-first rule, learned from NEW-L production bug).

## BFF Route Template

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

// Gateway URL — always include NEXT_PUBLIC fallback
const GW = process.env.API_GATEWAY_URL
        ?? process.env.NEXT_PUBLIC_API_GATEWAY_URL ?? '';

// Input validation schema
const RequestSchema = z.object({
  // ... define fields
});

export async function POST(req: NextRequest) {
  if (!GW) return NextResponse.json({ error: 'Service unavailable' }, { status: 503 });

  // CSRF — only reject when cookie present but mismatched
  const csrfCookie = req.cookies.get('tec_csrf')?.value ?? '';
  const csrfHeader = req.headers.get('x-csrf-token') ?? '';
  if (csrfCookie && csrfCookie !== csrfHeader) {
    return NextResponse.json({ error: 'CSRF validation failed' }, { status: 403 });
  }

  // Auth — read from cookie (NEVER Authorization header only)
  const token = req.cookies.get('tec_access_token')?.value;
  if (!token) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  // Validate input
  const raw = await req.json().catch(() => ({}));
  const parsed = RequestSchema.safeParse(raw);
  if (!parsed.success) {
    return NextResponse.json(
      { error: 'VALIDATION_ERROR', details: parsed.error.flatten() },
      { status: 400 }
    );
  }

  // Build gateway headers
  const gwHeaders: Record<string, string> = {
    'Content-Type':    'application/json',
    Authorization:     `Bearer ${token}`,
    'Idempotency-Key': crypto.randomUUID(),
  };
  // Only send x-internal-key if SET — empty string causes gateway 401
  if (process.env.INTERNAL_SECRET) {
    gwHeaders['x-internal-key'] = process.env.INTERNAL_SECRET;
  }

  try {
    const res = await fetch(`${GW}/api/YOUR_ENDPOINT`, {
      method:  'POST',
      headers: gwHeaders,
      body:    JSON.stringify(parsed.data),
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) {
      console.error('[bff/YOUR_ROUTE] gateway error:', res.status, data);
    }
    return NextResponse.json(data, { status: res.status });
  } catch (err) {
    console.error('[bff/YOUR_ROUTE] network error:', (err as Error).message);
    return NextResponse.json({ error: 'Service unavailable' }, { status: 503 });
  }
}
```

## BFF Route Naming Convention

```
/api/bff/wallet/balance     ← data fetch (cookie auth + token refresh) ✅ USE
/api/bff/payment/approve    ← Pi callback handler
/api/bff/payment/complete   ← Pi callback handler
/api/bff/payment/create     ← Backend-first payment creation (C-76)
/api/bff/payments/history   ← payment history list
/api/bff/orders             ← order creation
/api/wallet/balance         ← ⚠️ LEGACY — Authorization header only, no refresh
```

## BFF-First Rule (NEW-L lesson)

```
SYMPTOM: Page shows 0 balance even though Hub card shows correct balance.
CAUSE:   Client hook uses /api/wallet/balance — Authorization header only.
         On token expiry → silently returns {balance:0, walletId:null}.
FIX:     Switch to /api/bff/wallet/balance (createHandler + auto token refresh).

RULE: ALL client data fetching → /api/bff/* routes ONLY.
NEVER call /api/wallet/*, /api/payments/*, /api/notifications/* from client.
```

## getUserId Pattern

```typescript
// Hub SSO cookie may use id, sub, or piId — check all
const getUserId = (req: NextRequest): string => {
  try {
    const raw = req.cookies.get('tec_user')?.value ?? '';
    const u   = JSON.parse(decodeURIComponent(raw));
    return u?.id ?? u?.sub ?? u?.piId ?? '';
  } catch { return ''; }
};
```

## Two-SDK Boundary (NEVER cross)

```
Client Components  → packages/tec-core-sdk   (usePiAuth, useTecWallet)
API Routes (BFF)   → @yasser172/tec-sdk      (TecSdk.payment.*, TecSdk.auth.*)

FORBIDDEN:
  → tec-sdk npm imported in Client Components
  → window.Pi called directly in API Routes
  → axios / Pi SDK directly in API Routes
```
