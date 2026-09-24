# Pi Reward Campaign — Engineering Report on the Two Campaign Surfaces

**Date:** 2026-09-19
**Scope:** `/hub/campaign` (pioneer) · `/hub/admin/campaign` (payout queue) · their BFF routes ·
`tec-identity-service` campaign module
**Truth State:** [Current State] · **Governance:** [Draft] · **Verification:** [Code Verified]
**Reviewed at:** tec-app `b6b0b41` + branch `claude/tec-knowledge-base-review-6wzngc`

---

## 0. Summary

The campaign ran end-to-end on Mainnet this session and the payout verified against the
chain (C-02 Session 56o). **The money path is sound.** Identity is taken from the verified
session everywhere, seat allocation is race-safe by database constraint, a rejected claim
returns its seat, and `markPaid` refuses a hash the chain does not confirm or that another
seat already used.

This review looked for what breaks when the campaign stops being a test with one claimant
and becomes a public offer with a hundred. **Five findings.** One of them fires at the
campaign's most successful moment.

> **All five are now fixed, and so are the three gaps listed further down.** A second pass
> over the fixed code found no new defects. See *Correction to this report's own
> classification* — one item was filed under "decisions" that was plainly a defect, which
> makes the session's real defect count **six**.

| # | Severity | Finding | Fires when |
|---|----------|---------|-----------|
| **F1** | **P1** | A full campaign is reported as *"No campaign is running"* | The 101st pioneer arrives |
| **F2** | **P2** | Every tab focus flashes the whole page to skeleton | Every return from a mission — the core flow |
| **F3** | **P2** | The admin PATCH route defaults an unknown action to `paid` | A malformed request on a money path |
| **F4** | **P3** | Share is offered on a closed campaign | Any share after the round ends |
| **F5** | **P3** | `/campaign/me` replaces the service's sentence with a generic one | Diagnosis of a failure that never surfaces |

---

## F1 — A full campaign says it does not exist · **P1**

### Evidence

`campaign.service.ts::getStatus`:

```ts
open: parseApps(process.env.CAMPAIGN_APPS ?? '').length > 0 && claimed < CAMPAIGN_SEATS
```

`open: false` therefore carries **two entirely different facts**: *the round is not
configured*, and *every seat is taken*. The page cannot tell them apart, and renders one
sentence for both:

```ts
closedTitle: 'No campaign is running'
closedSub:   'Check back — the next round will appear here.'
```

### Why it matters

The campaign's success condition is 100 claimed seats. **At the exact moment it succeeds,
every new arrival is told the thing does not exist.** Somebody who followed a shared link,
or a friend's recommendation, reads that as "I was sent to something fake" — on the one
screen whose entire job is to convert a stranger into a pioneer, and at the point where
the most strangers are arriving.

It also destroys the campaign's own word of mouth precisely when word of mouth peaks.

### Fix

`getStatus` returns `closed_reason: 'not_configured' | 'full'` alongside `open`. The page
picks the sentence. *"All 100 seats are taken — the next round will be announced here"* is
true, is not a rejection, and keeps the reader.

> A single boolean that answers two questions will be read as answering the wrong one.

---

## F2 — Every tab focus flashes the page to skeleton · **P2**

### Evidence

`/hub/campaign`:

```ts
const load = useCallback(async () => {
  setLoading(true);                       // ← every call
  …
}, [isAuthenticated]);

useEffect(() => {
  const onFocus = () => { if (!authLoading) void load(); };
  window.addEventListener('focus', onFocus);
  …
}, [authLoading, load]);
```

and `<HubSubShell loading={authLoading || loading}>` renders `<Skeleton />`.

### Why it matters

**Every mission opens in a new tab.** Returning to this page is not an edge case — it is
the loop the page is built around, twenty-four times per pioneer.

> **Correction (2026-09-24).** Pi Browser **has no tabs** — `target="_blank"` there opens a
> fresh context whose history holds only the app, and whose cookie jar is not the Hub's
> (C-123 §7). The finding above still stands (a return is the common path), but "tab" is
> the wrong model: see C-123 §9 for what that context does to the Hub's own sign-in. Each return replaces
the mission list with grey blocks and rebuilds it.

