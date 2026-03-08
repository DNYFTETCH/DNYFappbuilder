#!/usr/bin/env bash
# Test: env profile management (no interactive prompts)
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"

mkdir -p "$ABP_ROOT/config/envs"

# Test create
bash "$ABP_ROOT/scripts/env.sh" create _test_ci_profile
[[ -f "$ABP_ROOT/config/envs/_test_ci_profile.env" ]] || { echo "Create failed"; exit 1; }

# Test list
bash "$ABP_ROOT/scripts/env.sh" list | grep -q "_test_ci_profile" || { echo "List failed"; exit 1; }

# Test show
bash "$ABP_ROOT/scripts/env.sh" show _test_ci_profile | grep -q "NODE_ENV" || { echo "Show failed"; exit 1; }

# Test apply
bash "$ABP_ROOT/scripts/env.sh" apply _test_ci_profile /tmp
[[ -f "/tmp/.env" ]] || { echo "Apply failed"; exit 1; }

# Cleanup without confirm prompt (direct rm)
rm -f "$ABP_ROOT/config/envs/_test_ci_profile.env" /tmp/.env

echo "Env test passed"