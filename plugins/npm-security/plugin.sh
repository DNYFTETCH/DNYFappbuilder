#!/usr/bin/env bash
# DNYFappbuilder Plugin — npm Security Audit

PLUGIN_NAME="npm-security"
PLUGIN_VERSION="1.0.0"

run_audit() {
    local project="${1:-.}"
    [[ ! -f "$project/package.json" ]] && { echo "Not a Node.js project: $project"; exit 1; }
    cd "$project"
    echo "Running npm security audit..."
    npm audit
    echo ""
    echo "Run 'npm audit fix' to auto-fix issues"
}

fix_vulnerabilities() {
    local project="${1:-.}"
    cd "$project"
    echo "Auto-fixing vulnerabilities..."
    npm audit fix
    echo "Done. Run 'npm audit' to verify."
}

case "${1:-audit}" in
    audit) shift; run_audit "$@" ;;
    fix)   shift; fix_vulnerabilities "$@" ;;
    info)  echo "npm Security Plugin v$PLUGIN_VERSION" ;;
    *)     echo "Usage: plugin.sh [audit|fix|info] [project-dir]" ;;
esac
