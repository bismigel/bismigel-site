# AGENTS.md — instructions for AI/LLM agents

`bismigel.dev`: write in **Org**, convert with **pandoc**, build with **Hugo**
(Omegion theme), deploy via GHCR → ArgoCD.

## Pipeline

```
org/*.org ──scripts/convert.sh (pandoc -s -f org -t markdown)──▶ content/posts/<slug>/index.md
                                                                    └─ hugo --minify ──▶ public/ ──▶ nginx image ──▶ GHCR ──▶ ArgoCD
```

## Writing style (important)

I am not a native English speaker. Write for a learner, not for an expert.

- **Simple English.** Short sentences, common words, one idea per sentence. If a
  simpler word exists, use it. Avoid idioms, slang and clever wordplay.
- **Learner's perspective.** Write as someone figuring it out, not as an
  authority. Say what I tried, what I got wrong, and what I learned. Keep the
  humble first-person voice ("I thought…", "it turned out…"). Never write as if
  the author already knew the answer.
- **Cohesion.** Each paragraph should connect to the one before it. Open with why
  the topic matters, move in a clear order, and close by pointing to the next
  idea. Keep the series quote blocks consistent.
- **Lean, not clipped.** Cut filler, repetition and throat-clearing, but keep
  sentences whole and readable. Never trade clarity for brevity.
- **Keep the facts.** While editing, do not change numbers, commands, versions,
  links, code, or technical claims. Caveats and mistakes stay in — they are the
  value of the post.
- **Titles are specific and searchable (SEO).** Name the technology and the
  subject, e.g. "Cloudflare Tunnel HA: two connectors for a safer homelab edge".
  No clickbait, no keyword stuffing, no questions.
- **Structure.** Real Org headings drive the TOC. Use code blocks for commands
  and tables for comparisons. End with what it bought or what you would change.

## Rules

1. **Content lives in `org/*.org`.** This is the source of truth. `content/` and
   `public/` are **generated** (git-ignored) — never edit them.
2. **One Org file = one page**, named `org/<slug>.org`; use `#+TITLE:` and
   `#+DATE:`. The URL becomes `/posts/<slug>/`.
3. **Convert + build + deploy with `make`** (default target does all three). The
   Makefile uses `scripts/convert.sh` (pandoc) then `hugo`.
4. **Theme:** `themes/hugo-omegion` (submodule, pinned). Config in
   `config/_default/` (Omegion requires `enableGitInfo`, `searchindex` output,
   `markup.toml`, `taxonomies.toml` — see the theme's exampleSite).
5. **Never hand-edit the image tag** in `deploy/k8s/deployment.yaml` — CI owns it.
6. Builds need Hugo **extended** and **pandoc** (CI installs both).

## Validate before pushing

```bash
make build            # convert + hugo build must succeed
```

## Notes

- Pandoc maps `#+TITLE`/`#+DATE` to Hugo YAML front matter automatically.
- `#+DESCRIPTION` → `description`; add `tags` via a `#+FILETAGS:`. `#+ALIASES:`
  becomes Hugo `aliases`, so renamed posts keep redirects from their old URLs.
- `enableGitInfo: true` means CI checks out with `fetch-depth: 0`.
