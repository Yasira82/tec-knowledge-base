---
name: tec-testing
description: "When writing tests for any TEC app — enforce TDD patterns, payment test setup (C-76 backend-first), coverage targets, and proper mock patterns for Pi SDK and gateway."
metadata:
  version: 1.0.0
  tier: HIGH
  domain: engineering
---

# TEC Testing Patterns

## Coverage Targets (Phase 0 gates)

| Repo | Target | Critical Files |
|------|--------|----------------|
| tec-auth (service) | ≥ 95% stmt, ≥ 92% branch | All auth flows |
| tec-auth (npm package) | ≥ 80% | getStoredUser, ssoRedirect, usePiAuth |
| tec-ecommerce | ≥ 60% | pi-payment.ts, BFF routes, useCart |
| tec-commerce | ≥ 60% | merchant auth, payment handler, order BFF |
| tec-assets | ≥ 60% | payment handler, asset BFF |

## Payment Test Setup (C-76 Backend-First — CRITICAL)

```typescript
// ⚠️ ALWAYS mock /api/.../payment/create FIRST
// Without this, test gets 422 and throws before Pi.createPayment

const mockCreateSuccess = () =>
  vi.spyOn(globalThis, 'fetch').mockImplementation(async (url) => {
    const u = String(url);
    if (u.includes('payment/create'))
      return { ok: true, status: 200,
               json: async () => ({ data: { id: 'internal-id' } }) } as Response;
    if (u.includes('payment/approve'))
      return { ok: true, status: 200, json: async () => ({}) } as Response;
    if (u.includes('payment/complete'))
      return { ok: true, status: 200,
               json: async () => ({ success: true, status: 'completed', txid: 'tx-1' }) } as Response;
    return { ok: false, status: 404, json: async () => ({}) } as Response;
  });
```

## createU2APayment — Always Resolves (Never Rejects)

```typescript
// createU2APayment RESOLVES with PaymentResult — NEVER rejects
// Commerce-aligned pattern (all TEC apps)

// ✅ CORRECT:
const result = await createU2APayment(...);
expect(result.status).toBe('error');
expect(result.message).toBe('Pi SDK not ready');

// ❌ WRONG (old pattern — causes CI failure):
await expect(createU2APayment(...)).rejects.toThrow('...');
```

## Pi Window Setup

```typescript
const setupPiWindow = (mockCreatePayment = vi.fn()) => {
  (window as any).__TEC_PI_READY = true;
  (window as any).Pi = {
    authenticate:  vi.fn().mockResolvedValue({}),
    createPayment: mockCreatePayment,
  };
  return mockCreatePayment;
};

afterEach(() => {
  delete (window as any).__TEC_PI_READY;
  delete (window as any).Pi;
});
```

## getStoredUser Test Coverage (tec-auth package)

```typescript
// Must cover all edge cases:
it('returns null when tec_user cookie missing', ...)
it('returns null when tec_user JSON is malformed', ...)
it('returns user when cookie is valid JSON', ...)
it('returns null when required fields missing', ...)
it('handles URL-encoded cookie value', ...)
```

## BFF Route Test Pattern

```typescript
// Test auth, CSRF, validation, gateway error, success
describe('POST /api/bff/payment/create', () => {
  it('returns 401 when no tec_access_token cookie', ...)
  it('returns 403 when CSRF cookie present but header mismatches', ...)
  it('returns 400 when amount is not positive', ...)
  it('returns 401 when tec_user cookie missing userId', ...)
  it('returns 503 when gateway unreachable', ...)
  it('returns gateway response on success', ...)
});
```

## Commerce Merchant Auth Tests

```typescript
// ALWAYS test that merchantId never comes from request body
it('rejects when body.merchantId used instead of session', ...)
it('derives merchant from tec_user cookie', ...)
it('returns 401 when tec_user cookie missing', ...)
```

## Vitest Config Pattern

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    environment: 'jsdom',      // required for document.cookie
    globals:     true,
    coverage: {
      provider:   'v8',
      reporter:   ['text', 'json', 'html'],
      thresholds: { statements: 60, branches: 60 },
    },
  },
});
```
