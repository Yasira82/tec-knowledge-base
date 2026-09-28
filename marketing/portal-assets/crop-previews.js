// Turn a phone screenshot into a Pi Portal "Previews" image.
//
//   node crop-previews.js <in.jpg> <out.jpg> ['[[x1,y1,x2,y2],...]']
//
// Input: a 1440x3120 Pi Browser screenshot. Drops the status + address bar
// (0..322) and the Android nav bar (2928..), scales to 900 wide → 900x1629 JPEG,
// above the Portal minimum of 750x1500 and far below its 1 MB cap.
//
// The optional boxes (coords in the 923-wide phone view the owner sees) are
// covered with a SOLID bar — another user's name or messages never go into a
// public listing. A blur was tried first and stayed readable; use the bar.
const { chromium } = require(process.env.PW_MODULE || 'playwright');
const fs = require('fs');
const [,, input, output, boxesJson = '[]'] = process.argv;
const boxes = JSON.parse(boxesJson);
const W = 900, K = W / 923;
(async () => {
  const b = await chromium.launch({ executablePath: process.env.CHROMIUM || undefined });
  const p = await b.newPage({ viewport: { width: W, height: Math.round(2000 * K) } });
  const d = 'data:image/jpeg;base64,' + fs.readFileSync(input).toString('base64');
  const bars = boxes.map(([x1, y1, x2, y2]) =>
    `<div style="position:absolute;left:${x1 * K}px;top:${y1 * K}px;width:${(x2 - x1) * K}px;height:${(y2 - y1) * K}px;background:#3A3D4A;border-radius:10px"></div>`).join('');
  await p.setContent(`<body style="margin:0;position:relative"><img src="${d}" style="display:block;width:${W}px">${bars}</body>`);
  await p.screenshot({ path: output, type: 'jpeg', quality: 88,
    clip: { x: 0, y: Math.round(206 * K), width: W, height: Math.round(1670 * K) } });
  await b.close();
})();
