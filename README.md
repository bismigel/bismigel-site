# miguelarbis.dev

Personal site published **straight from Org-mode** with Emacs' built-in
`org-publish`. No Hugo, no Node/Go toolchain — just Emacs and a small nginx image.

## How it works

```
build.el + org/*.org ──(emacs --batch)──▶ public/*.html
        └─ .github/workflows/release.yml: export ─▶ docker build ─▶ GHCR
                                                     └─ ArgoCD ─▶ k8s ─▶ miguelarbis.dev
```

## Write a post

Add an Org file in `org/`, e.g. `org/2026-10-11-my-homelab.org`:

```org
#+TITLE: My homelab
#+DATE: 2026-10-11

Body text...
```

Push to `main`. CI exports the Org files and deploys. The home page is the
auto-generated list of posts (newest first).

## Preview locally

```bash
emacs --batch -l build.el          # -> public/
python3 -m http.server -d public 8000   # then open http://localhost:8000
```

## Layout

| Path | Purpose |
| --- | --- |
| `org/*.org` | posts (each = one page); `index` is generated from these |
| `static/style.css` | stylesheet (PaperMod-ish) |
| `build.el` | org-publish config + export entrypoint |
| `deploy/k8s/` | Deployment/Service/Ingress (host `miguelarbis.dev`) |
| `.github/workflows/release.yml` | export → image → GHCR → tag bump |

## Deploy

ArgoCD (`bakuran-gitops/applications/miguelarbis-site.yaml`) points at this repo's
`deploy/k8s`. Merging to `main` builds a new image; ArgoCD rolls it out.
