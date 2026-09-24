# C-60 — CODE TEMPLATES
## Copy-Paste Patterns — every template ready to paste

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---


---

## ⚠️ How to use

```
1. اختار الـ template المناسب
2. غيّر الـ [PLACEHOLDERS] بالقيم الصح
3. Commerce = Reference — لو مش متأكد راجعه
```

---

## TEMPLATE 1 — BFF Route (Next.js)

```typescript
// src/app/api/bff/[resource]/route.ts
// Repo: [App] (Yasira82)

import { NextRequest, NextResponse } from 'next/server';
import { generateRequestId }         from '@yasser172/tec-ui';

// ✅ server-only — مش NEXT_PUBLIC_
const GW = process.env.API_GATEWAY_URL
        ?? process.env.NEXT_PUBLIC_API_GATEWAY_URL
        ?? 'https://api-gateway-production-6a68.up.railway.app';

// ✅ userId من cookie — مش من body
const getUserId = (req: NextRequest): string | null => {
  try {
    const raw = req.cookies.get('tec_user')?.value ?? '';
    const u   = JSON.parse(decodeURIComponent(raw));
    return u?.id ?? u?.sub ?? null;
  } catch { return null; }
};

const getToken = (req: NextRequest): string | null =>
  req.cookies.get('tec_access_token')?.value ?? null;

const getCsrf = (req: NextRequest): string =>
  req.cookies.get('tec_csrf')?.value ?? '';

export async function GET(req: NextRequest) {
  const token = getToken(req);
  if (!token) return NextResponse.json(
    { success: false, error: { code: 'UNAUTHORIZED', message: 'Unauthorized' } },
    { status: 401 }
  );

  const res  = await fetch(`${GW}/api/[service]/[endpoint]`, {
    headers: { Authorization: `Bearer ${token}` },
    cache:   'no-store',
  }).catch(() => null);

  if (!res) return NextResponse.json(
    { success: false, error: { code: 'SERVICE_UNAVAILABLE', message: 'Service unavailable' } },
    { status: 503 }
  );

  const data = await res.json().catch(() => ({}));
  return NextResponse.json(data, { status: res.status });
}

export async function POST(req: NextRequest) {
  const token  = getToken(req);
  const userId = getUserId(req);
  if (!token || !userId) return NextResponse.json(
    { success: false, error: { code: 'UNAUTHORIZED', message: 'Unauthorized' } },
    { status: 401 }
  );

  // ✅ CSRF على mutations
  const csrfCookie = getCsrf(req);
  const csrfHeader = req.headers.get('x-csrf-token') ?? '';
  if (!csrfCookie || csrfCookie !== csrfHeader) return NextResponse.json(
    { success: false, error: { code: 'CSRF_INVALID', message: 'CSRF validation failed' } },
    { status: 403 }
  );

  const body = await req.json().catch(() => ({}));

  const res = await fetch(`${GW}/api/[service]/[endpoint]`, {
    method:  'POST',
    headers: {
      'Content-Type':  'application/json',
      Authorization:   `Bearer ${token}`,
      'X-Request-Id':  generateRequestId(),
    },
    body: JSON.stringify({ ...body, userId }), // userId من JWT مش من body
  }).catch(() => null);

  if (!res) return NextResponse.json(
    { success: false, error: { code: 'SERVICE_UNAVAILABLE', message: 'Service unavailable' } },
    { status: 503 }
  );

  const data = await res.json().catch(() => ({}));
  return NextResponse.json(data, { status: res.status });
}
```

---

## TEMPLATE 2 — BFF Payment Route (Create)

