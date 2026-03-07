#!/usr/bin/env bash
# DNYFappbuilder — Deploy to Railway v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"

log_info "Deploying to ${BOLD}Railway.app${RESET}"

if ! command_exists railway; then
    log_warn "Railway CLI not found"
    log_info "Install: npm install -g @railway/cli"
    log_info "Then login: railway login"
    exit 1
fi

if ! railway whoami &>/dev/null; then
    log_step "Logging in to Railway..."
    railway login
fi

# Link project if not linked
if [[ ! -f ".railway/config.json" ]]; then
    log_step "Linking Railway project..."
    railway link
fi

log_step "Deploying..."
railway up --detach
log_success "Deployed to Railway!"
railway open 2>/dev/null || log_info "Check your Railway dashboard"
