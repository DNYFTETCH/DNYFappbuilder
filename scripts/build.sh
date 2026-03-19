#!/usr/bin/env bash
# DNYFappbuilder — Build Script v2.2.0

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

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)    TARGET="$2";        shift 2 ;;
        --profile)   PROFILE="$2";       shift 2 ;;
        --parallel)  PARALLEL=true;       shift ;;
        --no-cache)  NO_CACHE=true;       shift ;;
        --sign)      AUTO_SIGN=true;      shift ;;
        --install)   AUTO_INSTALL=true;   shift ;;
        --notify)    NOTIFY=true;         shift ;;
        --output)    OUTPUT_DIR="$2";     shift 2 ;;
        --device)    DEVICE_SERIAL="$2";  shift 2 ;;
        *) log_warn "Unknown flag: $1";   shift ;;
    esac
done

[[ ! -d "$PROJECT" ]] && { log_error "Project path not found: $PROJECT"; exit 1; }

PROJECT=$(realpath "$PROJECT")
TYPE=$(detect_project_type "$PROJECT")
BUILD_DIR="${OUTPUT_DIR:-$ABP_ROOT/builds/$(basename "$PROJECT")-$(timestamp)}"
mkdir -p "$BUILD_DIR"

log_build_header "$PROJECT" "$TYPE"
timer_start

log_info "Project : ${BOLD}$(basename "$PROJECT")${RESET}"
log_info "Type    : ${BOLD}$TYPE${RESET}"
log_info "Target  : ${BOLD}$TARGET${RESET}"
log_info "Profile : ${BOLD}$PROFILE${RESET}"
echo ""

BUILT_APK=""

# ── Build functions ───────────────────────────────────────

build_react_native() {
    log_step "React Native — installing dependencies"
    cd "$PROJECT"
    $NO_CACHE && rm -rf node_modules/.cache 2>/dev/null || true
    [[ -d node_modules ]] || npm install

    if [[ "$TARGET" == "android" ]] || [[ "$TARGET" == "all" ]]; then
        log_step "Building Android APK ($PROFILE)"
        cd android
        local gradle_task
        gradle_task="assemble$(tr '[:lower:]' '[:upper:]' <<< "${PROFILE:0:1}")${PROFILE:1}"
        ./gradlew "$gradle_task" --no-daemon
        local apk="$PROJECT/android/app/build/outputs/apk/$PROFILE/app-${PROFILE}.apk"
        if [[ -f "$apk" ]]; then
            cp "$apk" "$BUILD_DIR/"
            BUILT_APK="$BUILD_DIR/app-${PROFILE}.apk"
            log_success "APK: $BUILT_APK"
        fi
        cd "$PROJECT"
    fi

    if [[ "$TARGET" == "ios" ]] || [[ "$TARGET" == "all" ]]; then
        is_macos || { log_warn "iOS requires macOS — skipped"; return; }
        log_step "Building iOS ($PROFILE)"
        cd ios && pod install 2>/dev/null || true
        xcodebuild -workspace "*.xcworkspace" -scheme "$(basename "$PROJECT")" \
            -configuration "${PROFILE^}" -sdk iphoneos \
            -derivedDataPath "$BUILD_DIR/ios" archive \
            -archivePath "$BUILD_DIR/app.xcarchive"
        log_success "iOS archive: $BUILD_DIR/app.xcarchive"
    fi
}

build_flutter() {
    log_step "Flutter — fetching packages"
    cd "$PROJECT"
    require flutter "https://flutter.dev"
    flutter pub get

    build_flutter_target() {
        case "$1" in
            android)
                log_step "Flutter — Android APK ($PROFILE)"
                flutter build apk "--$PROFILE"
                local apk="$PROJECT/build/app/outputs/flutter-apk/app-${PROFILE}.apk"
                [[ -f "$apk" ]] && { cp "$apk" "$BUILD_DIR/"; BUILT_APK="$BUILD_DIR/app-${PROFILE}.apk"; log_success "APK: $BUILT_APK"; }
                ;;
            ios)
                is_macos || { log_warn "iOS requires macOS — skipped"; return; }
                flutter build ios "--$PROFILE" --no-codesign
                ;;
            web)
                log_step "Flutter — Web"
                flutter build web "--$PROFILE"
                cp -r "$PROJECT/build/web" "$BUILD_DIR/web"
                log_success "Web: $BUILD_DIR/web"
                ;;
        esac
    }

    if [[ "$TARGET" == "all" ]]; then
        $PARALLEL && { build_flutter_target android & build_flutter_target web & wait; } \
                  || { build_flutter_target android; build_flutter_target web; }
    else
        build_flutter_target "$TARGET"
    fi
}

build_android() {
    log_step "Android — Gradle build ($PROFILE)"
    cd "$PROJECT"
    require java "pkg install openjdk-17"
    local gradle_task
    gradle_task="assemble$(tr '[:lower:]' '[:upper:]' <<< "${PROFILE:0:1}")${PROFILE:1}"
    ./gradlew "$gradle_task" --no-daemon
    local apk
    apk=$(find "$PROJECT" -name "*.apk" -path "*/$PROFILE/*" 2>/dev/null | head -1)
    [[ -n "$apk" ]] && { cp "$apk" "$BUILD_DIR/"; BUILT_APK="$BUILD_DIR/$(basename "$apk")"; log_success "APK: $BUILT_APK"; }
}

