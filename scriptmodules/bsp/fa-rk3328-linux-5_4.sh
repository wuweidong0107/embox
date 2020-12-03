#!/bin/bash

emb_module_id="fa-rk3328-linux-5_4"
emb_module_desc="kernel for friendlyelec rk3328"
emb_module_help="kernel-v5.4 for FriendlyElec rk3328 boards"
emb_module_section="bsp"

function depends_fa-rk3328-linux-5_4() {
    emb_callModule fa-toolchain
}

function sources_fa-rk3328-linux-5_4() {
    gitPullOrClone "$md_build" https://github.com/friendlyarm/kernel-rockchip nanopi-r2-v5.4.y
    gitPullOrClone "${md_build}/sd-fuse_rk3328" https://github.com/friendlyarm/sd-fuse_rk3328
}

function build_fa-rk3328-linux-5_4() {
    export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH

    touch .scmversion
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- nanopi-r2_linux_defconfig
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- -j16

    local sdfuse_tools=${md_build}/sd-fuse_rk3328
    ${sdfuse_tools}/tools/mkkrnlimg arch/arm64/boot/Image kernel.img
    ${sdfuse_tools}/tools/resource_tool \
    --dtbname arch/arm64/boot/dts/rockchip/rk3328-nanopi*-rev*.dtb \
    ${sdfuse_tools}/prebuilt/boot/logo.bmp ${sdfuse_tools}/prebuilt/boot/logo_kernel.bmp
}

function install_img_fa-rk3328-linux-5_4() {
    md_ret_files=(
        'kernel.img'
        'resource.img'
    )
}

function install_mod_fa-rk3328-linux-5_4() {
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- modules_install INSTALL_MOD_PATH="$md_inst" -j16
}

function install_fa-rk3328-linux-5_4() {
    install_mod_fa-rk3328-linux-5_4

    cp ${scriptdir}/scriptmodules/${md_type}/fa-rk3328-linux-5_4/partmap.txt ${md_inst}

    md_ret_files=(
        'kernel.img'
        'resource.img'
    )
}

function upgrade_tf_fa-rk3328-linux-5_4() {
    local dev="$1"
    [[ -z "${dev}" ]] && echo "Error: miss tfcard device, e.g. /dev/sdX" && return

    local devname=$(basename ${dev})
    local sdupdate="${md_build}/sd-fuse_rk3328/tools/sd_update"
    local partmap="${md_inst}/partmap.txt"
    local blksize=$(cat /sys/class/block/${devname}/size)

    if [[ -z "${blksize}" ]] && [[ ${blksize} -le 0 ]]; then
        echo "Error: $1 is inaccessible"
        exit 1
    fi

    let devsize=${blksize}/2
    if [ ${devsize} -gt 64000000 ]; then
        echo "Error: $1 size (${devsize} KB) is too large"
        exit 1
    fi
    ${sdupdate} -d ${dev} -p ${partmap}
}

function upgrade_usb_fa-rk3328-linux-5_4() {
    # TODO
    echo "unsupported yet"
}