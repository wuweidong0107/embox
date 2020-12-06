#!/bin/bash

emb_module_id="lr-fbneo"
emb_module_desc="Arcade emu - FinalBurn Neo port for libretro"
emb_module_help="NULL"
emb_module_section="misc"

function sources_lr-fbneo() {
    gitPullOrClone "$md_build" https://github.com/libretro/FBNeo.git
}

function build_lr-fbneo() {
    cd src/burner/libretro
    local params=()
    make "${params[@]}"
    md_ret_require="${md_build}/src/burner/libretro/fbneo_libretro.so"
}

function install_lr-fbneo() {
    md_ret_files=(
        'fba.chm'
        'src/burner/libretro/fbneo_libretro.so'
        'gamelist.txt'
        'whatsnew.html'
        'metadata'
        'dats'
    )
}