#!/bin/bash

emb_module_id="fa-rk3399-uboot-2014"
emb_module_desc="u-boot for friendlyelec rk3399"
emb_module_help="U-boot for FriendlyElec rk3399"
emb_module_section="bsp"

function depends_fa-rk3399-uboot-2014() {
    :
}

function sources_fa-rk3399-uboot-2014() {
    gitPullOrClone "$md_build" https://github.com/friendlyarm/uboot-rockchip nanopi4-v2014.10_oreo
}

function build_fa-rk3399-uboot-2014() {
    export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH
    make CROSS_COMPILE=aarch64-linux- rk3399_defconfig
    make CROSS_COMPILE=aarch64-linux- -j16
}

function install_fa-rk3399-uboot-2014() {
    cp rk3399_loader_v1.24.119.bin MiniLoaderAll.bin
    md_ret_files=(
        'uboot.img'
        'trust.img'
        'MiniLoaderAll.bin'
    )
}
