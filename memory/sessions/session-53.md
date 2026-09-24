# SESSION 53 — the Testnet gate is closed on all 24 apps, and it exposed a guard one consumer wide

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

Pi Portal checklist **step 10** (one U2A Test-Pi payment on each app's paired Testnet
app) is **complete across the fleet**. Full engineering record:
`audits/PI_TESTNET_GATE_FINDINGS_2026-09-06.md`.

### What closed
The five apps left open at the last write-up now carry the port:

| App | How |
|---|---|
| Assets · Commerce · Ecommerce | hand-written — older than the template, each needed a genuinely different edit |
| NBF · Brookfield | attached to the session, then ported from the reference app unchanged |

### The three things worth carrying forward

**A host is read off the deployment or it is not known.** Vercel appends a suffix when
a project name is taken, and the suffixes are arbitrary: `tec-zone-mu`,
`tec-elite-bvzb` — and `commerce-app`, with no `tec-` prefix at all. The Hub's
`ALLOWED_TARGETS` had been written from the naming pattern. It must never become a
wildcard: `/api/auth/sso` hands the target a signed token carrying the user's access
token, and anyone can deploy on `*.vercel.app`.

**A branch that is nearly unreachable in production is not a tested branch.** Commerce
and Ecommerce sent an unauthenticated visitor to the Hub with **no `target=` at all** —
a one-way trip. The shared `.tecosystem.app` cookie means that branch is almost never
taken on Mainnet; on a host-only `*.vercel.app` host it is taken *every* time. Both had
shipped for months. Ecommerce had the constant redeclared in **eight** files, and in
Commerce two copies of the same rule had already drifted apart inside one repo.

**Overwriting is not removing.** `metadata.testnet` decides which Pi network the π
settles on and whether commerce grants PRO — so it must be derived from the request
host and a client-sent value **stripped**, not spread over. The host-derived value is
*absent* on Mainnet (present only when true, deliberately), so an overwrite there
overwrites nothing and the caller's claim survives.

### Recorded, not fixed — the next change

Fleet audit of every payment-create route: 22 apps + the template derive the marker and
strip the client claim; Assets and Commerce accept no client metadata at all. **The Hub
is the only app with neither** — `grep -ri testnet tec-frontend/src/` returns zero — and
its `metadata` is `.passthrough()`. Its sandbox default is also **inverted** against the
fleet (`!== 'false'` → defaults **true**).

Worse, one level down: **`tec-wallet-service` credits a real balance on
`payment.completed` with no `testnet` check.** All eight consumers of that event were
read; exactly one has the guard. A Test-Pi payment is refused a PRO subscription and
credited to a real wallet in the same breath. The `.v1` outbox payload carries
`metadata`, so the guard is implementable — the open decision is the legacy
direct-publish path, which carries none.

**Order for the next session: wallet-service first — it is the one that moves money.**

### …and then the CEO asked the question that found two more

> *"But no app works on the Testnet from the Hub."*

Not a bug report — an observation about the system nobody had stated, because every app's own
Mode-2 payment worked and Portal step 10 only ever needed Mode 2. It found two things.

**1. `HUB_URL` — the fourth build-time constant.** Mode 1 hands the payment to the Hub, which
creates *and approves* it, so the **Hub's own host** picks the key. Every app sent every
visitor to `NEXT_PUBLIC_HUB_URL` — one of the Hub's two hosts, baked at build time. A Testnet
visitor got a Mainnet approval and a Test-Pi wallet could not pay it. `APP_URL` · `sandbox` ·
`HUB_URL`: the same shape, a fourth time. Swept across 24 repos (33 files), matching **only**
the Mode-1 payment redirect so login — which works — was out of range by construction.

**2. The guard was on a route nothing calls.** The network marker and client-claim strip had
gone into `/api/bff/payment/create`, the ADR-009-shaped sibling that **no production code
calls**. Every real Hub payment posts to `/api/payment/create`, which forwarded the body
verbatim.

> **A guard's coverage is a fact about call sites, not about file names.** `grep` for the
> callers before believing a guard is in place.

Both closed. Full record: `audits/PI_TESTNET_GATE_FINDINGS_2026-09-06.md` §13 — and §4, which
had deferred this, is left standing rather than edited away: its reasoning was right for the
gate it was scoped against, and a record that quietly rewrites its own earlier judgement
teaches nothing.
