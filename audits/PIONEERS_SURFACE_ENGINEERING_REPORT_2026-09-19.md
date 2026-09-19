# Founding 100 — Engineering Report on the Pioneer Surface

**Date:** 2026-09-19
**Scope:** `/pioneers` (public) · `/pioneers/faq` · `/hub/admin/pioneers` (coverage) ·
their BFF routes · `tec-identity-service` pioneer module
**Truth State:** [Current State] · **Governance:** [Draft] · **Verification:** [Code Verified]
**Reviewed at:** tec-app `80b3c28` · tec-core-backend `claude/tec-knowledge-base-review-6wzngc`
**Companion:** `CAMPAIGN_SURFACES_ENGINEERING_REPORT_2026-09-19.md` (the reward campaign)

---

## 0. Summary

This is the page the whole platform is pointed at. Twenty-four `.pi` domains were won
at auction and paid for, and Pi will not accept a claim until each app has **5 unique
KYC'd pioneers engage with it**. `/pioneers` is the instrument for clearing that bar
twenty-four times.

**The foundations are sound.** The owner is the verified JWT identity everywhere, never
a body field. The 100 cap is enforced by a database `@unique`, so a race cannot hand two
people the same number and a 101st simply gets none. The public counter reports real
figures and shows an honest zero. The roster on the server is a **frozen copy** of the
registry — a deliberate, correct decision, written down with its reasoning. The Founding
gift is fail-safe: commerce being down can never cost somebody the place they earned.
The coverage screen carries its own caveat next to its own numbers.

**Seven findings.** Three of them make the page state something the system does not do.

> **All seven are now closed** — tec-app `dc24a62`, tec-core-backend `6e9e533`.
> F3 was a decision, not a repair, and the owner took it: **the Founding badge is open
> to any Pi account.** So the claim came off the page rather than the gate going into
> the code. See *The decision on F3* below.

| # | Severity | Finding | Fires when |
|---|----------|---------|-----------|
| **F1** | **P1** | The Quest target is derived from a list that moves; the server's is frozen | The 25th app ships, or one app is taken off `live` |
| **F2** | **P1** | The completion banner fires on local state the server may not share | Any pioneer who opened an app during a backend blip |
| **F3** | **P1** | KYC is advertised, denied in the FAQ, and enforced nowhere | Now — and it is the only anti-sybil control the cohort has |
| **F4** | **P2** | The arrival fix is invisible on the screen that aims the campaign | Every time the coverage list is read |
| **F5** | **P2** | The Founding gift is not on the page that sells it | Every visitor |
| **F6** | **P3** | Three admin pages still walk past their parent | Any back tap from Profile → admin |
| **F7** | **P3** | The attribution breakdown is on a public endpoint | Anyone who reads one URL |

---

## F1 — The Quest target moves on one side and not the other · **P1**

### Evidence

Client (`PioneersClient.tsx`):

```ts
const total = LIVE_DOMAINS.length;          // a runtime filter
// _registry.ts
export const LIVE_DOMAINS = ALL_DOMAINS.filter(d => d.status === 'live');
```

Server (`pioneer.service.ts`):

```ts
export const QUEST_APPS: readonly string[] = [ /* 24, written out */ ];
export const QUEST_TARGET = QUEST_APPS.length;
```

The server's comment explains exactly why its list is frozen, and it is right:

> *"A campaign's terms must not move under the people running it. If a 25th app ships
> tomorrow, someone standing at 24/24 must not silently drop to 24/25 and lose a
> Founding place they already earned."*

**That reasoning was applied to one side only.** The client still derives its target from
the live registry, so the drift the server was protected from lands on the screen instead.

### Why it matters

Both directions are bad, and they are bad in opposite ways:

| Change | Server | Page shows | Result |
|--------|--------|-----------|--------|
| A 25th app goes `live` | still 24 → grants the number | `24 of 25 explored`, no banner, 96% | Told they have not finished something they were already paid for |
| An app is flipped off `live` (maintenance) | still 24 → grants nothing | `23 of 23`, **100%**, 🎉 banner | Told they finished; no number ever arrives |

