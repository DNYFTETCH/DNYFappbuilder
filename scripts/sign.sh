#!/usr/bin/env bash
# DNYFappbuilder — Sign Script v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"
source "$ABP_ROOT/lib/signing.sh"

APK="${1:-}"
KEYSTORE=""
ALIAS=""
STOREPASS=""
AUTO_GEN=false

shift || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --keystore) KEYSTORE="$2"; shift 2 ;;
        --alias)    ALIAS="$2";    shift 2 ;;
        --password) STOREPASS="$2"; shift 2 ;;
        --auto)     AUTO_GEN=true; shift ;;
        *) shift ;;
    esac
done

[[ -z "$APK" ]] && {
    log_error "Usage: abp sign <app.apk> [--keystore <path>] [--alias <alias>] [--auto]"
    exit 1
}
[[ ! -f "$APK" ]] && { log_error "APK not found: $APK"; exit 1; }

# Use defaults or config
KEYSTORE="${KEYSTORE:-$(config_get '.signing.keystore' "$DEFAULT_KEYSTORE")}"
ALIAS="${ALIAS:-$(config_get     '.signing.alias'    "$DEFAULT_ALIAS")}"
STOREPASS="${STOREPASS:-$(config_get '.signing.password' "$DEFAULT_STOREPASS")}"

# Auto-generate keystore if needed
if $AUTO_GEN || [[ ! -f "$KEYSTORE" ]]; then
    log_info "Generating new keystore..."
    generate_keystore "$KEYSTORE" "$ALIAS" "$STOREPASS"
fi

sign_apk "$APK" "$KEYSTORE" "$ALIAS" "$STOREPASS"
