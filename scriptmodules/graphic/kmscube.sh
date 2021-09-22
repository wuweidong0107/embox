#!/bin/bash

emb_module_id="kmscube"
emb_module_desc="kmscube - bare metal graphics demo"
emb_module_help="a little demonstration program for how to drive bare metal graphics without a compositor like X11, wayland or similar, using DRM/KMS (kernel mode setting), GBM (graphics buffer manager) and EGL for rendering content using OpenGL or OpenGL ES"
emb_module_section="hardware"

function depends_kmscube() {
    local depends=(meson ninja-build)

    getDepends "${depends[@]}"

    local ver="0.47"
    if [ -d "$md_build" ]; then
        ver=$(grep meson_version $md_build/meson.build | cut -d= -f2 | cut -d\' -f1 | xargs)
    fi
    if ! hasPackage meson ${ver} ge; then
        echo "/usr/bin/meson is too old. Using ~/.local/bin/meson"
        pip3 install --user meson      
        export PATH=~/.local/bin:$PATH
    fi
}

function sources_kmscube() {
    # last test commit: Sun Feb 7 11:42:33 2021 / 9f63f359fab1b5d8e862508e4e51c9dfe339ccb0
    gitPullOrClone "$md_build" https://gitlab.freedesktop.org/mesa/kmscube/
}

function build_kmscube() {
    meson build
    ninja -C build
}

function install_kmscube() {
        md_ret_files=(
        'build/kmscube'
        'build/texturator'
    )
}

function run_kmscube() {
    ${md_inst}/kmscube
    ${md_inst}/texturator -z 3D RG16UI 37x65x4
}