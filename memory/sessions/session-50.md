# SESSION 50 — THE DEAD BADGE: FIVE VERIFICATION SURFACES THAT COULD NEVER FLIP (2 Sep 2026) ◐

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** for what merged · **[Planned State]** for what is in
> review · Verification: **[Runtime Verified]** only where named below, **[Code Verified]**
> everywhere else.
> **Merged:** Tec-Explorer **#31 #32 #34 #35** · tec-core-backend **#261 #262 #263**.
> **In review:** tec-core-backend **#264** · Tec-Zone **#36** · Tec-Explorer **#36** ·
> Tec-Estate **#30** · Tec-Epic **#34** · Tec-Nx **#28**.

### 1. The finding that organises the whole session

A `verified` column, read by the app, **ranked by** in the query, rendered as a badge,
and documented in a comment explaining where it comes from — with **nothing anywhere
writing it**. Found in **five** places, independently:

| Surface | Column | State before |
|---|---|---|
| Explorer | `ExplorerVerification` | Wired to the WRONG EVENT (below) |
| Connection | `ConnectionProfile.verified` | No writer at all |
| Epic | `EpicProject.zone_verified` | No writer at all |
| NBF | `NbfBusiness.zone_verified` | No writer at all |
| Estate | `zoneVerified` (frontend) | No writer, and none possible |

**Why this is worse than a missing feature.** Each of these lists orders trust-first:

```
orderBy: [{ verified: 'desc' }, { featured: 'desc' }, … ]
```

With the earned signal pinned `false` for every row, the ordering collapses onto the
**next** key — `featured`, which is a Pro placement and is **bought**. Every one of these
directories was ranking by the paid signal *because the earned one was empty*. Connection's
own `DirectoryCard` carries a comment warning against exactly that inversion, above code
that had been doing it since the column was created.

> **The rule this session earned:** a column that is READ and RANKED BY but never WRITTEN
> does not fail loudly — it silently promotes whatever key sorts after it. Adding a trust
> field and its writer must be one change, or the field is a lie with a sort order.

### 2. Explorer: the wrong event, not the wrong payload

The consumer listened to `kyc.verified`. Two separate errors, one visible and one not:

- **Constitutionally wrong.** KYC verifies a PERSON — an ID document and a selfie. It
  answers *"who is this?"* and cannot answer *"does this shop exist?"*. **C-120 §3 (WHAT
  ZONE OWNS)** lists `Merchants → Pi-accepting businesses` — word for word what the
  Explorer index holds. Explorer's own CLAUDE.md said KYC. **Two charters disagreed and
  the code followed the wrong one.**
- **Mechanically dead.** `kyc.verified` carries `{ userId, level }` — a UUID — while the
  consumer resolves a Pi username. `ownerOf` returned `undefined` every time, so
  `applyVerification` was never called. No error was logged, the consumer group existed,
  and every health check stayed green.

The zone events carry `piUsername` directly, which is the key `applyVerification` already
used — **the constitutionally correct source turned out to be the simpler one**, with no
identity translation left to get wrong.

### 3. Zone only ever announced half a decision

`reviewDecision` emitted on VERIFY and said nothing on REVOKE. A badge could be granted and
**never withdrawn**: Zone would show `REVOKED` while every consumer that had acted on the
grant kept displaying it. `zone.badge.revoked.v1` closes it.

> A verification that cannot be taken back is worse than one never given, **because it is
> trusted**.

### 4. Which verification vouches for what — the rule, in one place

Zone verifies four kinds of thing, and collapsing them into one boolean is how a badge
starts claiming something nobody reviewed:

| Consumer | Accepts | Because |
|---|---|---|
| Explorer (shops) | `MERCHANT` | A verified BUILDER is not a verified shop |
| Connection (people) | `BUILDER` + `MERCHANT` | Both are facts about the PERSON's own economic identity |
| Epic (projects) | `PROJECT` | |
| NBF (businesses) | `MERCHANT` | |

