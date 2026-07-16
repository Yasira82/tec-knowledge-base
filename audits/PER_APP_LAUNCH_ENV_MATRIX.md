# Per-App Launch & Env Matrix — TEC go-live runbook

> **Truth State:** `[Current State]` · **Verification:** `[Runtime Verified]`
> One runbook for taking any TEC app from "scaffold merged" → "login + payment work
> in production". Every incident in this session was **config, not code**. This is the
> checklist that would have prevented each one.
>
> Companion: `architecture/app-fleet.yaml` (what stage each app is at) ·
> `knowledge-base/C-12_Dual_Mode_Payment.md` §11 (payment anti-regression) ·
> `knowledge-base/C-123` (session/cookies) · `audits/PORTAL_SUBMISSION_RUNBOOK_2026-06-21.md`.

---

## 1. The four incident classes (memorize these signatures)

| Symptom in prod | Root cause | Fix | Source of law |
|---|---|---|---|
| `{"error":"sso_not_configured"}` at hub `/hub` | `SSO_SECRET` missing on the app's Vercel (or ≠ Hub's) | Set `SSO_SECRET` **= Hub's exactly**, redeploy | C-13 |
| Login/pay redirect → `.../hub` **404** | `NEXT_PUBLIC_HUB_URL` is a placeholder (e.g. `C_HUB_URL`) | Real `https://…` or unset; **redeploy** (NEXT_PUBLIC is build-time) | C-12 §11 rule 9 |
| Login → `tecosystem.app/api/auth/sso?...` → **net::ERR_CONNECTION_CLOSED** | `NEXT_PUBLIC_HUB_URL` = the **apex** `https://tecosystem.app` (no `hub.`) — apex serves no Hub | Set `NEXT_PUBLIC_HUB_URL = https://hub.tecosystem.app`; **redeploy** | Elite login incident (Jul 2026) |
| Standalone approve → **502**, Pi `payment_not_found`, Railway `Unknown payment source="app"` | `PI_API_KEY_<SLUG>` missing on payment-service **OR** create-route `APP_SOURCE` still `'app'` | Set `PI_API_KEY_<SLUG>` on Railway **and** verify `src/lib/app-source.ts` slug | C-12 §11 rule 10 |
| Payment → `SDK_MISSING` / instant 404 in Pi Browser | Portal **Linked App = Testnet** on a Mainnet listing | Point Linked App to the **Mainnet** app | FundX/Estate lesson |

---

## 2. Required Vercel env (Production) — every app

| Var | Value | Notes |
|-----|-------|-------|
| `SSO_SECRET` | **= Hub's, exactly** | HMAC signing; mismatch → sso_not_configured / bad SSO |
| `API_GATEWAY_URL` | Railway gateway (server-only) | never `NEXT_PUBLIC_*` (NEW-A) |
| `INTERNAL_SECRET` | shared platform secret | same value across gateway + services |
| `NEXT_PUBLIC_PI_APP_ID` | the app's Pi App ID | build-time — redeploy after change |
| `PI_SANDBOX` | `false` | Mainnet |
| `NEXT_PUBLIC_HUB_URL` | `https://hub.tecosystem.app` | real https or **unset** — never a placeholder |
| `NEXT_PUBLIC_APP_URL` | the app's own https domain | real https or unset |

> ⚠️ **NEXT_PUBLIC_\* are inlined at BUILD time.** Changing one requires a **redeploy**
> (a settings save alone does nothing). Easiest bootstrap: copy the three secrets
> (`SSO_SECRET`/`API_GATEWAY_URL`/`INTERNAL_SECRET`) from a working app (e.g. tec-system).

## 3. Railway (payment-service) — per app that takes payments

- Set **`PI_API_KEY_<SLUG>`** (slug uppercased, e.g. `PI_API_KEY_ZONE`). Missing → the
  loud fallback to the default Hub key → Pi 404 → approve 502. `getPiApiKey(source)`.

## 4. Hub enablement — the silent-failure step (easy to forget)

Two files in **Tec-App**, both required or login/visibility breaks **silently**:
1. `tec-frontend/src/app/api/auth/sso/route.ts` → add both domains to **`ALLOWED_TARGETS`**
   (`https://<app>.tecosystem.app` + `https://tec-<app>.vercel.app`). Missing → `invalid_target`.
2. `tec-frontend/src/domains/_registry.ts` → add the app entry (status `live`/`coming_soon`,
   route, description). Missing → app doesn't appear in the Hub grid.

## 5. Go-live checklist (per app)

```
□ package.json name + src/lib/app-source.ts slug set (NOT 'app')
□ sso-callback ALLOWED_AUDIENCES → app domains
□ privacy/ + terms/ → app name + domain
□ NEW-A: no Railway host / NEXT_PUBLIC gateway URL in client bundle
□ ADR-007 isHubNavigation() guard on every buy handler
□ Vercel envs (§2) set — SSO_SECRET = Hub's; redeploy after any NEXT_PUBLIC change
□ Railway PI_API_KEY_<SLUG> set (§3)
□ Hub enablement (§4): ALLOWED_TARGETS + _registry.ts  ← both
□ Pi Portal: register domain + App ID; /privacy + /terms URLs; Linked App = MAINNET
□ Add real App ID to C-01 §4 + architecture/app-fleet.yaml (status → registered/live)
□ Runtime-verify in Pi Browser: login (C-123) + a real payment Mode 1 (Hub) AND Mode 2
```

## 6. When adding a real App ID

Update in one commit: **C-01 §4** (Portal identity table) + **C-01 §3.1** (fleet table
✅) + **`architecture/app-fleet.yaml`** (`pi_app_id` + `status`). `check-portal-readiness`
requires §4 App IDs to be real (no `TBD`/placeholder) and to agree across C-01 ↔ C-02 ↔
the Portal runbook.
