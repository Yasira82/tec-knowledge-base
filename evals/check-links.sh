#!/bin/bash
# TEC Knowledge Base — Markdown Relative Link Checker
# Verifies that every relative Markdown link points to a file that exists.
# External links (http/https/mailto) and pure anchors (#...) are ignored.

set -e

echo "🔗 TEC Knowledge Base — Markdown Link Check"
echo "==========================================="

if ! command -v python3 >/dev/null 2>&1; then
  echo "❌ python3 not available — cannot run the link check. A check that cannot run fails; it never passes."
  exit 1
fi

python3 - <<'PY'
import re, os, glob, sys

LINK_RE = re.compile(r'\[[^\]]*\]\(([^)]+)\)')
broken = []
checked = 0

for f in glob.glob('**/*.md', recursive=True):
    base = os.path.dirname(f)
    with open(f, encoding='utf-8', errors='ignore') as fh:
        text = fh.read()
    for raw in LINK_RE.findall(text):
        link = raw.strip()
        if link.startswith(('http://', 'https://', 'mailto:', '#')):
            continue
        path = link.split('#', 1)[0].split('?', 1)[0].strip()
        if not path:
            continue
        checked += 1
        target = os.path.normpath(os.path.join(base, path))
        if not os.path.exists(target):
            broken.append((f, link))

print(f"  Relative links checked: {checked}")
if broken:
    print(f"  ❌ Broken links: {len(broken)}")
    for f, l in broken:
        print(f"     {f} -> {l}")
    sys.exit(1)
print("  ✅ No broken relative links.")

# Bare paths to a C-doc in the files an agent EXECUTES from (skills, agents, commands,
# and the root instructions). A wrong name there is not a broken link a reader notices —
# it is an instruction to load a file that does not exist (KB review, 14 Nov 2026: two
# skills pointed at a C-47 name it never had). History (audits/, memory/) is not checked.
PATH_RE = re.compile(r'knowledge-base/C-\d+[A-Za-z0-9_.-]*\.md')
roots = ['skills', 'agents', 'commands', 'docs']
files = [f for r in roots for f in glob.glob(f'{r}/**/*.md', recursive=True)]
files += [f for f in ('CLAUDE.md', 'AGENTS.md', 'CONTRIBUTING.md', 'README.md') if os.path.exists(f)]
bad = sorted({(f, m) for f in files for m in PATH_RE.findall(open(f, encoding='utf-8', errors='ignore').read()) if not os.path.exists(m)})
print(f"  Agent-facing C-doc paths checked in {len(files)} files")
if bad:
    print(f"  ❌ Paths to C-docs that do not exist: {len(bad)}")
    for f, m in bad:
        print(f"     {f} -> {m}")
    sys.exit(1)
print("  ✅ Every C-doc path an agent is told to load exists.")
PY

echo ""
echo "✅ Link check complete."
