# Portal assets — generators

The Pi Portal images for every app, as code. The PNGs are not committed: they are
regenerated from here, so one change to the style reaches all 25 apps at once.

| Script | Makes | Portal field |
|---|---|---|
| `logos.py` → `render-logos.js` | `tec-<app>-logo-1024.png` — 1024×1024, gold on dark, no Pi logo | App logo |
| `intros.js` | `tec-<app>-intro-1080.png` — logo + name + two lines of copy + domain | Intro Preview Image |
| `crop-previews.js` | a cropped, optionally redacted phone screenshot, 900×1629 | Previews |

```bash
cd marketing/portal-assets
python3 logos.py                 # writes one <app>.svg per app + list.json
node render-logos.js             # SVG → PNG, plus sheet.png (all logos side by side)
node intros.js                   # needs the SVGs above + life.svg / commerce.svg
node crop-previews.js in.jpg out.jpg '[[200,1115,430,1190]]'
```

Environment: `PW_MODULE` (path to a `playwright` install), `CHROMIUM` (browser binary),
`HUB_ICON` (the Hub's `tec-icon-1024.png`). In the cloud container:
`PW_MODULE=/home/user/Tec-App/node_modules/playwright CHROMIUM=/opt/pw-browsers/chromium`.

The intro copy lives in `intros.js` and follows `../pi-portal-copy.md` — gated apps say
they are gated (FundX educational · Insure "not an insurer" · Brookfield "simulated").
Change the copy there first, then here.

Backlog of the listing pass: `audits/PORTAL_LISTING_BACKLOG_2026-09-26.md`.
