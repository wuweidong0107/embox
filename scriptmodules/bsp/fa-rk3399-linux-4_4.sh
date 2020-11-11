#!/bin/bash

emb_module_id="fa-rk3399-linux-4_4"
emb_module_desc="fa-rk3399-linux-4_4"
emb_module_help="/opt/embox/hardwares/fa-rk3399-linux-4_4"
emb_module_section="bsp"

function sources_fa-rk3399-linux-4_4() {
    gitPullOrClone "$md_build" https://github.com/friendlyarm/kernel-rockchip nanopi4-linux-v4.4.y
}

function build_fa-rk3399-linux-4_4() {
    export PATH=/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- nanopi4_linux_defconfig
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- nanopi4-images
}

function install_fa-rk3399-linux-4_4() {
    :
}