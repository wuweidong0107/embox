#!/bin/bash

emb_module_id="devmem2"
emb_module_desc="devmem2 - physical memory access tool."
emb_module_help="
Usage:  ./devmem2 { address } [ type [ data ] ]
    address : memory address to act upon
    type    : access operation type : [b]yte, [h]alfword, [w]ord
    data    : data to be written
"
emb_module_section="hardware"

function sources_devmem2() {
    download http://sources.buildroot.net/devmem2/devmem2.c "$md_build"/devmem2.c
}

function build_devmem2() {
    gcc devmem2.c -o devmem2
}

function install_devmem2() {
    md_ret_files=(
        'devmem2'
    )
}