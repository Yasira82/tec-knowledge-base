# Session 56q — the KB learned to check itself against the code, and its first run found three bugs (24 Sep 2026)

> Truth State: **[Current State]** · Verification: **[Code Verified]**, and **[Runtime Verified]**
> for the drift job (run #1: 34 pass · 0 fail · 0 skip, all 30 repos cloned).
> PRs: tec-knowledge-base **#154 · #155 · #156**; tec-app **#256**; `partitioned` in 22 repos
> (the 19 open fleet PRs + Insure #37 · Brookfield #19 · NBF #24 · Zone #53 · Nexus #39 ·
> System #42 · Nx #36 · Titan #35 · Vip #35). Plan: `audits/KB_REMEDIATION_PLAN_2026-09-24.md` step 9.

## 1. What was built

The audit's F1 said the gates prove form, never truth: C-20 had listed ports no service
listens on, and C-14 versions nobody published, with every gate green. Step 9 answers that:

| Piece | What it does |
|---|---|
| `scripts/check-drift.py` | Reads every code repo **at a git ref** (never the working tree) and checks 7 things: versions · ports · events (both directions) · cookies (None + Partitioned, object by object, never lax) · refresh renews `tec_user` with the token · fleet ↔ Hub registry + SSO allowlist + each app's `APP_SOURCE` · SLOs (C-78 §2 ↔ manifest) |
| `.github/workflows/drift.yml` | Mondays 06:00 UTC + manual. Clones all 30 repos, runs `--strict`: a repo it cannot read fails the run. The one private repo (Tec-core-backend) is read with `DRIFT_READ_TOKEN`, a fine-grained PAT, Contents: Read-only on that repo alone |
| `evals/check-verification-freshness.sh` | A `[Code/Runtime Verified]` doc whose `Last verified …: YYYY-MM-DD` is > 60 days old fails; no date = warning (27 docs — added only when a doc is really re-verified) |

## 2. The first run found real drift — in the code, not the KB

1. **`resolve-incomplete` set `tec_access_token` without `Partitioned`**, in tec-template-base
   and therefore in 21 apps cloned from it. In an embedded Pi Browser context that is a
   second token in a different jar (C-123 §2) — the same half-session class as the refresh
   bug. Fixed fleet-wide with a per-app test that fails on the old code.
2. **20 of the 2026-09-23 refresh PRs were still unmerged** — the name fix had not reached
   production in most apps. Merged the same day.
3. **After the merge, the Hub itself**: its refresh renewed the token but never `tec_user`.
   The apps had been fixed; the Hub's route is different code and was missed. This is the
   likeliest cause of the name vanishing on the Pioneers and Campaign pages — both are Hub
   pages. Fixed in tec-app #256; the script gained the `refresh` check so it cannot regrow.

Plus one KB fact: `app-fleet.yaml` said "Gateway :4000" (it is :3000).

## 3. Two process lessons

- **A merge can race a push.** Six PRs were merged at 10:57–11:00 UTC; the `partitioned`
  commit landed on the same branch at 11:02. The PRs showed merged, `main` did not have the
  fix. Found by checking `main`, not the PR state; six new PRs opened. *Check what `main`
  has, not what the PR says.*
- **Merged ≠ deployed.** ~30 merges in a day exhausted Vercel's Hobby build quota
  ("Deployment rate limited — retry in 24 hours"). 16 apps were live at their `main`; 8 were
  not (Estate · FundX · Nx · Titan · Vip · Insure · Brookfield · NBF), and Vercel does not
  retry on its own. Elite has **two** Vercel projects on one repo, so every Elite merge
  deploys twice. Previews on every `claude/*` push are the other half of the cost.

## 4. Open after this session

| # | Item |
|---|---|
| 1 | Re-deploy the 8 rate-limited apps + the Hub (#256) once the quota resets (25 Sep) |
| 2 | Phone: does the Hub keep the name a day after sign-in (#256)? Does "Try again" recover a silent Pi (#253)? |
| 3 | Elite's second Vercel project; previews for `claude/*` branches |
