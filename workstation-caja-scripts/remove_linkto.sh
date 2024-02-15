#!/bin/bash
#
# Скрипт вызывающий fix_broken_links.sh для удаления приписки "Ссылка на "
# Главное назначение скрипта - быть болванкой для написания других caja-скриптов
#
# 2024 (c) haegor
#

[ -f "./.env" ] && . ./.env || exit 0

[ $# -eq 0 ] && exit 0

for i in $(seq 1 $#)
do
  if [ ! -L "$1" ]
  then
    shift
    continue
  fi

  "${COMMON_SCRIPTS_DIR}/Organize/fix_broken_links.sh" remove_link_to "$(pwd)/${1}"

  shift
done
