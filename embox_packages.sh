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

emb_registerAllModules

if [[ $# -gt 0 ]]; then
    emb_callModule $@
else
    emb_printUsageinfo
fi