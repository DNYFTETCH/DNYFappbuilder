#!/usr/bin/env bash
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"
bash "$ABP_ROOT/bin/abp" help &>/dev/null
echo "Help test passed"
