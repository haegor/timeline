#!/usr/bin/env python3
#
# Смотрит задачи на день и высылает напоминание о них на почту.
#
# 2021, 2024 (c) haegor
#

import json
import subprocess
import smtplib
import os # для dotenv
from dotenv import load_dotenv # для подгрузки настроек из .env

load_dotenv()

from_addr = os.getenv('TW_MAIL_FROM')
to_addr = os.getenv('USER_MAIL_TO')
SMTP_ADDR = os.getenv('SMTP_SERVER_ADDR')
SMTP_PORT = os.getenv('SMTP_SERVER_PORT')
username = os.getenv('UNIX_USERNAME')

taskwarrior_bin = os.getenv('TW_CLIENT_BIN')

# файл с UUID тех задач, что уже бывали посланы
list_of_sended_uuids="/home/" + username + "/.task/sended_uuid.json"

# Загружаем UUID тех задач, что уже бывали посланы
# А вообще вопрос, не стоит ли ввести специальный UDA, в котором отмечать факт
# отправки уведомления? Типа чтобы не быть зависимым от скрипта, чтобы можно
# было узнать о факте послания из общей базы... синхронизируемой базы...
#
if os.path.exists(list_of_sended_uuids):
    with open(list_of_sended_uuids) as sended_uuids_file:
        try:
            sended_uuids = json.load(sended_uuids_file)
        except:
            sended_uuids = []
else:
    open(list_of_sended_uuids,'x')
    sended_uuids = []

# Пример вывода одной задачи:
#[
#    {
#        "id":600,"description":"настроить работу с git на сервере через вэб",
#        "due":"20200815T210000Z",
#        "entry":"20200816T140052Z",
#        "modified":"20200816T140104Z",
#        "project":"<secret>",
#        "result":"success",
#        "status":"pending",
#        "tags":["inbox","order"],
#        "uuid":"68238485-6ed5-4b86-8c90-7438e5a7507e",
#        "urgency":-2.46433
#    }
#]

# Через временные файлы. Они один фиг разница создаются в /tmp, который весь в памяти
get_today_tasks = subprocess.Popen('sudo -u ' + username + ' -s ' + taskwarrior_bin + ' sync &>/dev/null && tmpf=$(mktemp) && sudo -u ' + username + ' -s ' + taskwarrior_bin + ' +TODAY or +ACTIVE or +OVERDUE export 2>/dev/null > ${tmpf}; echo ${tmpf}', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
tasks_today_tmp_file_dirty = get_today_tasks.stdout.readlines() # get output
tasks_today_tmp_file = tasks_today_tmp_file_dirty[0].rstrip().decode("utf-8") # decoded bytes

#D print (tasks_today_tmp_file)

with open(tasks_today_tmp_file) as f:
   try:
     tasks_today_array = json.load(f)
   except:
     tasks_today_array = []
    # это список словарей...

all_tasks_array=[]
for record_today in tasks_today_array:
    if record_today['uuid'] in sended_uuids:
        continue

    record_today['status']='today'
    all_tasks_array.append(record_today)

###############################################################################
# TODO Так должно быть сделано и так будет сделано, но для начала хоть как-то, чтобы обрести мясо и понимание
# На выходе лист, в котором находятся записи, представляющие из себя байты, которые таят в себе словари
# Чтобы было понятно: правильно читать напрямую, а не из файла.
#get_today_tasks = subprocess.Popen('task +TODAY export', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
#get_active_tasks = subprocess.Popen('task +ACTIVE export', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
##
#dirty_today_list=get_today_tasks.stdout.readlines()
#dirty_active_list=get_active_tasks.stdout.readlines()
###############################################################################

# flag =)
uuid_was_added = 'false'

with smtplib.SMTP (SMTP_ADDR, SMTP_PORT) as mail_server:
    ids_history=[] # массив с id, чтобы дважды письма не высылать

    for record in all_tasks_array:
        current_msg='Content-Type: text/html; charset=UTF-8'+'\n'
        if 'id' in record:
            if record['id']==0:
                continue
#            if record['id'] in ids_history:
#                continue
            else:
                ids_history.append(record['id'])
                # print (record['id'])
                current_msg += 'TASK ' + str(record['id']) + '<br>'
                subject = 'Task ' + str(record['id']) + ' - ' + record['status']

        if 'status' in record:
            current_msg += 'STTS ' + record['status'] + '<br>'

        if 'uuid' in record:
            if record['uuid'] in sended_uuids:
                continue
            else:
                uuid_was_added = 'true'
                sended_uuids.append (record['uuid'])
                current_msg += 'UUID ' + record['uuid'] + '<br>'
                # print (record['uuid'])
                # print ('uuid was added, value now is: ' + uuid_was_added + ' list is: ' + str(sended_uuids))

        if 'description' in record:
            # print (record['description'])
            current_msg += 'DESC ' + record['description'] + '<br>'
            subject += ' - ' + record['description']

        if 'project' in record:
            # print (record['project'])
            current_msg += 'PROJ ' + record['project'] + '<br>'

        if 'tags' in record:
            tags=''
            for tag in record['tags']:
                tags+=tag + ' '
            current_msg += 'TAGS ' + tags + '<br>'
            # print (tags)

        if 'urgency' in record:
            # print (record['urgency'])
            current_msg += 'URGS ' + str(record['urgency']) + '<br>'

        print ('Sending task: ' + '\n')
        print (current_msg)
        print ('======================')
        print (' ')

        msg = current_msg.encode('utf-8')
        #print (msg)

        fmt = 'From: {}\r\nTo: {}\r\nSubject: {}\r\n{}'
        mail_server.sendmail(from_addr, to_addr, fmt.format(from_addr, to_addr, subject, current_msg).encode('utf-8'))

os.remove(tasks_today_tmp_file)

if uuid_was_added == 'true':
    # print('dumping')
    with open(list_of_sended_uuids, 'w') as sended_uuids_file:
        json.dump(sended_uuids, sended_uuids_file)

sended_uuids_file.close()
