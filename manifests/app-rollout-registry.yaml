# TEC App Rollout Registry v1.1

> **Version:** v1.1 — 5 July 2026 (Session 17 — reconciled with C-01 §4: Analytics live; Life/Connection built; Zone V0 scaffold)
> **Truth State:** `[Planned State]` (live apps are `[Current State]`)
> **Governance State:** `[Governance Approved]`
> **Verification:** `[Documentation Verified]`
> **Authority Scope:** `[Platform]`
> **Status:** `[Deprecated]` historical Session 17 snapshot — do not use for current
> fleet status or Portal identity.
> **Current source of truth:** `architecture/app-fleet.yaml`, cross-checked against
> C-01 §4 by `evals/check-portal-readiness.sh`.

---

## Purpose

Single tracker for the **24-app rollout** required by the Pi Core Team — one app per
auction domain. **5 are live on Mainnet**; Life + Connection are **built** from the
template but await deploy + Pi Portal registration; Zone is a **V0 scaffold**; the rest
remain to be built from `tec-template-base` (v2, production-ready by default). Approval
gate per app: **≥ 5 users visited**.

```
Per-app path:  clone tec-template-base  →  set name/domain/App ID/legal
            →  deploy (Vercel)  →  register (Pi Portal)  →  ≥5 users (marketing)
```

Domains follow the `<slug>.tecosystem.app` convention (live apps confirmed; the 20
auction domains must be confirmed against the registrar before Pi Portal setup —
the domain is bound to `Pi.init()`, so treat it fail-closed until confirmed).

Status legend: `live` = Mainnet + approved-pending-users · `built` = built from template,
awaiting deploy + Portal registration · `scaffold` = V0 skeleton (identity/payment wired,
frontend pending) · `to-build` = not yet created.

---

## Registry

