# Engineering scorecard — cycle 2026-11-11

Scores out of 10, **per area, from the evidence of the phase that measured it**. Two columns:
`main` as deployed today, and **after** the local commits of this cycle are merged and deployed —
the difference is the cycle's own work, waiting on GitHub Actions.

| Area (phase) | `main` | After merge | Why — the one fact that sets it |
|---|---|---|---|
| Architecture (P1) | 7.5 | 7.5 | Clear service ownership and ADRs; 8 of 13 rules compliant at Run 1, the rest fixed or scheduled |
| Code quality (P2) | 7.0 | 7.0 | Strict TS and lint fleet-wide; very long Hub files; hand-written validation (0007) |
| Security (P3) | 6.0 | 6.5 | No secret ever committed; JWT pinned everywhere; one HS256 secret shared by all (0008); 0018 (HIGH) partly open; advisories in the Express services (0002) |
| Data integrity (P4) | 6.5 | 8.0 | DECIMAL + CHECK + unique keys; the reconciliation's missing event and two non-atomic status writes (fixed locally); Float price (0012) open |
| API & integration (P5) | 5.5 | 7.0 | No unrouted call; 437 of 465 gateway calls had no deadline (fixed locally); BFFs bypass the SDK (0034) |
| Functionality (P6) | 7.0 | 8.0 | 8 of 13 critical capabilities verified; session refresh broken on main (fixed locally) |
| Testing (P7) | 6.5 | 7.5 | 13,823 tests green; coverage floors never ran, no cross-service test (both fixed locally, partly) |
| Infrastructure (P8) | 5.0 | 6.0 | Non-root images, health endpoints, restored backups; no staging, no paging, no backup alert, every guard on one provider |
| Performance (P9) | 5.5 | 6.5 | Gateway hardened after June; uncapped public search (fixed locally); capacity never measured |
| Ecosystem (P10) | 6.0 | 6.5 | Uniform where a tool enforces it; drift in TEC's own packages and in hand-copied files |
| **Overall** | **6.3** | **7.1** | Unweighted mean. The baseline review of 11 Nov scored 6.8 — this cycle looked deeper and found more on `main`, and fixed more than it found |

The overall rises to about **7.6** once the owner-side items close (staging, paging, backup
alert, the asymmetric JWT) — the scores below 6.5 are almost all operations, not code.
