#!/bin/bash

emb_module_id="dtc"
emb_module_desc="Device Tree Compiler"
emb_module_help="Device Tree Compiler"
emb_module_section="misc"

function depends_dtc() {
    :
}

function sources_dtc() {
    gitPullOrClone "$md_build" https://git.kernel.org/pub/scm/utils/dtc/dtc.git v1.6.0
}

function build_dtc() {
    :
}

function install_dtc() {
    :
}