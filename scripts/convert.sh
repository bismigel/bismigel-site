#!/usr/bin/env bash
# Convert org/*.org -> content/posts/<slug>/index.md (Hugo / Omegion theme).
# The converted Markdown is generated, not committed (content/ is git-ignored).
set -euo pipefail
cd "$(dirname "$0")/.."

PANDOC="${PANDOC:-pandoc}"
SITE_TITLE="${SITE_TITLE:-Writing}"

rm -rf content
mkdir -p content/posts

# Section index for the posts list page
cat > content/posts/_index.md <<EOF
---
title: "${SITE_TITLE}"
---
EOF

count=0
for f in org/*.org; do
  [ -e "$f" ] || continue
  slug="$(basename "$f" .org)"
  [ "$slug" = "index" ] && continue
  mkdir -p "content/posts/$slug"
  "$PANDOC" -s \
    -f org -t markdown \
    --wrap=none \
    "$f" -o "content/posts/$slug/index.md"
  count=$((count + 1))
done

echo ">> converted ${count} org file(s) into content/posts/"
