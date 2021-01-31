#!/bin/bash

emb_module_id="tetris"
emb_module_desc="tetris - Tetris in C and NCURSES"
emb_module_help="https://github.com/brenns10/tetris"
emb_module_section="game"

function depends_tetris() {
    local depends=(libsdl-mixer1.2-dev libncurses5-dev)
    getDepends "${depends[@]}"
}

function sources_tetris() {
    gitPullOrClone "$md_build" https://github.com/brenns10/tetris
}

function build_tetris() {
    make
}