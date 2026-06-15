---
name: product-launch
description: "When launching a new TEC app, feature, or major update to the Pi Network ecosystem — execute a coordinated launch across Pi community channels, developer networks, and platform repos."
metadata:
  version: 1.0.0
  tier: HIGH
  domain: marketing
  related_skills:
    - pi-growth
    - content-strategy
    - community-marketing
  related_documents:
    - knowledge-base/C-41___ENGINEERING_ROADMAP.md
---

# TEC Product Launch Framework

## Launch Readiness Gate (must pass before any launch)

```
Technical:
  □ All P1 violations closed (or documented OPS-only)
  □ PI_SANDBOX=false verified on ALL production services
  □ Pi App ID registered in Pi developer portal
  □ Test coverage ≥ 60% on all affected repos
  □ External audit (target ≥ 9.5/10 for Pi Network submission)
  □ Payment success rate ≥ 95% in staging

Product:
  □ Core user journey < 3 clicks (Pi login → product → pay)
  □ Mobile-first: tested in Pi Browser on real device
  □ Error states: all failures show clear user message
  □ Offline handling: graceful degradation

Content:
  □ App store listing copy written (title, description, screenshots)
  □ Onboarding tutorial created
  □ FAQ page live
  □ Support channel ready (Telegram / Pi Chat)
```

## Launch Sequence (T-7 to T+7)

```
T-7 days:
  → Soft launch to 10 beta merchants/users
  → Collect feedback → fix critical bugs
  → Prepare Pi Marketplace submission

T-3 days:
  → Submit to Pi Network developer portal
  → Draft Pi Chat / Pi Forum announcement
  → Schedule social posts
  → Brief early community members (give them first access)

T-0 (Launch Day):
  09:00 — Push to production (with rollback plan ready)
  10:00 — Pi Forum post (long-form with screenshots)
  11:00 — Pi Chat announcement (short + app link)
  12:00 — Twitter thread (tag Pi Network official)
  14:00 — Monitor error rates, payment success rate
  16:00 — First-day metrics summary

T+1 to T+7:
  → Daily metrics review (MAU, payments, errors)
  → User feedback loop (Telegram community)
  → Quick fixes for top 3 reported issues
  → Referral activation (ask happy users to share)
```

## Pi Network Submission Checklist

```
□ App registered at minepi.com/developers
□ Pi App ID documented in all app CLAUDE.md files
□ Domain configured: tecosystem.app/[app-name]
□ Privacy policy live
□ Terms of service live
□ KYC flow implemented (for financial features)
□ PI_SANDBOX=false confirmed
□ Security audit score ≥ 9.5/10
```

## Launch Metrics Dashboard

```
Hour 1:  New users logged in via Pi SSO
Day 1:   Payments attempted vs completed (target ≥ 95%)
Day 7:   D7 retention (target ≥ 40%)
Day 30:  MAU, GMV, NPS
```
