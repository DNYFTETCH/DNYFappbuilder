#!/usr/bin/env bash
# DNYFappbuilder — Doctor v2.1.0 (with auto-fix)

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"

# ── Auto-fix flag ─────────────────────────────────────────
FIX_MODE=false
[[ "${1:-}" == "--fix" ]] && FIX_MODE=true

PASS=0; WARN=0; FAIL=0
MISSING_REQUIRED=()
MISSING_OPTIONAL=()

# ── Detect package manager ────────────────────────────────
detect_pkg_manager() {
    if is_termux; then           echo "termux"
    elif command -v apt &>/dev/null; then echo "apt"
    elif command -v brew &>/dev/null; then echo "brew"
    elif command -v dnf &>/dev/null; then echo "dnf"
    elif command -v pacman &>/dev/null; then echo "pacman"
    else                         echo "unknown"
    fi
}

PKG_MGR=$(detect_pkg_manager)

# ── Install a tool ────────────────────────────────────────
install_tool() {
    local pkg_termux="$1" pkg_apt="$2" pkg_brew="$3" pkg_npm="${4:-}"
    case "$PKG_MGR" in
        termux)  pkg install -y "$pkg_termux" ;;
        apt)     sudo apt-get install -y "$pkg_apt" ;;
        brew)    brew install "$pkg_brew" ;;
        dnf)     sudo dnf install -y "$pkg_apt" ;;
        pacman)  sudo pacman -S --noconfirm "$pkg_apt" ;;
        *)
            if [[ -n "$pkg_npm" ]]; then npm install -g "$pkg_npm"
            else log_error "Cannot auto-install: unknown package manager"; return 1; fi
            ;;
    esac
}

# ── Check function ────────────────────────────────────────
check() {
    local label="$1" cmd="$2" hint="${3:-}" \
          pkg_termux="${4:-}" pkg_apt="${5:-}" pkg_brew="${6:-}" pkg_npm="${7:-}"
    printf "  %-26s" "$label"
    if eval "$cmd" &>/dev/null 2>&1; then
        local ver; ver=$(eval "$cmd" 2>/dev/null | head -1 | cut -c1-36)
        echo -e "${GREEN}✓${RESET}  $ver"
        PASS=$(( PASS + 1 ))
    else
        echo -e "${RED}✗${RESET}  Not found"
        [[ -n "$hint" ]] && echo -e "    ${DIM}→ $hint${RESET}"
        FAIL=$(( FAIL + 1 ))
        MISSING_REQUIRED+=("$label|$cmd|$pkg_termux|$pkg_apt|$pkg_brew|$pkg_npm")
    fi
}

check_warn() {
    local label="$1" cmd="$2" hint="${3:-}" \
          pkg_termux="${4:-}" pkg_apt="${5:-}" pkg_brew="${6:-}" pkg_npm="${7:-}"
    printf "  %-26s" "$label"
    if eval "$cmd" &>/dev/null 2>&1; then
        local ver; ver=$(eval "$cmd" 2>/dev/null | head -1 | cut -c1-36)
        echo -e "${GREEN}✓${RESET}  $ver"
        PASS=$(( PASS + 1 ))
    else
        echo -e "${YELLOW}⚠${RESET}  Not found (optional)"
        [[ -n "$hint" ]] && echo -e "    ${DIM}→ $hint${RESET}"
        WARN=$(( WARN + 1 ))
        MISSING_OPTIONAL+=("$label|$cmd|$pkg_termux|$pkg_apt|$pkg_brew|$pkg_npm")
    fi
}

