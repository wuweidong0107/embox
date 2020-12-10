#!/bin/bash

emb_module_id="romfetcher"
emb_module_desc="romfetcher - A very easy rom downloader implemented for RetroPie"
emb_module_help="https://github.com/maximilianvoss/romfetcher"
emb_module_section="game"

function depends_romfetcher() {
    local depends=(libsdl2-ttf-dev libsdl2-image-dev \
        libsdl2-dev libcurl4-openssl-dev libsqlite3-dev \
        libcurl4-openssl-dev libssl-dev)
    getDepends "${depends[@]}"
    
}

function sources_romfetcher() {
    gitPullOrClone "$md_build" https://github.com/maximilianvoss/romfetcher
}

function build_romfetcher() {
    cmake -G "Unix Makefiles"
    make
}

function install_romfetcher() {
    make install
}