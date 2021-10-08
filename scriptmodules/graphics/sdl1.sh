#!/bin/bash

emb_module_id="sdl1"
emb_module_desc="sdl1 - Simple Directmedia Layer, 1.2 branch"
emb_module_help="https://github.com/libsdl-org/SDL-1.2"
emb_module_section="media"

function sources_sdl1() {
    gitPullOrClone "$md_build" https://github.com/libsdl-org/SDL-1.2 main
}

function build_sdl1() {
    ./configure --prefix="${md_inst}"
    make

    # build test
    make install    # for building test
    cd test
    SDL_CONFIG=${md_inst}/bin/sdl-config ./configure --prefix="${md_inst}/test"
    make
}