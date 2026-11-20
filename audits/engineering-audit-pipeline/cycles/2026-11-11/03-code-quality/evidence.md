# P2 evidence — cycle 2026-11-11 · Run 2

```bash
python3 tools/code_quality.py --repos-dir <clones> --ref origin/main > code-quality.json
```

| Ref | Finding | Location | Observation |
|---|---|---|---|
| EV-0054 | 0028 | Tec-App `tec-frontend/src/lib-client/hooks/useWallet.ts:197` | failed history fetch swallowed |
| EV-0055 | 0028 | Tec-App `tec-frontend/src/lib-client/hooks/useAppPayments.ts:25` | failed payment list swallowed |
| EV-0056 | 0007 | `code-quality.json` → services[].validation | empty for analytics · commerce · identity · kyc · notification · realtime · storage |

Silent catches classified in the template (`sso-callback/route.ts:70,142,148`,
`layout.tsx:56,64,91`, `pi-payment.ts:63`, pioneer components): storage access, inline boot
script, token-audience fallback — best-effort by design. Backend `console.log`: 151 of 158 in
`scripts/` and `*.cli.ts`; none in a request path.
