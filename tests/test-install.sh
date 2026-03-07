#!/usr/bin/env bash
# Test: install script validation (no device needed)
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"

# Should fail with "file not found" not a script error
OUTPUT=$(bash "$ABP_ROOT/scripts/install.sh" /tmp/nonexistent.apk 2>&1 || true)
echo "$OUTPUT" | grep -q "not found" && echo "Install validation test passed" || exit 1
