#!/usr/bin/env bash
# DNYFappbuilder Plugin — Gradle Optimizer
# Injects performance optimizations into Android/Flutter Gradle builds

PLUGIN_NAME="gradle-optimizer"
PLUGIN_VERSION="1.0.0"

apply_optimizations() {
    local project="${1:-.}"
    local props_file="$project/android/gradle.properties"

    [[ ! -f "$props_file" ]] && props_file="$project/gradle.properties"
    [[ ! -f "$props_file" ]] && { echo "No gradle.properties found in $project"; exit 1; }

    # Don't double-apply
    grep -q "ABP_OPTIMIZED" "$props_file" 2>/dev/null && {
        echo "Gradle optimizations already applied"
        exit 0
    }

    cat >> "$props_file" <<'PROPS'

# DNYFappbuilder — Gradle Optimizations (ABP_OPTIMIZED)
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configureondemand=true
org.gradle.jvmargs=-Xmx4096m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
android.enableJetifier=true
android.useAndroidX=true
android.enableR8.fullMode=true
PROPS

    echo "✓ Gradle optimizations applied to $props_file"
}

revert_optimizations() {
    local project="${1:-.}"
    local props_file="$project/android/gradle.properties"
    [[ ! -f "$props_file" ]] && props_file="$project/gradle.properties"
    sed -i '/# DNYFappbuilder — Gradle Optimizations/,/android\.enableR8\.fullMode/d' "$props_file"
    echo "✓ Gradle optimizations reverted"
}

case "${1:-apply}" in
    apply)  shift; apply_optimizations "$@" ;;
    revert) shift; revert_optimizations "$@" ;;
    info)   echo "Gradle Optimizer Plugin v$PLUGIN_VERSION" ;;
    *)      echo "Usage: plugin.sh [apply|revert|info] [project-dir]" ;;
esac
