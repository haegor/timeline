#!/bin/bash

[ -f "./.env" ] && . ./.env || exit 0

[ "$1" ] && template=$1 || exit 0

ssh "${DOKU_HOST}" "${TL_SERVERSIDE_SCRIPTS_DIR}/doku_search_srv.sh" "${template}"
