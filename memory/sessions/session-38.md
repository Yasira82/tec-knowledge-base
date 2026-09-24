# SESSION 38 — CONNECTION: DISCOVER DIRECTORY + CONNECTION PRO = FEATURED (8 Aug 2026) ✅

> Moved out of C-02 on 2026-09-24 (KB remediation step 7, audit F12). The text is
> unchanged apart from relative links, which now resolve from this folder.
> This is a **record of that session**, not current state — for current state read C-02.

> Truth State: **[Current State]** · Verification: **[Code Verified]** (PRs open). Eighth app deepened — the "make Pro real + serve the Pi community" campaign continues (NX → Connection).

### What it is
Connection's graph was **username-only** — you could follow a handle only if you already
knew it — and **Connection Pro enforced nothing** (it promised "unlimited collections",
which everyone already had). Two gaps closed with the proven pattern:
- **Community value → opt-in public discovery:** a **Discover directory** (`/app`) to find +
  follow people, plus a **public `/u/[username]` profile** reachable **outside a TEC session**
  (share `connection.tecosystem.app/u/<handle>` anywhere). Publishing is **opt-in**
  (sovereignty, C-107); verification is **presented** from Zone/kyc, never minted.
- **Real Pro → two genuine benefits (not just reach):**
  - **Network Insights** — the caller's OWN follower list + a `mutual` flag ("do I follow
    back?") + one-tap follow-back. Like "who viewed your profile" — **standalone value with
    zero population** (it's your own graph). The LIST is gated server-side behind live Pro
    (P5); the count is a non-sensitive teaser for non-Pro.
  - **⭐ Featured** directory card, ranked `verified → featured → recent` (reach only, within
    the verified tier — never trust). Both synced from the live subscription by the BFF (P5).
  - The Pro copy was rewritten from the empty "unlimited collections" claim to these.

### Backend / frontend (needs db push)
- `ConnectionProfile` (opt-in listing; `published` default false; `verified` presented;
  `featured` = Pro, `@@index`); `listDirectory` / `getPublicProfile` / `getMyProfile` /
  `upsertMyProfile` / `setDirectoryFeatured`. Controller: `GET discover` + `GET profile/:username`
  **public**; `profile/me` (GET/PUT) + `directory/featured` (PATCH) session-scoped. 20/20 connection tests.
- Discover section + "your public profile" editor + `/u/[username]` public page; BFF
  `/discover` + `/profile/[username]` (public) + `/profile/me` (own + featured reconcile). 23/23 frontend tests.

### The scorecard (8 apps: real Pro + a Pi-community surface)
| App | Real Pro | Pi-community surface (outside TEC) |
|-----|----------|-----------------------------------|
| Life | Unlimited goals | — |
| Explorer | ⭐ Featured listing | public merchant discovery |
| Zone | ⭐ Priority review | public verification badges |
| Legend | 🔖 Embeddable badge | public `/u` CV |
| Analytics | 📁 90-day export | public Pi Economy Pulse + peer comparison |
| Epic | ⭐ Featured project | public `/discover` project directory |
| NX | ⭐ Featured opportunity | public opportunity board + community posting |
| **Connection** | **📈 Network Insights (who follows you) + ⭐ Featured** | **public Discover directory + `/u/[handle]` profile** |

### PR ledger
tec-core-backend **#202** (ConnectionProfile + directory + followers endpoints, 22/22) ·
tec-connection **#27** (26/26). Ops: `db push` on `tec-identity-service` (`connection_profiles`).
All local gates green.
Next candidates: **Alert · DX**.
