# C-83 — ECONOMIC VISUAL LANGUAGE (EVL) & ECONOMIC STATE LANGUAGE (ESL)

## TEC Ecosystem — Design Governance Constitution

> Status: DRAFT — Post-Portal Implementation
> Authority: Platform Design Governance
> Scope: All 24 apps, shared UI packages, design tokens
> Version: 2.0 — June 2026
> Priority: Strategic Design Layer
> Truth State: [Planned State] | Governance State: [Draft] | Verification: [Unverified]
> Authority Scope: [Platform]

---

> ## ⚠️ RECONCILIATION WITH CURRENT RUNTIME (read first)
>
> **C-83 is a `[Planned State]` / `[Draft]` / `[Unverified]` target — it is NOT the
> live design system.** The words "IMMUTABLE" and "No app may override" below describe
> the EVL **end-state**, not today's runtime.
>
> **The single source of truth for the CURRENT live tokens is the code:**
> `@yasser172/tec-ui → src/theme.ts` (Code-Verified, used by all 4 apps today):
>
> | Token | C-83 EVL target (planned) | **Live now (`tec-ui/theme.ts`)** |
> |-------|---------------------------|----------------------------------|
> | gold / WEALTH | `#FBBF24` | **`#d4af37`** |
> | primary background | `#050816` | **`#020205`** |
> | surface | `#0B1020` | **`#0d0d14`** |
>
> Per the Authority Hierarchy (`… → Code`), code wins for *current* reality; C-83 is
> authoritative only for the *planned* EVL migration. The `design/tec-design-system`
> and `design/ui-patterns` skills correctly mirror the **live** tokens (`#d4af37`) and
> **must not** be edited to the EVL values in isolation.
>
> **Adopting EVL is a coordinated breaking change** (tec-ui `TEC_COLORS` is a contract —
> tec-ui R5): tec-ui **major version bump** → simultaneous deploy of all 4 apps → skills
> updated **last, together with the code**. Until that ships, there is **no conflict** —
> only a documented future target that differs from the present.

---

# 1. PHILOSOPHY

TEC IS NOT:
- a crypto app
- a gaming interface
- a dashboard

TEC IS:
An Economic Coordination Platform.

The interface communicates:
```
Stability | Trust | Precision | Operational clarity | Financial confidence
```

Target feel:
```
Stripe × Linear × Apple Wallet × Bloomberg Terminal
```

NOT:
```
Neon-heavy Web3 | Crypto casinos | NFT marketplaces
```

## Core Distinction

```
OLD (forbidden): color = aesthetic choice
NEW (required):  semantic = economic meaning → runtime resolves color + motion + shape + elevation

❌ color="gold"
✅ semantic="wealth"
```

---

# 2. ECONOMIC ONTOLOGY — PLATFORM PRIMITIVES

```
IDENTITY     — who the user is
WEALTH       — what the user owns
GROWTH       — what the user earns / spends
INTELLIGENCE — what the user knows / sees
RISK         — what threatens the user
GOVERNANCE   — what governs the platform
```

These are Platform Primitives — not colors. Colors are a runtime consequence.

---

# 3. SEMANTIC PRIORITY MATRIX

When domains conflict — this hierarchy wins:

```
P0 — RISK         (always overrides — danger is always visible)
P1 — GOVERNANCE   (platform authority)
P1 — IDENTITY     (who you are)
P2 — WEALTH       (what you own)
P2 — GROWTH       (activity)
P3 — INTELLIGENCE (data / analytics)
```

Rule: Higher priority domain overrides lower visually. P0 RISK always wins — no exceptions.

---

# 4. BACKGROUND LAYERS (IMMUTABLE)

```css
--tec-bg:        #050816;   /* Layer 1 — Primary Background */
--tec-surface:   #0B1020;   /* Layer 2 — Surface            */
--tec-surface-2: #111627;   /* Layer 3 — Card / Elevated    */
```

No app may override. No user may change.

---

# 5. SEMANTIC COLOR SYSTEM

```css
--tec-purple: #8B5CF6;  /* IDENTITY     */
--tec-gold:   #FBBF24;  /* WEALTH       */
--tec-green:  #22C55E;  /* GROWTH       */
--tec-cyan:   #06B6D4;  /* INTELLIGENCE */
--tec-red:    #EF4444;  /* RISK         */
--tec-blue:   #3B82F6;  /* GOVERNANCE   */
```

---

# 6. THE 6 ESL DOMAINS

| Domain | Color | Shape | Motion | Apps |
|--------|-------|-------|--------|------|
| IDENTITY | #8B5CF6 | Circle | Flow | Hub, Connection |
| WEALTH | #FBBF24 | Hexagon | Pulse | Assets, Wallet, FundX |
| GROWTH | #22C55E | Triangle Up | Upward | Commerce, Ecommerce |
| INTELLIGENCE | #06B6D4 | Grid | Scan | Analytics, Life, Explorer |
| RISK | #EF4444 | Triangle Alert | Flash | All (P0 override) |
| GOVERNANCE | #3B82F6 | Diamond | Stable | Hub (admin), Titan, Nexus |

---

