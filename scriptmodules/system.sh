#!/bin/bash

function setup_env() {
    get_platform
    get_os_version
    get_emb_depends
}

function get_emb_depends() {
    local depends=(git dialog wget gcc g++ build-essential)

    if ! getDepends "${depends[@]}"; then
        fatalError "Unable to install packages required by $0 - ${md_ret_errors[@]}"
    fi
}

function get_os_version() {
    # make sure lsb_release is installed
    getDepends lsb-release

    mapfile -t os < <(lsb_release -s -i -d -r -c)
    __os_id="${os[0]}"
    __os_desc="${os[1]}"
    __os_release="${os[2]}"
    __os_codename="${os[3]}"

    case "$__os_id" in
        Ubuntu|neon|Pop)
            if compareVersions "$__os_release" lt 16.04; then
                error="You need Ubuntu 16.04 or newer"
            fi
            ;;
        *)
            error="Unsupported OS"
            ;;
    esac
    [[ -n "$error" ]] && fatalError "$error\n\n$(lsb_release -idrc)"
}

function get_platform() {
    __platform_flags=()
    local architecture="$(uname --machine)"

    if [[ -z "$__platform" ]]; then
        case "$(sed -n '/^Hardware/s/^.*: \(.*\)/\1/p' < /proc/cpuinfo)" in
            *)
                # jetson nano and tegra x1 can be identified via /sys/firmware/devicetree/base/model
                local model_path="/sys/firmware/devicetree/base/model"
                if [[ -f "$model_path" ]]; then
                    # ignore end null to avoid bash warning
                    local model=$(tr -d '\0' <$model_path)
                    case "$model" in
                        "FriendlyElec NanoPi NEO3"|"FriendlyElec NanoPi R2 Pro")
                            __platform="rk3328"
                            __platform_flags+=(sdl1)
                            ;;
                    esac
                else
                    case $architecture in
                        i686|x86_64|amd64)
                            __platform="x86"
                            ;;
                    esac
                fi
                ;;
        esac
    fi

    if ! fnExists "platform_${__platform}"; then
        fatalError "Unknown platform - please manually set the __platform variable to one of the following: $(compgen -A function platform_ | cut -b10- | paste -s -d' ')"
    fi

    set_platform_defaults
    platform_${__platform}
}

function set_platform_defaults() {
    __default_opt_flags="-O2"

    # add platform name and 32bit/64bit to platform flags
    __platform_flags+=("$__platform" "$(getconf LONG_BIT)bit")
    __platform_arch=$(uname -m)
}

function platform_x86() {
    __platform_flags+=(gl)
}

function platform_rk3328() {
    __platform_flags+=(aarch64)
}