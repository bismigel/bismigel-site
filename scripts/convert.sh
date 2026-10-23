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

  # ---- aliases: "#+ALIASES: /posts/old-slug/, /posts/other/" ----
  raw_aliases=""
  if grep -qiE '^#\+aliases:' "$f"; then
    raw_aliases="$(grep -iE '^#\+aliases:' "$f" | head -1 | sed -E 's/^#\+aliases:[[:space:]]*//I')"
  fi
  aliases=""
  if [ -n "$raw_aliases" ]; then
    aliases="$(printf '%s' "$raw_aliases" | tr ',' ' ' | tr -s '[:space:]' ' ' | sed -E 's/^ //; s/ $//; s/[^ ]+/"&"/g; s/ /, /g')"
  fi

  # Remove metadata keywords before pandoc (it would emit them as raw org blocks)
  src="$(mktemp)"; md="$(mktemp)"
  grep -viE '^#\+(filetags|tags|aliases):' "$f" > "$src"
  "$PANDOC" -s -f org -t gfm --wrap=none "$src" -o "$md"
  rm -f "$src"

  # Org cross-links to sibling posts are written as [[file:<slug>.org][...]],
  # which pandoc renders as a relative href to a .org file -> 404 on the site.
  # Rewrite them to the real post URL, /posts/<slug>/.
  sed -i -E 's#\]\(([0-9A-Za-z._-]+)\.org\)#](/posts/\1/)#g' "$md"

  # Pandoc escapes apostrophes as \' in its markdown output, which then shows up
  # as a literal backslash in the rendered HTML (title and body). Drop the escape.
  sed -i "s/\\\\'/'/g" "$md"
  sed -i 's/{\.verbatim}//g' "$md"

  out="content/posts/$slug/index.md"
  extra=""
  [ -n "$tags" ] && extra="tags: [$tags]"
  [ -n "$aliases" ] && extra="${extra}${extra:+$'\n'}aliases: [$aliases]"
  if [ -n "$extra" ]; then
    awk -v e="$extra" 'NR==1 && $0=="---" {print; print e; next} {print}' "$md" > "$out"
  else
    cp "$md" "$out"
  fi
  rm -f "$md"
  count=$((count + 1))
done

  echo ">> converted ${count} org file(s) into content/posts/"

  # ---- projects: org/projects/*.org -> content/projects/<slug>/index.md ----
  # Project front matter is explicit (Hugo needs keys like externalUrl/summary
  # that pandoc won't derive), so build it here and convert only the body.
  mkdir -p content/projects
    printf '%s\n' '---' 'title: "Projects"' '---' > content/projects/_index.md

  yaml_esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
  proj_count=0
  for f in org/projects/*.org; do
    [ -e "$f" ] || continue
    slug="$(basename "$f" .org)"
    [ "$slug" = "index" ] && continue
    mkdir -p "content/projects/$slug"

    meta() { grep -iE "^#\+$1:" "$f" | head -1 | sed -E "s/^#\+[^:]+:[[:space:]]*//I" || true; }
    title="$(meta title)"; date="$(meta date)"; summary="$(meta summary)"
    external="$(meta externalurl)"; github="$(meta github)"
    website="$(meta website)"; docs="$(meta docs)"
    raw_tags="$(meta filetags)"; [ -n "$raw_tags" ] || raw_tags="$(meta tags)"
    tags=""
    if [ -n "$raw_tags" ]; then
      csv="$(printf '%s' "$raw_tags" | tr ':' ',' | tr -s '[:space:]' ',' | sed -E 's/^,|,$//g; s/,,*/,/g')"
      tags="$(printf '%s' "$csv" | sed -E 's/[^,]+/"&"/g')"
    fi

    src="$(mktemp)"; md="$(mktemp)"
    grep -viE '^#\+(title|date|summary|filetags|tags|externalurl|github|website|docs|description):' "$f" > "$src"
    "$PANDOC" -f org -t gfm --wrap=none "$src" -o "$md"
    rm -f "$src"
    sed -i "s/\\\\'/'/g" "$md"
    sed -i 's/{\.verbatim}//g' "$md"

    out="content/projects/$slug/index.md"
    {
      echo "---"
      echo "title: \"$(yaml_esc "$title")\""
      [ -n "$date" ] && echo "date: $date"
      echo "summary: \"$(yaml_esc "$summary")\""
      [ -n "$external" ] && echo "externalUrl: \"$(yaml_esc "$external")\""
      [ -n "$github" ] && echo "github: \"$(yaml_esc "$github")\""
      [ -n "$website" ] && echo "website: \"$(yaml_esc "$website")\""
      [ -n "$docs" ] && echo "docs: \"$(yaml_esc "$docs")\""
      [ -n "$tags" ] && echo "tags: [$tags]"
      # The runbook is served only on runbook.bismigel.dev (behind Access);
      # render it but keep it out of the public list and sitemap.
      if [ "$slug" = "runbook" ]; then
        echo "build:"
        echo "  list: never"
        echo "  render: always"
      fi
      echo "---"
      echo
      cat "$md"
    } > "$out"
    rm -f "$md"
    proj_count=$((proj_count + 1))
  done

  echo ">> converted ${proj_count} org file(s) into content/projects/"

  # ---- runbook: org/runbook/*.org -> content/runbook/... ----
  # A multi-page, Access-gated section. index.org is the section landing page;
  # every other file becomes /runbook/<slug>/ with a weight from its numeric
  # prefix (01-, 02-, ...) so the sidebar and prev/next order are stable.
  if [ -d org/runbook ]; then
    mkdir -p content/runbook
    runbook_count=0
    for f in org/runbook/*.org; do
      [ -e "$f" ] || continue
      slug="$(basename "$f" .org)"
      meta() { grep -iE "^#\+$1:" "$f" | head -1 | sed -E "s/^#\+[^:]+:[[:space:]]*//I" || true; }
      rtitle="$(meta title)"; rsummary="$(meta summary)"

      src="$(mktemp)"; md="$(mktemp)"
      grep -viE '^#\+(title|summary):' "$f" > "$src"
      "$PANDOC" -s -f org -t gfm --wrap=none "$src" -o "$md"
      rm -f "$src"
      sed -i "s/\\\\'/'/g" "$md"
      sed -i 's/{\.verbatim}//g' "$md"

      if [ "$slug" = "index" ]; then
        out="content/runbook/_index.md"
        {
          echo "---"
          echo "title: \"$(yaml_esc "$rtitle")\""
          echo "summary: \"$(yaml_esc "$rsummary")\""
          echo "sitemap: {disable: true}"
          echo "---"
          echo
          cat "$md"
        } > "$out"
      else
        weight="$(printf '%s' "$slug" | sed -E 's/^([0-9]+).*/\1/')"
        case "$weight" in ''|*[!0-9]*) weight=100;; esac
        weight=$((10#$weight))   # strip leading zeros (01 -> 1)
        mkdir -p "content/runbook/$slug"
        out="content/runbook/$slug/index.md"
        {
          echo "---"
          echo "title: \"$(yaml_esc "$rtitle")\""
          echo "weight: $weight"
          [ -n "$rsummary" ] && echo "summary: \"$(yaml_esc "$rsummary")\""
          echo "sitemap: {disable: true}"
          echo "---"
          echo
          cat "$md"
        } > "$out"
      fi
      rm -f "$md"
      runbook_count=$((runbook_count + 1))
    done
    echo ">> converted ${runbook_count} runbook page(s) into content/runbook/"
  fi
