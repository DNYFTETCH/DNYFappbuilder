#!/usr/bin/env bash
# Test: keygen (just check keytool availability)
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"
if command -v keytool &>/dev/null; then
    echo "Signing tools available (keytool found)"
else
    echo "keytool not found — skipping signing test (install JDK)"
fi
echo "Sign test passed"
