#!/bin/bash

function setup_env() {
    get_emb_depends
}

function get_emb_depends() {
    local depends=(git dialog wget gcc g++ build-essential)

    if ! getDepends "${depends[@]}"; then
        fatalError "Unable to install packages required by $0 - ${md_ret_errors[@]}"
    fi
}