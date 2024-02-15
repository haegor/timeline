#!/bin/bash
#
# (c) haegor
#

[ -f "./.env" ] && . ./.env || exit 0

[ "$1" ] && template=$1 || exit 0

find "${DW_PAGES_DIR}" -type f -name "*.txt" -exec bash -c "grep -Hwn --colour=always --no-messages \"${template}\" \"{}\"" \;

# H - вывод имени файла.
# n - показывать номер строки
# w - совпадение со словом
# --no-messages - не показывать сообщения об ошибках
