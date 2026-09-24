# SESSION 56b — the four runtimes: what they actually are, and the order to build them

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> **▶ THE ACTIVE PLAN LIVES IN `audits/FOUR_RUNTIMES_BUILD_ORDER_2026-09-13.md`.**
> It carries a STATUS table that is updated in the same PR as the work. Read it before
> starting anything in DX · Analytics · Nexus · TEC AI · NEXUS IIC.
> **Next action: merge tec-core-backend #306 · tec-app #234 · KB #137.**

A strategy round proposed a new primitive — **NEXUS IIC, an Intent Integrity Compiler** —
plus platform-layer upgrades to DX, Analytics, Nexus and TEC AI, and a SoloHost
distribution channel. Five documents came out of reading the **code** against those
proposals rather than the charters.

| Document | What it settles |
|---|---|
| `audits/NEXUS_IIC_v0.1_SPEC_2026-09-13.md` | The specification: Intent Object, delta, lineage, gate, proof |
| `audits/NEXUS_IIC_ENGINEERING_REPORT_2026-09-13.md` | What the five runtimes actually are, and the bottleneck |
| `audits/FOUR_RUNTIMES_ENGINEERING_REPORT_2026-09-13.md` | Registry drift · the generator argument · Alert's boundary |
| `audits/SOLOHOST_TEC_AI_DX_ENGINEERING_REPORT_2026-09-13.md` | The verified SoloHost contract and what it forbids |
| `audits/FOUR_RUNTIMES_BUILD_ORDER_2026-09-13.md` | **The plan + live status** |

### The five findings that decide everything else

**1. The right-hand half of the proposed pipeline is already built.**
`tec-identity-service/src/modules/nexus/` is a persisted saga engine — ordered steps,
compensation in reverse, an honest halt at every U2A payment, an idempotent resume from
`payment.completed.v1`. And the proposal's central claim — *the LLM proposes, it never
authorizes* — is **C-47, enforced by a CI job.** Most teams pitching an agent-trust layer
are proposing to build that. **So: NEXUS IIC is Nexus V2 (C-109 §10 Phase 2), not a 25th
app** — roughly 60% built, and the missing 40% is the part that is actually novel.

**2. …but Nexus does not call any service yet.** `NexusStep.service` is *"the owning
service that WOULD execute it."* **There is no external side effect for an execution gate
to gate.** A gate built now would pass every test because nothing on the other side can
fail — which is exactly how the A2U payout path shipped unable to pay anyone. **This is
the bottleneck, and it is chartered work, not new scope.**

**3. Three of the five are not runtimes.** DX and SYSTEM are **read-only seeded catalogs**
and say so in their own source (*"API-key issuance … NOT modeled here"* · *"there is NO
write method here, by design"*). TEC AI is advisory (*"Nothing executes on these"*). So
**SYSTEM cannot answer an authority question at runtime** and must stay off the gate's
decision path; Analytics is eventually consistent and must inform the intent at compile
time, never inside the gate.

**4. The capability registry exists TWICE and has already drifted.** `dx.service.ts` and
`system.service.ts` each hand-maintain the same five ids, two models, two enums,
descriptions that already differ, nothing syncing them — **P2, live on `main`.** Enriching
the DX copy would give the drifting duplicate the fields an agent would *act* on.

**5. A SoloHost package can hold no TEC secret.** Verified against
`github.com/pi-node/solohost`: the image is **public** and answers land in a **plaintext
`.env` on the user's machine**. The `hidden` field type hides a value from the installer
UI, **not from the user**. So the SoloHost edition is a different product —
**bring-your-own-key / local model, no Hub session** — which costs TEC nothing per user
and matches where Pi is going (OpenClaw, MCP, local AI).

### Two corrections to the strategy, worth keeping

- **The App Builder solves the wrong problem.** All 24 apps were cloned from
  `tec-template-base`; they diverged because fixes could not **travel** (Session 46: 18
  apps frozen on `^1.1.0`, 112 unmergeable PRs, 15 placeholder app names), not because
  they started differently. A generator improves day 1 and worsens day 400 — generated
  code is a fork at birth. **Build `dx doctor` (conformance) instead: it works on the 24
  apps that already exist.** The rule: **generate what is thrown away, template what is
  lived in** — which is also why a SoloHost *package* generator is fine.
- **Truth State: the observation was right, the conclusion inverts.** DX and SYSTEM
  carrying `[Future Vision]` is **correct** — the deployed part is a slice, not the claim.
  Nexus is the one mis-stated, in the opposite direction. Fix with per-doc
  `Implementation Status` (the v3.12.0 pattern), not by unifying upward.

### The order, in one line each

```
PHASE 0  truth       merge · re-consent reaches Mainnet users · 3 status sections
PHASE 1  one source  capability registry → manifest + gate · /api/ready
PHASE 2  bottleneck  Nexus steps CALL their services          ◄── everything waits
PHASE 3  the four    Nexus history · Analytics→Alert · AI intents · DX console
PHASE 4  invention   4.1/4.2 are pure — startable TODAY, zero risk
PHASE 5  SoloHost    BYO-key · secret-leak gate · one package
```

> **Phase 0 is the answer to "how does the project get strong."** The rest make it
> capable; Phase 0 makes it honest, it is the cheaper of the two, and it is the only one
> where being late costs something today.

**Shaped by one constraint, stated as a design input rather than an apology:** one person
builds this, with an AI, merging from a phone. Small serial PRs, one verification each —
never four parallel workstreams.
