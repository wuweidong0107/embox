#!/bin/bash

emb_module_id="setup"
emb_module_desc="GUI based setup for embox"
emb_module_section=""

function package_setup() {
    local idx="$1"
    local md_id="${__mod_id[$idx]}"

    declare -A option_msgs=(
        ["U"]="Update (from source)"
        ["B"]="Install from pre-compiled binary"
        ["S"]="Install from source"
    )

    while true; do
        local options=()

        if emb_isInstalled "$idx"; then
            options+=(U "${option_msgs[U]}")
        else
            options+=(S "${option_msgs[S]}")
        fi

        local help="${__mod_desc[$idx]}\n\n${__mod_help[$idx]}"
        if [[ -n "$help" ]]; then
            options+=(H "Package Help")
        fi

        cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --menu "Choose an option for ${__mod_id[$idx]}\n$status" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        case "$choice" in
            U|S)
                case "$choice" in
                    U) mode="_update_" ;;
                    S) mode="_source_" ;;
                esac
                dialog --defaultno --yesno "Are you sure you want to ${option_msgs[$choice]}?" 22 76 2>&1 >/dev/tty || continue
                emb_installModule "$idx" "$mode" "force"
                ;;
            H)
                printMsgs "dialog" "$help"
                ;;
            *)
                break
                ;;
        esac
    done
}

function section_gui_setup() {
    local section="$1"
    local default=""

    while true; do
        local options=()
        local pkgs=()
        local idx

        for idx in $(emb_getSectionIds $section); do
            if emb_isInstalled "$idx"; then
                installed="\Zb(Installed)\Zn"
                ((num_pkgs++))
            else
                installed=""
            fi
            pkgs+=("$idx" "${__mod_id[$idx]} ${installed}" "$idx ${__mod_desc[$idx]}"$'\n\n'"${__mod_help[$idx]}")
        done

        options+=(
            I "Install all ${__sections[$section]} packages" "This will install all $section packages."
            X "Remove all ${__sections[$section]} packages" "This will remove all $section packages."
        )
        options+=("${pkgs[@]}")

        local cmd=(dialog --colors --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --default-item "$default" --menu "Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            # remove HELP
            choice="${choice[@]:5}"
            # get id of menu item
            default="${choice/%\ */}"
            # remove id
            choice="${choice#* }"
            printMsgs "dialog" "$choice"
            continue
        fi

        default="$choice"

        case "$choice" in
            I)
                echo "Remove all"
                ;;
            X)
                echo "Install all"
                ;;
            *)
                package_setup "$choice"
                ;;
        esac
    done
}

function packages_gui_setup() {
    local section
    local default
    local options=()

    for section in book bsp hardware game graphic media misc; do
        options+=(${section} "Manage ${__sections[$section]} packages" "$section Choose top install/update/configure packages from the ${__sections[$section]}")
    done

    local cmd
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --default-item "$default" --menu "Choose an option" 22 76 16)

        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        section_gui_setup "$choice"
        default="$choice"
    done
}

function gui_setup() {
    while true; do
        local commit=$(git -C "$scriptdir" log -1 --pretty=format:"%cr (%h)")

        cmd=(dialog --backtitle "$__backtitle" --title "Embox-Setup Script" --cancel-label "Exit" --item-help --help-button --default-item "$default" --menu "Version: $__version - Last Commit: $commit\n" 22 76 16)
        options=(
            P "Manage packages"
            "P Install/Remove and Configure the various components of embox, including hardware, book, module, media."

            S "Update Embox-Setup script"
            "S Update this Embox-Setup script. This will update this main management script only, but will not update any software packages. To update packages use the 'Update' option from the main menu, which will also update the RetroPie-Setup script."

            X "Uninstall Embox"
            "X Uninstall Embox completely."
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        
        case "$choice" in
            P)
                packages_gui_setup
                ;;
            S)
                echo "updatescript_setup"
                ;;
            X)
                echo "uninstall_setup"
                ;;
        esac    
    done
}