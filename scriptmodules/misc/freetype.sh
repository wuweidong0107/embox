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

    if isPlatform "x86"; then       # cross_compile
        if [[ "$1" == "aarch64_sdl1" ]]; then
            export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH
            export NEED_CXX_LINKER=1
            export CC=aarch64-linux-gcc
            export CXX=aarch64-linux-g++
            ./configure \
            --host=aarch64-linux- \
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
            --disable-opengl1 \
            --disable-videocore \
            --disable-v4l2 \
            --disable-discord \
            --enable-neon \
            --disable-cdrom \
            --disable-qt \
            --disable-networking
            make -j16
        else
            echo "Error: miss target(aarch64_sdl1)"
            exit 1
        fi
    else
        if isPlatform "sdl1"; then
            ./configure \
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
            --disable-opengl1 \
            --disable-videocore \
            --disable-v4l2 \
            --disable-discord \
            --disable-cdrom \
            --disable-qt \
            --disable-networking

            embSwap on 1024
            make -j16
            embSwap off
        fi
    fi
}

function install_retroarch() {
    :
}