The refetch is right, and the comment explaining it is right: the server is the only
authority and nothing is ticked optimistically. What is wrong is that a **refresh** is
being presented as a **first load**.

The same shape is on the admin page: `onDone={() => void load(filter)}` after every
action, so recording one payout flashes the whole queue.

### Fix

Separate the two states. `loading` for the first load only; a `refreshing` flag for
subsequent ones, which the shell either ignores or shows as a hairline. The page keeps
what it has on screen while the numbers update underneath.

---

## F3 — An unknown admin action defaults to `paid` · **P2**

### Evidence

`/api/admin/campaign/claims/route.ts`:

```ts
const action = body?.action === 'reject' ? 'reject'
  : body?.action === 'send' ? 'send'
  : body?.action === 'unpaid' ? 'unpaid'
  : 'paid';                                  // ← everything else
```

A closed set was chosen deliberately — the comment says so, and it is the right instinct.
But the **fallback** is the action that records a payment.

### Why it matters

Not exploitable today: `markPaid` requires a 64-hex hash that the chain confirms and that
no other seat holds, so a stray action cannot mark anything paid. **The defence is
downstream, and it holds.**

The defect is the default itself. A malformed body, a typo in a future caller, or a
client sending `action: 'Paid'` lands on the money-recording branch rather than being
refused. P6 says doubt resolves to deny; here doubt resolves to the most consequential
verb in the set.

### Fix

Unknown action → `400`. The route already rejects a missing `id` that way.

---

## F4 — Share is offered on a closed campaign · **P3**

`actions={<ShareCampaign … />}` is passed to the shell unconditionally, outside the
`status?.open` branch that governs everything else on the page.

Somebody who shares after the round ends sends their contact to F1's screen. The share
text is deliberately free of numbers so it cannot go stale — but it can still point at a
door that is shut.

**Fix:** render it only while `status?.open`.

---

## F5 — The service's own sentence is discarded · **P3**

`/api/bff/campaign/me`:

```ts
if (!res.ok) throw Object.assign(new Error('Could not load your campaign progress'), { status: res.status });
```

The status survives; the **reason** does not. This is the pattern tec-app #239 removed
from ten other BFF routes after it cost four rounds of diagnosis on a single incident —
two unrelated causes arriving as one number.

Impact today is low: the page catches this and renders `me = null`, so the message is
never displayed to anyone. It is listed because the route is one edit away from surfacing
it, and the edit would restore a defect that was already paid for once.

**Fix:** carry `data?.message ?? data?.error` the way the claim route does.

---

## What was checked and found correct

Stated explicitly so it is not re-discovered as a finding later.

| Property | Evidence |
|----------|----------|
| Owner is never a request field | `claim` / `withdraw` / `changeAddress` / `me` all resolve the owner from the verified JWT |
| Seats cannot be double-allocated | `seat @unique` + retry that re-reads the taken set; a race loses on a constraint, cleanly |
| A rejected claim returns its seat | `reject` writes `seat: null` — the hundred seats are the budget |
| One wallet, one reward | `wallet_address @unique`, checked before the insert so the answer is a sentence and not a constraint error |
| A payout cannot be faked | `markPaid` requires 64-hex, refuses a hash another seat holds, then **asks the chain** whether it paid this address this amount |
| Unreadable state fails closed | status BFF returns `{ open: false }` — never invites a claim it cannot confirm |
| Admin is checked where it counts | route + service; the UI gate is cosmetic and documented as such |
| The admin list carries no internal key | deliberate — identity-service would read it as ServiceActor and skip the role check on a list of every claimant's wallet |
| A terminal payout is not reversible by the claimant | `withdraw` refuses a PAID claim |

---

## Correction to this report's own classification

The first version of this section was headed *"Decisions, not defects"* and listed four
items. **That heading was wrong about one of them, and the error is worth correcting in
place rather than quietly.**

The test is: **a defect produces a wrong outcome. A gap produces the right outcome with
more work.** Applied honestly:

