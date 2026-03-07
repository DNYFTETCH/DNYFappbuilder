#!/usr/bin/env bash
# DNYFappbuilder — App Installation Script v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"
source "$ABP_ROOT/lib/devices.sh"
source "$ABP_ROOT/lib/install.sh"

# ── Parse args ────────────────────────────────────────────
APP_FILE="${1:-}"
DEVICE_SERIAL=""
INSTALL_ALL=false
WIRELESS_IP=""
SHOW_QR=false
VERIFY=false
PACKAGE_ID=""

shift || true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --device)    DEVICE_SERIAL="$2"; shift 2 ;;
        --all)       INSTALL_ALL=true;   shift ;;
        --wireless)  WIRELESS_IP="$2";   shift 2 ;;
        --qr)        SHOW_QR=true;       shift ;;
        --verify)    VERIFY=true;        shift ;;
        --package)   PACKAGE_ID="$2";   shift 2 ;;
        *) log_warn "Unknown flag: $1"; shift ;;
    esac
done

# ── Validate ──────────────────────────────────────────────
[[ -z "$APP_FILE" ]] && {
    log_error "Usage: abp install <app.apk|app.ipa> [options]"
    echo ""
    echo "Options:"
    echo "  --device <serial>   Install to specific device"
    echo "  --all               Install to all connected devices"
    echo "  --wireless <ip>     Connect via WiFi ADB first"
    echo "  --qr                Serve APK as QR code for wireless install"
    echo "  --verify            Verify installation after install"
    echo "  --package <id>      Package ID for verification (e.g. com.myapp)"
    exit 1
}

[[ ! -f "$APP_FILE" ]] && {
    log_error "App file not found: $APP_FILE"
    exit 1
}

APP_FILE=$(realpath "$APP_FILE")
EXT="${APP_FILE##*.}"
APP_SIZE=$(file_size "$APP_FILE")

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║        DNYFappbuilder — Installer        ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""
log_info "App  : ${BOLD}$(basename "$APP_FILE")${RESET} ($APP_SIZE)"
log_info "Type : ${BOLD}${EXT^^}${RESET}"
echo ""

# ── QR code install ───────────────────────────────────────
if $SHOW_QR; then
    [[ "$EXT" != "apk" ]] && { log_error "QR install only supported for APKs"; exit 1; }
    generate_install_qr "$APP_FILE"
    exit 0
fi

# ── Wireless: connect first ───────────────────────────────
if [[ -n "$WIRELESS_IP" ]]; then
    log_step "Connecting to wireless device: $WIRELESS_IP"
    WIRELESS_SERIAL=$(connect_wireless "$WIRELESS_IP")
    [[ -z "$DEVICE_SERIAL" ]] && DEVICE_SERIAL="$WIRELESS_SERIAL"
fi

# ── Android APK install ───────────────────────────────────
install_android() {
    local serial="$1"
    install_apk_to_device "$APP_FILE" "$serial"

    if $VERIFY && [[ -n "$PACKAGE_ID" ]]; then
        verify_install "$serial" "$PACKAGE_ID"
    fi
}

# ── iOS IPA install ───────────────────────────────────────
install_ios() {
    local udid="${1:-}"
    log_step "Installing IPA to iOS device: ${udid:-default}"
    install_ipa_to_device "$APP_FILE" "$udid"
}

# ── Dispatch ──────────────────────────────────────────────
PASS=0
FAIL=0
timer_start

if [[ "$EXT" == "apk" ]]; then
    require adb "pkg install android-tools (Termux) | apt install adb (Linux)"

    adb start-server &>/dev/null || true

    if [[ -n "$DEVICE_SERIAL" ]]; then
        # Single device
        if install_android "$DEVICE_SERIAL"; then
            ((PASS++))
        else
            ((FAIL++))
        fi

    elif $INSTALL_ALL; then
        # All connected devices
        DEVICES=$(list_android_devices)
        if [[ -z "$DEVICES" ]]; then
            log_error "No Android devices connected"
            log_info  "Connect a device or use --wireless <ip>"
            exit 1
        fi

        DEVICE_COUNT=$(echo "$DEVICES" | wc -l)
        log_info "Installing to ${BOLD}$DEVICE_COUNT${RESET} device(s)..."
        echo ""

        while IFS= read -r serial; do
            [[ -z "$serial" ]] && continue
            if install_android "$serial"; then
                ((PASS++))
            else
                ((FAIL++))
            fi
        done <<< "$DEVICES"

    else
        # Auto-select: use only device, or prompt
        DEVICES=$(list_android_devices)
        DEVICE_COUNT=$(echo "$DEVICES" | grep -c . || true)

        if [[ "$DEVICE_COUNT" -eq 0 ]]; then
            log_error "No Android devices connected"
            log_info  "Options:"
            echo "  abp devices                     — see connected devices"
            echo "  abp install $APP_FILE --wireless <ip>"
            echo "  abp install $APP_FILE --qr"
            exit 1
        elif [[ "$DEVICE_COUNT" -eq 1 ]]; then
            SERIAL=$(echo "$DEVICES" | head -1)
            if install_android "$SERIAL"; then
                ((PASS++))
            else
                ((FAIL++))
            fi
        else
            log_info "Multiple devices connected. Choose one:"
            echo ""
            i=1
            declare -a SERIALS
            while IFS= read -r serial; do
                [[ -z "$serial" ]] && continue
                MODEL=$(adb_device_model "$serial")
                echo "  [$i] $MODEL ($serial)"
                SERIALS[$i]="$serial"
                ((i++))
            done <<< "$DEVICES"

            echo "  [a] All devices"
            echo ""
            echo -n "Selection: "
            read -r choice

            if [[ "$choice" == "a" ]]; then
                while IFS= read -r serial; do
                    [[ -z "$serial" ]] && continue
                    if install_android "$serial"; then
                        ((PASS++))
                    else
                        ((FAIL++))
                    fi
                done <<< "$DEVICES"
            elif [[ -n "${SERIALS[$choice]:-}" ]]; then
                if install_android "${SERIALS[$choice]}"; then
                    ((PASS++))
                else
                    ((FAIL++))
                fi
            else
                log_error "Invalid selection"
                exit 1
            fi
        fi
    fi

elif [[ "$EXT" == "ipa" ]]; then
    if [[ -n "$DEVICE_SERIAL" ]]; then
        install_ios "$DEVICE_SERIAL"
    else
        install_ios ""
    fi
    ((PASS++))

elif [[ "$EXT" == "aab" ]]; then
    log_error "AAB (App Bundle) cannot be installed directly on devices."
    log_info  "Upload it to the Play Store, or use bundletool to extract APKs:"
    echo "  java -jar bundletool.jar build-apks --bundle=$APP_FILE --output=app.apks"
    echo "  java -jar bundletool.jar install-apks --apks=app.apks"
    exit 1

else
    log_error "Unsupported file type: .$EXT"
    log_info  "Supported: .apk (Android), .ipa (iOS)"
    exit 1
fi

# ── Summary ───────────────────────────────────────────────
ELAPSED=$(timer_elapsed)
echo ""
echo -e "${BOLD}Installation Summary${RESET}"
echo -e "${DIM}────────────────────${RESET}"
echo -e "  ${GREEN}Passed : $PASS${RESET}"
[[ $FAIL -gt 0 ]] && echo -e "  ${RED}Failed : $FAIL${RESET}"
echo -e "  Time   : $ELAPSED"
echo ""

[[ $FAIL -gt 0 ]] && exit 1 || exit 0
