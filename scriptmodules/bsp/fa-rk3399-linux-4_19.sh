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

    touch .scmversion
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- nanopi4_linux_defconfig
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- nanopi4-images -j16
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- modules -j16
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- dtbs -j16
}

## @param target: install target (module|image)
function install_fa-rk3399-linux-4_19() {
    local target=$1

    export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH
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

function upgrade_tf_fa-rk3399-linux-4_19() {

    local dev=$1
    if ! embCheckBlkSize ${dev} 64000000; then
        echo "Error: invalid block dev ${dev}"
        exit 1
    fi

    # abandon "sd_update -d /dev/sdX -p parameter.txt" becasue
    # sd_update will remake gpt partition table
    local subdev
    local label
    declare -A kdata
    kdata=(
        ['resource']='5'
        ['kernel']='6'
        )
    for idx in ${!kdata[@]}; do
        subdev="${dev}${kdata[$idx]}"
        label=$(blkid ${subdev} -o export | grep PARTLABEL | cut -d= -f2)
        if [ "${label}" == "${idx}" ]; then
            dd if=${md_inst}/${idx}.img of=${subdev}
        else
            echo "${subdev}'s label($label) != ${idx}"
            exit 1
        fi
    done
}

function upgrade_usb_fa-rk3399-linux-4_19() {
    # TODO
    echo "unsupported yet"
}