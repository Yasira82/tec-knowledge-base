---
name: ui-patterns
description: "When building TEC app UI components — apply established Pi Browser-compatible patterns for modals, drawers, loaders, navigation, and payment states."
metadata:
  version: 1.0.0
  tier: MEDIUM
  domain: design
  related_skills:
    - tec-design-system
---

# TEC UI Patterns

## Loading States

```tsx
// Spinner (Pi-compatible — pure CSS animation)
<div style={{
  width: 32,
  height: 32,
  borderRadius: '50%',
  border: '3px solid rgba(251,191,36,0.15)',
  borderTopColor: '#FBBF24',
  animation: 'spin 0.8s linear infinite',
}} />
<style>{`@keyframes spin { to { transform: rotate(360deg) } }`}</style>
```

## Page Shell (authenticated)

```tsx
<div style={{
  minHeight: '100vh',
  background: '#050816',
  color: '#fff',
  fontFamily: 'Georgia, serif',
}}>
  <GlobalNav ... />
  {/* page content */}
</div>
```

## Drawer / Modal

```tsx
// Overlay
<div onClick={onClose} style={{
  position: 'fixed', inset: 0, zIndex: 290,
  background: 'rgba(5,8,22,0.75)',
  backdropFilter: 'blur(6px)',
}} />

// Drawer panel
<div style={{
  position: 'fixed',
  top: 0, right: 0, bottom: 0,
  zIndex: 300,
  width: 320, maxWidth: '92vw',
  background: '#0B1020',
  borderLeft: '1px solid rgba(251,191,36,0.1)',
  transform: isOpen ? 'translateX(0)' : 'translateX(100%)',
  transition: 'transform 0.3s cubic-bezier(0.16,1,0.3,1)',
}} />
```

## Payment Status UI

```tsx
// creating — "Preparing payment..."
<div style={{ color: '#f0c040' }}>Preparing payment…</div>

// paying — "Complete payment in Pi wallet..."
<div style={{ color: '#7ee7c0' }}>Complete payment in Pi wallet…</div>

// success
<div style={{ color: '#10b981' }}>🎉 Payment successful!</div>

// error
<div style={{ color: '#ef4444' }}>{errMsg || 'Payment failed'}</div>

// cancelled
<div style={{ color: '#a78bfa' }}>Payment cancelled</div>
```

## Error States

```tsx
// Empty state
<div style={{ textAlign: 'center', padding: '60px 0' }}>
  <div style={{ fontSize: 48, opacity: 0.3, marginBottom: 12 }}>📦</div>
  <p style={{ fontFamily: 'system-ui', fontSize: 14, color: '#3a3a4a' }}>
    No items yet
  </p>
</div>

// Error state with retry
<div style={{ textAlign: 'center', padding: '60px 0' }}>
  <div style={{ fontSize: 44, opacity: 0.35, marginBottom: 12 }}>⚠️</div>
  <p style={{ fontSize: 14, color: '#5a3a3a', marginBottom: 8 }}>Error loading data</p>
  <button onClick={retry} style={{
    fontSize: 12, color: '#FBBF24', background: 'none',
    border: '1px solid rgba(251,191,36,0.35)', borderRadius: 10,
    padding: '8px 20px', cursor: 'pointer',
  }}>↺ Retry</button>
</div>
```

## Grid Layouts

```css
/* Featured products (larger cards) */
.featured-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 10px;
}

/* Standard products */
.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
  gap: 10px;
}

/* Hub apps grid */
.apps-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}
```

## Animations

```css
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to   { opacity: 1; transform: none; }
}

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(16px); }
  to   { opacity: 1; transform: none; }
}

/* Apply with delay for staggered grid appearance */
.card {
  animation: fadeUp 0.4s ease both;
  animation-delay: calc(var(--i) * 60ms);
}
```
