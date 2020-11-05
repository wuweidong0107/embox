#!/bin/bash

emb_module_id="fb-test-app"
emb_module_desc="fb-test-app - framebuffer test tools"
emb_module_help="/opt/embox/hardwares/fb-test-app"
emb_module_section="hardware"

function sources_fb-test-app() {
    gitPullOrClone "$md_build" https://github.com/wuweidong0107/fb-test-app.git
}

function build_fb-test-app() {
    make clean
    make
}

function install_fb-test-app() {
    md_ret_files=(
        'fb-string'
        'fb-test'
        'offset'
        'perf'
        'rect'
    )
}