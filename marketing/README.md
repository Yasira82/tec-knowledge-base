# TEC Marketing Assets Kit

Reusable, ready-to-publish marketing copy for the TEC Federated Platform. This folder
is the **operational** companion to the governance doc `C-133 — Platform Adoption &
Growth Governance` (the rules) and `C-134 — Pioneer Runtime Charter` (the onboarding
runtime). C-133 governs; this kit executes.

> **Nothing here is a constitution.** These are working assets — copy, templates, and
> talking points. When a rule and an asset disagree, C-133 wins.

## Contents

| File | Use |
|------|-----|
| `one-liners.md` | Elevator pitches — platform + per-app one-liners (bios, ads, intros) |
| `launch-posts.md` | A ready launch post per app + the Invite & Earn post (X/Twitter, Telegram, Pi community) |
| `pi-portal-copy.md` | Pi Developer Portal listing copy per app (tagline + description) |
| `ambassador-kit.md` | Talking points, do/don't, and the honesty rules for TEC Ambassadors |
| `faq.md` | Objection-handling — the trust questions people actually ask (EN + AR) |
| `whats-live.md` | The honest "is this real?" proof sheet — **CI-checked** against the fleet registry |
| `launch-plan.md` | The launch sequence + cadence (turns the posts into an ordered campaign) |
| `outreach.md` | First-touch DM templates for merchants · developers · Pioneers (EN + AR) |

## Link hygiene (measure what works)

Tag every shared link so you know which post/channel drove sign-ups — add a UTM tail
(e.g. `?utm_source=telegram&utm_campaign=founding100`) on marketing links, and use the
referral **`?ref=`** code for invites (it attributes the reward automatically). Keep the
apex path clean: real `https://` URLs only, never a placeholder.

## Single source of truth

Every per-app value line here is derived from the **app value proposition** that lives
in code — `src/domains/_registry.ts` (`valueProp`) in `tec-app`. That registry is the
SSoT (C-133 R6: every live app must state real, standalone value). If an app's value
changes, update the registry first, then refresh the copy here.

## The honesty rules (non-negotiable — C-133 §7)

These apply to **every** asset in this folder and everywhere TEC is marketed:

1. **Real numbers only.** Never publish a fabricated user count, revenue figure, or
   "Founding spots claimed". If the real number is zero, say zero (or say nothing).
   Credibility with the Pi Core Team and the Pi community is the whole strategy.
2. **No fake scarcity.** The Founding 100 cap is real (100). Do not invent countdowns,
   "only 3 left!", or urgency that isn't backed by the server counter.
3. **No guaranteed returns / financial promises.** FundX, Insure, Brookfield and any
   capital-adjacent app are educational/preview until their P0 gates clear. Never imply
   yield, profit, or protection that isn't live.
4. **Earned, not bought.** The Founding Pioneer badge, Elite recognition, and Legend
   reputation are earned. Never market them as purchasable.
5. **KYC is Pi's.** Pi Network handles KYC (wallet, payments, domain claims). We present
   status; we never claim to verify identity ourselves.
6. **Every app delivers real value.** Do not promote an app whose linked experience is
   an empty landing page (C-133 R6). If it isn't real yet, market it as "preview".

## Tone

Confident, plain, Pi-native. Speak to a Pioneer, not an investor. Short sentences.
Bilingual where it ships (EN + AR) — Arabic copy is colloquial, matching the apps.
