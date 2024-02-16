#!/bin/bash
#
# Планировался как скрипт ручного редактирования текущего дня.
# Просто чтобы удобнее было делать заметки.
#
# (c) haegor
#
# TODO: Не хватает как минимум коммита после редактирования.
#

[ -f "$(dirname $0)/.env" ] && . "$(dirname $0)/.env" \
  || { echo "Отсутствует файл настроек (.env). Останов."; exit 0; }

dt_year=$(date +%Y)
dt_month=$(date +%m)
dt_day=$(date +%d)

days_subdir="$(echo ${DW_DAYS_NS} | tr : /)"
days_dir="${DW_PAGES_DIR}/${days_subdir}"

vim "${days_dir}/${dt_year}/${dt_month}/day-${dt_year}-${dt_month}-${dt_day}.txt"
