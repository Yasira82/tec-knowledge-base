# C-81 — P1 Runtime Fixes — Implementation Guide

> **Truth State:** `[Planned State]` → `[Current State]` after application
> **Governance State:** `[ADR Approved]` — ADR-008
> **Verification:** `[Documentation Verified]` → `[Code Verified]` after application
> **Authority:** C-96 Platform Runtime & Observability Constitution

**Violations:** NEW-K · NEW-N · NEW-O · NEW-L
**Repos affected:** `Yasira82/Tec-App` · `Yasira82/Tec-core-backend`

---

## Application Order

```
1. NEW-L  (Gateway timeout) — smallest change, highest safety
2. NEW-N  (Redis diagnostics) — 5 lines, zero risk
3. NEW-O  (Health details endpoint) — additive, no breaking changes
4. NEW-K  (PlatformHealthContext) — refactor, most lines
```

---

# FIX 1 — NEW-L: Gateway Timeout Alignment

**Repo:** `Tec-core-backend`
**File:** `tec-api-gateway/src/modules/proxy/proxy.service.ts`

**Before:**

```typescript
timeout: 30000,
proxyTimeout: 30000,
```

**After:**

```typescript
timeout: 10000,
proxyTimeout: 10000,
```

**Rationale:** Frontend cancels at 5,000ms. 30,000ms gap causes Railway to log 499 (client
cancellation) instead of actionable 500/502/503. Aligned stack: Frontend 5s → Gateway 10s →
Upstream 8s.

---

# FIX 2 — NEW-N: Redis Observable Lifecycle

**Repo:** `Tec-core-backend`
**File:** Where Redis client is initialized (e.g. `tec-api-gateway/src/modules/redis/redis.service.ts`
or `tec-api-gateway/src/app.module.ts`)

**Before:**

```typescript
client.on('error', () => {});
```

**After:**

```typescript
client.on('connect',      () => logger.info('Redis connecting...'));
client.on('ready',        () => logger.info('Redis ready'));
client.on('error',        (err: Error) => logger.error({ err }, 'Redis error'));
client.on('reconnecting', () => logger.warn('Redis reconnecting'));
client.on('end',          () => logger.warn('Redis connection ended'));
```

**If using NestJS with ioredis through a provider, the full pattern:**

```typescript
// redis.service.ts
import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import Redis from 'ioredis';

@Injectable()
export class RedisService implements OnModuleInit {
  private readonly logger = new Logger(RedisService.name);
  private client: Redis;

  onModuleInit() {
    this.client = new Redis({
      host: process.env.REDIS_HOST,
      port: parseInt(process.env.REDIS_PORT ?? '6379'),
      password: process.env.REDIS_PASSWORD,
      retryStrategy: (times) => Math.min(times * 100, 3000),
    });

    this.client.on('connect',      () => this.logger.log('Redis connecting'));
    this.client.on('ready',        () => this.logger.log('Redis ready'));
    this.client.on('error',        (err) => this.logger.error('Redis error', err.message));
    this.client.on('reconnecting', () => this.logger.warn('Redis reconnecting'));
    this.client.on('end',          () => this.logger.warn('Redis connection ended'));
  }

  getClient(): Redis {
    return this.client;
  }

  async ping(): Promise<boolean> {
    try {
      const result = await this.client.ping();
      return result === 'PONG';
    } catch {
      return false;
    }
  }
}
```

---

# FIX 3 — NEW-O: Health Details Endpoint

**Repo:** `Tec-core-backend`
**Files to create/update:**
- `tec-api-gateway/src/modules/health/health.controller.ts` (update)
- `tec-api-gateway/src/modules/health/health.service.ts` (update)

### health.controller.ts

```typescript
import { Controller, Get, Headers, UnauthorizedException } from '@nestjs/common';
import { HealthService } from './health.service';
import { timingSafeEqual, createHash } from 'crypto';

@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  check() {
    return { status: 'ok' };
  }

  @Get('details')
  async details(@Headers('x-internal-key') key: string) {
    const secret = process.env.INTERNAL_SECRET ?? '';
    const provided = key ?? '';

    const secretBuf = createHash('sha256').update(secret).digest();
    const providedBuf = createHash('sha256').update(provided).digest();

    if (
      secretBuf.length !== providedBuf.length ||
      !timingSafeEqual(secretBuf, providedBuf)
    ) {
      throw new UnauthorizedException('Invalid internal key');
    }

    return this.healthService.getDetails();
  }
}
```

### health.service.ts

