#!/bin/bash

emb_module_id="sd_update-bin"
emb_module_desc="sd_update-bin"
emb_module_help="https://github.com/friendlyarm/sd_update-bin"
emb_module_section="bsp"

function sources_sd_update-bin() {
    gitPullOrClone "$md_build" https://github.com/friendlyarm/sd_update-bin main
}