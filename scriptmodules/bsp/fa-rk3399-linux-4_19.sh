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

    [ -f ${md_inst}/kernel.img ] && dd if=${md_inst}/kernel.img of=/dev/${dev_part[kernel]}
    [ -f ${md_inst}/resource.img ] && dd if=${md_inst}/resource.img of=/dev/${dev_part[resource]}
}

function upgrade_usb_fa-rk3399-linux-4_19() {
    # TODO
    echo "unsupported yet"
}

function upgrade_ssh_fa-rk3399-linux-4_19() {
    local ip="$1"

    [ "${ip}" == "help" ] \
        && echo "Usage: embox_packages.sh ${md_id} upgrade_ssh ip <target>[image|module]" \
        && return

    [[ -z "${ip}" ]] \
        && echo "Usage: embox_packages.sh ${md_id} upgrade_ssh ip <target>[image|module]" \
        && return

    local target="$2"

    local data=(
        "${md_inst}/kernel.img"
        "${md_inst}/resource.img"
    )
    ssh root@${ip} mkdir -p ${md_inst}
    local dest="root@${ip}:${md_inst}"
    case "${target}" in
        "image")
            scp ${data[*]} ${dest}
            echo -e "\nRun command on RK3399:\n $ ./embox_packages.sh ${md_id} upgrade_tf /dev/mmcblkX"
            ;;
        "module")
            scp -r ${md_inst}/lib root@${ip}:/
            ;;
        *)
            scp -r ${md_inst}/lib root@${ip}:/
            scp ${data[*]} ${dest}
            echo -e "\nRun command on RK3399:\n $ ./embox_packages.sh ${md_id} upgrade_tf /dev/mmcblkX"
            ;;
    esac
}
