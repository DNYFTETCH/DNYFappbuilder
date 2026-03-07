#!/usr/bin/env bash
# DNYFappbuilder — Deploy to GitHub Pages v2.0.0
set -Eeuo pipefail
ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"

DIST_DIR="${1:-dist}"
[[ ! -d "$DIST_DIR" ]] && DIST_DIR="build/web"
[[ ! -d "$DIST_DIR" ]] && { log_error "Build directory not found: $DIST_DIR. Run abp build first."; exit 1; }

require git "pkg install git"
log_info "Deploying ${BOLD}$DIST_DIR${RESET} to GitHub Pages"

# Use gh-pages approach via git subtree
if git remote get-url origin &>/dev/null; then
    git add -f "$DIST_DIR"
    git commit -m "chore: deploy to gh-pages [skip ci]" --allow-empty
    git subtree push --prefix "$DIST_DIR" origin gh-pages
    log_success "Deployed to GitHub Pages!"
    REPO_URL=$(git remote get-url origin | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
    log_info "URL: $(echo "$REPO_URL" | sed 's/github.com\///' | awk -F'/' '{print "https://" $1 ".github.io/" $2}')"
else
    log_error "No git remote 'origin' found"
    exit 1
fi
