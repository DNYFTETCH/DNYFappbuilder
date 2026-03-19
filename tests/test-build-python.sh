#!/usr/bin/env bash
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"
DEST="/tmp/_abp_build_python"
rm -rf "$DEST" 2>/dev/null || true

mkdir -p "$DEST/app"
cat > "$DEST/requirements.txt" << 'REQ'
fastapi==0.109.0
uvicorn[standard]==0.27.0
REQ

cat > "$DEST/app/main.py" << 'PY'
from fastapi import FastAPI
app = FastAPI()
@app.get("/health")
async def health():
    return {"status": "healthy"}
PY
touch "$DEST/app/__init__.py"

abp build "$DEST" 2>&1
BUILD_EXIT=$?

# Check build output exists
ls "$ABP_ROOT/builds/" | grep -q "$(basename "$DEST")" || { echo "FAIL: no build output found"; exit 1; }

rm -rf "$DEST"
echo "Build python test passed"
