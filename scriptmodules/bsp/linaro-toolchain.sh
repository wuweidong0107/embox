#!/bin/bash

emb_module_id="linaro-toolchain"
emb_module_desc="linaro-toolchain"
emb_module_help="/opt/embox/hardwares/linaro-toolchain"
emb_module_section="bsp"

function sources_linaro-toolchain() {
    local url="https://releases.linaro.org/components/toolchain/binaries/6.4-2017.08/aarch64-linux-gnu/gcc-linaro-6.4.1-2017.08-x86_64_aarch64-linux-gnu.tar.xz"
    downloadAndExtract "${url}" "${md_build}"
}