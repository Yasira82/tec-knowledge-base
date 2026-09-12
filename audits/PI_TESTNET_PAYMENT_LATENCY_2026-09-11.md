# Testnet payments — what was fixed, what is still slow, and what is deliberately not being done

**Date:** 2026-09-11
**Scope:** the Hub (`tec-app`) + the 24 app frontends. No backend change except one.
**Truth State:** [Current State] · **Governance State:** [Draft] · **Verification:** [Runtime Verified] for the Hub and System; [Code Verified] for the rest

---

## 1. The state in one table

Session 53 closed the Pi Portal Testnet **gate** — one Test-Pi payment per app.
This session was about what happened when the owner actually *used* the Testnet
the way a person does: pay in the Hub, walk into an app, pay there.

| Repo | Merged | Testnet payment |
|---|---|---|
| `tec-app` (Hub) | **#209 → #226** (18 PRs) | works, both modes |
| `tec-system` | **#29 → #34** (6 PRs) | works, both modes — the reference app |
| `tec-core-backend` | **#293** | reconciliation reads Testnet payments with the Testnet key |
| **the other 21 apps** | **nothing merged** | **Mode 1 and Mode 2 both still broken on Testnet** |

> **That last row is the headline.** Every other app carries 2–4 commits on
> `claude/tec-knowledge-base-review-6wzngc` with an open PR, unmerged. Until those
> merge, only the Hub and System can take a Testnet payment at all.

---

## 2. What was actually wrong — five distinct defects, found in this order

Each fix exposed the next. None of them was the one guessed first.

### 2.1 ADR-007 was blind to the Testnet Hub
The hub-entry guard tested `referrer.includes('hub.tecosystem.app')` — the **Mainnet**
Hub, and only it, in three places per app. On the Testnet pair the Hub is
`tec-app-frontend.vercel.app`, so every hop from the Testnet Hub read as *standalone*:
the app ran `Pi.init()` inside a session the Hub owns, then sat in `Pi.authenticate`
forever. There is no error to catch — **the bridge simply never replies** — so the only
thing on screen is the app's own 90-second timeout, with the Pi wallet never opening.

Replaced with `HUB_HOSTS` + `isHubReferrer`, matching on **hostname**, not substring.
The substring form also matched `hub.tecosystem.app.attacker.com`, and that direction
fails **open**: a hostile referrer could force Mode 1 to a Hub URL of its choosing.

### 2.2 The Mode-1 chain on the Hub ran as a straight line
Arriving at `/hub?pay=1` did this, in order, nothing overlapping:

```
navigate cross-origin → auth resolution settles → POST /payment/create
→ modal mounts → only NOW warm the Pi session → user taps
```

Four serial steps before the handshake started. The handshake needs the SDK and
nothing else, so it now starts the moment the handoff is read, beside the other two.

This is only safe because of the gate (2.3): starting early would otherwise race
login's own authenticate.

### 2.3 Two concurrent `Pi.authenticate` calls — caused by the guard against them
Pi Browser answers neither of two concurrent `authenticate` calls reliably; the loser
dies silently on its own timer. The Hub had two independent callers — `loginWithPi`
(45s budget) and the modal's session manager (25s) — with nothing connecting them.
`withAuthGate` now serializes every caller, and a login is **adopted** rather than
repeated.

Then the tap re-created the same bug deliberately. Read off a production trace:

```
0.0s SDK ready — warming the Pi session
1.2s tap: warm-up still running — starting a fresh authenticate
1.2s tap: authenticating            … and then nothing, for a minute
```

The tap threw away a **healthy 1.2-second-old** handshake and issued a second one —
Pi's bridge still held the first. The code that did it was written to avoid inheriting
a *stalled* warm-up; the warm-up is not stalled, it is simply slow. A stalled one
cannot be inherited forever anyway: the auth call carries its own budget, settles, and
the gate then runs the next attempt **sequentially**. The tap now **joins**.

> **The lesson worth keeping: a defect can be load-bearing, and so can a guard.**
> Twice this session the failure was produced by the mechanism written to prevent it.

### 2.4 Cancel returned to the Hub, not to the app — and it was an open redirect
Apps sent **no `return_url`**, so the Hub fell back to its own `/hub`. The user is
dropped somewhere they never asked to be, and the app never learns the outcome.

Closing it exposed the real problem: the Hub **navigated to any `return_url` it was
given**, and on success appended `payment_id` and `txid` to it.
`/hub?pay=1&amount=1&return_url=https://evil.example` was enough to receive those.
Now validated against the SSO allowlist — extracted to `domains/allowed-origins.ts` so
the two consumers cannot drift — and matched on the **origin**, not a prefix of the
whole URL, which `hub.tecosystem.app.evil.example` would satisfy.