```typescript
import { Injectable, Logger } from '@nestjs/common';
import { RedisService } from '../redis/redis.service';

interface ServiceHealth {
  reachable: boolean;
  latency: number | null;
  lastChecked: string;
}

@Injectable()
export class HealthService {
  private readonly logger = new Logger(HealthService.name);

  private readonly services: Record<string, string> = {
    auth:         process.env.AUTH_SERVICE_URL         ?? '',
    wallet:       process.env.WALLET_SERVICE_URL       ?? '',
    payment:      process.env.PAYMENT_SERVICE_URL      ?? '',
    identity:     process.env.IDENTITY_SERVICE_URL     ?? '',
    commerce:     process.env.COMMERCE_SERVICE_URL     ?? '',
    storage:      process.env.STORAGE_SERVICE_URL      ?? '',
    notification: process.env.NOTIFICATION_SERVICE_URL ?? '',
    kyc:          process.env.KYC_SERVICE_URL          ?? '',
    asset:        process.env.ASSET_SERVICE_URL        ?? '',
    realtime:     process.env.REALTIME_SERVICE_URL     ?? '',
    analytics:    process.env.ANALYTICS_SERVICE_URL    ?? '',
  };

  constructor(private readonly redisService: RedisService) {}

  async getDetails() {
    const [redisUp, servicesHealth] = await Promise.all([
      this.redisService.ping(),
      this.checkServices(),
    ]);

    const memUsage = process.memoryUsage();

    return {
      gateway: 'up',
      redis: redisUp ? 'up' : 'down',
      uptime: Math.floor(process.uptime()),
      memory: {
        heapUsed:  `${Math.round(memUsage.heapUsed  / 1024 / 1024)}MB`,
        heapTotal: `${Math.round(memUsage.heapTotal / 1024 / 1024)}MB`,
        rss:       `${Math.round(memUsage.rss       / 1024 / 1024)}MB`,
      },
      services: servicesHealth,
      timestamp: new Date().toISOString(),
    };
  }

  private async checkServices(): Promise<Record<string, ServiceHealth>> {
    const checks = Object.entries(this.services).map(async ([name, url]) => {
      if (!url) return [name, { reachable: false, latency: null, lastChecked: new Date().toISOString() }];

      const start = Date.now();
      try {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), 3000);

        const res = await fetch(`${url}/health`, {
          signal: controller.signal,
          headers: { 'x-internal-key': process.env.INTERNAL_SECRET ?? '' },
        }).finally(() => clearTimeout(timeout));

        return [name, {
          reachable: res.ok,
          latency: Date.now() - start,
          lastChecked: new Date().toISOString(),
        }];
      } catch {
        return [name, {
          reachable: false,
          latency: null,
          lastChecked: new Date().toISOString(),
        }];
      }
    });

    const results = await Promise.allSettled(checks);
    return Object.fromEntries(
      results
        .filter((r): r is PromiseFulfilledResult<[string, ServiceHealth]> => r.status === 'fulfilled')
        .map((r) => r.value)
    );
  }
}
```

### health.module.ts (add RedisService if not already imported)

```typescript
import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';
import { RedisModule } from '../redis/redis.module';

@Module({
  imports: [RedisModule],
  controllers: [HealthController],
  providers: [HealthService],
})
export class HealthModule {}
```

---

# FIX 4 — NEW-K: Centralized Health Runtime

**Repo:** `Tec-App`
**Files:**

### Create: `src/context/PlatformHealthContext.tsx`

```typescript
'use client';

import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
} from 'react';

type HealthStatus = 'online' | 'offline' | 'checking';

interface PlatformHealthState {
  status: HealthStatus;
  lastChecked: Date | null;
  consecutiveFailures: number;
}

interface PlatformHealthContextValue extends PlatformHealthState {
  recheck: () => Promise<void>;
}

const PlatformHealthContext = createContext<PlatformHealthContextValue | null>(null);

const POLL_INTERVAL_MS = 30_000;
const HEALTH_ENDPOINT  = '/api/health';
const FETCH_TIMEOUT_MS = 5_000;

async function checkGatewayHealth(): Promise<boolean> {
  try {
    const res = await fetch(HEALTH_ENDPOINT, {
      signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
      cache: 'no-store',
    });
    return res.ok;
  } catch {
    return false;
  }
}

export function PlatformHealthProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<PlatformHealthState>({
    status: 'checking',
    lastChecked: null,
    consecutiveFailures: 0,
  });

  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const runCheck = useCallback(async () => {
    const ok = await checkGatewayHealth();
    setState((prev) => ({
      status: ok ? 'online' : 'offline',
      lastChecked: new Date(),
      consecutiveFailures: ok ? 0 : prev.consecutiveFailures + 1,
    }));
  }, []);

  useEffect(() => {
    runCheck();
    intervalRef.current = setInterval(runCheck, POLL_INTERVAL_MS);
    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [runCheck]);

  return (
    <PlatformHealthContext.Provider value={{ ...state, recheck: runCheck }}>
      {children}
    </PlatformHealthContext.Provider>
  );
}

export function usePlatformHealth(): PlatformHealthContextValue {
  const ctx = useContext(PlatformHealthContext);
  if (!ctx) throw new Error('usePlatformHealth must be used inside PlatformHealthProvider');
  return ctx;
}
```

