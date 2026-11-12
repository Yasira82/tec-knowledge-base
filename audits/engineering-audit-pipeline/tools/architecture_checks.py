#!/usr/bin/env python3
"""P1 — Architecture & baseline compliance: each canonical rule, searched for in code.

    python3 architecture_checks.py --repos-dir /path/with/clones --ref origin/main > hits.json

Every check names the rule it enforces. A HIT is a candidate, not a finding: the auditor
reads each one and records it as a finding or as a false positive with the reason (the
run's evidence.md). Reads `origin/<ref>` only; tests are excluded (a test that names a
forbidden pattern to forbid it is not a violation).
"""
import argparse, json, re, subprocess, sys
from pathlib import Path

SRC = ['*.ts', '*.tsx', '*.js', '*.mjs', '*.cjs']
NOT_TESTS = re.compile(r'(__tests__/|\.test\.|\.spec\.|/test/|/e2e/|node_modules/|\.d\.ts$)')
APPS = lambda r: r.lower() not in {'tec-core-backend', 'tec-sdk', 'tec-ui', 'tec-auth', 'tec-knowledge-base'}
BACKEND = lambda r: r.lower() == 'tec-core-backend'

# id, rule reference, scope, regex (git grep -E), path filter (regex on the path, optional)
CHECKS = [
    ('P1-C01', 'C-47 §12 — JWT verified, never decoded', 'all',
     r'jwt\.decode\(|decodeJwt\(', None),
    ('P1-C02', 'C-47 §12 · ADR-001 — no token in web storage', 'all',
     r'(localStorage|sessionStorage)\.setItem\([^)]*(token|jwt|access)', None),
    ('P1-C03', 'C-47 §12 — no CORS wildcard', 'all',
     r"origin:\s*['\"]\*['\"]|Access-Control-Allow-Origin['\"],\s*['\"]\*|origin:\s*true\b", None),
    ('P1-C04', 'C-47 §12 — internal key compared in constant time', 'backend',
     r"(x-internal-key|internalKey|INTERNAL_SECRET)[^;\n]{0,80}(===|!==)", None),
    ('P1-C06', 'C-47 §12 · C-71 — Pi amounts are DECIMAL(20,8), never Float', 'backend',
     r'^\s*\w*(amount|balance|price|total)\w*\s+Float', r'schema\.prisma$'),
    ('P1-C08', 'C-47 §12 — identity from the session, never from the body', 'all',
     r'body\??\.(userId|user_id|ownerId|owner_id|merchantId|merchant_id|buyerId|buyer_id|sellerId|seller_id|payerId|payer_id)\b', None),
    ('P1-C12', 'ADR-005 · NEW-A — no internal service URL in the browser', 'apps',
     r'NEXT_PUBLIC_[A-Z_]*(GATEWAY|SERVICE|RAILWAY|BACKEND|INTERNAL)[A-Z_]*|\.up\.railway\.app|railway\.internal', None),
    ('P1-C13', 'C-123 §11 · C-12 §11 — CSRF validated in middleware only', 'apps',
     r'csrfCookie\s*!==\s*csrfHeader|csrfCookie\s*===\s*csrfHeader|CSRF token mismatch|CSRF validation failed', r'/api/'),
    ('P1-C16', 'PAL (R1) — window.Pi only through PiRuntime', 'apps',
     r'window\.Pi\.(authenticate|createPayment|init)\(|\(window as any\)\.Pi\.(authenticate|createPayment|init)\(', None),
    # The Pi Platform API (api.minepi.com / api.sandbox.minepi.com). The base URL is built
    # from a constant, so the HOST is searched, not a path: a path pattern found nothing and
    # read as compliant (cycle 2026-11-11). Horizon (api.mainnet|testnet.minepi.com) is the
    # public ledger, read-only, and is not this API. Image hosts in next.config are not calls.
    ('P1-C18', 'ADR-002 · ADR-004 — the Pi Platform API is called only by tec-auth-service (identity) and tec-payment-service (payments)', 'backend+apps',
     r'api\.(sandbox\.)?minepi\.com', r'^(?!.*next\.config)'),
    ('P1-C20a', 'ADR-009 — the inter-service header is x-internal-key only', 'all',
     r'x-service-secret|SERVICE_SECRET', None),
    ('P1-C20b', 'ADR-009 — a payment amount is a number', 'all',
     r'amount:\s*z\.string\(', None),
    ('P1-C21', 'C-47 Forbidden #4 — no business logic in the gateway (direct DB access)', 'backend',
     r'PrismaClient|@prisma/client', r'^tec-api-gateway/'),
]


def grep(repo, ref, pattern):
    p = subprocess.run(['git', '-C', str(repo), 'grep', '-n', '-I', '-E', '-e', pattern, ref, '--', *SRC, '*.prisma'],
                       capture_output=True, text=True)
    out = []
    for line in p.stdout.splitlines():
        _, path, num, text = line.split(':', 3)
        out.append({'path': path, 'line': int(num), 'text': text.strip()[:220]})
    return out


def in_scope(scope, repo):
    return {'all': repo.lower() != 'tec-knowledge-base', 'apps': APPS(repo), 'backend': BACKEND(repo),
            'backend+apps': repo.lower() != 'tec-knowledge-base'}[scope]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repos-dir', required=True)
    ap.add_argument('--ref', default='origin/main')
    a = ap.parse_args()
    repos = sorted(p for p in Path(a.repos_dir).iterdir() if (p / '.git').exists())
    result = []
    allowed_by = {'P1-C18': re.compile(r'^tec-(auth|payment)-service/')}
    for cid, rule, scope, pattern, path_filter in CHECKS:
        hits = []
        for repo in repos:
            if not in_scope(scope, repo.name):
                continue
            for h in grep(repo, a.ref, pattern):
                if NOT_TESTS.search(h['path']):
                    continue
                if path_filter and not re.search(path_filter, h['path']):
                    continue
                allowed = allowed_by.get(cid)
                if allowed and allowed.search(h['path']):
                    continue
                hits.append({'repository': repo.name, **h})
        result.append({'check': cid, 'rule': rule, 'scope': scope, 'pattern': pattern,
                       'hits': hits, 'status': 'HITS' if hits else 'CLEAN'})
    json.dump({'ref': a.ref, 'checks': result}, sys.stdout, indent=2)
    print()


if __name__ == '__main__':
    main()
