# P1 evidence — cycle 2026-11-11 · Run 1

```bash
python3 audits/engineering-audit-pipeline/tools/architecture_checks.py --repos-dir <clones> --ref origin/main
# output committed as check-hits.json; counts:
# C01 0 · C02 0 · C03 0 · C04 5 · C06 4 · C08 21 · C12 2 · C13 0 · C16 80 · C18 0 · C20a 1 · C20b 1 · C21 0
```

**About P1-C18:** the first version searched for a path (`/v2/payments`) and found nothing,
which would have read as compliant. The base URL is built from a constant, so the search now
looks for the host (`api.minepi.com` / `api.sandbox.minepi.com`) and allows only
`tec-auth-service/` and `tec-payment-service/`. Horizon (`api.mainnet|testnet.minepi.com`) is
the public ledger, not the Platform API. The result is verified CLEAN, not just quiet.

## Triage of every hit

### P1-C04 (5) → TEC-AUDIT-0014
`tec-api-gateway/src/main.ts:729-735`, `tec-analytics-service/.../analytics.controller.ts:71`,
`tec-payment-service/src/middlewares/jwt.middleware.ts:46`,
`tec-wallet-service/src/guards/internal.guard.ts:75` all use `timingSafeEqual`, after comparing
`string.length`. `internal.guard.ts:80` is the refusal log. No `===` comparison of the key exists.

### P1-C06 (4) → TEC-AUDIT-0012, TEC-AUDIT-0013
| Location | Classification |
|---|---|
| `tec-asset-service/prisma/schema.prisma:70` `price Float` | Finding 0012 — read/written by `marketplace.service.ts:34-35` and `marketplace.controller.ts:121,141` |
| `tec-wallet-service/prisma/schema.prisma:114` `Account.balance Float` | Finding 0013 — model commented "nothing in the code reads or writes it"; the live `Wallet.balance` is Decimal(20,8) |
| `tec-analytics-service/prisma/schema.prisma:39` `total_volume Float?` | Finding 0013 — projection, eventual by C-47 |
| `tec-life-service/prisma/schema.prisma:40` `target_amount Float?` | Finding 0013 — a self-declared target |

### P1-C08 (21)
| Location | Classification | Why |
|---|---|---|
| Tec-App `api/kyc/admin/{reject,verify}/route.ts:12` | False positive | `userId` is the **target** of an admin action. tec-kyc-service `kyc.controller.ts:49-61,102-119` verifies the token (`jwtService.verify`, HS256) and requires `role === 'admin'` |
| Tec-Nexus `src/lib/nexus/handshake.ts:69` | False positive | The BFF route takes `owner`/`userId` from the session (`ownerFromSession`, `userIdFromSession` — `api/bff/nexus/handshakes/[code]/[action]/route.ts:13-16`) |
| tec-api-gateway `main.ts:97` | False positive | A comment |
| tec-asset-service `marketplace.controller.ts:127,130` | False positive | `assertCaller(body.sellerId, verifiedUser, true)` holds the body to the token |
| `owner-match.guard.ts:62,65` in business · identity · nexus · trust | False positive | This **is** the enforcement (C17): a user caller's `body.userId` must equal its token |
| tec-commerce-service `order.controller.ts:184,207` (reserve/release) · `subscription.controller.ts:109` (grant) | False positive | Service-only routes: `assertInternalKey(internalKey, caller)` before the body is read |
| tec-nexus-service `handshake.controller.ts:22,38` · `nexus.controller.ts:68` | False positive | Controllers under `@UseGuards(OwnerMatchGuard)` (`handshake.controller.ts:9`, `nexus.controller.ts:12`) |
| One remaining hit | **Finding TEC-AUDIT-0015** | Withheld while open (README §7): its classification and reasoning went to the owner, not here |

### P1-C12 (2) — false positives
`Tec-App tec-frontend/next.config.js:117` is the CSP `connect-src` entry for the realtime
service, which is public by design (C-20: the browser connects directly).
`tec-frontend/vitest.setup.ts:14` is a test-setup comment.

### P1-C16 (80) → TEC-AUDIT-0011
Per repository: 3 in each template app (layout `Pi.init` · `pi-auth.ts` authenticate ·
`pi-payment.ts` createPayment), Tec-App 4, Tec-Commerce 6, Tec-Assets 4, Tec-Ecommerce 4,
Tec-Life 2. The `layout.tsx` `Pi.init` lines are the accepted exception (inline, before any
module). `PiRuntime.ts:23-43` (template) shows what the bypass skips: the circuit-breaker gate.

### P1-C20a (1) — false positive
`TEC-SDK src/contracts/payment.ts:69`: "`x-service-secret` is NOT recognised — never use it."

### P1-C20b (1) → TEC-AUDIT-0016
`Tec-App tec-frontend/src/app/api/bff/wallet/withdraw/route.ts:44` — wallet, not payment.

## Evidence index

EV-0014 … EV-0032 — see `registry/evidence-index.json`.
