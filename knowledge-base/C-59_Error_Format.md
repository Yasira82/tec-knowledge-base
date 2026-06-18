# C-59 — UNIFIED ERROR RESPONSE FORMAT
## Enterprise Standard — كل الـ Services + BFF Routes

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---


---

## 1. THE STANDARD FORMAT

```typescript
// ✅ كل error في كل مكان في الـ ecosystem لازم يتبع الـ format ده

interface TecErrorResponse {
  success:   false;
  error: {
    code:       string;    // machine-readable — دايماً SCREAMING_SNAKE
    message:    string;    // human-readable — English
    field?:     string;    // validation errors فقط
    requestId?: string;    // x-request-id للـ debugging
    details?:   unknown;   // extra context (non-production only)
  };
}

// ✅ Success format (للـ consistency)
interface TecSuccessResponse<T = unknown> {
  success: true;
  data:    T;
  meta?: {
    page?:  number;
    limit?: number;
    total?: number;
  };
}
```

---

## 2. ERROR CODES — Standard Dictionary

### Auth Errors (401/403)
```
UNAUTHORIZED          → no token / invalid token
TOKEN_EXPIRED         → token expired — refresh needed
FORBIDDEN             → valid token, no permission
CSRF_INVALID          → CSRF token mismatch
SSO_TOKEN_INVALID     → SSO JWT invalid/expired
SSO_TOKEN_REPLAYED    → JTI already used
```

### Validation Errors (400/422)
```
VALIDATION_ERROR      → general validation failure (+ field)
MISSING_FIELD         → required field absent (+ field)
INVALID_FORMAT        → wrong format (+ field)
INVALID_AMOUNT        → Pi amount invalid (negative, too many decimals)
```

### Payment Errors (400/409/422)
```
PAYMENT_NOT_FOUND     → payment ID doesn't exist
PAYMENT_INVALID_STATE → wrong state for this transition
PAYMENT_DUPLICATE     → idempotency key already used
PAYMENT_PI_FAILED     → Pi Network API error
PAYMENT_TIMEOUT       → payment exceeded 90s
SANDBOX_MODE_ACTIVE   → PI_SANDBOX=true in production
```

### Wallet Errors (400/409)
```
WALLET_INSUFFICIENT   → balance < amount
WALLET_NOT_FOUND      → wallet doesn't exist for user
WALLET_LOCKED         → concurrent operation in progress
```

### Rate Limit (429)
```
RATE_LIMIT_EXCEEDED   → too many requests
```

### Server Errors (500/503)
```
INTERNAL_ERROR        → unexpected server error
SERVICE_UNAVAILABLE   → downstream service down
CIRCUIT_OPEN          → circuit breaker open (Pi API)
GATEWAY_TIMEOUT       → upstream timeout (25s exceeded)
DATABASE_ERROR        → Prisma/PostgreSQL error
REDIS_ERROR           → Redis connection error
```

---

## 3. BACKEND IMPLEMENTATION (NestJS)

```typescript
// shared/src/errors/tec-error.ts

export class TecError extends Error {
  constructor(
    public readonly code:    string,
    public readonly message: string,
    public readonly status:  number = 500,
    public readonly field?:  string,
  ) {
    super(message);
    this.name = 'TecError';
  }

  toResponse(requestId?: string): TecErrorResponse {
    return {
      success: false,
      error: {
        code:      this.code,
        message:   this.message,
        ...(this.field     && { field:     this.field }),
        ...(requestId      && { requestId: requestId }),
      },
    };
  }

  static unauthorized(msg = 'Unauthorized') {
    return new TecError('UNAUTHORIZED', msg, 401);
  }
  static forbidden(msg = 'Forbidden') {
    return new TecError('FORBIDDEN', msg, 403);
  }
  static notFound(resource: string) {
    return new TecError(`${resource.toUpperCase()}_NOT_FOUND`, `${resource} not found`, 404);
  }
  static validation(msg: string, field?: string) {
    return new TecError('VALIDATION_ERROR', msg, 422, field);
  }
  static paymentInvalidState(from: string, to: string) {
    return new TecError(
      'PAYMENT_INVALID_STATE',
      `Cannot transition payment from ${from} to ${to}`,
      409,
    );
  }
}
```