build_nodejs() {
    log_step "Node.js — preparing build"
    cd "$PROJECT"
    $NO_CACHE && npm cache clean --force 2>/dev/null || true

    if [[ -f package-lock.json ]]; then
        npm ci --prefer-offline 2>/dev/null || npm install --prefer-offline || true
    elif [[ ! -d node_modules ]]; then
        npm install --prefer-offline 2>/dev/null || true
    fi

    if [[ -f package.json ]] && node -e "const p=require('./package.json');process.exit(p.scripts&&p.scripts.build?0:1)" 2>/dev/null; then
        log_step "Running build script"
        npm run build 2>/dev/null || true
    fi

    rsync -a --exclude node_modules --exclude .git "$PROJECT/" "$BUILD_DIR/" 2>/dev/null || \
        cp -r "$PROJECT/." "$BUILD_DIR/"
    log_success "Build output: $BUILD_DIR"
}

build_vite() {
    log_step "Vite — building frontend ($PROFILE)"
    cd "$PROJECT"
    $NO_CACHE && rm -rf node_modules/.cache 2>/dev/null || true
    [[ -d node_modules ]] || npm install --prefer-offline 2>/dev/null || true

    local vite_mode="production"
    [[ "$PROFILE" == "debug" ]] && vite_mode="development"

    npm run build -- --mode "$vite_mode" 2>/dev/null || npm run build 2>/dev/null || true

    local dist_dir="$PROJECT/dist"
    [[ -d "$PROJECT/.next" ]] && dist_dir="$PROJECT/.next"
    [[ -d "$PROJECT/.svelte-kit" ]] && dist_dir="$PROJECT/.svelte-kit"

    if [[ -d "$dist_dir" ]]; then
        cp -r "$dist_dir" "$BUILD_DIR/dist"
        log_success "Frontend build: $BUILD_DIR/dist"
    else
        rsync -a --exclude node_modules --exclude .git "$PROJECT/" "$BUILD_DIR/" 2>/dev/null || true
        log_success "Build output: $BUILD_DIR"
    fi
}

build_nextjs() {
    log_step "Next.js — building"
    cd "$PROJECT"
    [[ -d node_modules ]] || npm install --prefer-offline 2>/dev/null || true
    npm run build 2>/dev/null || true
    rsync -a --exclude node_modules --exclude .git "$PROJECT/" "$BUILD_DIR/" 2>/dev/null || true
    log_success "Next.js build: $BUILD_DIR"
}

build_electron() {
    log_step "Electron — packaging desktop app"
    cd "$PROJECT"
    [[ -d node_modules ]] || npm install --prefer-offline 2>/dev/null || true
    npm run build 2>/dev/null || npm run dist 2>/dev/null || true
    local dist="$PROJECT/dist"
    [[ -d "$dist" ]] && cp -r "$dist" "$BUILD_DIR/dist" && log_success "Electron dist: $BUILD_DIR/dist"
}

build_python() {
    log_step "Python — setting up venv"
    cd "$PROJECT"
    require python3
    $NO_CACHE && rm -rf venv 2>/dev/null || true
    python3 -m venv venv
    source venv/bin/activate
    [[ -f requirements.txt ]] && pip install --upgrade pip -q && pip install -r requirements.txt -q
    [[ -f pyproject.toml ]]  && pip install -e ".[all]" -q 2>/dev/null || pip install -e . -q 2>/dev/null || true
    rsync -a --exclude venv --exclude __pycache__ --exclude .git "$PROJECT/" "$BUILD_DIR/"
    log_success "Python build: $BUILD_DIR"
}

build_django() {
    log_step "Django — collecting static"
    cd "$PROJECT"
    require python3
    $NO_CACHE && rm -rf venv 2>/dev/null || true
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip -q && pip install -r requirements.txt -q
    python manage.py collectstatic --noinput 2>/dev/null || true
    rsync -a --exclude venv --exclude __pycache__ --exclude .git "$PROJECT/" "$BUILD_DIR/"
    log_success "Django build: $BUILD_DIR"
}

build_go() {
    log_step "Go — compiling"
    cd "$PROJECT"
    require go "pkg install golang"
    go mod tidy 2>/dev/null || true
    local output="$BUILD_DIR/$(basename "$PROJECT")"
    go build -o "$output" ./cmd/server/... 2>/dev/null || \
    go build -o "$output" . 2>/dev/null || true
    [[ -f "$output" ]] && log_success "Binary: $output" || log_warn "Build output not found"
}

build_rust() {
    log_step "Rust — cargo build"
    cd "$PROJECT"
    require cargo "https://rustup.rs"
    [[ "$PROFILE" == "release" ]] && cargo build --release || cargo build
    local bin
    bin=$(find target -name "$(basename "$PROJECT")" -type f 2>/dev/null | head -1)
    [[ -n "$bin" ]] && cp "$bin" "$BUILD_DIR/" && log_success "Binary: $BUILD_DIR/$(basename "$bin")"
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
        log_error "No Maven or Gradle wrapper found"; exit 1
    fi
    [[ -n "${jar:-}" ]] && cp "$jar" "$BUILD_DIR/" && log_success "JAR: $BUILD_DIR/$(basename "$jar")"
}

# ── Dispatch ──────────────────────────────────────────────
case "$TYPE" in
    react-native)          build_react_native ;;
    flutter)               build_flutter ;;
    android)               build_android ;;
    nodejs|nodejs-ts)      build_nodejs ;;
    react|vue|svelte|pwa)  build_vite ;;
    nextjs)                build_nextjs ;;
    electron)              build_electron ;;
    python|fastapi|flask)  build_python ;;
    django)                build_django ;;
    golang)                build_go ;;
    rust)                  build_rust ;;
    spring-boot|java)      build_spring_boot ;;
    *)
        log_error "Unknown project type: $TYPE"
        log_info  "Run: abp init <name> <template> to create a supported project"
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
    [[ ! -f "$KEYSTORE" ]] && { log_warn "No keystore — generating..."; generate_keystore "$KEYSTORE" "$ALIAS" "$PASS"; }
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
