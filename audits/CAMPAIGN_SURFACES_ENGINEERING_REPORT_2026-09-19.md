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
the loop the page is built around, twenty-four times per pioneer. Each return replaces
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

## Decisions, not defects

Recorded so they are chosen rather than inherited.

1. **No claim-specific rate limit.** The gateway limits globally (NEW-V, in-memory). A
   claim endpoint that pays real Pi is a reasonable place for its own bucket.
2. **No search or sort in the payout queue.** Fine at one claim; a hundred rows on a
   phone is a scroll. Filter chips exist; a username search does not.
3. **No export.** Reconciling a hundred hand-sent payouts against the chain is a CSV away
   and currently a scroll away.
4. **Taps versus arrivals** — see C-02 Session 56o. Fixed in code this session, gated OFF
   until the fleet deploys (`CAMPAIGN_REQUIRE_ARRIVAL`). It is the single largest
   correctness item on the campaign and it is already in flight.

---

## Recommended order

**F1 first** — it is the only finding that damages the campaign at its best moment, and it
is roughly an hour: one field on `getStatus`, one branch on the page, two strings in each
locale.

**F2 next** — it is felt twenty-four times per pioneer and nobody will report it, because
a flashing skeleton reads as "the page is slow" rather than "the page is wrong".

**F3** whenever the route is next touched. The defence downstream is real, so this is
hardening, not a hole.

**F4, F5** are minutes each.

---

## Related

- `C-02` Session 56o — the campaign's first verified payout, and the tap-vs-arrival fix
- `C-47` — P6 Fail Closed, the rule F3 departs from
- tec-app **#239** — the incident F5 repeats the shape of
