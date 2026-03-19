#!/usr/bin/env bash
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
DEST="/tmp/_abp_test_react"
rm -rf "$DEST" 2>/dev/null || true

bash "$ABP_ROOT/scripts/init.sh" _abp_test_react react "$DEST"

[ -f "$DEST/package.json" ]     || { echo "FAIL: package.json missing"; exit 1; }
[ -f "$DEST/vite.config.js" ]   || { echo "FAIL: vite.config.js missing"; exit 1; }
[ -f "$DEST/index.html" ]       || { echo "FAIL: index.html missing"; exit 1; }
[ -f "$DEST/src/main.jsx" ]     || { echo "FAIL: src/main.jsx missing"; exit 1; }
[ -f "$DEST/src/App.jsx" ]      || { echo "FAIL: src/App.jsx missing"; exit 1; }
grep -q "vite" "$DEST/package.json" || { echo "FAIL: vite not in package.json"; exit 1; }
grep -q "react" "$DEST/package.json" || { echo "FAIL: react not in package.json"; exit 1; }

rm -rf "$DEST"
echo "Init react test passed"
