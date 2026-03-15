#!/usr/bin/env bash
# DNYFappbuilder — test-env.sh

export ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
ENV_SCRIPT="$ABP_ROOT/scripts/env.sh"
ENV_DIR="$ABP_ROOT/config/envs"
PROFILE="_test_ci_profile"
TMPFILE="/tmp/_abp_env_test.txt"

# Pre-clean
rm -f "$ENV_DIR/$PROFILE.env" "/tmp/.env" "$TMPFILE" 2>/dev/null || true
mkdir -p "$ENV_DIR"

# Verify env.sh exists
if [ ! -f "$ENV_SCRIPT" ]; then
    echo "FAIL: env.sh not found at $ENV_SCRIPT"
    exit 1
fi

# ── 1. Create ────────────────────────────────────────────
bash "$ENV_SCRIPT" create "$PROFILE" >"$TMPFILE" 2>&1
RC=$?
if [ $RC -ne 0 ] || [ ! -f "$ENV_DIR/$PROFILE.env" ]; then
    echo "FAIL: create (exit $RC)"
    cat "$TMPFILE"
    exit 1
fi

# ── 2. List ──────────────────────────────────────────────
bash "$ENV_SCRIPT" list >"$TMPFILE" 2>&1
RC=$?
if [ $RC -ne 0 ]; then
    echo "FAIL: list returned exit $RC"
    cat "$TMPFILE"
    exit 1
fi
if ! grep -q "$PROFILE" "$TMPFILE"; then
    echo "FAIL: list did not contain $PROFILE"
    cat "$TMPFILE"
    exit 1
fi

# ── 3. Show ──────────────────────────────────────────────
bash "$ENV_SCRIPT" show "$PROFILE" >"$TMPFILE" 2>&1
RC=$?
if [ $RC -ne 0 ]; then
    echo "FAIL: show returned exit $RC"
    cat "$TMPFILE"
    exit 1
fi
if ! grep -q "NODE_ENV" "$TMPFILE"; then
    echo "FAIL: show output missing NODE_ENV"
    cat "$TMPFILE"
    exit 1
fi

# ── 4. Apply ─────────────────────────────────────────────
bash "$ENV_SCRIPT" apply "$PROFILE" /tmp >"$TMPFILE" 2>&1
RC=$?
if [ $RC -ne 0 ] || [ ! -f "/tmp/.env" ]; then
    echo "FAIL: apply (exit $RC)"
    cat "$TMPFILE"
    exit 1
fi

# ── Cleanup ───────────────────────────────────────────────
rm -f "$ENV_DIR/$PROFILE.env" "/tmp/.env" "$TMPFILE"

echo "Env test passed"
