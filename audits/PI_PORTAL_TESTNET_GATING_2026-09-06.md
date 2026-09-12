# Pi Portal — the Testnet gate in front of 24 domains

**Date:** 2026-09-06 · **Scope:** Pi Developer Portal (all TEC apps) + `tec-payment-service` + every app frontend
**Method:** read the Portal screens directly, then the code. Where a Portal screen and an assumption disagree, the screen wins.

**Truth State:** [Current State] · **Verification:** [Documentation Verified] · **Governance:** [Draft]

> ▶ **This is the PLAN. The OUTCOME is `audits/PI_TESTNET_GATE_FINDINGS_2026-09-06.md`.**
> The plan was right and still cost four separate defects to execute — none of them visible
> here. Read the findings before touching another app's testnet path.

> **Why this is written down at all.** The work is not "make the apps better" — the apps
> are live and working. The work is a **checklist in somebody else's product**, and the
> cost of getting it wrong is measured in weeks of review time, not in bugs. A plan that
> lives only in a chat is a plan that gets re-derived from screenshots every session.

---

## 1 · What is actually being bought

The Core Team requires **one app per `.pi` domain**. So the apps are not the goal — the
**domains** are, and each app is the toll paid for one.

That reframes everything below. This is not feature work with a nice-to-have deadline;
it is a **gate on 24 domains**, and it is currently closed on 23 of them.

`tec.pi` has been **Claim Pending for four weeks** (winning bid 21 π, auction ended).

---

## 2 · The gate, as the Portal states it

Two requirements, and **they are not the same requirement**. Conflating them cost a
session's worth of time before it was written down.

| | Checklist step 10 | Mainnet App Wallet |
|---|---|---|
| **Direction** | **U2A** — a user pays the app | **A2U** — the app pays a user |
| **Count** | 1 payment | 5 payments |
| **Who** | the owner, alone | **5 distinct Pi accounts** |
| **Where** | the Testnet app's URL, in Pi Browser | from the Testnet app's wallet |
| **Portal wording** | *"Process a User-to-App payment to confirm that the setup is complete."* | *"The paired Testnet app needs App to User transactions to 5 unique wallets."* |

Step 10 is **cheap and solo**. The 5 A2U payouts need **four other people**, because A2U
pays by `uid` — an address alone is not enough, the account must have authenticated with
*that* app before a `uid` for it exists.

### Observed state, 2026-09-06

| App | Testnet checklist | Testnet app wallet | Mainnet app wallet |
|---|---|---|---|
| TEC-APP | **10 of 10** ✅ | `GCVMC…JY7CI` | **None** ❌ |
| Connection | **9 of 10** — step 10 pending | `GBYAM…MEWOF` | not checked |
| the other 22 | not surveyed | — | — |

A complete checklist is **not** the same as the 5 A2U payouts: TEC-APP is 10/10 and its
Mainnet wallet application is still blocked.

---

## 3 · Why it has not simply been done

