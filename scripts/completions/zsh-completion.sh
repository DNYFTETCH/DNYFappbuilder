#!/usr/bin/env zsh
# DNYFappbuilder — Zsh Completion

_abp() {
    local state

    _arguments \
        '1: :->command' \
        '*: :->args'

    case $state in
        command)
            local commands=(
                'init:Create a new project'
                'build:Build application'
                'devices:List connected devices'
                'install:Install app to device(s)'
                'uninstall:Remove app from device(s)'
                'screenshot:Capture device screenshot'
                'logcat:Stream device logs'
                'sign:Sign an APK'
                'keygen:Generate keystore'
                'verify-sign:Verify APK signature'
                'deploy:Deploy to cloud platform'
                'docker:Docker management'
                'logs:View build logs'
                'env:Manage environment profiles'
                'plugins:Manage plugins'
                'update:Self-update DNYFappbuilder'
                'doctor:Check environment health'
                'clean:Clean build cache'
                'version:Show version'
                'help:Show help'
            )
            _describe 'command' commands
            ;;
        args)
            case ${words[2]} in
                init)
                    if [[ ${#words[@]} -eq 3 ]]; then
                        _message 'project name'
                    else
                        local templates=(react-native flutter android nodejs python java react vue)
                        _describe 'template' templates
                    fi
                    ;;
                build)
                    _arguments \
                        '--target[Build target]:(android ios web all)' \
                        '--profile[Build profile]:(debug release staging)' \
                        '--parallel[Parallel builds]' \
                        '--no-cache[Skip cache]' \
                        '--sign[Auto-sign]' \
                        '--install[Auto-install]' \
                        '--notify[Send notification]' \
                        '--output[Output directory]:dir:_directories' \
                        '--device[Device serial]:serial'
                    ;;
                install)
                    _arguments \
                        '1:app file:_files -g "*.apk *.ipa"' \
                        '--device[Target device]:serial' \
                        '--all[All devices]' \
                        '--wireless[WiFi IP address]:ip' \
                        '--qr[Show QR code]' \
                        '--verify[Verify install]' \
                        '--package[Package ID]:id'
                    ;;
                deploy)
                    local targets=(render railway vercel heroku docker github-pages)
                    _describe 'deploy target' targets
                    ;;
            esac
            ;;
    esac
}

compdef _abp abp
