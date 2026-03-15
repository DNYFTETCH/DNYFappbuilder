#!/usr/bin/env bash
# DNYFappbuilder — Deploy to Render v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"

ENV="production"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --env) ENV="$2"; shift 2 ;;
        *) shift ;;
    esac
done

log_info "Deploying to ${BOLD}Render.com${RESET} ($ENV)"

# Check for render.yaml
if [[ ! -f "render.yaml" ]]; then
    log_warn "render.yaml not found — generating default..."
    cat > render.yaml <<YAML
services:
  - type: web
    name: $(basename "$PWD")
    env: node
    buildCommand: npm install && npm run build
    startCommand: npm start
    envVars:
      - key: NODE_ENV
        value: production
      - key: PORT
        value: 3000
YAML
    log_success "Created render.yaml — customize as needed"
fi

if command_exists render; then
    render deploy --confirm
else
    log_warn "Render CLI not found"
    log_info "Install: npm install -g @render-oss/cli"
    log_info "Or deploy via GitHub — push to your connected branch"
    log_info "Dashboard: https://dashboard.render.com"
fi
