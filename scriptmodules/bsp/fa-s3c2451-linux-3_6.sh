#!/bin/bash

emb_module_id="fa-s3c2451-linux-3_6"
emb_module_desc="kernel for friendlyelec s3c2451/s3c2416"
emb_module_help="kernel-v3.6 for FriendlyElec s3c2451/s3c2416 boards"
emb_module_section="bsp"

function depends_fa-s3c2451-linux-3_6() {
    emb_callModule fa-toolchain-4_4
}

function sources_fa-s3c2451-linux-3_6() {
    if [ ! -f "${md_build}/mini2451_linux_config" ]; then
        echo "Please extract kernel into ${md_build}"
        exit 0
    fi
}

## @param target: install target (module|image)
function build_fa-s3c2451-linux-3_6() {
    export PATH=${rootdir}/bsp/fa-toolchain-4_4/opt/FriendlyARM/toolschain/4.4.3/bin/:$PATH

    local target=$1

    touch .scmversion
    cp mini2451_linux_config .config

    case "${target}" in
        "image")
            make ARCH=arm CROSS_COMPILE=arm-linux- zImage -j16
            ;;
        "module")
            make ARCH=arm CROSS_COMPILE=arm-linux- modules -j16
            ;;    
        *)
            make ARCH=arm CROSS_COMPILE=arm-linux- zImage -j16
            make ARCH=arm CROSS_COMPILE=arm-linux- modules -j16
            ;;  
    esac
}

## @param target: install target (module|image)
function install_fa-s3c2451-linux-3_6() {
    local target=$1

    case "${target}" in
        "image")
            md_ret_files=(
                'arch/arm/boot/zImage'
            )
            ;;
        "module")
            make ARCH=arm CROSS_COMPILE=arm-linux- modules_install INSTALL_MOD_PATH="$md_inst" -j16
            ;;
        *)
            make ARCH=arm CROSS_COMPILE=arm-linux- modules_install INSTALL_MOD_PATH="$md_inst" -j16
            md_ret_files=(
                'arch/arm/boot/zImage'
            )
            ;;
    esac
}