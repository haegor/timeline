#!/bin/bash
#
# Скрипт для сбора результатов за день.
# Как правило используется для разбора Загрузок.
# В будущем станет полноценным скриптом для быстрой сортировки папок.
#
# Смысл такой: находясь в какой-то папке вызываем скрипт на каком-то файле и он
# двигает файло в папку _today
#
# 2024 (c) haegor
#

[ -f "$(dirname $0)/.env" ] && . "$(dirname $0)/.env" \
  || { echo "Отсутствует файл настроек (.env). Останов."; exit 0; }

# Осторожно! Если закомментить эту строку и запустить скрипт без параметров, то он
# переместит папку из которой был запущен
[ $# -eq 0 ] && exit 0

work_dir="$(pwd)"

#action='echo mv'
#action='notify-send mv'
action='mv'

today_dir="/home/$(whoami)/${TODAY}"

for i in $(seq 1 $#)
do
  file_bn=$(basename "$1")

  if [ -f "${today_dir}/${file_bn}" ]
  then
    notify-send "Файл уже существует" "${file_bn}"
    shift
    continue
  fi

  $action "${work_dir}/${file_bn}" "${today_dir}/${file_bn}"

  shift
done
