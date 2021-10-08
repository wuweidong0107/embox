#!/bin/bash

emb_module_id="cmake-demo"
emb_module_desc="cmake-demo - Some cmake study demo"
emb_module_help="https://www.hahack.com/codes/cmake/"
emb_module_section="misc"

function sources_cmake-demo() {
    gitPullOrClone "$md_build" https://github.com/wzpan/cmake-demo
}