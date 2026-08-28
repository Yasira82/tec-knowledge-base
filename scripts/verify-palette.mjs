#!/usr/bin/env node
/**
 * verify-palette.mjs — is the Pi amber actually ON SCREEN, fleet-wide?
 *
 * Session 46 moved WEALTH to the Pi amber (#FBB44A, C-83) and 23 repos merged it.
 * Merged is not deployed, and deployed is not verified: only Life, Zone and Epic
 * were ever seen on a real device. Checking the other twenty by hand is the kind
 * of chore nobody repeats, so it silently never happens — which is exactly how
 * the fleet ended up on THREE different golds in the first place.
 *
 * This fetches each live app and reads what it actually serves.
 *
 *   node scripts/verify-palette.mjs              # whole fleet
 *   node scripts/verify-palette.mjs zone life    # named apps only
 *   node scripts/verify-palette.mjs --json       # machine-readable
 *
 * Exit 0 = every reachable app serves the new palette and no old one.
 * Exit 1 = at least one app still serves a superseded value.
 * Exit 2 = nothing could be reached (network/DNS) — NOT a palette verdict.
 *
 * The distinction in exit 2 is the point: "I could not look" must never be
 * reported as "it is fine". An unreachable app is UNKNOWN, not PASS.
 *
 * Source of truth for the app list: architecture/app-fleet.yaml
 * Source of truth for the values:   C-83 (and @yasser172/tec-ui v3.0.0)
 */

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');

// C-83 §5 + tec-ui v3.0.0. Case-insensitive on the wire.
const EXPECTED = { '#FBB44A': 'gold / WEALTH', '#050816': 'bg layer 1' };
const SUPERSEDED = {
  '#d4af37': 'pre-2.0 legacy gold',
  '#FBBF24': 'v2.x amber-400 (superseded by the Pi amber)',
  '#020205': 'pre-2.0 background',
  '#0d0d14': 'pre-2.0 surface',
};

const args = process.argv.slice(2);
const asJson = args.includes('--json');
const only = args.filter((a) => !a.startsWith('--')).map((s) => s.toLowerCase());

function fleet() {
  // Deliberately a line parser rather than a YAML dependency: this script must
  // run from a bare checkout on any machine. Nothing here is worth an npm install.
  //
  // app-fleet.yaml writes each app as an inline flow map on ONE line:
  //   - { app: Hub, repo: Tec-App, domain: hub.tecosystem.app, ... }
  const text = readFileSync(join(ROOT, 'architecture/app-fleet.yaml'), 'utf8');
  const lines = text.split('\n');
  const apps = [];
  for (const raw of lines) {
    // The `}\s*$` form silently dropped the four apps whose line carries a
    // trailing `# comment` (Estate, FundX, Insure, Brookfield) — a checker that
    // quietly examines 20 of 24 is worse than one that fails.
    const m = raw.match(/^\s*-\s*\{(.*)\}\s*(?:#.*)?$/);
    if (!m) continue;
    const rec = {};
    for (const pair of m[1].split(',')) {
      const kv = pair.match(/^\s*([A-Za-z_]+)\s*:\s*(.*?)\s*$/);
      if (kv) rec[kv[1]] = kv[2].replace(/^["']|["']$/g, '');
    }
    if (rec.app && rec.domain) apps.push(rec);
  }

  // Loud on drift: if the file declares more apps than we parsed, say so and
  // stop. Silently checking a subset is how a green report starts lying.
  const declared = lines.filter((l) => /^\s*-\s*\{.*\bapp:/.test(l)).length;
  if (!apps.length || apps.length !== declared) {
    console.error(`FATAL: parsed ${apps.length} of ${declared} apps declared in architecture/app-fleet.yaml.`);
    console.error('The file format changed. Refusing to report on a partial fleet.');
    process.exit(2);
  }
  return apps;
}

async function probe(url) {
  const ctl = new AbortController();
  const t = setTimeout(() => ctl.abort(), 20000);
  try {
    const res = await fetch(url, {
      signal: ctl.signal,
      redirect: 'follow',
      headers: { 'user-agent': 'tec-verify-palette' },
    });
    return { ok: true, status: res.status, body: await res.text() };
  } catch (e) {
    return { ok: false, error: e.name === 'AbortError' ? 'timeout' : e.message };
  } finally {
    clearTimeout(t);
  }
}

const hits = (body, hex) => (body.match(new RegExp(hex.replace('#', '#?'), 'gi')) || []).length;

const results = [];
for (const a of fleet()) {
  if (only.length && !only.includes(a.app.toLowerCase()) && !only.includes((a.app_source || '').toLowerCase())) continue;
  const url = `https://${a.domain}/`;
  const r = await probe(url);

  if (!r.ok) { results.push({ ...a, url, verdict: 'UNREACHABLE', detail: r.error }); continue; }

  // A non-2xx body is NOT the app. Scanning it finds no colour and would report
  // "inconclusive", which reads as a soft pass. It is not: an egress proxy's
  // 403 page, a Vercel error, or a login wall all land here, and none of them
  // tell you anything about the palette. Caught exactly this way in testing —
  // the sandbox proxy answers 403 with a plain-text body.
  if (r.status < 200 || r.status >= 300) {
    results.push({ ...a, url, verdict: 'UNREACHABLE', detail: `HTTP ${r.status} — not the app` });
    continue;
  }

  const found = Object.keys(EXPECTED).filter((h) => hits(r.body, h));
  const stale = Object.keys(SUPERSEDED).filter((h) => hits(r.body, h));

  // An app whose landing ships no colour literals at all (fully CSS-file driven)
  // is INCONCLUSIVE, not a pass — the page may still be painting the old palette
  // from a stylesheet this probe never fetched.
  const verdict = stale.length ? 'STALE' : found.length ? 'OK' : 'INCONCLUSIVE';
  results.push({ ...a, url, verdict, found, stale, status: r.status });
}

if (asJson) {
  console.log(JSON.stringify({ generated: new Date().toISOString(), results }, null, 2));
} else {
  const mark = { OK: '✅', STALE: '❌', INCONCLUSIVE: '❓', UNREACHABLE: '⚠️ ' };
  for (const r of results) {
    let note = '';
    if (r.verdict === 'STALE') note = r.stale.map((h) => `${h} (${SUPERSEDED[h]})`).join(', ');
    else if (r.verdict === 'OK') note = r.found.join(' ');
    else if (r.verdict === 'UNREACHABLE') note = r.detail;
    else note = 'no colour literal served — check the stylesheet by hand';
    console.log(`${mark[r.verdict]} ${r.app.padEnd(14)} ${r.domain.padEnd(34)} ${note}`);
  }
  const n = (v) => results.filter((r) => r.verdict === v).length;
  console.log(`\n  ok ${n('OK')} · stale ${n('STALE')} · inconclusive ${n('INCONCLUSIVE')} · unreachable ${n('UNREACHABLE')}  (of ${results.length})`);
}

if (!results.length) {
  console.error(`\nNo app matched ${JSON.stringify(only)} — nothing was checked.`);
  process.exit(2);
}
// Exit 0 requires POSITIVE confirmation from at least one app. A run that
// reached nothing, or reached everything and confirmed nothing, is exit 2 —
// "I could not look" must never be indistinguishable from "it is fine".
const stale = results.filter((r) => r.verdict === 'STALE').length;
const confirmed = results.filter((r) => r.verdict === 'OK').length;
if (stale) process.exit(1);
if (!confirmed) {
  console.error('\nNothing was CONFIRMED on the new palette — this is not a pass.');
  process.exit(2);
}
process.exit(0);
