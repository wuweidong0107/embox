#!/bin/bash

emb_module_id="kmscube"
emb_module_desc="kmscube - bare metal graphics demo"
emb_module_help="a little demonstration program for how to drive bare metal graphics without a compositor like X11, wayland or similar, using DRM/KMS (kernel mode setting), GBM (graphics buffer manager) and EGL for rendering content using OpenGL or OpenGL ES"
emb_module_section="hardware"

function depends_kmscube() {
    local depends=(meson ninja-build)

    getDepends "${depends[@]}"
}

function sources_kmscube() {
    gitPullOrClone "$md_build" https://gitlab.freedesktop.org/mesa/kmscube/
}

function build_kmscube() {
    mkdir -p build
    meson build
    cd build && ninja
}

function install_kmscube() {
        md_ret_files=(
        'build/kmscube'
        'build/texturator'
    )
}