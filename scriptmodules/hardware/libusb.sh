#!/bin/bash

emb_module_id="libgpiod"
emb_module_desc="libgpiod - C library and tools for interacting with the linux GPIO character device"
emb_module_help="/opt/embox/hardwares/libgpiod"
emb_module_section="hardware"

function depends_libgpiod() {
    local depends=(autoconf-archive)
    getDepends "${depends[@]}"
}

function sources_libgpiod() {
    gitPullOrClone "$md_build" https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git v1.6.x
}

function build_libgpiod() {
    ./autogen.sh --enable-tools=yes
    make
}

function install_libgpiod() {
    make install
    ldconfig
}