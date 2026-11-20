# P10 evidence — cycle 2026-11-11 · Run 6

```bash
# resolved versions: packages[node_modules/<pkg>].version from every package-lock.json
# drift: node scripts/template-sync.mjs check ../<app> --repo <app>   (tec-template-base, 20 apps)
# duplicates: sha1 of every git-tracked src/**/*.ts(x) per app; a (path, hash) in >= 5 apps and in
#             none of template-sync's shared / fleet / markers  → 11 paths
# orphans: the gateway's 60 prefixes vs every /api/... literal in the apps (origin/main); live
#          catalog events with consumers: []
# advisories (0002 re-measured): npm audit --package-lock-only --omit=dev per Express service
```

**The duplicate search was checked before it was believed:** its first count (22) missed
template-sync's `fleet` list; the tool's own report named `src/app/error.tsx` as tracked, which
the search had called untracked. Recounted with every list: 11.

| Ref | Finding | Location | Observation |
|---|---|---|---|
| EV-0095 · 0096 | 0044 | per-file sha1 · `template-sync.json` | 11 untracked duplicates; auth/me 3 variants in 7 sampled apps |
| EV-0097–0099 | 0045 | lock files · Hub package.json · npm | tec-ui 2.1.0 ×3; sdk 1.4.0 unused; Hub has no tec-ui / tec-auth |
