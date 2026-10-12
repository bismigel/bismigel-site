# bismigel-site — write in Org, convert with pandoc, build with Hugo, deploy.
#
#   make            convert org -> content, hugo build, then deploy (commit + push)
#   make compile    alias for `make`
#   make convert    just run the pandoc conversion (org/ -> content/)
#   make build      convert + hugo build into public/ (no git)
#   make serve      convert + local preview at http://localhost:1313
#   make clean      remove generated public/ and content/
#
# Deploy = git add/commit/push (of the .org sources); CI converts + builds the
# image and ArgoCD rolls it out to bismigel.dev.
# Override the commit message:  make MSG="post: new entry"

PANDOC ?= pandoc
HUGO   ?= hugo
PORT   ?= 1313

.PHONY: all compile convert build deploy serve clean

all: compile
compile: deploy

convert:
	@scripts/convert.sh

build: convert
	@echo ">> hugo build"
	@$(HUGO) --minify

deploy: build
	@git add -A
	@if git diff --cached --quiet; then \
		echo ">> nothing to deploy"; \
	else \
		git commit -q -m "$${MSG:-deploy: $$(date -u +%Y-%m-%dT%H:%M:%SZ)}"; \
		git pull --rebase --autostash -q origin "$$(git rev-parse --abbrev-ref HEAD)" 2>/dev/null || true; \
		git push; \
		echo ">> pushed — CI converts + builds the image and ArgoCD deploys to bismigel.dev"; \
	fi

serve: convert
	@$(HUGO) server -D --bind 0.0.0.0 --port $(PORT)

clean:
	@rm -rf public content resources
