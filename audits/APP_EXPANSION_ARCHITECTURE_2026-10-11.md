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

## 1. Domain hosts — a service per DOMAIN, not per app, and not one for everything

### 1.1 Why neither extreme

| Option | Why not |
|---|---|
| One host for everything (today) | One deploy, one database, one event loop for ~20 apps: a bad migration or a hot path in one app takes down sign-in-adjacent identity for all (C-02 row 17). |
| One service per app | ~15 new Railway services, databases, secrets and dashboards, run by one person (C-02 row 17 again — the largest single point of failure is the operator). Most of these apps are read-heavy previews with a few tables. |
| **One host per domain** | Apps that share a lifecycle, a data shape and a failure mode share a host. A failure is contained to one domain; the operator runs a handful of services, not dozens. This is what C-132's own §2 seam was built to make mechanical. |

### 1.2 The map

| Host | Domain | Apps / modules | Today |
|---|---|---|---|
| `tec-identity-service` | **The person** | identity core · Life · Connection · TEC AI conversations (#411) | stays — closed to new domains |
| **`tec-business-service`** *(new)* | **Business & opportunity** | NBF → Titan (formation → scale, C-124 → C-130) · NX · Epic | modules in identity → move here |
| **`tec-trust-service`** *(new, later)* | **Evidence → recognition → privilege** | Zone → Legend → Elite → VIP | modules in identity → move when that chain is worked on |
| **`tec-platform-service`** *(new)* | **Governance, coordination & builders** | System · DX · Nexus (workflows, C-109) · Pioneer / campaign registry · Feedback · Intent | modules in identity → move here |
| `tec-search-service` *(C-132 T1, unchanged)* | Discovery | Explorer | already the flagged T1 candidate; extract on load |
| `tec-notification-service` | Signals | Alert | the Alert module belongs with its owning service |
| financial **state** host *(later)* | Pools, protection, property | FundX · Insure · Estate · Brookfield state | stays gated (legal + custody + SYSTEM); custody is payment-service forever (R-4) |

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

A module moves **when it is next worked on**, never all at once:

1. Create the domain host from `tec-template` backend conventions (NestJS · Prisma ·
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
| **S4** | **Business & opportunity**: create `tec-business-service`; move NBF + Titan modules (§1.4); NBF → Titan graduation with real data | the first domain host, created by real work |
| **S5** | NX + Epic onto the business host; opportunities and projects from real postings | same host, same domain |
| **S6** | **Governance & developers**: create `tec-platform-service`; move System + DX; System's policy registry and DX's guides read live, not from fixtures | the platform's own tooling |
| later | Trust chain (Zone → Legend → Elite → VIP) onto `tec-trust-service`; Explorer → search on load | when that chain is next worked on |

## 4. What this does not change

- Ownership and write authority (C-68); event names (C-70); the payment custody rule (R-4).
- The ADR-007 payment modes, C-123 cookie law, the Hub SSO contract.
- The financial gates (FundX · Insure · Brookfield): legal + custody + SYSTEM first, as written.

## 5. Open questions for the owner

1. The T5 threshold: **8 domain modules** per host — or another number?
2. The performance budget (E15): start at 250 KB gzip for `/app`?
3. The first domain host's name: `tec-business-service`?
