#!/bin/bash

__version="0.0.1"

scriptdir="$(dirname "$0")"
scriptdir="$(cd "$scriptdir" && pwd)"
__tmpdir="$scriptdir/tmp"
__builddir="$__tmpdir/build"

source "$scriptdir/scriptmodules/helpers.sh"
source "$scriptdir/scriptmodules/packages.sh"

emb_registerAllModules

if [[ $# -gt 0 ]]; then
    emb_callModule $@
else
    emb_printUsageinfo
fi