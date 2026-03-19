#!/usr/bin/env bash
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"
DEST="/tmp/_abp_build_react"
rm -rf "$DEST" 2>/dev/null || true

mkdir -p "$DEST/src"
cat > "$DEST/package.json" << 'JSON'
{
  "name": "test-react-build",
  "version": "0.0.1",
  "type": "module",
  "scripts": { "build": "echo vite-build-ok" }
}
JSON
cat > "$DEST/vite.config.js" << 'VITE'
export default {}
VITE
echo 'export default function App() { return null }' > "$DEST/src/App.jsx"

abp build "$DEST" 2>&1
ls "$ABP_ROOT/builds/" | grep -q "$(basename "$DEST")" || { echo "FAIL: no build output"; exit 1; }

rm -rf "$DEST"
echo "Build react test passed"
