# AGENTS.md — instructions for AI/LLM agents

`bismigel.dev`: write in **Org**, convert with **pandoc**, build with **Hugo**
(Omegion theme), deploy via GHCR → ArgoCD.

## Pipeline

```
org/*.org ──scripts/convert.sh (pandoc -s -f org -t markdown)──▶ content/posts/<slug>/index.md
                                                                    └─ hugo --minify ──▶ public/ ──▶ nginx image ──▶ GHCR ──▶ ArgoCD
```

## Writing a post

1. **Create `org/<date>-<slug>.org`** — the filename is the URL slug
   (`/posts/<date>-<slug>/`).
2. **Front matter** at the top:
   ```org
   #+TITLE: My post title
   #+DATE: 2026-11-01
   #+FILETAGS: homelab:nginx
   ```
3. **Sections use real Org headings — they drive the on-page table of contents:**
   - `* Section` → a top-level entry in the TOC.
   - `** Sub-point` → an indented entry under it.

   The TOC is automatic (theme via `layouts/partials/toc.html`); never add one by
   hand. Headings must be real (`* ` at line start), not inline bold (`*bold*`).
4. **Series / prev-next nav** goes in a `#+begin_quote` block at the **top and
   bottom** of the file, e.g.
   `*Building the lab* — Part 9 of 8. ← [[file:<prev>.org][previous]] · [[file:<next>.org][next]]`.
5. **Cross-links between posts**: `[[file:<slug>.org][label]]` — `scripts/convert.sh`
   rewrites these to `/posts/<slug>/`.
6. **Deploy**: commit the `.org` file and push (a branch + PR, or `main`). CI
   converts, builds the image, and ArgoCD deploys. Never edit `content/` or
   `public/` — they're generated.

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
