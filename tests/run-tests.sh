#!/usr/bin/env bash
# DNYFappbuilder — Test Suite v2.2.0

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"

source "$ABP_ROOT/lib/common.sh" 2>/dev/null || {
    RED=$'\e[1;31m'; GREEN=$'\e[1;32m'; CYAN=$'\e[1;36m'
    BOLD=$'\e[1m'; DIM=$'\e[2m'; RESET=$'\e[0m'
    log_success() { echo -e "${GREEN}[SUCCESS]${RESET} $*"; }
    log_error()   { echo -e "${RED}[ERROR]${RESET} $*"; }
}

PASSED=0; FAILED=0; SKIPPED=0

run_test() {
    local name="$1" file="$2"
    printf "  %-44s" "$name"
    if [[ ! -f "$file" ]]; then
        echo -e "${DIM}SKIP${RESET}"
        SKIPPED=$(( SKIPPED + 1 ))
        return 0
    fi
    if bash "$file" > /tmp/abp-test-out 2>&1; then
        echo -e "${GREEN}✓ PASS${RESET}"
        PASSED=$(( PASSED + 1 ))
    else
        echo -e "${RED}✗ FAIL${RESET}"
        echo "    $(tail -3 /tmp/abp-test-out | head -1)"
        FAILED=$(( FAILED + 1 ))
    fi
}

echo ""
echo -e "${BOLD}DNYFappbuilder — Test Suite v2.2.0${RESET}"
echo -e "${DIM}────────────────────────────────────────────────${RESET}"
echo ""

echo -e "${CYAN}Core CLI${RESET}"
run_test "CLI: version command"              "tests/test-cli.sh"
run_test "CLI: help command"                 "tests/test-help.sh"

echo ""
echo -e "${CYAN}Project Init${RESET}"
run_test "Init: nodejs scaffold"             "tests/test-init.sh"
run_test "Init: react scaffold"              "tests/test-init-react.sh"
run_test "Init: vue scaffold"                "tests/test-init-vue.sh"
run_test "Init: python scaffold"             "tests/test-init-python.sh"
run_test "Init: go scaffold"                 "tests/test-init-go.sh"
run_test "Init: electron scaffold"           "tests/test-init-electron.sh"
run_test "Init: nextjs scaffold"             "tests/test-init-nextjs.sh"

echo ""
echo -e "${CYAN}Build${RESET}"
run_test "Build: nodejs project"             "tests/test-build.sh"
run_test "Build: python project"             "tests/test-build-python.sh"
run_test "Build: vite react project"         "tests/test-build-react.sh"

echo ""
echo -e "${CYAN}Device${RESET}"
run_test "Devices: ADB detection"            "tests/test-devices.sh"
run_test "Install: APK install"              "tests/test-install.sh"

echo ""
echo -e "${CYAN}Features${RESET}"
run_test "Doctor: env check"                 "tests/test-doctor.sh"
run_test "Env: profile management"           "tests/test-env.sh"
run_test "Sign: keystore gen"                "tests/test-sign.sh"
run_test "Detect: project type detection"    "tests/test-detect.sh"

echo ""
echo -e "${DIM}────────────────────────────────────────────────${RESET}"
echo -e "  ${GREEN}Passed  : $PASSED${RESET}"
echo -e "  ${RED}Failed  : $FAILED${RESET}"
echo -e "  ${DIM}Skipped : $SKIPPED${RESET}"
echo ""

if [[ "$FAILED" -eq 0 ]]; then
    log_success "All tests passed!"
    exit 0
else
    log_error "$FAILED test(s) failed"
    exit 1
fi
