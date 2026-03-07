#!/usr/bin/env bash
# DNYFappbuilder — Test Runner v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh" 2>/dev/null || {
    RED='\e[1;31m'; GREEN='\e[1;32m'; CYAN='\e[1;36m'; RESET='\e[0m'
    log_info() { echo -e "${CYAN}[INFO]${RESET} $*"; }
    log_success() { echo -e "${GREEN}[SUCCESS]${RESET} $*"; }
    log_error() { echo -e "${RED}[ERROR]${RESET} $*"; }
}

PASSED=0
FAILED=0
SKIPPED=0

run_test() {
    local name="$1" file="$2"
    printf "  %-40s" "$name"
    if [[ ! -f "$file" ]]; then
        echo -e "${DIM:-}SKIP${RESET:-}"
        ((SKIPPED++))
        return
    fi
    if bash "$file" &>/tmp/abp-test-out 2>&1; then
        echo -e "${GREEN}✓ PASS${RESET}"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${RESET}"
        echo "    $(tail -3 /tmp/abp-test-out | head -1)"
        ((FAILED++))
    fi
}

echo ""
echo -e "${BOLD}DNYFappbuilder — Test Suite v2.0.0${RESET}"
echo -e "${DIM}──────────────────────────────────────────${RESET}"
echo ""

echo -e "${CYAN}Core Tests${RESET}"
run_test "CLI: version command"   "tests/test-cli.sh"
run_test "CLI: help command"      "tests/test-help.sh"
run_test "Project: init nodejs"   "tests/test-init.sh"
run_test "Build: nodejs project"  "tests/test-build.sh"

echo ""
echo -e "${CYAN}Device Tests${RESET}"
run_test "Devices: ADB detection" "tests/test-devices.sh"
run_test "Install: APK install"   "tests/test-install.sh"

echo ""
echo -e "${CYAN}Feature Tests${RESET}"
run_test "Doctor: env check"      "tests/test-doctor.sh"
run_test "Env: profile management" "tests/test-env.sh"
run_test "Sign: keystore gen"     "tests/test-sign.sh"

echo ""
echo -e "${DIM}──────────────────────────────────────────${RESET}"
echo -e "  ${GREEN}Passed  : $PASSED${RESET}"
echo -e "  ${RED}Failed  : $FAILED${RESET}"
echo -e "  ${DIM}Skipped : $SKIPPED${RESET}"
echo ""

if [[ $FAILED -eq 0 ]]; then
    log_success "All tests passed!"
    exit 0
else
    log_error "$FAILED test(s) failed"
    exit 1
fi
