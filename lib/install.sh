#!/usr/bin/env bash
# DNYFappbuilder — App Installation Library

# Install APK to a single Android device
install_apk_to_device() {
    local apk="$1" serial="$2"
    local model
    model=$(adb_device_model "$serial" 2>/dev/null || echo "$serial")

    log_step "Installing to: ${BOLD}$model${RESET} ($serial)"
    timer_start

    local result
    if adb -s "$serial" install -r "$apk" 2>&1; then
        local elapsed; elapsed=$(timer_elapsed)
        log_success "Installed on $model in $elapsed"
        return 0
    else
        log_error "Installation failed on: $model ($serial)"
        return 1
    fi
}

# Install IPA to iOS device
install_ipa_to_device() {
    local ipa="$1" udid="${2:-}"
    if command_exists ios-deploy; then
        local flag=""
        [[ -n "$udid" ]] && flag="--id $udid"
        # shellcheck disable=SC2086
        ios-deploy --bundle "$ipa" $flag --no-wifi
    elif command_exists xcrun; then
        xcrun devicectl device install app --device "$udid" "$ipa"
    else
        log_error "iOS install requires ios-deploy: npm install -g ios-deploy"
        return 1
    fi
}

# Verify app installed on device
verify_install() {
    local serial="$1" package_id="$2"
    log_info "Verifying installation: $package_id"
    if adb -s "$serial" shell pm list packages 2>/dev/null | grep -q "$package_id"; then
        log_success "Verified: $package_id is installed"
        return 0
    else
        log_error "Verification failed: $package_id not found on $serial"
        return 1
    fi
}

# Generate QR code for wireless APK download
generate_install_qr() {
    local apk="$1"
    local host_ip port=8765

    # Get local IP
    host_ip=$(hostname -I 2>/dev/null | awk '{print $1}' || ip route get 1 | awk '{print $NF; exit}')
    local url="http://${host_ip}:${port}/$(basename "$apk")"

    log_info "Starting temporary HTTP server for wireless install..."
    log_info "APK URL: ${CYAN}$url${RESET}"

    # Show QR code if qrencode is available
    if command_exists qrencode; then
        echo ""
        qrencode -t ANSIUTF8 "$url"
        echo ""
        log_info "Scan QR code to install, or open URL on your device"
    else
        log_info "Install qrencode for QR display: apt install qrencode / pkg install qrencode"
        log_info "Share this URL with your device:"
        echo -e "  ${CYAN}$url${RESET}"
    fi

    # Serve APK via Python HTTP server
    local apk_dir; apk_dir=$(dirname "$apk")
    log_info "Serving from $apk_dir on port $port (Ctrl+C to stop)"
    cd "$apk_dir" && python3 -m http.server $port
}
