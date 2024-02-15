#!/bin/bash
#
# Смена ссылки "Сегодня" на страницу текущего дня.
#
# (c) haegor
#

[ -f "./.env" ] && . ./.env || exit 0

year=$(date +%Y)
month=$(date +%m)
date=$(date +%F)

sed -i "s/^\*\*\[\[${DW_DAYS_NS}:[0-9]\{4\}:[0-9]\{2\}:day-[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/\*\*\[\[${DW_DAYS_NS}:${year}:${month}:day-${date}/" "${DW_PAGES_DIR}/sidebar.txt"
