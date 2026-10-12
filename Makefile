# bismigel-site — Org -> HTML (org-publish), then deploy.
#
#   make            export the site AND deploy (commit + push to main)
#   make compile    alias for `make`
#   make build      export only (no git)
#   make serve      export, then preview at http://localhost:8000
#   make clean      remove generated public/
#
# Deploy = git add/commit/push; CI builds the image and ArgoCD rolls it out to bismigel.dev.
# Override the commit message:  make MSG="post: new entry"

EMACS      ?= emacs
SERVE_PORT ?= 8000

.PHONY: all compile build deploy serve clean

all: compile
compile: deploy

build:
	@echo ">> exporting org/ -> public/"
	@$(EMACS) --batch -l build.el

deploy: build
	@git add -A
	@if git diff --cached --quiet; then \
		echo ">> nothing to deploy"; \
	else \
		git commit -q -m "$${MSG:-deploy: $$(date -u +%Y-%m-%dT%H:%M:%SZ)}"; \
		git pull --rebase --autostash -q origin "$$(git rev-parse --abbrev-ref HEAD)" 2>/dev/null || true; \
		git push; \
		echo ">> pushed — CI builds the image and ArgoCD deploys to bismigel.dev"; \
	fi

serve: build
	@echo ">> serving public/ at http://localhost:$(SERVE_PORT)"
	@python3 -m http.server -d public $(SERVE_PORT)

clean:
	@rm -rf public
