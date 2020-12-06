#!/bin/bash

emb_module_id="retroarch"
emb_module_desc="RetroArch - frontend to the libretro cores"
emb_module_help="NULL"
emb_module_section="misc"

function depends_retroarch() {
    if isPlatform "sdl1"; then
        local depends=(libsdl1.2-dev)
        getDepends "${depends[@]}"
    fi
}

function sources_retroarch() {
    gitPullOrClone "$md_build" https://github.com/libretro/RetroArch
}

function build_retroarch() {
    local cross=$1
    local params=()
    if isPlatform "x86"; then
        if [[ "${cross}" == "aarch64_sdl1" ]]; then
            export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH
            CROSS_COMPILE=aarch64-linux-
            params+=(--host=aarch64-linux-)
        else
            echo "Error: miss target for cross compile. supported: aarch64_sdl1"
            exit 1
        fi
    fi

    if isPlatform "sdl1" || [[ "${cross}" == "aarch64_sdl1" ]]; then
        params+=(\
        --disable-ffmpeg \
        --disable-cg \
        --disable-opengl_core \
        --disable-pulse \
        --disable-jack \
        --disable-mali_fbdev \
        --disable-x11 --disable-sdl2 \
        --disable-wayland \
        --disable-egl \
        --enable-sdl \
        --disable-opengl \
        --disable-opengl1 \
        --disable-videocore \
        --disable-v4l2 \
        --disable-discord \
        --disable-neon \
        --disable-cdrom \
        --disable-qt \
        --disable-networking)
    else
        echo "Error: unsupported platform"
        exit 1
    fi

    export NEED_CXX_LINKER=1
    export CC=${CROSS_COMPILE}gcc
    export CXX=${CROSS_COMPILE}g++
    ./configure "${params[@]}"

    local mem=$(awk '/MemFree/ { printf "%d", $2/1024 }' /proc/meminfo)
    if [[ "${mem}" -lt 1024 ]]; then
        embSwap on 1024
    fi
    make -j16
    if [[ "${mem}" -lt 1024 ]]; then
        embSwap off
    fi
}

function install_retroarch() {
    md_ret_files=(
        'retroarch'
    )
}