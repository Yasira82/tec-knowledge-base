# C-65 — NEW BACKEND SERVICE TEMPLATE

> **Truth State:** `[Current State]`
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`

---


NestJS Service Scaffold — نسخ ولصق جاهز

## SERVICE CREATION GATE — اقرأ أولاً

❌ ممنوع إنشاء service جديدة إلا إذا تحققت كل الشروط:

  1. الـ functionality لا تنتمي لأي service من الـ 12 الموجودين
  2. Bounded context مستقل فعلياً — مش مجرد feature
  3. Event ownership واضح — مين بيبعت ومين بيستقبل
  4. Database ownership واضح — الـ service يملك DB منفردة

⚠️ Default decision = أضف Module داخل service موجود
   مش service جديدة. Service جديدة هي الاستثناء مش القاعدة.

أول service جديد مخطط: life-service (بعد Portal Submission)

---

## هيكل الـ Service الجديد

```
Tec-core-backend/
  tec-[name]-service/
    prisma/
      schema.prisma
    src/
      main.ts
      app.module.ts
      modules/
        [domain]/
          [domain].module.ts
          [domain].controller.ts
          [domain].service.ts
          dto/
            create-[domain].dto.ts
      consumers/
        [name].consumer.ts
      health/
        health.controller.ts
      config/
        env.ts
    Dockerfile
    .env.example
```

---

## STEP 1 — env.ts (validation إلزامي)

```typescript
import { z } from 'zod';

const envSchema = z.object({
  PORT:            z.string().default('501X'),
  NODE_ENV:        z.enum(['development', 'production', 'test']),
  DATABASE_URL:    z.string().min(1),
  REDIS_URL:       z.string().min(1),
  JWT_SECRET:      z.string().min(32),
  INTERNAL_SECRET: z.string().min(32),
});

export type Env = z.infer<typeof envSchema>;
let _env: Env;

export const getEnv = (): Env => {
  if (!_env) {
    const parsed = envSchema.safeParse(process.env);
    if (!parsed.success) {
      console.error('❌ Invalid environment:');
      console.error(parsed.error.format());
      process.exit(1);
    }
    _env = parsed.data;
  }
  return _env;
};

export const env = getEnv();
```

---

## STEP 2 — main.ts (bootstrap)

```typescript
import { NestFactory } from '@nestjs/core';
import { AppModule }   from './app.module';
import { env }         from './config/env';
import pino            from 'pino';

const logger = pino({ level: 'info' });

async function bootstrap() {
  if (!env.INTERNAL_SECRET) {
    logger.error('FATAL: INTERNAL_SECRET not configured');
    process.exit(1);
  }
  if (!env.REDIS_URL && env.NODE_ENV === 'production') {
    logger.error('FATAL: REDIS_URL required in production');
    process.exit(1);
  }

  const app = await NestFactory.create(AppModule, { logger: false });
  app.setGlobalPrefix('api/v1');
  await app.listen(env.PORT);
  logger.info(`[name]-service running on port ${env.PORT}`);
}

bootstrap();
```

---

## STEP 3 — app.module.ts

```typescript
import { Module }         from '@nestjs/common';
import { PrismaModule }   from './prisma/prisma.module';
import { [Domain]Module } from './modules/[domain]/[domain].module';
import { HealthModule }   from './health/health.module';

@Module({
  imports: [PrismaModule, [Domain]Module, HealthModule],
})
export class AppModule {}
```

---

## STEP 4 — [domain].module.ts

```typescript
import { Module }             from '@nestjs/common';
import { [Domain]Controller } from './[domain].controller';
import { [Domain]Service }    from './[domain].service';
import { PrismaModule }       from '../../prisma/prisma.module';

@Module({
  imports:     [PrismaModule],
  controllers: [[Domain]Controller],
  providers:   [[Domain]Service],
  exports:     [[Domain]Service],
})
export class [Domain]Module {}
```

---

## STEP 5 — [domain].controller.ts

```typescript
import {
  Controller, Get, Post, Body, Param,
  UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common';
import { [Domain]Service }   from './[domain].service';
import { Create[Domain]Dto } from './dto/create-[domain].dto';
import { AuthGuard }         from '../../guards/auth.guard';
import { InternalGuard }     from '../../guards/internal.guard';
import { GetUser }           from '../../decorators/get-user.decorator';

@Controller('[domain]')
export class [Domain]Controller {
  constructor(private readonly svc: [Domain]Service) {}

  @Get(':id')
  @UseGuards(InternalGuard)
  @HttpCode(HttpStatus.OK)
  async findOne(@Param('id') id: string) {
    const data = await this.svc.findOne(id);
    return { success: true, data };
  }

  @Post()
  @UseGuards(AuthGuard)
  @HttpCode(HttpStatus.CREATED)
  async create(
    @GetUser('id') userId: string,
    @Body() dto: Create[Domain]Dto,
  ) {
    const data = await this.svc.create(userId, dto);
    return { success: true, data };
  }
}
```

---

## STEP 6 — [domain].service.ts

```typescript
import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService }                 from '../../prisma/prisma.service';
import { Create[Domain]Dto }             from './dto/create-[domain].dto';
import pino                              from 'pino';

