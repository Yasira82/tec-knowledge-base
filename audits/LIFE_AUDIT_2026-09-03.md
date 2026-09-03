# TEC Life — Charter Audit (C-106)

**Date:** 2026-09-03 · **Scope:** `Tec-Life` (frontend) + `tec-identity-service/src/modules/life` (backend)
**Method:** read the code, then compare with C-106. Where the two disagree, the code is what runs.

**Truth State:** [Current State] · **Verification:** [Code Verified] · **Governance:** [Draft]

> **Since this audit was written (same day).** The findings below are kept as they were FOUND —
> an audit that quietly rewrites itself as work lands stops being a record of what was true.
> What has changed:
>
> | Finding | Now |
> |---|---|
> | L-1 identity anchor | ✅ Fixed — tec-core-backend #267. Also **re-classified**: shared, not split, and **latent** rather than exploitable. See the correction inside L-1. |
> | L-2 theme | ✅ Fixed — Tec-Life #44 |
> | L-3 twelve locales | ✅ Fixed — Tec-Life #44 |
> | Capability 4, skills | ✅ Built — #267 + #44, **self-declared half only** |
> | Capability 5, trajectory | ✅ Built — #268 + Tec-Life #46 |
> | Capability 6, intent signals | ✅ Built — #269 + Tec-Life #47 |
> | L-4 consent | ✅ Built — #269 + #47 |
> | L-5 purge | ✅ Built — #269 + #47 |
>
> **Every finding in this audit is closed, in one day.** That deserves a sentence of
> caution rather than a victory lap: closed means *merged and tested*, not *seen working
> on a phone*. What still needs a device or a prod read is named in C-106 §11b.
>
> The recommended order held. The identity anchor went first because everything below it
> writes rows keyed by it; the theme and locales went second, so Skills, Pace and Privacy
> were **built** themeable and translated instead of converted later — a cost this fleet
> has already paid twice. What the order did not anticipate is that consent would land
> **before** the reader it protects, which is the only sequence in which P0-1 means
> anything at all.

---

## The one-line finding

> Life is **live, correct in what it does, and doing about a third of what its charter says it owns.**
> Nothing here is broken. The gaps are *unbuilt*, and two of them are the reason the app cannot
> yet be what C-106 calls it: *"the memory of the TEC economic identity."*

---

## 1 · What C-106 says Life OWNS, against what exists

C-106 §4 lists six things. Three are built.

| # | Owned capability | State | Where |
|---|------------------|-------|-------|
| 1 | Goals and aspirations (self-declared) | ✅ **Built** | `LifeGoal` — CRUD, π target, progress log, auto-complete, Pro insights |
| 2 | Preferences and settings | ✅ **Built** | `LifePreference` — key/value, per user |
| 3 | Activity timeline (spending, trading, creating) | ✅ **Built, and built the RIGHT way** | Read live from Analytics (`/analytics/me/activity`); Life stores nothing |
| 4 | **Skills inventory** (self-declared + activity-inferred) | ❌ **Absent** *(built since — see the banner)* | no model, no endpoint, no screen |
| 5 | **Personal trajectory** (where the user is headed) | ❌ **Absent** | — |
| 6 | **Intent signals** (what the user is trying to do now) | ❌ **Absent** | C-106 §5 specifies Redis with a 30-min TTL. No Redis usage in the module at all. |

The whole backend is **168 lines of service + 114 of controller**. For comparison, Explorer's module
is 1,560 and Zone's is 694. That ratio is the finding: Life is the smallest module in the service and
the one with the largest charter.

### Why 4–6 are not "nice to have"

C-106 §2 — *"Without Life, TEC AI has no personal context, Connection has no relationship baseline,
and Ecommerce has no personalization signal."* Goals and preferences are what a user **says**.
Skills, trajectory and intent are what makes the context *usable by another runtime*. Today there is
no personal-context API to consume, because there is almost no personal context to serve.

---

## 2 · Findings that are about correctness, not scope

### L-1 · The identity anchor is one indirection away from the charter — **and can silently SHARE a user** ⚠️ HIGH (latent)

C-106 §11 P0-2 is explicit:

> Life data tied to `tec_user.piUsername` (permanent Pi identity). **Not** tied to internal TEC user
> ID (which could change). This ensures Life survives identity migrations.

`LifeGoal.user_id` is a foreign key to the identity-service `User.id` — an internal id. The comment in
`life.controller.ts` says the anchor is honoured, and *in the normal case it is*, because that `User`
row is unique on `pi_user_id`. The risk is in how the row is found:

```ts
const piUserId = (decoded.pi_uid ?? decoded.piId ?? decoded.pi_user_id ?? decoded.sub) as string;
const user = await this.identityService.findOrCreateUser({ piUserId, username });
return user.id;
```

Two hazards compound:

1. **The `?? decoded.sub` fallback.** A token that carries no Pi-uid claim resolves the *auth* user id
   into the `pi_user_id` column. The same person, arriving with a differently-shaped token, is then a
   **different `User` row**.
2. **`findOrCreateUser` creates** when neither `pi_user_id` nor `username` matches.

The failure is silent and total: the user's goals do not appear, nothing errors, and the old rows are
orphaned under an id nothing will look up again. `findOrCreateUser`'s own comment records that
"a different pi_user_id representation" has already happened once in production (it caused a 500 on
Life goals/preferences and the username fallback was added for it).

### It is worse than "split", and narrower than it first looks

Re-reading the resolution after this audit was written turned up the second half of the fallback:

```ts
username = pi_username ?? username ?? piUsername ?? 'unknown'
```

