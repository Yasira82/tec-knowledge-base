# SESSION 50.1 — THE HUB'S COLOURS WERE NEVER WRITTEN DOWN (3 Sep 2026) ◐

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

A one-line question — *"did you document the Hub's colour shades in the KB?"* — and the
answer was **no**, with a consequence already shipped.

**What C-83 actually had:** the dark WEALTH tokens, and `#FEA500` mentioned once in
passing inside a note about something else. Nothing on the light palette, the three
theme states, the channel tokens, the gold-family rule, the status-colour contrast, or
the top band. All of it live in the Hub for months, in code, in one repo.

**What that cost, the same week:** porting light mode to Explorer and Connection, the
Hub's values were not available to copy — so they were re-derived. Twice wrong:

| | Hub (authority) | What shipped | Effect |
|---|---|---|---|
| `--tec-gold-dark` (light) | `#E08800` | `#F08C00` | two apps a shade apart on the same button |
| `--tec-gold-light` (light) | `#FFC04D` | `#FFC24D` | " |
| status colours (light) | darkened (`#15803d` …) | **not overridden** | `#22C55E` on white ≈ **2.3:1** — every success line unreadable as text |

The status-colour miss is the serious one: it is a contrast failure, not a shade
disagreement, and the gold-family guard did not cover it because that guard was written
for the gold family.

**Closed:**
- **C-83 §5.5** — the theme contract, written as the AUTHORITY rather than a
  description: three states · the light palette table · *a token is a family, not a
  value* · status colours darken (with the measured ratios) · channels and the four
  shapes of the silent-failure bug · the top band + `.tec-on-band` · the two structural
  hex exemptions.
- Connection + Explorer realigned to the Hub's values, status colours darkened.
- A new guard in both: the light block must override `--tec-green/blue/red/purple` and
  their channels.

> **The lesson, and it is the fleet's oldest one.** A value that lives in one repo and
> nowhere else is not a standard, it is a coincidence — and the next app will re-derive
> it slightly differently. C-02 Session 46 recorded this exact shape (a rule existed,
> one repo followed it, nobody back-adopted it) and it recurred inside two weeks,
> because the fix then was to sweep the repos rather than to write the rule down.

### The follow-up question found a bigger gap

*"…the greys and blacks and off-white too, and the curves on the inner pages"* — and
reading the Hub to answer it turned up that **C-83 §4 declares three background values
the Hub stopped painting.**

| | C-83 §4 says "IMMUTABLE" | Hub actually ships |
|---|---|---|
| Layer 1 | `#050816` blue-black | **`#101014`** neutral charcoal |
| Layer 2 | `#0B1020` | **`#21212a`** |
| Layer 3 | `#111627` | **`#2c2c37`** |
| Layer 4 | *(none — only three layers)* | **`#383844`** |

A doc that declares "no app may override" over values the reference implementation
abandoned is **worse than saying nothing**: an app reading it adopts the wrong ground in
good faith, which is what all 23 of them did.

**Recorded as C-83 §5.6:** the neutral dark ramp and why it is neutral (a blue-black
pushes the Pi amber green); the warm off-white light ramp and why the PAGE is off-white
while the CARD is white; the four-step ink ladder plus `--tec-icon` and the two fill
washes; and the radius scale including `--tec-topbar-radius: 22px`, which sits between
`lg` and `xl` on purpose and applies to the bottom corners only. §4 gets a supersede
banner — kept, not deleted, because 21 apps still run it and the *structure* is still
right; only the numbers moved.

**Deliberately NOT swept.** Each app takes the ramp with its own change, verified on a
device, copying §5.6.1–5.6.3 rather than approximating them — that is the whole lesson
of 50.1, applied the same day it was written. Ramp first, then the band: a band tuned
against `#050816` and dropped onto `#101014` is a different band.

**First adopter, same session.** Connection took the ramp — `#050816 → #101014`,
`#0B1020 → #21212a` for the card — plus the four-step ink ladder and `--tec-icon`. It is
pinned by VALUE in that repo's `theme.test.ts` (verified to fail when the old ground is
put back), because a guard that only checks "a light override exists" would have passed
the re-derived amber above.

### The table, and the style law (C-83 §5.7 + §5.8)

Asked to write down **all** the colours and the style, because it goes into every app.
§5.5–5.6 explained the reasoning; §5.7 is now the lookup table (every token, both themes,
plus radius / spacing / type / shadow / motion / z) and **§5.8 is the component style
law** — eight rules, each written after the opposite shipped, each naming what went wrong:

| | Rule | What it cost |
|---|---|---|
| 5.8.1 | A filled accent is **flat** | 21 buttons in Connection, 10 in Explorer, gradienting `#FEA500 → #E08800` — a dirty patch on every one, in light |
| 5.8.2 | The accent gets **one meaning per surface** | a gold bubble per message drowned the one gold that meant something (you were **named**) |
| 5.8.3 | Icons from the set, **never emoji** | 📎🎤➤ carry their own colour, so no token reached them, and each platform drew them differently |
| 5.8.4 | **One slot** for a mode pair | the primary action sat grey and disabled most of the time, and the input paid for both in width |
| 5.8.5 | Chrome sits on a **surface** | composer + nav on one ground read as a single thick strip |
| 5.8.6 | The band's **proportions** are part of the shape | a 22px corner on a 117px band reads heavier than on an 87px one — same token, different curve |
| 5.8.7 | Three places take hex, and **only** hex | the exemption was one-directional, so a sweep put `var()` into the SSO landing and the share card — no ground, no accent, live |
| 5.8.8 | What a guard must check | by **value** not presence · **derived** not listed · for the **class** not the last bug |

§5.8.8 is the one that generalises: **five forms of a single silent failure shipped in
sequence, each past a guard written for the previous one.**

### Explorer joined the ramp

Same session, same values — flat amber, `#101014` ramp, four-step ladder. Two earlier
Explorer commits (the gold family + darkened status colours) turned out never to have
landed: **PR #36 merged an earlier state of the branch**, so `#22C55E` on white — ~2.3:1
— was still shipping there. Rebased onto current `main` rather than re-derived.

**Adopted: Hub · Connection · Explorer.** Remaining: 21.

**Still open:** the other 21 apps have no light theme at all and are on the old ramp.
When they move, §5.5–§5.8 are what they copy from.
