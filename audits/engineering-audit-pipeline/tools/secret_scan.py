#!/usr/bin/env python3
"""P3 — credentials committed to any repository, in ANY commit of its history (not only main).

    python3 secret_scan.py --repos-dir /path/with/clones > secret-scan.json

Prints WHERE a match is (repository, commit, file, line, rule) and never the matched value:
a scan that copies a secret into its own report has leaked it a second time. A match is a
candidate; the auditor classifies it (test fixture, placeholder, real) in evidence.md.
"""
import argparse, json, re, subprocess, sys
from pathlib import Path

RULES = {
    'private-key':      r'-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----',
    'aws-access-key':   r'\b(AKIA|ASIA)[0-9A-Z]{16}\b',
    'github-token':     r'\b(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{36}\b|\bgithub_pat_[A-Za-z0-9_]{60,}',
    'slack-token':      r'\bxox[abposr]-[A-Za-z0-9-]{10,}',
    'anthropic-key':    r'\bsk-ant-[A-Za-z0-9_-]{20,}',
    'openai-key':       r'\bsk-(proj-)?[A-Za-z0-9]{32,}',
    'groq-key':         r'\bgsk_[A-Za-z0-9]{40,}',
    'google-api-key':   r'\bAIza[0-9A-Za-z_-]{35}\b',
    'stripe-live':      r'\b(sk|rk)_live_[0-9A-Za-z]{20,}',
    'db-url-password':  r'(postgres(ql)?|mysql|mongodb(\+srv)?|redis|rediss)://[^:@/\s"\'`]+:[^@/\s"\'`$<{]{6,}@(?!localhost|127\.0\.0\.1|postgres[:/]|redis[:/]|db[:/]|host[:/]|HOST)',
    'hex-secret-assign': r'(SECRET|PRIVATE_KEY|API_KEY|PASSWORD|TOKEN)\s*[:=]\s*["\']?[0-9a-f]{40,}["\']?',
}
SKIP_PATH = re.compile(r'(package-lock\.json|\.lock$|node_modules/|\.min\.js$|\.map$)')


def scan(repo):
    found = []
    for rule, rx in RULES.items():
        # -G: commits whose diff adds or removes a line matching the rule, across all refs
        p = subprocess.run(['git', '-C', str(repo), 'log', '--all', '-G', rx, '--format=%H', '--', '.'],
                           capture_output=True, text=True)
        for sha in dict.fromkeys(p.stdout.split()):
            diff = subprocess.run(['git', '-C', str(repo), 'show', '--format=', '-U0', sha],
                                  capture_output=True, text=True, errors='replace').stdout
            path = None
            for line in diff.splitlines():
                if line.startswith('+++ b/'):
                    path = line[6:]
                elif line.startswith('+') and not line.startswith('+++') and path and not SKIP_PATH.search(path):
                    if re.search(rx, line):
                        on_main = subprocess.run(['git', '-C', str(repo), 'grep', '-qE', rx, 'origin/main', '--', path],
                                                 capture_output=True).returncode == 0
                        found.append({'rule': rule, 'commit': sha[:12], 'path': path, 'still_on_main': on_main})
    seen, out = set(), []
    for f in found:
        k = (f['rule'], f['path'], f['commit'])
        if k not in seen:
            seen.add(k); out.append(f)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repos-dir', required=True)
    a = ap.parse_args()
    res = []
    for repo in sorted(p for p in Path(a.repos_dir).iterdir() if (p / '.git').exists()):
        hits = scan(repo)
        print(f'{repo.name}: {len(hits)}', file=sys.stderr)
        res.append({'repository': repo.name, 'candidates': hits})
    json.dump({'history': 'all refs fetched in each clone', 'rules': list(RULES), 'results': res}, sys.stdout, indent=2)
    print()


if __name__ == '__main__':
    main()