```typescript
// src/app/api/bff/payment/create/route.ts
// نفس هذا الـ template في كل app — غيّر APP_SOURCE فقط

import { NextRequest, NextResponse } from 'next/server';

const GW         = process.env.API_GATEWAY_URL
               ?? process.env.NEXT_PUBLIC_API_GATEWAY_URL!;
const APP_SOURCE = process.env.NEXT_PUBLIC_APP_SOURCE ?? '[appname]';

const getUserId = (req: NextRequest): string | null => {
  try {
    const raw = req.cookies.get('tec_user')?.value ?? '';
    const u   = JSON.parse(decodeURIComponent(raw));
    return u?.id ?? u?.sub ?? null;
  } catch { return null; }
};

export async function POST(req: NextRequest) {
  const token  = req.cookies.get('tec_access_token')?.value;
  const userId = getUserId(req);
  if (!token || !userId) return NextResponse.json(
    { success: false, error: { code: 'UNAUTHORIZED', message: 'Unauthorized' } },
    { status: 401 }
  );

  const body = await req.json().catch(() => ({})) as {
    amount:     number;
    product_id: string;
    memo:       string;
  };

  const res = await fetch(`${GW}/api/payment/create`, {
    method:  'POST',
    headers: {
      'Content-Type':    'application/json',
      Authorization:     `Bearer ${token}`,
      'Idempotency-Key': crypto.randomUUID(), // ✅ required
    },
    body: JSON.stringify({
      userId,           // ✅ من JWT — مش من body
      amount:   body.amount,
      currency: 'PI',
      payment_method: 'pi',
      metadata: { product_id: body.product_id, source: APP_SOURCE },
      memo:     body.memo,
    }),
  }).catch(() => null);

  if (!res) return NextResponse.json(
    { success: false, error: { code: 'SERVICE_UNAVAILABLE', message: 'Service unavailable' } },
    { status: 503 }
  );

  const data = await res.json().catch(() => ({}));
  return NextResponse.json(data, { status: res.status });
}
```

---

## TEMPLATE 3 — NestJS Controller Endpoint

```typescript
// tec-[service]-service/src/modules/[domain]/[domain].controller.ts
// Repo: Tec-core-backend (Yasira82)

import {
  Controller, Get, Post, Body, Param,
  UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common';
import { AuthGuard }      from '../../guards/auth.guard';
import { InternalGuard }  from '../../guards/internal.guard';
import { [Domain]Service } from './[domain].service';
import { Create[Domain]Dto } from './dto/create-[domain].dto';
import { GetUser }        from '../../decorators/get-user.decorator';

@Controller('[domain]')
export class [Domain]Controller {
  constructor(private readonly [domain]Service: [Domain]Service) {}

  // ✅ Internal endpoint (x-internal-key)
  @Get(':id')
  @UseGuards(InternalGuard)
  @HttpCode(HttpStatus.OK)
  async findOne(@Param('id') id: string) {
    const result = await this.[domain]Service.findOne(id);
    return { success: true, data: result };
  }

  // ✅ User endpoint (JWT required)
  @Post()
  @UseGuards(AuthGuard)
  @HttpCode(HttpStatus.CREATED)
  async create(
    @GetUser('id') userId: string,   // ✅ من JWT decorator — مش من body
    @Body() dto: Create[Domain]Dto,
  ) {
    const result = await this.[domain]Service.create(userId, dto);
    return { success: true, data: result };
  }
}
```

---

## TEMPLATE 4 — Redis Event Consumer (new service)

```typescript
// tec-[service]-service/src/consumers/[domain].consumer.ts
// Repo: Tec-core-backend (Yasira82)

import { Redis }             from 'ioredis';
import { logger }            from '../utils/logger';
import {
  subscribeStream,
  ensureConsumerGroup,
  EVENTS,
}                            from '@yasser172/tec-shared';

const SERVICE_NAME  = '[service]-service';
const CONSUMER_NAME = '[service]-consumer-1';

export const start[Domain]Consumer = async (client: Redis): Promise<void> => {
  // ✅ Ensure consumer group exists
  await ensureConsumerGroup(client, EVENTS.PAYMENT_COMPLETED, SERVICE_NAME);

  logger.info('[Consumer] Starting payment.completed consumer...');

  await subscribeStream(
    client,
    EVENTS.PAYMENT_COMPLETED,  // 'payment.completed'
    SERVICE_NAME,
    CONSUMER_NAME,
    async (payload) => {
      const { payment_id, user_id, amount, source } = payload as {
        payment_id: string;
        user_id:    string;
        amount:     string;
        source:     string;
      };

      logger.info({ payment_id, user_id }, '[Consumer] Processing payment.completed');

      try {
        await handle[Domain]PaymentCompleted({ payment_id, user_id, amount, source });
        logger.info({ payment_id }, '[Consumer] Processed successfully');
      } catch (err) {
        logger.error({ err, payment_id }, '[Consumer] Processing failed');
        throw err;
      }
    },
    { batchSize: 10, blockMs: 5000, retryDelay: 1000 },
  );
};
```

---

## TEMPLATE 5 — Vitest Test (Frontend)

