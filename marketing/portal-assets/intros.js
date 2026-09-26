const { chromium } = require(process.env.PW_MODULE || 'playwright');
const fs=require('fs');
const A=[
['hub','Hub','One Pi identity + wallet','for a whole economy.'],
['life','Life','Your goals, skills &amp; progress','— private by default.'],
['commerce','Commerce','Sell or buy with Pi —','real orders, real checkout.'],
['ecommerce','Ecommerce','Pi-native online stores —','browse, buy, check out.'],
['assets','Assets','Your Pi-native assets,','in one portfolio.'],
['analytics','Analytics','The real numbers behind Pi.','Real data only.'],
['connection','Connection','Your trusted Pi network.','Connections, trust, collaboration.'],
['zone','Zone','Verify what can be trusted.','Evidence, not claims.'],
['nexus','Nexus','Coordination across TEC apps.','Multi-step actions, tied together.'],
['explorer','Explorer','Discover who accepts Pi,','ranked by trust.'],
['system','System','The rules, in plain terms.','A read-only governance console.'],
['alert','Alert','One smart inbox.','Your TEC activity + Pi news.'],
['nx','NX','Your next Pi opportunity.','Jobs, grants, hackathons.'],
['dx','DX','Build on Pi fast.','SDKs, templates, guides.'],
['titan','Titan','Run your org on Pi.','Teams, roles, operations.'],
['epic','Epic','Build your Pi project.','Create, launch, grow.'],
['legend','Legend','Reputation,','earned — not bought.'],
['elite','Elite','Recognition for','real achievement.'],
['vip','VIP','Premium experiences','across the Pi ecosystem.'],
['nbf','NBF','Start a verified','Pi business.'],
['fundx','FundX','Learn how Pi','capital pools work.'],
['estate','Estate','Real estate on Pi —','explore, lease, manage.'],
['insure','Insure','See your Pi risk.','A risk platform, not an insurer.'],
['brookfield','Brookfield','Institutional assets on Pi.','A simulated preview.'],
];
const mark=s=>{
  if(s==='hub') return `<img src="data:image/png;base64,${fs.readFileSync(process.env.HUB_ICON || '../../../Tec-App/tec-frontend/public/brand/tec-icon-1024.png').toString('base64')}" width="440" height="440" style="margin-top:120px;border-radius:48px">`;
  const inner=fs.readFileSync(s+'.svg','utf8').replace(/^[\s\S]*?<rect[^>]*\/>/,'').replace('</svg>','');
  return `<svg width="440" height="440" viewBox="180 180 664 664" style="margin-top:120px">${inner}</svg>`;
};
const page=([s,name,l1,l2])=>`<body style="margin:0"><div style="width:1080px;height:1080px;position:relative;overflow:hidden;
 background:radial-gradient(ellipse at 50% 38%,#1A1D2B 0%,#08090D 72%);font-family:'DejaVu Sans',sans-serif;color:#fff;
 display:flex;flex-direction:column;align-items:center">${mark(s)}
 <div style="font-size:${name.length>8?84:92}px;font-weight:700;letter-spacing:2px;margin-top:40px"><span style="color:#FBB44A">TEC</span> ${name}</div>
 <div style="font-size:38px;color:#C9CCD6;margin-top:22px">${l1}</div>
 <div style="font-size:38px;color:#C9CCD6;margin-top:6px">${l2}</div>
 <div style="position:absolute;bottom:56px;font-size:26px;color:#7C8193;letter-spacing:3px">${s.toUpperCase()}.TECOSYSTEM.APP</div></div></body>`;
(async()=>{const b=await chromium.launch({executablePath: process.env.CHROMIUM || undefined});
const p=await b.newPage({viewport:{width:1080,height:1080}});
for(const a of A){await p.setContent(page(a)); await p.screenshot({path:`tec-${a[0]}-intro-1080.png`,clip:{x:0,y:0,width:1080,height:1080}});}
const cells=A.map(a=>`<img src="data:image/png;base64,${fs.readFileSync(`tec-${a[0]}-intro-1080.png`).toString('base64')}" width="270">`).join('');
await p.setViewportSize({width:1620,height:1080});
await p.setContent(`<body style="margin:0;background:#333;display:grid;grid-template-columns:repeat(6,270px)">${cells}</body>`);
await p.screenshot({path:'intro-sheet.png',fullPage:true}); await b.close();})();
