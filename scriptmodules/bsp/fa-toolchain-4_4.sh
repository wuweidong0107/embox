#!/bin/bash

emb_module_id="fa-toolchain-4_4"
emb_module_desc="gcc 4.4 for friendlyelec s3c2451/s3c2416"
emb_module_help="gcc 4.4 for friendlyelec s3c2451/s3c2416"
emb_module_section="bsp"

function sources_fa-toolchain-4_4() {
    :
}

function install_fa-toolchain-4_4() {
    local tc="arm-linux-gcc-4.4.3.tar.gz"

    if [[ ! -e "${tc}" ]]; then
        echo "Error: missing ${tc} in ${md_build}"
        exit 0
    fi

    extract ${tc} "$md_inst"
}