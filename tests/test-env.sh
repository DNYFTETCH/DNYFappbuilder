#!/usr/bin/env bash
# DNYFappbuilder — test-env.sh
# No pipes used — avoids bash -e pipe exit code propagation

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
ENV_SCRIPT="$ABP_ROOT/scripts/env.sh"
ENV_DIR="$ABP_ROOT/config/envs"
PROFILE="_test_ci_profile"
TMP_OUT="/tmp/abp_env_test_out.txt"

mkdir -p "$ENV_DIR"

# ── 1. Create ────────────────────────────────────────────
bash "$ENV_SCRIPT" create "$PROFILE" > "$TMP_OUT" 2>&1
if [ ! -f "$ENV_DIR/$PROFILE.env" ]; then
    echo "FAIL: create — profile file not found"
    cat "$TMP_OUT"
    exit 1
fi

# ── 2. List ──────────────────────────────────────────────
bash "$ENV_SCRIPT" list > "$TMP_OUT" 2>&1
if ! grep -q "$PROFILE" "$TMP_OUT"; then
    echo "FAIL: list — profile not in output"
    cat "$TMP_OUT"
    exit 1
fi

# ── 3. Show ──────────────────────────────────────────────
bash "$ENV_SCRIPT" show "$PROFILE" > "$TMP_OUT" 2>&1
if ! grep -q "NODE_ENV" "$TMP_OUT"; then
    echo "FAIL: show — NODE_ENV not in output"
    cat "$TMP_OUT"
    exit 1
fi

# ── 4. Apply ─────────────────────────────────────────────
bash "$ENV_SCRIPT" apply "$PROFILE" /tmp > "$TMP_OUT" 2>&1
if [ ! -f "/tmp/.env" ]; then
    echo "FAIL: apply — /tmp/.env not created"
    cat "$TMP_OUT"
    exit 1
fi

# ── Cleanup ───────────────────────────────────────────────
rm -f "$ENV_DIR/$PROFILE.env" "/tmp/.env" "$TMP_OUT"

echo "Env test passed"