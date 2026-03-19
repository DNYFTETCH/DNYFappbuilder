#!/usr/bin/env bash
# DNYFappbuilder — One-liner Installer v2.1.0
# Usage: curl -fsSL https://raw.githubusercontent.com/DNYFTETCH/DNYFappbuilder/main/install.sh | bash
set -Eeuo pipefail

REPO="https://github.com/DNYFTETCH/DNYFappbuilder"
VERSION="2.0.0"
INSTALL_DIR="${HOME}/dnyf-appbuilder"

# Colors
RED=$'\e[1;31m'; GREEN=$'\e[1;32m'; CYAN=$'\e[1;36m'
MAGENTA=$'\e[1;35m'; BOLD=$'\e[1m'; DIM=$'\e[2m'; RESET=$'\e[0m'

echo -e "${MAGENTA}${BOLD}"
cat << 'BANNER'
 █████╗ ██████╗ ██████╗
██╔══██╗██╔══██╗██╔══██╗
███████║██████╔╝██████╔╝
██╔══██║██╔══██╗██╔═══╝
██║  ██║██████╔╝██║
╚═╝  ╚═╝╚═════╝ ╚═╝
BANNER
echo -e "${CYAN}DNYFappbuilder v${VERSION} Installer${RESET}"
echo ""

# ── Detect environment ────────────────────────────────────
IS_TERMUX=false
IS_MACOS=false
IS_LINUX=false
[[ -n "${TERMUX_VERSION:-}" ]] || [[ -d "/data/data/com.termux" ]] && IS_TERMUX=true
[[ "$(uname -s)" == "Darwin" ]] && IS_MACOS=true
[[ "$(uname -s)" == "Linux" ]] && ! $IS_TERMUX && IS_LINUX=true

echo -e "${DIM}Platform : $(uname -s) $($IS_TERMUX && echo '(Termux)' || true)${RESET}"

# ── Homebrew path (macOS / Linux) ─────────────────────────
if ! $IS_TERMUX && command -v brew &>/dev/null; then
    echo ""
    echo -e "${CYAN}Homebrew detected — installing via tap (recommended)${RESET}"
    echo ""
    brew tap DNYFTETCH/tap 2>/dev/null || true
    brew install DNYFTETCH/tap/abp
    echo ""
    echo -e "${GREEN}${BOLD}✓ Installed via Homebrew${RESET}"
    echo -e "  Run: ${CYAN}abp doctor${RESET}"
    exit 0
fi

# ── Git clone install (Termux + non-brew systems) ─────────
echo -e "${DIM}Install dir: ${BOLD}$INSTALL_DIR${RESET}"
echo ""

# Check dependencies
command -v git  &>/dev/null || { echo -e "${RED}git required: pkg install git${RESET}"; exit 1; }
command -v bash &>/dev/null || { echo -e "${RED}bash required${RESET}"; exit 1; }

# Backup existing install
if [[ -d "$INSTALL_DIR" ]]; then
    BACKUP="${INSTALL_DIR}.backup.$(date +%s)"
    echo -e "${DIM}Backing up: $BACKUP${RESET}"
    mv "$INSTALL_DIR" "$BACKUP"
fi

# Clone and install
echo -e "${CYAN}Cloning DNYFappbuilder...${RESET}"
git clone --depth 1 "$REPO.git" "$INSTALL_DIR"

cd "$INSTALL_DIR"
chmod +x setup.sh
bash setup.sh

echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════╗"
echo -e "║   DNYFappbuilder v${VERSION} installed!      ║"
echo -e "╚══════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${CYAN}source ~/.bashrc${RESET}   # reload shell"
echo -e "  ${CYAN}abp doctor${RESET}         # check environment"
echo -e "  ${CYAN}abp doctor --fix${RESET}   # auto-install missing tools"
