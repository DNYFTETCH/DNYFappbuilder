#!/usr/bin/env bash
# Test: doctor command
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"
bash "$ABP_ROOT/scripts/doctor.sh" &>/dev/null
echo "Doctor test passed"
