#!/usr/bin/env bash
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
DEST="/tmp/_abp_test_vue"
rm -rf "$DEST" 2>/dev/null || true

bash "$ABP_ROOT/scripts/init.sh" _abp_test_vue vue "$DEST"

[ -f "$DEST/package.json" ]     || { echo "FAIL: package.json missing"; exit 1; }
[ -f "$DEST/vite.config.js" ]   || { echo "FAIL: vite.config.js missing"; exit 1; }
[ -f "$DEST/index.html" ]       || { echo "FAIL: index.html missing"; exit 1; }
[ -f "$DEST/src/main.js" ]      || { echo "FAIL: src/main.js missing"; exit 1; }
[ -f "$DEST/src/App.vue" ]      || { echo "FAIL: src/App.vue missing"; exit 1; }
grep -q "vue" "$DEST/package.json" || { echo "FAIL: vue not in package.json"; exit 1; }

rm -rf "$DEST"
echo "Init vue test passed"
