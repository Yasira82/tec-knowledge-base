---
name: tec-design-system
description: "When building or modifying any TEC app UI — enforce TEC design tokens, Pi Browser compatibility rules (inline styles only), and the dark premium aesthetic defined in tec-ui."
metadata:
  version: 1.0.0
  tier: HIGH
  domain: design
  related_skills:
    - ui-patterns
    - bff-patterns
  related_documents:
    - knowledge-base/C-47___KERNEL_SPEC___PLATFORM_CONSTITUTION.md
---

# TEC Design System

## Design Tokens (from @yasser172/tec-ui)

**Authority: C-83 (EVL). Adopted live in `@yasser172/tec-ui` v2.0.0.** These mirror the code in `tec-ui/src/theme.ts` — keep them in sync.

```typescript
import { TEC_COLORS } from '@yasser172/tec-ui';   // v2.0.0+

// WEALTH accent (EVL — was #d4af37 pre-2.0)
TEC_COLORS.gold      = '#FBBF24'   // WEALTH — primary accent
TEC_COLORS.goldDark  = '#F59E0B'   // buttons, gradients
TEC_COLORS.goldLight = '#FCD34D'   // highlights
// Background layers (C-83 §4 — immutable)
TEC_COLORS.bg        = '#050816'   // Layer 1 — page background (was #020205)
TEC_COLORS.surface   = '#0B1020'   // Layer 2 — card / drawer (was #0d0d14)
TEC_COLORS.surface2  = '#111627'   // Layer 3 — elevated
TEC_COLORS.subtext   = '#6b6b7a'   // secondary text
// EVL semantic domains (C-83 §5)
TEC_COLORS.purple    = '#8B5CF6'   // IDENTITY
TEC_COLORS.green     = '#22C55E'   // GROWTH
TEC_COLORS.cyan      = '#06B6D4'   // INTELLIGENCE
TEC_COLORS.red       = '#EF4444'   // RISK
TEC_COLORS.blue      = '#3B82F6'   // GOVERNANCE

// CSS variables (via tec-design-tokens.css in hub/layout.tsx)
--tec-bg:          #050816   // Layer 1
--tec-surface:     #0B1020   // Layer 2
--tec-surface-2:   #111627   // Layer 3
--tec-gold:        #FBBF24   // WEALTH
--tec-purple:      #8B5CF6   // IDENTITY
--tec-green:       #22C55E   // GROWTH
--tec-cyan:        #06B6D4   // INTELLIGENCE
--tec-red:         #EF4444   // RISK
--tec-blue:        #3B82F6   // GOVERNANCE
```

## Pi Browser Compatibility Rules (CRITICAL)

```
FORBIDDEN in @yasser172/tec-ui or any Pi Browser-served component:
  ❌ CSS Modules (.module.css)
  ❌ Tailwind CSS classes
  ❌ styled-components
  ❌ CSS-in-JS that requires build step
  ❌ window.* / document.* in tec-ui package
  ❌ Pi SDK calls (window.Pi.*) in tec-ui

REQUIRED:
  ✓ Inline styles ONLY for tec-ui components
  ✓ Standard CSS via <style> tags or global CSS files
  ✓ Inline style={{ }} props on React components
  ✓ tec-design-tokens.css imported in layout.tsx (not page.tsx)
```

## Typography

```css
/* Primary: Georgia (serif) — brand, headings, prices */
font-family: 'Georgia, serif';

/* Secondary: system-ui (sans) — body, labels, UI copy */
font-family: 'system-ui, -apple-system, sans-serif';
```

## Component Patterns

### Button — Primary (Gold Gradient)
```tsx
<button style={{
  padding: '13px 32px',
  background: `linear-gradient(135deg, ${TEC_COLORS.gold}, ${TEC_COLORS.goldDark})`,
  border: 'none',
  borderRadius: 14,
  color: '#07070f',
  fontSize: 14,
  fontWeight: 800,
  fontFamily: 'system-ui',
  cursor: 'pointer',
}}>
  Action
</button>
```

### Card
```tsx
<div style={{
  borderRadius: 14,
  background: '#0B1020',
  border: '1px solid rgba(251,191,36,0.1)',
  overflow: 'hidden',
  transition: 'border-color 0.2s, box-shadow 0.2s',
}}>
  {/* content */}
</div>
```

### Price Badge
```tsx
<div style={{
  background: 'rgba(7,7,15,0.88)',
  border: '1px solid rgba(251,191,36,0.4)',
  color: '#FBBF24',
  fontSize: 11,
  fontWeight: 900,
  padding: '2px 7px',
  borderRadius: 20,
  fontFamily: 'Georgia',
  backdropFilter: 'blur(8px)',
}}>
  {price}π
</div>
```

## Hub Sub-page CSS Fix (Common Bug)

```
SYMPTOM: Hub sub-page renders but colors/fonts missing.
         CSS vars like var(--tec-text-1) render as transparent.

CAUSE:   hub/layout.tsx not importing tec-design-tokens.css.

FIX:     In hub/layout.tsx:
         import '@/styles/tec-design-tokens.css';

DO NOT: Import this in individual page.tsx files.
        Import ONCE in layout.tsx — applies to all sub-pages.
```

## tec-ui v1.2.0 Roadmap (Phase 0 deliverable)

```
□ createU2APayment()     ← src/payment/ — shared payment helper
□ PaymentModal component ← src/payment/ — replaces per-app modals
□ Payment status badges  ← src/payment/ — success/error/pending
□ Publish v1.2.0
□ Coordinate simultaneous upgrade: ALL 4 apps at once

WARNING: Staggered deploy = version mismatch = UI inconsistency.
         ALL 4 apps must upgrade in same deployment window.
```
