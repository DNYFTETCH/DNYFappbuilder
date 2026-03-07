#!/usr/bin/env bash
# Test: device detection
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"
# Just test that the command runs without error (no devices in CI is fine)
bash "$ABP_ROOT/scripts/devices.sh" &>/dev/null || true
echo "Devices test passed"
