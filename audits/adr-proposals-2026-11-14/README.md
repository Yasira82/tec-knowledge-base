# ADR proposals — 14 Nov 2026 (KB governance review)

Two decisions the platform already runs on have no record in C-64. Each draft below
writes down what the code and the October work already do, so the owner can accept,
change or reject it. **Status: PROPOSED.** Numbers are the owner's (`.cursorrules`
RULE 6); the next free numbers in C-64 are ADR-015 and ADR-016, and each draft
names the one it would take only as a suggestion.

| Draft | What it records | Why now |
|---|---|---|
| [`outbox-pattern.md`](outbox-pattern.md) | payment-service writes a state change and its event in one transaction; a worker publishes the event | Six C-docs and payment-service's comments cite it as "ADR-004" — in C-64, ADR-004 is BFF-Only. |
| [`c-132-amendment-domain-hosts.md`](c-132-amendment-domain-hosts.md) | T5 (host saturation), domain hosts, and a logical database per service — the October moves | `audits/APP_EXPANSION_ARCHITECTURE_2026-10-11.md` said it "becomes law only when … an ADR amending C-132" exists. Seven services were then built under it; the ADR never was. |

On acceptance: the owner assigns the number, the text goes into C-64 (index row and
section), and the citations listed in each draft are re-pointed in the same change.
Until then nothing here is law, and no citation is changed to a number that does not
exist yet.
