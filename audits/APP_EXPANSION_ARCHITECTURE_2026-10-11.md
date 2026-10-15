# App expansion — domain hosts, the App Excellence Standard, and the order (2026-10-11)

> Truth State: **[Planned State]** · Governance: **[Draft]** — a proposal for the owner. It
> becomes law only when the owner approves it and assigns its numbers (an ADR amending C-132,
> and a C-doc for the standard — an AI never assigns a `C-NN`). Verification: **[Code Verified]**
> for every "today" fact below (read from the repos on 2026-10-11).

## 0. The three decisions (owner, 2026-10-11)

1. **`tec-identity-service` is closed to new domain modules.** It carries **21 domain modules** beside the
   identity core (`src/modules/`, 2026-10-11 — C-132 §7.5 still says 17) and is a named single point of failure (C-02 row 17).
2. **Where things go instead: "the right answer, engineering-wise"** → §1.
3. **Every app meets one written standard, checked by CI** → §2. Expansion starts with the
   apps that hold real data, Business & Opportunity, and Governance & Developers → §3.

---

## 1. Where things run — own services where the code earns one, domain hosts for the rest

### 1.1 Why neither extreme

| Option | Why not |
|---|---|
| One host for everything (today) | One deploy, one database, one event loop for ~20 apps: a bad migration or a hot path in one app takes down sign-in-adjacent identity for all (C-02 row 17). |
| One service per app | ~15 new Railway services, databases, secrets and dashboards, run by one person (C-02 row 17 again — the largest single point of failure is the operator). Most of these apps are read-heavy previews with a few tables. |
| **Own service where a trigger exists; one host per domain otherwise** | Apps that share a lifecycle, a data shape and a failure mode share a host. A failure is contained to one domain; the operator runs a handful of services, not dozens. This is what C-132's own §2 seam was built to make mechanical. |

### 1.2 The map — the target (owner, 2026-10-11)

Two kinds of new service: **own-service apps**, each with a T1–T3 trigger read from its code,
and **domain hosts** for the light apps that have none.

**Own service — the trigger is already in the code:**

