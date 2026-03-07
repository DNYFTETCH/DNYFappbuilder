#!/usr/bin/env bash
# DNYFappbuilder — Deploy to Docker Registry v2.0.0
set -Eeuo pipefail
ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"

IMAGE="${1:-}"
[[ -z "$IMAGE" ]] && {
    log_error "Usage: abp deploy docker <registry/image:tag>"
    log_info  "Example: abp deploy docker ghcr.io/dnyftech/myapp:latest"
    exit 1
}

require docker "https://docker.com"
log_info "Building and pushing: ${BOLD}$IMAGE${RESET}"

log_step "Building image..."
docker build -t "$IMAGE" .

log_step "Pushing to registry..."
docker push "$IMAGE"

log_success "Pushed: $IMAGE"
