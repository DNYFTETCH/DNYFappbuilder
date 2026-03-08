#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════╗
# ║    DNYFappbuilder v2.0.0 — Setup & Installation          ║
# ║    GitHub: https://github.com/DNYFTECH/dnyf-appbuilder    ║
# ╚══════════════════════════════════════════════════════════╝
set -Eeuo pipefail

# ── Config ────────────────────────────────────────────────
ABP_VERSION="2.0.0"
ABP_ROOT="${HOME}/dnyf-appbuilder"
CI_MODE=false
REINSTALL=false

# ── Colors ────────────────────────────────────────────────
RED='\e[1;31m'; GREEN='\e[1;32m'; YELLOW='\e[1;33m'
CYAN='\e[1;36m'; MAGENTA='\e[1;35m'; BOLD='\e[1m'; RESET='\e[0m'

# ── Parse flags ───────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --ci)          CI_MODE=true;    shift ;;
        --reinstall)   REINSTALL=true;  shift ;;
        --root)        ABP_ROOT="$2";   shift 2 ;;
        *) shift ;;
    esac
done

# In CI mode, always reinstall
$CI_MODE && REINSTALL=true

# ── Error handler ─────────────────────────────────────────
trap 'echo -e "\n${RED}Setup failed at line $LINENO${RESET}"; exit 1' ERR

# ── Banner ────────────────────────────────────────────────
echo -e "${MAGENTA}${BOLD}"
cat <<'BANNER'
 █████╗ ██████╗ ██████╗
██╔══██╗██╔══██╗██╔══██╗
███████║██████╔╝██████╔╝
██╔══██║██╔══██╗██╔═══╝
██║  ██║██████╔╝██║
╚═╝  ╚═╝╚═════╝ ╚═╝
BANNER
echo -e "${CYAN}DNYFappbuilder v${ABP_VERSION} — Setup${RESET}"
echo -e "${DIM:-}Multi-Language Build System with Device Install${RESET}"
echo ""

# ── Check existing install ────────────────────────────────
if [[ -d "$ABP_ROOT" ]] && ! $REINSTALL; then
    EXISTING_VERSION=$(grep 'VERSION=' "$ABP_ROOT/bin/abp" 2>/dev/null | head -1 | cut -d'"' -f2 || echo "unknown")
    if [[ "$EXISTING_VERSION" == "$ABP_VERSION" ]]; then
        echo -e "${GREEN}DNYFappbuilder v$ABP_VERSION is already installed at $ABP_ROOT${RESET}"
        echo "Run with --reinstall to force reinstall."
        exit 0
    fi
fi

echo -e "${CYAN}Installing to: ${BOLD}$ABP_ROOT${RESET}"

# ── Create directories ────────────────────────────────────
echo -e "\n${CYAN}[1/5] Creating directory structure...${RESET}"
mkdir -p "$ABP_ROOT"/{bin,lib,scripts/{deploy,completions},docker,config/{envs},plugins,k8s,logs,builds,.cache}

# ── Copy files ────────────────────────────────────────────
echo -e "${CYAN}[2/5] Installing files...${RESET}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -d "$SCRIPT_DIR/bin" ]]; then
    cp -r "$SCRIPT_DIR/bin" "$ABP_ROOT/"
    cp -r "$SCRIPT_DIR/lib" "$ABP_ROOT/"
    cp -r "$SCRIPT_DIR/scripts" "$ABP_ROOT/"
    cp -r "$SCRIPT_DIR/docker" "$ABP_ROOT/"
    cp -r "$SCRIPT_DIR/config" "$ABP_ROOT/"
    cp -r "$SCRIPT_DIR/k8s" "$ABP_ROOT/"
    [[ -d "$SCRIPT_DIR/plugins" ]] && cp -r "$SCRIPT_DIR/plugins" "$ABP_ROOT/" || true
    echo -e "${GREEN}✓ Files copied from: $SCRIPT_DIR${RESET}"
else
    echo -e "${RED}✗ Source directory not found: $SCRIPT_DIR${RESET}"
    exit 1
fi

# ── Set permissions ───────────────────────────────────────
echo -e "${CYAN}[3/5] Setting permissions...${RESET}"
chmod +x "$ABP_ROOT/bin/abp" 2>/dev/null || true
find "$ABP_ROOT/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
echo -e "${GREEN}✓ Permissions set${RESET}"

# ── Setup PATH ────────────────────────────────────────────
echo -e "${CYAN}[4/5] Configuring PATH...${RESET}"

export_line='export PATH="$PATH:$HOME/dnyf-appbuilder/bin"'
abp_root_line='export ABP_ROOT="$HOME/dnyf-appbuilder"'
completion_line="[[ -f \"\$HOME/dnyf-appbuilder/scripts/completions/bash-completion.sh\" ]] && source \"\$HOME/dnyf-appbuilder/scripts/completions/bash-completion.sh\""

for rc in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc" "$HOME/.profile"; do
    if [[ -f "$rc" ]]; then
        if ! grep -q "dnyf-appbuilder/bin" "$rc" 2>/dev/null; then
            {
                echo ""
                echo "# DNYFappbuilder"
                echo "$abp_root_line"
                echo "$export_line"
                echo "$completion_line"
            } >> "$rc"
            echo -e "${GREEN}✓ Updated $rc${RESET}"
        fi
    fi
done

# ── Termux-specific ───────────────────────────────────────
if [[ -n "${TERMUX_VERSION:-}" ]] || [[ -d "/data/data/com.termux" ]]; then
    echo ""
    echo -e "${CYAN}Termux detected — applying optimizations...${RESET}"
    # Termux doesn't need sudo, PATH is different
    for rc in "$HOME/.bashrc" "$PREFIX/etc/bash.bashrc"; do
        if [[ -f "$rc" ]] && ! grep -q "dnyf-appbuilder/bin" "$rc"; then
            echo "$export_line" >> "$rc"
        fi
    done
    echo -e "${GREEN}✓ Termux configured${RESET}"
fi

# ── Verify install ────────────────────────────────────────
echo -e "${CYAN}[5/5] Verifying installation...${RESET}"
export PATH="$PATH:$ABP_ROOT/bin"
export ABP_ROOT

if bash "$ABP_ROOT/bin/abp" version &>/dev/null; then
    echo -e "${GREEN}✓ ABP CLI working${RESET}"
else
    echo -e "${YELLOW}⚠ CLI verification failed — check PATH after shell reload${RESET}"
fi

# ── Done ──────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════╗"
echo -e "║   DNYFappbuilder v$ABP_VERSION installed!   ║"
echo -e "╚══════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${CYAN}Next steps:${RESET}"
echo "  1. source ~/.bashrc          # Reload shell"
echo "  2. abp version               # Verify install"
echo "  3. abp doctor                # Check environment"
echo "  4. abp init myapp react-native"
echo "  5. abp build myapp --target android --sign --install"
echo ""
echo -e "${CYAN}Key new commands:${RESET}"
echo "  abp devices                  # List connected devices"
echo "  abp install app.apk --all   # Install to all devices"
echo "  abp install app.apk --qr    # Wireless QR install"
echo "  abp sign app.apk --auto     # Auto-sign APK"
echo "  abp keygen                   # Generate keystore"
echo ""
echo -e "${DIM}GitHub: https://github.com/DNYFTECH/dnyf-appbuilder${RESET}"
