#!/usr/bin/env bash
# DNYFappbuilder — Build Script v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"
source "$ABP_ROOT/lib/detect.sh"
source "$ABP_ROOT/lib/signing.sh"
source "$ABP_ROOT/lib/notify.sh"

# ── Defaults ──────────────────────────────────────────────
PROJECT="${1:-.}"; shift || true
TARGET="all"
PROFILE="release"
PARALLEL=false
NO_CACHE=false
AUTO_SIGN=false
AUTO_INSTALL=false
NOTIFY=false
OUTPUT_DIR=""
DEVICE_SERIAL=""

# ── Parse flags ───────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)    TARGET="$2";    shift 2 ;;
        --profile)   PROFILE="$2";  shift 2 ;;
        --parallel)  PARALLEL=true;  shift ;;
        --no-cache)  NO_CACHE=true;  shift ;;
        --sign)      AUTO_SIGN=true; shift ;;
        --install)   AUTO_INSTALL=true; shift ;;
        --notify)    NOTIFY=true;    shift ;;
        --output)    OUTPUT_DIR="$2"; shift 2 ;;
        --device)    DEVICE_SERIAL="$2"; shift 2 ;;
        *) log_warn "Unknown flag: $1"; shift ;;
    esac
done

# ── Validate ──────────────────────────────────────────────
[[ ! -d "$PROJECT" ]] && { log_error "Project path not found: $PROJECT"; exit 1; }

PROJECT=$(realpath "$PROJECT")
TYPE=$(detect_project_type "$PROJECT")
BUILD_DIR="${OUTPUT_DIR:-$ABP_ROOT/builds/$(basename "$PROJECT")-$(timestamp)}"
ensure_dir "$BUILD_DIR"

log_build_header "$PROJECT" "$TYPE"
timer_start

log_info "Project : ${BOLD}$(basename "$PROJECT")${RESET}"
log_info "Type    : ${BOLD}$TYPE${RESET}"
log_info "Target  : ${BOLD}$TARGET${RESET}"
log_info "Profile : ${BOLD}$PROFILE${RESET}"
echo ""

# ── Build functions ───────────────────────────────────────

build_react_native() {
    log_step "React Native — installing dependencies"
    cd "$PROJECT"
    $NO_CACHE && rm -rf node_modules/.cache
    [[ -d node_modules ]] || npm install

    if [[ "$TARGET" == "android" ]] || [[ "$TARGET" == "all" ]]; then
        log_step "Building Android APK ($PROFILE)"
        cd android

        local gradle_task="assemble$(tr '[:lower:]' '[:upper:]' <<< "${PROFILE:0:1}")${PROFILE:1}"
        ./gradlew "$gradle_task" --no-daemon ${NO_CACHE:+--rerun-tasks}

        local apk="$PROJECT/android/app/build/outputs/apk/$PROFILE/app-${PROFILE}.apk"
        if [[ -f "$apk" ]]; then
            cp "$apk" "$BUILD_DIR/"
            log_success "APK: $BUILD_DIR/app-${PROFILE}.apk ($(file_size "$apk"))"
            BUILT_APK="$BUILD_DIR/app-${PROFILE}.apk"
        fi
        cd "$PROJECT"
    fi

    if [[ "$TARGET" == "ios" ]] || [[ "$TARGET" == "all" ]]; then
        if is_macos; then
            log_step "Building iOS ($PROFILE)"
            cd ios && xcodebuild -workspace *.xcworkspace \
                -scheme "$(basename "$PROJECT")" \
                -configuration "$(tr '[:lower:]' '[:upper:]' <<< "${PROFILE:0:1}")${PROFILE:1}" \
                -sdk iphoneos \
                -derivedDataPath "$BUILD_DIR/ios" \
                DEVELOPMENT_TEAM="${APPLE_TEAM_ID:-}" \
                archive -archivePath "$BUILD_DIR/app.xcarchive"
            log_success "iOS archive: $BUILD_DIR/app.xcarchive"
        else
            log_warn "iOS builds require macOS. Skipping iOS target."
        fi
    fi
}

build_flutter() {
    log_step "Flutter — fetching packages"
    cd "$PROJECT"
    require flutter "https://flutter.dev/docs/get-started/install"
    flutter pub get

    build_flutter_target() {
        local t="$1"
        case "$t" in
            android)
                log_step "Flutter — building Android APK ($PROFILE)"
                flutter build apk --"$PROFILE" ${NO_CACHE:+--no-pub}
                local apk="$PROJECT/build/app/outputs/flutter-apk/app-${PROFILE}.apk"
                if [[ -f "$apk" ]]; then
                    cp "$apk" "$BUILD_DIR/"
                    BUILT_APK="$BUILD_DIR/app-${PROFILE}.apk"
                    log_success "APK: $BUILD_DIR/app-${PROFILE}.apk ($(file_size "$apk"))"
                fi
                ;;
            ios)
                is_macos || { log_warn "iOS build requires macOS"; return; }
                log_step "Flutter — building iOS"
                flutter build ios --"$PROFILE" --no-codesign
                ;;
            web)
                log_step "Flutter — building Web"
                flutter build web --"$PROFILE"
                cp -r "$PROJECT/build/web" "$BUILD_DIR/web"
                log_success "Web: $BUILD_DIR/web"
                ;;
        esac
    }

    if [[ "$TARGET" == "all" ]]; then
        if $PARALLEL; then
            build_flutter_target android &
            build_flutter_target web &
            wait
        else
            build_flutter_target android
            build_flutter_target web
        fi
    else
        build_flutter_target "$TARGET"
    fi
}