```typescript
// src/app/[route]/__tests__/[page].test.ts

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import * as React from 'react';

const mockPi = {
  init:          vi.fn(),
  authenticate:  vi.fn().mockResolvedValue({ accessToken: 'mock_token', user: { uid: 'u1', username: 'test' } }),
  createPayment: vi.fn(),
};

const mockFetch = vi.fn();

beforeEach(() => {
  vi.stubGlobal('window', {
    Pi:                          mockPi,
    __TEC_PI_READY:              true,
    __TEC_PI_FOREIGN_SESSION:    false,
    location:                    { href: '', assign: vi.fn() },
    dispatchEvent:               vi.fn(),
    addEventListener:            vi.fn(),
    removeEventListener:         vi.fn(),
    document: {
      cookie: 'tec_access_token=mock_token; tec_csrf=mock_csrf; tec_user=%7B%22id%22%3A%22user1%22%7D',
    },
  });
  vi.stubGlobal('fetch', mockFetch);
  vi.stubGlobal('crypto', { randomUUID: () => 'mock-uuid' });
});

afterEach(() => {
  vi.unstubAllGlobals();
  vi.clearAllMocks();
});

describe('[Component/Page] Tests', () => {
  it('should [description]', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({ success: true, data: { id: 'payment-1' } }),
    });
    // Act + Assert
    expect(mockFetch).toHaveBeenCalledWith(
      '/api/bff/payment/create',
      expect.objectContaining({ method: 'POST' }),
    );
  });
});
```

---

## TEMPLATE 6 — Jest Test (Backend NestJS)

```typescript
// tec-[service]-service/src/modules/[domain]/[domain].service.spec.ts

import { Test, TestingModule } from '@nestjs/testing';
import { [Domain]Service }    from './[domain].service';
import { PrismaService }      from '../../prisma/prisma.service';

describe('[Domain]Service', () => {
  let service: [Domain]Service;

  const mockPrisma = {
    [domain]: {
      findUnique: vi.fn(),
      create:     vi.fn(),
      update:     vi.fn(),
    },
    $transaction: vi.fn().mockImplementation(cb => cb(mockPrisma)),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        [Domain]Service,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<[Domain]Service>([Domain]Service);
  });

  afterEach(() => vi.clearAllMocks());

  describe('create()', () => {
    it('should create successfully', async () => {
      mockPrisma.[domain].create.mockResolvedValue({ id: 'id-1' });
      const result = await service.create('user-1', {});
      expect(result).toMatchObject({ id: 'id-1' });
    });
  });
});
```

---

## TEMPLATE 7 — layout.tsx (New App Pi.init)

```typescript
// src/app/layout.tsx — كل app جديدة

import type { Metadata } from 'next';
import Script            from 'next/script';

export const metadata: Metadata = {
  title:       process.env.NEXT_PUBLIC_APP_NAME ?? 'TEC App',
  description: 'TEC Ecosystem — Pi Network',
};

const piInitScript = `(function(){
  var tries=0,appId="${process.env.NEXT_PUBLIC_PI_APP_ID ?? ''}";
  function ready(){
    window.__TEC_PI_READY=true;
    window.dispatchEvent(new Event('tec-pi-ready'));
  }
  function init(){
    if(tries++>=40){window.__TEC_PI_ERROR=true;return;}
    if(!window.Pi){setTimeout(init,150);return;}
    try{
      window.Pi.init({version:'2.0',sandbox:false});
      ready();
    }catch(e){
      var m=String(e).toLowerCase();
      if(m.includes('already')||m.includes('initialized')){
        window.__TEC_PI_FOREIGN_SESSION=true;ready();
      }else{setTimeout(init,150);}
    }
  }
  init();
})();`;

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Script src="https://sdk.minepi.com/pi-sdk.js" strategy="beforeInteractive" />
        <Script id="pi-init" strategy="afterInteractive"
          dangerouslySetInnerHTML={{ __html: piInitScript }} />
        {children}
      </body>
    </html>
  );
}
```

---

## TEMPLATE 8 — middleware.ts (New App)

```typescript
// middleware.ts (root)

import { createAuthMiddleware } from '@yasser172/tec-auth/middleware';

export default createAuthMiddleware({
  protectedRoutes: ['/app', '/[route2]'],
  csrfExcluded:    ['/api/bff/payment/'],
  loginRedirectUrl: '/',
});

export const config = {
  matcher: [
    '/app/:path*',
    '/api/bff/:path*',
    '/((?!_next/static|_next/image|favicon.ico|api/health).*)',
  ],
};
```