```typescript
// Global Exception Filter (tec-api-gateway)
// tec-api-gateway/src/filters/global-exception.filter.ts

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx     = host.switchToHttp();
    const res     = ctx.getResponse<Response>();
    const req     = ctx.getRequest<Request>();
    const reqId   = (req as any).id ?? req.headers['x-request-id'];

    // TecError — structured error
    if (exception instanceof TecError) {
      return res.status(exception.status).json(
        exception.toResponse(reqId)
      );
    }

    // NestJS HttpException
    if (exception instanceof HttpException) {
      const status  = exception.getStatus();
      const exRes   = exception.getResponse();
      const message = typeof exRes === 'string'
        ? exRes
        : (exRes as any)?.message ?? 'Request error';

      return res.status(status).json({
        success: false,
        error: {
          code:      `HTTP_${status}`,
          message:   Array.isArray(message) ? message[0] : message,
          requestId: reqId,
        },
      });
    }

    // Unknown error
    logger.error({ err: exception, reqId }, 'Unhandled exception');
    return res.status(500).json({
      success: false,
      error: {
        code:      'INTERNAL_ERROR',
        message:   'An unexpected error occurred',
        requestId: reqId,
      },
    });
  }
}
```

---

## 4. FRONTEND BFF IMPLEMENTATION

```typescript
// src/lib/bff-response.ts — في كل app

export interface TecApiError {
  code:       string;
  message:    string;
  field?:     string;
  requestId?: string;
}

export interface TecApiResponse<T = unknown> {
  success: boolean;
  data?:   T;
  error?:  TecApiError;
}

// ✅ Unified BFF error handler
export const bffError = (
  message: string,
  status:  number,
  code:    string,
  field?:  string,
): NextResponse => NextResponse.json(
  {
    success: false,
    error:   { code, message, ...(field && { field }) },
  },
  { status },
);

// ✅ Unified BFF success
export const bffSuccess = <T>(data: T, status = 200): NextResponse =>
  NextResponse.json({ success: true, data }, { status });

// ✅ Usage in BFF routes
export async function POST(req: NextRequest) {
  const token = req.cookies.get('tec_access_token')?.value;
  if (!token) return bffError('Unauthorized', 401, 'UNAUTHORIZED');

  const userId = getUserId(req);
  if (!userId) return bffError('Unauthorized', 401, 'UNAUTHORIZED');

  try {
    const res  = await fetch(`${GW}/api/payment/create`, { ... });
    const data = await res.json();

    if (!res.ok) {
      return NextResponse.json(
        { success: false, error: data.error ?? { code: 'UPSTREAM_ERROR', message: data.error } },
        { status: res.status },
      );
    }

    return bffSuccess(data);
  } catch {
    return bffError('Service unavailable', 503, 'SERVICE_UNAVAILABLE');
  }
}
```

---

## 5. CLIENT-SIDE ERROR HANDLING

```typescript
// ✅ Standard client error handler
const handleApiError = (error: TecApiError) => {
  switch (error.code) {
    case 'UNAUTHORIZED':
    case 'TOKEN_EXPIRED':
      refreshAccessToken().then(() => location.reload());
      break;
    case 'PAYMENT_INVALID_STATE':
      toast.error('Payment already processed');
      break;
    case 'WALLET_INSUFFICIENT':
      toast.error('Insufficient Pi balance');
      break;
    case 'RATE_LIMIT_EXCEEDED':
      toast.error('Too many requests. Please wait.');
      break;
    default:
      toast.error(error.message ?? 'Something went wrong');
  }
};

// ✅ Fetch wrapper with error parsing
const apiFetch = async <T>(url: string, init?: RequestInit): Promise<T> => {
  const res  = await fetch(url, { credentials: 'include', ...init });
  const data = await res.json() as TecApiResponse<T>;

  if (!data.success || !res.ok) {
    throw data.error ?? { code: 'UNKNOWN_ERROR', message: 'Request failed' };
  }

  return data.data as T;
};
```

---

## 6. MIGRATION CHECKLIST

```
Backend (كل service):
  □ Add TecError class (shared/)
  □ Add GlobalExceptionFilter
  □ Replace all res.json({ error: '...' }) → TecError

Frontend (كل BFF route):
  □ Import bffError + bffSuccess helpers
  □ Replace NextResponse.json({ error: '...' }) → bffError()
  □ Add error code constants

Client:
  □ Add handleApiError utility
  □ Add apiFetch wrapper
  □ Remove manual error string parsing
```