### Update: `src/app/layout.tsx` (or root layout)

```typescript
// Add PlatformHealthProvider to the root layout
import { PlatformHealthProvider } from '@/context/PlatformHealthContext';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <PlatformHealthProvider>
          {children}
        </PlatformHealthProvider>
      </body>
    </html>
  );
}
```

### Refactor: `src/components/BackendOfflineBanner.tsx`

```typescript
'use client';

import { usePlatformHealth } from '@/context/PlatformHealthContext';

export function BackendOfflineBanner() {
  const { status } = usePlatformHealth();

  if (status !== 'offline') return null;

  return (
    <div
      role="alert"
      className="fixed top-0 inset-x-0 z-50 bg-red-600 text-white text-center py-2 text-sm font-medium"
    >
      Backend is currently unavailable. Please try again in a moment.
    </div>
  );
}
```

### Refactor: `src/components/BackendStatus.tsx`

```typescript
'use client';

import { usePlatformHealth } from '@/context/PlatformHealthContext';

const STATUS_CONFIG = {
  online:   { label: 'Online',   className: 'bg-green-500' },
  offline:  { label: 'Offline',  className: 'bg-red-500'   },
  checking: { label: 'Checking', className: 'bg-yellow-500' },
} as const;

export function BackendStatus() {
  const { status, lastChecked } = usePlatformHealth();
  const { label, className } = STATUS_CONFIG[status];

  return (
    <div className="flex items-center gap-2 text-sm">
      <span className={`h-2 w-2 rounded-full ${className}`} aria-hidden="true" />
      <span>Backend: {label}</span>
      {lastChecked && (
        <span className="text-xs text-gray-400">
          ({lastChecked.toLocaleTimeString()})
        </span>
      )}
    </div>
  );
}
```

### Delete (if exists): `src/hooks/useBackendHealth.ts`

This hook is now replaced by `usePlatformHealth()` from the context.
If other components use `useBackendHealth`, replace calls with `usePlatformHealth()`.

---

## Testing Checklist

### NEW-L (Gateway Timeout)

```bash
# Verify the change
grep -r "proxyTimeout\|timeout:" tec-api-gateway/src/modules/proxy/proxy.service.ts
# Expected: timeout: 10000, proxyTimeout: 10000
```

### NEW-N (Redis Diagnostics)

```bash
# Verify all 5 listeners exist
grep -c "client.on(" tec-api-gateway/src/modules/redis/redis.service.ts
# Expected: 5 (connect, ready, error, reconnecting, end)
```

### NEW-O (Health Details)

```bash
# Test public endpoint
curl http://localhost:3000/health
# Expected: { "status": "ok" }

# Test details (with internal key)
curl -H "x-internal-key: $INTERNAL_SECRET" http://localhost:3000/health/details
# Expected: { gateway, redis, uptime, memory, services }
```

### NEW-K (PlatformHealthContext)

```bash
# Verify no duplicate polling
grep -r "setInterval\|useBackendHealth\|checkGatewayHealth\|checkBackendHealth" \
  src/components/BackendOfflineBanner.tsx \
  src/components/BackendStatus.tsx
# Expected: 0 matches (all polling is in PlatformHealthContext)
```

---

## PR Titles (suggested)

```
fix(gateway): align proxy timeout to 10s — resolves 499 ghost failures (NEW-L)
fix(gateway): add Redis lifecycle event listeners — observable runtime (NEW-N)
feat(gateway): add /health/details endpoint with runtime evidence (NEW-O)
refactor(frontend): centralize health polling in PlatformHealthContext (NEW-K)
```

---

## After All 4 PRs Merge

Update C-40 violations:
- NEW-K → VERIFIED
- NEW-N → VERIFIED
- NEW-O → VERIFIED
- NEW-L → VERIFIED

Update C-02 PLATFORM STATE:
- Health Runtime: 6.5 → 9.0
- PRI score target: 8.22 → ~8.8

---

*C-81 Implementation Guide — prepared June 2026 | Authority: ADR-008 + C-96*
