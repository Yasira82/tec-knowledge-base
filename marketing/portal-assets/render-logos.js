const { chromium } = require(process.env.PW_MODULE || 'playwright');
const fs=require('fs'); const names=JSON.parse(fs.readFileSync('list.json'));
(async()=>{const b=await chromium.launch({executablePath: process.env.CHROMIUM || undefined});
const p=await b.newPage({viewport:{width:1024,height:1024}});
for(const n of names){await p.setContent(`<body style="margin:0">${fs.readFileSync(n+'.svg','utf8')}</body>`);
 await p.screenshot({path:`tec-${n}-logo-1024.png`,clip:{x:0,y:0,width:1024,height:1024}});}
const cells=names.map(n=>`<div style="text-align:center;color:#ccc;font:16px sans-serif"><img src="data:image/png;base64,${fs.readFileSync(`tec-${n}-logo-1024.png`).toString('base64')}" width="220"><br>${n}</div>`).join('');
await p.setViewportSize({width:1680,height:1260});
await p.setContent(`<body style="margin:0;background:#333;display:grid;grid-template-columns:repeat(7,240px);gap:0">${cells}</body>`);
await p.screenshot({path:'sheet.png',fullPage:true}); await b.close();})();
