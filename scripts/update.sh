#!/usr/bin/env bash
# DNYFappbuilder — Self-Update Script v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"

REPO="https://github.com/DNYFTECH/dnyf-appbuilder"
BRANCH="main"
TMP_DIR="/tmp/abp-update-$$"

log_info "Checking for updates..."

if ! check_internet; then
    log_error "No internet connection"
    exit 1
fi

if ! command_exists git; then
    log_error "git is required for updates: pkg install git / apt install git"
    exit 1
fi

mkdir -p "$TMP_DIR"
trap 'rm -rf "$TMP_DIR"' EXIT

log_step "Pulling latest from $REPO..."
git clone --depth 1 --branch "$BRANCH" "$REPO" "$TMP_DIR/abp" 2>&1 | tail -1

# Get new version
NEW_VERSION=$(grep 'VERSION=' "$TMP_DIR/abp/bin/abp" | head -1 | cut -d'"' -f2)
CUR_VERSION=$(grep 'VERSION=' "$ABP_ROOT/bin/abp" | head -1 | cut -d'"' -f2)

if [[ "$NEW_VERSION" == "$CUR_VERSION" ]]; then
    log_success "Already up to date (v$CUR_VERSION)"
    exit 0
fi

log_info "Update available: v$CUR_VERSION → v$NEW_VERSION"

if ! confirm "Install update?"; then
    log_info "Update cancelled"
    exit 0
fi

# Backup current installation
BACKUP="$HOME/.abp-backup-$CUR_VERSION"
cp -r "$ABP_ROOT" "$BACKUP"
log_info "Backup saved: $BACKUP"

# Apply update
rsync -a --exclude '.git' --exclude 'logs' --exclude 'builds' --exclude 'config' \
    "$TMP_DIR/abp/" "$ABP_ROOT/"

chmod +x "$ABP_ROOT"/bin/*
chmod +x "$ABP_ROOT"/scripts/*.sh
chmod +x "$ABP_ROOT"/scripts/deploy/*.sh 2>/dev/null || true

log_success "Updated to v$NEW_VERSION"
log_info    "Backup at: $BACKUP (remove when satisfied)"
