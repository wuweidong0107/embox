#!/bin/bash

emb_module_id="fa-rk3399-linux-5_10"
emb_module_desc="kernel for friendlyelec rk3399"
emb_module_help="kernel-v5.4 for FriendlyElec rk3399 boards"
emb_module_section="bsp"

function depends_fa-rk3399-linux-5_10() {
    emb_callModule fa-toolchain
}

function sources_fa-rk3399-linux-5_10() {
    gitPullOrClone "$md_build" https://github.com/friendlyarm/kernel-rockchip nanopi-r2-v5.10.y
    gitPullOrClone "${md_build}/sd-fuse_rk3399" https://github.com/friendlyarm/sd-fuse_rk3399 kernel-5.10.y
}

function build_fa-rk3399-linux-5_10() {
    export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH

    touch .scmversion
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- nanopi-r2_linux_defconfig
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- -j16

    local sdfuse_tools=${md_build}/sd-fuse_rk3399
    ${sdfuse_tools}/tools/mkkrnlimg arch/arm64/boot/Image kernel.img
    ${sdfuse_tools}/tools/resource_tool \
    --dtbname arch/arm64/boot/dts/rockchip/rk3399-nanopi*-rev*.dtb \
    ${sdfuse_tools}/prebuilt/boot/logo.bmp ${sdfuse_tools}/prebuilt/boot/logo_kernel.bmp
}

function _install_module_fa-rk3399-linux-5_10() {
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- modules_install INSTALL_MOD_PATH="$md_inst" -j16
    unlink "$md_inst/lib/modules/${kver}/source"
    unlink "$md_inst/lib/modules/${kver}/build"
}

## @param target: install target (module|image)
function install_fa-rk3399-linux-5_10() {
    local target=$1

    [ "${target}" == "help" ] \
        && echo "Usage: embox_packages.sh ${md_id} install <target>[image|module]" \
        && return

    export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH
    local kver=$(make ARCH=arm64 CROSS_COMPILE=aarch64-linux- kernelrelease)
    cp ${scriptdir}/scriptmodules/${md_type}/fa-rk3399-linux-5_10/partmap.txt ${md_inst}
    case "${target}" in
        "image")
            md_ret_files=(
                'kernel.img'
                'resource.img'
            )
            ;;
        "module")
            _install_module_fa-rk3399-linux-5_10
            ;;
        *)
            _install_module_fa-rk3399-linux-5_10
            md_ret_files=(
                'kernel.img'
                'resource.img'
            )
            ;;
    esac
}

function upgrade_tf_fa-rk3399-linux-5_10() {
    local dev="$1"

    [ "${dev}" == "help" ] \
        && echo "Usage: embox_packages.sh ${md_id} upgrade_tf /dev/sdX" \
        && return

    [[ -z "${dev}" ]] \
        && echo "Usage: embox_packages.sh ${md_id} upgrade_tf /dev/sdX" \
        && return

    local devname=$(basename ${dev})
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
    declare -A dev_part
    dev_part[resource]=${devname}5
    dev_part[kernel]=${devname}6
    cd /sys/class/block
    for i in ${devname}*; do 
        part_name=$(cat ${i}/uevent | grep PARTNAME | cut -d= -f2)
        if [ -n "${part_name}" ]; then
            dev_part[${part_name}]=${i}
        fi
    done
    cd ->/dev/null

    dd if=${md_inst}/kernel.img of=/dev/${dev_part[kernel]}
    dd if=${md_inst}/resource.img of=/dev/${dev_part[resource]}
}

function upgrade_usb_fa-rk3399-linux-5_10() {
    # TODO
    echo "unsupported yet"
}

function upgrade_ssh_fa-rk3399-linux-5_10() {
    local ip="$1"

    [ "${ip}" == "help" ] \
        && echo "Usage: embox_packages.sh ${md_id} upgrade_ssh ip <target>[image|module]" \
        && return

    [[ -z "${ip}" ]] \
        && echo "Usage: embox_packages.sh ${md_id} upgrade_ssh ip <target>[image|module]" \
        && return

    local target="$2"

    local data=(
        "${scriptdir}/tmp/build/sd_update-bin/aarch64/sd_update"
        "${md_inst}/partmap.txt"
        "${md_inst}/kernel.img"
        "${md_inst}/resource.img"
    )
    local dest="root@${ip}:/root/"
    case "${target}" in
        "image")
            scp ${data[*]} ${dest}
            echo -e "\nRun command on RK3399:\n $ cd root\n $ ./sd_update -d /dev/mmcblkX -p partmap.txt"
            ;;
        "module")
            scp -r ${md_inst}/lib root@${ip}:/
            ;;
        *)
            scp -r ${md_inst}/lib root@${ip}:/
            scp ${data[*]} ${dest}
            echo -e "\nRun command on RK3399:\n $ cd root\n $ ./sd_update -d /dev/mmcblkX -p partmap.txt"
            ;;
    esac
}