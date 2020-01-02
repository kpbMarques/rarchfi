#!/bin/bash

# Raspbery pi Arch Linux Fast Install (rarchfi)
# --------------------------------
# author    : Keiven Marques
#
# project   :
# license   : LGPL-3.0 (http://opensource.org/licenses/lgpl-3.0.html)
#
# referance : https://wiki.archlinux.org/index.php/Installation_guide


apptitle="Raspbery pi Arch Linux Fast Install (rarchfi)- Version: 2020.1.02 (GPLv3)"
baseurl=http://downloads.sourceforge.net/project/archfi/release/2019.12.15.00.04.07
skipfont="0"


# --------------------------------------------------------
mainmenu(){
  if [ "${1}" = "" ]; then
    nextitem="."
  else
    nextitem=${1}
  fi
  options=()
  options+=("${txtlanguage}" "Language")
  options+=("${txtsetkeymap}" "(loadkeys ...)")
  options+=("${txteditor}" "(${txtoptional})")
  options+=("${txtdiskpartmenu}" "")
  options+=("${txtselectpartsmenu}" "")
  options+=("" "")
  options+=("${txtreboot}" "")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtmainmenu}" --menu "" --cancel-button "${txtexit}" --default-item "${nextitem}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    case ${sel} in
      "${txtlanguage}")
        chooselanguage
        nextitem="${txtsetkeymap}"
      ;;
      "${txtsetkeymap}")
        setkeymap
        nextitem="${txtdiskpartmenu}"
      ;;
      "${txteditor}")
        chooseeditor
        nextitem="${txtdiskpartmenu}"
      ;;
      "${txtdiskpartmenu}")
        diskpartmenu
        nextitem="${txtselectpartsmenu}"
      ;;
      "${txtselectpartsmenu}")
        selectparts
        nextitem="${txtreboot}"
      ;;
      "${txthelp}")
        help
        nextitem="${txtreboot}"
      ;;
      "${txtchangelog}")
        showchangelog
        nextitem="${txtreboot}"
      ;;
      "${txtreboot}")
        rebootpc
        nextitem="${txtreboot}"
      ;;
    esac
    mainmenu "${nextitem}"
  else
    clear
  fi
}

chooselanguage(){
  options=()
  options+=("English" "(By MatMoul)")
  options+=("Portuguese" "(By hugok)")

  sel=$(whiptail --backtitle "${apptitle}" --title "${txtlanguage}" --menu "" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    clear
    if [ "${sel}" = "English" ]; then
      loadstrings
    else
      eval $(curl -L ${baseurl}/lng/${sel} | sed '/^#/ d')
    fi
    if [ "${skipfont}" = "0" ]; then
      eval $(setfont ${font})
    fi
    font=
    if [ "$(cat /etc/locale.gen | grep ""#${locale}"")" != "" ]; then
      sed -i "/${locale}/s/^#//g" /etc/locale.gen
      locale-gen
    fi
    export LANG=${locale}
  fi
}

setkeymap(){
  #items=$(localectl list-keymaps)
  #options=()
  #for item in ${items}; do
  #  options+=("${item}" "")
  #done
  items=$(find /usr/share/kbd/keymaps/ -type f -printf "%f\n" | sort -V)
  options=()
  for item in ${items}; do
    options+=("${item%%.*}" "")
  done
  keymap=$(whiptail --backtitle "${apptitle}" --title "${txtsetkeymap}" --menu "" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    clear
    echo "loadkeys ${keymap}"
    loadkeys ${keymap}
    pressanykey
  fi
}

chooseeditor(){
  options=()
  options+=("nano" "")
  options+=("vim" "")
  options+=("vi" "")
  options+=("edit" "")
  options+=("emacs" "")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txteditor}" --menu "" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    clear
    echo "export EDITOR=${sel}"
    export EDITOR=${sel}
    EDITOR=${sel}
    pressanykey
  fi
}

rebootpc(){
  if (whiptail --backtitle "${apptitle}" --title "${txtreboot}" --yesno "${txtreboot} ?" --defaultno 0 0) then
    clear
    reboot
  fi
}
# --------------------------------------------------------

