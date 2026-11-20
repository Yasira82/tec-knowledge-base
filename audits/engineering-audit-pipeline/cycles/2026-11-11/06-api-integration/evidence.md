# P5 evidence — cycle 2026-11-11 · Run 3

```bash
# gateway prefixes: '^/api/...' keys in service-registry.ts (60)
# app calls: git grep -hoIE '\$\{[^}]*\}/api/[A-Za-z0-9/_${}.?=&-]*' origin/main -- src tec-frontend/src
#   ${…} inside a path → X; query stripped; matched by prefix
# timeouts: each fetch(`${…}/api/…`) up to its closing ');' searched for signal|timeout|AbortSignal
python3 scripts/check-drift.py --repos-dir <clones> --ref origin/main      # 36 pass · 0 fail
```

The path matcher was shown to find before its silence was trusted: it reported the three
unmatched paths above, and each was confirmed by reading the call site.

| App | gateway calls without a timeout / all |
|---|---|
| Tec-App | 65/69 |
| Tec-Connection | 34/35 |
| Tec-Explorer | 25/26 |
| Tec-Epic | 22/23 |
| Tec-Alert · Tec-Legend | 18/19 |
| Tec-Assets · Tec-Nx | 17/18 |
| Tec-Ecommerce · Tec-Zone | 16/17 |
| Tec-Estate | 15/16 |
| Tec-Analytics- · Tec-Nexus · tec-nbf | 14/15 |
| Tec-Commerce · Dx · Elite · Insure · Life · Titan · Vip | 13/14 |
| tec-brookfield · tec-template-base · Tec-Fundx | 11/12 |
| Tec-system | 10/11 |
| **All** | **439/467** |

SDK-importing source files per app (tests excluded): 0 in Tec-Assets, Tec-Commerce, Tec-Life;
1 (`src/lib/sdk.ts`) in every other. TEC-SDK `origin/main`: last commit 2026-09-13, `1.4.0`.

| Ref | Finding | Location |
|---|---|---|
| EV-0068 · 0069 | 0033 | table above · NEW-W (gateway-side timeouts) |
| EV-0070–0072 | 0034 | `src/lib/sdk.ts:1` · counts above · TEC-SDK log |
| EV-0073 · 0074 | 0035 | `service-registry.ts` · `src/app/api/bff/items/route.ts:30,55` |
