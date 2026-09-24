# SESSION 27 — REPUTATION CHAIN RUNTIME-VERIFIED (real user) + ZONE → PI ECOSYSTEM (7 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Runtime Verified]** for the Epic → Legend chain (a real user completed an Epic project in prod → the achievement is recorded in Legend, and `epic.project.completed.v1` is visible in the Analytics event log) · **[Code Verified]** (merged) for the new surfaces below (each needs its Vercel/Railway redeploy to be Runtime Verified).

### Headline — the reputation value chain is now proven with REAL DATA
Sessions 20–21 wired the chain in code; **this session it fired for a real user end-to-end in production.** A pioneer (`yas55eR82`) created an Epic project ("Atlas"), completed it, and: (1) `epic.project.completed.v1` shows in the **Analytics Recent-events** feed (Aug 7), (2) Legend recorded a **verified achievement** ("Completed an Epic project") on their live profile. The `create → earn` edge is **[Runtime Verified]** with genuine user activity, not a seed.

### What shipped (deepening 3 chain apps into real, usable services)

**Epic (Creation) — from read-only preview → a real create+track surface (C-125)**
- **Create a project** — a signed-in pioneer actually makes a project (DRAFT/unverified/unfunded, unique slug, owner = session identity — P6). `EpicService.createProject` + `POST /identity/epic/project`; a `CreateProject` form on the board. Backend #190 · frontend tec-epic #17/#18.
- **Milestones** — the owner adds milestones + checks them off on `/project/[id]` (owner-only, server-side gated, terminal-safe, bounded). `addMilestone`/`setMilestoneDone` + `POST/PATCH …/milestone`. Backend #191 · frontend #18.
- **Epic → Zone verification request (C-121 create → verify)** — the owner asks Zone to verify their project; the BFF forwards the JWT to Zone's own gateway API (a clean service-API seam, C-132 — **no backend change**). Zone starts it PENDING; on VERIFY it emits `zone.badge.issued.v1` → Legend. frontend tec-epic #19.
- The always-visible fix: `CreateProject` no longer gated on the client-side `usePiAuth` flag (unreliable in Pi Browser — C-123); the BFF fails closed server-side (401). #18.

**Zone (Verification) — now serves the WHOLE Pi ecosystem, not just TEC (C-120)**
- **Public Trust Check** — a verified-first search over the live registry (backend `ZoneService.search` + `GET /identity/zone/lookup`; frontend `TrustCheck` on `/app`). Anyone (no TEC login) can ask "is X Zone Verified?". Backend #190 · frontend tec-zone #22.
- **Embeddable "Zone Verified" badge** — `GET /badge/<handle>.svg` renders the **live** verdict (verified · pending · revoked · not verified); a `ShareBadge` panel on `/verify/<handle>` (verified only) gives copy-link + copy-embed-HTML. A verified Pi project embeds it on its **own** site → every badge links back to the evidence → Zone spreads across Pi as the shared trust layer. Constitutionally sound: only an already-verified entity can broadcast (earned, never bought — C-120 §7). No backend. frontend tec-zone #24.
- **Review panel fix** — the reviewer queue was gated on the client `isAuth` flag (C-123) so a real ADMIN never saw it; now always loads, server decides. tec-zone #23.

**Legend (Reputation) — own & share your reputation (C-126)**
- **Own-view (bug fix)** — a real user could never see their own profile (only a `publicOnly` endpoint existed, profiles default PRIVATE). `GET /identity/legend/own/:owner` (includes PRIVATE; `{profile:null}` when none earned) + three honest home states (live · empty · sign-in). Backend #193.
- **Visibility control** — PUBLIC/CONNECTIONS/PRIVATE (the one user-controlled setting, C-126) via `setVisibility` + `PATCH …/visibility`; never creates a profile. Backend #193 · frontend tec-legend #17.
- **Shareable public CV** — `/u/<handle>` renders a PUBLIC profile ("Pi Professional CV"); a private/missing one is not discoverable. frontend #17.
- **0-score UX** — a real profile with achievements but no computed scores read as "empty 0"; now it leads with the achievement count + explains scores are Analytics-computed/pending. frontend tec-legend #18.

**Analytics (Intelligence) — scores become timely (ADR-013)**
- Legend scoring batch **24h → hourly** (`SCORING_INTERVAL_MS`) + `POST /api/analytics/scoring/run` (SOVEREIGN — internal/admin, C-122 §5) for an on-demand recompute. The pipeline was already wired (`epic.project.completed.v1`/`zone.badge.issued.v1` → `AnalyticsEvent` → `computeScores` → `legend.scores.updated.v1`); this makes a freshly-earned score appear within the hour, not the next day. Backend #194 (47/47 tests).

**Identity — admin bootstrap (the missing key, C-47/C-110)**
- There was **no path to ADMIN** (`findOrCreateUser` grants only USER), so Zone's review queue 403'd for everyone and verifications stuck PENDING. Added an env bootstrap: a Pi username in **`PLATFORM_ADMIN_USERNAMES`** is granted ADMIN on login (idempotent; only-write-if-missing; re-loads roles). The **only** path to ADMIN — no self-serve (P6). Backend #192. Runtime-verified: the operator became ADMIN and the Zone review queue rendered "Atlas".

### Honest gaps / notes
- **Separation of duties works as designed (not a bug):** a reviewer may not decide their **own** submission (C-120 §7), so the operator can't self-verify "Atlas". A real verification needs a different submitter — correct, and the whole point of Zone.
- **Scores → non-zero** requires the Analytics redeploy + one batch tick (or the on-demand endpoint). The `creator` dimension maps `epic.project.completed.v1`; the events are already in the log.
- **Strategic note (recorded):** the reputation apps (Epic/Zone/Legend/Elite/VIP) are chain-linked and mostly serve TEC-internal activity. "Packaging independence" (separate domains/logins) ≠ "value independence" (serving non-TEC Pi users). The apps with genuine outward value are **Zone** (public trust check + badge), **Legend** (public `/u` CV), **Explorer** (Pi-merchant discovery), and **Commerce/Ecommerce**. Direction agreed: make those few genuinely independent; treat the rest as the C-132 modules they already are, surfaced through Hub.

### PR ledger
Backend `tec-core-backend`: **#190** (Epic create + Zone Trust Check search), **#191** (Epic milestones), **#192** (admin bootstrap), **#193** (Legend own-view + visibility), **#194** (Analytics hourly scoring + recompute). Frontend: **tec-epic #17/#18/#19** · **tec-zone #22/#23/#24** · **tec-legend #17/#18**. All merged.
