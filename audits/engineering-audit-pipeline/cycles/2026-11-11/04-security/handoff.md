# P3 → Run 3 (P4 · P5) handoff · cycle 2026-11-11

- **P5:** the gateway route table (0024) — every exemption, method by method; body-size
  limits on routes that validate arrays (0020).
- **P4:** nothing new from P3; 0012 / 0013 are waiting there from Run 1.
- **P8:** the served headers (HSTS, CSP as delivered) were BLOCKED here — read them from Vercel.
- **Remediation order the owner can take** (no CI needed to decide, CI needed to merge):
  0018 first; then the SDK release (0019); the deletions (0021 · 0022 · 0025) are one-line PRs.
