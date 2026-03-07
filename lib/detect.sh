#!/usr/bin/env bash
# DNYFappbuilder — Project Type Detection Library

detect_project_type() {
    local path="${1:-.}"

    if [[ -f "$path/package.json" ]]; then
        if grep -q '"react-native"' "$path/package.json" 2>/dev/null; then
            echo "react-native"
        elif grep -q '"next"' "$path/package.json" 2>/dev/null; then
            echo "nextjs"
        elif grep -q '"vue"' "$path/package.json" 2>/dev/null; then
            echo "vue"
        elif grep -q '"@angular/core"' "$path/package.json" 2>/dev/null; then
            echo "angular"
        else
            echo "nodejs"
        fi
    elif [[ -f "$path/pubspec.yaml" ]]; then
        echo "flutter"
    elif [[ -f "$path/build.gradle" ]] || [[ -f "$path/build.gradle.kts" ]]; then
        if grep -q "spring" "$path/build.gradle" 2>/dev/null || grep -q "spring" "$path/pom.xml" 2>/dev/null; then
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
    elif [[ -f "$path/requirements.txt" ]] || [[ -f "$path/setup.py" ]] || [[ -f "$path/pyproject.toml" ]]; then
        if grep -q "fastapi" "$path/requirements.txt" 2>/dev/null; then
            echo "fastapi"
        elif grep -q "django" "$path/requirements.txt" 2>/dev/null; then
            echo "django"
        elif grep -q "flask" "$path/requirements.txt" 2>/dev/null; then
            echo "flask"
        else
            echo "python"
        fi
    elif [[ -f "$path/Cargo.toml" ]]; then
        echo "rust"
    elif [[ -f "$path/go.mod" ]]; then
        echo "golang"
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
        android) echo "$path/app/build/outputs/apk/release/app-release.apk" ;;
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
