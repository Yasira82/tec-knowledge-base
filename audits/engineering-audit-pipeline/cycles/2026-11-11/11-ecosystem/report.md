# P10 — Cross-Repository Audit · cycle 2026-11-11 · Run 6

**Status: PASSED_WITH_FINDINGS** · [Code Verified], 13 Nov 2026, on each repository's working
tree (= `origin/main` + this cycle's local remediation commits; lock files as resolved).

## What was checked, and what it found

| Check | Result |
|---|---|
| One version of each shared package | Next 15.5.29 · React 18.2.0 · TypeScript 5.9.3 · zod 3.25.76 in all 25 apps. **Not the TEC packages → 0045**: `tec-ui` 3.0.0 in 21 apps, **2.1.0** in Assets · Commerce · Ecommerce (the pre-amber palette, C-83); `tec-sdk` **1.4.0 is published and used by none** — 21 on 1.3.0, 4 on 1.2.2; the **Hub uses neither `tec-ui` nor `tec-auth`** though its instructions say it does |
| Backend versions | Prisma 5.22.0 in all 19 with a schema; Fastify 5 / Nest 11 in 16; **Nest 10 on Express** in gateway · auth · wallet · realtime (C-02 says so) — where 0002's highs remain (3–6 high each, re-measured now) |
| A template fix reaches the apps | `template-sync` run on all 20 template apps: 17 differ by **one file** — the example this cycle's own 0035 fix added to the shared list and never copied out (a gap in the remediation, fixed with this run's); **Life and Zone miss 15–16** (the fleet screens, help, feedback, manifest, the Pi Browser e2e) → TEC-AUDIT-0005, still open there; NBF one test differs |
| Logic copied without a tracker | **0044.** 11 source files identical in 8–18 apps and in none of template-sync's lists. Five are in the template and **already diverge** (`api/auth/me` — session verification — in 3 versions among 7 sampled apps; the Pro cancel button in 4); the **referral loop** (C-133) is in 16 apps and **not in the template**, so a new app is born without it |
| Contracts across repositories | `payment.completed.v1`: one contract, producer + three consumers checked (0038, local). The dual stream (0036) converges after the three consumers deploy. SDK ↔ BFF: 0034 (an ADR) |
| Orphans | No unrouted call (P5). 26 gateway prefixes are `/api/v1/…` **aliases** no app names (apps call the unversioned form) — harmless, recorded. One live event with no consumer: `payment.approved.v1` (outbox row, no reader) — recorded |
| One provider for every guard | 0040 (P8): every scheduled check on GitHub Actions — the cross-repo single point of failure |

## Summary

**2 findings: 2 MEDIUM.** The fleet is uniform where a tool enforces it (Next, React, the
template-sync shared files) and drifts wherever nothing does: TEC's own packages, the files
copied by hand, and the two apps the sync never caught up. The lesson is the cycle's in one line:
**what is not checked by a tool diverges** — and does so quietly.
