#!/bin/bash

emb_module_id="cmake-examples"
emb_module_desc="cmake-examples - Useful CMake Examples"
emb_module_help="https://github.com/ttroy50/cmake-examples/tree/master/01-basic"
emb_module_section="misc"

function sources_cmake-examples() {
    gitPullOrClone "$md_build" https://github.com/ttroy50/cmake-examples
}