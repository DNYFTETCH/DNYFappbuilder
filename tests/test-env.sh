#!/usr/bin/env bash
# Test: env profile management
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"
mkdir -p "$ABP_ROOT/config/envs"
bash "$ABP_ROOT/scripts/env.sh" create test_profile_abp
[[ -f "$ABP_ROOT/config/envs/test_profile_abp.env" ]] || exit 1
bash "$ABP_ROOT/scripts/env.sh" list &>/dev/null
bash "$ABP_ROOT/scripts/env.sh" delete test_profile_abp <<< "y" 2>/dev/null || true
echo "Env test passed"
