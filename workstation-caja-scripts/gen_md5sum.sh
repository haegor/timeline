#!/bin/bash
#
# Caja-скрипт для формирования файлов c md5-суммой.
#
# Если обычные файлы передаются скрипту без проблем, то вот ярлыки на рабочем
# столе - это записи из *.desktop и их параметры передаются хрен пойми как.
#
# 2024 (c) haegor
#

[ $# -eq 0 ] && exit 0

work_dir="$(pwd)"

for i in $(seq 1 $#)
do
  if [ -L "$1" ] || [ -d "$1" ]
  then
    shift
    continue
  fi

  if [ -f "${i}.md5" ]
  then
    shift
    continue
  fi

  file_bn=$(basename "$1")
  md5sum "${work_dir}/${file_bn}" > "${work_dir}/${file_bn}.md5"

  shift
done
