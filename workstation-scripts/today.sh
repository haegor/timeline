#!/bin/bash
#
# Скрипт создаёт "быструю" ссылку на директорию, соответствущую текущему дню.
# Предыдущие - переименовывает.
# Таким образом формируются ссылки для трёх дней: сегодя, вчера и позавчера.
# Зачем? Для повсеместной настройки "быстрого доступа". Особенно через панель
# caja или mintmenu.
#
# 2022, 2024 (c) haegor
#

[ -f "./.env" ] && . ./.env || exit 0

if [ $1 ]
then
    user_dir="$1"
else
    user_dir="/home/$(whoami)"
fi

# Вермя
dt_year=`date +%Y`
dt_month=`date +%m`
dt_day=`date +%d`
dt=`date +%F`

days_dir="${user_dir}/${DAYS_SUBDIR}"

if [ ! -d "${days_dir}/${dt_year}/${dt_month}/${dt}" ]
then
    rm "${user_dir}/${THIRD_DAY}" 2>/dev/null
    mv "${user_dir}/${SECOND_DAY}" "${user_dir}/${THIRD_DAY}"
    mv "${user_dir}/${TODAY}" "${user_dir}/${SECOND_DAY}"

    mkdir -p "${days_dir}/${dt_year}/${dt_month}/${dt}"
    ln -s "${days_dir}/${dt_year}/${dt_month}/${dt}" "${user_dir}/${TODAY}" 2>/dev/null
fi