### 2.5 The diagnostic was testing a different path from the one it diagnosed
`/pi-test` paid under `source: 'test'`, resolving `PI_API_KEY_TEST_TESTNET`, which
exists nowhere. It reported a failure production would never have.

> **A diagnostic that tests a DIFFERENT path from the one it is diagnosing sends you
> hunting the wrong bug.** It cost most of a day.

---

## 3. What is STILL slow, and why it is being left alone

After all of the above, one behaviour remains: **pay in the Hub, then pay in an app —
the first payment after arriving takes tens of seconds.** The reverse order (app first,
then Hub) is instant.

The trace shows our side is clean — one handshake, started at 0.0s, joined correctly by
the tap. **The remaining wait is inside `Pi.authenticate` itself**, the first call after
arriving from a different Pi app, and it is paid **once**: the next payment is immediate.
That is a Pi app-context switch inside Pi Browser. No code on our side shortens it.

It appears on **Testnet only**. Mainnet is instant in the same sequence.

### The structural cause, and the decision not to act on it

| | Hub | app |
|---|---|---|
| **Mainnet** | `hub.tecosystem.app` | `<app>.tecosystem.app` — **one registrable domain** |
| **Testnet** | `tec-app-frontend.vercel.app` | `tec-<app>.vercel.app` — **two unrelated sites** |

`vercel.app` is on the **public suffix list**, so the two Testnet hosts are as unrelated
to each other as two strangers' domains: separate cookie jars, separate partitions,
nothing shared. Every host-vs-network bug in this series grew in that gap.

A `-test.tecosystem.app` pairing would give Testnet Mainnet's shape. **The code for it
is written and open in a PR on all 25 repos — the domains are deliberately NOT being
created.** Reasons, recorded so the decision is not re-litigated from scratch:

1. It is **not a diagnosed cause** of the latency — it removes a category of difference.
2. The pain is confined to a **test environment**. Mainnet, which users touch, is fine.
3. The cost is ~48 manual steps by the owner (24 Vercel domains + 24 Pi Portal domain
   changes), and changing a registered Portal domain can break Testnet payments that
   **currently work**, slowly.
4. Merging the code is free and additive — every legacy `*.vercel.app` host stays
   listed and working — so the option stays open at zero cost.

**Revisit only if the latency is observed on Mainnet.**

---

## 4. The recurring bug shape — now at six instances

A **build-time constant answering a question only the request can answer**:

```
APP_URL · sandbox · HUB_URL · appId · the Hub's app-grid routes · ADR-007's hub referrer
```

One build serves two hosts. Any constant naming one of them is wrong half the time,
and on this platform "wrong" means a Test-Pi wallet holding a Mainnet payment, or a
bridge that never replies. **The host is the only thing that differs between a Mainnet
app and its Testnet twin, which is exactly why Pi itself uses it.**

Three separate axes, repeatedly conflated:

- the **HOST** picks which Pi *app*;
- that app's **API KEY** picks which *network*;
- **`sandbox`** points the SDK at Pi's *Sandbox environment* — a third thing.

---

## 5. Process notes from this session

- **A merged PR cannot carry new work.** A commit was pushed to a branch whose PR had
  already merged, leaving the fix invisible with no open PR. Pushing to the branch and
  opening its PR are **one step**.
- **A fleet sweep must check what it is about to overwrite.** A branch-switch + stash
  strategy dropped an unmerged commit in two repos. Caught by auditing all 25 for the
  expected content, and restored. **Never force-push a fleet without first proving each
  branch holds only already-merged history.**
- **When a fix produces a red run, the red run is the deliverable.** Printing what the
  tool actually sees beat three plausible theories, twice.

---

## 6. Open after this session

| # | Item | State |
|---|---|---|
| 1 | **21 app repos unmerged** — ADR-007 Testnet fixes still sitting in open PRs | **blocks Testnet payment on those apps** |
| 2 | `tec-core-backend` **#294** — `piNetworkLabel` (a Testnet approve logs `network: mainnet`) | open, cosmetic but misleading |
| 3 | `-test.tecosystem.app` pairing | code open in 25 PRs; **domains deliberately not created** (§3) |
| 4 | Pi Portal Privacy URL is `/policy` on some apps, `/privacy` on others | raised, never done |

---

## Related
- `audits/PI_TESTNET_GATE_FINDINGS_2026-09-06.md` — the gate itself (Session 53)
- `audits/PI_PORTAL_TESTNET_GATING_2026-09-06.md`
- `knowledge-base/C-76___ADR-007.md` — Pi foreign session
- `knowledge-base/C-12_Dual_Mode_Payment.md` — dual-mode payment + anti-regression
- `knowledge-base/C-123___PI_BROWSER_SESSION_COOKIE_SPEC.md` — cookie law
