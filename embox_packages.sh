#!/bin/bash

__version="0.0.1"

# main embox install location
rootdir="/opt/embox"

scriptdir="$(dirname "$0")"
scriptdir="$(cd "$scriptdir" && pwd)"
__tmpdir="$scriptdir/tmp"
__builddir="$__tmpdir/build"

__backtitle="Embox Setup. Installation folder: ${rootdir}"

source "$scriptdir/scriptmodules/helpers.sh"
source "$scriptdir/scriptmodules/packages.sh"
source "$scriptdir/scriptmodules/system.sh"

setup_env
emb_registerAllModules

export http_proxy=http://192.168.1.39:1082
export https_proxy=http://192.168.1.39:1082

if [[ $# -gt 0 ]]; then
    emb_callModule $@
else
    emb_printUsageinfo
fi