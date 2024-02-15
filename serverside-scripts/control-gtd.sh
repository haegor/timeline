#!/bin/bash
#
# Скрипт управления сервисами timeline
#
# (c) haegor
#

case $1 in
'start')
    systemctl start httpd.service
    systemctl start nginx.service
    systemctl start taskd.service
;;
'stop')
    systemctl stop nginx.service
    systemctl stop httpd.service
    systemctl stop taskd.service
;;
esac
