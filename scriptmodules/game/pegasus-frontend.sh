#!/bin/bash

emb_module_id="pegasus-frontend"
emb_module_desc="pegasus-frontend - A cross platform, customizable graphical frontend for launching emulators"
emb_module_help="https://github.com/mmatyas/pegasus-frontend"
emb_module_section="game"

function sources_pegasus-frontend() {
    gitPullOrClone "$md_build" https://github.com/mmatyas/pegasus-frontend alpha14
}

function build_pegasus-frontend() {

    #export PATH=/opt/Qt5.14.1/5.14.1/gcc_64/bin/:$PATH

    mkdir -p build && cd build
    qmake ..
    make
}

function install_pegasus-frontend() {
    md_ret_files=(
        './build/src/app/pegasus-fe'
    )
}