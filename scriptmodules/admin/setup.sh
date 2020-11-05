#!/bin/bash

emb_module_id="setup"
emb_module_desc="GUI based setup for embox"
emb_module_section=""

function gui_setup() 
{
    while true; do
        local commit=$(git -C "$scriptdir" log -1 --pretty=format:"%cr (%h)")

        cmd=(dialog --backtitle "$__backtitle" --title "Embox-Setup Script" --cancel-label "Exit" --item-help --help-button --default-item "$default" --menu "Version: $__version - Last Commit: $commit\n" 22 76 16)
        options=(
            P "Manage packages"
            "P Install/Remove and Configure the various components of embox, including hardware, books, modules, medias."

            S "Update Embox-Setup script"
            "S Update this Embox-Setup script. This will update this main management script only, but will not update any software packages. To update packages use the 'Update' option from the main menu, which will also update the RetroPie-Setup script."

            X "Uninstall Embox"
            "X Uninstall Embox completely."
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        
        case "$choice" in
            P)
                echo "packages_gui_setup"
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