# 7. APP IDENTITY LAYER

| App | Primary | Secondary |
|-----|---------|----------|
| Hub | Identity | Governance |
| Assets | Wealth | Identity |
| Commerce | Growth | Wealth |
| Ecommerce | Growth | — |
| Life | Intelligence | Growth |
| Connection | Identity | — |
| Analytics | Intelligence | Governance |
| FundX | Wealth | Risk |
| Nexus | Governance | Intelligence |
| Titan | Governance | Growth |
| Explorer | Intelligence | Growth |

Rules:
```
✅ One PRIMARY domain per app
✅ One SECONDARY domain allowed
❌ No three domains simultaneously dominant
❌ No user-defined theme overrides
```

---

# 8. SEMANTIC COMPONENT API

## Phase 1 — CSS Variables (tec-ui v1.2.0)
> Truth State: [Planned State] | Commitment: [Committed] | Verification: [Unverified — not yet implemented]
```css
.card-wealth {
  border-color: var(--tec-gold);
  box-shadow:   var(--tec-glow-gold);
}
```

## Phase 2 — Semantic Props (Post-Portal)
```tsx
<Card primary="wealth" secondary="identity" />
```

## Phase 3 — Runtime Semantics (Post-Scale)
```tsx
<Card primary="wealth" secondary="identity" riskLevel="none" confidence="high" />
```

---

# 9. GLOW SYSTEM

```css
--tec-glow-purple: 0 0 20px rgba(139,92,246, 0.5);
--tec-glow-gold:   0 0 20px rgba(251,191,36,  0.5);
--tec-glow-green:  0 0 20px rgba(34,197,94,   0.5);
--tec-glow-cyan:   0 0 20px rgba(6,182,212,   0.5);
--tec-glow-red:    0 0 20px rgba(239,68,68,   0.5);
--tec-glow-blue:   0 0 12px rgba(59,130,246,  0.3); /* reduced — governance = institutional */
```

---

# 10. TYPOGRAPHY SEMANTICS

```
Sora (700)      → Authority, Headlines, Platform-level
Inter (400/500) → Operational clarity, Body text
Space Mono      → Financial truth, Numbers, Pi amounts, Transaction IDs
```

Rule: Pi amounts ALWAYS Space Mono. Never Sora or Inter.

---

# 11. SEMANTIC ELEVATION

```css
--tec-elevation-passive:  0 1px  4px  rgba(0,0,0,0.2);
--tec-elevation-active:   0 4px  16px rgba(0,0,0,0.35);
--tec-elevation-modal:    0 8px  32px rgba(0,0,0,0.5);
--tec-elevation-critical: 0 12px 48px rgba(239,68,68,0.3);
```

---

# 12. ECONOMIC DENSITY RULES

```
Max semantic domains visible simultaneously: 3
Max glow sources in one viewport:           2
Max animated elements at once:              1
```

---

# 13. ECONOMIC PHYSICS — IMMUTABLE LAWS

```
wealth   ≠ danger    (gold never used for errors)
danger   ≠ premium   (red never used for PRO features)
identity ≠ economy   (purple never used for earnings)
risk     ≠ success   (red never on growth contexts)
```

---

# 14. TYPESCRIPT TYPES (Phase 1 — tec-ui v1.2.0)
> Truth State: [Planned State] | Commitment: [Committed] | Verification: [Unverified]
> SemanticDomain type and resolveDomain() are NOT yet in npm package

```typescript
export type SemanticDomain =
  | 'identity' | 'wealth' | 'growth'
  | 'intelligence' | 'risk' | 'governance';

export type SemanticPriority = 0 | 1 | 2 | 3;

export const DOMAIN_PRIORITY: Record<SemanticDomain, SemanticPriority> = {
  risk: 0, governance: 1, identity: 1,
  wealth: 2, growth: 2, intelligence: 3,
};

export const resolveDomain = (
  primary: SemanticDomain,
  event?:  SemanticDomain,
): SemanticDomain => {
  if (!event) return primary;
  return DOMAIN_PRIORITY[event] <= DOMAIN_PRIORITY[primary] ? event : primary;
};
```

---

# 15. PACKAGE ARCHITECTURE

```
Phase 1 — tec-ui v1.2.0 (NOW)
  CSS variables (design tokens)
  SemanticDomain type
  Basic glow utility classes

Phase 2 — Post-Portal
  @tec/evl-core    ← Semantic Engine (Gate A required)

Phase 3 — Post-Scale (5+ apps using semantic layer)
  @tec/motion + @tec/icons
```

Gate rule: Do NOT publish @tec/evl-core until Gate A PASSED.

---

# 16. VIOLATION RULES

| Violation | Severity |
|-----------|----------|
| Hardcoded color in component | P2 |
| Risk doesn't override Wealth | P1 |
| User can override brand core | P1 |
| Economic Physics violated | P1 |
| Governance uses Web3/DAO aesthetic | P2 |
| Financial amount not in Space Mono | P2 |
| 3+ domains simultaneously dominant | P2 |

---

# FINAL STATEMENT

```
Color is style.
Semantics is meaning.
Meaning builds trust.
Trust builds economy.
```
