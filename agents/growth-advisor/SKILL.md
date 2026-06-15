---
name: growth-advisor
description: "When analyzing growth metrics, funnel performance, or retention for any TEC app — activate growth advisory for data-driven optimization of Pi payment conversion, user activation, and referral loops."
metadata:
  version: 1.0.0
  tier: MEDIUM
  domain: growth
  related_skills:
    - pi-growth
    - content-strategy
    - community-marketing
---

# TEC Growth Advisor

## Growth Metrics Framework

### Acquisition
```
Top of Funnel:
  Source breakdown: Pi Marketplace / Pi Chat / Referral / Direct
  Pioneer app installs: track via Pi Developer Portal
  Landing page conversion: visitor → login attempt

Target: 40% of visitors complete Pi SSO login
```

### Activation
```
Activation event: First successful Pi payment
Time-to-activate: login → first payment (target < 5 min)
Onboarding completion rate: (saw product) → (added to cart or clicked Buy)

Target: 25% of logged-in users make first payment within session
```

### Retention
```
D1  retention: 40%+ (saw value immediately)
D7  retention: 25%+ (found reason to return)
D30 retention: 15%+ (habitual Pi spender)

Retention drivers:
  → Notification hooks (order status, new products)
  → Subscription value (Hub PRO features)
  → Social ("your friend bought X on TEC")
```

### Revenue
```
GMV: Gross Merchandise Value in Pi (total Pi transacted)
ARPU: Average Revenue Per User in Pi
MRR: Monthly Recurring Revenue from subscriptions
LTV: Pioneer lifetime value (cumulative Pi spent)

Growth accounting:
  New Pi → Retained Pi → Resurrected Pi → Churned Pi
```

## Funnel Optimization Playbook

### Fix: Login Drop-off
```
Problem: Pioneers start SSO but don't complete
Diagnosis: Pi Browser session issues / slow load / confusing UI
Fix options:
  1. Optimize login page load (< 1s LCP)
  2. Show value before login ("See products — login to buy")
  3. Remember session longer (reduce re-auth friction)
```

### Fix: Payment Drop-off
```
Problem: User clicks Buy but doesn't complete payment
Diagnosis: Pi SDK not ready / hub navigation / wallet not funded
Fix:
  1. Check isHubNavigation() — mode 1 vs mode 2 routing
  2. Payment success rate monitoring: /api/bff/metrics
  3. Better error messages: "Please fund your Pi Wallet first"
```

### Fix: Day-7 Churn
```
Problem: Users don't return after first visit
Diagnosis: No re-engagement trigger
Fix:
  1. Email/push: "New products added to TEC Store"
  2. Price drop notification: "Product you viewed is now cheaper"
  3. Subscription value: "Unlock PRO features with Hub subscription"
```

## Growth Experiments Backlog

```
High Impact / Low Effort:
  [ ] Referral program: "+0.01 Pi when friend makes first purchase"
  [ ] Social proof: show "X pioneers bought this today"
  [ ] Urgency: "5 left in stock" (when true)

High Impact / High Effort:
  [ ] Personalization: show products based on Pi transaction history
  [ ] Merchant loyalty: punch card system (10th purchase = Pi reward)
  [ ] Cross-sell: "Customers who bought X also bought Y"

Test Queue:
  [ ] A/B: Gold CTA vs White CTA on landing page
  [ ] A/B: Show price in Pi vs Show price in USD equivalent
  [ ] A/B: Login-first vs Browse-first homepage
```
