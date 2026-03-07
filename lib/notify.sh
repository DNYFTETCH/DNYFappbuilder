#!/usr/bin/env bash
# DNYFappbuilder — Build Notifications Library

# Send desktop/terminal notification
notify_build_done() {
    local project="$1" status="$2" elapsed="${3:-}"
    local msg="$project build $status"
    [[ -n "$elapsed" ]] && msg="$msg in $elapsed"

    # Termux notification
    if command_exists termux-notification; then
        termux-notification \
            --title "DNYFappbuilder" \
            --content "$msg" \
            --id abp-build \
            --priority high 2>/dev/null || true
        return
    fi

    # macOS notification
    if is_macos && command_exists osascript; then
        osascript -e "display notification \"$msg\" with title \"DNYFappbuilder\"" 2>/dev/null || true
        return
    fi

    # Linux desktop notification
    if command_exists notify-send; then
        local icon="dialog-information"
        [[ "$status" == "FAILED" ]] && icon="dialog-error"
        notify-send "DNYFappbuilder" "$msg" --icon="$icon" 2>/dev/null || true
        return
    fi

    # Terminal bell as fallback
    printf '\a'
}

# Send Slack webhook notification
notify_slack() {
    local webhook="$1" msg="$2"
    [[ -z "$webhook" ]] && return 0
    curl -sf -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$msg\"}" "$webhook" &>/dev/null || true
}

# Send generic webhook notification
notify_webhook() {
    local url="$1" project="$2" status="$3" elapsed="${4:-}"
    [[ -z "$url" ]] && return 0
    local payload="{\"project\":\"$project\",\"status\":\"$status\",\"elapsed\":\"$elapsed\",\"timestamp\":\"$(date -u +%FT%TZ)\"}"
    curl -sf -X POST -H 'Content-Type: application/json' \
        --data "$payload" "$url" &>/dev/null || true
}
