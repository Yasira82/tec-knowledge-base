# SESSION 56h — Phase 4 begins: what a human authorized, and a delta that only narrows

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

`tec-core-backend #316` — IIC **4.1 + 4.2** in `tec-identity-service`. A module beside the
engine it extends, not a new service (C-132; no T1–T4 trigger exists).

> ⚠️ **SCHEMA PUSH REQUIRED.** `npm run db:push && node dist/main` as the Railway start
> command on `tec-identity-service`, redeploy, then put it back. Two additions: the
> `intents` table + `IntentStatus`, and `nexus_runs.intent_id`. Push BEFORE deploying the
> code that reads them — the reverse is an outage, not a warning (Session 56c).

### 4.2 — one asymmetry does all the work

```
Narrowing is always allowed.  Widening never is.
```

An agent may spend less, exclude more, trust a narrower set or finish sooner without
asking. It may not spend more, reach a service it was not given, remove a human
checkpoint, or buy itself time. Every widening is CRITICAL, and CRITICAL means a new
human signature — not an agent's assertion that it is fine.

**The comparand is the human-signed ROOT, and there is no variant that takes a
predecessor.** No single step widens a budget from 250 to 400; five steps widen it by 30
each and every one looks reasonable beside the step before it. A test walks that exact
path.

**Where the thinking actually went: being honest about what cannot be compared.**

| Case | Verdict, and why |
|---|---|
| A hard constraint whose value is a **string** | CRITICAL. There is no ordering on strings, so `zone_verified → any_seller` cannot be shown to be a tightening. A trust LADDER would let this be ordered — invented silently, it would be a ranking nobody signed. |
| The **operator** changed | CRITICAL. A different relation is not a narrowing. |
| `hard` re-classed to `soft` at the same value | CRITICAL. The subtlest widening in the spec: nothing moved, and the limit stopped being a limit. A diff comparing values alone reports "no change". |
| A ceiling set to `null` | CRITICAL. `null` means unlimited — the largest widening there is, and the one an off-by-one would let through because no number in the file ever showed it. |

A delta that only knew how to compare numbers would have passed every one of those.

### 4.1 — a DRAFT authorizes nothing

Only `confirm()` — an explicit act by the owner — makes an intent citable. A revision is
a NEW ROW under the same `root_id`, never an edit, which is what keeps the signed root
reachable at version 6. Someone else's intent is NOT FOUND rather than forbidden: telling
a caller an id exists but is not theirs answers a question they had no right to ask.

`NexusRun.intent_id` is nullable and additive — every run today has none and behaves
exactly as before. **But a nullable foreign key with no rule is a comment in a table**, so
`startRun` asks `IntentService` (a service API — the R-2-clean seam, C-132 §7.5) whether
the cited intent is the caller's own, CONFIRMED and unexpired, and creates nothing if not.

This **records**; it does not gate. `/check` returns a verdict rather than enforcing one —
enforcement is 4.4, in front of the dispatcher, and two places answering "may this
proceed" is the duplication the last several sessions were spent removing.

### The bug the tests caught

`fingerprintOf()` was hashing **preferences**. TypeScript's structural typing accepts a
wider object for a `BindingFields` parameter, so passing the whole normalized intent
compiled cleanly and quietly included `preferences` and `temporal`.

> Every legitimate re-ranking would have moved the fingerprint — making the one signal
> that detects real drift fire constantly. **A signal that fires constantly is one nobody
> reads**, which is the same failure as the detector in 3.2 that fires on noise. §4.2 says
> preferences are excluded; the function now PICKS its five fields instead of trusting its
> parameter type.

### Status

- 1154/1154 green (55 new), typecheck + build clean. `[Code Verified]`; it becomes
  `[Runtime Verified]` after the schema push and a deploy.
- **Next: 4.4** — `intent.gate.ts`. Everything it needs now exists: 2.1 made the
  dispatcher real, 4.1 gave a run an intent to cite, 4.2 produces the verdict. It is the
  first step where this layer stops recording and starts refusing.
