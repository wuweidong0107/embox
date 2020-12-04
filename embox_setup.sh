#!/bin/bash

#export SHELLOPTS

scriptdir="$(dirname "$0")"
scriptdir="$(cd "$scriptdir" && pwd)"

"$scriptdir/embox_packages.sh" setup gui