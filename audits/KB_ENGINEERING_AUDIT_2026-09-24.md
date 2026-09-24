# KB Engineering Audit — every file in `tec-knowledge-base`

> **Truth State:** `[Current State]` · **Verification:** `[Code Verified]` — every factual
> finding below was checked against the code on `main` of the repo it describes
> (tec-app, tec-core-backend, tec-ui, tec-auth, TEC-SDK, the app fleet) on 2026-09-24.
> **Audited revision:** `main` @ `b2a7027` (2026-09-19). #153 was open and is not included.
> **Scope:** all **270** tracked files — 117 C-docs individually (Appendix A), the other 153
> by folder (Appendix B).

---

## ملخص بالعربي

الـ KB **سليمة من ناحية الشكل** و**مش متزامنة مع الكود في المحتوى**. الـ 21 gate كلهم خضر،
ومع ذلك لقيت 3 مستندات بتوصف cookies وتسجيل دخول **ممنوعين** بقوانين C-123، وجدول ports غلط
في 5 خدمات، وإصدارات كل الـ packages غلط، و24 متغير env موثّقين من أصل 158 مستخدمين. ده مش
إهمال في الكتابة — ده لأن **مفيش gate بيقارن الـ KB بالكود**: كل الـ gates بتقيس التنسيق
والروابط والـ headers. 52 من 67 مستند "Current State" ماتلمسوش من قبل 15 يوليو.

اللي سليم فعلًا: قايمة الـ 24 app متطابقة مع الـ Hub والـ SSO، الـ events-catalog متطابق
مع الكود، مفيش أسرار ولا بيانات شخصية، وكل الإحالات `C-NN` بتشاور على ملفات موجودة.

---

## 1. Verdict

| Dimension | Result |
|---|---|
| Structure (headers, index, numbering, links) | ✅ **Excellent** — 21/21 gates, 117/117 headers, 0 broken relative links, every `C-NN` resolves |
| Security / privacy | ✅ No secrets, no wallet addresses, no emails, no tx hashes (full-history scan) |
| **Truth vs code** | ❌ **Drifting** — 52 of 67 `[Current State]` docs untouched since before 2026-07-15; 11 verified factual contradictions, 3 of them on the session/cookie law |
| Machine-readable manifests | ⚠️ 4 of 8 `manifests/*.yaml` are not YAML; `dependency-graph.yaml` has drifted from the registry |
| Operability (can a new session find "now"?) | ❌ C-02 is 5,856 lines, sessions out of order, no current summary |

**Root cause of every P1/P2 below:** the gates prove *form*, never *fact*. Nothing compares
the KB with the repos it describes, so a document stays `[Code Verified]` after the code moves.

---

## 2. Findings

Severity: **P1** = a reader following the doc would build something broken or forbidden ·
**P2** = wrong fact that misleads operations · **P3** = hygiene / maintainability.

### F1 · P1 — The gates verify form, not truth

- **Evidence:** `bash scripts/preflight.sh` → **21/21 passed** on the revision where F2–F11 were all present.
- **Why:** every gate reads the KB only (headers, index, links, registry, schema of its own
  manifests). KB CI has no access to `tec-app` / `tec-core-backend`. The per-app "Drift
  Detection" CI step checks a handful of payment/CSRF claims — not versions, ports, env,
  cookie attributes or the auth flow.
- **Fix:** a **cross-repo drift check** that clones the repos (read-only) and asserts a small,
  high-value set of facts: package versions (C-14), service ports (C-20), cookie attributes
  (C-13/C-15/C-51 vs C-123 §2), env names (C-44), events (C-56 vs catalog), SLO numbers
  (C-62 vs manifest). Run it on a weekly `schedule`, not per-PR. Add a `Last-Verified:` date to
  `[Code Verified]` headers and fail when it is older than 60 days.

### F2 · P1 — C-13 (`[Code Verified]`) documents the login flow C-123 forbids

- **C-13 §1:** "BFF sets 4 cookies" on `POST /api/auth/pi-login` — an XHR response. **C-123 LAW 1:** XHR Set-Cookie is unreliable.
- **C-13 §2:** sso-callback "Set cookies + **Redirect** → /app". **C-123 LAW 2:** cookies on a 3xx are dropped. The code returns a **200 HTML landing** (C-123 §3).
- C-13 §2 also has no branch for "Hub not logged in" — the path that lost the destination until tec-app #253.
- **Fix:** rewrite C-13 §1–§2 as a pointer to C-123 §3 + §9, or retire C-13 into C-123.

### F3 · P1 — C-51 and C-15 omit `Partitioned`

- Both specify `sameSite: 'none'` (correct) and never mention `Partitioned`. **C-123 §1 LAW 3 / §2:** `Secure; SameSite=None; Partitioned` is mandatory; without it the cookie is blocked in embedded contexts.
- **Fix:** replace both cookie blocks with a reference to the locked contract in C-123 §2.

### F4 · P2 — C-20 service ports wrong in 5 of 12 services; three contradictory port tables

| Service | C-20 | Code default (`main.ts`) | tec-core-backend CLAUDE.md |
|---|---|---|---|
| asset | 5009 | **5004** | 4006 |
| identity | 5004 | **5005** | 4004 |
| commerce | 5005 | **5009** | 4003 |
| storage | 5006 | **5007** | 4010 |
| notification | 5007 | **5006** | 4008 |

Railway's own log line `tec-core-backend-a5f9.railway.internal:5004` for asset-service confirms the code.
C-20 also lists **public `*.up.railway.app` URLs** that ADR-005 (Session 56m) removed.
- **Fix:** C-20 = the code's table, private hostnames only; delete the 4000-series table from the backend CLAUDE.md (or point it at C-20).

### F5 · P2 — C-14 has every package version wrong

| Package | C-14 | `package.json` on `main` |
|---|---|---|
| `@yasser172/tec-ui` | v2.1.0 | **3.0.0** |
| `@yasser172/tec-auth` | v1.0.0 | **1.2.0** |
| `@yasser172/tec-sdk` | v1.2.2 | **1.4.0** |

### F6 · P2 — C-11 (Repository Map) lists none of the 20 domain apps

Mentions the original repos + backend services only; 28 TEC repos exist (Life, Zone, Connection … Brookfield, NBF).

### F7 · P2 — C-44 documents 24 env vars; the code uses at least 158

