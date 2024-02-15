#!/bin/bash
#
# Массово создаёт отсутствующие страницы месяцев
#
# (c) haegor
#

[ -f "./.env" ] && . ./.env || exit 0

human_month () {
  case $1 in
    "01" ) rslt="Январь" ;;
    "02" ) rslt="Февраль" ;;
    "03" ) rslt="Март" ;;
    "04" ) rslt="Апрель" ;;
    "05" ) rslt="Май" ;;
    "06" ) rslt="Июнь" ;;
    "07" ) rslt="Июль" ;;
    "08" ) rslt="Август" ;;
    "09" ) rslt="Сентябрь" ;;
    "10" ) rslt="Октябрь" ;;
    "11" ) rslt="Ноябрь" ;;
    "12" ) rslt="Декабрь" ;;
  esac
  echo $rslt

  return 0
}

days_dir="${DW_PAGES_DIR}/$(echo ${DW_DAYS_NS} | tr : /)"
#tasks_dir="${DW_PAGES_DIR}/$(echo ${DW_TASKS_NS} | tr : /)"

year=$(date +%Y)

for month in 01 02 03 04 05 06 07 08 09 10 11 12
do
  result_month_file="${days_dir}/${year}/${month}/start.txt"
  month_h=`human_month ${month}`

  if [ -f ${result_month_file} ];
  then
    month_file=$(mktemp)
    echo "====== ${year} ${month_h}  ======" >> ${month_file}
    echo "{{yearbox>year=${year};months=${month};ns=my:days}} {{archive>*?${year}-${month}}}" >> ${month_file}

    php "${DW_BIN_DIR}/dwpage.php" \
            commit -m 'prettify' ${month_file} ${DW_DAYS_NS}:${year}:${month}:start

    rm ${month_file}
  fi
done

# На случай, если запускаем под рутом
find "${DW_DATA_DIR}" -user root -exec chown apache:apache '{}' \;
