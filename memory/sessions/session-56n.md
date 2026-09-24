# Session 56n — the fleet finally received a rule it already had, and the bill explained why that matters

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

Four threads, and they turned out to be one thread: **a platform of 29 repos pays for
every rule twice — once to write it, and once for every repo that never received it.**

### 1.3 — `/api/ready` reaches the fleet (23 apps + the template)

`tec-template-base` #33 added the readiness endpoint months ago. Counted today:
**24 apps carry `/api/health`, exactly ONE carried `/api/ready`** — the template itself.

```
health  → "am I alive?"   — ALWAYS 200, never blocks a deploy
ready   → "can I serve?"  — 503 when a dependency it needs is unusable
```

These cannot be one endpoint. `/api/health` is deliberately incapable of failing
(NEW-W: a liveness check that failed while the gateway was merely BUSY reported the
platform down, and **the false alarm was the outage people saw**). Which left nothing
able to gate a rollout or pull a broken instance out of rotation.

> **Third time, same shape.** The `^1.1.0` caret trap and the Dependabot config were
> the first two, both recorded above. **A rule that lives in the template and not in
> the apps is a rule the fleet does not have.** Writing it down is not shipping it.

Verified, not assumed: 14 apps run locally (test + typecheck green), and the other 9 —
which had no `node_modules` in the session — were confirmed by **reading their own CI
runs**, all green. 23/23 covered by evidence, none by inference.

### The CI bill, and the arithmetic nobody had done

The Actions budget hit **98% of its $65 cap with `Stop usage` armed** — one pipeline
from freezing every open PR across the fleet. Opening 23 PRs in an hour is what pushed
it there, which is a cost that should have been counted before the PRs, not after.

`ci.yml` was five jobs. **Four of them ran `npm install`**, and — the part that had
never been reckoned with — **GitHub bills each job ROUNDED UP TO THE MINUTE**, so a
policy job of five seconds' greps cost a full minute. Five jobs is five roundings
before any real work counts.

Measured on Tec-Zone, same repo, same day, old run beside new:

| | 5 jobs | 1 job |
|---|---|---|
| `npm install` | 4× (75s) | 1× (16s) |
| actual compute | 195s | 82s |
| **billed** | **6 min** | **2 min** |

**67% off every run, same checks, nothing dropped.** Splitting bought parallelism — a
faster red light. On a platform built by one person, wall-clock is worth far less than
the bill.

> **The merge was done by transforming each repo's OWN file, not by copying the
> template over it — and that is the whole lesson.** The files are not the same file:
> six distinct variants. Comparing first is what caught two defects that had nothing to
> do with the thing being fixed — `tec-ecommerce` carried `push: [main, 'claude/**']`
> ALONGSIDE `pull_request`, starting **two full pipelines per commit** (concurrency
> cannot help: different `github.ref` means duplicates, not superseded runs); and
> `tec-nbf`/`tec-brookfield` had no `cache: 'npm'`, re-downloading the tree every
> install. A blind copy would also have **deleted** the Drift-Detection checks that
> only Analytics and Ecommerce carry.

### Two things I was wrong about, recorded so the next look is shorter

- I called `tec-core-backend`'s three concurrency-less workflows "the best remaining
  target". **Wrong about all three.** `changelog.yml` fires on `release: published`;
  `load-test.yml` and `weekly-scan.yml` are `workflow_dispatch` ONLY. **A missing
  `concurrency` on a workflow nobody triggers is not a leak.**
- `weekly-scan.yml` had already had its schedule removed deliberately, reasoning written
  into the file. **I was about to redo finished work.**

The backend's CI turned out to be the best-tuned pipeline on the platform (paths-filter
matrix, per-service node cache, Docker layer cache). Its one real defect: the Prisma
version pin ran for **every** service, so `tec-api-gateway` and `tec-realtime-service`
— which own no schema and import no Prisma — downloaded the client and its engines on
every run, to throw them away.

### IIC 4.5 — the proof module existed and nothing ever called it

#316 shipped `intent.proof.ts` complete: canonicalise, build, sign, verify, tested.
**Never invoked.** The platform had a proof implementation and zero proofs. Wired now,
both halves: the backend collects decisions/effects/approvals where each fact is first
known and emits at the terminal transition, and the Hub posts the approval **with the
sentence the buyer actually read**.

`shown.ts` in the Hub was the same shape again — written, tested, no callers, while the
modal built the same strings a second time five lines away.

> **A capability that never worked still costs whatever it was granted.** Same
> sentence as the Pi webhook, one layer up.

### The revenue surfaces that took money and delivered nothing

| App | What happened | Fix |
|---|---|---|
| **VIP** | `item_id: 'vip-standard'` matches NEITHER commerce pattern (`_pro_monthly` / `_enterprise_monthly`), so the consumer found no plan and returned. Every purchase moved real π and created **no subscription row at all** | → `vip_pro_monthly`, **5π not 50π** |
| **Elite** | `elite-certificate`, 5π, **no issuance, no record, no backend anywhere** | Button removed; the screen now says recognition is free and the certificate is not yet available |

**50π → 5π, and the reasoning matters more than the number.** Naming it
`vip_enterprise_monthly` would also have made the id match at 50π — rejected, because
VIP STANDARD is the ENTRY tier of STANDARD → PARTNER, and **calling the entry tier
"enterprise" so a regex agrees is fixing the parser by lying to it.** As PRO it joins
the fleet's real entry price (Life/Connection/Alert all 5π for the identical
entitlement).

The price also lived in **three places** — the charged constant, a literal `π 50` in
the card's JSX, and `price: 50` in the tier catalog. Now rendered from what is charged.
**A screen and a payment disagreeing about the price is the one disagreement a buy
surface cannot have**, and it was one edit away.

### The fact that reframes the roadmap

Asked who needed a refund for those two SKUs, the answer was: **nobody but the owner,
on two accounts.**

So no user was harmed, and nothing is owed. But it says something larger, and it should
be written down rather than inferred later: **24 apps are live on Mainnet with real Pi
payments working, and there are effectively no external paying users yet.**

That **validates the Elite decision rather than merely excusing it** — the certificate's
addressable buyers really would have been zero, which is exactly why building the
issuance was refused. And it moves VIP's unfulfilled benefits (reduced Commerce fees,
<2hr Hub support, advanced Analytics dashboards — **not implemented in any owning app**,
confirmed by grep) from "fix now" to "before VIP is marketed": nobody is paying for them
and being let down.

> The next question is not what to build. It is **what gets the first real user**.
