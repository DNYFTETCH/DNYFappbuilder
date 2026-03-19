#!/usr/bin/env bash
# DNYFappbuilder — Keystore Generator v2.1.0
# Generates keystore + encodes it for GitHub Actions secrets

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"

KEYSTORE="${ABP_ROOT}/config/dnyf-release.keystore"
ALIAS="abp-key"
STOREPASS="dnyf-release-2024"
DNAME="CN=DNYFappbuilder, OU=Dev, O=DNYFTECH, L=Lagos, ST=Lagos, C=NG"
VALIDITY=10000
CI_OUTPUT=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --keystore) KEYSTORE="$2"; shift 2 ;;
        --alias)    ALIAS="$2";    shift 2 ;;
        --password) STOREPASS="$2"; shift 2 ;;
        --dname)    DNAME="$2";    shift 2 ;;
        --ci)       CI_OUTPUT=true; shift ;;
        *) shift ;;
    esac
done

require keytool "Install JDK: pkg install openjdk-17"
mkdir -p "$(dirname "$KEYSTORE")"

# ── Check existing ────────────────────────────────────────
if [[ -f "$KEYSTORE" ]]; then
    log_warn "Keystore already exists: $KEYSTORE"
    echo -e "  ${DIM}Use --keystore <path> to specify a different location${RESET}"
    echo -e "  ${DIM}Delete the existing file to regenerate${RESET}"
    echo ""
    log_info "Keystore info:"
    keytool -list -keystore "$KEYSTORE" -storepass "$STOREPASS" -v 2>/dev/null | grep -E "Alias|Owner|Valid|SHA" | head -8
else
    # ── Generate ──────────────────────────────────────────
    log_step "Generating keystore: $KEYSTORE"
    keytool -genkey -v \
        -keystore "$KEYSTORE" \
        -alias "$ALIAS" \
        -keyalg RSA \
        -keysize 2048 \
        -validity "$VALIDITY" \
        -storepass "$STOREPASS" \
        -keypass "$STOREPASS" \
        -dname "$DNAME"

    log_success "Keystore generated: $KEYSTORE"
fi

# ── GitHub Actions secret output ─────────────────────────
echo ""
echo -e "${BOLD}GitHub Actions — Add these repository secrets:${RESET}"
echo -e "${DIM}Settings → Secrets → Actions → New repository secret${RESET}"
echo ""

echo -e "  ${CYAN}KEYSTORE_BASE64${RESET}"
echo -e "  ${DIM}Value:${RESET}"

B64=$(base64 "$KEYSTORE" 2>/dev/null | tr -d '\n')
if [[ ${#B64} -gt 80 ]]; then
    echo "  ${B64:0:60}...  ($(echo ${#B64}) chars)"
else
    echo "  $B64"
fi

echo ""
echo -e "  ${CYAN}KEY_ALIAS${RESET}        →  $ALIAS"
echo -e "  ${CYAN}KEY_PASSWORD${RESET}     →  $STOREPASS"
echo -e "  ${CYAN}STORE_PASSWORD${RESET}   →  $STOREPASS"

# ── Save secrets to file for easy copy ───────────────────
SECRETS_FILE="${ABP_ROOT}/config/github-secrets.txt"
{
    echo "# DNYFappbuilder — GitHub Actions Secrets"
    echo "# Generated: $(date)"
    echo "# Add these at: Settings → Secrets → Actions"
    echo ""
    echo "KEYSTORE_BASE64="
    base64 "$KEYSTORE" | tr -d '\n'
    echo ""
    echo ""
    echo "KEY_ALIAS=$ALIAS"
    echo "KEY_PASSWORD=$STOREPASS"
    echo "STORE_PASSWORD=$STOREPASS"
} > "$SECRETS_FILE"

echo ""
log_success "Secrets saved to: $SECRETS_FILE"
log_warn "Keep this file private — never commit it to git"
echo ""

# ── Add to .gitignore ─────────────────────────────────────
GITIGNORE="${ABP_ROOT}/../.gitignore"
if [[ -f "$GITIGNORE" ]]; then
    if ! grep -q "github-secrets.txt" "$GITIGNORE" 2>/dev/null; then
        echo "config/github-secrets.txt" >> "$GITIGNORE"
        echo "config/*.keystore" >> "$GITIGNORE"
        log_info "Added secrets + keystore to .gitignore"
    fi
fi

echo -e "${CYAN}Next:${RESET}"
echo "  1. cat $SECRETS_FILE"
echo "  2. Copy each value into GitHub → Settings → Secrets → Actions"
echo "  3. git tag v2.0.1 && git push origin v2.0.1  # triggers signed release"
echo ""