```yaml
rollout_version: "1.1"
total_domains: 24
live: 5           # Hub · Commerce · Ecommerce · Assets · Analytics
built: 2          # Life · Connection (built from template, await deploy + Portal)
scaffold: 1       # Zone (V0 skeleton)
to_build: 16
approval_gate_per_app: ">=5 users visited"

apps:
  # ── LIVE (Mainnet) — App IDs are authoritative from C-01 §4 ───────────────
  - name: Tec (Hub)
    slug: tec
    domain: hub.tecosystem.app
    pi_app_id: tec-app-923b947851f9dfe1
    status: live
    track: production-ready
    repo: yasira82/tec-app
    blueprint: C-01
  - name: Commerce
    slug: commerce
    domain: commerce.tecosystem.app
    pi_app_id: commerce-app-68aa99081fc1897a
    status: live
    track: production-ready
    repo: yasira82/tec-commerce
    blueprint: C-101
  - name: Ecommerce
    slug: ecommerce
    domain: ecommerce.tecosystem.app
    pi_app_id: ecommerce-app-71ca4d3e462eaf54
    status: live
    track: production-ready
    repo: yasira82/tec-ecommerce
    blueprint: C-103
  - name: Assets
    slug: assets
    domain: assets.tecosystem.app
    pi_app_id: assets-app-af2fb490e7b03db7
    status: live
    track: production-ready
    repo: yasira82/tec-assets
    blueprint: C-100
  - name: Analytics
    slug: analytics
    domain: analytics.tecosystem.app
    pi_app_id: analytics-822d9810de66bc84   # C-01 §4 — registered 3 Jul 2026, Mainnet
    status: live
    track: production-ready
    repo: yasira82/tec-analytics-
    blueprint: C-105

  # ── BUILT (2) — built from tec-template-base, await deploy + Pi Portal ─────
  # Pi App ID present = registered in Portal; TBD = registration still pending.
  - { name: Life,       slug: life,       domain: life.tecosystem.app,       pi_app_id: life-app-c468e9eb5bf115fa, status: built, track: production-ready, repo: yasira82/tec-life,       blueprint: C-106, has_blueprint: true }
  - { name: Connection, slug: connection, domain: connection.tecosystem.app, pi_app_id: TBD,                      status: built, track: production-ready, repo: yasira82/tec-connection, blueprint: C-107, has_blueprint: true }

  # ── SCAFFOLD (1) — V0 skeleton: identity + payment key wired, frontend pending
  - { name: Zone,       slug: zone,       domain: zone.tecosystem.app,       pi_app_id: TBD, status: scaffold, track: production-ready, repo: yasira82/tec-zone, blueprint: C-120, has_blueprint: true }

  # ── TO BUILD (16) — clone tec-template-base v2 ────────────────────────────
  # pi_app_id: TBD (assigned at Pi Portal registration)
  # domain:    <slug>.tecosystem.app (CONFIRM vs registrar before Pi.init())
  # has_blueprint: true → a KB charter/blueprint already describes the product
  - { name: Explorer,   slug: explorer,   domain: explorer.tecosystem.app,   pi_app_id: TBD, status: to-build, track: future-vision, has_blueprint: true }
  - { name: Nexus,      slug: nexus,      domain: nexus.tecosystem.app,      pi_app_id: TBD, status: to-build, track: future-vision, has_blueprint: true }
  - { name: Alert,      slug: alert,      domain: alert.tecosystem.app,      pi_app_id: TBD, status: to-build, track: future-vision, has_blueprint: true }
  - { name: Nx,         slug: nx,         domain: nx.tecosystem.app,         pi_app_id: TBD, status: to-build, track: future-vision, has_blueprint: true }
  - { name: Fundx,      slug: fundx,      domain: fundx.tecosystem.app,      pi_app_id: TBD, status: to-build, track: future-vision, has_blueprint: true }
  - { name: Estate,     slug: estate,     domain: estate.tecosystem.app,     pi_app_id: TBD, status: to-build, track: future-vision, has_blueprint: true }
  - { name: Dx,         slug: dx,         domain: dx.tecosystem.app,         pi_app_id: TBD, status: to-build, track: build-next,    has_blueprint: true }
  - { name: System,     slug: system,     domain: system.tecosystem.app,     pi_app_id: TBD, status: to-build, track: build-next,    has_blueprint: true }
  - { name: Insure,     slug: insure,     domain: insure.tecosystem.app,     pi_app_id: TBD, status: to-build, track: expansion,     has_blueprint: false }
  - { name: Nbf,        slug: nbf,        domain: nbf.tecosystem.app,        pi_app_id: TBD, status: to-build, track: expansion,     has_blueprint: false }
  - { name: Epic,       slug: epic,       domain: epic.tecosystem.app,       pi_app_id: TBD, status: to-build, track: expansion,     has_blueprint: false }
  - { name: Legend,     slug: legend,     domain: legend.tecosystem.app,     pi_app_id: TBD, status: to-build, track: expansion,     has_blueprint: false }
  - { name: Brookfield, slug: brookfield, domain: brookfield.tecosystem.app, pi_app_id: TBD, status: to-build, track: expansion,     has_blueprint: false }
  - { name: Vip,        slug: vip,        domain: vip.tecosystem.app,        pi_app_id: TBD, status: to-build, track: expansion,     has_blueprint: false }
  - { name: Titan,      slug: titan,      domain: titan.tecosystem.app,      pi_app_id: TBD, status: to-build, track: expansion,     has_blueprint: false }
  - { name: Elite,      slug: elite,      domain: elite.tecosystem.app,      pi_app_id: TBD, status: to-build, track: expansion,     has_blueprint: false }

# Per-app rollout checklist (track each in this file as it progresses)
per_app_checklist:
  - repo_created          # clone tec-template-base
  - configured            # name · domain · App ID · legal pages (privacy/terms)
  - deployed              # Vercel on the domain
  - portal_registered     # Pi Developer Portal: App ID + domain + privacy + terms + Mainnet
  - smoke_tested          # real Pi payment Mode 1 + Mode 2
  - users_5plus           # approval gate — marketing (deferred until apps done)
```

---

## Governance notes

- **Blueprints:** every built/scaffolded app already has a KB charter (Life C-106 ·
  Connection C-107 · Zone C-120). Of the 16 still `to-build`, 8 have charters/blueprints
  (Explorer · Nexus · Alert · Nx · Fundx · Estate · Dx · System). The other 8
  (Insure · Nbf · Epic · Legend · Brookfield · Vip · Titan · Elite) are auction-domain
  holds that **still need a product definition** (a one-line purpose at minimum) before
  they are more than a compliant skeleton.
- **External audit gate:** C-77 / EXECUTION_PLAN require an independent security audit
  **≥ 9.5** before mainnet-scaling the Future-Vision apps. Skeletons can deploy to claim
  domains; full economic features wait on the audit.
- **Capacity (C-77):** solo developer → controlled expansion. The template (v2) makes
  each skeleton cheap; product depth is the real cost.
