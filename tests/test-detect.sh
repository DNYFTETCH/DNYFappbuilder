#!/usr/bin/env bash
export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/detect.sh"

fail() { echo "FAIL: $1 detected as $2, expected $3"; exit 1; }
pass() { : ; }

# Test nodejs
D=$(mktemp -d)
echo '{"name":"test"}' > "$D/package.json"
[[ "$(detect_project_type "$D")" == "nodejs" ]] && pass || fail "plain package.json" "$(detect_project_type "$D")" "nodejs"
rm -rf "$D"

# Test react
D=$(mktemp -d)
echo '{"dependencies":{"react":"^18","vite":"^5"}}' > "$D/package.json"
touch "$D/vite.config.js"
[[ "$(detect_project_type "$D")" == "react" ]] && pass || fail "react+vite" "$(detect_project_type "$D")" "react"
rm -rf "$D"

# Test vue
D=$(mktemp -d)
echo '{"dependencies":{"vue":"^3"}}' > "$D/package.json"
touch "$D/vite.config.js"
[[ "$(detect_project_type "$D")" == "vue" ]] && pass || fail "vue+vite" "$(detect_project_type "$D")" "vue"
rm -rf "$D"

# Test python fastapi
D=$(mktemp -d)
echo "fastapi==0.109.0" > "$D/requirements.txt"
[[ "$(detect_project_type "$D")" == "fastapi" ]] && pass || fail "fastapi" "$(detect_project_type "$D")" "fastapi"
rm -rf "$D"

# Test go
D=$(mktemp -d)
echo "module github.com/test/app" > "$D/go.mod"
[[ "$(detect_project_type "$D")" == "golang" ]] && pass || fail "go" "$(detect_project_type "$D")" "golang"
rm -rf "$D"

# Test rust
D=$(mktemp -d)
echo '[package]\nname="test"' > "$D/Cargo.toml"
[[ "$(detect_project_type "$D")" == "rust" ]] && pass || fail "rust" "$(detect_project_type "$D")" "rust"
rm -rf "$D"

# Test flutter
D=$(mktemp -d)
echo "name: test" > "$D/pubspec.yaml"
[[ "$(detect_project_type "$D")" == "flutter" ]] && pass || fail "flutter" "$(detect_project_type "$D")" "flutter"
rm -rf "$D"

# Test django
D=$(mktemp -d)
echo "django==4.2" > "$D/requirements.txt"
[[ "$(detect_project_type "$D")" == "django" ]] && pass || fail "django" "$(detect_project_type "$D")" "django"
rm -rf "$D"

echo "Detect test passed (8/8 types correct)"
