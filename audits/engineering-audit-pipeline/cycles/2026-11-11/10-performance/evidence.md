# 10-performance evidence — cycle 2026-11-11 · Run 5

All reads `git show origin/main:<path>` / `git grep … origin/main`; nothing deployed was touched.

| Ref | Finding | Location | Observation |
|---|---|---|---|
| EV-0089 | 0041 | `tec-search-service explorer.service.ts:235 · explorer.controller.ts:105` | findMany(where) — no take |
| EV-0090 | 0041 | `tec-business-service nx.service.ts:112 · nx.controller.ts:27` | findMany(where) — no take |
| EV-0091 | 0041 | `tec-search-service schema.prisma:168` | @@index([search_text]) — btree |
| EV-0092 | 0043 | `Tec-core-backend/k6/` | two scripts; no recorded run |
| EV-0093 | 0043 | `manifests/slo-definitions.yaml` | availability only |
