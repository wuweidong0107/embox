#!/bin/bash

emb_module_id="fa-rk3399-linux-4_4"
emb_module_desc="kernel for friendlyelec rk3399"
emb_module_help="kernel-v4.4 for FriendlyElec rk3399 boards"
emb_module_section="bsp"

function depends_fa-rk3399-linux-4_4() {
    emb_callModule fa-toolchain
}

function sources_fa-rk3399-linux-4_4() {
    gitPullOrClone "$md_build" https://github.com/friendlyarm/kernel-rockchip nanopi4-linux-v4.4.y
    gitPullOrClone "${md_build}/sd-fuse_rk3399" https://github.com/friendlyarm/sd-fuse_rk3399
}

function build_fa-rk3399-linux-4_4() {
    export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH

    touch .scmversion
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- nanopi4_linux_defconfig
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- nanopi4-images -j16
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- modules -j16
}

## @param target: install target (module|image)
function install_fa-rk3399-linux-4_4() {
    local target=$1

    cp ${scriptdir}/scriptmodules/${md_type}/fa-rk3399-linux-4_4/partmap.txt ${md_inst}
    case "${target}" in
        "image")
            md_ret_files=(
                'kernel.img'
                'resource.img'
            )
            ;;
        "module")
            make ARCH=arm64 CROSS_COMPILE=aarch64-linux- modules_install INSTALL_MOD_PATH="$md_inst" -j16
            ;;
        *)
            make ARCH=arm64 CROSS_COMPILE=aarch64-linux- modules_install INSTALL_MOD_PATH="$md_inst" -j16
            md_ret_files=(
                'kernel.img'
                'resource.img'
            )
            ;;
    esac
}

function upgrade_tf_fa-rk3399-linux-4_4() {
    local dev="$1"
    [[ -z "${dev}" ]] && echo "Error: miss tfcard device, e.g. /dev/sdX" && return

    local devname=$(basename ${dev})
    local sdupdate="${md_build}/sd-fuse_rk3399/tools/sd_update"
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

function upgrade_usb_fa-rk3399-linux-4_4() {
    # TODO
    echo "unsupported yet"
}