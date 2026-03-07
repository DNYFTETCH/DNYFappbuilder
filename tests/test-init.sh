#!/usr/bin/env bash
# Test: project init (nodejs — fastest to init)
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"
cd /tmp
rm -rf _abp_test_node 2>/dev/null || true
abp init _abp_test_node nodejs
[[ -f "_abp_test_node/src/index.js" ]] || exit 1
[[ -f "_abp_test_node/package.json" ]] || exit 1
rm -rf _abp_test_node
echo "Init test passed"
