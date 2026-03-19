#!/usr/bin/env bash
# DNYFappbuilder — One-liner Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/DNYFTECH/DNYFappbuilder/main/install.sh | bash
set -Eeuo pipefail

REPO="https://github.com/DNYFTECH/DNYFappbuilder"
RAW="https://raw.githubusercontent.com/DNYFTECH/DNYFappbuilder/main"
INSTALL_DIR="${HOME}/dnyf-appbuilder"
VERSION="2.0.0"

# Colors
RED=$'\e[1;31m'; GREEN=$'\e[1;32m'; CYAN=$'\e[1;36m'; MAGENTA=$'\e[1;35m'
BOLD=$'\e[1m'; RESET=$'\e[0m'

echo -e "${MAGENTA}${BOLD}"
cat <<'BANNER'
 ██████╗ ███╗   ██╗██╗   ██╗███████╗
 ██╔══██╗████╗  ██║╚██╗ ██╔╝██╔════╝
 ██║  ██║██╔██╗ ██║ ╚████╔╝ █████╗
 ██║  ██║██║╚██╗██║  ╚██╔╝  ██╔══╝
 ██████╔╝██║ ╚████║   ██║   ██║
 ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝
BANNER
echo -e "${CYAN}DNYFappbuilder v${VERSION} Installer${RESET}"
echo ""

# ── Check dependencies ────────────────────────────────────
need() {
    command -v "$1" &>/dev/null || { echo -e "${RED}Missing: $1 — install it first${RESET}"; exit 1; }
}

need git
need bash

# ── Detect environment ────────────────────────────────────
IS_TERMUX=false
[[ -n "${TERMUX_VERSION:-}" ]] || [[ -d "/data/data/com.termux" ]] && IS_TERMUX=true

echo -e "${CYAN}Environment : $(uname -s) $($IS_TERMUX && echo '(Termux)' || true)${RESET}"
echo -e "${CYAN}Install dir : ${BOLD}$INSTALL_DIR${RESET}"
echo ""

# ── Backup existing install ───────────────────────────────
if [[ -d "$INSTALL_DIR" ]]; then
    BACKUP="${INSTALL_DIR}.backup.$(date +%s)"
    echo -e "${CYAN}Backing up existing install → $BACKUP${RESET}"
    mv "$INSTALL_DIR" "$BACKUP"
fi

# ── Clone repo ────────────────────────────────────────────
echo -e "${CYAN}Cloning DNYFappbuilder...${RESET}"
git clone --depth 1 "$REPO.git" "$INSTALL_DIR"

# ── Run setup ─────────────────────────────────────────────
cd "$INSTALL_DIR"
chmod +x setup.sh
bash setup.sh

echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════╗"
echo -e "║   DNYFappbuilder installed!              ║"
echo -e "╚══════════════════════════════════════════╝${RESET}"
echo ""
echo -e "Run: ${CYAN}source ~/.bashrc && abp doctor${RESET}"