# ── Auto-fix function ─────────────────────────────────────
do_fix() {
    local items=("$@")
    if [[ ${#items[@]} -eq 0 ]]; then
        log_info "Nothing to fix."
        return
    fi
    echo ""
    log_info "Auto-installing ${#items[@]} missing tool(s) via: ${BOLD}$PKG_MGR${RESET}"
    echo ""

    for entry in "${items[@]}"; do
        IFS='|' read -r label cmd pkg_termux pkg_apt pkg_brew pkg_npm <<< "$entry"
        printf "  Installing %-20s ... " "$label"
        if install_tool "$pkg_termux" "$pkg_apt" "$pkg_brew" "$pkg_npm" &>/dev/null 2>&1; then
            echo -e "${GREEN}✓ done${RESET}"
        else
            echo -e "${RED}✗ failed — install manually${RESET}"
        fi
    done
}

# ── Header ───────────────────────────────────────────────
echo ""
echo -e "${BOLD}DNYFappbuilder — Doctor v2.1.0${RESET}"
$FIX_MODE && echo -e "${CYAN}Auto-fix mode enabled${RESET}"
echo -e "${DIM}Checking environment...${RESET}"
echo ""

# ── Core Tools ───────────────────────────────────────────
echo -e "${CYAN}Core Tools${RESET}"
check      "Bash 4+"         "bash --version"    ""                                    "bash"      "bash"      "bash"
check      "Git"             "git --version"     "pkg install git"                     "git"       "git"       "git"
check      "curl"            "curl --version"    "pkg install curl"                    "curl"      "curl"      "curl"
check      "jq"              "jq --version"      "pkg install jq"                      "jq"        "jq"        "jq"

# ── Build Runtimes ────────────────────────────────────────
echo ""
echo -e "${CYAN}Build Runtimes${RESET}"
check      "Node.js"         "node --version"    "pkg install nodejs"                  "nodejs"    "nodejs"    "node"
check      "npm"             "npm --version"     "comes with Node.js"                  "nodejs"    "npm"       "node"
check      "Python 3"        "python3 --version" "pkg install python"                  "python"    "python3"   "python3"
check      "pip3"            "pip3 --version"    "pkg install python"                  "python"    "python3-pip" "python3"
check      "Java (JDK)"      "java -version"     "pkg install openjdk-17"              "openjdk-17" "default-jdk" "openjdk@17"
check_warn "Flutter"         "flutter --version" "https://flutter.dev"                 ""          ""          ""
check_warn "Gradle"          "gradle --version"  "pkg install gradle"                  "gradle"    "gradle"    "gradle"
check_warn "Kotlin"          "kotlin -version"   "pkg install kotlin"                  "kotlin"    "kotlin"    "kotlin"

# ── Android Tools ─────────────────────────────────────────
echo ""
echo -e "${CYAN}Android Tools${RESET}"
check      "ADB"             "adb --version"     "pkg install android-tools"           "android-tools" "adb"   "android-platform-tools"
check_warn "apksigner"       "apksigner --version" "Android SDK build-tools"           ""          ""          ""
check_warn "zipalign"        "zipalign --version"  "Android SDK build-tools"           ""          ""          ""
check_warn "keytool"         "keytool -help"     "part of JDK"                         "openjdk-17" "default-jdk" "openjdk@17"
check_warn "qrencode"        "qrencode --version" "pkg install qrencode"              "qrencode"  "qrencode"  "qrencode"

# ── iOS Tools ─────────────────────────────────────────────
echo ""
echo -e "${CYAN}iOS Tools${RESET}"
if is_macos; then
    check_warn "xcrun"       "xcrun --version"         "Install Xcode"                 ""  ""  ""
    check_warn "ios-deploy"  "ios-deploy --version"    "npm install -g ios-deploy"     ""  ""  ""  "ios-deploy"
    check_warn "idevice_id"  "idevice_id --version"    "brew install libimobiledevice" ""  "libimobiledevice" "libimobiledevice"
else
    echo -e "  ${DIM}iOS tools require macOS — skipped${RESET}"
fi

# ── DevOps / Deploy ───────────────────────────────────────
echo ""
echo -e "${CYAN}DevOps / Deploy${RESET}"
check_warn "Docker"          "docker --version"      "https://docker.com"              ""          ""          ""
check_warn "docker compose"  "docker compose version" "included with Docker"           ""          ""          ""
check_warn "Railway CLI"     "railway --version"     "npm install -g @railway/cli"     ""          ""          ""  "@railway/cli"
check_warn "Vercel CLI"      "vercel --version"      "npm install -g vercel"           ""          ""          ""  "vercel"
check_warn "Heroku CLI"      "heroku --version"      "https://devcenter.heroku.com"    ""          ""          ""
check_warn "gh (GitHub CLI)" "gh --version"          "pkg install gh"                  "gh"        "gh"        "gh"
check_warn "rsync"           "rsync --version"       "pkg install rsync"               "rsync"     "rsync"     "rsync"

# ── Notifications ─────────────────────────────────────────
echo ""
echo -e "${CYAN}Notifications & Extras${RESET}"
check_warn "termux-notification" "termux-notification --help" "Install Termux:API from F-Droid" "" "" ""
check_warn "openssh"         "ssh -V"                "pkg install openssh"             "openssh"   "openssh-client" "openssh"
check_warn "python-uvicorn"  "uvicorn --version"     "pip3 install uvicorn"            ""          ""          ""

# ── Termux extras ─────────────────────────────────────────
if is_termux; then
    echo ""
    echo -e "${CYAN}Termux Environment${RESET}"
    echo -e "  ${GREEN}✓${RESET}  Termux v${TERMUX_VERSION:-detected}"
    check_warn "Termux:API"  "termux-battery-status" "Install Termux:API from F-Droid" "" "" ""
    check_warn "proot-distro" "proot-distro list"    "pkg install proot-distro"        "proot-distro" "" ""
fi

# ── ABP install health ────────────────────────────────────
echo ""
echo -e "${CYAN}DNYFappbuilder Install${RESET}"
printf "  %-26s" "ABP Root"
[[ -d "$ABP_ROOT" ]] && echo -e "${GREEN}✓${RESET}  $ABP_ROOT" || echo -e "${RED}✗${RESET}  Missing — run setup.sh"

printf "  %-26s" "Config"
[[ -f "$ABP_ROOT/config/builder.json" ]] && echo -e "${GREEN}✓${RESET}  Found" || echo -e "${YELLOW}⚠${RESET}  Missing — run setup.sh"

printf "  %-26s" "Keystore"
KEYSTORE="$ABP_ROOT/config/dnyf-release.keystore"
[[ -f "$KEYSTORE" ]] && echo -e "${GREEN}✓${RESET}  Found" || echo -e "${YELLOW}⚠${RESET}  Not found — run: abp keygen"

# ── Summary ───────────────────────────────────────────────
echo ""
echo -e "${DIM}────────────────────────────────────────${RESET}"
echo -e "  ${GREEN}Passed  : $PASS${RESET}"
[[ $WARN -gt 0 ]] && echo -e "  ${YELLOW}Optional: $WARN (not required)${RESET}"
[[ $FAIL -gt 0 ]] && echo -e "  ${RED}Missing : $FAIL (required)${RESET}"
echo ""

# ── Auto-fix or suggest ───────────────────────────────────
if [[ $FAIL -gt 0 ]] || [[ $WARN -gt 0 ]]; then
    if $FIX_MODE; then
        [[ ${#MISSING_REQUIRED[@]} -gt 0 ]] && do_fix "${MISSING_REQUIRED[@]}"
        [[ ${#MISSING_OPTIONAL[@]} -gt 0 ]] && do_fix "${MISSING_OPTIONAL[@]}"
        echo ""
        log_success "Auto-fix complete — re-running check..."
        echo ""
        exec bash "$ABP_ROOT/scripts/doctor.sh"
    else
        if [[ $FAIL -gt 0 ]]; then
            log_warn "$FAIL required tool(s) missing."
            echo -e "  ${CYAN}Run: ${BOLD}abp doctor --fix${RESET}${CYAN} to install them automatically${RESET}"
        else
            log_success "All required tools present. $WARN optional tool(s) available."
            echo -e "  ${CYAN}Run: ${BOLD}abp doctor --fix${RESET}${CYAN} to install optional tools${RESET}"
        fi
    fi
else
    log_success "Environment is fully configured!"
fi
echo ""
