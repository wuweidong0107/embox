#!/bin/bash

emb_module_id="mjpg-streamer"
emb_module_desc="mjpg-streamer - a command line app for stream JPEG"
emb_module_help="https://github.com/jacksonliam/mjpg-streamer"
emb_module_section="media"

function depends_mjpg-streamer() {
    local depends=(libjpeg8-dev)
    getDepends "${depends[@]}"
}

function sources_mjpg-streamer() {
    gitPullOrClone "$md_build" https://github.com/jacksonliam/mjpg-streamer
}

function build_mjpg-streamer() {
    cd mjpg-streamer-experimental
    make CMAKE_BUILD_TYPE=Debug
}
function install_mjpg-streamer() {
    :
}
