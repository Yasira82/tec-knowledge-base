# Smoke Test Demo Video Script (5 minutes)

> **Purpose:** Walk through the 30-minute pre-submission smoke test in a 5-minute video
> **Audience:** Solo developer (you) before Pi Portal submission
> **Tone:** Professional but conversational — like a senior engineer talking to themselves

---

## Pre-Production Setup

**Equipment:**
- Screen recorder (OBS / QuickTime / Loom)
- Pi Browser open on desktop
- Terminal open with repo
- Vercel dashboard open
- This script on a second monitor

**Before recording:**
- Close all unnecessary apps
- Make sure all 4 apps are deployed and healthy
- Have 0.1 π available for test payments

---

## Script

### [0:00–0:30] Intro

**[Camera: screen recording, terminal visible]**

> "This is the TEC Platform pre-submission smoke test. 30 minutes, 4 apps, 8 payments. If everything passes, we submit to Pi Network Developer Portal. Let's go."

**[Action: show the 30-min plan table on screen briefly]**

> "The plan: load all 4 apps, test SSO, check realtime, then 2 payment modes per app — Mode 2 standalone, Mode 1 via Hub. Final check: Vercel logs for 403s."

---

### [0:30–3:00] Phase 1: Load + SSO + Realtime

**[Action: open Pi Browser, navigate to hub.tecosystem.app]**

> "First — Hub. Loads in under 3 seconds. Good."

**[Action: click Login, authenticate with Pi]**

> "SSO login. No 401 loop, cookie persists. Good."

**[Action: navigate to a page that uses realtime]**

> "Check realtime endpoint. If REALTIME_URL is set, this returns 200, not 500. Good."

**[Action: logout, login again to verify SSO refresh works]**

> "Logout, login again. Token refresh works. Phase 1 done — 3 minutes."

---

### [3:00–9:00] Phase 2: Ecommerce (Mode 2 + Mode 1)

**[Action: navigate to ecommerce.tecosystem.app]**

> "Ecommerce. Mode 2 first — standalone payment."

**[Action: add a 0.01 π item to cart, click Buy]**

> "Buy a 0.01 π item. Pi payment modal opens. Approve. Payment completes. Order created."

**[Action: show the order confirmation page]**

> "Order confirmed. Mode 2 works."

**[Action: now navigate to hub.tecosystem.app?pay=1&app=ecommerce&...]**

> "Now Mode 1 — via Hub redirect. Hub modal opens."

**[Action: complete the payment via Hub]**

> "Payment completes through Hub. Ecommerce: Mode 1 + Mode 2 both work. 6 minutes in."

---

### [9:00–15:00] Phase 3: Assets (Mode 2 + Mode 1)

**[Action: navigate to assets.tecosystem.app]**

> "Assets. Mode 2 — mint a 0.01 π asset."

**[Action: click Mint, pay 0.01 π]**

> "Payment completes. Asset recorded at real price — not 1 π. ADR-009 contract working."

**[Action: now Mode 1 via Hub]**

> "Mode 1 via Hub. Hub modal, payment, asset created. Assets: both modes work. 12 minutes in."

---

### [15:00–21:00] Phase 4: Commerce (Mode 2 + Mode 1)

**[Action: navigate to commerce app]**

> "Commerce. Mode 2 — subscribe to a 0.01 π plan."

**[Action: click Subscribe, pay]**

> "Payment completes. Subscription active."

**[Action: Mode 1 via Hub]**

> "Mode 1 via Hub. Payment, subscription. Commerce: both modes work. 18 minutes in."

---

### [21:00–25:00] Phase 5: Log Check

**[Action: open Vercel dashboard → Hub project → Logs]**

> "Final check — Vercel logs. Looking for 403 or 500 on /api/bff/payment/*."

**[Action: filter logs by path: /api/bff/payment]**

> "Filter by payment routes. Zero 403s. Zero 500s. The CI guard prevented the CSRF regression."

**[Action: check Railway dashboard — all 12 services green]**

> "Railway — all 12 services green. Healthchecks passing."

---

### [25:00–28:00] Phase 6: Final Verification

**[Action: open terminal, run CI checks]**

> "Last thing — run the KB CI gates locally. All 10 should pass."

**[Action: for s in evals/*.sh; do bash "$s"; done]**

> "validate-skills ✅ · validate-charters ✅ · validate-structure ✅ · check-knowledge-gaps ✅ · check-links ✅ · check-truth-framework ✅ · check-c57-index ✅ · check-registry-integrity ✅ · check-vam-compliance ✅ · AHV engine ✅"

> "10 for 10. All green."

---

### [28:00–30:00] Outro

**[Camera: face to face if comfortable, or terminal]**

> "30 minutes. 8 payments. 10 CI gates. Zero failures. The platform is production-ready."

> "Next: open Pi Developer Portal, submit all 4 apps following the PORTAL_SUBMISSION_RUNBOOK. After that: wait 1–2 weeks for Pi review."

> "TEC Platform — Session 14, June 2026. Let's go."

---

## Post-Production Notes

- If any test fails, STOP recording and fix the issue first
- Re-record only the failed section — don't redo the whole 30 minutes
- Keep the video as a record — useful for post-submission debugging
- Upload to private YouTube / Loom for future reference
- Title: "TEC Platform — Pre-Submission Smoke Test (June 2026)"

## Voice-over Tips

- Speak clearly, slightly slower than normal
- Narrate what you're doing ("Now I'm clicking Buy...")
- If something takes time (page load), say "waiting for..."
- If something fails, don't panic — say "that's a fail, let me check why"
- Keep energy up — this is a milestone, not a chore
