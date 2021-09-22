#!/bin/bash

emb_module_id="libdrm"
emb_module_desc="libdrm - Userspace library for drm"
emb_module_help="https://gitlab.freedesktop.org/mesa/drm"
emb_module_section="media"

function depends_libdrm() {
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

function sources_libdrm() {
    # last test commit: Mon Aug 2 01:06:44 2021 / 8d0fb9b3f225183fb3276a0e4ae1f8354a3519e8
    gitPullOrClone "$md_build" https://gitlab.freedesktop.org/mesa/drm
}

function build_libdrm() {
    meson build/
    ninja -C build install
}

function install_libdrm() {
        md_ret_files=(
        'build/tests'
        'build/lib*'
    )
}

function run_libdrm() {
    :
}
