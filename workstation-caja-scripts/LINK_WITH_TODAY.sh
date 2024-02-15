#!/bin/bash
#
# Нужен чтобы создавать линки на сегодняшний день. Чтобы не терять то, чем вообще занимался.
#
# 2024 (c) haegor
#

[ -f "./.env" ] && . ./.env || exit 0

work_dir="$(pwd)"
today_dir="/home/$(whoami)/${TODAY}"

if [ $@ -lt 1 ]
then
  ln -s "${work_dir}" "${today_dir}"
  exit 0
fi

for i in $(seq 1 $#)
do
  file_bn=$(basename "$1")

  if [ -f "${today_dir}/${file_bn}" ]
  then
    notify-send "Файл уже существует" "${file_bn}"
    shift
    continue
  fi

  ln -s "${work_dir}/${file_bn}" "${today_dir}/${file_bn}"

  shift
done
