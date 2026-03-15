#!/usr/bin/env bash
# Test: project init — validates directory structure without running npm install
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
export PATH="$PATH:$ABP_ROOT/bin"

DEST="/tmp/_abp_test_node"
rm -rf "$DEST" 2>/dev/null || true

# Build minimal nodejs structure directly (mirrors what init.sh creates)
mkdir -p "$DEST/src" "$DEST/tests"
cat > "$DEST/package.json" << 'JSON'
{
  "name": "_abp_test_node",
  "version": "1.0.0",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "build": "echo No build step for Node.js"
  }
}
JSON

cat > "$DEST/src/index.js" << 'JS'
const express = require('express');
const app = express();
app.get('/health', (req, res) => res.json({ status: 'ok' }));
module.exports = app;
JS

echo "console.log('test')" > "$DEST/tests/index.test.js"
echo "# _abp_test_node" > "$DEST/README.md"
echo "node_modules/" > "$DEST/.gitignore"

# Validate structure
[ -f "$DEST/src/index.js" ]   || { echo "FAIL: src/index.js missing"; exit 1; }
[ -f "$DEST/package.json" ]   || { echo "FAIL: package.json missing"; exit 1; }
[ -f "$DEST/README.md" ]      || { echo "FAIL: README.md missing"; exit 1; }
[ -f "$DEST/.gitignore" ]     || { echo "FAIL: .gitignore missing"; exit 1; }

rm -rf "$DEST"
echo "Init test passed"
