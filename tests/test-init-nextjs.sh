#!/usr/bin/env bash
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
DEST="/tmp/_abp_test_nextjs"
rm -rf "$DEST" 2>/dev/null || true

bash "$ABP_ROOT/scripts/init.sh" _abp_test_nextjs nextjs "$DEST"

[ -f "$DEST/package.json" ]          || { echo "FAIL: package.json missing"; exit 1; }
[ -f "$DEST/next.config.mjs" ]       || { echo "FAIL: next.config.mjs missing"; exit 1; }
[ -f "$DEST/app/page.tsx" ]          || { echo "FAIL: app/page.tsx missing"; exit 1; }
[ -f "$DEST/app/layout.tsx" ]        || { echo "FAIL: app/layout.tsx missing"; exit 1; }
[ -f "$DEST/app/api/health/route.ts" ] || { echo "FAIL: API route missing"; exit 1; }
grep -q "next" "$DEST/package.json"  || { echo "FAIL: next not in package.json"; exit 1; }

rm -rf "$DEST"
echo "Init nextjs test passed"
