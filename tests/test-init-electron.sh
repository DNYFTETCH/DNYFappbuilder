#!/usr/bin/env bash
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
DEST="/tmp/_abp_test_electron"
rm -rf "$DEST" 2>/dev/null || true

bash "$ABP_ROOT/scripts/init.sh" _abp_test_electron electron "$DEST"

[ -f "$DEST/package.json" ]      || { echo "FAIL: package.json missing"; exit 1; }
[ -f "$DEST/src/main.js" ]       || { echo "FAIL: src/main.js missing"; exit 1; }
[ -f "$DEST/src/preload.js" ]    || { echo "FAIL: src/preload.js missing"; exit 1; }
[ -f "$DEST/src/index.html" ]    || { echo "FAIL: src/index.html missing"; exit 1; }
grep -q "electron" "$DEST/package.json" || { echo "FAIL: electron not in package.json"; exit 1; }

rm -rf "$DEST"
echo "Init electron test passed"
