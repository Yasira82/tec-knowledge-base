# Dependency map — cycle 2026-11-11 · Run 6

How the 30 repositories depend on each other, and what a change in one forces in the others.
`[Code Verified]` from lock files and imports, 13 Nov 2026.

```
                    tec-knowledge-base  (rules · catalog · drift checks — reads all, ships nothing)
                              │
   TEC-SDK 1.4.0 ─┐   Tec-ui 3.0.0 ─┐   tec-auth 1.2.0 ─┐        (npm)
   (1.3.0: 21 apps │  (2.1.0: Assets  │  (not the Hub,    │
    1.2.2: Hub +   │   Commerce,      │   not Commerce)   │
    Assets,Commerce│   Ecommerce;     │                   │
    Ecommerce)     │   not the Hub)   │                   │
                   ▼                  ▼                   ▼
   tec-template-base ──template-sync──▶ 20 apps (Life · Zone far behind; NBF one test)
        │                                     │
        │   untracked: Tec-App (Hub) · Tec-Commerce · Tec-Assets · Tec-Ecommerce
        ▼                                     ▼
   every app's BFF ── gatewayFetch (local) ──▶ tec-api-gateway :3000 ──▶ 19 services (private)
                                                     │
          payment-service ── outbox payment.completed.v1 ──▶ commerce (subscription · order) · asset
                         │                                   · trust/legend · nexus · wallet
                         └─ direct payment.completed (best effort) ──▶ notification · realtime ·
                                                                       analytics  (dual-read, local)
          backup-job (Railway cron) ── R2 ◀── restore check (GitHub Actions; Railway twin, local)
```

| A change in… | …forces |
|---|---|
| `payment.completed.v1` shape | `shared/contracts/payment.completed.v1.json` + producer + every consumer, one change (the contract tests fail otherwise — local) |
| a shared template file | `template-sync apply` in 20 apps; fleet-drift names the laggards weekly (when Actions runs) |
| one of 0044's 11 files | **nothing tells you** — fix by hand in up to 18 apps, until they are tracked |
| `tec-sdk` | a publish, then each app's range (`^1.x` never reaches 2.x — C-02 Session 46) |
| `tec-ui` | the same; three apps are a major behind |
| the cookie contract (C-123) | all 24 apps + the Hub + `tec-auth`, together |
