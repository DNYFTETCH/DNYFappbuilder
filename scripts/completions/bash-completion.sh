#!/usr/bin/env bash
# DNYFappbuilder — Bash Completion

_abp_completions() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local commands="init build devices install uninstall screenshot logcat sign keygen verify-sign deploy docker logs env plugins update doctor clean version help"

    local templates="react-native flutter android nodejs python java react vue"
    local targets="android ios web all"
    local profiles="debug release staging"
    local deploy_targets="render railway vercel heroku docker github-pages"
    local docker_actions="build run push compose-up compose-down clean ps logs"
    local env_actions="list create edit show apply delete"
    local plugin_actions="list install remove"

    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
    elif [[ $COMP_CWORD -eq 2 ]]; then
        case "$prev" in
            init)    COMPREPLY=( $(compgen -W "myapp" -- "$cur") ) ;;
            build)   COMPREPLY=( $(compgen -d -- "$cur") ) ;;
            install) COMPREPLY=( $(compgen -f -X '!*.apk' -- "$cur") $(compgen -f -X '!*.ipa' -- "$cur") ) ;;
            deploy)  COMPREPLY=( $(compgen -W "$deploy_targets" -- "$cur") ) ;;
            docker)  COMPREPLY=( $(compgen -W "$docker_actions" -- "$cur") ) ;;
            env)     COMPREPLY=( $(compgen -W "$env_actions" -- "$cur") ) ;;
            plugins) COMPREPLY=( $(compgen -W "$plugin_actions" -- "$cur") ) ;;
            sign|verify-sign) COMPREPLY=( $(compgen -f -X '!*.apk' -- "$cur") ) ;;
        esac
    elif [[ $COMP_CWORD -eq 3 ]]; then
        case "${COMP_WORDS[1]}" in
            init) COMPREPLY=( $(compgen -W "$templates" -- "$cur") ) ;;
        esac
    else
        case "$prev" in
            --target)  COMPREPLY=( $(compgen -W "$targets" -- "$cur") ) ;;
            --profile) COMPREPLY=( $(compgen -W "$profiles" -- "$cur") ) ;;
            --device)  COMPREPLY=( $(compgen -W "$(adb devices 2>/dev/null | grep -v List | awk '{print $1}' | grep -v '^$')" -- "$cur") ) ;;
            --output)  COMPREPLY=( $(compgen -d -- "$cur") ) ;;
            --keystore) COMPREPLY=( $(compgen -f -X '!*.keystore' -- "$cur") $(compgen -f -X '!*.jks' -- "$cur") ) ;;
        esac

        case "${COMP_WORDS[1]}" in
            build)
                local build_flags="--target --profile --parallel --no-cache --sign --install --notify --output --device"
                COMPREPLY+=( $(compgen -W "$build_flags" -- "$cur") )
                ;;
            install)
                local install_flags="--device --all --wireless --qr --verify --package"
                COMPREPLY+=( $(compgen -W "$install_flags" -- "$cur") )
                ;;
            sign)
                local sign_flags="--keystore --alias --password --auto"
                COMPREPLY+=( $(compgen -W "$sign_flags" -- "$cur") )
                ;;
        esac
    fi

    return 0
}

complete -F _abp_completions abp
