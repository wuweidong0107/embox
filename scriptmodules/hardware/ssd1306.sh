#!/bin/bash

emb_module_id="ssd1306"
emb_module_desc="ssd1306 - Userspace driver for OLEDs"
emb_module_help="https://github.com/lexus2k/ssd1306"
emb_module_section="hardware"

function sources_ssd1306() {
    gitPullOrClone "$md_build" https://github.com/lexus2k/ssd1306
}

function build_ssd1306() {
    cd examples/
    for f in $(ls demos); do
        make -f Makefile.linux PROJECT=demos/${f}
    done
}

function install_ssd1306() {
    cp -v bld/demos/*.out "$md_inst/"
}