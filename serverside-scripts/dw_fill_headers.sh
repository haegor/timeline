#!/bin/bash
#
# Скрипт для поиска страниц в вики, не имеющих заголовка
#
# 2022 (c) haegor
#

[ -f "$(dirname $0)/.env" ] && . "$(dirname $0)/.env" \
  || { echo "Отсутствует файл настроек (.env). Останов."; exit 0; }

echo "ПЛОХО ПЕРЕНОСИТ РУССКИЙ ЯЗЫК когда имена файлов записаны с помощью процентов."
# ВНИМАНИЕ: РУЧНИК!
# TODO Скрипт следует перепроверить!
exit 0


skiplist=("${DW_PAGES_DIR}/wiki/stopwords.txt" "${DW_PAGES_DIR}/sidebar.txt")

for filename in $(find ${DW_PAGES_DIR} -name "*.txt")
do
	skipping=0
	for filecheck in ${skiplist[*]}
	do
		if [ "${filename}" == "${filecheck}" ];
		then
		# Почему не использовать сразу continue?
		# А потому что применится к текущему for
			skipping=1;
		fi
	done

	if [ $skipping -eq 1 ];
	then
  	    continue;
    fi

	result6=''
	result5=''

	header=$(head -1 "${filename}")
	result6=$(echo ${header} | grep -P "^======.*======$")
	result5=$(echo ${header} | grep -P "^=====.*=====$")

	if [ "${result6}" != '' ] || [ "${result5}" != '' ];
	then
		#echo "header is ${result}"
		continue;
	else
		echo "file ${filename} does not have any header"
		echo "--------------------- CUT -------------------------"
                head "${filename}"
		echo
		echo "--------------------- CUT -------------------------"
		echo "Please enter one:"
		read new_header
		echo "New header will be set to: ${new_header}"

		tmp_file=$(mktemp)
		echo "Tmp file: ${tmp_file}"
		echo "====== ${new_header} ======" > "${tmp_file}"
		cat "${filename}" >> "${tmp_file}"
		mv "${tmp_file}" "${filename}"
		chown apache:apache "${filename}"

		#namespace=$(echo ${filename} | awk -F'.txt' '{ print $1 }' | awk -F"${dw_pages}/" '{ print $2}' | tr / : )
		# Тоже самое, но компактнее
		namespace=$(echo "${filename:19:-4}" | tr / : )
		echo "Namespace: ${namespace}"

        php "${DW_BIN_DIR}/dwpage.php" commit -t -m 'fix header' "${filename}" "${namespace}"
		echo "========================== NEXT ONE ============================="

#		exit 0
	fi
done
