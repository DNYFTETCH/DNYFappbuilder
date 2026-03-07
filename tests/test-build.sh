#!/usr/bin/env bash
# Test: build nodejs project
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"

cd /tmp
rm -rf _abp_build_test 2>/dev/null || true
mkdir -p _abp_build_test/src

# Create minimal package.json
cat > _abp_build_test/package.json <<'JSON'
{
  "name": "test-build",
  "version": "1.0.0",
  "main": "src/index.js",
  "scripts": { "start": "node src/index.js" }
}
JSON

echo 'console.log("ok")' > _abp_build_test/src/index.js

abp build _abp_build_test
rm -rf _abp_build_test
echo "Build test passed"
