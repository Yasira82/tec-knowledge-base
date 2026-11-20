# P1 — Architecture & Baseline Compliance · cycle 2026-11-11 · Run 1

**Status: PASSED_WITH_FINDINGS** · Gate B met with one recorded gap (TEC-AUDIT-0017) ·
[Code Verified] at `origin/main`, 11 Nov 2026

Each canonical rule that can be read in code was turned into a search
(`tools/architecture_checks.py`, output `check-hits.json`). A hit is a candidate. Every hit
was read in place and classified: a finding, or a false positive with the reason
(`evidence.md`). Tests are excluded.

## Results by rule

| Check | Rule | Hits | Outcome |
|---|---|---|---|
| P1-C01 | C-47 §12 — JWT verified, never decoded | 0 | **Compliant** |
| P1-C02 | ADR-001 — no token in web storage | 0 | **Compliant** |
| P1-C03 | C-47 §12 — no CORS wildcard | 0 | **Compliant** |
| P1-C04 | C-47 §12 — internal key compared in constant time | 5 | Constant time everywhere; length check on characters, not bytes → **TEC-AUDIT-0014** (LOW) |
| P1-C06 | C-47 §12 · C-71 — Pi amounts DECIMAL(20,8) | 4 | Marketplace `price` Float → **TEC-AUDIT-0012** (MEDIUM); three non-financial columns → **TEC-AUDIT-0013** (LOW). The real `Wallet.balance` is Decimal(20,8) |
| P1-C08 | C-47 §12 — identity from the session, never the body | 21 | 20 false positives (service-only routes behind the internal key, owner-match guards, admin routes behind a verified admin token). One → **TEC-AUDIT-0015** (INFO — unreachable; fixed) |
| P1-C12 | ADR-005 · NEW-A — no internal URL in the browser | 2 | False positives (CSP host for the public realtime service; a test comment) — **Compliant** |
| P1-C13 | C-12 §11 · C-123 — CSRF in middleware only | 0 | **Compliant** |
| P1-C16 | PAL (R1) — `window.Pi` only through PiRuntime | 80 | Sign-in and payment bypass the PAL in every app → **TEC-AUDIT-0011** (MEDIUM) |
| P1-C18 | ADR-002 · ADR-004 — Pi Platform API only from auth and payment services | 0 | **Compliant** |
| P1-C20a | ADR-009 — `x-internal-key` is the only inter-service header | 1 | False positive (the SDK's comment forbidding the old header) — **Compliant** |
| P1-C20b | ADR-009 — a payment amount is a number | 1 | A wallet withdrawal, not a payment endpoint; the baseline itself disagrees → **TEC-AUDIT-0016** (LOW) |
| P1-C21 | C-47 Forbidden #4 — no DB access in the gateway | 0 | **Compliant** |

**8 of 13 rules compliant. 5 produced findings: 0 critical, 0 high, 2 medium, 3 low, 1 info.**

## What this says about the architecture

- The **trust boundary holds where it was hardened**: no decoded JWTs, no wildcard CORS, no
  token in web storage, CSRF only in middleware, the Pi Platform API only in the two services
  allowed to call it, no database in the gateway. The C17 owner-match guard covers the modules
  that take an owner from the request (Nexus, Intent, Business, Identity, Trust).
- The **weakest rule in code is the PAL** (TEC-AUDIT-0011). It is listed as risk R1 (P0) in
  the Hub's own register and the abstraction exists, but the two paths that matter most —
  signing in and paying — do not use it, in all 25 repositories.
- **Money types are right in the financial core** (wallet, payment, commerce) and wrong at
  one edge that does price things in Pi: the asset marketplace (TEC-AUDIT-0012).
- The **baseline needs one decision** (TEC-AUDIT-0016) before P5 can judge amount types
  consistently.

## Not checked by search (handed on)

Rules that need runtime or tracing, not grep: outbox use on every payment state change
(ADR-004 → P4/P6), ActorContext on every sensitive operation (C-47 → P3/P6), event naming and
immutability (C-70 → P5), terminal-state transitions (C-47 Invariant #7 → P4/P6).
