#!/bin/bash

emb_module_id="c-thread-pool"
emb_module_desc="c-thread-pool - minimal but powerful thread pool in ANSI C"
emb_module_help="https://github.com/Pithikos/C-Thread-Pool"
emb_module_section="misc"
xxx
function depends_c-thread-pool() {
    :
}

function sources_c-thread-pool() {
    gitPullOrClone "$md_build" https://github.com/Pithikos/C-Thread-Pool
}

function build_c-thread-pool() {
    gcc example.c thpool.c -D THPOOL_DEBUG -pthread -o example
}
function install_c-thread-pool() {
    md_ret_files=(
        'example'
    )
}