build_android() {
    log_step "Android — assembling ($PROFILE)"
    cd "$PROJECT"
    require java "apt install default-jdk / pkg install openjdk-17"

    local gradle_task="assemble$(tr '[:lower:]' '[:upper:]' <<< "${PROFILE:0:1}")${PROFILE:1}"
    ./gradlew "$gradle_task" --no-daemon

    local apk
    apk=$(find "$PROJECT" -name "*.apk" -path "*/$PROFILE/*" 2>/dev/null | head -1)
    if [[ -n "$apk" ]]; then
        cp "$apk" "$BUILD_DIR/"
        BUILT_APK="$BUILD_DIR/$(basename "$apk")"
        log_success "APK: $BUILT_APK ($(file_size "$apk"))"
    fi
}

build_nodejs() {
    log_step "Node.js — preparing build"
    cd "$PROJECT"
    $NO_CACHE && npm cache clean --force 2>/dev/null || true

    # Only install if package-lock or node_modules absent
    if [[ -f package-lock.json ]]; then
        npm ci --prefer-offline 2>/dev/null || npm install --prefer-offline || true
    elif [[ ! -d node_modules ]]; then
        npm install --prefer-offline 2>/dev/null || true
    fi

    if [[ -f package.json ]] && node -e "const p=require('./package.json');process.exit(p.scripts&&p.scripts.build?0:1)" 2>/dev/null; then
        log_step "Running build script"
        npm run build 2>/dev/null || true
    fi

    # Copy to build dir
    rsync -a --exclude node_modules --exclude .git "$PROJECT/" "$BUILD_DIR/" 2>/dev/null ||         cp -r "$PROJECT/." "$BUILD_DIR/"
    log_success "Build output: $BUILD_DIR"
}

build_python() {
    log_step "Python — setting up environment"
    cd "$PROJECT"
    require python3

    if $NO_CACHE; then
        rm -rf venv
    fi

    python3 -m venv venv
    # shellcheck source=/dev/null
    source venv/bin/activate

    if [[ -f requirements.txt ]]; then
        pip install --upgrade pip -q
        pip install -r requirements.txt -q
    elif [[ -f pyproject.toml ]]; then
        pip install -e ".[all]" -q 2>/dev/null || pip install -e . -q
    fi

    rsync -a --exclude venv --exclude __pycache__ --exclude .git "$PROJECT/" "$BUILD_DIR/"
    log_success "Python build: $BUILD_DIR"
}

build_spring_boot() {
    log_step "Spring Boot — building JAR"
    cd "$PROJECT"
    require java

    if [[ -f mvnw ]]; then
        ./mvnw clean package -DskipTests -q
        local jar; jar=$(find target -name "*.jar" ! -name "*sources*" | head -1)
    elif [[ -f gradlew ]]; then
        ./gradlew bootJar --no-daemon
        local jar; jar=$(find build/libs -name "*.jar" | head -1)
    else
        log_error "No Maven or Gradle wrapper found"
        exit 1
    fi

    [[ -n "$jar" ]] && cp "$jar" "$BUILD_DIR/" && log_success "JAR: $BUILD_DIR/$(basename "$jar")"
}

# ── Main build dispatch ────────────────────────────────────
BUILT_APK=""

case "$TYPE" in
    react-native) build_react_native ;;
    flutter)      build_flutter ;;
    android)      build_android ;;
    nodejs|nextjs|vue|angular) build_nodejs ;;
    python|fastapi|django|flask) build_python ;;
    spring-boot|java) build_spring_boot ;;
    *)
        log_error "Unknown project type: $TYPE"
        log_info  "Supported: react-native, flutter, android, nodejs, python, spring-boot"
        exit 1
        ;;
esac

ELAPSED=$(timer_elapsed)

# ── Post-build: Sign ──────────────────────────────────────
if $AUTO_SIGN && [[ -n "$BUILT_APK" ]]; then
    log_step "Auto-signing APK..."
    KEYSTORE=$(config_get '.signing.keystore' "$DEFAULT_KEYSTORE")
    ALIAS=$(config_get    '.signing.alias'    "$DEFAULT_ALIAS")
    PASS=$(config_get     '.signing.password' "$DEFAULT_STOREPASS")

    if [[ ! -f "$KEYSTORE" ]]; then
        log_warn "No keystore found — generating one..."
        generate_keystore "$KEYSTORE" "$ALIAS" "$PASS"
    fi

    SIGNED=$(sign_apk "$BUILT_APK" "$KEYSTORE" "$ALIAS" "$PASS")
    BUILT_APK="${SIGNED:-$BUILT_APK}"
fi

# ── Post-build: Install ───────────────────────────────────
if $AUTO_INSTALL && [[ -n "$BUILT_APK" ]]; then
    log_step "Auto-installing to device..."
    bash "$ABP_ROOT/scripts/install.sh" "$BUILT_APK" ${DEVICE_SERIAL:+--device "$DEVICE_SERIAL"}
fi

# ── Post-build: Notify ────────────────────────────────────
if $NOTIFY; then
    notify_build_done "$(basename "$PROJECT")" "SUCCESS" "$ELAPSED"
    SLACK_HOOK=$(config_get '.notifications.slack_webhook' "")
    notify_slack "$SLACK_HOOK" "✅ DNYFappbuilder: $(basename "$PROJECT") built in $ELAPSED"
fi

echo ""
log_success "Build complete in ${BOLD}$ELAPSED${RESET}"
log_info    "Output: $BUILD_DIR"
