#!/usr/bin/env bash
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
DEST="/tmp/_abp_test_python"
rm -rf "$DEST" 2>/dev/null || true

bash "$ABP_ROOT/scripts/init.sh" _abp_test_python python "$DEST"

[ -f "$DEST/requirements.txt" ]    || { echo "FAIL: requirements.txt missing"; exit 1; }
[ -f "$DEST/app/main.py" ]         || { echo "FAIL: app/main.py missing"; exit 1; }
[ -f "$DEST/main.py" ]             || { echo "FAIL: main.py missing"; exit 1; }
[ -f "$DEST/.env" ]                || { echo "FAIL: .env missing"; exit 1; }
grep -q "fastapi" "$DEST/requirements.txt" || { echo "FAIL: fastapi not in requirements.txt"; exit 1; }

rm -rf "$DEST"
echo "Init python test passed"
