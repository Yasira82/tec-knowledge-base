# Railway environment-variable breach — the rotation runbook (22 October 2026)

> Truth State: **[Current State]** for §1–§3 (the incident as Railway reported it, what is done,
> and the map of secrets read from code); **[Planned State]** for §4 (the order of the rotation
> still to do). Governance State: **[Governance Approved]** — the owner decides each step and does
> it by hand. Verification: **[Code Verified]** for the map in §3 (`git grep` over every service,
> 2026-10-23); **[Runtime Verified]** for each line marked ✅ in §2 (the owner's own screens).
> Last verified against code: 2026-10-23.
>
> **No secret value is written in this file, ever.** Names, places and order only.

## 1. What happened

On 22 Oct 2026 Railway emailed: "an unauthorized third party may have accessed encrypted
environment variables and, for some of them, obtained the decrypted contents", part of a series of
attacks on platform companies aimed at AI inference providers. Railway's advice: revoke and reissue
every variable, review logs. Builds were paused for a day; from 22 Oct 22:49 UTC Railway's status
page reports builds and deployments running normally, with the incident report still to come.

Not a sign of our own account being taken: the "project queued for deletion" email
(`easygoing-friendship`) was the owner's own action (confirmed 2026-10-23).

**Owner's decision (2026-10-23):** the secrets that matter most are replaced only after Railway
says the breach is **contained** — otherwise a new value could leak the same way. Revoking at the
provider (which needs no Railway) is done first; low-risk keys may go in before.

## 2. Done (✅) and waiting

| Secret | At the provider | In Railway |
|---|---|---|
| Cloudflare R2 — backups | ✅ new token `tec-backups-2026-10` (Object R/W, `tec-db-backups` only); old `railway-backup-write` deleted | ✅ set and redeployed 2026-10-23; manual run: `backup: complete … databases: 26 … failures: []`. `BACKUP_PASSPHRASE` unchanged — waits for "contained" |
| Cloudflare R2 — storage | ✅ new token `tec-storage-2026-10` (Object R/W, `tec-storage` only); old `tec-storage-token` deleted | ✅ storage-service set and Online; Tec-Commerce (Vercel) set and redeployed; asset-service never had them. Checked 2026-10-23: a new product photo in Commerce and an NFT image upload in Assets both worked |
| R2 — `github-backup-read` | kept: read-only, stored in GitHub secrets, never in Railway | — |
| R2 — was anything downloaded? | ✅ `tec-db-backups` metrics, 7 days: Class B (reads) ≈ 10 a day at backup time on 21 and 22 Oct as on every other day; one ≈ 37 days earlier (the restore check). A download of the backups would add ≥ 18 reads (one per database). **No sign of it.** ("Data Retrieved = 0" is not evidence: it counts Infrequent Access only.) | — |
| Groq | ✅ two new keys — `tec-railway-2026-10` (Railway) and `tec-github-eval-2026-10` (the quality eval); old deleted; GitHub secret `GROQ_API_KEY` updated | waiting — Life and TEC AI cannot answer until set |
| Gemini | ✅ new key; old `…jqls` deleted (free tier — no spend possible) | waiting |
| OpenRouter | ✅ new key `tec-railway-2026-10`, credit limit $1/month; old keys deleted; account showed $0 used and no activity | waiting |
| Anthropic | was never in Railway — nothing leaked | — |
| Mainnet A2U wallet (`PI_A2U_WALLET_SEED`) | the wallet `GBXU6DHS…MIQQ3R` is still **pending Pi's review** and holds nothing. Plan: replace the address while the application is pending (or ask Pi), and **never fund the old address** | to remove; `PI_HUB_APP_WALLET_ADDRESS` (public) lets the balance page work without it |
| Railway account | password · 2FA · revoke account tokens · review members | — |

## 3. Every secret and the services that read it (from code, 2026-10-23)

| Secret | Read by |
|---|---|
| `JWT_SECRET` | api-gateway, auth, ai, analytics, business, commerce, connection, identity, kyc, life, notification, payment, platform, realtime, search, storage, trust, wallet — **and every Vercel app** (tec-app, Tec-Life and the template's apps) |
| `JWT_REFRESH_SECRET` | auth |
| `INTERNAL_SECRET` | every service above plus asset and nexus — **and every Vercel app** |
| `INTENT_PROOF_SECRET` | nexus |
| `PI_API_KEY`, `PI_API_KEY_<APP>`, `…_TESTNET` | payment (one key per Pi app, regenerated in the Pi Developer Portal) |
| `PI_A2U_WALLET_SEED`, `…_TESTNET…` | payment |
| `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY` | backup-job (`tec-backups-…`), storage (`tec-storage-…`). asset-service's code reads them too, but production never had them set (2026-10-23): its domain-SVG upload has always fallen back to a data URL, so nothing is put there |
| `BACKUP_PASSPHRASE`, `ALERT_WEBHOOK_URL` | backup-job |
| `GROQ_API_KEY`, `GEMINI_API_KEY`, `OPENROUTER_API_KEY`, `UPSTASH_REDIS_REST_TOKEN` | ai |
| `DATABASE_URL` | every service with a database (change the role's password in Postgres first, then the variable) |
| `REDIS_URL` | nearly every service |
| `LIFE_CONVERSATION_KEY` | life — **do not change by hand**: every kept conversation would become unreadable; it needs a re-encryption step in code |
| `SSO_SECRET` | Vercel only — Vercel was not breached; no change needed |

**Outside Railway, the storage token is also read by the Tec-Commerce Vercel app**
(`src/app/api/bff/storage/upload/route.ts`: `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`,
`R2_BUCKET_NAME`, `R2_PUBLIC_URL`). Product image uploads there fail until the new
`tec-storage-…` values are put in Vercel and the app is redeployed.

**Found while rotating (2026-10-23): `tec-storage` has Public Access enabled (r2.dev).** The
storage-service code assumes the bucket is private, but the bucket also holds `kyc/`, `chat/` and
`stories/`. Keys contain a uuid, so they cannot be guessed. Still, a key that leaks anywhere (a log,
a forwarded link) can be read by anyone, with no expiry. Public access cannot simply be switched
off: Tec-Assets (`nft/upload`, hard-coded r2.dev URL), Tec-Commerce (`products/`) and
asset-service (`domains/`) hand out public URLs. Follow-up, in code: put private media (`kyc/`,
`chat/`, `stories/`) in a private bucket, read through signed URLs only. Then decide whether
the public bucket keeps only public media.

Unused variables in asset-service (its code reads none of them): `PI_API_KEY`, `JWT_REFRESH_SECRET`, `SSO_SECRET` — remove them.

**Secret copies no code reads (checked by `grep` over each service, 2026-10-23), to remove so
there is less to rotate:**

| Variable | Remove from |
|---|---|
| `PI_API_KEY` | every service except payment (commerce, gateway, auth, identity, realtime, analytics, kyc, notification, wallet) |
| `JWT_REFRESH_SECRET` | every service except auth |
| `SSO_SECRET` | api-gateway, auth (only the Vercel apps read it) |
| `JWT_PRIVATE_KEY` | auth (no code reads it; tokens are HS256 with `JWT_SECRET`) |
| `DIRECT_URL` | api-gateway (it has no database; the value is a database password) |
| `DATABASE_URL` | realtime (no database) |
| `PI_VALIDATION_KEY`, `PI_WALLET_ADDRESS`, `API_WEBHOOK_SECRET` | payment |
| `PI_API_KEY_CONNECTION_TESTNET` | identity (moved to payment) |

**Done 2026-10-23 (owner):** all of the above removed. One slip: identity-service's own
`DATABASE_URL` was removed too; its deploy failed (health check) while the previous version kept
serving. Restored as a reference, `${{db-identity.DATABASE_URL}}`, which closes the "literal
string" item in `DATABASE_PLACEMENT_AND_BACKUP_2026-10-12.md`; logs: `Connected to database`.

Kept on purpose: `PI_API_KEY_BROOKFIELD…` (payment resolves `PI_API_KEY_<SOURCE>` by name, and
`brookfield` is a source); `JWT_PUBLIC_KEY` is not a secret.

Unused variables found in payment-service (`PI_API_KEY_CN_TESTNET`, `PI_API_KEY_CON_TESTNET`,
`PI_API_KEY_CONNEN_TESTNET`; the code reads `PI_API_KEY_CONNECTION_TESTNET`) — remove them.

## 4. The rotation, once Railway says "contained"  *[Planned State]*

Each step on its own, checked before the next:

1. **AI keys** (low risk — free tiers, $1 cap) into `tec-ai-service`: `GROQ_API_KEY`,
   `GEMINI_API_KEY`, `OPENROUTER_API_KEY` → Apply. Check: a Life message gets an answer. *(May go
   in before "contained".)*
2. **Pi API keys**: Regenerate per app in the Pi Developer Portal (Hub first, then Ecommerce,
   Commerce, Assets, then the rest) → each into payment-service at once — the old key stops on
   regenerate. Remove `PI_A2U_WALLET_SEED`; add `PI_HUB_APP_WALLET_ADDRESS`. Check: a Testnet payment.
3. **R2 + backups**: backup-job ← `tec-backups-…` **and a new `BACKUP_PASSPHRASE` together** (the
   old passphrase saved outside Railway — without it the old backups cannot be opened); storage and
   asset ← `tec-storage-…`. Check: the next backup run succeeds; an upload works.
4. **Databases and Redis**: per database, new role password in Postgres → the matching
   `DATABASE_URL`; then Redis. One at a time; check each service is Online after.
5. **`JWT_SECRET`, `JWT_REFRESH_SECRET`, `INTERNAL_SECRET`, `INTENT_PROOF_SECRET`**: the same new
   values in **every Railway service and every Vercel app in the same hour**, then redeploy all
   (mind Vercel's daily build quota). Everyone signs in again once. Check: sign-in on the Hub and in
   two apps; a payment; Life.
6. `ALERT_WEBHOOK_URL`, `UPSTASH_REDIS_REST_TOKEN`; remove the unused variables (§3).
7. `LIFE_CONVERSATION_KEY` — only with the re-encryption code (to be built), never by hand.

When all are done: a short record in `runtime-evidence/` and the C-02 row closed.
