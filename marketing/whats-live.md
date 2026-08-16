# What's Actually Live — TEC Proof Sheet

The honest, evidence-based answer to *"is this real?"* — the single most important
question on Pi. Hand this to anyone who's skeptical. Every row is the truth from the
platform's own source of truth (`architecture/app-fleet.yaml`), and a CI gate
(`evals/check-whats-live.sh`) **fails the build** if this page ever drifts from it.
So it can't quietly become a lie.

> **How to read "Live":** 🟢 **Live** = the app is deployed, reachable in Pi Browser,
> logs in with your Pi identity, and processes a **real Pi subscription** (verified in
> production). 🟡 **Live · core gated** = the app is deployed and its subscription is
> real Pi, **but** its high-risk financial mechanics (pools / escrow / securities) are
> intentionally **turned off** until legal + custody + governance clear. That gate is a
> feature, not a limitation — we don't move money we're not allowed to move.

> **What "Live" does NOT mean:** it does not mean an app has users, revenue, or traction
> we haven't earned. It means the software is real and works. Numbers are always the real
> number or nothing (honesty rule #1).

> **Bilingual by default (EN + AR).** Every app in the fleet ships a full **Arabic
> interface with right-to-left (RTL) layout** — switch language in-app from Settings.
> One consistent mobile experience across all apps (same navigation, same profile
> showing your real Pi name, same Pro card). Built for the Pi community, not just an
> English-first afterthought.

## The 24 apps

| App | Status | What is real today | Domain |
|-----|--------|--------------------|--------|
| Hub | 🟢 Live | Pi SSO — one login, one wallet, real Pi payments across the ecosystem | hub.tecosystem.app |
| Commerce | 🟢 Live | Merchant orders, checkout, real Pi payment | commerce.tecosystem.app |
| Assets | 🟢 Live | Pi-native asset portfolio | assets.tecosystem.app |
| Ecommerce | 🟢 Live | Pi-native storefronts + checkout | ecommerce.tecosystem.app |
| Analytics | 🟢 Live | Real economic-activity dashboard + Merchant Pro | analytics.tecosystem.app |
| Life | 🟢 Live | Personal goals + preferences (sovereign, private) | life.tecosystem.app |
| Connection | 🟢 Live | Follow / connect social graph | connection.tecosystem.app |
| Zone | 🟢 Live | Verification runtime — evidence-based verified status | zone.tecosystem.app |
| Nexus | 🟢 Live | Coordination runtime | nexus.tecosystem.app |
| Explorer | 🟢 Live | Discover Pi-accepting businesses | explorer.tecosystem.app |
| System | 🟢 Live | Read-only governance console | system.tecosystem.app |
| Alert | 🟢 Live | Unified notification inbox | alert.tecosystem.app |
| NX | 🟢 Live | Opportunity board (jobs / grants / partnerships) | nx.tecosystem.app |
| DX | 🟢 Live | Developer portal — SDKs, templates, guides | dx.tecosystem.app |
| Titan | 🟢 Live | Enterprise console (org / team / roles) | titan.tecosystem.app |
| Epic | 🟢 Live | Create + launch a Pi project | epic.tecosystem.app |
| Legend | 🟢 Live | Evidence-based reputation profile | legend.tecosystem.app |
| Elite | 🟢 Live | Criteria-based recognition | elite.tecosystem.app |
| VIP | 🟢 Live | Premium experience layer | vip.tecosystem.app |
| NBF | 🟢 Live | Start a verified Pi business | nbf.tecosystem.app |
| Estate | 🟢 Live | Real-estate services on Pi (services only — never full purchase / title) | estate.tecosystem.app |
| FundX | 🟡 Live · core gated | Browse educational pool charters. **No contributions, no yield** — pools gated on legal + KYC + governance | fundx.tecosystem.app |
| Insure | 🟡 Live · core gated | Risk score + protection surfaces. **Not an insurer; escrow gated** | insure.tecosystem.app |
| Brookfield | 🟡 Live · core gated | Explore institutional assets. **Simulated portfolio; real securities legally gated** | brookfield.tecosystem.app |

## What is deliberately NOT live (and why that's the honest part)

- **No Pi cash rewards / cashback / referral payouts.** The referral reward is a **free
  subscription month**, never Pi (ADR-012). Moving Pi to users is capital movement, and
  only the payment-service custodies Pi (Invariant #8).
- **No investment pools, escrow custody, or securities.** FundX / Insure / Brookfield
  keep those OFF until legal + custody + governance clear. Educational / simulated only.
- **We don't KYC you.** Pi Network does identity + KYC. We present status; we never claim
  to verify people ourselves.
- **No fabricated traction.** Any user / revenue number we ever publish is the real one.

> **Source of truth:** `architecture/app-fleet.yaml` (per-app deployment status) +
> `knowledge-base/C-01` (registered Pi App IDs). This sheet is regenerated-by-hand but
> **CI-checked** against the fleet registry on every change.
