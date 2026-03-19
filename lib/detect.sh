#!/usr/bin/env bash
# DNYFappbuilder — Project Type Detection v2.2.0

detect_project_type() {
    local path="${1:-.}"

    # ── JavaScript / TypeScript ────────────────────────────
    if [[ -f "$path/package.json" ]]; then
        local pkg; pkg=$(cat "$path/package.json" 2>/dev/null)

        if echo "$pkg" | grep -q '"react-native"'; then
            echo "react-native"
        elif [[ -f "$path/electron.js" ]] || [[ -f "$path/src/main.js" ]] && echo "$pkg" | grep -q '"electron"'; then
            echo "electron"
        elif echo "$pkg" | grep -q '"next"'; then
            echo "nextjs"
        elif [[ -f "$path/svelte.config.js" ]] || echo "$pkg" | grep -q '"svelte"'; then
            echo "svelte"
        elif echo "$pkg" | grep -q '"vue"'; then
            echo "vue"
        elif echo "$pkg" | grep -q '"@angular/core"'; then
            echo "angular"
        elif [[ -f "$path/vite.config.js" ]] || [[ -f "$path/vite.config.ts" ]]; then
            if echo "$pkg" | grep -q '"react"'; then
                echo "react"
            elif echo "$pkg" | grep -q '"vue"'; then
                echo "vue"
            else
                echo "nodejs"
            fi
        elif [[ -f "$path/tsconfig.json" ]] && echo "$pkg" | grep -q '"typescript"'; then
            echo "nodejs-ts"
        else
            echo "nodejs"
        fi

    # ── Flutter ────────────────────────────────────────────
    elif [[ -f "$path/pubspec.yaml" ]]; then
        echo "flutter"

    # ── Android / Java / Kotlin ────────────────────────────
    elif [[ -f "$path/build.gradle" ]] || [[ -f "$path/build.gradle.kts" ]]; then
        if grep -q "spring" "$path/build.gradle" 2>/dev/null || \
           grep -q "spring" "$path/build.gradle.kts" 2>/dev/null; then
            echo "spring-boot"
        else
            echo "android"
        fi

    elif [[ -f "$path/pom.xml" ]]; then
        if grep -q "spring" "$path/pom.xml" 2>/dev/null; then
            echo "spring-boot"
        else
            echo "java"
        fi

    # ── Python ─────────────────────────────────────────────
    elif [[ -f "$path/requirements.txt" ]] || [[ -f "$path/setup.py" ]] || [[ -f "$path/pyproject.toml" ]]; then
        local reqs=""
        [[ -f "$path/requirements.txt" ]] && reqs=$(cat "$path/requirements.txt" 2>/dev/null | tr '[:upper:]' '[:lower:]')
        if echo "$reqs" | grep -q "fastapi"; then
            echo "fastapi"
        elif echo "$reqs" | grep -q "django"; then
            echo "django"
        elif echo "$reqs" | grep -q "flask"; then
            echo "flask"
        else
            echo "python"
        fi

    # ── Go ─────────────────────────────────────────────────
    elif [[ -f "$path/go.mod" ]]; then
        echo "golang"

    # ── Rust ───────────────────────────────────────────────
    elif [[ -f "$path/Cargo.toml" ]]; then
        echo "rust"

    # ── PWA ────────────────────────────────────────────────
    elif [[ -f "$path/manifest.json" ]] || [[ -f "$path/public/manifest.json" ]]; then
        echo "pwa"

    else
        echo "unknown"
    fi
}

detect_build_output() {
    local type="$1" path="${2:-.}" target="${3:-android}"
    case "$type" in
        react-native)
            case "$target" in
                android) echo "$path/android/app/build/outputs/apk/release/app-release.apk" ;;
                ios)     echo "$path/ios/build/Products/Release-iphoneos/*.ipa" ;;
            esac ;;
        flutter)
            case "$target" in
                android) echo "$path/build/app/outputs/flutter-apk/app-release.apk" ;;
                ios)     echo "$path/build/ios/iphoneos/*.app" ;;
                web)     echo "$path/build/web" ;;
            esac ;;
        android)     echo "$path/app/build/outputs/apk/release/app-release.apk" ;;
        nodejs|nodejs-ts|react|vue|nextjs|svelte|pwa) echo "$path/dist" ;;
        python|fastapi|django|flask) echo "$path" ;;
        golang)      echo "$path/bin/server" ;;
        rust)        echo "$path/target/release/$( basename "$path")" ;;
        spring-boot|java) echo "$(find "$path/build/libs" -name "*.jar" 2>/dev/null | head -1)" ;;
        *) echo "" ;;
    esac
}

detect_package_id() {
    local path="${1:-.}"
    if [[ -f "$path/android/app/src/main/AndroidManifest.xml" ]]; then
        grep 'package=' "$path/android/app/src/main/AndroidManifest.xml" 2>/dev/null \
            | sed 's/.*package="\([^"]*\)".*/\1/' | head -1
    elif [[ -f "$path/android/app/build.gradle" ]]; then
        grep 'applicationId' "$path/android/app/build.gradle" 2>/dev/null \
            | sed 's/.*applicationId.*"\(.*\)".*/\1/' | head -1
    fi
}
