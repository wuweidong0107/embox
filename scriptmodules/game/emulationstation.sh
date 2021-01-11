#!/bin/bash

emb_module_id="emulationstation"
emb_module_desc="emulationstation - A flexible emulator front-end"
emb_module_help="https://github.com/RetroPie/EmulationStation"
emb_module_section="game"

function sources_emulationstation() {
    gitPullOrClone "$md_build" https://github.com/RetroPie/EmulationStation
}
