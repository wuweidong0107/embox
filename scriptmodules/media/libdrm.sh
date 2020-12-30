#!/bin/bash

emb_module_id="libdrm"
emb_module_desc="libdrm - "
emb_module_help="https://gitlab.freedesktop.org/mesa/drm"
emb_module_section="media"

function depends_libdrm() {
    local depends=(meson)
    getDepends "${depends[@]}"
}

function sources_libdrm() {
    gitPullOrClone "$md_build" https://gitlab.freedesktop.org/mesa/drm
}

function build_libdrm() {
    meson builddir/
    ninja -C builddir/ install
}
function install_libdrm() {
    :
}
