#!/bin/bash
#
# backup всему голова =)
#
# (c) haegor
#

[ -f "$(dirname $0)/.env" ] && . "$(dirname $0)/.env" \
  || { echo "Отсутствует файл настроек (.env). Останов."; exit 0; }

tar -czf "${BKP_DIR}/dokuwiki_$(date +%Y-%m-%d_%H:%M).tar.gz" "${DW_DATA_DIR}"
