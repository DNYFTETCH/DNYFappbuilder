#!/usr/bin/env bash
# DNYFappbuilder — Device Discovery Script v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"
source "$ABP_ROOT/lib/devices.sh"

WIRELESS=false
ENABLE_WIRELESS=false
IP_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --wireless)        WIRELESS=true; shift ;;
        --enable-wireless) ENABLE_WIRELESS=true; shift ;;
        --connect)         IP_ARG="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# ── Connect wireless ──────────────────────────────────────
if [[ -n "$IP_ARG" ]]; then
    connect_wireless "$IP_ARG"
    exit $?
fi

if $ENABLE_WIRELESS; then
    enable_wireless_adb
    exit $?
fi

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║         DNYFappbuilder — Devices         ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""

# ── Android Devices ───────────────────────────────────────
echo -e "${CYAN}${BOLD}Android Devices (ADB)${RESET}"
echo -e "${DIM}──────────────────────────────────────────${RESET}"

ANDROID_COUNT=0

if ! command_exists adb; then
    echo -e "  ${YELLOW}ADB not installed${RESET}"
    echo -e "  Install: ${CYAN}pkg install android-tools${RESET} (Termux) | ${CYAN}apt install adb${RESET} (Linux)"
else
    # Start ADB server silently
    adb start-server &>/dev/null || true

    while IFS= read -r serial; do
        [[ -z "$serial" ]] && continue
        local_type="physical"
        is_emulator "$serial" && local_type="emulator"

        local model android_ver battery
        model=$(adb_device_model "$serial")
        android_ver=$(adb_device_android "$serial")
        battery=$(adb -s "$serial" shell dumpsys battery 2>/dev/null | grep "level:" | awk '{print $2}' | tr -d '\r' || echo "?")

        echo -e "  ${GREEN}●${RESET} ${BOLD}$model${RESET}"
        echo -e "    Serial   : ${CYAN}$serial${RESET}"
        echo -e "    Android  : $android_ver"
        echo -e "    Battery  : ${battery}%"
        echo -e "    Type     : $local_type"
        echo ""
        ((ANDROID_COUNT++))
    done < <(list_android_devices)

    if [[ $ANDROID_COUNT -eq 0 ]]; then
        echo -e "  ${DIM}No Android devices connected${RESET}"
        echo -e "  ${DIM}• Connect a device with USB debugging enabled${RESET}"
        echo -e "  ${DIM}• Or run: abp devices --connect <ip>${RESET}"
        echo ""
    fi
fi

# ── iOS Devices ───────────────────────────────────────────
echo -e "${CYAN}${BOLD}iOS Devices${RESET}"
echo -e "${DIM}──────────────────────────────────────────${RESET}"

if is_macos; then
    IOS_LIST=$(list_ios_devices)
    if [[ -n "$IOS_LIST" ]]; then
        while IFS= read -r udid; do
            [[ -z "$udid" ]] && continue
            local name
            name=$(idevicename -u "$udid" 2>/dev/null || echo "iOS Device")
            echo -e "  ${GREEN}●${RESET} ${BOLD}$name${RESET}"
            echo -e "    UDID : ${CYAN}$udid${RESET}"
            echo ""
        done <<< "$IOS_LIST"
    else
        echo -e "  ${DIM}No iOS devices connected${RESET}"
        echo ""
    fi
else
    echo -e "  ${DIM}iOS device management requires macOS${RESET}"
    echo ""
fi

# ── Wireless Mode ─────────────────────────────────────────
if $WIRELESS; then
    echo -e "${CYAN}${BOLD}Wireless ADB Setup${RESET}"
    echo -e "${DIM}──────────────────────────────────────────${RESET}"
    enable_wireless_adb
    echo ""
fi

# ── Summary ───────────────────────────────────────────────
echo -e "${DIM}Total Android: $ANDROID_COUNT${RESET}"
echo -e "${DIM}Run 'abp install <app.apk> --all' to install on all devices${RESET}"
echo ""
