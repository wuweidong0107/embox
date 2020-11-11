#!/bin/bash

emb_module_id="fa-toolchain"
emb_module_desc="fa-toolchain"
emb_module_help="/opt/embox/hardwares/fa-toolchain"
emb_module_section="bsp"

function sources_fa-toolchain() {
    gitPullOrClone "$md_build" https://github.com/friendlyarm/prebuilts.git
}

function install_fa-toolchain() {
    cd gcc-x64
    cat toolchain-6.4-aarch64.tar.gz* | tar xz -C "$md_build"
    cat toolchain-4.9.3-armhf.tar.gz* | tar xz -C "$md_build"
    cd ->/dev/null

    cd gcc
    extract arm-linux-gcc-4.4.3.tar.gz "$md_build"
    extract arm-linux-gcc-4.5.1-v6-vfp.tar.xz "$md_build"
    cd ->/dev/null
}