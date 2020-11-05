#!/bin/bash

## @fn gitPullOrClone()
## @param dest destination directory
## @param repo repository to clone or pull from
## @param branch branch to clone or pull from (optional)
## @param commit specific commit to checkout (optional - requires branch to be set)
## @param depth depth parameter for git. (optional)
## @brief Git clones or pulls a repository.
## @details depth parameter will default to 1 (shallow clone) so long as __persistent_repos isn't set.
## A depth parameter of 0 will do a full clone with all history.
function gitPullOrClone()
{
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
function fnExists()
{
    declare -f "$1" > /dev/null
    return $?
}

## @fn runCmd()
## @param command command to run
## @brief Calls command and record any non zero return codes for later printing.
## @return whatever the command returns.
function runCmd()
{
    local ret
    "$@"
    ret=$?
    if [[ "$ret" -ne 0 ]]; then
        md_ret_errors+=("Error running '$*' - returned $ret")
    fi
    return $ret
}
