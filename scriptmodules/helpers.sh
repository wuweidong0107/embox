#!/bin/bash

## @file helpers.sh
## @brief RetroPie helpers library
## @copyright GPLv3

## @fn printMsgs()
## @param type style of display to use - dialog, console or heading
## @param message string or array of messages to display
## @brief Prints messages in a variety of ways.
function printMsgs() {
    local type="$1"
    shift

    for msg in "$@"; do
        [[ "$type" == "dialog" ]] && dialog --backtitle "$__backtitle" --cr-wrap --no-collapse --msgbox "$msg" 20 60 >/dev/tty
        [[ "$type" == "console" ]] && echo -e "$msg"
        [[ "$type" == "heading" ]] && echo -e "\n= = = = = = = = = = = = = = = = = = = = =\n$msg\n= = = = = = = = = = = = = = = = = = = = =\n"
    done
    return 0
}

## @fn gitPullOrClone()
## @param dest destination directory
## @param repo repository to clone or pull from
## @param branch branch to clone or pull from (optional)
## @param commit specific commit to checkout (optional - requires branch to be set)
## @param depth depth parameter for git. (optional)
## @brief Git clones or pulls a repository.
## @details depth parameter will default to 1 (shallow clone) so long as __persistent_repos isn't set.
## A depth parameter of 0 will do a full clone with all history.
function gitPullOrClone() {
    local dir="$1"
    local repo="$2"
    local branch="$3"
    [[ -z "$branch" ]] && branch="master"
    local commit="$4"
    local depth="$5"
    if [[ -z "$depth" && "$__persistent_repos" -ne 1 && -z "$commit" ]]; then
        depth=1
    else
        depth=0
    fi

    if [[ -d "$dir/.git" ]]; then
        pushd "$dir" > /dev/null
        echo "console" "Updating \"$repo\" \"$dir\" \"$branch\""
        runCmd git checkout "$branch"
        runCmd git pull
        runCmd git submodule update --init --recursive --progress
        popd > /dev/null
    else
        local git="git clone --recursive"
        if [[ "$depth" -gt 0 ]]; then
            git+=" --depth $depth"
        fi
        git+=" --branch $branch"
        echo "console" "$git \"$repo\" \"$dir\""
        runCmd $git "$repo" "$dir"
    fi

    if [[ -n "$commit" ]]; then
        echo "console" "Winding back $repo->$branch to commit: #$commit"
        git -C "$dir" branch -D "$commit" &>/dev/null
        runCmd git -C "$dir" checkout -f "$commit" -b "$commit"
    fi

    branch=$(runCmd git -C "$dir" rev-parse --abbrev-ref HEAD)
    commit=$(runCmd git -C "$dir" rev-parse HEAD)
    echo "console" "HEAD is now in branch '$branch' at commit '$commit'"
}

# @fn fnExists()
# @param name name of function to check for
# @brief Checks if function name exists.
# @retval 0 if the function name exists
# @retval 1 if the function name does not exist
function fnExists() {
    declare -f "$1" > /dev/null
    return $?
}

## @fn runCmd()
## @param command command to run
## @brief Calls command and record any non zero return codes for later printing.
## @return whatever the command returns.
function runCmd() {
    local ret
    "$@"
    ret=$?
    if [[ "$ret" -ne 0 ]]; then
        md_ret_errors+=("Error running '$*' - returned $ret")
    fi
    return $ret
}

## @fn getDepends()
## @param packages package / space separated list of packages to install
## @brief Installs packages if they are not installed.
## @retval 0 on success
## @retval 1 on failure
function getDepends() {
    apt install $@
    ret=$?
    return $ret
}

