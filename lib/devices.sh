#!/usr/bin/env bash
# DNYFappbuilder — Device Management Library

# List all Android devices via ADB
list_android_devices() {
    if ! command_exists adb; then
        log_warn "ADB not found — Android devices unavailable"
        return 0
    fi

    local devices
    devices=$(adb devices 2>/dev/null | grep -v "^List" | grep -v "^$" | grep -v "offline" | awk '{print $1}')

    if [[ -z "$devices" ]]; then
        return 0
    fi

    echo "$devices"
}

# List all iOS devices via idevice_id or xcrun
list_ios_devices() {
    if command_exists idevice_id; then
        idevice_id -l 2>/dev/null || true
    elif command_exists xcrun; then
        xcrun xctrace list devices 2>/dev/null | grep -v "Simulator" | grep -v "^$" || true
    fi
}

# Get device info
get_device_info() {
    local serial="$1"
    local model android_ver battery
    model=$(adb -s "$serial" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
    android_ver=$(adb -s "$serial" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
    battery=$(adb -s "$serial" shell dumpsys battery 2>/dev/null | grep "level:" | awk '{print $2}' | tr -d '\r')
    echo "${model:-Unknown} | Android ${android_ver:-?} | Battery ${battery:-?}%"
}

# Check if device is an emulator
is_emulator() {
    local serial="$1"
    [[ "$serial" == *"emulator"* ]] || \
    adb -s "$serial" shell getprop ro.kernel.qemu 2>/dev/null | grep -q "1"
}

# Connect wireless ADB device
connect_wireless() {
    local ip="$1" port="${2:-5555}"
    require adb "pkg install android-tools (Termux) | apt install adb (Linux)"
    log_info "Connecting to $ip:$port..."
    adb connect "$ip:$port"
    sleep 1
    if adb devices | grep -q "$ip:$port"; then
        log_success "Connected: $ip:$port"
        echo "$ip:$port"
    else
        log_error "Connection failed: $ip:$port"
        return 1
    fi
}

# Enable ADB over WiFi on a connected device
enable_wireless_adb() {
    local serial="${1:-}"
    local flag="-s $serial"
    [[ -z "$serial" ]] && flag=""

    require adb
    log_info "Enabling ADB over TCP..."
    # shellcheck disable=SC2086
    adb $flag tcpip 5555
    sleep 2

    # Get device IP
    local ip
    # shellcheck disable=SC2086
    ip=$(adb $flag shell ip route 2>/dev/null | awk '{print $NF}' | tail -1 | tr -d '\r')
    if [[ -n "$ip" ]]; then
        log_success "Wireless ADB ready!"
        log_info "Connect with: abp install <app.apk> --wireless $ip"
        echo "$ip"
    else
        log_warn "Could not determine device IP. Check device WiFi settings."
    fi
}
