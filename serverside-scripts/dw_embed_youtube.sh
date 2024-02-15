#!/bin/bash
#
# Скрипт для подмены youtube-ссылок на тег плагина "youtube".
# Он позволяет встраивать видео прямо внутрь вики.
# По сути он просто применяет этот плагин для тех страниц,
# для которых я забыл это сделать вручную.
#
# В качестве параметра можно указать папку с данными dokuwiki
#
# Алгоритм: ищем find-ом подходящие файлы. Идём по их списку.
# Каждый проверяем на соответствие списку исключений.
# Грепаем файл на соответствие регулярке и сразу узнаём номера строк.
# Это чтобы дважды не вставать. Т.к. работа с памятью дешевле чем с диском,
# даже если для этого нужен awk.
# Все результаты, если они вообще есть, попадают на вход while и читаются
# построчно. Из каждой строки мы извлекаем сначала её номер, а потом
# идентификатор видео. После чего, с помощью sed, заменяем youtube-ссылку
# на тег плагина, попутно подставляя вычленынный ранее id виедо.
#
# Отказ от лишнего grep-а и от awk в сторону cut ускорил скрипт на 30%
#   linenum=$(echo "${yt_line}" | awk -F: '{print $1}')
# done < <(grep -n 'https://www.youtube.com/watch?v=' "${filename}" | grep -P '^\d*: *https\:\/\/www\.youtube\.com\/watch\?v\=.{11} *\\{2} *$')
#
# (c) haegor
#

# Ручник =)
exit 0

[ -f "./.env" ] && . ./.env || exit 0

skiplist=("${DW_PAGES_DIR}/wiki/stopwords.txt" "${DW_PAGES_DIR}/sidebar.txt")

for filename in $(find "${DW_PAGES_DIR}" -iname "*.txt")
do
	#yt_lines=''

        skipping=0
        for filecheck in ${skiplist[*]}
        do
            if [ "${filename}" == "${filecheck}" ];
            then
                # continue использовать нельзя потому что применится к текущему for
                skipping=1;
            fi
        done

        if [ $skipping -eq 1 ];
        then
            continue;
        fi

	# В идентификаторе видео всегда 11 символов
	# Ссылка на коммент делается добавлением что-то вроде '=UgyNKXnkGxioVySRGGV4AaABAg'

	# ВАЖНО: результат грепа нельзя просто так подменять, т.к. строк может быть несколько
    #[root@msk scripts]# grep -n 'https://www.youtube.com/watch?v=' "/srv/DW_DATA/pages/database/druid/start.txt" | grep -P '^\d*: *https\:\/\/www\.youtube\.com\/watch\?v\=.{11} *\\{2} *$'
    #13:https://www.youtube.com/watch?v=NBVCOn7w9Z4 \\
    #14:https://www.youtube.com/watch?v=f-LLTle-Xug \\
    #15:https://www.youtube.com/watch?v=y_-qbcPX70c \\
    #16:https://www.youtube.com/watch?v=c9UBkmiRqWw \\

	# Обрабатывать через for тоже не выйдет, результат команды будет резаться по пробелам.
	# for line in $(grep -n 'https://www.youtube.com/watch?v=' "${filename}" | grep -P '^\d*: *https\:\/\/www\.youtube\.com\/watch\?v\=.{11} *\\{2} *$')
	#
	# без -r один из слешей для переноса строк будет съедаться
	while read -r yt_line
	do
	    echo "---------------------------------------------------------------------"
	    echo "file: ---> ${filename} "
	    echo "line: -> ${yt_line}"
           
            linenum=$(echo "${yt_line}" | cut -d: -f1)
            echo "numb: -> ${linenum}"

	    video_id=`echo ${yt_line} | awk -F= '
	      {
		vid = substr ($2, 1, 11)
		print vid
              }
	    '`
	    echo "v_id: -> ${video_id}"

	    # Пример: https://www.youtube.com/watch?v=NBVCOn7w9Z4
	    # Одинарные ковычки использовать нельзя - переменные не подставляются.
	    # Да, через |. Потому что sed без разницы, а мне надоело воевать с регэкспами и экранированием.
	    sed -i "${linenum}s|https://www.youtube.com/watch?v=.\{11\}|{{youtube>${video_id}}}|" "${filename}"

	    # TODO: А где фиксация изменения через внесение комита?
	    # php ${dw_bin}/dwpage.php \
            #  commit -m 'youtube embed' ${filename} \
            #  ${days_ns}:${year}:${month}:day-${year}-${month}-${day}

	    echo

	# Мы получаем список изменений тут, а не в строке с while потому что иначе это вынудит нас вызывать
	# дочернюю оболочку и делать изменения там. Что навернёт всю возможность обмена переменными с другими
	# частями скрипта
	done < <(grep -Pn '^ *https\:\/\/www\.youtube\.com\/watch\?v\=.{11} *\\{2} *$' "${filename}")
done
