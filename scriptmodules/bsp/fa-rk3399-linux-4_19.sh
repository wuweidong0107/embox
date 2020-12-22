#!/bin/bash

emb_module_id="fa-rk3399-linux-4_19"
emb_module_desc="kernel for friendlyelec rk3399"
emb_module_help="kernel-v4.19 for FriendlyElec rk3399 boards"
emb_module_section="bsp"

function depends_fa-rk3399-linux-4_19() {
    emb_callModule fa-toolchain
}

function sources_fa-rk3399-linux-4_19() {
    gitPullOrClone "$md_build" https://github.com/friendlyarm/kernel-rockchip nanopi4-v4.19.y
}

function build_fa-rk3399-linux-4_19() {
    export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- nanopi4_linux_defconfig
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- nanopi4-images -j16
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- modules -j16
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- dtbs -j16
}

function install_fa-rk3399-linux-4_19() {
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- modules_install INSTALL_MOD_PATH="$md_inst" -j16
    md_ret_files=(
        'kernel.img'
        'resource.img'
    )
}