`PROJECT` and `COMMUNITY` never vouch for a person: **verifying a community does not vouch
for whoever registered it.**

The filtering lives in `ZoneService` (`hasVerifiedIdentity`, `verifiedNamesFor`) and
deliberately **not** in any consumer — deciding it in two places is how two answers start
to disagree.

### 5. Recompute, never toggle

Every consumer asks Zone for the current answer rather than flipping a boolean from
whichever event just arrived. Both reasons are correctness, not taste:

- **A person can hold several verifications.** Revoking a MERCHANT badge must not clear the
  flag while a BUILDER verification stands — a toggle would, and it would look like Zone
  withdrew something it never did.
- **Streams are at-least-once.** A recompute is idempotent by construction; only rows whose
  value actually differs are written, so a redelivery writes nothing.

### 6. Estate: a claim the platform cannot make at all

Estate showed **"🛡️ Zone Verified" / "Verification pending"**, listed **"Unverified"**, and
counted **"✓ Zone"** on its dashboard. All four were permanent, and no code could change
them — **Zone has no property type**. Its four kinds are PROJECT, MERCHANT, BUILDER,
COMMUNITY (C-120 §3). A building is none of them.

So "pending" promised a review that was not queued, could not be requested, and had no
process behind it. The label now reads **"Self-recorded"**, and the counter is removed
rather than left pinned at zero.

> When a badge cannot be backed, the fix is not a better data source — it is **saying what
> is true**. A permanent "pending" is a promise; "self-recorded" is a fact.

### 7. Zone's applicant surface was invisible

The whole verification workflow — submit an entity, attach evidence, watch the status —
was **built and rendering nothing**. `VerificationPanel` opened with `if (!isAuth) return
null` and was handed `usePiAuth().isAuthenticated`, which reads `document.cookie`. Pi
Browser stores `tec_user` so the SERVER can read it and client JS cannot (**C-123 §3**), so
on the only platform this ships to that value is always `false`.

The page already knew: `useMe()` is a server round-trip and the line declaring it carries
the C-123 note. Two call sites were missed.

**The identical bug had shipped in Explorer's "My Business" tab weeks earlier** — same
hook, same `return null`, same platform. It is now pinned by a test in both repos.

`ReviewPanel` is deliberately left NOT gated on the client flag: a genuine ADMIN can be
signed in with `isAuth=false`, and the backend answers 403 for a non-admin, so
authorization stays server-side either way (P6).

### 8. Fabricated verifications in fixture data

`PROJECTS` (Epic), `PORTFOLIO` (Estate) and `OPPORTUNITIES` (NX) carried `verified: true` on
twelve rows between them. A fixture wearing a verification badge is **the platform verifying
itself** — C-120 and C-108 §4 forbid it, C-135 §4 forbids a fabricated directory reaching a
screen.

None are rendered today; every page resolves live data. **That is precisely why it mattered:**
Explorer's seed was dead too, until someone wired it and eight invented businesses appeared
in production carrying six "Verified" badges. A fixture is one import away from being real.

All twelve are `false` now, with a test in each repo pinning it. In Epic **a test was
asserting the violation** (`expect(legend?.zoneVerified).toBe(true)`) — a test that requires
the badge turns the violation into a rule.

### 9. Explorer: trust became a ladder

Every real merchant was labelled **Unverified**, because the only other value required a
review that is not reachable end-to-end. A badge with one attainable value is not a badge —
it is a warning printed on everything, and `live · 0 verified` was permanent.

| | Means | Evidence |
|---|---|---|
| **L1** Self-listed | Nobody stands behind it | No owner (legacy rows only) |
| **L2** Pi account | A real person with a Mainnet wallet listed this | `owner`, written server-side from a verified session token |
| **L3** Verified business | A reviewer checked the business | Zone's verdict |

