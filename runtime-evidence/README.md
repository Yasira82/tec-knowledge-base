# Runtime Evidence

This directory holds **runtime evidence records** — append-only facts emitted by the
live platform (metrics, health snapshots, incidents, SLO breaches). It is the
`Reality → Evidence → Governance` half of the Runtime Governance Layer.

- **Contract:** `manifests/runtime-evidence-schema.yaml` (schema v1.0)
- **CI gate:** `evals/check-runtime-evidence.sh` validates every `**/*.yaml` here
- **Authority:** C-96 (obligation) · C-92 (health model) · C-78 (SLOs) ·
  C-93 (Verification Engine, consumer) · VAM tier **V-5 Operational Authority**

## Rules (enforced by the gate)

Every record must:
1. carry all required fields — `evidence_id`, `kind`, `timestamp`, `source`, `binds_to`;
2. use a known `kind` — `metric` · `health_snapshot` · `incident` · `slo_breach`;
3. include the kind-specific required fields (see schema);
4. name a non-empty `source` (attributable — C-96 Incident Evidence Principle);
5. `binds_to` ≥ 1 **existing** C-doc id (Runtime Visibility — no dangling claims);
6. use a unique `evidence_id`.

## Layout

```
runtime-evidence/
  README.md                 # this file
  examples/                 # committed, schema-validating samples
  *.yaml                    # real records (begin when Observability stack is live)
```

## Status

`[Planned State]` — the schema and validator are live now (the contract is ready).
Real records begin when the Observability stack (Prometheus/SLOs, infra/ops) starts
emitting here. The `examples/` prove the contract end-to-end and keep the gate green
until then.
