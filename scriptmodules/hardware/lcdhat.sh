#!/bin/bash

emb_module_id="lcdhat"
emb_module_desc="lcdhat - app for NanoPi NEO3's LCD HAT"
emb_module_help="https://github.com/wuweidong0107/lcdhat"
emb_module_section="hardware"

function sources_lcdhat() {
    gitPullOrClone "$md_build" https://github.com/wuweidong0107/lcdhat
}

function build_lcdhat() {
    make
}

function install_lcdhat() {
    make install
    md_ret_files=(
        'start.sh'
    )
}