- Sampled 4 repos (Hub, backend, Zone, Life): **158** distinct `process.env.*`. Missing from C-44 include `COOKIE_DOMAIN`, every `*_SERVICE_URL`, `JWT_REFRESH_SECRET`, `CAMPAIGN_*`, `FOUNDING_GIFT_*`, `INTENT_PROOF_SECRET`, `ANTHROPIC_API_KEY`.
- In C-44 but **used nowhere**: `REFRESH_SECRET` (code: `JWT_REFRESH_SECRET`), `PI_WEBHOOK_SECRET`, `PI_API_KEY_HUB`.
- **Cost, observed:** on 2026-09-24 `insure.pi` sat at 0/5 arrivals because one Vercel var was missing (`configured:false`). The per-app matrix in `audits/PER_APP_LAUNCH_ENV_MATRIX.md` (07-16) is the right idea; C-44 should *be* it, generated from code.

### F8 · P2 — Two SLO sources disagree on availability (violates P1 Single Source of Truth)

| SLO | C-62 | C-78 §2 · `manifests/slo-definitions.yaml` |
|---|---|---|
| Payment availability | **99.99%** | **99.9%** |
| Auth availability | 99.95% | 99.9% |
| Gateway availability | 99.95% | 99.9% |

(Corrected during remediation: C-62's "> 99%" is the *Pi API* success rate, not our payment
success rate, so it does not conflict with the manifest's `payment_success_rate ≥ 95%`.)
`check-slo-definitions` validates the manifest only. **Fix:** C-62 cites the manifest; numbers live in one place.

### F9 · P2 — C-56's stream list is two streams, one of them retired

C-56 §3 "STREAM NAMES (كلهم — all of them)" lists `payment.completed` and `user.created`;
`user.created` was retired in Session 24 and **15 events are live** in the catalog. Its §8
"future" list names `kyc.approved`, `asset.transferred`, `subscription.upgraded`,
`order.created` — none adopted, none in code (verification shipped as `kyc.verified` /
`kyc.rejected`, orders as `order.paid.v1`). (Corrected during remediation: those four were
listed as *future*, not claimed live.) `manifests/events-catalog.yaml` is correct.
**Fix:** C-56 → pointer to the catalog.

### F10 · P2 — C-40 lists NEW-M as open; it closed on 2026-06-18

tec-core-backend `38d33e4` "extract service-registry.ts … **closes NEW-M**" — C-40 still says "P2 Open: 1 ⚠️ (NEW-M)".

### F11 · P2 — Phase statements are three months old

- **C-41:** "PHASE 1 — Portal Readiness (**CURRENT**)", "External Audit ← **NEXT NOW**".
- **`memory/platform-snapshot.md`:** "Phase: 0 → Pre-Mainnet Hardening".
- Reality (C-02, `app-fleet.yaml`): all 24 apps live on Mainnet since July. The CLAUDE.md of tec-app, tec-commerce, tec-assets, tec-ecommerce and tec-core-backend still say "Current Phase: Phase 0 — Pre-Mainnet Hardening".

### F12 · P2 — C-02 cannot answer "where do we stand?"

5,856 lines, 70 H2 sections, order: Session 51 → down to 19 → Session 6/8 → then 54 → 56o appended. No top-of-file summary of current state; the "SESSION START RULE" sends every session into it.
- **Fix:** keep ≤ 150 lines of *current* state at the top (live apps, open items, last 3 sessions); move session narratives to `memory/sessions/` (one file per session) or C-50.

### F13 · P2 — `manifests/dependency-graph.yaml` has drifted from the registry

`python3 scripts/regenerate-cdg.py` rewrites it: **+187 / −43 lines**. No gate checks it (the registry has one). C-118's stale-flag propagation reads this graph, so it propagates over an outdated one.
- **Fix:** regenerate + add the same "regenerate and diff" step preflight uses for the registry.

### F14 · P3 — The runtime-evidence loop is dormant

Newest real record: `runtime-evidence/ev-2026-07-16-024.yaml`. Since then: the first real A2U payout, the ADR-005 deploy, today's Vercel/Railway trace — none recorded. The loop C-96 describes exists on paper.

### F15 · P3 — Four `.yaml` manifests are not YAML

`app-rollout-registry.yaml`, `runtime-evidence-schema.yaml`, `slo-definitions.yaml`,
`verification-authority-matrix.yaml` are Markdown with fenced YAML. The gates extract the fences,
so they pass; any standard tool (`yaml.safe_load`, editors, CI linters) fails. **Fix:** rename to `.md`, or split front-matter prose from a real YAML file.

### F16 · P3 — The KB's description of itself is stale

- `README.md`: "All **13** CI gates", "**112** C-docs", badge **v3.12.0**. Actual: 20 gates (+registry regen = 21), 116 C-docs, work through Session 56.
- `CLAUDE.md`: 716 lines, an append-only log of 18 sessions; its counts (10 → 13 → 16 gates; 104 → 113 assets) are each true only at the session that wrote them.

### F17 · P3 — Broken references

| Where | Reference | Actual |
|---|---|---|
| `architecture/PLATFORM_ARCHITECTURE.md`, `commands/new-adr.md` (+ tec-app `CLAUDE.md`) | `C-64___ADR_SYSTEM.md` | `C-64___ARCHITECTURE_DECISION_RECORDS.md` |
| `C-80` | proposes "C-23 or doc **#24**" for a tec-auth doc | #24 was never created (this reference in `knowledge-base/` is not seen by `check-session-canonical`, which scans `audits/` + `memory/` only) |
| `audits/EXTERNAL_AUDIT_2026-06-20_Session14.md` | `docs/PAYMENT_SYSTEM.md` | does not exist |
| `CLAUDE.md` Session 25 | `scripts/verify-runtime.mjs` | lives in **tec-core-backend**, not here |

### F18 · P3 — Language policy: ~30 English-only docs contain Arabic; the policy contradicts itself

`governance/LANGUAGE_POLICY.md` makes C-00→C-23, C-30→C-32, C-47, C-64, C-67→C-78 English-only.
Arabic lines found in C-01 (19), C-10–C-23 (1–37 each), C-30–C-32, C-47 (14), C-64 (78), C-67–C-77 (19–70 each).
The policy also puts C-02 inside the English-only C-00→C-23 range and then lists it as internal/mixed. (C-100→C-115 carry 4 Arabic lines each — the allowed bilingual header.)

### F19 · P3 — Stale infrastructure hostnames

12 `*.up.railway.app` hostnames in 7 files — removed from the internet by ADR-005, still printed. Harmless while the repo is private; an infrastructure map if it is ever made public.

### F20 · P3 — Duplicates and generated noise

- `scripts/impact_analysis.py` and `scripts/registry-impact-analysis.py` — two "v1.0" blast-radius engines, same purpose; only the second is used.
- `architecture/registry-integrity-report.md` is a generated artefact committed with an absolute local path (`/home/user/...`) and a timestamp — churn on every run.

### F21 · P3 — The "4 apps" era is still in 21 files

"all 4 apps" / "4 consumer apps" appears **50×** (including `CLAUDE.md`, `architecture/PLATFORM_ARCHITECTURE.md`, `docs/QUICKSTART.md`, `agents/design-system-advisor`). The platform has 24. `agents/`, `commands/`, `templates/` have not been edited since June.

---

## 3. What is verifiably right

- **`architecture/app-fleet.yaml` ↔ tec-app `_registry.ts` ↔ SSO `allowed-origins.ts`:** all 24 apps agree on domain, `live` status and allowlist membership (naming only: fleet `hub` = registry `tec`).
- **`manifests/events-catalog.yaml`:** every event is present in tec-core-backend source.
- **Secrets / PII:** full-history scan — none (see C-02 Session 56p).
- **References:** every `C-NN` cited anywhere resolves except the cases in F17; 0 broken relative Markdown links.
- **Scripts:** all 7 Python scripts compile; all shell scripts pass `bash -n`.
- **C-123, C-12, C-76** — the three documents most used in real incidents — are accurate (C-123/C-76 extended by #153).

---

## 4. Remediation plan

| Step | Work | Closes | Size |
|---|---|---|---|
| 1 | Rewrite C-13 §1–§2, C-15 & C-51 cookie blocks → cite C-123 §2/§3/§9 | F2, F3 | S |
| 2 | Correct C-14 versions, C-20 ports + private hosts, C-40 NEW-M, C-41/`memory` phase | F4, F5, F10, F11 | S |
| 3 | C-56 → pointer to events-catalog; C-62 → pointer to the SLO manifest (decide 95% vs 99%) | F8, F9 | S |
| 4 | Regenerate `dependency-graph.yaml`; add regen+diff to preflight/CI | F13 | S |
| 5 | Fix F17 references; delete `impact_analysis.py`; stop committing the integrity report | F17, F20 | S |
| 6 | README/CLAUDE.md: replace counts with "run preflight"; CLAUDE.md → navigation only | F16 | M |
| 7 | C-02 split: ≤150-line current state + per-session files | F12 | M |
| 8 | C-11 + C-44 regenerated from the repos (script) | F6, F7 | M |
| 9 | **Cross-repo drift job** (weekly) + `Last-Verified` on `[Code Verified]` headers | F1 — prevents the rest recurring | L |
| 10 | Language-policy pass (or amend the policy to what the KB actually does) | F18 | M |

Steps 1–5 are document edits (one PR). Step 9 is the one that stops this report from needing to be written again.

---

## 5. Method

- `git ls-files` inventory (270); per-C-doc header parse, size, last commit date, inbound `C-NN` citations.
- Facts cross-checked against `origin/main` of: tec-app (registry, allowlist, sso route), tec-core-backend (every `main.ts` port, service registry, event names, commit history), Tec-ui / tec-auth / TEC-SDK `package.json`, `process.env.*` across Hub, backend, Zone, Life.
- Full-history secret/PII scan; YAML/JSON parse of every manifest; `py_compile` + `bash -n` on every script; `regenerate-cdg.py` run on a copy.
- **Not done:** paragraph-level proofreading of the 31 `[Future Vision]` and 5 `[Speculation]` docs — they make no claim about current code, so there is nothing to verify them against.

---

## Appendix A — every C-doc (117)

`stale?` = `[Current State]` and not edited since before 2026-07-15. P-codes refer to §2.

| ID | File | Lines | Last edit | Truth | Verification | Cited by | Findings |
|---|---|---|---|---|---|---|---|
| C-00 | C-00_v3.0___PLATFORM_CONSTITUTION___ENGINEERING_ | 236 | 2026-06-16 | Current State | Documentation Verified | 48 | stale? |
| C-01 | C-01_Project_Identity.md | 200 | 2026-07-17 | Current State | Documentation Verified | 21 |  |
| C-02 | C-02___CURRENT_STATE_.md | 5856 | 2026-09-19 | Current State | Code Verified | 48 | P2 5.8k lines, unordered |
| C-10 | C-10_System_Architecture.md | 137 | 2026-06-21 | Current State | Code Verified | 14 | stale? |
| C-11 | C-11___REPOSITORY_MAP.md | 77 | 2026-06-17 | Current State | Code Verified | 5 | P2 missing 20 app repos; stale? |
| C-12 | C-12_Dual_Mode_Payment.md | 218 | 2026-07-11 | Current State | Code Verified | 39 | stale? |
| C-13 | C-13_Auth_SSO.md | 118 | 2026-06-17 | Current State | Code Verified | 11 | P1 contradicts C-123 LAW 1/2; stale? |
| C-14 | C-14___SHARED_PACKAGES.md | 107 | 2026-06-26 | Current State | Code Verified | 5 | P2 all 3 versions stale; stale? |
| C-15 | C-15_Security_Rules.md | 134 | 2026-06-17 | Current State | Code Verified | 14 | P1 no Partitioned (LAW 3); stale? |
| C-16 | C-16_Database_Rules.md | 106 | 2026-06-17 | Current State | Code Verified | 13 | stale? |
| C-17 | C-17___DATA_PRIVACY_RETENTION_COMPLIANCE.md | 132 | 2026-06-18 | Planned State | Documentation Verified | 9 |  |
| C-18 | C-18___DISASTER_RECOVERY_BACKUP_CONSTITUTION.md | 148 | 2026-06-18 | Planned State | Documentation Verified | 6 |  |
| C-19 | C-19___FRAUD_ABUSE_AML_CONTROLS.md | 137 | 2026-06-18 | Planned State | Documentation Verified | 10 |  |
| C-20 | C-20_Backend_Services.md | 52 | 2026-06-16 | Current State | Code Verified | 21 | P2 ports wrong ×5; public URLs post-ADR-005; stale? |
| C-21 | C-21_Hub_App.md | 80 | 2026-06-17 | Current State | Code Verified | 7 | stale? |
| C-22 | C-22_Apps_Commerce_Assets_Ecommerce.md | 85 | 2026-06-17 | Current State | Code Verified | 7 | stale? |
| C-23 | C-23_TEC_SDK.md | 67 | 2026-06-18 | Current State | Code Verified | 12 | stale? |
| C-30 | C-30_Vision_24_Apps.md | 131 | 2026-07-17 | Future Vision | Assumed | 11 |  |
| C-31 | C-31_App_Blueprints_Life_Connection_Fundx_Estate | 92 | 2026-07-17 | Future Vision | Assumed | 4 |  |
| C-32 | C-32_App_Blueprints_Nexus_Titan_DX.md | 63 | 2026-07-17 | Future Vision | Assumed | 9 |  |
| C-40 | C-40___OPEN_VIOLATIONS_MAP.md | 169 | 2026-06-17 | Current State | Documentation Verified | 21 | P2 NEW-M closed 06-18; stale? |
| C-41 | C-41_Engineering_Roadmap.md | 112 | 2026-06-16 | Current State | Documentation Verified | 11 | P2 phase/NEXT stale; stale? |
| C-42 | C-42_Testing_Strategy.md | 101 | 2026-06-18 | Current State | Documentation Verified | 7 | stale? |
| C-43 | C-43_CI_CD_DevOps.md | 113 | 2026-06-18 | Current State | Documentation Verified | 10 | stale? |
| C-44 | C-44_Environment_Variables.md | 70 | 2026-06-18 | Current State | Documentation Verified | 9 | P2 24 of ~158 vars; stale? |
| C-45 | C-45_Observability.md | 79 | 2026-06-18 | Current State | Documentation Verified | 10 | stale? |
| C-46 | C-46_Commercial_Strategy.md | 78 | 2026-07-17 | Planned State | Assumed | 5 |  |
| C-47 | C-47_Kernel_Spec_Architecture_Binding.md | 100 | 2026-06-18 | Current State | Code Verified | 83 | stale? |
| C-48 | C-48_Engineering_Audit_May2026.md | 97 | 2026-08-28 | Current State | Documentation Verified | 6 |  |
| C-49 | C-49_Engineering_Work_Map.md | 124 | 2026-06-18 | Current State | Documentation Verified | 8 | stale? |
| C-50 | C-50___SESSION_LOG.md | 181 | 2026-08-28 | Current State | Documentation Verified | 11 |  |
| C-51 | C-51_Cookie_Architecture.md | 68 | 2026-06-18 | Current State | Documentation Verified | 8 | P1 no Partitioned (LAW 3); stale? |
| C-52 | C-52_Protected_Files_Map.md | 70 | 2026-06-18 | Current State | Documentation Verified | 5 | stale? |
| C-53 | C-53_New_App_Protocol.md | 245 | 2026-06-18 | Current State | Documentation Verified | 9 | stale? |
| C-54 | C-54_Package_Management.md | 199 | 2026-06-18 | Current State | Documentation Verified | 7 | stale? |
| C-55 | C-55_Scoring_Audit_Strategy.md | 148 | 2026-08-28 | Current State | Documentation Verified | 10 |  |
| C-56 | C-56_Redis_Streams_Events_Map.md | 182 | 2026-06-18 | Current State | Documentation Verified | 16 | P2 phantom/retired events; stale? |
| C-57 | C-57___MASTER_CONTENTS_INDEX.md | 404 | 2026-07-26 | Current State | Documentation Verified | 23 |  |
| C-58 | C-58_Hub_Completion_Plan.md | 291 | 2026-07-17 | Planned State | Assumed | 8 |  |
| C-59 | C-59_Error_Format.md | 320 | 2026-06-18 | Current State | Documentation Verified | 10 | stale? |
| C-60 | C-60_Code_Templates.md | 446 | 2026-06-18 | Current State | Documentation Verified | 11 | stale? |
| C-61 | C-61_Typescript_Types.md | 263 | 2026-06-18 | Current State | Documentation Verified | 6 | stale? |
| C-62 | C-62_SLO_Definitions.md | 248 | 2026-06-18 | Current State | Documentation Verified | 12 | P2 conflicts slo manifest; stale? |
| C-63 | C-63___PI_NETWORK_INTEGRATION_RULES.md | 146 | 2026-06-18 | Current State | Documentation Verified | 13 | stale? |
| C-64 | C-64___ARCHITECTURE_DECISION_RECORDS.md | 445 | 2026-08-01 | Current State | Documentation Verified | 44 | P3 cited by wrong filename |
| C-65 | C-65___NEW_BACKEND_SERVICE_TEMPLATE.md | 390 | 2026-06-18 | Current State | Documentation Verified | 8 | stale? |
| C-66 | C-66___HUB_FEATURES_CODE_GUIDE.md | 411 | 2026-06-18 | Current State | Documentation Verified | 7 | stale? |
| C-67 | C-67___SOURCE_OF_TRUTH_MATRIX.md | 318 | 2026-06-18 | Current State | Documentation Verified | 33 | stale? |
| C-68 | C-68___DOMAIN_OWNERSHIP_MATRIX.md | 266 | 2026-06-18 | Current State | Documentation Verified | 20 | stale? |
| C-69 | C-69___API_CONTRACTS_GOVERNANCE.md | 271 | 2026-06-18 | Current State | Documentation Verified | 7 | stale? |
| C-70 | C-70___EVENT_GOVERNANCE_SPEC.md | 235 | 2026-06-18 | Current State | Documentation Verified | 28 | stale? |
| C-71 | C-71___FINANCIAL_INTEGRITY_SPEC.md | 229 | 2026-06-18 | Current State | Documentation Verified | 21 | stale? |
| C-72 | C-72___FRONTEND_STATE_GOVERNANCE.md | 147 | 2026-06-18 | Current State | Documentation Verified | 3 | stale? |
| C-73 | C-73___INCIDENT_RESPONSE_RUNBOOK.md | 194 | 2026-06-18 | Current State | Documentation Verified | 14 | stale? |
| C-74 | C-74___PLATFORM_SCALABILITY_SPEC.md | 189 | 2026-07-17 | Planned State | Assumed | 4 |  |
| C-75 | C-75___RELEASE_GOVERNANCE_SPEC.md | 211 | 2026-06-18 | Current State | Documentation Verified | 8 | stale? |
| C-76 | C-76___ADR-007.md | 249 | 2026-06-18 | Current State | Code Verified | 30 | note: #153 adds reverse case; stale? |
| C-77 | C-77___STRATEGIC_ANALYSIS___RISK_ASSESSMENT.md | 350 | 2026-08-28 | Current State | Documentation Verified | 18 |  |
| C-78 | C-78___PLATFORM_OPERATIONS___RELIABILITY_GOVERNA | 473 | 2026-09-05 | Current State | Documentation Verified | 32 |  |
| C-79 | C-79___INSTITUTIONAL_MEMORY_CONSTITUTION.md | 219 | 2026-08-28 | Speculation | Assumed | 11 |  |
| C-80 | C-80___ENGINEERING_ASSESSMENT_REPORT.md | 397 | 2026-07-17 | Current State | Documentation Verified | 11 | P3 cites a doc #24 that was never created |
| C-81 | C-81___P1_FIXES_IMPLEMENTATION.md | 504 | 2026-06-18 | Planned State | Documentation Verified | 8 |  |
| C-82 | C-82___PLATFORM_MATURITY_EVOLUTION.md | 164 | 2026-06-17 | Current State | Documentation Verified | 10 | stale? |
| C-83 | C-83___EVL_ESL.md | 814 | 2026-09-03 | Planned State | Assumed | 20 |  |
| C-84 | C-84___RUNTIME_CONSTITUTION.md | 356 | 2026-08-28 | Future Vision | Assumed | 26 |  |
| C-85 | C-85___INFRASTRUCTURE_STACK.md | 493 | 2026-08-28 | Future Vision | Assumed | 20 |  |
| C-86 | C-86___TEMPORAL_GOVERNANCE.md | 228 | 2026-08-28 | Future Vision | Assumed | 12 |  |
| C-87 | C-87___EXECUTION_GOVERNANCE.md | 286 | 2026-08-28 | Future Vision | Assumed | 13 |  |
| C-88 | C-88___PI_ECONOMIC_FLOW_CONSTITUTION.md | 319 | 2026-06-12 | Current State | Documentation Verified | 6 | stale? |
| C-89 | C-89___DEVELOPER_PLATFORM_GOVERNANCE.md | 338 | 2026-08-28 | Planned State | Assumed | 6 |  |
| C-90 | C-90___SECURITY_TRUST_MODEL.md | 402 | 2026-08-28 | Current State | Code Verified | 10 |  |
| C-91 | C-91___ENGINEERING_ROADMAP_TO_SCALE.md | 377 | 2026-06-21 | Current State | Documentation Verified | 8 | stale? |
| C-92 | C-92___PLATFORM_HEALTH_MODEL.md | 519 | 2026-06-21 | Planned State | Documentation Verified | 26 |  |
| C-93 | C-93___INSTITUTIONAL_VERIFICATION_CONSTITUTION.m | 576 | 2026-08-28 | Future Vision | Assumed | 31 |  |
| C-94 | C-94___GOVERNED_CAPABILITY_CONSTITUTION.md | 452 | 2026-08-28 | Future Vision | Assumed | 22 |  |
| C-95 | C-95___INSTITUTIONAL_KNOWLEDGE_CONSTITUTION.md | 246 | 2026-08-28 | Speculation | Assumed | 16 |  |
| C-96 | C-96___PLATFORM_RUNTIME_CONSTITUTION.md | 536 | 2026-06-22 | Current State | Code Verified | 38 | stale? |
| C-97 | C-97___CONTEXT_CONSTITUTION.md | 282 | 2026-08-28 | Speculation | Assumed | 11 |  |
| C-98 | C-98___INSTITUTIONAL_CONSTRUCTION_CONSTITUTION.m | 223 | 2026-08-28 | Speculation | Assumed | 8 |  |
| C-99 | C-99___INSTITUTIONAL_GOVERNANCE_CONSTITUTION.md | 292 | 2026-08-28 | Speculation | Assumed | 18 |  |
| C-100 | C-100___HUB_INSTITUTIONAL_CHARTER.md | 251 | 2026-06-15 | Current State | Documentation Verified | 39 | stale? |
| C-101 | C-101___COMMERCE_INSTITUTIONAL_CHARTER.md | 245 | 2026-06-21 | Current State | Documentation Verified | 22 | stale? |
| C-102 | C-102___ASSETS_INSTITUTIONAL_CHARTER.md | 233 | 2026-06-15 | Current State | Documentation Verified | 13 | stale? |
| C-103 | C-103___ECOMMERCE_INSTITUTIONAL_CHARTER.md | 236 | 2026-06-15 | Current State | Documentation Verified | 17 | stale? |
| C-104 | C-104___TEC_AI_INSTITUTIONAL_CHARTER.md | 567 | 2026-08-22 | Planned State | Assumed | 24 |  |
| C-105 | C-105___ANALYTICS_INSTITUTIONAL_CHARTER.md | 309 | 2026-08-01 | Current State | Runtime Verified | 40 |  |
| C-106 | C-106___LIFE_INSTITUTIONAL_CHARTER.md | 412 | 2026-09-05 | Future Vision | Assumed | 19 |  |
| C-107 | C-107___CONNECTION_INSTITUTIONAL_CHARTER.md | 552 | 2026-09-03 | Future Vision | Assumed | 23 |  |
| C-108 | C-108___EXPLORER_INSTITUTIONAL_CHARTER.md | 328 | 2026-09-03 | Future Vision | Assumed | 24 |  |
| C-109 | C-109___NEXUS_INSTITUTIONAL_CHARTER.md | 314 | 2026-09-13 | Future Vision | Assumed | 18 |  |
| C-110 | C-110___SYSTEM_INSTITUTIONAL_CHARTER.md | 300 | 2026-09-13 | Future Vision | Assumed | 35 |  |
| C-111 | C-111___ALERT_INSTITUTIONAL_CHARTER.md | 225 | 2026-08-28 | Future Vision | Assumed | 19 |  |
| C-112 | C-112___NX_INSTITUTIONAL_CHARTER.md | 253 | 2026-08-28 | Future Vision | Assumed | 15 |  |
| C-113 | C-113___FUNDX_INSTITUTIONAL_CHARTER.md | 231 | 2026-08-28 | Future Vision | Assumed | 24 |  |
| C-114 | C-114___ESTATE_INSTITUTIONAL_CHARTER.md | 246 | 2026-08-28 | Future Vision | Assumed | 14 |  |
| C-115 | C-115___DX_INSTITUTIONAL_CHARTER.md | 325 | 2026-09-13 | Future Vision | Assumed | 34 |  |
| C-116 | C-116___AUTHORITY_AUTOMATION_CONSTITUTION.md | 266 | 2026-06-18 | Planned State | Documentation Verified | 13 |  |
| C-117 | C-117___REGISTRY_INTEGRITY_CONSTITUTION.md | 287 | 2026-06-18 | Current State | Documentation Verified | 11 | stale? |
| C-118 | C-118___DEPENDENCY_PROPAGATION_CONSTITUTION.md | 227 | 2026-06-18 | Current State | Code Verified | 8 | stale? |
| C-119 | C-119___ECONOMIC_OPERATING_SYSTEM_MODEL.md | 379 | 2026-06-26 | Future Vision | Assumed | 9 |  |
| C-120 | C-120___ZONE_CONSTITUTIONAL_RUNTIME_CHARTER.md | 526 | 2026-09-03 | Future Vision | Assumed | 25 |  |
| C-121 | C-121___INSTITUTIONAL_KNOWLEDGE_PIPELINE.md | 493 | 2026-07-31 | Future Vision | Assumed | 12 |  |
| C-122 | C-122___ANALYTICS_CONSTITUTIONAL_RUNTIME_CHARTER | 400 | 2026-06-28 | Future Vision | Assumed | 7 |  |
| C-123 | C-123___PI_BROWSER_SESSION_COOKIE_SPEC.md | 262 | 2026-07-02 | Current State | Runtime Verified | 24 | note: #153 adds §9; stale? |
| C-124 | C-124___NBF_BUSINESS_FOUNDATION_RUNTIME.md | 512 | 2026-07-31 | Future Vision | Assumed | 10 |  |
| C-125 | C-125___EPIC_CREATION_RUNTIME.md | 351 | 2026-07-31 | Future Vision | Assumed | 10 |  |
| C-126 | C-126___LEGEND_REPUTATION_RUNTIME.md | 389 | 2026-08-01 | Future Vision | Assumed | 24 |  |
| C-127 | C-127___ELITE_EXCELLENCE_RUNTIME.md | 417 | 2026-07-31 | Future Vision | Assumed | 15 |  |
| C-128 | C-128___VIP_PREMIUM_EXPERIENCE_RUNTIME.md | 403 | 2026-07-31 | Planned State | Assumed | 14 |  |
| C-129 | C-129___INSURE_RISK_PROTECTION_RUNTIME.md | 483 | 2026-07-31 | Future Vision | Assumed | 16 |  |
| C-130 | C-130___TITAN_ENTERPRISE_OS_RUNTIME.md | 305 | 2026-07-31 | Future Vision | Assumed | 9 |  |
| C-131 | C-131___BROOKFIELD_INFRASTRUCTURE_RUNTIME.md | 302 | 2026-07-31 | Future Vision | Assumed | 9 |  |
| C-132 | C-132___SERVICE_EXTRACTION_MODULAR_ARCHITECTURE_ | 333 | 2026-08-01 | Current State | Documentation Verified | 18 |  |
| C-133 | C-133___PLATFORM_ADOPTION_GROWTH_GOVERNANCE.md | 358 | 2026-07-25 | Current State | Documentation Verified | 28 |  |
| C-134 | C-134___PIONEER_RUNTIME_CHARTER.md | 510 | 2026-09-05 | Planned State | Documentation Verified | 7 |  |
| C-135 | C-135___LAUNCH_STRATEGY_FOCUSED_8.md | 218 | 2026-07-26 | Current State | Documentation Verified | 4 |  |
| - | archive/47___TEC_Kernel_Spec_v1_1.1__Constitutio | 386 | 2026-06-18 | Future Vision | — | 0 |  |

---

## Appendix B — every other file (153), by folder

#### (root)/ (11)

| File | Last edit | Finding |
|---|---|---|
| `.cursorrules` | 2026-07-31 |  |
| `.editorconfig` | 2026-06-18 |  |
| `.gitignore` | 2026-06-18 |  |
| `.mcp.json` | 2026-06-15 |  |
| `AGENTS.md` | 2026-06-18 |  |
| `CLAUDE.md` | 2026-09-13 | P3 716-line append-only session log; stale counts; verify-runtime.mjs lives in backend |
| `CODE_OF_CONDUCT.md` | 2026-06-18 |  |
| `CONTRIBUTING.md` | 2026-06-18 |  |
| `LICENSE` | 2026-06-18 |  |
| `README.md` | 2026-07-31 | P3 "13 CI gates", "112 C-docs", v3.12.0 — all stale |
| `SECURITY.md` | 2026-06-18 |  |

#### .claude/ (1)

| File | Last edit | Finding |
|---|---|---|
| `.claude/settings.json` | 2026-06-13 |  |

#### .claude-plugin/ (1)

| File | Last edit | Finding |
|---|---|---|
| `.claude-plugin/plugin.json` | 2026-06-17 |  |

#### .github/ (7)

| File | Last edit | Finding |
|---|---|---|
| `.github/CODEOWNERS` | 2026-06-18 |  |
| `.github/ISSUE_TEMPLATE/config.yml` | 2026-06-18 |  |
| `.github/ISSUE_TEMPLATE/correction.md` | 2026-06-18 |  |
| `.github/ISSUE_TEMPLATE/knowledge_gap.md` | 2026-06-18 |  |
| `.github/PULL_REQUEST_TEMPLATE.md` | 2026-06-18 |  |
| `.github/dependabot.yml` | 2026-06-18 |  |
| `.github/workflows/knowledge-ci.yml` | 2026-09-13 |  |

#### agents/ (4)

| File | Last edit | Finding |
|---|---|---|
| `agents/README.md` | 2026-06-15 |  |
| `agents/cmo-advisor/SKILL.md` | 2026-06-15 |  |
| `agents/design-system-advisor/SKILL.md` | 2026-06-15 |  |
| `agents/growth-advisor/SKILL.md` | 2026-06-15 |  |

#### architecture/ (5)

| File | Last edit | Finding |
|---|---|---|
| `architecture/PLATFORM_ARCHITECTURE.md` | 2026-06-15 | P3 cites C-64___ADR_SYSTEM.md (wrong name); "4 apps" era |
| `architecture/app-fleet.yaml` | 2026-07-17 | OK — matches Hub registry + SSO allowlist, all 24 |
| `architecture/asset-registry.yaml` | 2026-09-13 |  |
| `architecture/registry-integrity-report.md` | 2026-09-13 | P3 generated artefact with local absolute paths |
| `architecture/registry-integrity-rules.yaml` | 2026-07-17 |  |

#### audits/ (29)

| File | Last edit | Finding |
|---|---|---|
| `audits/A2U_FIRST_PAYOUT_ROUND_2026-09-13.md` | 2026-09-13 |  |
| `audits/CAMPAIGN_SURFACES_ENGINEERING_REPORT_2026-09-19.md` | 2026-09-19 |  |
| `audits/COMPETITIVE_TEARDOWN_REPUTA_SCORE_2026-08-19.md` | 2026-08-20 |  |
| `audits/DEPTH_MODULES_2026-07-17.md` | 2026-07-17 |  |
| `audits/DEPTH_MODULES_2026-07-18_read-expansion.md` | 2026-07-18 |  |
| `audits/EVENT_CONSUMER_IDEMPOTENCY_AUDIT_2026-08-01.md` | 2026-08-01 |  |
| `audits/EVENT_STREAM_NAME_CONSISTENCY_AUDIT_2026-08-01.md` | 2026-08-01 |  |
| `audits/EXECUTION_PLAN_2026-06-21.md` | 2026-06-22 |  |
| `audits/EXTERNAL_AUDIT_2026-06-20_Session14.md` | 2026-06-21 |  |
| `audits/FOUR_RUNTIMES_BUILD_ORDER_2026-09-13.md` | 2026-09-13 |  |
| `audits/FOUR_RUNTIMES_ENGINEERING_REPORT_2026-09-13.md` | 2026-09-13 |  |
| `audits/GROWTH_AUTOPILOT_PROPOSAL_2026-08-14.md` | 2026-08-20 |  |
| `audits/KB_STRATEGIC_REVIEW_2026-06-21.md` | 2026-06-21 |  |
| `audits/LIFE_AUDIT_2026-09-03.md` | 2026-09-05 |  |
| `audits/MARKETPLACE_SELLER_PAYOUT_GAP_2026-08-19.md` | 2026-08-20 |  |
| `audits/NEXUS_IIC_ENGINEERING_REPORT_2026-09-13.md` | 2026-09-13 |  |
| `audits/NEXUS_IIC_v0.1_SPEC_2026-09-13.md` | 2026-09-13 |  |
| `audits/PER_APP_LAUNCH_ENV_MATRIX.md` | 2026-07-16 |  |
| `audits/PIONEERS_SURFACE_ENGINEERING_REPORT_2026-09-19.md` | 2026-09-19 |  |
| `audits/PIONEER_ACQUISITION_INTERVIEW_FIRST_2026-08-16.md` | 2026-08-20 |  |
| `audits/PI_PORTAL_TESTNET_GATING_2026-09-06.md` | 2026-09-12 |  |
| `audits/PI_TESTNET_GATE_FINDINGS_2026-09-06.md` | 2026-09-12 |  |
| `audits/PI_TESTNET_HOST_OWNERSHIP_2026-09-12.md` | 2026-09-12 |  |
| `audits/PI_TESTNET_PAYMENT_LATENCY_2026-09-11.md` | 2026-09-12 |  |
| `audits/PLATFORM_WORK_MAP_2026-06-21.md` | 2026-06-22 |  |
| `audits/PORTAL_SUBMISSION_RUNBOOK_2026-06-21.md` | 2026-07-17 |  |
| `audits/SOLOHOST_TEC_AI_DX_ENGINEERING_REPORT_2026-09-13.md` | 2026-09-13 |  |
| `audits/UNIFIED_ENGINEERING_REPORT_2026-06-21.md` | 2026-06-21 |  |
| `audits/WRITE_PATHS_2026-07-18.md` | 2026-07-18 |  |

#### commands/ (8)

| File | Last edit | Finding |
|---|---|---|
| `commands/README.md` | 2026-06-15 |  |
| `commands/check-ci.md` | 2026-06-15 |  |
| `commands/check-deployments.md` | 2026-06-15 |  |
| `commands/check-violations.md` | 2026-06-15 |  |
| `commands/knowledge-sync.md` | 2026-06-15 |  |
| `commands/new-adr.md` | 2026-06-15 | P3 cites C-64___ADR_SYSTEM.md (wrong name) |
| `commands/new-skill.md` | 2026-06-15 |  |
| `commands/platform-health.md` | 2026-06-15 |  |

#### deliverables/ (4)

| File | Last edit | Finding |
|---|---|---|
| `deliverables/docs/PHASE_B2_PRD.md` | 2026-06-21 |  |
| `deliverables/docs/SMOKE_TEST_VIDEO_SCRIPT.md` | 2026-06-21 |  |
| `deliverables/docs/TEMPLATE_V2_DESIGN.md` | 2026-06-21 |  |
| `deliverables/patches/doc-inconsistency-fix.sh` | 2026-06-21 |  |

#### docs/ (2)

| File | Last edit | Finding |
|---|---|---|
| `docs/QUICKSTART.md` | 2026-07-31 |  |
| `docs/STRATEGIC_ROADMAP_90DAY.md` | 2026-06-18 |  |

#### evals/ (20)

| File | Last edit | Finding |
|---|---|---|
| `evals/check-authority-consistency.sh` | 2026-06-18 |  |
| `evals/check-c57-index.sh` | 2026-06-18 |  |
| `evals/check-canonical-numbering.sh` | 2026-07-31 |  |
| `evals/check-capability-registry.sh` | 2026-09-13 |  |
| `evals/check-events-catalog.sh` | 2026-07-31 |  |
| `evals/check-header-tokens.sh` | 2026-08-28 |  |
| `evals/check-knowledge-gaps.sh` | 2026-06-17 |  |
| `evals/check-links.sh` | 2026-06-18 |  |
| `evals/check-marketing-live-claims.sh` | 2026-07-25 |  |
| `evals/check-portal-readiness.sh` | 2026-09-12 |  |
| `evals/check-registry-integrity.sh` | 2026-07-17 |  |
| `evals/check-runtime-evidence.sh` | 2026-07-17 |  |
| `evals/check-session-canonical.sh` | 2026-07-31 |  |
| `evals/check-slo-definitions.sh` | 2026-06-22 |  |
| `evals/check-truth-framework.sh` | 2026-06-18 |  |
| `evals/check-vam-compliance.sh` | 2026-06-18 |  |
| `evals/check-whats-live.sh` | 2026-07-25 |  |
| `evals/validate-charters.sh` | 2026-06-18 |  |
| `evals/validate-skills.sh` | 2026-06-17 |  |
| `evals/validate-structure.sh` | 2026-06-18 |  |

#### governance/ (2)

| File | Last edit | Finding |
|---|---|---|
| `governance/LANGUAGE_POLICY.md` | 2026-06-18 |  |
| `governance/TEC_GOVERNANCE_CHARTER_v1.2.md` | 2026-06-18 |  |

#### manifests/ (8)

| File | Last edit | Finding |
|---|---|---|
| `manifests/app-rollout-registry.yaml` | 2026-07-17 | P3 not valid YAML (Markdown); [Deprecated] — fine |
| `manifests/capability-registry.yaml` | 2026-09-13 |  |
| `manifests/dependency-graph.yaml` | 2026-07-02 | P2 drift vs registry (+187/−43), no gate |
| `manifests/events-catalog.yaml` | 2026-09-13 | OK — every event found in backend code |
| `manifests/runtime-evidence-coverage.yaml` | 2026-07-17 |  |
| `manifests/runtime-evidence-schema.yaml` | 2026-07-17 | P3 not valid YAML (fenced) |
| `manifests/slo-definitions.yaml` | 2026-06-22 | P2 conflicts with C-62; P3 not valid YAML (fenced) |
| `manifests/verification-authority-matrix.yaml` | 2026-06-18 | P3 not valid YAML (fenced) |

#### marketing/ (9)

| File | Last edit | Finding |
|---|---|---|
| `marketing/README.md` | 2026-07-25 |  |
| `marketing/ambassador-kit.md` | 2026-07-25 |  |
| `marketing/faq.md` | 2026-07-25 |  |
| `marketing/launch-plan.md` | 2026-08-20 |  |
| `marketing/launch-posts.md` | 2026-07-25 |  |
| `marketing/one-liners.md` | 2026-08-20 |  |
| `marketing/outreach.md` | 2026-07-25 |  |
| `marketing/pi-portal-copy.md` | 2026-07-23 |  |
| `marketing/whats-live.md` | 2026-08-20 |  |

#### memory/ (2)

| File | Last edit | Finding |
|---|---|---|
| `memory/README.md` | 2026-06-15 |  |
| `memory/platform-snapshot.md` | 2026-06-18 | P2 says "Phase 0 → Pre-Mainnet" as current |

#### runtime-evidence/ (10)

| File | Last edit | Finding |
|---|---|---|
| `runtime-evidence/README.md` | 2026-07-17 |  |
| `runtime-evidence/ev-2026-06-22-010.yaml` | 2026-06-25 |  |
| `runtime-evidence/ev-2026-06-25-011.yaml` | 2026-06-26 |  |
| `runtime-evidence/ev-2026-06-26-012.yaml` | 2026-06-26 |  |
| `runtime-evidence/ev-2026-06-26-013.yaml` | 2026-06-26 |  |
| `runtime-evidence/ev-2026-07-16-024.yaml` | 2026-07-17 | P3 newest real record — loop dormant since |
| `runtime-evidence/examples/consumer-liveness-example.yaml` | 2026-08-01 |  |
| `runtime-evidence/examples/health-snapshot-example.yaml` | 2026-06-22 |  |
| `runtime-evidence/examples/incident-example.yaml` | 2026-06-22 |  |
| `runtime-evidence/examples/slo-breach-example.yaml` | 2026-06-22 |  |

#### scripts/ (9)

| File | Last edit | Finding |
|---|---|---|
| `scripts/ahv_engine.py` | 2026-06-18 |  |
| `scripts/build-asset-registry.py` | 2026-07-26 |  |
| `scripts/check_header_tokens.py` | 2026-08-28 |  |
| `scripts/impact_analysis.py` | 2026-06-18 | P3 duplicates registry-impact-analysis.py; not in CI |
| `scripts/preflight.sh` | 2026-08-28 |  |
| `scripts/propagate-dependency.py` | 2026-06-18 |  |
| `scripts/regenerate-cdg.py` | 2026-06-18 |  |
| `scripts/registry-impact-analysis.py` | 2026-06-18 |  |
| `scripts/verify-palette.mjs` | 2026-08-28 |  |

#### skills/ (17)

| File | Last edit | Finding |
|---|---|---|
| `skills/README.md` | 2026-06-17 |  |
| `skills/design/tec-design-system/SKILL.md` | 2026-06-26 |  |
| `skills/design/ui-patterns/SKILL.md` | 2026-06-26 |  |
| `skills/engineering/bff-patterns/SKILL.md` | 2026-06-15 |  |
| `skills/engineering/tec-testing/SKILL.md` | 2026-06-15 |  |
| `skills/marketing/community-marketing/SKILL.md` | 2026-06-15 |  |
| `skills/marketing/content-strategy/SKILL.md` | 2026-06-15 |  |
| `skills/marketing/pi-growth/SKILL.md` | 2026-06-15 |  |
| `skills/marketing/product-launch/SKILL.md` | 2026-06-15 |  |
| `skills/marketing/seo-aeo/SKILL.md` | 2026-06-15 |  |
| `skills/platform/charter-advisor/SKILL.md` | 2026-07-31 |  |
| `skills/platform/knowledge-orchestrator/SKILL.md` | 2026-06-15 |  |
| `skills/platform/mcp-orchestrator/SKILL.md` | 2026-06-15 |  |
| `skills/platform/observability/SKILL.md` | 2026-06-15 |  |
| `skills/platform/payment-expert/SKILL.md` | 2026-06-15 |  |
| `skills/platform/platform-architect/SKILL.md` | 2026-06-15 |  |
| `skills/platform/security-reviewer/SKILL.md` | 2026-06-15 |  |

#### templates/ (4)

| File | Last edit | Finding |
|---|---|---|
| `templates/new-adr/ADR-TEMPLATE.md` | 2026-06-15 |  |
| `templates/new-c-document/C-XX-TEMPLATE.md` | 2026-06-15 |  |
| `templates/new-charter/CHARTER_TEMPLATE.md` | 2026-06-18 |  |
| `templates/new-skill/SKILL.md` | 2026-06-15 |  |
