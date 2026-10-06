# Life + TEC AI expansion — what is missing, the order, and the state (2026-10-06)

> Truth State: **[Current State]** for §1–§2 (read from the charters and the code on 2026-10-06)
> and for M1 · L1 · A1 · A2 · A3, all merged on 2026-10-06 (§4); **[Future Vision]** for V2, which
> stays a gate. Governance: **[Draft]** — the owner's question ("what is missing to expand Life and TEC
> AI?") answered and turned into issues the same day; no ADR, nothing in this plan changes a charter.
> Verification: **[Code Verified]** where a PR is named. Tracker: tec-knowledge-base #199.

## 1. Where the two stood on the morning of 6 October

**Life** (C-106 §11b): the six capabilities (goals · preferences · activity · skills · trajectory ·
intent), consent and the right to delete, and the outbound context door — which got its **first
reader** that morning (tec-app #284; Life's door had zero consumers since September).

**TEC AI** (C-104 §5.1): V1, the honest concierge — bilingual chat, routes to an app or page through
nav chips, an own-scope context (username · KYC · 5 goal titles · focus · Analytics activity) signed
so the browser cannot rewrite it, three providers in a fallback chain. It executes nothing.

## 2. What is missing

### Life

| # | Missing | Source | Note |
|---|---|---|---|
| 1 | **Phase 1 entirely**: spending timeline · a budget by category · cash flow | C-106 §10 | The only slice that serves a Pioneer who uses **no other TEC app** (the owner's rule for growth). Activity is presented from Analytics; there was no budget |
| 2 | **Nothing writes into Life from outside** | C-106 §10 Phase 3 · §11 P1-1 | Activity-inferred skills deliberately unbuilt; the charter itself says "without this Life is purely self-declared — low adoption" |
| 3 | The door's other readers: Connection, Ecommerce | §11b | Zero until the morning; one since |
| 4 | **Nothing Runtime Verified** | §11b | The Pace panel needs progress on two calendar days and has not been seen on a device; the sign-in door (C-123 §14) likewise |
| 5 | **§8 metrics never measured**: consent coverage · profile completion · retention | C-106 §8 | None existed anywhere |
| 6 | §10a (personal continuity) waits on a measurement no round runs | C-106 §10a · S7 Tec-Life #67 | The lost-phone question left Round 3 on 5 Oct |

### TEC AI

| # | Missing | Source | Note |
|---|---|---|---|
| 1 | **The context is narrow**: 5 goal titles + focus | `lib/ai/life-context.ts` | The door already serves skills and the pace when granted; the Hub drops them. One file |
| 2 | **V2, the orchestrator**: tool-calling · pre-filled intents · a plan handed to Nexus | C-104 §10 | Gated on P0-1 (C-94) and P0-2 (C-97) |
| 3 | Connection context | C-104 §10 V2 | Connection has no consent door of its own |
| 4 | **The intent-observation compiler writes and nobody reads** | `intent-observation.ts` | The `null` rows say what the closed set is missing; no screen or session reviews them |
| 5 | P1-1 CI check (AI code never calls payment-service) · P1-2 audit schema · P2 hallucination check | C-104 §11 | Not built |

### What connects them
The loop runs one way: Life → (consent door) → AI, and "Ask TEC AI" on a goal sends the person to
the Hub. The other direction — the assistant proposes a goal, the person confirms it **inside Life**
— is C-104 §1.5's own sentence (recommend + pre-fill; the human confirms in the owning app) and is
not execution; but §10 lists pre-filled intents under V2, so a line in the charter comes before the
code.

## 3. The order (decided with the owner, 2026-10-06)

```
M1  measure first       → consent coverage (C-106 §8) + assistant usage, counts only
L1  Life Phase 1        → a self-declared budget (Life owns the caps) + spending / cash flow PRESENTED
A1  widen the context   → skills + pace from the door, consent-gated, one file
A2  read the null rows  → an admin read of the intent observations that matched nothing
A3  close the loop      → the charter line, then [[go:life:goal?title=…]] → Life's Add form confirms
V2  gated               → Nexus · C-94 · C-97, only when the boxes in #198 are ticked
```

One step in flight at a time; a step starts when the one before it is merged and deployed. Three
rules hold throughout: measure before building · Life data leaves Life only through its consent door
(C-106 §5) · the assistant proposes, it never executes (C-104 §1.5).

**Deliberately outside the plan:** §10a (no measurement runs); activity-inferred skills and other
apps writing into Life (C-106 §11b keeps them unbuilt); Connection's consent door (a V2
precondition, listed there).

## 4. State

| Step | Issue | PR | State (2026-10-06) |
|---|---|---|---|
| M1 backend | Tec-core-backend #384 | **#387** | **merged** — `GET /identity/life/admin/consent-coverage` (admin, counts only, audited) · `GET /analytics/admin/ai/usage?weeks=` (platform scope; the count is the `ai.intent.observed` rows the Hub already writes per message, no new write) |
| M1 Hub | Tec-App #285 | **#289** | **merged** — `/hub/admin/life-ai`, linked from the profile's Admin section; the two halves fail independently and a failed half says *Could not read this (HTTP n)*, never 0 |
| L1 backend | Tec-core-backend #385 | **#388** | **merged** — `LifeBudget` (one cap per owner · app slug · UTC month, DECIMAL(20,8), string on the wire), `BUDGET` consent category (denied until granted), the door serves this month's caps only, purge deletes them. **Narrowing recorded on the issue:** identity-service keeps to the caps; spending is presented at the BFF, not fetched by identity |
| L1 Life | Tec-Life #73 | **#75** | **merged** — Budget and Cash flow on Home; `/api/bff/life/budget` and `/cashflow` read identity + payment-service + commerce-service with the session only and compose in `lib/life/money.ts` (exact micro-π); an unreadable amount is said, never 0; no net while a side is unknown. Campaign rewards not in "In" yet (the claim payload carries no amount) |
| A1 | Tec-App #286 | **#290** | **merged** — the assistant keeps what Life's door serves: skills (ladder word, max 5) when SKILLS is granted, the pace only when Life calls it projectable; signed in the context token and re-narrowed on the way out; the prompt routes toward a skill, never grades it, and states no number the context does not hold |
| A2 backend · Hub | Tec-core-backend #386 · Tec-App #287 | **#389 · #291** | **merged** — `GET /analytics/admin/ai/intent-observations` (the unmatched asks with their excerpt, no identity — `user_id` is never selected) and `/intent-objectives` (counts, `null` at zero); the card on `/hub/admin/life-ai` informs the closed set, never edits it |
| A3 KB · Life · Hub | tec-knowledge-base #197 · Tec-Life #74 · Tec-App #288 | **#200 · #76 · #292** | **merged** — C-104 §10.1 (pre-fill with confirmation in the owning app is V1); `/app?goal=&target=` fills Life's Add form, read inside the sign-in door and removed from the URL once read, nothing saved until Add; `[[go:life:goal?title=…]]` with a key whitelist, a required title, through the signed handoff |
| V2 | tec-knowledge-base #198 | — | closed to work, open as a record; its gate lists five conditions |

## 5. Found along the way

- **The gate did its job twice in one day.** A `"0"` cap passed the BFF's decimal regex (the
  identity-side check would have caught it, but the BFF should not forward it) — closed with a
  refine. And loading `useLife.ts` into the coverage denominator revealed that **none of the Life
  hooks had a unit test**: functions fell from 62.6 % to 53 % and the floor failed. The fix was 16
  tests for the hooks, not a smaller denominator. Coverage now 82 / 70 / 76 / 87.
- **A refused preferences save rolls back and the rollback read clears the error**, so the refusal is
  never shown. Pinned as it is; not fixed in this slice.
- **Backend CI runs again** (#387 · #388 green on every check) — C-02 row 10 is closed.
- **A squash-merged commit is not "in main" to `git cherry`**; a merge commit is. Check the PR's
  `merge_commit_sha` is an ancestor of `main` and that the files the commit touched are identical,
  then rebase or force-with-lease.
- **Playwright in the cloud session** needs `launchOptions.executablePath: '/opt/pw-browsers/chromium'`
  through a project-local config — the pinned headless shell is not installed there.

## Related

- `knowledge-base/C-106___LIFE_INSTITUTIONAL_CHARTER.md` — §8 (the metrics), §10 (Phase 1), §11b
- `knowledge-base/C-104___TEC_AI_INSTITUTIONAL_CHARTER.md` — §1.5, §5.1, §10, §11
- `memory/sessions/session-56t.md` §6