| Item | Verdict | Why |
|------|---------|-----|
| **Taps counted as arrivals** | **DEFECT** | Produces a WRONG NUMBER — an app reporting 5 engaged pioneers while Pi counts 0. It was found, named a defect, and fixed this session. Listing it beside the other three implied it was a choice. It was not. |
| No claim rate limit | **Hardening** | The protections that matter are `owner @unique`, `wallet_address @unique` and the eligibility check — **database constraints, not counters**. A thousand attempts yield at most one reward. What they yield is load. |
| No search in the payout queue | **Gap** | Right answer, more scrolling. |
| No export | **Gap** — and weaker than first stated | The report said *"for reconciliation"*. Reconciliation is **already done**: every `tx_id` is verified against the chain as it is written. Export is convenience, not correctness. |

**So the campaign's defect count for this session is SIX, not five** — F1–F5 plus the
tap/arrival defect — and the sixth was the most serious of them.

All three remaining items were built anyway (below), so the distinction is now historical.
It is recorded because a report that mis-sorts its own findings teaches the next reader
the wrong test.

---

## Built after the report

| Item | What shipped |
|------|--------------|
| **Claim attempt limit** | 12 attempts / 5 min per pioneer, env-overridable, counted **before** any query — the queries are the thing being bounded. Keyed on the canonical owner, so a different capitalisation of your own username is not a way around it. The refusal names a **wait**, not an accusation: the likely reader is somebody whose address keeps being refused, and being called an attacker on a screen offering free Pi is how a pioneer leaves for good. |
| **Search** | Seat, username or address — the three things somebody arrives holding. Client-side over the loaded round, because 100 rows is not a pagination problem. The **total stays on the whole queue**: a figure that shrinks as you type will be read as the amount owed, and reported as one. |
| **Export** | CSV of exactly what is listed, filter and search included — a file containing more than the list above it is a quiet lie. Every cell quoted, internal quotes doubled (a username is user-supplied text; one bare comma shifts every later column), UTF-8 BOM so Excel does not mangle a non-ASCII name. |

> **Two limits of the attempt counter, written into the code rather than left to be
> found:** it resets on deploy, and it is **per instance** — with N replicas the real
> ceiling is N × the limit. Both are fine for a load bound and would be unacceptable for
> an anti-fraud control. It is not one; the `@unique` constraints are, and those hold
> across every replica and every deploy because they live in the database.

---

## Second pass

Re-read after every fix above was applied. **No new defects.** Stated plainly rather than
padded: a second audit that always finds something is an audit that is inventing.

What it did produce:

1. **The attempt limiter's scope was understated.** The comment said "resets on deploy"
   and did not say "per instance". Corrected in place — a control whose real ceiling is
   unclear is a control somebody will later mistake for a guarantee.
2. **The export carries 100 wallet addresses into a file.** Not new exposure: the admin
   already sees every one on screen, and they are public keys. Worth knowing that the
   file outlives the session the screen does not.

Checked and found correct on the second pass: no address is ever rendered that did not
come from the server; the admin role gate is still cosmetic-only with the route and the
service deciding; `qualified` cannot render `0 / 0` because `claim()` refuses an
unconfigured round; `claimed` excludes rejected seats, so a rejection really does return
its seat to the pool.

---

## Recommended order

All five findings and all three gaps are now **closed**. Remaining work on the campaign is
operational, not engineering:

1. Deploy `tec-core-backend` (carries `closed_reason`, the attempt limiter, the arrival
   endpoint and the `qualified` column).
2. Deploy the Hub and the 24 apps.
3. Watch `arrived` climb toward `verified` on `/pioneer/coverage`.
4. Set `CAMPAIGN_REQUIRE_ARRIVAL=true` once the gap closes. **Not before** — flipping it
   while half the fleet is undeployed fails every mission on the apps that had not caught
   up.

---

## Related

- `C-02` Session 56o — the campaign's first verified payout, and the tap-vs-arrival fix
- `C-47` — P6 Fail Closed, the rule F3 departs from
- tec-app **#239** — the incident F5 repeats the shape of
