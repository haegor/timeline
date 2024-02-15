#!/bin/bash
#
# backup всему голова =)
#
# (c) haegor
#

[ -f "./.env" ] && . ./.env || exit 0

tar -czf "${BKP_DIR}/dokuwiki_$(date +%Y-%m-%d_%H:%M).tar.gz" "${DW_DATA_DIR}"
