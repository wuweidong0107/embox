#!/bin/bash

emb_module_id="qt"
emb_module_desc="qt - a cross-platform application development framework"
emb_module_help="https://wiki.qt.io/About_Qt"
emb_module_section="graphics"

function depends_qt() {
    if isPlatform "x86" && [[ "${__target_platform}" == "aarch64" ]]; then
        emb_callModule fa-toolchain
    fi
}

function sources_qt() {
    download "http://download.qt.io/archive/qt/5.12/5.12.10/single/qt-everywhere-src-5.12.10.tar.xz" "${md_build}"/qt-everywhere-src-5.12.10.tar.xz
}

function build_qt() {
    if isPlatform "x86" && [[ "${__target_platform}" == "aarch64" ]]; then
        export PATH=${rootdir}/bsp/fa-toolchain/opt/FriendlyARM/toolchain/6.4-aarch64/bin/:$PATH
        cd qt-everywhere-src-5.12.10
        ./configure -recheck-all -release -extprefix /opt/aarch64_qt5.12.10 -xplatform linux-aarch64-gnu-g++ -no-opengl -no-openssl -nomake tests -no-compile-examples -nomake examples -gif -ico -qt-libpng -qt-libjpeg -qt-sqlite
        make -j16
    else
        exit 0
    fi
}

function install_qt() {
    if isPlatform "x86" && [[ "${__target_platform}" == "aarch64" ]]; then
        set -x
        cd qt-everywhere-src-5.12.10
        make install
        set +x
    fi
}
