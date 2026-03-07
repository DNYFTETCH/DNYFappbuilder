#!/usr/bin/env bash
# DNYFappbuilder Plugin — QR Installer
# Enables QR-code based wireless APK installation
# Usage: Called automatically by abp install --qr

PLUGIN_NAME="qr-installer"
PLUGIN_VERSION="1.0.0"

plugin_info() {
    echo "QR Installer Plugin v$PLUGIN_VERSION"
    echo "Enables wireless APK distribution via QR code"
}

plugin_check_deps() {
    local ok=true
    command -v python3 &>/dev/null || { echo "Missing: python3"; ok=false; }
    $ok
}

plugin_run() {
    local apk="$1"
    [[ -z "$apk" ]] && { echo "Usage: abp install <app.apk> --qr"; exit 1; }
    [[ ! -f "$apk" ]] && { echo "File not found: $apk"; exit 1; }

    # Use qrencode if available, else fallback
    local host_ip port=8765
    host_ip=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "localhost")
    local url="http://${host_ip}:${port}/$(basename "$apk")"

    echo ""
    echo "═══════════════════════════════════════"
    echo "  DNYFappbuilder — QR Installer"
    echo "  App : $(basename "$apk")"
    echo "  URL : $url"
    echo "═══════════════════════════════════════"
    echo ""

    if command -v qrencode &>/dev/null; then
        qrencode -t ANSIUTF8 "$url"
    else
        echo "  Install qrencode for QR display:"
        echo "  pkg install qrencode  (Termux)"
        echo "  apt install qrencode  (Linux)"
        echo ""
        echo "  Share this URL on your device:"
        echo "  $url"
    fi

    echo ""
    echo "Serving on port $port — open URL on device to install"
    echo "(Ctrl+C to stop)"
    echo ""

    cd "$(dirname "$apk")"
    python3 -m http.server $port
}

# Entry point
case "${1:-info}" in
    info)   plugin_info ;;
    check)  plugin_check_deps ;;
    run)    shift; plugin_run "$@" ;;
    *)      plugin_info ;;
esac
