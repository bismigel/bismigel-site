# AGENTS.md; instructions for AI/LLM agents

`bismigel.dev`: write in **Org**, convert with **pandoc**, build with **Hugo**
(Omegion theme), deploy via GHCR → ArgoCD.

## Pipeline

```
org/*.org ──scripts/convert.sh (pandoc -s -f org -t markdown)──▶ content/posts/<slug>/index.md
                                                                    └─ hugo --minify ──▶ public/ ──▶ nginx image ──▶ GHCR ──▶ ArgoCD
```

## Writing style (important)

I am not a native English speaker. Write as an experienced traditional sysadmin
and observability engineer who is learning DevOps, Kubernetes and modern SRE.

- **Simple English.** Short sentences, common words, one idea per sentence. If a
  simpler word exists, use it. Avoid idioms, slang and clever wordplay.
- **Assume the fundamentals.** The reader knows Linux, networking, CI/CD and
  observability. Do not explain GitHub Actions, containers or Prometheus basics.
  Lead with the decision, the constraint and the failure mode.
- **Learner on the cloud-native side.** Be explicit about what was new in
  Kubernetes, GitOps and SRE, what you tried, and what broke. Keep the
  first-person learning voice, but do not pretend to be a beginner in ops.
- **Confident about decisions, honest about gaps.** Say what you built and why.
  Keep the mistakes and trade-offs; own them as engineering decisions, not
  ignorance.
- **Cohesion.** Each paragraph should connect to the one before it. Open with why
  the topic matters, move in a clear order, and close by pointing to the next
  idea. Keep the series quote blocks consistent.
- **Lean, not clipped.** Cut filler, repetition and throat-clearing, but keep
  sentences whole and readable. Never trade clarity for brevity.
- **Keep the facts.** While editing, do not change numbers, commands, versions,
  links, code, or technical claims. Caveats and mistakes stay in; they are the
  value of the post.
- **Titles are specific and searchable (SEO).** Name the technology and the
  subject, e.g. "Cloudflare Tunnel HA: two connectors for a safer homelab edge".
  No clickbait, no keyword stuffing, no questions.
- **Structure.** Real Org headings drive the TOC. Use code blocks for commands
  and tables for comparisons. End with what it bought or what you would change.

## Rules

1. **Content lives in `org/*.org`.** This is the source of truth. `content/` and
   `public/` are **generated** (git-ignored); never edit them.
2. **One Org file = one page**, named `org/<slug>.org`; use `#+TITLE:` and
   `#+DATE:`. The URL becomes `/posts/<slug>/`.
3. **Convert + build + deploy with `make`** (default target does all three). The
   Makefile uses `scripts/convert.sh` (pandoc) then `hugo`.
4. **Theme:** `themes/hugo-omegion` (submodule, pinned). Config in
   `config/_default/` (Omegion requires `enableGitInfo`, `searchindex` output,
   `markup.toml`, `taxonomies.toml`; see the theme's exampleSite).
5. **Never hand-edit the image tag** in `deploy/k8s/deployment.yaml`; CI owns it.
6. **Use Org inline code in posts.** Write `=code=` or `~code~`, not Markdown
   backticks. Pandoc treats backticks as literal text and can turn `--` into an
   en dash.
7. Builds need Hugo **extended** and **pandoc** (CI installs both).

## Validate before pushing

```bash
make build            # convert + hugo build must succeed
```

## Notes

- Pandoc maps `#+TITLE`/`#+DATE` to Hugo YAML front matter automatically.
- `#+DESCRIPTION` → `description`; add `tags` via a `#+FILETAGS:`. `#+ALIASES:`
  becomes Hugo `aliases`, so renamed posts keep redirects from their old URLs.
- `enableGitInfo: true` means CI checks out with `fetch-depth: 0`.
