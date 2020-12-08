#!/bin/bash

emb_module_id="WiringNP"
emb_module_desc="WiringNP - a GPIO access library for NanoPi-H3/H5"
emb_module_help="https://github.com/friendlyarm/WiringNP"
emb_module_section="hardware"

function sources_WiringNP() {
    gitPullOrClone "$md_build" https://github.com/friendlyarm/WiringNP
}

function build_WiringNP() {
    chmod 755 build
    ./build
}

function install_WiringNP() {
    echo "Already install into /usr/local/lib/"
}