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

## @fn fatalError()
## @param message string or array of messages to display
## @brief Calls PrintMsgs with "heading" type, and exits immediately.
function fatalError() {
    printMsgs "heading" "Error"
    echo -e "$1"
    exit 1
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
        printMsgs "console" "Updating \"$repo\" \"$dir\" \"$branch\""
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
        printMsgs "console" "$git \"$repo\" \"$dir\""
        runCmd $git "$repo" "$dir"
    fi

    if [[ -n "$commit" ]]; then
        printMsgs "console" "Winding back $repo->$branch to commit: #$commit"
        git -C "$dir" branch -D "$commit" &>/dev/null
        runCmd git -C "$dir" checkout -f "$commit" -b "$commit"
    fi

    branch=$(runCmd git -C "$dir" rev-parse --abbrev-ref HEAD)
    commit=$(runCmd git -C "$dir" rev-parse HEAD)
    printMsgs "console" "HEAD is now in branch '$branch' at commit '$commit'"
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

## @fn compareVersions()
## @param version first version to compare
## @param operator operator to use (lt le eq ne ge gt)
## @brief version second version to compare
## @retval 0 if the comparison was true
## @retval 1 if the comparison was false
function compareVersions() {
    dpkg --compare-versions "$1" "$2" "$3" >/dev/null
    return $?
}

## @fn hasPackage()
## @param package name of Debian package
## @param version requested version (optional)
## @param comparison type of comparison - defaults to `ge` (greater than or equal) if a version parameter is provided.
## @brief Test for an installed Debian package / package version.
## @retval 0 if the requested package / version was installed
## @retval 1 if the requested package / version was not installed
function hasPackage() {
    local pkg="$1"
    local req_ver="$2"
    local comp="$3"
    [[ -z "$comp" ]] && comp="ge"

    local ver
    local status
    local out=$(dpkg-query -W --showformat='${Status} ${Version}' $1 2>/dev/null)
    if [[ "$?" -eq 0 ]]; then
        ver="${out##* }"
        status="${out% *}"
    fi

    local installed=0
    [[ "$status" == *"ok installed" ]] && installed=1
    # if we are not checking version
    if [[ -z "$req_ver" ]]; then
        # if the package is installed return true
        [[ "$installed" -eq 1 ]] && return 0
    else
        # if checking version and the package is not installed we need to clear "ver" as it may contain
        # the version number of a removed package and give a false positive with compareVersions.
        # we still need to do the version check even if not installed due to the varied boolean operators
        [[ "$installed" -eq 0 ]] && ver=""

        compareVersions "$ver" "$comp" "$req_ver" && return 0
    fi
    return 1
}

## @fn aptUpdate()
## @brief Calls apt-get update (if it has not been called before).
function aptUpdate() {
    if [[ "$__apt_update" != "1" ]]; then
        apt-get update
        __apt_update="1"
    fi
}

## @fn aptInstall()
## @param packages package / space separated list of packages to install
## @brief Calls apt-get install with the packages provided.
function aptInstall() {
    aptUpdate
    apt-get install -y "$@"
    return $?
}

## @fn getDepends()
## @param packages package / space separated list of packages to install
## @brief Installs packages if they are not installed.
## @retval 0 on success
## @retval 1 on failure
function getDepends() {
    local apt_pkgs=()
    local pkg

    for pkg in "$@"; do
        # add package to apt_pkgs for installation if not installed
        if ! hasPackage "$pkg"; then
            apt_pkgs+=("$pkg")
        fi
    done

    [[ ${#apt_pkgs[@]} -eq 0 ]] && return
    aptInstall --no-install-recommends "${apt_pkgs[@]}"

    for pkg in ${apt_pkgs[@]}; do
        if ! hasPackage "$pkg"; then
            failed+=("$pkg")
        fi
    done

    if [[ ${#failed[@]} -gt 0 ]]; then
        md_ret_errors+=("Could not install package(s): ${failed[*]}.")
        return 1
    fi

    return 0
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

## @fn compareVersions()
## @param version first version to compare
## @param operator operator to use (lt le eq ne ge gt)
## @brief version second version to compare
## @retval 0 if the comparison was true
## @retval 1 if the comparison was false
function compareVersions() {
    dpkg --compare-versions "$1" "$2" "$3" >/dev/null
    return $?
}

## @fn hasFlag()
## @param string string to search in
## @param flag flag to search for
## @brief Checks for a flag in a string (consisting of space separated flags).
## @retval 0 if the flag was found
## @retval 1 if the flag was not found
function hasFlag() {
    local string="$1"
    local flag="$2"
    [[ -z "$string" || -z "$flag" ]] && return 1

    if [[ "$string" =~ (^| )$flag($| ) ]]; then
        return 0
    else
        return 1
    fi
}

## @fn isPlatform()
## @param platform
## @brief Test for current platform / platform flags.
function isPlatform() {
    local flag="$1"
    if hasFlag "${__platform_flags[*]}" "$flag"; then
        return 0
    fi
    return 1
}

## @fn embSwap()
## @param command *on* to add swap if needed and *off* to remove later
## @param memory total memory needed (swap added = memory needed - available memory)
## @brief Adds additional swap to the system if needed.
function embSwap() {
    local command=$1
    local swapfile="${scriptdir}/tmp/swap"
    case $command in
        on)
            embSwap off
            local needed=$2
            local size=$((needed - __memory_avail))
            mkdir -p "${scriptdir}/tmp/"
            if [[ $size -ge 0 ]]; then
                echo "Adding $size MB of additional swap"
                fallocate -l ${size}M "$swapfile"
                chmod 600 "$swapfile"
                mkswap "$swapfile"
                swapon "$swapfile"
            fi
            ;;
        off)
            echo "Removing additional swap"
            swapoff "$swapfile" 2>/dev/null
            rm -f "$swapfile"
            ;;
    esac
}