## @fn download()
## @param url url of file
## @param dest destination name (optional)
## @brief Download a file
## @details Download a file - if the dest parameter is ommitted, the file will be downloaded to the current directory
## @retval 0 on success
function download() {
    local url="$1"
    local dest="$2"

    # if no destination, get the basename from the url (supported by GNU basename)
    [[ -z "$dest" ]] && dest="${PWD}/$(basename "$url")"

    # set up additional file descriptor for stdin
    exec 3>&1

    local cmd_err
    local ret
    # get the last non zero exit status (ignoring tee)
    set -o pipefail
    printMsgs "console" "Downloading $url ..."
    # capture stderr - while passing both stdout and stderr to terminal
    # wget by default outputs the progress to stderr - if we force it to log to stdout, we get no useful error msgs
    # however this code will be useful when switching away from wget to curl. For now it's best left with -nv
    # no progress, but less log spam, and output can be useful on failure
    cmd_err=$(wget -nv -O"$dest" "$url" 2>&1 1>&3 | tee /dev/stderr)
    ret="$?"
    set +o pipefail
    # remove stdin copy
    exec 3>&-

    # if download failed, remove file, log error and return error code
    if [[ "$ret" -ne 0 ]]; then
        rm "$dest"
        md_ret_errors+=("URL $url failed to download.\n\n$cmd_err")
        return "$ret"
    fi
    return 0
}

## @fn downloadAndVerify()
## @param url url of file
## @param dest destination file (optional)
## @brief Download a file and a corresponding .asc signature and verify the contents
## @details Download a file and a corresponding .asc signature and verify the contents.
## The .asc file will be downloaded to verify the file, but will be removed after downloading.
## If the dest parameter is omitted, the file will be downloaded to the current directory
## @retval 0 on success
function downloadAndVerify() {
    local url="$1"
    local dest="$2"
set -x
    # if no destination, get the basename from the url (supported by GNU basename)
    [[ -z "$dest" ]] && dest="${PWD}/$(basename "$url")"

    local cmd_out
    local ret=1
    if download "${url}.asc" "${dest}.asc"; then
        if download "$url" "$dest"; then
            cmd_out="$(gpg --verify "${dest}.asc" 2>&1)"
            ret="$?"
            if [[ "$ret" -ne 0 ]]; then
                md_ret_errors+=("$dest failed signature check:\n\n$cmd_out")
            fi
        fi
    fi
set +x
    sleep 5
    return "$ret"
}

## @fn downloadAndExtract()
## @param url url of archive
## @param dest destination folder for the archive
## @param optional additional parameters to pass to the decompression tool.
## @brief Download and extract an archive
## @details Download and extract an archive.
## @retval 0 on success
function downloadAndExtract() {
    local url="$1"
    local dest="$2"
    shift 2
    local opts=("$@")

    local ext="${url##*.}"
    local cmd=(tar -xv)
    local is_tar=1

    local ret
    case "$ext" in
        gz|tgz)
            cmd+=(-z)
            ;;
        bz2)
            cmd+=(-j)
            ;;
        xz)
            cmd+=(-J)
            ;;
        exe|zip)
            is_tar=0
            local tmp="$(mktemp -d)"
            local file="${url##*/}"
            runCmd wget -q -O"$tmp/$file" "$url"
            runCmd unzip "${opts[@]}" -o "$tmp/$file" -d "$dest"
            rm -rf "$tmp"
            ret=$?
    esac

    if [[ "$is_tar" -eq 1 ]]; then
        mkdir -p "$dest"
        cmd+=(-C "$dest" "${opts[@]}")

        runCmd "${cmd[@]}" < <(wget -q -O- "$url")
        ret=$?
    fi

    return $ret
}

## @fn downloadAndExtract()
## @param url url of archive
## @param dest destination folder for the archive
## @param optional additional parameters to pass to the decompression tool.
## @brief Download and extract an archive
## @details Download and extract an archive.
## @retval 0 on success
function extract() {
    local src="$1"
    local dest="$2"
    shift 2
    local opts=("$@")

    local ext="${src##*.}"
    local cmd=(tar -xv)
    local is_tar=1

    local ret
    case "$ext" in
        gz|tgz)
            cmd+=(-z)
            ;;
        bz2)
            cmd+=(-j)
            ;;
        xz)
            cmd+=(-J)
            ;;
        exe|zip)
            is_tar=0
            runCmd unzip "${opts[@]}" -o "$src" -d "$dest"
            ret=$?
    esac

    if [[ "$is_tar" -eq 1 ]]; then
        mkdir -p "$dest"
        cmd+=(-C "$dest" "${opts[@]}")

        runCmd "${cmd[@]}" < <(cat ${src})
        ret=$?
    fi
}