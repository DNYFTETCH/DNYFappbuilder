#!/usr/bin/env bash
# DNYFappbuilder — Deploy to Vercel v2.0.0
set -Eeuo pipefail
ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"

log_info "Deploying to ${BOLD}Vercel${RESET}"
if ! command_exists vercel; then
    log_warn "Vercel CLI not found. Install: npm install -g vercel"
    exit 1
fi
vercel --prod