| Service | App | Trigger (C-132 §5) | Evidence (2026-10-11) |
|---|---|---|---|
| **`tec-life-service`** | Life + the coach's data and schedule | **T3** — changes weekly, and every change redeploys identity (sign-in-adjacent) · **T2** — the most sensitive personal data (goals, budget, cash flow, intent) with its own consent model and purge · **T1 (soon)** — the weekly check-in and monthly review sweep every user | mentor steps 1–3 + budget shipped in one week (56u · 56t) |
| **`tec-ai-service`** | TEC AI — reasoning, provider keys, conversations | **T1** — long streaming calls to model providers, cost and rate limits, today inside the Hub's Vercel functions · **T3** — changes more than anything else · **T2** — provider keys and the prompt boundary | conversations land in identity first (tec-core-backend #411) and move here |
| **`tec-connection-service`** | Connection | **T1** — messages, reactions, groups, stories: write-heavy with realtime fan-out · **T2** — reports, blocks, moderation | `Message · MessageReaction · Story · StoryView · GroupJoinRequest · ConnectionBlock · ConnectionReport` |
| **`tec-nexus-service`** | Nexus | **T1** — a dispatcher loop running workflow steps inside identity's event loop (the NEW-W failure shape) | `NexusRun · NexusStep · nexus.dispatcher.ts · nexus.consumer.ts` |
| **`tec-search-service`** | Explorer | **T1** — full-text, geo and ranking (C-132's first flagged candidate) | `ExplorerBusiness · ExplorerReview · ExplorerReport`, Arabic normaliser |

**Domain hosts — light apps, no trigger of their own:**

| Host | Domain | Apps |
|---|---|---|
| **`tec-business-service`** | Business & opportunity | NBF → Titan · NX · Epic |
| **`tec-platform-service`** | Governance & builders | System · DX · Feedback (live 2026-10-15) · Pioneer + campaign (live 2026-10-16) — Intent moved with Nexus (2026-10-13) |
| **`tec-trust-service`** *(later)* | Evidence → recognition → privilege | Zone · Legend · Elite · VIP records — their **scores** computed in Analytics |
| financial **state** host *(when unlocked)* | Pools, protection, property | FundX · Insure · Brookfield — **T2 pre-emptive**; custody in payment-service forever (R-4) |

**Existing platform services take what is already theirs:**

| Service | Takes | Why |
|---|---|---|
| `tec-notification-service` | the Alert app's notifications (today `AlertNotification` in identity duplicates it) · Life's weekly/monthly alerts | one inbox, one table |
| `tec-analytics-service` | the computations its charters name: Legend scores · Elite criteria · Insure risk · Titan reports | computes, never owns records (eventual consistency). **Its database is the free Supabase tier (28 / 500 MB, C-02 row 14) — upgrade before adding load** |
| `tec-realtime-service` | live delivery for every app (notifications, Connection messages, a seller's new order, Nexus steps) | a transport with no database; today it relays `payment.completed` only |

**What stays in `tec-identity-service`:** identity, profile, KYC, roles — the core, stable,
deployed rarely.

**Cost, said plainly:** this is ~7–8 new Railway services beside today's 11, run by one person.
It is affordable only with the three rules of §1.4: create a service when its app is next worked
on (never all at once), from one backend template, watched on one page.

**Today: nothing moves.** Every module stays where it is and every open PR merges as written
(the owner, 2026-10-11 — including the AI conversations in identity, #411). This section is the
destination; §1.4 is how each step is taken, later.

The 11 core services and their ownership (C-68) do not change. A domain host changes **where a
module runs**, never **who owns its data** or its event names (C-132 §3).

### 1.3 The rule that makes it law — a fifth trigger

C-132 §5 allows a new service only on T1–T4. The amendment adds:

> **T5 — Host saturation.** A host that carries more than **8 domain modules**, or whose
> failure would take down more than **one domain**, is closed to new domains. New domains go to
> the domain host of §1.2, created when the first module that belongs to it is built or moved.

T5 does not license a service per app: a domain host must hold a **domain** (≥ 2 apps or one
app with a clear growth path), and every host it creates is a line in this map first.

### 1.4 How a module moves (no big-bang)

A module moves **when it is next worked on**, never all at once. Three rules keep the cost bearable:
a **`tec-service-template`** backend (health/ready · internal key · `migrate.cjs` · non-root Docker ·
tests · CI) so a new service is minutes, not days; **one monitoring page** for every service; and
**the order**: Life → TEC AI → Connection → Nexus → Explorer → business → platform.

1. Create the service from `tec-service-template` (NestJS · Prisma ·
   `migrate.cjs` · `/health` + `/ready` · internal key · non-root Docker) — once per host.
2. Copy the module folder (R-2 makes this a move: own tables, no cross-module joins).
3. Its tables: a new database for the host; data copied with a one-off, audited script
   (read-only on the old side), verified by row counts, then the old tables are dropped in a
   later deploy (expand → contract, never destructive in one step).
4. Gateway: the route for that path prefix points at the new host. One change, one rollback.
5. The app's BFF is unchanged — it already talks to the gateway path, not to a service.

The first host is created by the first piece of real work in its domain (§3), not before.

---

## 2. The App Excellence Standard — one checklist, scored in CI

Every app is a Next.js app cloned from `tec-template-base`, so one standard can be checked by
one script. Each line is **measurable**; "looks professional" is not a check.

### 2.1 The checklist (v1)

| # | Area | Requirement | How CI checks it |
|---|---|---|---|
| E1 | Failure states | `app/error.tsx` (a real error screen, with retry) · `app/not-found.tsx` · `loading.tsx` on data pages | files exist; error screen has a retry action |
| E2 | Empty states | A list with nothing in it says why and what to do — never a blank card | component test per list page |
| E3 | Languages | The fleet's 12 locales, same keys in every dictionary; `dir` follows the language | key-parity test across dictionaries |
| E4 | Design system | Colours from tokens only (`var(--tec-*)` / `TEC_COLORS`), no raw hex in components | the existing theme guard, made mandatory |
| E5 | Session | `SignInGate` door · C-123 cookie law · `cookieDomainFor` in every route that sets or clears a cookie · `tec_user` encoded once | the tests added in session 56v, mandatory |
| E6 | Payments | ADR-007 guard in every buy handler · `APP_SOURCE` set · amount a number (ADR-009) | the `payment-policy` CI job |
| E7 | Health | `/api/health` (never 500s) · `/api/ready` (503 when unusable) | existing route tests |
| E8 | No silent failures | every `catch` logs or says `/* ignore */` with a reason (C-96) | the existing no-silent-failures guard |
| E9 | Tests | coverage ≥ 60 % lines (raise per app as it grows) | `test:coverage` threshold |
| E10 | Accessibility | every icon-only control has an `aria-label`; images have `alt`; tap targets ≥ 40 px | `eslint-plugin-jsx-a11y` rules on, zero errors |
| E11 | Install & share | web manifest + app icon (C16) · Open Graph title/description/image | files + metadata present |
| E12 | Help & feedback | a Help/Support entry and the fleet Feedback form reachable from Settings | link present |
| E13 | Legal | `/privacy` · `/terms` with this app's name and domain | existing check |
| E14 | Pi Browser | an e2e smoke run in the Pi Browser user agent (sign-in door renders, home renders) | Playwright project |
| E15 | Performance | first-load JS for `/app` under a budget (start: 250 KB gzip) | `next build` output parsed |
| E16 | Real data or honest preview | a screen built on sample data says it is a preview; no invented numbers presented as real (C-135 §4) | `preview` banner when the data source is a fixture |

### 2.2 How it is enforced

- **`scripts/app-scorecard.mjs`** in `tec-template-base`: runs E1–E16, prints a score per
  area, exits non-zero below the app's floor. Added to every app's CI.
- **Floors, not cliffs.** Each app starts at the score it has today and may never go down
  (a ratchet, like the language-policy ratchet). New apps start at 100 %.
- **The template is fixed first.** Today the template itself has no `error.tsx`,
  `not-found.tsx`, `loading.tsx` or manifest, and three i18n files — so every app cloned from
  it inherited the gaps. A standard that the template fails is a standard nobody meets.
- The standard becomes a C-doc once approved (number by the owner); this table is its draft.

### 2.3 Today (sample, read from the repos 2026-10-11)

| | error.tsx | not-found.tsx | loading.tsx | manifest | i18n files | health · ready |
|---|---|---|---|---|---|---|
| tec-template-base | ✗ | ✗ | ✗ | ✗ | 3 | ✓ ✓ |
| Life | ✗ | ✗ | ✗ | ✗ | 15 | ✓ ✓ |
| Titan | ✗ | ✗ | ✗ | ✗ | 3 | ✓ ✓ |
| DX | ✗ | ✗ | ✗ | ✗ | 3 | ✓ ✓ |

---

## 3. The order

One step in flight at a time; a step starts when the one before is merged **and deployed**
(Vercel Hobby: count the day's builds first — session 56v §5).

| Step | What | Why first |
|---|---|---|
| **S0** | Owner approves this proposal; assigns the ADR and C-doc numbers | nothing below is law until then |
| **S1** | Template: E1, E3 (12 locales scaffold), E11, scorecard script | every later app inherits it |
| **S2** | Scorecard into all apps at today's floor (one commit per repo, pushed once) | stops the gaps from growing |
| **S3** | **Real-data apps to the standard**: Life · Connection · Explorer · Commerce · Ecommerce · Assets — E1/E2/E10/E11/E12 first | the apps people already use |
| **S4** | `tec-service-template` (backend) + one monitoring page | every later service is generated from it |
| later — one at a time, **when that app is next worked on** | Move to its own service, in this order: **Life** → **TEC AI** (with the conversations from #411) → **Connection** → **Nexus** → **Explorer** (search). Then the domain hosts: **business** (NBF → Titan · NX · Epic) and **platform** (System · DX · …); Alert into notification-service; scores into Analytics (after its database is upgraded) | the owner: "leave everything as it is now, and move later" (2026-10-11) |
| later | Trust chain onto `tec-trust-service`; FundX · Insure · Brookfield state host when their gates open | when that work starts |

## 4. What this does not change

- Ownership and write authority (C-68); event names (C-70); the payment custody rule (R-4).
- The ADR-007 payment modes, C-123 cookie law, the Hub SSO contract.
- The financial gates (FundX · Insure · Brookfield): legal + custody + SYSTEM first, as written.

## 5. Decided (owner, 2026-10-11)

1. T5 threshold: **8 domain modules** per host.
2. Performance budget (E15): **250 KB gzip** first-load JS for `/app`.
3. The first domain host: **`tec-business-service`**.

4. **Databases (owner, 2026-10-12).** Shared infrastructure, separate data: a new service gets a
   **logical database** on an existing PostgreSQL server (Railway Hobby allows 10 volumes per
   project and all 10 are used), with its own role, migrations and no read of another
   service's data. Not on `db-identity` by default, never on the payment / wallet / auth / KYC
   servers; the server is chosen from a read-only resource report. No Pro upgrade for volumes;
   restorable backups are a separate priority. Details and runbooks:
   `audits/DATABASE_PLACEMENT_AND_BACKUP_2026-10-12.md`.

The ADR and C-doc numbers are still the owner's to assign.

## 6. Language policy for new services (owner, 2026-10-11)

**TypeScript + NestJS is the default** for every new service. A service may be written in **Go**
only when a trigger is **measured** in production, not expected — e.g. the Nexus dispatcher,
once in its own service, showing CPU, memory or event-processing lag that TypeScript cannot
meet — and only after the CI guards that today scan TypeScript (no `body.userId`, no
`jwt.decode`, `timingSafeEqual`, the internal-key check) exist for Go as well: a service the
guards cannot read is a service the rules do not reach. Nexus is the first to be evaluated;
nothing moves now.

## 7. Progress

| Step | State |
|---|---|
| S1 — template: E1 · E3 · E4 · E10 · E11 · E12 · E14 · scorecard | tec-template-base **#52** (merged). Floor **13/13** + E15 (`/app` 112 KB of 250); jsx-a11y on with zero findings; `/help` + feedback to the fleet inbox; Pi Browser e2e 4/4. |
| S2 — scorecard in every app | 24 PRs (2026-10-11, open), one commit each; floors 3–6 of 13 (Commerce · Ecommerce 3 → Life · Hub 6). Template **#53** (open): E6 reads the ADR-009 drift step; the Hub's CI one level up. Found on the way: Commerce `refresh` sets cookies without `cookieDomainFor`; Analytics `logout` clears them without it |
| S4 — `tec-service-template` | tec-core-backend **#412** (merged): never deployed, CI builds and tests it; `scripts/new-service.mjs <name> <port>`. Verified against a real Postgres 16. Database placement decided (`DATABASE_PLACEMENT_AND_BACKUP_2026-10-12.md`) |
| Life → its own service | **Live 2026-10-12.** `tec-life-service` on `tec_life` (notification-realtime); the gateway routes `/api/identity/life/*` to it when `LIFE_SERVICE_URL` is set (#415). Data copied with every count equal; verified from the app. Left: the contract step (drop Life from identity) |
| TEC AI → its own service, step 1 (conversations) | **Live 2026-10-13.** `tec-ai-service` on `tec_ai` (notification-realtime, role `tec_ai_svc`, isolation read back); gateway `identity/ai` carve-out switched by `AI_SERVICE_URL` (#418). Identity held 0 conversations, so nothing to copy. Verified from the Hub: a new conversation lands in `tec_ai` and comes back after the tab is closed. Left: drop the module from identity |
| TEC AI → its own service, step 2 (reasoning) | **Live 2026-10-13.** `POST /identity/ai/chat` in `tec-ai-service` (#419: the Hub's route and its 15 specs, unchanged in behaviour; gateway waits 75 s for a first byte). The Hub forwards there and answers with its own copy whenever a reply lacks `x-tec-ai: service` (Tec-App #316). Provider keys (Gemini · Groq · OpenRouter; no Claude key, as in the Hub) set on the service. Verified: a direct call from the service console answered via Gemini, then a Hub question logged `[TecAiChat] chat 200 provider=gemini first_byte_ms=5739` (#420). Left: remove the Hub's local copy once the service has run cleanly for a while |
| Connection → its own service | **Live 2026-10-13.** `tec-connection-service` (tec-core-backend **#421**, port 5014) on `tec_connection` (db-storage): the 18 `connection_*` tables + `connection_audit_logs`, same `/identity/connection/*` paths. Users, "is @x on TEC?" and Zone's ✅ are asked of identity over `/internal/` routes. Copy: every count equal (messages 74 · conversation members 42 · hides 45 · trust events 16 · …); gateway `CONNECTION_SERVICE_URL` set; owner verified the app. Identity's Campaign asks the service for group messages (`CONNECTION_SERVICE_URL` on identity). The trust-signal consumer moved: `CONNECTION_CONSUMER_ENABLED=false` on identity, `true` on the service (log: `listening for trust signals`). Final copy after cutover: messages 76 in the service vs 74 in identity — two written after cutover, nothing missing. `SOURCE_DATABASE_URL` removed. **Rollback:** delete `CONNECTION_SERVICE_URL` on gateway and identity, set identity's consumer flag back to `true`. Left: drop the module and tables from identity; account deletion must reach Life · AI · Connection (an account-deleted event) |
| Nexus (+ Intent) → its own service | **Live 2026-10-13.** `tec-nexus-service` (tec-core-backend **#422**, port 5015) on `tec_nexus` (db-asset): `nexus_runs` · `nexus_steps` · `intents` · `intent_decisions` · `intent_approvals` · `intent_effects` · `intent_proofs`, same `/identity/nexus/*` and `/identity/intent/*` paths. **Intent moved with Nexus, not to the platform service** (owner, 2026-10-13): Nexus is its only caller and `nexus_runs.intent_id` is a foreign key to `intents` — this table's earlier grouping of Intent under `tec-platform-service` is superseded. One gateway switch, `NEXUS_SERVICE_URL`, moves both prefixes. `INTENT_PROOF_SECRET` is a reference to identity's value, so proofs signed before the move still verify. Copy: runs 16 · steps 61 · intents 0, every count equal; re-copy after cutover added nothing. Owner verified the app: templates listed, existing runs shown at `awaiting payment` with step 1 done. Payment resume moved: `NEXUS_CONSUMER_ENABLED=false` on identity (log `OFF here`), `true` on the service (log `Started — resuming runs on payment completion`). `SOURCE_DATABASE_URL` removed. **Rollback:** delete `NEXUS_SERVICE_URL` on the gateway, set identity's consumer flag back to `true`. Left: drop both modules and their tables from identity |
| Explorer → its own service | **Live 2026-10-15.** `tec-search-service` (tec-core-backend **#423**, port 5016) on `tec_search` (db-asset): `explorer_businesses` · `explorer_reviews` · `explorer_reports`, same `/identity/explorer/*` paths, no identity calls (standalone since C-132 §6). CI's 70 % line floor first failed at 68.4 % — the controllers' HTTP half had no spec; one was added (82.4 %). Copy: businesses 2 (one live, one retired — retired rows are kept, not shown), reviews 0, reports 0, every count equal; re-copy after cutover added nothing. Gateway `SEARCH_SERVICE_URL` set; owner verified the app: search, a listing page with its map and contact. Discovery signals moved: `EXPLORER_CONSUMER_ENABLED=false` on identity (log `OFF here`), `true` on the service (log `Started — listening for discovery signals`, four streams). `SOURCE_DATABASE_URL` removed. **Rollback:** delete `SEARCH_SERVICE_URL`, set identity's flag back to `true`. Left: drop the module and tables from identity |
| System + DX → `tec-platform-service` | **Live 2026-10-15.** tec-core-backend **#424** (port 5017) on `tec_platform` (notification-realtime): `system_policies` · `system_tier_defs` · `system_capabilities` · `dx_*` (4 tables), same `/identity/system/*` and `/identity/dx/*` paths, one gateway switch (`PLATFORM_SERVICE_URL`). The owner first asked for DX as its own service; kept with System (owner, 2026-10-15) because DX reads capability status from System and today is 234 lines of read-only, code-seeded catalog — it graduates when it gains state (API keys, rate tiers; C-115 Phase 1). Both catalogs are seeded from code on first start, so the copy **upserts on each table's stable public id** and identity's content wins: policies 10 · tiers 3 · capabilities 5 · SDKs 4 · templates 1 · DX capabilities 5 · guides 3, every count equal. Owner verified both apps. No consumers to move. **Rollback:** delete `PLATFORM_SERVICE_URL`. The rest of the platform group joins this service later, one at a time: Feedback (needs identity for the user), then Pioneer + the campaign registry (~4,100 lines, tied to users and identity's audit log — its own plan). Left: drop System and DX from identity |
| NBF · Titan · NX · Epic → `tec-business-service` | **Live 2026-10-15.** tec-core-backend **#425** (port 5018) on `tec_business` (db-asset): `nbf_businesses` · `titan_orgs` · `titan_members` · `titan_modules` · `nx_opportunities` · `epic_projects`, same `/identity/{nbf,titan,nx,epic}/*` paths, one gateway switch (`BUSINESS_SERVICE_URL`). Zone stays in identity (it moves with `tec_trust`): NBF and Epic read a person's verified names through a new internal route, `GET /identity/internal/zone/verified-names/:owner?type=MERCHANT\|PROJECT`, and fail closed (503) when identity does not answer. Copy: NBF, NX and Epic by id (1 · 1 · 3); Titan is a read-only, code-seeded sample, so its three tables are **replaced** with identity's (1 · 5 · 10) — every count equal; re-copy after cutover added nothing. Owner verified all four apps. Zone badges moved: `BUSINESS_CONSUMER_ENABLED=false` on identity (log `OFF here`), `true` on the service (log `Started — listening for verification verdicts`, `zone.badge.issued.v1` · `.revoked.v1`). `SOURCE_DATABASE_URL` removed. **Rollback:** delete `BUSINESS_SERVICE_URL`, set identity's flag back to `true`. Left: drop the four modules and tables from identity; identity's demo purge for these tables moves to this service |
| Feedback → `tec-platform-service` | **Live 2026-10-15.** tec-core-backend **#426** (port 5017, joins System + DX) on `tec_platform`: table `feedback`, same `/identity/feedback/*` paths, its **own** gateway switch `FEEDBACK_SERVICE_URL` (System and DX were already live on `PLATFORM_SERVICE_URL`; Feedback needed its copy first). No foreign key across services: `user_id` is identity's `users.id`, resolved through `/identity/internal/users/resolve`; the admin list names authors through `/internal/users/usernames`, and fails 503 rather than show nameless rows. `JWT_SECRET` and `IDENTITY_SERVICE_URL` are optional on this service so System and DX boot without them; unset, Feedback answers 503. Copy is **insert-only** by id, so a re-copy never puts back a status an admin changed here: 2 rows copied; after cutover the re-copy copied 0 and reported source 2 · target 3 (the third written to the new service, from Life). Owner verified the Hub's admin inbox: three messages with usernames, status changes saved. No consumer. **Security fix in the same PR (identity and platform):** the triage gate trusted `x-internal-key`, which the gateway adds to every proxied request — so any signed-in user (including through the Hub's `/api/admin/feedback`, which forwards only the token) could read everyone's feedback and change statuses. The key now counts only when the gateway marked the caller `service` (`x-tec-caller`, C17); everyone else needs an admin token. `SOURCE_DATABASE_URL` removed. **Rollback:** delete `FEEDBACK_SERVICE_URL`. Left: drop the module and table from identity; Pioneer + the campaign registry are next for this service (their own plan) |
| Pioneer + the Pi reward campaign → `tec-platform-service` | **Live 2026-10-16.** tec-core-backend **#428** (port 5017, joins System · DX · Feedback) on `tec_platform`: `pioneer_quests` · `campaign_visits` · `campaign_claims` · `campaign_missions` · `campaign_events` (keyed by Pi username, no foreign keys), same `/identity/pioneer/*` and `/identity/campaign/*` paths, **one** gateway switch `PIONEER_SERVICE_URL` (the two modules share tables). The person stays in identity: an admin's user id through `/internal/users/resolve`, a payout's Pi uid through `/internal/users/lookup` (now also returns `pi_user_id`); identity not answering is a 503 — a payout is never addressed or refused on a guess. Admin actions (payouts, reviews, reset) are audited in the service's own `platform_audit_logs`; identity's audit rows from before the move stay there. Group-message missions read only from tec-connection-service (the fallback to identity's old message table is gone). `JWT_SECRET` + `IDENTITY_SERVICE_URL` became required at boot; the campaign settings (`CAMPAIGN_*`, `PI_CLAIMED_APPS`) and neighbours are references to identity's values. Copy by id, insert-only; `--refresh` (identity wins) was run once while the campaign was not running and before the switch: quests 22 · visits 241 · claims 8 · missions 7 · events 6, every count equal; the post-switch re-copy copied 0. Owner verified the Hub's campaign and admin pages. No consumer. **Preceded by #427 (security):** `POST /identity/pioneer/arrived` trusted the gateway-added internal key, so a signed-in person calling the gateway directly could record a confirmed arrival at any app — the record campaign seats (real Pi) and the .pi-domain count are qualified on; it now requires the gateway's `service` mark (C17). `SOURCE_DATABASE_URL` removed. **Rollback:** delete `PIONEER_SERVICE_URL`. Left: drop both modules and their tables from identity |
