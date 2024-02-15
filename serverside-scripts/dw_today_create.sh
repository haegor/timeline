#!/bin/bash
#
# Скрипт ежедневного создания страницы дня, месяца и года.
# В зависимости от того, чего не хватает.
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
month=$(date +%m)
month_h=`human_month ${month}`
quartal=$(date +%q)
day=$(date +%d)
date=$(date +%F)
dow=$(date +%a)
week=$(date +%V)

result_year_file="${days_dir}/${year}/start.txt"
result_month_file="${days_dir}/${year}/${month}/start.txt"
result_day_file="${days_dir}/${year}/${month}/day-${year}-${month}-${day}.txt"

##### Файл года ###############################################################
if [ ! -f "${result_year_file}" ];
then
  year_file=$(mktemp)
  echo "====== ${year}й год ======" >> ${year_file}
  echo "{{yearbox>year=${year};ns=${DW_DAYS_NS}}}\\\\" >> ${year_file}

  # Пример: my:days:2022:04:start
  echo "Сводки по месяцам:\\\\" >> ${year_file}
  echo "Первый квартал:[[${DW_DAYS_NS}:${year}:01:start|`human_month 01`]], [[${DW_DAYS_NS}:${year}:02:start|`human_month 02`]], [[${DW_DAYS_NS}:${year}:03:start|`human_month 03`]]\\\\" >> ${year_file}
  echo "Второй квартал:[[${DW_DAYS_NS}:${year}:04:start|`human_month 04`]], [[${DW_DAYS_NS}:${year}:05:start|`human_month 05`]], [[${DW_DAYS_NS}:${year}:06:start|`human_month 06`]]\\\\" >> ${year_file}
  echo "Третий квартал:[[${DW_DAYS_NS}:${year}:07:start|`human_month 07`]], [[${DW_DAYS_NS}:${year}:08:start|`human_month 08`]], [[${DW_DAYS_NS}:${year}:09:start|`human_month 09`]]\\\\" >> ${year_file}
  echo "Четвёртый квартал:[[${DW_DAYS_NS}:${year}:10:start|`human_month 10`]], [[${DW_DAYS_NS}:${year}:11:start|`human_month 11`]], [[${DW_DAYS_NS}:${year}:12:start|`human_month 12`]]\\\\" >> ${year_file}

  echo "{{archive>${DW_DAYS_NS}:${year}?*}}" >> ${year_file}

  php "${DW_BIN_DIR}/dwpage.php" \
      commit -m 'init' ${year_file} ${DW_DAYS_NS}:${year}:start

  rm ${year_file}
fi

##### месячный файл ###########################################################
if [ ! -f "${result_month_file}" ];
then
  month_file=$(mktemp)
  echo "====== ${year}, ${quartal}й квартал, ${month_h}  ======" >> ${month_file}
  echo "{{yearbox>year=${year};months=${month};ns=${DW_DAYS_NS}}}" >> ${month_file}
  echo "{{archive>*?${year}-${month}}}" >> ${month_file}

  php "${DW_BIN_DIR}/dwpage.php" \
      commit -m 'init' ${month_file} ${DW_DAYS_NS}:${year}:${month}:start

  rm ${month_file}
fi

##### Дневной файл ############################################################
if [ -f "${result_day_file}" ];
then
    echo Already exists. Exit.
    exit 0
fi

day_file=$(mktemp)

echo "====== ${date} ${dow}., ${week} нед. ======" >> ${day_file}

# Всё в одну строку для того чтобы при просмотре через Летопись было всё красиво, в одну строку, а не громоздко
echo "[[${DW_DAYS_NS}:${year}:start|${year}й]]: [[${DW_DAYS_NS}:${year}:01:start|01]] - [[${DW_DAYS_NS}:${year}:02:start|02]] - [[${DW_DAYS_NS}:${year}:03:start|03]] - [[${DW_DAYS_NS}:${year}:04:start|04]] - [[${DW_DAYS_NS}:${year}:05:start|05]] - [[${DW_DAYS_NS}:${year}:06:start|06]] - [[${DW_DAYS_NS}:${year}:07:start|07]] - [[${DW_DAYS_NS}:${year}:08:start|08]] - [[${DW_DAYS_NS}:${year}:09:start|09]] - [[${DW_DAYS_NS}:${year}:10:start|10]] - [[${DW_DAYS_NS}:${year}:11:start|11]] - [[${DW_DAYS_NS}:${year}:12:start|12]] [<>]" >> ${day_file}

echo " " >> ${day_file}

echo "===== Задачи сегодня  =====" >> ${day_file}
echo "<nspages ${DW_TASKS_NS}:${year}:${month}:${day} -h1 -textPages=\"\" -numberedList -hideNoPages -hideNoSubns>" >> ${day_file}
#if [ -d "${tasks_dir}/stalled" ]; then
#	echo "<nspages ${DW_TASKS_NS}:stalled -h1 -textPages=\"Просроченые\" -simpleList -hideNoPages>" >> ${day_file}
#	echo " " >> ${day_file}
#fi

echo "===== Наработки =====" >> ${day_file}
echo "{{NEWPAGE>${DW_DAYS_NS}:${year}:${month}:${day}}}" >> ${day_file}
echo "<nspages ${DW_DAYS_NS}:${year}:${month}:${day} -h1 -textPages=\"\" -simpleList>" >> ${day_file}
echo "~~NOCACHE~~" >> ${day_file}

echo "===== День =====" >> ${day_file}
echo " " >> ${day_file}

#sudo -u apache -s
php "${DW_BIN_DIR}/dwpage.php" \
    commit -m 'init' ${day_file} \
    ${DW_DAYS_NS}:${year}:${month}:day-${year}-${month}-${day}

# На случай, если запускаем под рутом
find "${DW_DATA_DIR}" -user root -exec chown apache:apache '{}' \;

rm ${day_file}
