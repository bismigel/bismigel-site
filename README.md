# bismigel.dev

Personal site. Write in **Org**, convert with **pandoc**, build with **Hugo**
(the [Omegion](https://github.com/omegion/hugo-omegion) theme), deploy with
GHCR + ArgoCD.

## Pipeline

```
org/*.org ──scripts/convert.sh (pandoc)──▶ content/posts/<slug>/index.md
                                                └─ hugo ──▶ public/ ──nginx──▶ GHCR ──▶ ArgoCD
```

## Write a post

Add `org/YYYY-MM-DD-slug.org`:

```org
#+TITLE: My post
#+DATE: 2026-10-12

Body in Org...
```

Then `make` (see below). The home page lists posts newest-first.

## Local

```bash
make build     # convert org -> content, then hugo build into public/
make serve     # convert + hugo server at http://localhost:1313
```

Requires `pandoc` and Hugo **extended**; with Nix:
`nix shell nixpkgs#pandoc nixpkgs#hugo`.

## Deploy

```bash
make           # = convert + build + commit + push (org sources)
```

Pushing to `main` triggers CI, which runs `scripts/convert.sh`, `hugo --minify`,
builds the nginx image, pushes it to GHCR, and bumps the image tag in
`deploy/k8s/deployment.yaml`. ArgoCD then rolls it out to `bismigel.dev`.

## Layout

| Path | Purpose |
| --- | --- |
| `org/*.org` | posts (source of truth) |
| `scripts/convert.sh` | pandoc: `org/` → `content/` |
| `config/_default/` | Hugo config (Omegion) |
| `themes/hugo-omegion` | theme (git submodule, pinned v1.3.0) |
| `deploy/k8s/` | Deployment/Service/Ingress (`bismigel.dev`) |
| `.github/workflows/release.yml` | convert → hugo → image → GHCR → tag bump |
