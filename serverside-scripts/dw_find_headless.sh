#!/bin/bash
#
# Скрипт для поиска страниц в вики, не имеющих заголовка
#
# (c) haegor
#

[ -f "./.env" ] && . ./.env || exit 0

case $1 in
'')
	# Читающий, помни, что bash различает наименование переменных заглавными и прописными буквами
	# Для него они разные.
    dw_pages_dir="${DW_PAGES_DIR}"
;;
*)
    dw_pages_dir="$1"
;;
esac

#D echo "Data directory: ${pages_dir}"

for i in $(find "${dw_pages_dir}" -iname "*.txt")
do
	header=$(head -1 ${i})
	result=$(echo ${header} | grep -P "^======.*======$")

	if [ "${result}" != '' ];
	then 
		#D echo "header is ${result}"
		continue
	else
		echo "file ${i} does not have any header"
	fi
done
