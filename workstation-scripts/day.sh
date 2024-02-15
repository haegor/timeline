#!/bin/bash

[ -f "./.env" ] && . ./.env || exit 0

dt_year=$(date +%Y)
dt_month=$(date +%m)
dt_day=$(date +%d)

ssh ${DOKU_HOST} "cat ${DW_DATA_DIR}/pages/${DW_DAYS_SUBDIR}/${dt_year}/${dt_month}/day-${dt_year}-${dt_month}-${dt_day}.txt"
