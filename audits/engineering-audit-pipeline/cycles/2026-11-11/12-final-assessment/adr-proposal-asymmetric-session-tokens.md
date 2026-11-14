# ADR proposal — session tokens signed by one service, verified with a public key

**Status:** PROPOSED — for the owner. Unnumbered: the owner numbers it (README §7) and, if accepted,
it goes into C-64. It amends ADR-002 (auth-service is the identity authority) and touches C-123
(the session law) only in how a token is checked, never in which cookies carry it.
**Answers:** TEC-AUDIT-0008 (acceptance: only tec-auth-service holds a signing key; every
verifier holds only a public key).
**Truth State:** [Current State] for the facts, [Planned State] for the decision.
**Verification:** [Code Verified] — read from the code on 14 Nov 2026. Last verified: 2026-11-14.

## Context — what the code shows

- Session tokens are HS256 over one `JWT_SECRET`. To **verify** a token a service needs that secret,
  and anything holding it can also **sign** one — for any user, the operator included.
- It is held by tec-auth-service, **19 of the backend services** and **22 apps** (each app's BFF
  verifies the session locally). One leak anywhere is a forged session everywhere.
- auth-service is not the only signer today. **The Hub signs** the AI context token with
  `JWT_SECRET` (`lib/ai/context-token.ts`, verified by tec-ai-service): a second issuer of a token
  minted under the session key.
- Verification itself is in good order: 135 calls, every one pinned to `HS256` (P3 report) — the
  problem is who can sign, not how tokens are checked.
- Separate and smaller: `SSO_SECRET` (one-time handoff tokens between the Hub and the apps, HS256,
  short-lived, `jti`-checked) has the same shape — every app can mint a handoff for every other.

## Decision proposed

1. **auth-service alone signs session tokens, with ES256** (P-256). The private key is one Railway
   variable on auth-service and nowhere else.
2. **Every verifier holds the public key only** — `JWT_PUBLIC_KEYS`, a PEM (or a short list of
   them), set as a variable, not fetched. A JWKS endpoint was considered and not chosen: a fetch
   on the verification path is a dependency that can fail, and a variable that is missing fails
   closed at boot (the env schemas already do this). Each token carries a `kid`; the variable may
   hold two keys during a rotation.
3. **Algorithms are pinned per key** (`algorithms: ['ES256']`), never read from the token.
4. **ES256, not EdDSA:** `@nestjs/jwt` signs through `jsonwebtoken`, which has no EdDSA; `jose`
   (the apps, the edge middleware) does both. ES256 is the one every library here supports.
5. **The Hub stops signing with the session key.** The AI context token gets its own key pair
   (the Hub signs, ai-service verifies with the public half) — or auth-service issues it; the
   owner's choice. Either way `JWT_SECRET` is no longer a signing key anywhere.
6. **Refresh tokens** are read only by auth-service; they may stay symmetric on an auth-only
   secret (`JWT_REFRESH_SECRET`, which already exists) — no other service ever needs it.
7. `SSO_SECRET` follows the same pattern in a second phase (the Hub signs handoffs; apps verify
   with its public key). Not in this decision's first rollout.

## Rollout — no one is signed out

| Step | What | Gate |
|---|---|---|
| 1 | Every verifier accepts **both**: HS256 with `JWT_SECRET` and ES256 with `JWT_PUBLIC_KEYS`, chosen by the token's `alg`/`kid` against an allow-list (never "whatever the token says") | Deployed to all 19 services + 22 apps; a test in each with an ES256 token |
| 2 | auth-service signs **ES256** for new sessions | Step 1 complete fleet-wide (C-11 shows versions) |
| 3 | Wait one refresh lifetime (7 days): every live session is now ES256 | Logs: no HS256 session verified for 24 h |
| 4 | Remove HS256 acceptance and `JWT_SECRET` from every service and app | — |
| 5 | Rotate: new key pair, both public keys listed, switch the signer, drop the old | A runbook entry (C-78) |

Release chain as usual: tec-core-backend → tec-sdk (if a verifier helper is shared there) → the
template → template-sync to the apps → the Hub.

## Costs

- Two variables per service and app change (one added, one later removed) — 40+ places; the
  drift check (`check-drift.py`) should learn `JWT_PUBLIC_KEYS`.
- ES256 verification is slower than HS256 by microseconds per request — nothing at this traffic.
- A forgotten verifier in step 1 rejects every session at step 2. That is why step 2 is gated on
  a fleet-wide check, not on a calendar date.

## Not decided here

Who issues the AI context token (point 5) and when `SSO_SECRET` follows (point 7).
