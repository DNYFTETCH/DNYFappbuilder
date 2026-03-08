#!/usr/bin/env bash
# DNYFappbuilder — Environment Profile Manager v2.0.0

ABP_ROOT="${ABP_ROOT:-$HOME/dnyf-appbuilder}"
source "$ABP_ROOT/lib/common.sh"

ACTION="${1:-list}"
shift 2>/dev/null || true
ENV_DIR="$ABP_ROOT/config/envs"
mkdir -p "$ENV_DIR"

case "$ACTION" in

    list)
        log_info "Environment profiles:"
        local_count=0
        for f in "$ENV_DIR"/*.env; do
            [ -f "$f" ] || continue
            echo "  • $(basename "$f" .env)"
            local_count=$(( local_count + 1 ))
        done
        [ "$local_count" -eq 0 ] && echo "  (none — create with: abp env create <name>)"
        ;;

    create)
        NAME="${1:-}"
        [ -z "$NAME" ] && { log_error "Usage: abp env create <name>"; exit 1; }
        FILE="$ENV_DIR/$NAME.env"
        if [ -f "$FILE" ]; then
            log_warn "Profile already exists: $NAME"
            exit 0
        fi
        printf '# DNYFappbuilder — Environment: %s\nNODE_ENV=%s\nPORT=3000\n# Add your variables below:\n' \
            "$NAME" "$NAME" > "$FILE"
        log_success "Created profile: $NAME ($FILE)"
        ;;

    edit)
        NAME="${1:-}"
        [ -z "$NAME" ] && { log_error "Usage: abp env edit <name>"; exit 1; }
        FILE="$ENV_DIR/$NAME.env"
        [ ! -f "$FILE" ] && { log_error "Profile not found: $NAME"; exit 1; }
        "${EDITOR:-nano}" "$FILE"
        ;;

    show)
        NAME="${1:-}"
        [ -z "$NAME" ] && { log_error "Usage: abp env show <name>"; exit 1; }
        FILE="$ENV_DIR/$NAME.env"
        [ ! -f "$FILE" ] && { log_error "Profile not found: $NAME"; exit 1; }
        cat "$FILE"
        ;;

    apply)
        NAME="${1:-}"
        [ -z "$NAME" ] && { log_error "Usage: abp env apply <name> [project-dir]"; exit 1; }
        DIR="${2:-.}"
        FILE="$ENV_DIR/$NAME.env"
        [ ! -f "$FILE" ] && { log_error "Profile not found: $NAME"; exit 1; }
        cp "$FILE" "$DIR/.env"
        log_success "Applied profile '$NAME' to $DIR/.env"
        ;;

    delete)
        NAME="${1:-}"
        [ -z "$NAME" ] && { log_error "Usage: abp env delete <name>"; exit 1; }
        FILE="$ENV_DIR/$NAME.env"
        [ ! -f "$FILE" ] && { log_error "Profile not found: $NAME"; exit 1; }
        rm -f "$FILE"
        log_success "Deleted: $NAME"
        ;;

    *)
        echo "Usage: abp env <list|create|edit|show|apply|delete> [name]"
        ;;
esac
