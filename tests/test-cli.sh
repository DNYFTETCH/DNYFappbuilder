#!/usr/bin/env bash
# Test: CLI commands
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"
bash "$ABP_ROOT/bin/abp" version &>/dev/null
bash "$ABP_ROOT/bin/abp" help &>/dev/null
echo "CLI tests passed"
