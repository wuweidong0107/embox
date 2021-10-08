#!/bin/bash

emb_module_id="nanohat-oled"
emb_module_desc="nanohat-oled - physical memory access tool."
emb_module_help="
Usage:  ./nanohat-oled { address } [ type [ data ] ]
    address : memory address to act upon
    type    : access operation type : [b]yte, [h]alfword, [w]ord
    data    : data to be written
"
emb_module_section="hardware"

function sources_nanohat-oled() {
    download http://sources.buildroot.net/nanohat-oled/nanohat-oled.c "$md_build"/nanohat-oled.c
}

function build_nanohat-oled() {
    gcc nanohat-oled.c -o nanohat-oled
}

function install_nanohat-oled() {
    md_ret_files=(
        'nanohat-oled'
    )
}