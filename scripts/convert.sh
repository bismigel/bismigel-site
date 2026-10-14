#!/usr/bin/env bash
# Convert org/*.org -> content/posts/<slug>/index.md (Hugo / Omegion theme).
#
# Org tags (#+FILETAGS: :a:b:  or  #+TAGS: a b) become Hugo `tags` front matter.
set -euo pipefail
cd "$(dirname "$0")/.."

PANDOC="${PANDOC:-pandoc}"
SITE_TITLE="${SITE_TITLE:-Writing}"

rm -rf content
mkdir -p content/posts

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

  # ---- tags: "#+FILETAGS: :a:b:" or "#+TAGS: a b" ----
  raw_tags=""
  if grep -qiE '^#\+filetags:' "$f"; then
    raw_tags="$(grep -iE '^#\+filetags:' "$f" | head -1 | sed -E 's/^#\+filetags:[[:space:]]*//I')"
  elif grep -qiE '^#\+tags:' "$f"; then
    raw_tags="$(grep -iE '^#\+tags:' "$f" | head -1 | sed -E 's/^#\+tags:[[:space:]]*//I')"
  fi
  tags=""
  if [ -n "$raw_tags" ]; then
    csv="$(printf '%s' "$raw_tags" | tr ':' ',' | tr -s '[:space:]' ',' | sed -E 's/^,|,$//g; s/,,*/,/g')"
    tags="$(printf '%s' "$csv" | sed -E 's/[^,]+/"&"/g')"
  fi

  # Remove tag keywords before pandoc (it would emit them as raw org blocks)
  src="$(mktemp)"; md="$(mktemp)"
  grep -viE '^#\+(filetags|tags):' "$f" > "$src"
  "$PANDOC" -s -f org -t markdown --wrap=none "$src" -o "$md"
  rm -f "$src"

  # Org cross-links to sibling posts are written as [[file:<slug>.org][...]],
  # which pandoc renders as a relative href to a .org file -> 404 on the site.
  # Rewrite them to the real post URL, /posts/<slug>/.
  sed -i -E 's#\]\(([0-9A-Za-z._-]+)\.org\)#](/posts/\1/)#g' "$md"

  out="content/posts/$slug/index.md"
  if [ -n "$tags" ]; then
    awk -v t="$tags" 'NR==1 && $0=="---" {print; print "tags: [" t "]"; next} {print}' "$md" > "$out"
  else
    cp "$md" "$out"
  fi
  rm -f "$md"
  count=$((count + 1))
done

echo ">> converted ${count} org file(s) into content/posts/"
