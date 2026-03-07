#!/usr/bin/env bash
# DNYFappbuilder — APK Signing Library

DEFAULT_KEYSTORE="$HOME/dnyf-appbuilder/config/dnyf-release.keystore"
DEFAULT_ALIAS="abp-key"
DEFAULT_STOREPASS="dnyf-release-2024"

# Sign an APK with apksigner or jarsigner
sign_apk() {
    local apk="$1" keystore="$2" alias="$3" storepass="$4" keypass="${5:-$4}"

    [[ ! -f "$apk" ]]      && { log_error "APK not found: $apk"; return 1; }
    [[ ! -f "$keystore" ]] && { log_error "Keystore not found: $keystore"; return 1; }

    local signed_apk="${apk%.apk}-signed.apk"

    log_step "Signing: $(basename "$apk")"

    if command_exists apksigner; then
        apksigner sign \
            --ks "$keystore" \
            --ks-key-alias "$alias" \
            --ks-pass "pass:$storepass" \
            --key-pass "pass:$keypass" \
            --out "$signed_apk" \
            "$apk"
    elif command_exists jarsigner; then
        cp "$apk" "$signed_apk"
        jarsigner \
            -verbose \
            -sigalg SHA256withRSA \
            -digestalg SHA-256 \
            -keystore "$keystore" \
            -storepass "$storepass" \
            -keypass "$keypass" \
            "$signed_apk" \
            "$alias"
        # Zipalign if available
        if command_exists zipalign; then
            local aligned="${signed_apk%.apk}-aligned.apk"
            zipalign -v 4 "$signed_apk" "$aligned"
            mv "$aligned" "$signed_apk"
        fi
    else
        log_error "No signing tool found. Install JDK (apksigner/jarsigner)"
        return 1
    fi

    log_success "Signed APK: $signed_apk ($(file_size "$signed_apk"))"
    echo "$signed_apk"
}

# Generate a new keystore
generate_keystore() {
    local keystore="${1:-$DEFAULT_KEYSTORE}"
    local alias="${2:-$DEFAULT_ALIAS}"
    local storepass="${3:-$DEFAULT_STOREPASS}"
    local dname="${4:-CN=DNYFappbuilder, OU=Dev, O=DNYFTECH, L=Lagos, S=Lagos, C=NG}"

    require keytool "Install JDK"

    ensure_dir "$(dirname "$keystore")"

    log_step "Generating keystore: $keystore"
    keytool -genkey -v \
        -keystore "$keystore" \
        -alias "$alias" \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -storepass "$storepass" \
        -keypass "$storepass" \
        -dname "$dname"

    log_success "Keystore generated: $keystore"
    log_info "Alias    : $alias"
    log_info "Password : $storepass"
    log_warn "Store this keystore securely — you need it for every release!"
}
