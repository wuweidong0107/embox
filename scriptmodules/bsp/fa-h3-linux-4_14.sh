#!/bin/bash

emb_module_id="fa-h3-linux-4_14"
emb_module_desc="kernel for friendlyelec h3"
emb_module_help="kernel-v5.4 for FriendlyElec h3 boards"
emb_module_section="bsp"

function depends_fa-h3-linux-4_14() {
    emb_callModule fa-toolchain
}

function sources_fa-h3-linux-4_14() {
    gitPullOrClone "$md_build" https://github.com/friendlyarm/kernel-rockchip nanopi-r2-v5.4.y
}

function build_fa-h3-linux-4_14() {
    export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH

    touch .scmversion
    make ARCH=arm CROSS_COMPILE=aarch64-linux- nanopi-r2_linux_defconfig
    make ARCH=arm CROSS_COMPILE=aarch64-linux- -j16
}

function _install_module_fa-h3-linux-4_14() {
    make ARCH=arm CROSS_COMPILE=aarch64-linux- modules_install INSTALL_MOD_PATH="$md_inst" -j16
    unlink "$md_inst/lib/modules/${kver}/source"
    unlink "$md_inst/lib/modules/${kver}/build"
}

## @param target: install target (module|image)
function install_fa-h3-linux-4_14() {
    local target=$1

    [ "${target}" == "help" ] \
        && echo "Usage: embox_packages.sh ${md_id} install <target>[image|module]" \
        && return

    export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH
    local kver=$(make ARCH=arm CROSS_COMPILE=aarch64-linux- kernelrelease)
    cp ${scriptdir}/scriptmodules/${md_type}/fa-h3-linux-4_14/partmap.txt ${md_inst}
    case "${target}" in
        "image")
            md_ret_files=(
                'kernel.img'
                'resource.img'
            )
            ;;
        "module")
            _install_module_fa-h3-linux-4_14
            ;;
        *)
            _install_module_fa-h3-linux-4_14
            md_ret_files=(
                'kernel.img'
                'resource.img'
            )
            ;;
    esac
}

function upgrade_tf_fa-h3-linux-4_14() {
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

function upgrade_usb_fa-h3-linux-4_14() {
    # TODO
    echo "unsupported yet"
}

function upgrade_ssh_fa-h3-linux-4_14() {
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
            echo -e "\nRun command on RK3328:\n $ cd root\n $ ./sd_update -d /dev/mmcblkX -p partmap.txt"
            ;;
        "module")
            scp -r ${md_inst}/lib root@${ip}:/
            ;;
        *)
            scp -r ${md_inst}/lib root@${ip}:/
            scp ${data[*]} ${dest}
            echo -e "\nRun command on RK3328:\n $ cd root\n $ ./sd_update -d /dev/mmcblkX -p partmap.txt"
            ;;
    esac
}