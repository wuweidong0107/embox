#!/bin/bash

emb_module_id="triggerhappy"
emb_module_desc="triggerhappy - A lightweight hotkey daemon."
emb_module_help="https://github.com/wertarbyte/triggerhappy"
emb_module_section="hardware"

function sources_triggerhappy() {
    gitPullOrClone "$md_build" https://github.com/wertarbyte/triggerhappy
}

function build_triggerhappy() {
    make -j16
}

function install_triggerhappy() {
    #make install DESTDIR=${md_inst}
    make install
}