# SESSION 19 — REFERRAL PROGRAM "Invite & Earn" (25 July 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** (deployed — Hub on Vercel + commerce-service migration on Railway).
> Decision of record: **ADR-012 (C-64)** · Growth doc: **C-133 §5.1**.

**Shipped:** the referral / invite viral loop on top of the Founding-Pioneer funnel.
A user invites a friend; when that friend takes their **first paid subscription**,
**both** get a free **30-day PRO month**.

- **Reward = gift subscription, never raw Pi** (ADR-012). A Pi cashback is capital
  movement — only payment-service custodies Pi (Invariant #8) — so it's **hard-gated**
  (legal + custody + SYSTEM) like FundX/Insure and NOT built. The gift month moves no Pi.
- **Reward on the referee's first paid subscription** (outcome, not signup) → anti-sybil.
  Atomic `PENDING→REWARDED`, at-most-once per referee.
- **Owner = `tec-commerce-service`** (the reward *is* a subscription extension → atomic,
  no cross-service call). Identity from the verified JWT, never the body (P6).
- **Entry points:** animated **Invite & Earn** carousel slide · **🎁 Invite** Hub tool ·
  any **`?ref=` invite link** captured on any page pre-login, applied on first auth.

**PRs (merged):** tec-core-backend #156 (referral module + migration) · tec-app #129
(referral page + BFF) · tec-app #130 (carousel slide + global `?ref` capture).
