# TEC — 10-Minute Quick Start

> **This is onboarding material, not constitutional knowledge.** It is intentionally
> **not** a `C-NN` document: it changes often (versions, commands, URLs) and must not
> add drift to the constitution. It has no Truth Framework header and is **not** in
> C-57. For the *why* behind any step, follow the C-doc links.

Goal: from zero to **a running TEC app you can log into and pay in** — in ~10 minutes.

---

## 0. What you're building on (30 seconds)

TEC is one economy on Pi: **24 frontend apps** sharing one identity + one wallet, over a
**12-service backend**. The release chain (never skip the order):

```
tec-core-backend  →  tec-sdk  →  tec-auth  →  tec-ui  →  [fleet apps]
```

- **Fleet source of truth:** `architecture/app-fleet.yaml` (domain · Pi App ID · slug · status).
- **New app?** Clone `tec-template-base` and follow its `New app setup checklist`.

---

## 1. Prerequisites (1 min)

```bash
node -v      # ≥ 20
npm -v       # ≥ 10
docker -v    # for the backend stack
```

---

## 2. Run a frontend app (3 min)

Every fleet app is a Next.js 15 app with the same shape. Using any app repo (e.g. `tec-commerce`):

```bash
git clone https://github.com/Yasira82/Tec-Commerce && cd Tec-Commerce
npm install
cp .env.example .env.local   # then fill the values in step 4
npm run dev                  # http://localhost:3000
```

Standard scripts in every app:

```bash
npm run dev         # dev server
npm run build       # production build
npm run lint        # ESLint
npm run typecheck   # tsc --noEmit (strict)
npm run test        # vitest
```

---

## 3. Run the backend (2 min)

```bash
git clone https://github.com/Yasira82/Tec-core-backend && cd Tec-core-backend
docker-compose up            # brings up the gateway + services + Postgres + Redis
# one service in dev:
cd tec-identity-service && npm install && npm run dev
```

Gateway is the single entry point (ADR-005). All client traffic → `tec-api-gateway` → services.

---

## 4. The env you actually need (2 min)

Minimum for login + payment to work (never commit these):

| Var | Where | Purpose |
|-----|-------|---------|
| `API_GATEWAY_URL` | app `.env.local` (**server-only**, never `NEXT_PUBLIC_*`) | BFF → gateway |
| `INTERNAL_SECRET` | app + every backend service | inter-service `x-internal-key` (must match everywhere) |
| `SSO_SECRET` | app | Hub SSO callback verification |
| `NEXT_PUBLIC_PI_APP_ID` | app | Pi SDK init (from `app-fleet.yaml`) |
| `PI_SANDBOX` | app | `false` in production |
| `NEXT_PUBLIC_HUB_URL` | app | **real https URL or unset** — a placeholder becomes the login/redirect target → 404 |
| `REDIS_URL` | backend services | streams + idempotency (value chain needs it on `tec-identity-service`) |
| `PI_API_KEY_<SLUG>` | `tec-payment-service` | per-app Pi key; missing → Mode-2 approve fails (Pi 404) |

---

## 5. Log in + pay (2 min)

1. **Login** — click "Login with Pi". Hub sets HttpOnly cookies `tec_access_token`,
   `tec_csrf`, `tec_user` (never localStorage). See **C-123** for the cookie laws.
2. **Pay** — every buy handler is dual-mode (**ADR-007** / C-76):
   - came **from Hub** (`isHubNavigation()`) → Mode 1: redirect to `/hub?pay=1&...`
   - standalone Pi Browser → Mode 2: `createPaymentRecord()` then `createU2APayment()`
3. Verify **both** modes with a real Pi payment before you call an app live.

Two rules that break payments if ignored:
- **CSRF is middleware-only** — never validate CSRF in a route handler (403s Mode-2). C-12 §11.
- `amount` is a **number**; gateway path is `/api/payment/*`; header is `x-internal-key`. **ADR-009**.

---

## 6. Deploy (1 min)

- **Frontend** → Vercel (per app). Set the env from step 4; **redeploy after changing any
  `NEXT_PUBLIC_*`** (inlined at build time).
- **Backend** → Railway (12 services). `INTERNAL_SECRET` must match across all of them.
- **Portal** → register the domain + App ID in the Pi Developer Portal; set `/privacy` + `/terms`.

---

## Where to go next

- **First real read:** [`knowledge-base/C-02___CURRENT_STATE_.md`](../knowledge-base/C-02___CURRENT_STATE_.md) — the living current-state doc (read it at the start of every session).
- **Architecture policy:** [`C-132`](../knowledge-base/C-132___SERVICE_EXTRACTION_MODULAR_ARCHITECTURE_POLICY.md) (Modules-First) · **Kernel Spec:** [`C-47`](../knowledge-base/C-47_Kernel_Spec_Architecture_Binding.md).
- **Payments:** [`C-12`](../knowledge-base/C-12_Dual_Mode_Payment.md) · [`C-76`/ADR-007](../knowledge-base/C-76___ADR-007.md) · **Sessions/cookies:** [`C-123`](../knowledge-base/C-123___PI_BROWSER_SESSION_COOKIE_SPEC.md).
- **Events:** [`C-70`](../knowledge-base/C-70___EVENT_GOVERNANCE_SPEC.md) governance + [`manifests/events-catalog.yaml`](../manifests/events-catalog.yaml) the catalog.
- **Full index:** [`C-57`](../knowledge-base/C-57___MASTER_CONTENTS_INDEX.md).
