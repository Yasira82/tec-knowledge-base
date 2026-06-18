# C-95 — Institutional Knowledge Constitution

> **Version:** v1.0
> **Truth State:** `[Speculation]`
> **Governance State:** `[Draft]`
> **Verification State:** `[Unverified]`
> **Authority Scope:** `[Platform]`
> **Decision Status:** `[Recommended]`
> **Commitment Level:** `[Exploratory]`

---

## Purpose

Define how verified institutional state becomes institutional knowledge.

**C-93 defines:**
How reality becomes verified institutional state.

**C-95 defines:**
How verified institutional state becomes institutional knowledge.

**C-94 defines:**
How institutional knowledge becomes executable capability.

---

## Constitutional Question

How does TEC transform verified institutional state into actionable knowledge?

---

## Core Constitutional Principle

```
Institutional State does not equal Knowledge.

Institutional State answers: What is verified?
Knowledge answers: What is true, and why?

Institutional State → Knowledge → Capability
```

---

## Constitutional Rules

```
Unverified State cannot become Knowledge.
Knowledge without Classification   = Ambiguity
Knowledge without Versioning       = Drift
Knowledge without Ownership        = Orphaned Truth
Knowledge without Supersession     = Contradiction
Knowledge without Authority        = Unchecked Claims
Outdated Knowledge = Institutional Liability
```

---

## What C-95 Owns

| Asset | Description |
|-------|-------------|
| Knowledge Base | System of Knowledge |
| Knowledge Registry | Catalog of all institutional knowledge artifacts |
| Knowledge Lifecycle | Proposed → Approved → Active → Superseded → Archived |
| Knowledge Versioning | Every knowledge artifact must carry a version |
| Knowledge Classification | Type, scope, authority level |
| Knowledge Authority | Who may create, approve, supersede |
| Knowledge Supersession | How outdated knowledge is retired |

---

## Knowledge Transformation Model

```
Institutional State (verified — from C-93)
  ↓
Knowledge Extraction
  ↓
Classification
  ↓
Authority Assignment
  ↓
Knowledge Registry Entry
  ↓
Active Knowledge
  ↓
Capability Input (C-94)
```

---

## Knowledge Types

### Architectural Knowledge
ADRs, C-Series constitutions, architectural standards, patterns.

### Governance Knowledge
Policies, rules, authority boundaries, delegation constraints.

### Operational Knowledge
Runtime patterns, incident learnings, SLOs, runbooks.

### Economic Knowledge
Payment models, settlement rules, Pi transaction patterns.

### Security Knowledge
Threat models, security policies, audit findings, control standards.

### Historical Knowledge
Decision lineage, postmortems, superseded patterns — lives in C-96.

---

## Knowledge Lifecycle

| Stage | Name | Entry Condition |
|-------|------|-----------------|
| 1 | **Proposed** | A claim exists — not yet verified |
| 2 | **Under Review** | Verification in progress (C-93 process) |
| 3 | **Approved** | Verified + governance-approved |
| 4 | **Active** | In use — informing capabilities |
| 5 | **Superseded** | Replaced by newer knowledge — kept for lineage |
| 6 | **Archived** | Retired — moved to Institutional Memory (C-79) |

> Unverified claims may not enter Active state.

---

## Knowledge Authority

| Role | Responsibility |
|------|---------------|
| **Knowledge Author** | Proposes new knowledge artifacts |
| **Verification Owner** | Validates against C-93 verification process |
| **Knowledge Authority** | Approves entry into Active state |
| **Governance Owner** | Ratifies high-authority knowledge (constitutions, ADRs) |

> The Knowledge Base (C-Series + ADRs + Governance docs) is the canonical Knowledge Registry.

---

## Knowledge vs. Institutional State

| Concept | Answers | Lives in |
|---------|---------|---------|
| Institutional State | What is currently verified? | C-93 Institutional State Registry |
| Knowledge | What is true, classified, and usable? | C-95 Knowledge Registry (KB) |
| Memory | Why is it true? What led here? | C-79 Institutional Memory |

> These three are distinct. Conflating them causes governance drift.

---

## Knowledge Supersession Protocol

When knowledge is superseded:

1. New knowledge must be verified (C-93)
2. Old knowledge is marked `Superseded` with a pointer to the replacement
3. Lineage is preserved in Institutional Memory (C-79)
4. Capabilities built on superseded knowledge enter **Review Mode**
5. Governance Owner must ratify supersession of constitutional-level knowledge

---

## Knowledge and TEC AI

TEC AI **may:**
- Retrieve knowledge
- Explain knowledge
- Cross-reference knowledge artifacts
- Detect knowledge gaps
- Recommend knowledge updates

TEC AI **may NOT:**
- Author Active knowledge without verification
- Supersede existing knowledge autonomously
- Bypass knowledge authority

---

## Knowledge and DX

DX **may:**
- Package knowledge as templates and reference implementations
- Distribute knowledge through SDKs and generators

DX **may NOT:**
- Create constitutional-level knowledge without governance approval

---

## Constitutional Mapping

| System | Role |
|--------|------|
| Knowledge Base (C-Series, ADRs, Governance docs) | System of Knowledge |
| C-93 Institutional State Registry | Feeds verified state into knowledge |
| C-94 Governed Capability Registry | Consumes knowledge as capability input |
| C-79 Institutional Memory Registry | Archives superseded knowledge |

---

## Tier-1 Constitutional Position

| Document | Defines |
|----------|---------|
| **C-93** Institutional Verification Constitution | How reality becomes institutional legitimacy |
| **C-95** Institutional Knowledge Constitution | How institutional state becomes institutional knowledge |
| **C-94** Governed Capability Constitution | How institutional knowledge becomes executable capability |

---

## Architectural Conclusion

```
Verification produces Institutional State.
Institutional State informs Knowledge.
Knowledge is classified, versioned, and owned.
Knowledge feeds Capabilities.
Outdated Knowledge is superseded and archived.

The Knowledge Constitution ensures institutional truth
is traceable, governable, and evolvable.
```

---

## Related Documents

```
C-00  Platform Constitution
C-47  Kernel Spec & Architecture Binding
C-67  Source of Truth Matrix
C-93  Institutional Verification Constitution (upstream)
C-94  Governed Capability Constitution (downstream)
C-79  Institutional Memory Constitution (archival layer)
C-64  Architecture Decision Records (primary Knowledge Registry entries)
```

---

*End of C-95 v1.0*
