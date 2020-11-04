#!/bin/bash

function emb_listFunctions() {
    local idx
    local mod_id
    local desc
    local mode
    local func

    echo -e "Index/ID:                 Description:                                 List of available actions"
    echo "-----------------------------------------------------------------------------------------------------------------------------------"
    for idx in ${__mod_idx[@]}; do
        mod_id=${__mod_id[$idx]};
        printf "%d/%-20s: %-42s :" "$idx" "$mod_id" "${__mod_desc[$idx]}"
        while read mode; do
            # skip private module functions (start with an underscore)
            [[ "$mode" = _* ]] && continue
            mode=${mode//_$mod_id/}
            echo -n " $mode"
        done < <(compgen -A function -X \!*_$mod_id)
        echo -n " help"
        echo ""
    done
    echo "==================================================================================================================================="
}

function emb_printUsageinfo() {
    echo -e "Usage:\n$0 <Index # or ID>\nThis will run the actions depends, sources, build, install, configure and clean automatically.\n"
    echo -e "Alternatively, $0 can be called as\n$0 <Index # or ID [depends|sources|build|install|configure|clean|remove]\n"
    echo    "Definitions:"
    echo    "depends:    install the dependencies for the module"
    echo    "sources:    install the sources for the module"
    echo    "build:      build/compile the module"
    echo    "install:    install the compiled module"
    echo    "configure:  configure the installed module (es_systems.cfg / launch parameters etc)"
    echo    "clean:      remove the sources/build folder for the module"
    echo    "help:       get additional help on the module"
    echo -e "\nThis is a list of valid modules/packages and supported commands:\n"
    emb_listFunctions
}

function emb_callModule() {
    local req_id="$1"
    local mode="$2"
    local md_id
    local md_idx

    local md_build="${__builddir}/${md_id}"

    if [[ "$req_id" =~ ^[0-9]+$ ]]; then
        md_id="$(emb_getIdFromIdx $req_id)"
        md_idx="$req_id"
    else
        md_idx="$(emb_getIdxFromId $req_id)"
        md_id="$req_id"
    fi

    if [[ -z "${mode}" ]]; then
        local modes=(depends sources build install configure clean)
        for mode in "${modes[@]}"; do
            emb_callModule "$md_idx" "$mode" || return 1
        done
        return 0
    fi

    # create function name
    local function="${mode}_${md_id}"
    fnExists "$function" && "$function" "$@"
    return 0
}

function emb_registerModule() {
    local module_idx="$1"
    local module_path="$2"
    local module_type="$3"
    local emb_module_id=""
    local emb_module_desc=""
    local emb_module_help=""
    local emb_module_section=""

    source "$module_path"

    # check if submodule has define emb_module_id emb_module_desc
    for var in emb_module_id emb_module_desc; do
        if [[ -z "${!var}" ]]; then
            echo "Module $module_path is missing valid $var"
            error=1
        fi
    done
    [[ $error -eq 1 ]] && exit 1

    __mod_idx+=("$module_idx")
    __mod_id["$module_idx"]="$emb_module_id"
    __mod_type["$module_idx"]="$module_type"
    __mod_desc["$module_idx"]="$emb_module_desc"
    __mod_help["$module_idx"]="$emb_module_help"
    __mod_section["$module_idx"]="$emb_module_section"

    # id to idx mapping via associative array
    __mod_id_to_idx["$emb_module_id"]="$module_idx"    
}

function emb_registerModuleDir() {
    local module_idx="$1"
    local module_dir="$2"
    for module in $(find "${scriptdir}/scriptmodules/$2" -maxdepth 1 -name "*.sh" | sort); do
        emb_registerModule ${module_idx} "${module}" "${module_dir}"
        ((module_idx++))
    done
}

function emb_registerAllModules() {
    __mod_idx=()
    __mod_id=()
    __mod_type=()
    __mod_desc=()
    __mod_help=()
    __mod_section=()

    emb_registerModuleDir 100 "hardwares"
}

function emb_getIdxFromId() {
    echo "${__mod_id_to_idx[$1]}"
}

function emb_getIdFromIdx() {
    echo "${__mod_id[$1]}"
}