#!/bin/bash
#
# backup всему голова =)
#
# (c) haegor
#

[ -f "./.env" ] && . ./.env || exit 0

tar -czf "${BKP_DIR}/taskd_$(date +%Y-%m-%d_%H:%M).tar.gz" "${TW_SERVER_DATA_DIR}"
