# P3 evidence — cycle 2026-11-11 · Run 2

```bash
# full history first — the clones were shallow (`git rev-parse --is-shallow-repository` → true)
git fetch --unshallow --no-tags origin            # in each of the 30 clones; ~7,000 commits in all

python3 tools/secret_scan.py      --repos-dir <clones>                  > secret-scan.json
python3 tools/dependency_audit.py --repos-dir <clones> --ref origin/main > dependency-audit.json
```

**The secret scan was proven able to find before its silence was trusted:** each of its 11
rules matched a fabricated credential of its kind (private key, AWS, GitHub, Slack, Anthropic,
OpenAI, Groq, Google, Stripe live, a database URL with a password, a hex secret assignment).
Its output names location only; no value is ever printed.

## Per finding

| Ref | Finding | Location | Observation |
|---|---|---|---|
| EV-0036 | 0018 | withheld | given to the owner directly |
| EV-0037 · 0038 | 0019 | `dependency-audit.json` · TEC-SDK lock | 14–15 high per app; SDK pins a flagged axios |
| EV-0039 | 0020 | `dependency-audit.json` | zod high in 38 locks, no in-range fix |
| EV-0040–0042 | 0021 | root vs `tec-frontend/` lock · Vercel build log `dpl_Hu21VDiAkb4XeB9BYwuuMGu8Z22R` | 15.5.29 vs 15.5.12; production built with 15.5.29 |
| EV-0043 · 0044 | 0022 | backend root `package.json` | Nest 10 monolith, no source; criticals proxy-addr, tar |
| EV-0045 | 0023 | three locks | happy-dom ≤ 21.0.3 |
| EV-0046–0048 | 0024 | `jwt-auth.ts:6-48` · `main.ts:705-720,758` · `product.controller.ts:35-46,79-81` | prefix exemptions; Swagger public; commerce re-verifies writes |
| EV-0049 | 0025 | Assets `src/app/api/debug/route.ts` | debug route in production |
| EV-0050 | 0026 | Hub `public/firebase-messaging-sw.js` | Firebase web key |
| EV-0051–0053 | 0027 | C-64 ADR-001 · Hub CLAUDE.md · template sso-callback | HttpOnly claimed; `httpOnly: false` decided and coded |

## Verified compliant (no finding)

- JWT: 135 verification calls; 128 pin `algorithms: ['HS256']`, 7 inherit it from the module —
  `tec-auth-service/src/modules/auth/auth.module.ts:15`, commerce `app.module.ts:26` and each
  module, identity `identity.module.ts:20`, realtime `app.module.ts:19`.
- `dangerouslySetInnerHTML`: Icon components (constant `PATHS[name]`) in 20 repos + Tec-ui; Hub
  `pioneers/faq/page.tsx:36` (`JSON.stringify` of a constant).
- `.env` history: `Tec-App/.env.local` (added and deleted 16 Feb 2026) and
  `tec-frontend/.env.local` (2 Apr 2026): variable names only reviewed — `PI_APP_ID`,
  `NEXT_PUBLIC_*` URLs and flags; no secret.

## Blocked

`curl https://<app>.tecosystem.app/` → `403` from this environment's egress proxy for every
host. The served headers are therefore **not verified**; HSTS in particular is assumed from
Vercel's platform default, not observed.
