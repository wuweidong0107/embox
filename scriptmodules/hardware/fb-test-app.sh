#!/bin/bash

emb_module_id="fb-test-app"
emb_module_desc="fb-test-app - framebuffer test tools"
emb_module_help="
Build:
[CROSS_COMPILE=arm-linux-] ./embox_packages.sh fb-test-app

Install:
/opt/embox/hardware/fb-test-app/

Usage:
1) show R/G/B
$ fb-test -f fbnum -r -g -b -w -p pattern
Where -f fbnum   = framebuffer device number
      -r         = fill framebuffer with red
      -g         = fill framebuffer with green
      -b         = fill framebuffer with blue
      -w         = fill framebuffer with white
      -p pattern = fill framebuffer with pattern number

2) print string
$ fb-string x y string color bg_color
Where x          = x position of the top left corner
      y          = y position of the top left corner
      string     = String to display
      color      = Text Color
      bg_color   = background Color

Example:
$ fb-test 
$ fb-test -f 0 -r
$ fb-string 100 50 embox 0xff 0x0
"
emb_module_section="hardware"

function sources_fb-test-app() {
    gitPullOrClone "$md_build" https://github.com/wuweidong0107/fb-test-app.git
}

function build_fb-test-app() {
    make clean
    make
}

function install_fb-test-app() {
    md_ret_files=(
        'fb-string'
        'fb-test'
        'offset'
        'perf'
        'rect'
    )
}