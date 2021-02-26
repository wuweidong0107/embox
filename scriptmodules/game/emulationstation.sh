#!/bin/bash

emb_module_id="emulationstation"
emb_module_desc="emulationstation - A flexible emulator front-end"
emb_module_help="https://github.com/RetroPie/EmulationStation"
emb_module_section="game"

function sources_emulationstation() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/EmulationStation stable "" 10000
}

function build_emulationstation() {
    local params=(-DFREETYPE_INCLUDE_DIRS=/usr/include/freetype2/)
    cmake . "${params[@]}"
    make
    md_ret_require="$md_build/emulationstation"
}

function install_emulationstation() {
    md_ret_files=(
        'CREDITS.md'
        'emulationstation'
        'emulationstation.sh'
        'GAMELISTS.md'
        'README.md'
        'THEMES.md'
    )
}