The second is the one that will actually happen. Taking an app off `live` for an hour is
an ordinary operational act, and nobody performing it would expect it to promise a
hundred strangers a badge they cannot receive.

### The fix is already in the payload

`getStats()` returns `quest_target: QUEST_TARGET` — and the page fetches that exact
response and picks four fields out of it, dropping this one:

```ts
setServerStats({ claimed: …, remaining: …, pioneers: …, completed: … });
//                                    quest_target is right there, unread
```

So the correction is to read it, falling back to `LIVE_DOMAINS.length` only when the
server has not answered. The campaign's terms then come from the campaign.

> A test pins the Hub side at `toHaveLength(24)`, which does turn CI red when a 25th app
> ships. But the obvious way to make it green again is `24 → 25` — which is precisely the
> change that breaks the agreement. A guard that names the wrong number is worse than
> none, because it tells you to edit it.

---

## F2 — The banner celebrates something the server may not agree with · **P1**

### Evidence

```ts
const done     = effectiveVisited.length;   // localStorage ∪ server
const complete = done >= total;
…
{complete && <p>🎉 Quest complete — you opened all 24. You qualify for the
                 Founding Pioneer badge.</p>}
```

`markVisited` writes localStorage first and POSTs best-effort:

```ts
try { localStorage.setItem(QUEST_KEY, JSON.stringify(next)); } catch {}
void fetch('/api/bff/pioneer/open', { … }).catch(() => {});
```

and the server read merges as a **union**, which adds and never subtracts:

```ts
setVisited((prev) => Array.from(new Set([...prev, ...q.opened_apps])));
```

### Why it matters

If the POST fails — backend restarting, gateway shedding load, a tunnel, a dead
Wi-Fi handoff mid-navigation — the tick is in localStorage and nowhere else. It stays
there. The union never removes it. The app now renders `✓ Explored`, which is exactly
what stops the person from tapping it again, and tapping again was the only retry path.

So the page reaches 24/24, shows the celebration, and tells the reader they qualify —
while the server holds 23 and will never grant a number. The badge section reads the
server honestly (`foundingNumber` only ever comes from `/me`), so the two sections of
the same screen say opposite things, and the louder one is wrong.

This is the shape of the reward campaign's F1: a screen asserting at the emotional peak
something the server denies. There it was a full campaign reporting that it did not
exist; here it is an incomplete quest reporting that it is finished.

### Fix

Two parts, and the first alone is enough to stop the false promise:

1. Fire the banner on **server truth** — `/me` already returns `app_count` and
   `completed_at`. Local state can drive the bar; it must not drive the promise.
2. Give the failed write a way back: retry an un-POSTed slug on the next page load
   (the set difference between local and server is exactly the list of what to re-send),
   or mark a tick as unsynced so the ✓ does not close the door on it.

---

## F3 — Three different answers to the one question a Pi user will ask · **P1**

### Evidence

The page, in the badge section, to everybody:

> *"One condition: your Pi account must be **KYC-verified by Pi Network**, because only
> verified Pioneers count."*

The FAQ, in `schema.org` structured data — the text Google lifts into search results:

> *"**Do I need KYC?** Pi Network handles KYC itself for wallet, payments and domain
> claims. You do not complete a separate TEC KYC to be a Pioneer."*

The code, `recordOpen` → `assignFounding`:

```ts
if (completedAt && quest.founding_number == null) {
  return this.assignFounding(owner, args.userId);   // no KYC check anywhere
}
```

`kyc_verified` is written to the row and the service says so plainly — *"RECORDED, NOT
ENFORCED"*. The comment is honest. The page is not aligned with it.

### Why it matters

Strictly, the two sentences are reconcilable — the FAQ is denying a *TEC* KYC, the page
is asserting a *Pi* one. A careful reader gets there. **A cautious Pi user deciding
whether this is a scam is not a careful reader**, and this is the single question that
decides it. One surface says a verified account is required; the other says KYC is
somebody else's business. Neither is the rule the code follows.