**L2 is not Explorer verifying anything** (C-108 §4) — it reports a fact already held. It is
**derived, never stored**: no enum change, no migration, and no trust column that can drift
from the facts it summarises.

### 10. Also shipped in Explorer (merged)

| | The decision worth keeping |
|---|---|
| **Arabic search** | Both the stored text and the query fold through ONE normalizer. ة/ه · أإآ→ا · ى/ي · tashkeel · tatweel · Arabic-Indic digits · `ال`. Folding one side only makes matching *worse*. |
| **Removing a listing** | A **redaction, not a delete**: `uniqueHandle` frees the slug when the row goes, so the next merchant with a similar name would inherit the previous business's reviews and moderation reports. Reviews and reports survive — otherwise "delete and re-list" clears a record. |
| **Five listings per owner** | Was one, which refused anyone with two branches. |
| **Light + dark** | The token file carried a `[data-theme='light']` block from day one that **nothing could reach**: 248 `TEC_COLORS` references are hex baked into inline styles, decided at render. Now `var(--tec-*)`, with CHANNEL tokens (`--tec-gold-rgb`) because `var(--tec-gold)22` is invalid CSS that **raises no error**. |
| **Map pin without a permission** | `navigator.geolocation` was the ONLY way to set one, and Pi Browser's host app decides whether it reaches the page. Now: tap the map, or paste coordinates. `٫` (U+066B) is the Arabic **decimal** separator — read as a comma it moves a pin thirty degrees, into the sea, in silence. |

### 11. What the audit cleared

| App | Finding |
|---|---|
| **Life** | No verification concept, and correctly so — a personal record has no entity to verify. Nothing changed. |
| **Commerce · Ecommerce · Assets** | `kycVerified` from the JWT is a **personal gate** ("KYC before you sell"), never a trust badge shown to buyers. Correct as-is. |
| **Nexus · System · Dx · FundX · Vip · Elite · Insure · Titan · Alert · Hub** | No verification claim rendered. Nothing to fix. |

### 12. Guards added, and why each exists

Every rule below fails **silently** when broken, which is why each is pinned rather than
reviewed:

- **Theme (Explorer, 23 tests)** — the alpha-on-a-token guard was rewritten twice because it
  only knew the shapes of bugs already found. Four forms shipped past earlier versions:
  `${C.gold}22`, `${(v ? C.gold : C.subtext)}55`, `C.subtext + '55'`, `rgba(5,8,22,0.92)`.
  *A guard that chases syntax one form at a time finds each bug once.*
- **Trust ladder (Explorer, 30)** · **pin fallback (23)** · **removal (12)**
- **Verification source (backend, 27)** — including that the health sensor moved WITH the
  subscription: left pointing at `kyc.*` it would report a healthy group on a stream
  Explorer no longer touches and miss a dead one on the stream it now reads.
- **Zone visibility (9)** · **fixture honesty (3 repos)**

### 13. Open, and honest about it

- **#264 is not merged.** Until it is, four badges remain unwritable.
- **L3 is unreachable in practice** even after merge: Zone's applicant surface needed
  **#36** to be visible at all, and no merchant has submitted anything. Explorer handles
  this honestly by showing L2 rather than a permanent "Unverified".
- **The Zone↔Epic join is by owner + NAME**, matching the frontend's existing
  `zoneStatusForName`. A stored `zone_handle` would be exact and is deliberately NOT added:
  nothing would write it without a submit-to-Zone flow inside Epic, and **a nullable column
  no code fills is precisely the failure this session was fixing.**
- **Runtime Verified** covers only what was seen on a real device: the Arabic search
  returning a real listing, the light theme, and the map. Everything else is
  **[Code Verified]**.
- **Fleet reality:** the Explorer index holds **one real listing** — the owner's own. The
  subscription-activation gap ran across 19 apps for months before anyone noticed. Both are
  evidence that the fleet has close to zero users, which is a product question and not an
  engineering one.
