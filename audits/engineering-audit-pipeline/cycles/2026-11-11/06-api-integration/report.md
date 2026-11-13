# P5 — API & Integration Contracts · cycle 2026-11-11 · Run 3

**Status: PASSED_WITH_FINDINGS** · [Code Verified] at `origin/main`, 13 Nov 2026

## What was checked, and what it found

| Check | Method | Result |
|---|---|---|
| Every gateway path the apps call is routed | all `${…}/api/…` calls in 25 app repos (712) against the 60 prefixes in `tec-api-gateway/src/config/service-registry.ts` | **709 match.** Two are tests calling the app's own origin; one is the template's example `/api/items` → **0035** |
| Docs ↔ code (ports, events, cookies, fleet) | `scripts/check-drift.py --ref origin/main` | **36 pass · 0 fail** — the events catalog has a producer for every entry |
| Timeouts on gateway calls | every BFF `fetch` to the gateway | **439 of 467 have none → 0033** |
| SDK as the contract (C-47 §14) | imports of `@yasser172/tec-sdk` per app; SDK history | 0–1 file per app; SDK unchanged since 13 Sep → **0034** |
| Request body limits | each service's parser | Bounded everywhere: Express default 100 kB (payment), Fastify default 1 MB, asset 5 MB, ai/life `BODY_LIMIT`. No finding |
| Gateway public routes | (Run 2, 0024) | Fixed locally in Run 2 — reads only for the catalogue |
| Amount type on the wire | C-71 §3 (Run 1, 0016) | One rule now; not re-measured |

## Summary

**3 findings: 2 MEDIUM · 1 LOW.** Routing is sound — nothing the apps call is unrouted. The two
MEDIUMs share a cause: there is **no shared way for a BFF to call the gateway**, so each of 467
calls decides for itself whether to time out and whether to check the response. One helper in the
template (timeout + optional schema), carried by template-sync, answers both.
