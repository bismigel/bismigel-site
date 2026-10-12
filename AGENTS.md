# AGENTS.md — instructions for AI/LLM agents

This repo is **miguelarbis.dev**: a static site produced by **Emacs `org-publish`**
(no Hugo). Content is Org; CI exports it and deploys via GHCR → ArgoCD.

## The pipeline

```
org/*.org ──emacs --batch -l build.el──▶ public/ ──docker──▶ GHCR ─▶ ArgoCD ─▶ miguelarbis.dev
```

## Rules

1. **Content lives in `org/*.org`.** Add posts there, not in `public/`
   (`public/` is generated and git-ignored). Keep work-in-progress in
   `org/drafts/` — it is committed but **never published** (excluded in `build.el`).
2. **One Org file = one page.** Use `#+TITLE:` and `#+DATE:`; the home page is the
   auto-generated `index` (list of posts, newest first).
3. **Header/footer live in `preamble.html` + `postamble.html`** (edited directly,
   not in elisp). `build.el` reads them via `read-partial`.
4. **Styling** is `static/style.css` (PaperMod-inspired). Keep it minimal.
5. **Don't hand-edit the image tag** in `deploy/k8s/deployment.yaml` — CI owns it.
6. Builds run with `emacs -Q --batch -l build.el` (no user init) for reproducibility.

## Verify before pushing

```bash
emacs --batch -l build.el          # must succeed
find public -type f                # index.html + posts + style.css
```

## Add a page that isn't a post

Currently unsupported: the publish project's sitemap lists every `org/*.org` file,
and Org's `:exclude` would stop it being published at all. To add a non-listed
page (e.g. About), add a second `org-publish-project-alist` entry without
`:auto-sitemap`.
