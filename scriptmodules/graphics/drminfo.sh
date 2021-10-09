#!/bin/bash

emb_module_id="drminfo"
emb_module_desc="drminfo - Small utility to dump info about DRM devices."
emb_module_help="https://github.com/ascent12/drm_info"
emb_module_section="graphics"

function depends_drminfo() {
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

function sources_drminfo() {
    gitPullOrClone "$md_build" https://github.com/ascent12/drm_info
}

function build_drminfo() {
    meson build/
    ninja -C build install
}

function install_drminfo() {
        md_ret_files=(
        'build/drm_info'
    )
}

function run_drminfo() {
    :
}
