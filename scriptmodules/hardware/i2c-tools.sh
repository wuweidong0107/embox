#!/bin/bash

emb_module_id="i2c-tools"
emb_module_desc="i2c-tools - a set of I2C tools for Linux"
emb_module_help="/opt/embox/hardwares/i2c-tools"
emb_module_section="hardware"

function sources_i2c-tools() {
    gitPullOrClone "$md_build" git://git.kernel.org/pub/scm/utils/i2c-tools/i2c-tools.git
}

function build_i2c-tools() {
    make clean
    make
}

function install_i2c-tools() {
    DESTDIR=${md_inst} PREFIX=/usr/local make install
    make install
    ldconfig
}