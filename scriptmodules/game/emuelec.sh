#!/bin/bash

emb_module_id="EmuELEC"
emb_module_desc="EmuELEC - A retro game emulation distribution"
emb_module_help="https://github.com/EmuELEC/EmuELEC"
emb_module_section="game"

function sources_EmuELEC() {
    gitPullOrClone "$md_build" https://github.com/EmuELEC/EmuELEC
}
