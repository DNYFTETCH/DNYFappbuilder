#!/usr/bin/env bash
# DNYFappbuilder — Deploy to Heroku v2.0.0
set -Eeuo pipefail
ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"

APP_NAME="${1:-}"
log_info "Deploying to ${BOLD}Heroku${RESET}"

if ! command_exists heroku; then
    log_warn "Heroku CLI not found. Install from https://devcenter.heroku.com/articles/heroku-cli"
    exit 1
fi

if ! heroku auth:whoami &>/dev/null; then
    heroku login -i
fi

if [[ -n "$APP_NAME" ]]; then
    heroku git:remote -a "$APP_NAME"
fi

git push heroku main
log_success "Deployed to Heroku!"
heroku open 2>/dev/null || true
