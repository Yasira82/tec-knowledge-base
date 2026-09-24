# SESSION 56d — Phase 1.1 + 1.2: the capability registry stops being two things

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

Phase 1 step 1.1 shipped as **tec-core-backend #309** and step 1.2 lands here. Together
they close a P2 violation that was live on `main`, and they close it at both ends: the
runtime stops *reading* the duplicate, and CI stops a *third* one from being written.

### What was actually wrong

Two registries held the same five capabilities. **SYSTEM** had `SystemCapability` with
the enum `SystemGovernanceStatus` — the C-94 authority, as C-110 §5 says it should be.
**DX** had `DxCapability` with its own enum `DxCapStatus`, hand-typed beside it. Two
tables, two enums, nothing syncing them, and they had **already diverged**: `analytics-query`
read `DESIGNED` in SYSTEM and `CERTIFIED` in DX.

> A stale description is a bad doc. A stale `status` is a builder told an **uncertified**
> capability is certified — and which answer they got depended on which copy they happened
> to open. C-115 §4 says DX distributes and never certifies; the second table was that rule
> broken in storage.

**#309** made `DxService.listCapabilities()` ask `SystemService` at read time, through the
**service API** — the R-2-clean seam (C-132 §7.5), the same shape already adopted for
VIP → Elite and Elite → Legend, not a cross-module table read. DX keeps only what is
genuinely its own (`use`, `rank`). A capability SYSTEM does not govern comes back
`status: null, governed: false` — **listed, never dropped, never given a DX-local
default**, because presenting an uncertified capability as certified is the one outcome
this must not have (P6).

### 1.2 — the gate, and the single rule it enforces

`manifests/capability-registry.yaml` + `evals/check-capability-registry.sh` — the **20th
KB gate**, built on the pattern already proven on 12 events (C-70 ↔ events-catalog).

`meta.status_authority` names the one place `owner` and `governance_status` may come from.
Every entry repeats it in `status_source`, and the gate fails when any entry names a
different one — or carries a bare `status` field, which is what the DX copy was called.
A declared consumer must assert `stores_status: false`. The remaining checks are the
ordinary ones: required fields, unique `cap_id`, `binds_to` resolving to a real C-doc,
`governance_status` inside the C-94 lifecycle, deterministic ranks.

**The gate was proved to fail before it was trusted** — five deliberate breakages, each
caught: a second `status_source`, a re-introduced bare `status`, a consumer storing its
own copy, a status off the lifecycle, a dangling `binds_to`. *(A test file that cannot
fail is worse than no file — the same lesson this session already learned in jest.)*

Preflight: **21/21**. The new gate needed no edit to `scripts/preflight.sh` — it parses
the gate list out of the workflow, so adding the CI job was enough. That is the design
working as intended, one session after it was written.

### Honest status

- `[Code Verified]`, not `[Runtime Verified]`: #309 is merged but the fix reaches users
  only when `tec-identity-service` redeploys. **No schema change** — so no `db push`, and
  none of Session 56c applies here.
- **The dead columns are still there.** `DxCapability.owner` / `.status` (+ `DxCapStatus`)
  are still written by the DX seed and read by nothing. Expand-contract says stop reading
  first, drop later; the contract half is recorded in the manifest under
  `deprecated_copies` and remains an open follow-up.

### Phase 1 status

- **1.1 collapse the duplicate registry** ✅ (#309) · **1.2 manifest + CI gate** ✅ (this PR)
- **1.3 `/api/ready` separate from `/api/health`** ☐ next — template first, then the fleet.
  Health stays fail-safe and never 500s (NEW-W); ready is allowed, and required, to fail.
- Open, unchanged: Mainnet App Wallet under review · `PI_A2U_FEE` unset · the
  `wallet_address` re-consent is still uncollected.
