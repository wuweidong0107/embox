#!/bin/bash

emb_module_id="tinyalsa"
emb_module_desc="tinyalsa - library to interface with ALSA"
emb_module_help="/opt/embox/hardwares/tinyalsa"
emb_module_section="hardware"

function sources_tinyalsa() {
    gitPullOrClone "$md_build" https://github.com/tinyalsa/tinyalsa
}

function build_tinyalsa() {
    make clean
    make
}

function install_tinyalsa() {
    #DESTDIR=${md_inst} PREFIX=/usr/local make install
    make install
    ldconfig
}