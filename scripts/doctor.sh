#!/usr/bin/env bash
# DNYFappbuilder — Doctor (Environment Health Check) v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"

PASS=0
WARN=0
FAIL=0

check() {
    local label="$1" cmd="$2" hint="${3:-}"
    printf "  %-25s" "$label"
    if eval "$cmd" &>/dev/null 2>&1; then
        local version; version=$(eval "$cmd" 2>/dev/null | head -1 | tr -d '\n' | cut -c1-40)
        echo -e "${GREEN}✓${RESET}  $version"
        ((PASS++))
    else
        echo -e "${RED}✗${RESET}  Not found"
        [[ -n "$hint" ]] && echo -e "    ${DIM}→ $hint${RESET}"
        ((FAIL++))
    fi
}

check_warn() {
    local label="$1" cmd="$2" hint="${3:-}"
    printf "  %-25s" "$label"
    if eval "$cmd" &>/dev/null 2>&1; then
        local version; version=$(eval "$cmd" 2>/dev/null | head -1 | tr -d '\n' | cut -c1-40)
        echo -e "${GREEN}✓${RESET}  $version"
        ((PASS++))
    else
        echo -e "${YELLOW}⚠${RESET}  Not found (optional)"
        [[ -n "$hint" ]] && echo -e "    ${DIM}→ $hint${RESET}"
        ((WARN++))
    fi
}

echo ""
echo -e "${BOLD}DNYFappbuilder — Doctor${RESET}"
echo -e "${DIM}Checking environment...${RESET}"
echo ""

echo -e "${CYAN}Core Tools${RESET}"
check "Bash 4+"         "bash --version"
check "Git"             "git --version"              "apt install git / pkg install git"
check "curl"            "curl --version"              "apt install curl / pkg install curl"

echo ""
echo -e "${CYAN}Build Runtimes${RESET}"
check      "Node.js"    "node --version"              "https://nodejs.org"
check      "npm"        "npm --version"               "comes with Node.js"
check      "Python 3"   "python3 --version"           "apt install python3 / pkg install python"
check      "Java (JDK)" "java -version"               "apt install default-jdk / pkg install openjdk-17"
check_warn "Flutter"    "flutter --version"           "https://flutter.dev"
check_warn "Gradle"     "gradle --version"            "apt install gradle / pkg install gradle"

echo ""
echo -e "${CYAN}Android Tools${RESET}"
check      "ADB"        "adb --version"               "apt install adb / pkg install android-tools"
check_warn "apksigner"  "apksigner --version"         "part of Android SDK build-tools"
check_warn "zipalign"   "zipalign --version"          "part of Android SDK build-tools"
check_warn "keytool"    "keytool -help"               "part of JDK"
check_warn "bundletool" "java -jar bundletool.jar help 2>/dev/null || bundletool help" "https://github.com/google/bundletool"

echo ""
echo -e "${CYAN}iOS Tools (macOS only)${RESET}"
if is_macos; then
    check_warn "Xcode (xcrun)"   "xcrun --version"        "Install Xcode from App Store"
    check_warn "ios-deploy"      "ios-deploy --version"   "npm install -g ios-deploy"
    check_warn "idevice_id"      "idevice_id --version"   "brew install libimobiledevice"
else
    echo -e "  ${DIM}iOS tools require macOS — skipped${RESET}"
fi

echo ""
echo -e "${CYAN}DevOps / Deploy${RESET}"
check_warn "Docker"         "docker --version"       "https://docker.com"
check_warn "docker compose" "docker compose version" "included with Docker Desktop"
check_warn "Railway CLI"    "railway --version"      "npm install -g @railway/cli"
check_warn "Render CLI"     "render --version"       "https://render.com/docs/cli"
check_warn "Vercel CLI"     "vercel --version"       "npm install -g vercel"
check_warn "Heroku CLI"     "heroku --version"       "https://devcenter.heroku.com/articles/heroku-cli"

echo ""
echo -e "${CYAN}QR & Notification${RESET}"
check_warn "qrencode"            "qrencode --version"      "apt install qrencode / pkg install qrencode"
check_warn "termux-notification" "termux-notification --help" "Termux:API app from F-Droid"
check_warn "jq"                  "jq --version"            "apt install jq / pkg install jq"

# ── Termux-specific ───────────────────────────────────────
if is_termux; then
    echo ""
    echo -e "${CYAN}Termux Environment${RESET}"
    echo -e "  ${GREEN}✓${RESET}  Termux detected (v${TERMUX_VERSION:-?})"
    check_warn "Termux:API" "termux-battery-status" "Install Termux:API app from F-Droid"
    check_warn "openssh"    "ssh -V"                "pkg install openssh"
fi

# ── ABP Installation ─────────────────────────────────────
echo ""
echo -e "${CYAN}DNYFappbuilder${RESET}"
printf "  %-25s" "ABP Root"
if [[ -d "$ABP_ROOT" ]]; then
    echo -e "${GREEN}✓${RESET}  $ABP_ROOT"
else
    echo -e "${RED}✗${RESET}  Not found ($ABP_ROOT)"
fi

printf "  %-25s" "Config"
if [[ -f "$ABP_ROOT/config/builder.json" ]]; then
    echo -e "${GREEN}✓${RESET}  $ABP_ROOT/config/builder.json"
else
    echo -e "${YELLOW}⚠${RESET}  Not found — run setup.sh"
fi

printf "  %-25s" "Signing keystore"
KEYSTORE="${ABP_ROOT}/config/dnyf-release.keystore"
if [[ -f "$KEYSTORE" ]]; then
    echo -e "${GREEN}✓${RESET}  $KEYSTORE"
else
    echo -e "${YELLOW}⚠${RESET}  Not found — run: abp keygen"
fi

# ── Summary ───────────────────────────────────────────────
echo ""
echo -e "${DIM}────────────────────────────────────────${RESET}"
echo -e "  ${GREEN}Passed  : $PASS${RESET}"
[[ $WARN -gt 0 ]] && echo -e "  ${YELLOW}Warnings: $WARN (optional tools)${RESET}"
[[ $FAIL -gt 0 ]] && echo -e "  ${RED}Failed  : $FAIL${RESET}"
echo ""

if [[ $FAIL -gt 0 ]]; then
    log_warn "Some required tools are missing. Install them and re-run: abp doctor"
else
    log_success "Environment looks good!"
fi
