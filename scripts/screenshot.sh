#!/usr/bin/env bash
# DNYFappbuilder — Screenshot Script v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"
source "$ABP_ROOT/lib/devices.sh"

DEVICE_SERIAL=""
OUTPUT_DIR="$HOME/Pictures/abp-screenshots"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --device) DEVICE_SERIAL="$2"; shift 2 ;;
        --output) OUTPUT_DIR="$2";    shift 2 ;;
        *) shift ;;
    esac
done

require adb "pkg install android-tools (Termux) | apt install adb"
adb start-server &>/dev/null || true

# Auto-select device
if [[ -z "$DEVICE_SERIAL" ]]; then
    DEVICE_SERIAL=$(list_android_devices | head -1)
    [[ -z "$DEVICE_SERIAL" ]] && { log_error "No devices connected"; exit 1; }
fi

ensure_dir "$OUTPUT_DIR"
MODEL=$(adb_device_model "$DEVICE_SERIAL" | tr ' ' '_')
FILENAME="${MODEL}-$(date +%Y%m%d_%H%M%S).png"
DEVICE_PATH="/sdcard/abp_screenshot.png"
LOCAL_PATH="$OUTPUT_DIR/$FILENAME"

log_info "Capturing screenshot from ${BOLD}$MODEL${RESET}..."
adb -s "$DEVICE_SERIAL" shell screencap -p "$DEVICE_PATH"
adb -s "$DEVICE_SERIAL" pull "$DEVICE_PATH" "$LOCAL_PATH" &>/dev/null
adb -s "$DEVICE_SERIAL" shell rm "$DEVICE_PATH" &>/dev/null

log_success "Screenshot saved: ${BOLD}$LOCAL_PATH${RESET}"
echo "$LOCAL_PATH"
