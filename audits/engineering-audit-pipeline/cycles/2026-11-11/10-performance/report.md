# P9 — Performance & Scalability · cycle 2026-11-11 · Run 5

**Status: PASSED_WITH_FINDINGS** · [Code Verified] at `origin/main`, 13 Nov 2026. No benchmark
was run: there is no staging (TEC-AUDIT-0006) and load against production is not safe.

## What was checked, and what it found

| Check | Result |
|---|---|
| Queries without a row limit | 178 `findMany` in service code; 113 have no `take`. Read one by one: **most are bounded by their `where`** (one owner, one run, one wallet, a list of ids) or are admin/sweeper reads. The ones that grow with use **and** answer a public request → **0041** |
| Public directory search | **0041.** Explorer `search` and NX `search` return **every** matching listing — no page, no cap — and Explorer filters with `contains` on `search_text`, whose btree index cannot serve `LIKE '%…%'`: a full scan per word |
| Gateway under load | The June collapse (ev-2026-06-25-011) was fixed structurally (keep-alive pool, isolated `/health`, load shedding — NEW-U · NEW-W); BFF calls now have a deadline (0033, fixed locally) |
| Latency objectives | `slo-definitions.yaml` sets **availability** targets only — none for latency → part of **0043** |
| Capacity | k6 scripts exist (`k6/gateway-load-test.js`, `payment-load-test.js`, `workflow_dispatch` only); **no run has ever been recorded** → **0043** |
| My own search, corrected | The first count missed the shorthand `take,` and named owner fields (`sellerId`, `ownerId`); both fixed before any number was kept — "a search that finds nothing proves nothing" works both ways |

## Summary

At today's scale (C-02 item 23: no outside customer has paid yet) nothing here is slow. The two
findings are about what happens as the directories fill: answers that grow without a cap, and a
platform whose capacity has never been measured.
