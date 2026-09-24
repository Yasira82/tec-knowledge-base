# SESSION 43 — Fleet-wide UX pass: unified app-shell + Arabic/RTL + real Pi username + Pro parity (16 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (all PRs merged to `main`).
> A consistency pass across the whole app fleet so every TEC app looks + behaves like one product,
> and — the campaign-critical part — is **fully bilingual (EN + AR) with RTL** for the Pi community.

### What shipped (per app, merged to main)
- **Unified mobile app-shell** — a local `BottomNav` (4 tabs) with **local vector icons** (lucide-style
  SVG, NOT emoji), glass backdrop (`rgba(5,8,22,0.92)` + blur), active scale + gold underline, light
  haptic. Local `Icon.tsx` per app so we do **NOT** bump `@yasser172/tec-ui` to 2.x (a coordinated EVL
  palette break). The long single page is split into tabs (Home/primary · content · Pro · Settings).
- **Rich `SettingsView`** — sectioned Profile / Appearance / About, an **EN/AR language toggle**, and
  logout. Invite card included only where the app has the referral loop (omitted for NBF · Brookfield ·
  Explorer, which have none).
- **Real Pi username (`useMe`)** — new `src/lib-client/hooks/useMe.ts` resolves the login name via the
  server `GET /api/auth/me`. Pi Browser hides the `tec_user` cookie from client JS (**C-123 §3**), so
  reading it client-side returned null → Settings showed "TEC Member" / "Not signed in" for signed-in
  users. Now resolved server-side; fails closed to null (P6).
- **Arabic (EN/AR) + RTL** — `applyDir()` added to each app's `src/lib/i18n/index.tsx` (sets
  `document.documentElement.dir = rtl` / `lang`), driven by the toggle + persisted (`tec_locale`). Each
  app gained a fully-translated `<app>` i18n section in `en.ts` / `ar.ts`. On several apps `LocaleProvider`
  was defined but **never wired into the layout** — now wrapped.
- **Pro entitlement parity with Life** — every app's `<App>Pro.tsx` active card shows **★ You're on Pro**
  + the `daysRemaining` renewal reminder ("Expires in N days", amber nudge in the last 7 days; Pi U2A is
  one-time, no auto-renewal), matching the Life reference (Session 27). NBF + Brookfield had **missed** the
  Session-27 fleet propagation (not deployed then) — added here, so the fleet is now 100% consistent.
- **Removed internal (C-NN) doc citations from user-facing copy** — knowledge-base references (e.g.
  "Boundary (C-124)", "Simulated (C-131)") are internal, not for end users; stripped from visible text
  across the apps touched this session (code comments keep their C-NN refs — those are not user-facing).

### Fleet coverage
- **This continuation (final 8):** Legend · Elite · Alert · System · Ecommerce · Nexus · **NBF** · **Brookfield**.
- **Earlier in the session (13):** Life · Connection · Analytics · Zone · VIP · Explorer · Estate · Titan ·
  DX · NX · FundX · Insure · Epic. → the whole fleet now carries the unified shell + Arabic.
- **Ecommerce is the exception by design:** it is the mature marketplace with its **own** top nav
  (ShopHeader: Shop/Orders/Sell/Cart) + hamburger drawer + cart — a bottom nav would duplicate it. So it
  got `useMe` (real username) + an **EN/AR toggle inside its existing drawer** + RTL, and **zero** payment-flow
  change (ADR-007 `isHubNavigation()` guard, `handleBuy`, cart, BFF routes all untouched — R2 preserved).

### Notes / honest status
- **NBF + Brookfield branch repair:** both feature branches had drifted onto an **unrelated history**
  (no common ancestor with `main`) — that surfaced as GitHub "conflicts". Fixed by **rebuilding the branch
  on top of current `main`** with the exact same tree (verified byte-identical), giving each PR a clean,
  conflict-free diff. Then merged.
- **[Code Verified], not yet [Runtime Verified]** — the changes are merged to `main`; each app still needs
  its Vercel redeploy + an eyes-on check inside Pi Browser (real username, Arabic RTL, Pro card) to promote
  to Runtime Verified. No prod telemetry fabricated.
- **No backend / payment / KB-structure change** — pure frontend UX + i18n. Registry, C-doc headers, and all
  KB CI gates are unaffected (no C-doc header lines touched). Campaign proof sheet (`marketing/whats-live.md`)
  reconciled to note the fleet is now bilingual (see marketing update this session).
