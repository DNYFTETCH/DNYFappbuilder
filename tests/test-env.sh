#!/usr/bin/env bash
# DNYFappbuilder — Environment Profile Manager v2.0.0
set -Eeuo pipefail

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"

ACTION="${1:-list}"; shift || true
ENV_DIR="$ABP_ROOT/config/envs"
mkdir -p "$ENV_DIR"

case "$ACTION" in
    list)
        log_info "Environment profiles:"
        if ls "$ENV_DIR"/*.env &>/dev/null; then
            for f in "$ENV_DIR"/*.env; do
                echo "  • $(basename "$f" .env)"
            done
        else
            echo "  (none — create with: abp env create <name>)"
        fi
        ;;

    create)
        NAME="${1:-}"
        [[ -z "$NAME" ]] && { log_error "Usage: abp env create <name>"; exit 1; }
        FILE="$ENV_DIR/$NAME.env"
        [[ -f "$FILE" ]] && { log_warn "Profile already exists: $NAME"; exit 0; }
        cat > "$FILE" <<ENV
# DNYFappbuilder — Environment: $NAME
NODE_ENV=$NAME
PORT=3000
# Add your variables below:
ENV
        log_success "Created profile: $NAME ($FILE)"
        ;;

    edit)
        NAME="${1:-}"
        [[ -z "$NAME" ]] && { log_error "Usage: abp env edit <name>"; exit 1; }
        FILE="$ENV_DIR/$NAME.env"
        [[ ! -f "$FILE" ]] && { log_error "Profile not found: $NAME"; exit 1; }
        "${EDITOR:-nano}" "$FILE"
        ;;

    show)
        NAME="${1:-}"
        [[ -z "$NAME" ]] && { log_error "Usage: abp env show <name>"; exit 1; }
        FILE="$ENV_DIR/$NAME.env"
        [[ ! -f "$FILE" ]] && { log_error "Profile not found: $NAME"; exit 1; }
        cat "$FILE"
        ;;

    apply)
        NAME="${1:-}"
        [[ -z "$NAME" ]] && { log_error "Usage: abp env apply <name> [project-dir]"; exit 1; }
        DIR="${2:-.}"
        FILE="$ENV_DIR/$NAME.env"
        [[ ! -f "$FILE" ]] && { log_error "Profile not found: $NAME"; exit 1; }
        cp "$FILE" "$DIR/.env"
        log_success "Applied profile '$NAME' to $DIR/.env"
        ;;

    delete)
        NAME="${1:-}"
        [[ -z "$NAME" ]] && { log_error "Usage: abp env delete <name>"; exit 1; }
        FILE="$ENV_DIR/$NAME.env"
        [[ ! -f "$FILE" ]] && { log_error "Profile not found: $NAME"; exit 1; }
        confirm "Delete profile '$NAME'?" && rm "$FILE" && log_success "Deleted: $NAME"
        ;;

    *)
        echo "Usage: abp env <list|create|edit|show|apply|delete> [name]"
        ;;
esac