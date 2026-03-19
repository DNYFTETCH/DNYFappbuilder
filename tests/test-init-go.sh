#!/usr/bin/env bash
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
DEST="/tmp/_abp_test_go"
rm -rf "$DEST" 2>/dev/null || true

bash "$ABP_ROOT/scripts/init.sh" _abp_test_go go "$DEST"

[ -f "$DEST/go.mod" ]                  || { echo "FAIL: go.mod missing"; exit 1; }
[ -f "$DEST/cmd/server/main.go" ]      || { echo "FAIL: cmd/server/main.go missing"; exit 1; }
[ -f "$DEST/Makefile" ]                || { echo "FAIL: Makefile missing"; exit 1; }
grep -q "module" "$DEST/go.mod"        || { echo "FAIL: go.mod has no module"; exit 1; }

rm -rf "$DEST"
echo "Init go test passed"