`piUserId` falls back to a value that DIFFERS per person (the auth id), while `username` falls back to
a literal that is the **SAME for everyone**. `findOrCreateUser` looks up by `pi_user_id` first and by
`username` second — so the first caller with no Pi username creates a row named `unknown`, and every
later one misses step 1, **matches it on step 2**, and is handed that person's identity: their goals,
their follow graph, their profile. That is not a split identity. It is a shared one, and it is an
Invariant #3 breach.

**Reachability — stated honestly.** The `register()` path that creates a Pi-less account exists in
`tec-auth-service`, but **sign-in is "Sign in with Pi" only**: such an account cannot get in to reach
these routes. The defect was therefore **latent, not exploitable in production**. The first write-up
of this finding overstated that, and the correction belongs in the record next to the finding.

**Fixed (tec-core-backend #267), and it was small.** Both fallbacks removed — a missing claim is a 401
(P6) — plus a guard inside `findOrCreateUser` that rejects a blank or placeholder username before it
touches the database, so a fourth caller cannot reintroduce it.

### L-2 · Light mode is impossible — 49 hardcoded colours in one file ⚠️ MEDIUM

`src/app/app/page.tsx` uses `TEC_COLORS.*` **49 times** inside inline `style={{}}`, and the repo has
**no `theme.ts` and no `palette.ts`** (Connection and Explorer both have them).

> A hex literal in an inline style cannot follow a theme — it is decided at render.

This is the exact root cause fixed in Connection (#56) and Explorer (#35–#37), documented as
**C-83 §5.5**. Life imports `tec-design-tokens.css` but nothing reads the tokens. The app is
dark-only, and cannot be otherwise without the same conversion.

### L-3 · Two languages out of twelve ⚠️ MEDIUM

`src/lib/i18n/` contains `ar.ts` and `en.ts`. Connection and Explorer each ship **twelve**
(en · ar · zh · vi · ko · id · hi · es · pt · fr · tr · ru).

Life is the most *personal* app on the platform — goals someone writes in their own words — and it
speaks the fewest languages. Ten of the twelve communities the rest of the fleet serves get an
English interface here.

### L-4 · No consent schema exists · C-106 §11 P0-1 📋 RECORD, don't panic

> *"Before any Life data is stored, define: consent schema (category-level, timestamped), deletion
> guarantees, data classification. Do not launch Life without legal/privacy review."*

Life data **is** being stored, and there is no consent model in the schema. The honest mitigation is
that the risk it guards against has not arrived: **nothing consumes Life data yet.** There is no TEC AI
reader, no outbound personal-context API, and no cross-app export. Access is own-scope only (P6 is
correctly enforced everywhere in the module — every query is keyed by the resolved session user).

So: not an active breach, and **it becomes one the day the first consumer is wired.** The consent
gateway (P1-2) must land *before* the personal-context API, not after — that ordering is the whole
point of it being a P0.

### L-5 · Right-to-delete is partial ⚠️ LOW

C-106 §5 promises *"purge all Life data while keeping payment records."* `deleteGoal` removes one goal;
there is no purge. `LifeGoal`/`LifePreference` cascade on `User` delete, so deleting the identity row
would take Life with it — but that is a different, much larger action than "delete my Life data".

---

## 3 · What is right, and should not be "fixed"

Worth stating explicitly, because a redesign is the moment these get broken by accident:

- **Activity is not stored.** It is read live from Analytics at request time. C-106 §4 says Life does
  not own transaction truth, and this honours it exactly. C-106 §11 P1-1 asks for a Redis consumer
  building a timeline — **the live read is the better answer** and should be recorded as satisfying
  P1-1 differently, not as an open gap. A second copy of payment history in Life would be a second
  thing to keep correct.
- **P6 is enforced consistently.** Every read and write is scoped by the resolved session user;
  ownership lives in the `WHERE` clause (`updateMany`/`deleteMany` by `id` + `user_id`), so a
  non-owner matches nothing rather than being caught by an `if`.
- **The goal tracker is genuinely well-built.** Progress clamps to `[0, target]`, auto-completes on
  reaching the target, and never resurrects a terminal goal.
- **Pro gating sits at the BFF**, not in the component — the aggregate is the paid value and the list
  stays free (P5).

---

## 4 · Recommended order

Sequenced so each step makes the next one cheaper, and so nothing is built twice.

| # | Work | Why here |
|---|------|----------|
| **1** | ~~L-1 identity anchor~~ ✅ | Done — tec-core-backend #267. Small, and everything below writes rows keyed by it. |
| **2** | ~~L-2 theme + L-3 twelve locales~~ ✅ | Done — Tec-Life #44. Doing it before the new screens exist meant Skills was *built* themeable and translated in twelve languages instead of converted later — the fleet has now paid that conversion cost twice. |
| **3** | ~~Skills inventory~~ ✅ | Done — tec-core-backend #267 + Tec-Life #44. **Self-declared only**: the `ACTIVITY_INFERRED` half is deliberately unbuilt, because inferring a skill means reading activity Analytics owns. `source` exists so an inferred row has an honest place to land. |
| **4** | **Trajectory** (capability 5) | Derived from goals + activity, both of which already exist. Nothing new to store except the projection. |
| **5** | **Intent signals** (capability 6) | Needs Redis + TTL (C-106 §5) and is the one that only pays off once a consumer exists. |
| **6** | **Consent gateway** (P1-2) | **Before** any personal-context API is exposed — not before the capabilities are built, but strictly before the first outbound reader. |

---

## Related

- `knowledge-base/C-106___LIFE_INSTITUTIONAL_CHARTER.md` — the charter this audits
- `knowledge-base/C-83___EVL_ESL.md` §5.5 — the theme contract L-2 refers to
- `knowledge-base/C-47` — P6 fail-closed, Invariant #8 (one owning service per entity)
- `knowledge-base/C-105` — Analytics, which serves the activity timeline
