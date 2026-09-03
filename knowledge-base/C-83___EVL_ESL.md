# C-83 — ECONOMIC VISUAL LANGUAGE (EVL) & ECONOMIC STATE LANGUAGE (ESL)

## TEC Ecosystem — Design Governance Constitution

> Status: DRAFT — Post-Portal Implementation
> Authority: Platform Design Governance
> Scope: All 24 apps, shared UI packages, design tokens
> Version: 2.0 — June 2026
> Priority: Strategic Design Layer
> Truth State: [Planned State] | Governance State: [Draft] | Verification: [Assumed]
> Authority Scope: [Platform]

---

> ## ✅ RUNTIME STATUS — EVL COLOR TOKENS ADOPTED, WEALTH NOW THE Pi AMBER (read first)
>
> **The EVL color system is the LIVE identity**, adopted in `@yasser172/tec-ui` **v2.0.0**
> and moved to the **Pi amber** in **v3.0.0** (`src/theme.ts`, Code-Verified). The
> color-token half of C-83 is `[Current State]`:
>
> | Token | C-83 EVL (v2) | **Live now (`tec-ui` v3.0.0)** | Status |
> |-------|---------------|--------------------------------|--------|
> | gold / WEALTH | `#FBBF24` | **`#FBB44A`** | ✅ re-sampled in v3.0.0 (was `#FBBF24`, was `#d4af37`) |
> | goldDark | `#F59E0B` | **`#E8962A`** | ✅ moved with WEALTH |
> | goldLight | `#FCD34D` | **`#FDCF7A`** | ✅ moved with WEALTH |
> | primary background | `#050816` | **`#050816`** | ✅ adopted (was `#020205`) |
> | surface | `#0B1020` | **`#0B1020`** | ✅ adopted (was `#0d0d14`) |
> | surface-2 / semantic (purple/green/cyan/red/blue) | per §4–§5 | **present** | ✅ unchanged by v3 |
>
> ### Why WEALTH moved again (v3.0.0, Aug 2026)
>
> `#FBBF24` is Tailwind's generic amber-400. `#FBB44A` is sampled **from the Pi app
> itself** — it is the colour of its splash mark — so a TEC app sitting beside Pi Browser
> chrome reads as part of the same product instead of a near-miss of it. Every TEC app
> lives inside that chrome, so the accent is not a free aesthetic choice.
>
> **v3.0.0 is a MAJOR bump with nothing renamed or removed** — only token VALUES move, so
> no consumer fails to compile. That is exactly why it is dangerous and why it is a major:
> the change is invisible to the type checker and total on screen.
>
> ### Load-bearing constraint — every token stays a plain 6-digit hex
>
> Consumers append alpha to these strings (`` `1px solid ${TEC_COLORS.gold}33` ``, 216
> places across the fleet). A `var(--tec-gold)` in this object would render
> `var(--tec-gold)33`: invalid CSS, **no error**, and a border that silently stops
> painting everywhere at once. Theme-aware colour belongs in a CSS custom property the
> **app** owns, never in the package's constant — one constant cannot hold both the
> dark-ground amber and the deeper `#FEA500` a light theme needs.
> `tec-ui/src/__tests__/theme-contract.test.ts` pins this.
>
> ### An app paints from TWO sources — bumping the package alone makes it WORSE
>
> Verified on Tec-Zone before the Session 46 sweep: with only the package bumped, the
> running page carried **`#050816` and `#020205` at the same time**, and two golds. An app
> reads `TEC_COLORS.*` in inline styles **and** `var(--tec-*)` from its own
> `src/styles/tec-design-tokens.css`. **The package bump and the app's local token sweep
> are one change, never two.**
>
> **What is STILL `[Planned]`:** the rest of EVL — CSS-variable layer (§ Phase 1),
> TypeScript domain types, **shapes**, **motion**, and the **ESL** state language.
> Those sections below keep their `[Planned State]` markers.
>
> **App adoption: COMPLETE for 23 of 26 repos** (Session 46) — Hub + the 20 domain apps +
> NBF + Brookfield are on `^3.0.0` with their local palettes swept to match.
> **Deliberately excluded:** `tec-assets` (104 hardcoded hexes), `tec-commerce` (149),
> `tec-ecommerce` (202) — these barely consume `TEC_COLORS`, so moving them is a re-skin,
> not an upgrade, and is a separate decision. Per tec-ui R5 the adopters deploy together;
> a staggered deploy puts two palettes on screen at once.
> Evidence/lineage: tec-ui v2.0.0 → v3.0.0 (tec-ui #22).

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

> ### ⚠️ SUPERSEDED BY §5.6 — these are the OLD blue-black values
>
> The Hub no longer paints `#050816`. It moved to a **neutral** charcoal ramp
> (`#101014 / #21212a / #2c2c37 / #383844`) and that is what ships. This block was
> never updated, so it declares "IMMUTABLE" over three values the reference
> implementation stopped using — which is worse than saying nothing, because an app
> reading it adopts the wrong ground in good faith. **§5.6 is the authority.**
>
> Kept, not deleted: 21 apps still run these values, so this is what most of the fleet
> looks like today. The *structure* — three layers, apps do not invent their own — is
> still right. Only the numbers moved.

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
--tec-gold:   #FBB44A;  /* WEALTH       */  /* Pi splash amber — v3.0.0 (was #FBBF24) */
--tec-green:  #22C55E;  /* GROWTH       */
--tec-cyan:   #06B6D4;  /* INTELLIGENCE */
--tec-red:    #EF4444;  /* RISK         */
--tec-blue:   #3B82F6;  /* GOVERNANCE   */
```

---

# 5.5 THEME STATES — THE LIGHT PALETTE, THE CHANNELS, AND THE BAND

> Truth State: [Current State] | Governance State: [Draft] | Verification: [Code Verified]
> Authority: `tec-app/tec-frontend/src/styles/tec-design-tokens.css` (the Hub is the
> reference implementation). Adopted: Hub · Explorer · Connection. Not yet: the other 21 apps.

Sections 4 and 5 above define the **dark** ground, and for a long time that was the
only ground there was. It is no longer: the Hub ships a light theme and the apps are
adopting it. **These values were live in the Hub for months and written down nowhere**,
which is exactly how the fleet drifts — a rule exists, one repo follows it, and the
next app re-derives it slightly differently (see C-02 Session 46, and §5.5.3 below,
which is that mistake happening again).

## 5.5.1 Three states, not two

| State | Expressed as | Meaning |
|-------|--------------|---------|
| dark | `[data-theme='dark']` | the reader chose dark |
| light | `[data-theme='light']` | the reader chose light |
| **system** (default) | **the ABSENCE of the attribute** | follow the phone, live |

`system` is a real choice and it is the default. It is the absence of the attribute so
the media query keeps tracking — resolving it in JS would freeze the page at whatever
the phone happened to be at first launch.

The media query **MUST** be scoped `:root:not([data-theme])`. Unscoped, a light phone
silently overrules a reader who explicitly picked dark, and they have no way to tell
the setting is being ignored.

`color-scheme` is stamped on `<html>` by an inline boot script in `<head>`, never
pinned in CSS or in a `<meta>`. Pinned to `dark` it gave light mode dark scrollbars and
dark form controls. Deferred instead of inline, the page paints dark and **snaps** to
light on every load.

## 5.5.2 The light palette (authority)

```css
[data-theme='light'] {
  --tec-bg:          #f4f3f1;   /* Layer 1 */
  --tec-surface-1:   #ffffff;   /* Layer 2 */
  --tec-surface-2:   #f1efec;   /* Layer 3 */
  --tec-surface-3:   #e7e4df;
  --tec-border:      rgba(0,0,0,0.09);

  --tec-gold:        #FEA500;   /* the WEALTH amber, measured on white */
  --tec-gold-dark:   #E08800;
  --tec-gold-light:  #FFC04D;
  --tec-gold-rgb:    254, 165, 0;

  --tec-text-1:      rgba(0,0,0,0.90);
  --tec-text-2:      rgba(0,0,0,0.62);
  --tec-text-3:      rgba(0,0,0,0.42);
  --tec-text-rgb:    0, 0, 0;
  --tec-fill-soft:   rgba(0,0,0,0.05);
}
```

**The amber deepens on white.** `#FBB44A` is sampled from the Pi splash mark and carries
a dark page; on white it is a pale wash that fails both as text and as a border.
`#FEA500` is Pi's own *"Welcome to Pi"* headline amber — the same brand measured on a
light ground. Which one is in play is a THEME decision and lives in the token file.

## 5.5.3 A token is a FAMILY, not a value — the mistake this section exists to stop

Overriding `--tec-gold` alone is not a theme, it is half of one.

Connection and Explorer did exactly that. The gradient companions stayed on their
dark-ground values, so every primary button in light mode ran `#FEA500 → #E8962A` —
and `#E8962A` (R232 G150 B42) was chosen to sit on near-black, so it carries a
desaturated brown cast that reads as a **dirty dark patch** on the light half of a
button. Twenty-six buttons in one app. It looked like the gradient was broken rather
than a token being unset.

Worse, the repair **re-derived** `#F08C00`/`#FFC24D` instead of copying the Hub's
`#E08800`/`#FFC04D` — because the Hub's values were not written down anywhere. Two
apps a shade apart on the same button, from one undocumented number. That is why this
section exists, and why the table above is the authority rather than a description.

> **Rule.** A theme block overrides every member of a family it touches, and it copies
> the authority rather than choosing a near-match.
> Enforced by `theme.test.ts`, which DERIVES the gold family from `:root` and asserts
> the light block covers every member — derived rather than listed, so a new token is
> covered the day it is added.

## 5.5.4 Status colours DARKEN on white — contrast, not taste

The §5 semantic colours were picked to glow on near-black and **fail as text on white**:

| Domain | Dark | on white | Light | on white |
|--------|------|---------:|-------|---------:|
| GROWTH | `#22C55E` | ~2.3:1 ❌ | `#15803d` | ~5.0:1 ✅ |
| RISK | `#EF4444` | ~3.3:1 ❌ | `#b91c1c` | ~5.9:1 ✅ |
| GOVERNANCE | `#3B82F6` | ~3.1:1 ❌ | `#1d4ed8` | ~6.3:1 ✅ |
| IDENTITY | `#8B5CF6` | ~3.5:1 ❌ | `#6d28d9` | ~6.7:1 ✅ |

The **meaning** does not change with the theme — green still means GROWTH — only the
luminance does. The channel tokens move with them (`--tec-green-rgb`), or every
`rgba(var(--tec-green-rgb), …)` keeps painting the bright one.

## 5.5.5 Channels — and the silent failure they exist to prevent

```css
--tec-gold-rgb: 251, 180, 74;   --tec-text-rgb: 255, 255, 255;
--tec-bg-rgb:   5, 8, 22;       --tec-green-rgb / --tec-red-rgb
```

An app that wants a colour at partial opacity used to append two hex digits to a hex
string. Pointed at a variable that yields **`var(--tec-gold)33`: invalid CSS that
raises NO error** — the declaration is dropped and the border silently stops painting.

The channels let `rgba(var(--tec-gold-rgb), .2)` follow the theme instead. This is the
same constraint §"load-bearing" states for the package: `TEC_COLORS.*` stays plain hex
because consumers append alpha to it; theme-aware colour belongs in a CSS custom
property the **app** owns.

**Four shapes of this bug have shipped**, each past a guard written for the last one:

```
`${C.gold}22`                     an interpolated token
`${(v ? C.gold : C.subtext)}55`   an expression, not a bare member
C.subtext + '55'                  concatenation, no template at all
'1px solid ${goldA(0.25)}'        a placeholder inside SINGLE quotes — a literal
rgba(5,8,22,0.92)                 a raw colour, matching none of the above
```

> A guard that knows only the shapes of the bugs already found finds each bug once.

## 5.5.6 The top band

Every inner page is framed by a solid band with rounded **bottom** corners. Without it
an inner page opens on exactly the same flat ground as the one before, and tapping
through feels like nothing happened.

```css
--tec-topbar:        #3f311f;   /* dark: ~20% gold mixed into the page */
--tec-topbar-radius: 22px;
--tec-topbar-ink-1 / -ink-2 / -ink-3 / -gold / -fill / -border
```

`[data-theme='light']` sets `--tec-topbar: #17171d`. **The band is dark in BOTH themes** —
which is the part that needs care: a control inside it reads the *page* palette, so on
a light page it paints black ink and a white surface onto a near-black band and
disappears.

`.tec-on-band` **re-scopes the tokens for that subtree** rather than restyling each
control, so a component dropped into the header is correct without knowing the band
exists. That is the only version of this that stays true after the next change.

## 5.5.7 Two exemptions, both structural

Hex literals are correct in exactly two places, and neither is a shortcut:

- **`sso-callback/route.ts`** — plain HTML served *before any stylesheet*; it cannot
  read a custom property at all.
- **`opengraph-image.tsx`** (`next/og`) — Satori resolves no custom properties, and a
  share card is a cached server-composed image with no reader whose theme it could follow.

A `<meta name="theme-color">` is a third: it is read by the browser's own chrome,
outside the document's style resolution. Give it one per scheme instead.

**Do not "fix" any of these into `var()`.**

---

# 5.6 THE NEUTRAL RAMP — GREYS, BLACK, OFF-WHITE, AND THE RADII

> Truth State: [Current State] | Governance State: [Draft] | Verification: [Code Verified]
> Authority: `tec-app/tec-frontend/src/styles/tec-design-tokens.css`.
> Adopted: **Hub only.** The other 23 apps are on the §4 blue-black. Adopting this is a
> deliberate per-app change, not a sweep — see §5.6.5.

§4 declares a blue-black ground. The Hub does not paint it any more, and this is the
ramp it actually ships. Recorded here because **it is going into every app**, and the
last time a fleet value lived only in the Hub two apps re-derived it wrong within a week
(C-02 Session 50.1).

## 5.6.1 Dark — a NEUTRAL charcoal, not a blue-black

```css
--tec-bg:        #101014;   /* Layer 1 — the page */
--tec-surface-1: #21212a;   /* Layer 2 — a card */
--tec-surface-2: #2c2c37;   /* Layer 3 — a tile inside a card */
--tec-surface-3: #383844;   /* Layer 4 — raised, or pressed */
--tec-border:    rgba(255,255,255,0.07);
```

**Why neutral.** `#050816` is a blue-black: it reads as *cold*, and beside the Pi amber
it pushes the amber green. `#101014` is very nearly neutral (R16 G16 B20 — four points
of blue, enough to avoid a dead grey, not enough to tint). The amber sits on it as the
same amber the Pi app shows.

**Why four layers and not three.** §4 stopped at three, so "pressed" had nowhere to go
and every app improvised it — usually by appending alpha to something, which is the
`var(--tec-gold)33` failure in another costume. Four layers means elevation is a token.

**The steps are deliberate, roughly +11 in lightness each.** Two adjacent surfaces must
be distinguishable on a phone in daylight without a border doing the work. `#21212a` on
`#101014` is visible unaided; a 4-point step is not.

## 5.6.2 Light — an OFF-WHITE page, a white card

```css
--tec-bg:        #f4f3f1;   /* Layer 1 — the page: off-white, WARM */
--tec-surface-1: #ffffff;   /* Layer 2 — a card: pure white */
--tec-surface-2: #f1efec;   /* Layer 3 */
--tec-surface-3: #e7e4df;   /* Layer 4 */
--tec-border:    rgba(0,0,0,0.09);
```

**The page is off-white and the card is white — that order, not the reverse.** A pure
white page with a grey card is the default every framework gives you and it inverts the
elevation model: the thing you are meant to look at ends up *darker* than its ground.
Here the card lifts off the page, the same way `--tec-surface-1` lifts off `--tec-bg`
in dark.

**It is WARM off-white** (`#f4f3f1`, R244 G243 B241), not a cool `#f8f8fc`. The ramp
runs warmer as it darkens (`#f1efec` → `#e7e4df`) because the accent is amber; a cool
grey ramp under a warm accent reads as two designs.

## 5.6.3 The ink ladder — four steps, plus icons

| Token | Dark | Light | Use |
|-------|------|-------|-----|
| `--tec-text-1` | `rgba(255,255,255,0.92)` | `rgba(0,0,0,0.90)` | body, headings |
| `--tec-text-2` | `rgba(255,255,255,0.62)` | `rgba(0,0,0,0.62)` | secondary, captions |
| `--tec-text-3` | `rgba(255,255,255,0.38)` | `rgba(0,0,0,0.42)` | labels, timestamps |
| `--tec-text-4` | `rgba(255,255,255,0.25)` | `rgba(0,0,0,0.30)` | disabled, watermarks |
| `--tec-icon` | `rgba(255,255,255,0.80)` | `rgba(0,0,0,0.68)` | icon strokes |
| `--tec-fill-soft` | `rgba(255,255,255,0.05)` | `rgba(0,0,0,0.05)` | a wash over the page |
| `--tec-fill-softer` | `rgba(255,255,255,0.02)` | `rgba(0,0,0,0.025)` | a wash over a card |

**Never pure white or pure black.** `#ffffff` ink on a dark ground glares; `#000000` on
off-white is a hole. The ladder is alpha over the ground, so it composes correctly on
every layer without a per-surface variant.

**`--tec-icon` is not `--tec-text-1`.** A 1.5px stroke reads lighter than a filled glyph
at the same alpha, so an icon set to body ink looks faded next to its own label.

**The apps stop at `text-3`.** Anything that needs a fourth step improvises, which is
how `#3a3a4a` ended up hardcoded on Explorer's bottom nav and went invisible in light.

## 5.6.4 Radii — including the inner-page curve

```css
--radius-sm:   8px;      /* chips, small controls */
--radius-md:   14px;     /* buttons, inputs */
--radius-lg:   20px;     /* cards */
--radius-xl:   28px;     /* sheets, modals */
--radius-full: 9999px;   /* pills, avatars */

--tec-topbar-radius: 22px;   /* the inner-page band — see §5.5.6 */
```

The band's **22px sits deliberately between `lg` and `xl`**: it is wider than a card, so
it must curve more, but it is chrome rather than a sheet. It has its own token because
it is a fleet-wide shape — an app that hardcodes `20` here is a screen framed
differently from the Hub it was tapped in from.

Applied as `borderRadius: '0 0 var(--tec-topbar-radius) var(--tec-topbar-radius)'` —
**bottom corners only**. The band is anchored to the top edge of the viewport; rounding
its top corners would float it off an edge it is attached to.

## 5.6.5 Adoption — honest status

**The Hub is the only app on this ramp.** The other 23 run the §4 blue-black with a
three-layer surface set and a three-step ink ladder.

That is a real difference a user can see when they tap from the Hub into an app: the
ground shifts from neutral charcoal to blue-black. It is recorded rather than swept,
for the reason §5.5.3 gives — the previous sweep of this kind is what produced the
re-derived amber. Each app takes the ramp with its own change, verified on a device,
and copies the values in §5.6.1–5.6.3 rather than approximating them.

> **The order that matters.** Ramp first, then the band. A band tuned against
> `#050816` and dropped onto `#101014` is a different band.

---

# 6. THE 6 ESL DOMAINS

| Domain | Color | Shape | Motion | Apps |
|--------|-------|-------|--------|------|
| IDENTITY | #8B5CF6 | Circle | Flow | Hub, Connection |
| WEALTH | #FBB44A | Hexagon | Pulse | Assets, Wallet, FundX |
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
> Truth State: [Planned State] | Commitment: [Committed] | Verification: [Assumed]
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
Phase 1 — tec-ui v2.0.0
  ✅ EVL color tokens in TEC_COLORS (DONE — live)
  ☐ CSS variables (design tokens)        ← still planned
  ☐ SemanticDomain type                  ← still planned
  ☐ Basic glow utility classes           ← still planned

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
