# P5 → handoff · cycle 2026-11-11 · Run 3

- **Remediation (template first, then template-sync):** a shared `gatewayFetch` with a timeout
  (0033); move the example route out of `src/app` (0035). Local commits only until Actions is back.
- **0034 needs a decision, not a patch:** where domain contracts live (SDK or app). An ADR — the
  owner's call. Until then, schema-check the money and entitlement routes first.
- **P8:** what users see when the gateway is slow, measured in production.
- **P10:** the SDK's release cadence and its consumers' ranges.
