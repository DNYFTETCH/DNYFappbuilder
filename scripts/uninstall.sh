#!/usr/bin/env bash
# DNYFappbuilder — Uninstall Script v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"
source "$ABP_ROOT/lib/devices.sh"

PACKAGE="${1:-}"
DEVICE_SERIAL=""
UNINSTALL_ALL=false

shift || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --device) DEVICE_SERIAL="$2"; shift 2 ;;
        --all)    UNINSTALL_ALL=true; shift ;;
        *) shift ;;
    esac
done

[[ -z "$PACKAGE" ]] && {
    log_error "Usage: abp uninstall <package.id> [--device <serial>|--all]"
    log_info  "Example: abp uninstall com.mycompany.myapp"
    exit 1
}

require adb "pkg install android-tools (Termux) | apt install adb"
adb start-server &>/dev/null || true

uninstall_from() {
    local serial="$1"
    local model; model=$(adb_device_model "$serial")
    log_step "Uninstalling $PACKAGE from ${BOLD}$model${RESET} ($serial)"
    if adb -s "$serial" uninstall "$PACKAGE"; then
        log_success "Uninstalled from $model"
    else
        log_error "Failed to uninstall from $model — is the package installed?"
    fi
}

if [[ -n "$DEVICE_SERIAL" ]]; then
    uninstall_from "$DEVICE_SERIAL"
elif $UNINSTALL_ALL; then
    while IFS= read -r serial; do
        [[ -z "$serial" ]] && continue
        uninstall_from "$serial"
    done < <(list_android_devices)
else
    SERIAL=$(list_android_devices | head -1)
    [[ -z "$SERIAL" ]] && { log_error "No devices connected"; exit 1; }
    uninstall_from "$SERIAL"
fi
