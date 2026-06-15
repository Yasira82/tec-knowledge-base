---
name: design-system-advisor
description: "When building or reviewing TEC app UI, planning tec-ui upgrades, or making design decisions — enforce Pi Browser compatibility, design token usage, and coordinated multi-app deployment."
metadata:
  version: 1.0.0
  tier: MEDIUM
  domain: design
  related_skills:
    - tec-design-system
    - ui-patterns
---

# TEC Design System Advisor

## tec-ui Health Check

```bash
# Run before any tec-ui change
npm run type-check                    # 0 errors
npm run build                         # clean dist/ (ESM + CJS)
grep -r "window\.Pi" src/ && echo "⚠️ Pi SDK in tec-ui!" || echo "✅ clean"
grep -r "\.module\.\|tailwind" src/ && echo "⚠️ CSS framework!" || echo "✅ clean"
```

## Version Bump Decision Tree

```
Change type?
  ├── New component or export → MINOR (v1.2.0 → v1.3.0)
  ├── Bug fix, no API change  → PATCH (v1.2.0 → v1.2.1)
  ├── Rename/remove export   → MAJOR (v1.2.0 → v2.0.0)
  └── Prop type change       → MAJOR

Before MAJOR bump:
  □ Add @deprecated JSDoc to old export
  □ Keep old export for 1 full major version
  □ Update ALL 4 consumer apps simultaneously
  □ Test in Pi Browser (not just Chrome)
```

## Coordinated Deploy Protocol

```
tec-ui version bump workflow:

  1. Build + test tec-ui locally
  2. Run type-check in ALL 4 consumer apps with new version
  3. Fix any breaking changes
  4. Publish to npm
  5. Update package.json in ALL 4 apps (same PR per app)
  6. Deploy ALL 4 apps in same 30-min window

WARNING: Staggered deploy = version mismatch window
         = users see different UI across apps
         = Pi Browser cache may serve mixed versions
```

## v1.2.0 Delivery Checklist

```
□ createU2APayment(amount, memo, metadata, internalId) → PaymentResult
□ PaymentModal component (idle/creating/paying/success/error/cancelled)
□ Payment status badges (inline indicators)
□ Observability status component (success rate display)
□ All inline styles (no CSS modules)
□ Tested in Pi Browser on real device
□ Type-check passes in: tec-app, tec-ecommerce, tec-assets, tec-commerce
□ Published to npm
□ All 4 apps upgraded in coordinated deploy
```

## Common Design Bugs

| Bug | Cause | Fix |
|-----|-------|-----|
| CSS vars undefined (blank styles) | hub/layout.tsx missing token import | Add `import '@/styles/tec-design-tokens.css'` to layout.tsx |
| Component blank in Pi Browser | CSS module / Tailwind used | Convert all styles to inline |
| Type error after tec-ui upgrade | Breaking export change without major bump | Bump major version + keep deprecated export |
| Build error: window is not defined | browser API in tec-ui | Remove immediately — tec-ui is pure UI |
