#!/bin/bash

emb_module_id="fa-rk3399-linux-4_4"
emb_module_desc="kernel for friendlyelec rk3399"
emb_module_help="kernel-v4.4 for FriendlyElec rk3399 boards"
emb_module_section="bsp"

function depends_fa-rk3399-linux-4_4() {
    emb_callModule fa-toolchain
    emb_callModule sd_update-bin
}

function sources_fa-rk3399-linux-4_4() {
    gitPullOrClone "$md_build" https://github.com/friendlyarm/kernel-rockchip nanopi4-linux-v4.4.y
}

function build_fa-rk3399-linux-4_4() {
    export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH

    touch .scmversion
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- nanopi4_linux_defconfig
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- nanopi4-images -j16
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- modules -j16
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- dtbs -j16
}

function _install_module_fa-rk3399-linux-4_4() {
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux- modules_install INSTALL_MOD_PATH="$md_inst" -j16
    unlink "$md_inst/lib/modules/${kver}/source"
    unlink "$md_inst/lib/modules/${kver}/build"
}

## @param target: install target (module|image)
function install_fa-rk3399-linux-4_4() {
    local target=$1

    [ "${target}" == "help" ] \
        && echo "Usage: embox_packages.sh ${md_id} install <target>[image|module]" \
        && return

    export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH
    local kver=$(make ARCH=arm64 CROSS_COMPILE=aarch64-linux- kernelrelease)
    cp ${scriptdir}/scriptmodules/${md_type}/fa-rk3399-linux-4_4/partmap.txt ${md_inst}
    case "${target}" in
        "image")
            md_ret_files=(
                'kernel.img'
                'resource.img'
            )
            ;;
        "module")
            _install_module_fa-rk3399-linux-4_4
            ;;
        *)
            _install_module_fa-rk3399-linux-4_4
            md_ret_files=(
                'kernel.img'
                'resource.img'
            )
            ;;
    esac
}

function upgrade_tf_fa-rk3399-linux-4_4() {
    local dev="$1"

    [ "${dev}" == "help" ] \
        && echo "Usage: embox_packages.sh ${md_id} upgrade_tf /dev/sdX" \
        && return

    [[ -z "${dev}" ]] \
        && echo "Usage: embox_packages.sh ${md_id} upgrade_tf /dev/sdX" \
        && return

    local devname=$(basename ${dev})
    local sdupdate="${scriptdir}/tmp/build/sd_update-bin/x86_64/sd_update"
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

function upgrade_ssh_fa-rk3399-linux-4_4() {
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