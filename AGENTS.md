# AGENTS.md — instructions for AI/LLM agents

`bismigel.dev`: write in **Org**, convert with **pandoc**, build with **Hugo**
(Omegion theme), deploy via GHCR → ArgoCD.

## Pipeline

```
org/*.org ──scripts/convert.sh (pandoc -s -f org -t markdown)──▶ content/posts/<slug>/index.md
                                                                    └─ hugo --minify ──▶ public/ ──▶ nginx image ──▶ GHCR ──▶ ArgoCD
```

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
- `#+DESCRIPTION` → `description`; add `tags` via a `#+FILETAGS:` or by editing the
  generated front matter step in `scripts/convert.sh` if needed.
- `enableGitInfo: true` means CI checks out with `fetch-depth: 0`.