const logger = pino({ level: 'info' });

@Injectable()
export class [Domain]Service {
  constructor(private readonly prisma: PrismaService) {}

  async findOne(id: string) {
    const record = await this.prisma.[domain].findUnique({ where: { id } });
    if (!record) throw new NotFoundException(`[Domain] ${id} not found`);
    return record;
  }

  async create(userId: string, dto: Create[Domain]Dto) {
    logger.info({ userId }, 'Creating [domain]');
    return this.prisma.[domain].create({ data: { userId, ...dto } });
  }
}
```

---

## STEP 7 — prisma/schema.prisma

```prisma
generator client {
  provider = "prisma-client-js"
  output   = "./prisma/client"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model [Domain] {
  id        String   @id @default(uuid())
  userId    String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@map("[domains]")
}
```

---

## STEP 8 — Redis Consumer

```typescript
import { Redis }           from 'ioredis';
import {
  subscribeStream,
  ensureConsumerGroup,
  EVENTS,
}                          from '@yasser172/tec-shared';
import pino                from 'pino';

const logger       = pino({ level: 'info' });
const SERVICE_NAME = '[name]-service';
const CONSUMER     = '[name]-consumer-1';

export const start[Name]Consumer = async (redis: Redis): Promise<void> => {
  await ensureConsumerGroup(redis, EVENTS.PAYMENT_COMPLETED, SERVICE_NAME);
  logger.info('[name] consumer started');

  await subscribeStream(
    redis,
    EVENTS.PAYMENT_COMPLETED,
    SERVICE_NAME,
    CONSUMER,
    async (payload) => {
      const { payment_id, user_id, amount, source } = payload as {
        payment_id: string;
        user_id:    string;
        amount:     string;
        source:     string;
      };
      logger.info({ payment_id, user_id }, 'Processing payment.completed');
      // ✅ idempotency check في الـ service قبل أي DB write
    },
    { batchSize: 10, blockMs: 5000, retryDelay: 1000 },
  );
};
```

---

## STEP 9 — health/health.controller.ts

```typescript
import { Controller, Get } from '@nestjs/common';
import { PrismaService }   from '../prisma/prisma.service';

@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  check() {
    return { status: 'ok', service: '[name]-service' };
  }

  @Get('ready')
  async ready() {
    await this.prisma.$queryRaw`SELECT 1`;
    return { status: 'ready', database: 'ok' };
  }
}
```

---

## STEP 10 — Dockerfile

```dockerfile
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npx prisma generate
RUN npm run build

FROM node:20-slim AS runner
WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

COPY --from=builder --chown=appuser:appgroup /app/dist         ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/package.json ./
COPY --from=builder --chown=appuser:appgroup /app/prisma       ./prisma

USER appuser
EXPOSE ${PORT}

HEALTHCHECK --interval=30s --timeout=10s \\
  CMD curl -f http://localhost:${PORT}/api/v1/health/ready || exit 1

CMD ["node", "dist/main.js"]
```

---

## STEP 11 — Gateway Integration

```typescript
// tec-api-gateway/src/main.ts
const [NAME]_SERVICE_URL = process.env.[NAME]_SERVICE_URL;

app.use('/api/v1/[domain]', createProxyMiddleware({
  target:       [NAME]_SERVICE_URL,
  changeOrigin: true,
  headers: {
    'x-internal-key': env.INTERNAL_SECRET,
    'x-request-id':   requestId,
  },
}));
```

---

## STEP 12 — Railway Checklist

```
□ أضف service في Railway
□ DATABASE_URL=postgresql://...tec_[name]
□ REDIS_URL= (نفس الـ ecosystem)
□ JWT_SECRET= (نفس الـ ecosystem)
□ INTERNAL_SECRET= (نفس الـ ecosystem)
□ PORT=501X
□ أضف [NAME]_SERVICE_URL في Gateway
□ Deploy → health check: /api/v1/health/ready ✅
```

---

## Related Contents

- C-16 — Database Rules
- C-20 — Backend Services (ports + URLs)
- C-47 — Kernel Spec
- C-56 — Redis Streams
- C-60 — Code Templates
