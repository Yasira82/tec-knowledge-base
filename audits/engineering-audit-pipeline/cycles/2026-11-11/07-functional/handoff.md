# P6 → handoff · cycle 2026-11-11 · Run 4

- **Remediation:** 0036 — move notification, realtime and analytics to `.v1` (each idempotent by
  paymentId first), then stop the direct publish; correct the catalog; teach the drift check to
  compare consumers.
- **Owner:** 3 (session refresh) and 12 (Nexus Handshake payment) need a phone in Pi Browser.
- **P10:** the dual stream is a cross-repo contract — converge it in one coordinated change.
