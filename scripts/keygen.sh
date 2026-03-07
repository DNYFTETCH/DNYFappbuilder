#!/usr/bin/env bash
# DNYFappbuilder — Keystore Generator v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"
source "$ABP_ROOT/lib/signing.sh"

KEYSTORE="$DEFAULT_KEYSTORE"
ALIAS="$DEFAULT_ALIAS"
STOREPASS="$DEFAULT_STOREPASS"
ORG="DNYFTECH"
COUNTRY="NG"
CITY="Lagos"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --keystore) KEYSTORE="$2"; shift 2 ;;
        --alias)    ALIAS="$2";    shift 2 ;;
        --password) STOREPASS="$2"; shift 2 ;;
        --org)      ORG="$2";      shift 2 ;;
        --country)  COUNTRY="$2";  shift 2 ;;
        --city)     CITY="$2";     shift 2 ;;
        *) shift ;;
    esac
done

DNAME="CN=DNYFappbuilder, OU=Dev, O=$ORG, L=$CITY, S=$CITY, C=$COUNTRY"
generate_keystore "$KEYSTORE" "$ALIAS" "$STOREPASS" "$DNAME"

echo ""
log_info "Add to your config/builder.json:"
cat <<JSON
  "signing": {
    "keystore": "$KEYSTORE",
    "alias": "$ALIAS",
    "password": "$STOREPASS"
  }
JSON
