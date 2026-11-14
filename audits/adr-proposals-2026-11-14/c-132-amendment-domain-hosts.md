# PROPOSED — Amend ADR-011 / C-132: domain hosts, T5, a logical database per service

> Truth State: `[Current State]` for what runs · `[Planned State]` for the record
> Governance State: `[Draft]` — the owner accepts it and assigns the number (suggested: ADR-016)
> Verification: `[Documentation Verified]` — the October progress table, and C-20's port map

## Context

ADR-011 (C-132) set Modules-First: a new domain is a module in an existing service, and a new
service needs an extraction trigger (T1–T4). It also said "target service count now = the 11
live services — unchanged".

On 11–16 Oct 2026 the owner decided (`audits/APP_EXPANSION_ARCHITECTURE_2026-10-11.md` §0, §5)
that identity-service had become a single point of failure carrying too many domains, and moved
them out: connection (5014), nexus + intent (5015), search / Explorer (5016), platform / System + DX
(5017), business / NBF · Titan · NX · Epic (5018), trust / Zone · Legend · Elite · VIP (5019) —
each with its own logical database, one gateway switch and a rollback. That document said it
"becomes law only when the owner approves it and assigns its numbers (an ADR amending C-132)".
The moves were approved and done; the ADR was never written. C-132 §7.1 was corrected on 14 Nov
2026 to list the 20 deployed services; this ADR supplies the rule that allowed them.

## Decision

1. **T5 — host saturation** (added to C-132 §5). A service that carries more than **8 domain
   modules**, or whose failure would take down more than **one domain**, is closed to new
   domains. New domains go to a **domain host**.
2. **Domain host.** A service that holds one domain (≥ 2 apps, or one app with a clear growth
   path) — e.g. `tec-business-service`, `tec-trust-service`. T5 does not license a service per app.
3. **A move changes where a module runs, never who owns it.** Owners (C-68), table names,
   event names and public paths (`/identity/<module>/*`) stay; the gateway switches one
   `*_SERVICE_URL`, and the move ships with its copy counts and its rollback.
4. **A logical database per service** on an existing PostgreSQL server, with its own role and
   migrations, and no read of another service's data. Never on the payment, wallet, auth or KYC
   servers (owner, 2026-10-12; `audits/DATABASE_PLACEMENT_AND_BACKUP_2026-10-12.md`).
5. **ADR-011 stays.** Modules-First is still the default; the Financial Hard-Gate is unchanged
   (payment-service is the only Pi custodian). This ADR replaces only ADR-011's decision 5
   ("11 live services — unchanged").

## Consequences

- The deployed count is whatever C-20 says (20 on 14 Nov 2026: the gateway and 19 services);
  no ADR holds a count again — counts go stale, rules do not.
- Identity keeps what it owns (users, the ADMIN role) and answers moved modules over
  `/internal/` routes; those calls fail closed (503) when identity does not answer.
- Open follow-ups the October table already names: drop the moved modules and tables from
  identity; account deletion must reach every service that holds a person's data.

## On acceptance

- C-64: index row + section; ADR-011's row notes "decision 5 amended by ADR-0NN".
- C-132: §5 gains T5; §7 cites this ADR for the domain hosts.
- `audits/APP_EXPANSION_ARCHITECTURE_2026-10-11.md`: header → `[ADR Approved]`.

**References:** ADR-011 / C-132 · C-20 (ports, the deployed list) · C-68 (domain ownership) · C-47 (Invariant #8)
