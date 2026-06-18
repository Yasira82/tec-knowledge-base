#!/bin/bash
# TEC Knowledge Base — Markdown Relative Link Checker
# Verifies that every relative Markdown link points to a file that exists.
# External links (http/https/mailto) and pure anchors (#...) are ignored.

set -e

echo "🔗 TEC Knowledge Base — Markdown Link Check"
echo "==========================================="

if ! command -v python3 >/dev/null 2>&1; then
  echo "⚠️  python3 not available — skipping link check."
  exit 0
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
PY

echo ""
echo "✅ Link check complete."
