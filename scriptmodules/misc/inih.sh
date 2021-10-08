#!/bin/bash

emb_module_id="inih"
emb_module_desc="inih - simple .INI file parser in C"
emb_module_help="https://github.com/benhoyt/inih"
emb_module_section="misc"

function depends_inih() {
    :
}

function sources_inih() {
    gitPullOrClone "$md_build" https://github.com/benhoyt/inih
}

function build_inih() {
    :
}

function install_inih() {
    :
}