And it is not only copy. The Founding cohort is a hundred places, each carrying **180
days of PRO** (F5), and its entire anti-sybil control is *"have a Pi account"* — which
is free until you verify. Compare the reward campaign, which went to the trouble of
`wallet_address @unique` for exactly this reason: a Pi account is KYC-verified or it has
no wallet, so one address is one verified person.

The campaign's stated purpose is to move Pi's count, and Pi's count moves **only** for
KYC'd pioneers. A Founding place taken by a non-verified account costs a real place and
moves that number not at all.

### Fix — pick one and make all three surfaces say it

- **Enforce it**: grant the number only when `kyc_verified`; a completed-but-unverified
  quest holds its place pending verification rather than consuming one. This makes the
  reward and the purpose the same thing.
- **Or drop the claim**: if the badge is deliberately open to any Pi account — which is
  a defensible choice, and the service argues for it well (*"asking a first-time visitor
  for identity documents to earn a badge reads as a scam"*) — then the page must stop
  saying it is a condition, and say instead that only verified pioneers count *toward the
  domain claims*, which is true and is a different sentence.

**What cannot stand is the current state**, where the page states a rule, the FAQ waves
it away, and the code enforces neither.

---

## F4 — The compass was repaired and the dial was never fitted · **P2**

`getAppCoverage` now returns, per app:

```ts
{ app, verified, arrived, unconfirmed, openers, threshold, still_needed }
```

`arrived` and `unconfirmed` are the entire product of this session's tap-vs-arrival fix —
the difference between engagement Pi will count and taps nobody can prove landed. The
admin page's row type is:

```ts
interface AppRow { app; verified; openers; threshold; still_needed; }
```

Neither new field is declared, and neither is rendered.

**So the screen that exists to aim the campaign still shows only the number the fix was
written to correct.** The honest `0`s would have been the point: they say the reporter has
not deployed yet. Instead there is nothing to look at, and the gap between taps and
arrivals — the one figure that says how much of the reported engagement is real — cannot
be seen at all.

**Fix:** add both to the row type and render `arrived` beside `verified`, with
`unconfirmed` as the muted context, the same way `openers` already sits beside `verified`.

---

## F5 — The best thing on offer is not on the page selling it · **P2**

Completing the Quest grants **180 days of PRO**, `FOUNDING_GIFT_DAYS`, via commerce.
The page's badge copy, in full:

> *"A permanent recognition in your TEC reputation (Legend / VIP) — reserved for the
> first 100 Pioneers to complete the Quest. It cannot be bought, only earned. Founding
> Pioneers get early access to new apps and features first."*

Six months of PRO is not mentioned on `/pioneers`, in the FAQ, in the OG description, or
in the share text. At the fleet's own Pro prices that is roughly 30–60π of value, offered
to a hundred people, and nobody is told.

This is not an engineering defect — nothing computes a wrong answer. It is the largest
conversion gap on the surface, on a page whose only job is conversion, and it belongs in
a report about being ready for the campaign.

> One caution if it goes on the page: it must be described the way the system delivers
> it — a **6-month period that ends**, because there is no auto-renewal by design and
> `giftFoundingPro` is explicitly fail-safe. "Free PRO for Founding Pioneers" with no
> end date would be a second promise the code does not keep.

---

## F6 — Three admin pages still walk past their parent · **P3**

`HubSubShell` gained `backTo` this session. Two pages use it:

```
/hub/admin/campaign           backTo="/hub/campaign"      ✅
/hub/admin/campaign/diagnose  backTo="/hub/admin/campaign" ✅
/hub/admin/pioneers           — defaults to /hub           ❌
/hub/admin/feedback           — defaults to /hub           ❌
/hub/admin/kyc                — defaults to /hub           ❌
```

All three are reached from `/hub/profile` (its four admin buttons), so back takes you
past the page you came from and out to the Hub — returning means navigating in again.
The same defect that was fixed, in the same component, on the same day.

**Fix:** `backTo="/hub/profile"` on all three.

---

## F7 — The attribution breakdown sits on a public endpoint · **P3**

`/api/bff/pioneer/stats` is `requireAuth: false` **by design** — `/pioneers` is public and
needs the counter. The response now also carries:

```ts
by_source: [{ source: 'x|social|launch|-', pioneers: 12 }, …]
```

The page hides the counter behind `isPioneerAdmin`, and the code says what that is:

> *"NEXT_PUBLIC_PIONEER_ADMINS … not a secret, purely a UI gate"*

That is accurate and honest — but the consequence is worth stating plainly: **the counter
is hidden, not private.** One request to a public URL returns the real claimed count, the
pioneer total, and which marketing channel is converting.

Nothing here is personal data and no per-user row is exposed. The point is that the
endpoint's publicness was decided when it carried only counts; `by_source` was added
afterwards and widened what a public URL discloses without that decision being re-taken.

**Fix (if it matters to you):** keep `founding_claimed` / `founding_remaining` /
`total_pioneers` / `completed` / `quest_target` public — the page needs them, and F1's fix
needs `quest_target` — and move `by_source` behind the admin read that already exists.

---

## What was checked and found correct

Stated explicitly so it is not re-discovered as a finding later.

| Property | Evidence |
|----------|----------|
| Owner is never a request field | `/me`, `/open`, `/arrived` all resolve the owner from the verified JWT; the by-owner IDOR is closed and commented |
| The hundred cannot be over-issued | `founding_number @unique`; `assignFounding` recounts and retries on `P2002`, and simply stops at the cap |
| A slug cannot be invented | Roster on the server (the authority) + a registry pre-check in the BFF (readable 400). The `'a'..'x'` forgery is dead on both sides |
| The counter is honest | Real aggregates; the demo seed row was removed *because* it inflated `total_pioneers`; shows 0 rather than a fake number |
| The gift cannot cost a place | `giftFoundingPro` never rethrows — commerce being down leaves the number written and the gift re-grantable |
| The gift cannot be double-granted | `once: true` + `note: "Founding Pioneer #N"` as the idempotency key |
| A destructive reset is awkward and audited | `role === 'admin'` on a verified token, **no** internal key, an exact confirmation phrase, and the audit row written *before* the delete |
| The coverage number does not overstate itself | The service's caveat is returned with the data and rendered beside it — "below the threshold is reliable; at or above it is not a confirmation from Pi" |
| Admin coverage forwards the user, not a service key | Deliberate, tested, and commented: `x-internal-key` would make identity-service skip the role check |
| The OG image uses no CSS variables | Satori resolves none; the file says so and uses literals |
| Attribution is bounded before it reaches the DB | `sanitizeSource` — lowercase, `[a-z0-9_|.-]`, 200 chars; marketing metadata, never used in logic |
| A missing `source` column cannot break the counter | Both the `groupBy` and the upsert degrade and retry without it |

---

## Two things this report deliberately does **not** call defects

The test from the companion report applies: **a defect produces a wrong outcome; a gap
produces the right outcome with more work.**

| Item | Verdict | Why |
|------|---------|-----|
| `getAppCoverage` reads every row into memory | **Not a defect** | A hundred rows. The service says so and chose clarity over a clever query. It becomes one at a scale this campaign is capped below. |
| No refresh control on the coverage screen | **Gap** | Right answer, a page reload away. Worth adding; nothing is wrong without it. |

---

## The decision on F3 — and what it costs

F3 was the only finding that could not be repaired, because there was no "correct"
state to restore: the page, the FAQ and the code each described a different campaign,
and somebody had to say which one was real.

**The owner's decision: the badge is open to any Pi account.** No KYC gate goes into
`recordOpen`; the condition comes off the page instead, and the FAQ — which was right
all along — is now the surface the page agrees with.

That is the better of the two, and for the reason the service already argued:

> *"asking a first-time visitor for identity documents to earn a badge reads as a scam
> and costs more trust than it buys"*

A KYC gate on a free badge, at the top of a funnel, on a platform strangers are being
asked to trust for the first time, would suppress exactly the participation the campaign
exists to produce.

**The cost, recorded rather than glossed:** the hundred places now have no anti-sybil
control beyond *"have a Pi account"*, which is free until you verify. The report raised
this; it is real and it is accepted.

What blunts it is not the badge but the gift. `giftFoundingPro` grants a subscription
bound to the Pi identity, and the service says why that shape was chosen:

> *"a PRO month is bound to the Pi identity and cannot be sold or moved, so a hundred
> harvested accounts are a hundred subscriptions nobody can use"*

A farmed place yields a badge on an account nobody is, and six months of PRO nobody can
spend. The cost of taking one is twenty-four real app visits. **The economics do the work
the KYC gate would have done, without the funnel damage** — which is why this decision
stands on its own rather than merely being the owner's call.

One consequence stays true and is worth keeping in view: **the campaign's reward and the
campaign's purpose are now deliberately decoupled.** Founding places measure completion;
Pi's domain threshold measures verified engagement at the app. They are different
numbers, they will diverge, and the coverage screen (F4) is where that divergence is
read. That is the screen to watch, not the Founding counter.

---

## What shipped

| # | Fix | Where |
|---|-----|-------|
| F1 | `quest_target` read from the stats response; `LIVE_DOMAINS.length` demoted to a fallback; the grid counts live apps separately | tec-app |
| F2 | Banner reads `completed_at`; the `/open` response is believed; the local↔server difference is re-sent on load | tec-app |
| F3 | The KYC claim removed from the page, both languages; page and FAQ now say the same thing | tec-app |
| F4 | `arrived` + `unconfirmed` declared and rendered beside `verified` | tec-app |
| F5 | The 6-month PRO gift named on the page, the FAQ and its structured data — worded as a period that ends | tec-app |
| F6 | `backTo="/hub/profile"` on pioneers · feedback · kyc | tec-app |
| F7 | `by_source` stripped from the public counter, moved to the admin `/coverage` | tec-core-backend |

**Gates:** tsc 0 · vitest **2663/2663** · lint 0 errors · build clean (Hub) ·
tsc 0 · jest **1257/1257** across 52 suites (identity-service).

### On the tests

`pioneers-copy.test.ts` was pinning `"Needs a Pi-verified account"` into the hero — a
condition that was never in the code. **The tests were doing their job and holding the
wrong sentence still.** They were rewritten to pin what is now true rather than deleted,
because the risk they guard against is real: this page will eventually be edited by
somebody who wants it to sound more exclusive, and "verified accounts only" is the first
thing that reaches for.

Two client tests asserted the banner firing from local state. Both now supply
`completed_at`, and a new one pins the inverse — **local-only completion must not promise
the badge.** Reverting either of F1 or F2 fails five tests; that was checked by actually
reverting them, not assumed.

---

## Recommended order

All seven are closed. What remains is operational, and the ordering is the same as the
reward campaign's:

1. Deploy **tec-core-backend** — it carries F7, and F1's fix depends on `quest_target`
   reaching the page. Until it does, the page runs on its `LIVE_DOMAINS.length` fallback,
   which is the pre-fix behaviour. Correct, and not yet the fix.
2. Deploy the **Hub**.
3. Deploy the **24 apps** (the arrival reporter), then watch `arrived` climb toward
   `verified` on the coverage screen — which can now show it.

> **F1 and F4 are both only half-live until step 1 and step 3.** A merged fix that
> depends on a deploy is not a working fix, and the honest reading of the coverage screen
> before step 3 is *"nothing has confirmed anything yet"*, not *"nobody arrived"*.

---

## Related

- `CAMPAIGN_SURFACES_ENGINEERING_REPORT_2026-09-19.md` — the reward campaign's six
- `C-02` Session 56o — the tap-vs-arrival fix whose output F4 does not render
- `C-47` — P6 Fail Closed; Invariant #3 (one principal), which F3's sybil argument rests on
- `C-108` — Explorer's charter, the nearest statement of "verified is Pi's word, not ours"