> ⚠️ **STALE — corrected 2026-09-12.** The blocker described below was real when this was
> written and is **fixed**: the Pi network is now chosen **per payment**, from the same
> target that picks the key (tec-core-backend #290 · #291), so a Testnet payment no longer
> requires flipping a global switch. And A2U itself **is built and merged**
> (`pi-a2u.ts` · `POST /payment/internal/a2u`). What still blocks the Mainnet App Wallet
> is §2's people requirement — 5 payouts to 5 distinct Pi accounts, each of which must
> have authenticated with the Testnet app first. Left in place rather than deleted,
> because the reasoning is still the record of why it waited.

`tec-payment-service` chooses the Pi network **globally**, from `PI_SANDBOX`. It is
`false`, because 24 apps take real Pi through it.

So a Testnet payment cannot be approved by the service that is running. Flipping
`PI_SANDBOX` to make step 10 possible would take **every live payment on the platform
down** for as long as it is flipped. That is not a trade worth making for a checklist.

The per-app **API key** already resolves per app (`PI_API_KEY_<SOURCE>`, `env.ts`). The
network does not. That asymmetry is the whole blocker.

---

## 4 · The observation that makes this cheap

The Mainnet app and the Testnet app **point at the same deployment**, on different hosts:

```
Connection Mainnet → connection.tecosystem.app
Connection Testnet → tec-connection.vercel.app      ← same Vercel project
TEC-APP  Mainnet   → hub.tecosystem.app
TEC-APP  Testnet   → tec-app-frontend.vercel.app    ← same Vercel project
```

The network therefore **cannot** be a build-time `NEXT_PUBLIC_PI_SANDBOX`: one build
serves both Pi apps. It has to be decided per request, from the host.

This is the difference between **24 preview deployments with 24 env sets** and **one
rule**. It was found by reading the Portal's own URL fields, not by planning.

---

## 5 · The plan

### Part 1 — payment-service: network per payment, not per process

The payment carries which network it belongs to; the service picks the matching Pi API
base, Horizon and app key.

**The default is the behaviour that runs today.** Absent an explicit network, Mainnet —
so this is additive, and a live payment path is not rewritten to serve a checklist.

### Part 2 — the frontends: network from the HOST, decided server-side

```
*.vercel.app      → Testnet
*.tecosystem.app  → Mainnet
```

Read from the `Host` header **inside the BFF**. Never from the client: a client-supplied
network flag is, literally, a button that says *"treat this payment as fake"* on a path
that moves real Pi (P6).

Built on `tec-template-base` first, then one app.

### Part 3 — one app before twenty-four

**Connection** is the reference. Ship parts 1+2, deploy, do step 10 on Connection, confirm
**10 of 10**, and only then repeat. Editing 24 apps and discovering the gap afterwards is
how a day is lost.

---

## 6 · What the owner has to supply, and why it paces the work

**A Testnet app API key per app** on `tec-payment-service` — **24 keys**, each created by
hand in the Portal and set on Railway.

**The keys are the real work, not the code.** The code is written once; the keys are 24
manual operations. Without an app's key its approve returns **502** — which is precisely
the Analytics lesson already recorded in `C-12 §11`, arriving again from a new direction.

So: **Connection's key only**, prove the whole path end to end, then the rest.

The payments themselves are **Test-Pi**. Nothing real is spent.

---

## 7 · Stated as unverified, deliberately

These are written down **as open questions**, not as findings. An unverified cause that
gets repeated until it sounds true is worse than an unanswered one.

| Question | Status |
|---|---|
| Is the 4-week `tec.pi` delay caused by the app not being complete? | **Unknown.** The domain auction and the app checklist are separate Portal systems. Plausible, unconfirmed. |
| Does Pi gate the 5 A2U payouts on the Testnet checklist being complete? | **Unknown.** TEC-APP is 10/10 and still blocked, which suggests they are independent — but that is one data point. |
| "≈90% of ecosystem apps never finish step 10" | **Owner's observation, 2026-09-06.** Not measured. Recorded because if it is true it is a fact about how hard this gate is, not about TEC. |

None of these could be checked from the engineering environment: outbound requests to
`minepi.com` are refused by the proxy, so **no claim about Pi's own behaviour in this
document comes from Pi** — only from its Portal screens.

---

## 8 · What this is not

- **Not** evidence that the Core Team has rejected anything. No such message was received.
- **Not** a code defect. Every app is deployed and taking real Pi on Mainnet today.
- **Not** blocked on TEC. It is blocked on a checklist, a network switch, and 24 keys.

---

## Related

`C-12_Dual_Mode_Payment.md` §11 (per-app Pi key · approve→502) ·
`C-01_Project_Identity.md` (app IDs and domains) ·
`audits/PORTAL_SUBMISSION_RUNBOOK_2026-06-21.md` (the submission path this gate sits in)
