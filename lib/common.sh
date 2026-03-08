#!/usr/bin/env bash
# DNYFappbuilder — Common Library v2.0.0

# ── Colors ────────────────────────────────────────────────
export RED='\e[1;31m'
export GREEN='\e[1;32m'
export YELLOW='\e[1;33m'
export CYAN='\e[1;36m'
export MAGENTA='\e[1;35m'
export BLUE='\e[1;34m'
export BOLD='\e[1m'
export DIM='\e[2m'
export RESET='\e[0m'

# ── Logging ───────────────────────────────────────────────
ABP_LOG_DIR="${ABP_LOG_DIR:-$HOME/dnyf-appbuilder/logs}"
ABP_LOG_FILE="${ABP_LOG_DIR}/build.log"
mkdir -p "$ABP_LOG_DIR" 2>/dev/null || true

_log() {
    local level="$1" color="$2" label="$3"; shift 3
    local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
    local msg="$*"
    echo -e "${color}[${label}]${RESET} $msg"
    echo "[$ts] [$level] $msg" >> "$ABP_LOG_FILE" 2>/dev/null || true
}

log_info()    { _log INFO    "$CYAN"    "INFO"    "$@"; }
log_success() { _log SUCCESS "$GREEN"   "SUCCESS" "$@"; }
log_warn()    { _log WARN    "$YELLOW"  "WARN"    "$@"; }
log_error()   { _log ERROR   "$RED"     "ERROR"   "$@"; }
log_step()    { _log STEP    "$MAGENTA" "STEP"    "$@"; }
log_debug()   { [[ "${ABP_DEBUG:-0}" == "1" ]] && _log DEBUG "$DIM" "DEBUG" "$@" || true; }

# ── Utilities ─────────────────────────────────────────────
command_exists()  { command -v "$1" &>/dev/null; }
timestamp()       { date '+%Y-%m-%d_%H-%M-%S'; }
ensure_dir()      { mkdir -p "$1" 2>/dev/null || true; }
file_size()       { du -sh "$1" 2>/dev/null | cut -f1; }
is_termux()       { [[ -n "${TERMUX_VERSION:-}" ]] || [[ -d "/data/data/com.termux" ]]; }
is_macos()        { [[ "$(uname)" == "Darwin" ]]; }
is_linux()        { [[ "$(uname)" == "Linux" ]]; }

# ── Require tool ──────────────────────────────────────────
require() {
    local tool="$1" install_hint="${2:-}"
    if ! command_exists "$tool"; then
        log_error "Required tool not found: ${BOLD}$tool${RESET}"
        [[ -n "$install_hint" ]] && echo -e "  Install with: ${CYAN}$install_hint${RESET}"
        exit 1
    fi
}

# ── Timer ─────────────────────────────────────────────────
_TIMER_START=0
timer_start() { _TIMER_START=$(date +%s); }
timer_elapsed() {
    local end; end=$(date +%s)
    local elapsed=$(( end - _TIMER_START ))
    echo "${elapsed}s"
}

# ── Progress spinner ──────────────────────────────────────
_SPINNER_PID=""
spinner_start() {
    local msg="${1:-Working...}"
    local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    (
        i=0
        while true; do
            printf "\r${CYAN}${frames:$i:1}${RESET} %s" "$msg"
            i=$(( (i+1) % ${#frames} ))
            sleep 0.1
        done
    ) &
    _SPINNER_PID=$!
}
spinner_stop() {
    if [[ -n "$_SPINNER_PID" ]]; then
        kill "$_SPINNER_PID" 2>/dev/null || true
        wait "$_SPINNER_PID" 2>/dev/null || true
        _SPINNER_PID=""
        printf "\r\033[K"
    fi
}

# ── Confirm prompt ────────────────────────────────────────
confirm() {
    local msg="${1:-Continue?}"
    echo -e -n "${YELLOW}$msg [y/N]: ${RESET}"
    read -r reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

# ── Config reader ─────────────────────────────────────────
config_get() {
    local key="$1" default="${2:-}"
    local cfg="${ABP_CONFIG:-$HOME/dnyf-appbuilder/config/builder.json}"
    if command_exists jq && [[ -f "$cfg" ]]; then
        jq -r "$key // empty" "$cfg" 2>/dev/null || echo "$default"
    else
        echo "$default"
    fi
}

# ── Check internet ────────────────────────────────────────
check_internet() {
    ping -c1 -W2 8.8.8.8 &>/dev/null || curl -sf --connect-timeout 3 https://google.com &>/dev/null
}

# ── Build log header ──────────────────────────────────────
log_build_header() {
    local project="$1" type="$2"
    {
        echo "════════════════════════════════════════"
        echo "  DNYFappbuilder — Build Log"
        echo "  Project : $project"
        echo "  Type    : $type"
        echo "  Date    : $(date)"
        echo "════════════════════════════════════════"
    } >> "$ABP_LOG_FILE" 2>/dev/null || true
}

# ── ADB helpers (re-exported for use in scripts) ──────────
adb_devices_list() {
    adb devices 2>/dev/null | grep -v "^List" | grep -v "^$" | awk '{print $1}' | grep -v "^$"
}

adb_device_model() {
    local serial="$1"
    adb -s "$serial" shell getprop ro.product.model 2>/dev/null | tr -d '\r'
}

adb_device_android() {
    local serial="$1"
    adb -s "$serial" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r'
}