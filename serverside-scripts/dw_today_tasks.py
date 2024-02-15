#!/usr/bin/env python3
#
# Забирает задачи на день из taskwarrior и создаёт для них страницы в dokuwiki
#
# 2021, 2024 (c) haegor
#

import os
import subprocess
import json
import datetime
#import date

from dotenv import load_dotenv # для подгрузки настроек из .env

load_dotenv()

### SETTINGS ###############################################################################

dw_url = os.getenv('DW_URL')
task_api_uri = os.getenv('TW_API_URL')

dw_bin_dir = os.getenv('DW_BIN_DIR')
dw_data_dir = os.getenv('DW_DATA_DIR')
tasks_ns = os.getenv('DW_TASKS_NS')
days_ns = os.getenv('DW_DAYS_NS')

tasks_dir = os.getenv('DW_PAGES_DIR') + '/' + os.getenv('DW_TASKS_SUBDIR')

tw_bin = os.getenv('TW_CLIENT_BIN')

username = os.getenv('UNIX_USERNAME')
tmp_tasks_dir = '/tmp'

filter_tags = '+TODAY'

### FUNCTIONS ##############################################################################

def task_query(filter):
    get_tasks = subprocess.Popen('sudo -u ' + username + ' -s ' + tw_bin + ' sync 2>/dev/null 1>/dev/null && sudo -u ' + username ' -s ' + tw_bin + ' ' + filter +  ' export 2>/dev/null', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    get_tasks_bytes = get_tasks.stdout.readlines() # get output

    tasks_json_string = ''
    for record in get_tasks_bytes:
        tasks_json_string += record.rstrip().decode("utf-8") # decoded bytes

    return tasks_json_string

def split_str(s):
  return [ch for ch in s]

def get_tags(tags):
  tagline=''
  for tag in tags:
      tagline += ' ' + tag
  return tagline

def convert_time (timestring):
    format = '%Y%m%dT%H%M%SZ'
    result = datetime.datetime.strptime(timestring, format)
    return result

def remove_whitespaces (task_ident):
    ns_task_ident=''
    for i in split_str(task_ident):
        if ord(i) == ord(' '):
            ns_task_ident+='_'
            continue
        if ord(i) == ord('\t'):
            ns_task_ident+='_'
            continue
        if ord(i) == ord(','):
            continue
#        if ord(i) == ord('!'):
#            continue
#        if ord(i) == ord('?'):
#            continue
#        if ord(i) == ord('#'):
#            continue
#        if ord(i) == ord('/'):
#            continue
#        if ord(i) == ord('\'):
#            continue
        ns_task_ident+=i

    return ns_task_ident

def translit_case_sensitive(ns_task_ident):
    res=''
    for i in split_str(ns_task_ident):
        switcher = {
           'а': "a", 'А': "A",
           'б': "b", 'Б': "B",
           'в': "w", 'В': "W",
           'г': "g", 'Г': "G",
           'д': "d", 'Д': "D",
           'е': "ye", 'Е': "YE",
           'ё': "yo", 'Ё': "YO",
           'ж': "j", 'Ж': "J",
           'з': "z", 'З': "Z",
           'и': "i", 'И': "I",
           'й': "yi", 'Й': "YI",
           'к': "k", 'К': "K",
           'л': "l", 'Л': "L",
           'м': "m", 'М': "M",
           'н': "n", 'Н': "N",
           'о': "o", 'О': "O",
           'п': "p", 'П': "P",
           'р': "r", 'Р': "R",
           'с': "s", 'С': "S",
           'т': "t", 'Т': "T",
           'у': "u", 'У': "U",
           'ф': "f", 'Ф': "F",
           'х': "h", 'Х': "H",
           'ц': "c", 'Ц': "C",
           'ч': "ch", 'ч': "CH",
           'ш': "sh", 'Ш': "SH",
           'щ': "sch", 'Щ': "SCH",
           'ь': "", 'Ь': "",
           'ы': "i", 'Ы': "I",
           'Ъ': "", 'Ъ': "",
           'э': "e", 'Э': "E",
           'ю': "yu", 'Ю': "YU",
           'я': "ya", 'Я': "YA"
        }
        res += switcher.get(i,i)
        # Смысл такой: во время добавления символа подменить i по таблице, а если там нет, то взять просто i
    return res

def translit(ns_task_ident):
    res=''
    for i in split_str(ns_task_ident):
        switcher = {
           'а': "a", 'А': "a",
           'б': "b", 'Б': "b",
           'в': "w", 'В': "w",
           'г': "g", 'Г': "g",
           'д': "d", 'Д': "d",
           'е': "ye", 'Е': "ye",
           'ё': "yo", 'Ё': "yo",
           'ж': "j", 'Ж': "j",
           'з': "z", 'З': "z",
           'и': "i", 'И': "i",
           'й': "yi", 'Й': "yi",
           'к': "k", 'К': "k",
           'л': "l", 'Л': "l",
           'м': "m", 'М': "m",
           'н': "n", 'Н': "n",
           'о': "o", 'О': "o",
           'п': "p", 'П': "p",
           'р': "r", 'Р': "r",
           'с': "s", 'С': "s",
           'т': "t", 'Т': "t",
           'у': "u", 'У': "u",
           'ф': "f", 'Ф': "f",
           'х': "h", 'Х': "h",
           'ц': "c", 'Ц': "c",
           'ч': "ch", 'ч': "ch",
           'ш': "sh", 'Ш': "sh",
           'щ': "sch", 'Щ': "sch",
           'ь': "", 'Ь': "",
           'ы': "i", 'Ы': "i",
           'Ъ': "", 'Ъ': "",
           'э': "e", 'Э': "e",
           'ю': "yu", 'Ю': "yu",
           'я': "ya", 'Я': "ya"
        }
        res += switcher.get(i,i)
        # Смысл такой: во время добавления символа подменить i по таблице, а если там нет, то взять просто i
    return res

############################# MAIN #########################################################

tasks_array = json.loads(task_query(filter_tags))
today = datetime.date.today()
d_year = today.strftime("%Y")
d_month = today.strftime("%m")
d_day = today.strftime("%d")

for record in tasks_array:

    print (record)

    # UUID
    short_uuid = record['uuid'].split('-',1)[0]

    task_tmp_file = tmp_tasks_dir + '/' + record['uuid'] + '.txt'
    if os.path.exists(task_tmp_file):
      os.remove(task_tmp_file)

    # DESCRIPTION
    task_title = short_uuid + ' ' + record['description']
    task_ident = short_uuid + '_' + record['description']

    ns_task_ident = translit(remove_whitespaces(task_ident));
    # 250 потому что потом ещё будет ".txt", а ограничение 254 символа. Не надеемся на 260 от ntfs
    ns_task_ident = ns_task_ident[:250]

    if os.path.exists(tasks_dir + '/' + d_year + '/' + d_month + '/' + d_day + '/' + ns_task_ident + '.txt'):
        print ('Task ' + ns_task_ident + ' already exists\n')
        continue
    else:
        print ('Task didnt exist. Because this file is absent: ' + tasks_dir + '/' + d_year + '/' + d_month + '/' + d_day + '/' + ns_task_ident + '.txt')

    f = open (task_tmp_file, 'a')
    f.write ('====== ' + task_title + ' ======\n')
    f.write ('[<6>]\n')
    f.write ('**Description:** ' + record['description'] + '\\\\\n')

    if task_api_uri == '':
      f.write ('**Short UUID:** ' + short_uuid + '\\\\\n')
      f.write ('**Full UUID:** ' + record['uuid'] + '\\\\\n')
    else:
      f.write ('**Short UUID:** [[' + task_api_uri + '/task.py?uuid=' + short_uuid +'|' + short_uuid + ']]\\\\\n')
      f.write ('**Full UUID:**  [[' + task_api_uri + '/task.py?uuid=' + record['uuid'] +'|' + record['uuid'] + ']]\\\\\n')

# Пример: dt_full = 2021-12-20 19:29:09
    if 'due' in record:
        dt_full = str(convert_time(record['due']))
        dt = dt_full[0:10]
        dt_year = dt[0:4]
        dt_month = dt[5:7]
        dt_day = dt[8:10]
# Пример: [[ my:days:2021:12:day-2021-12-21 | 2021-12-21 ]]
        f.write ('**Due:** [[' + days_ns + ':' + dt_year + ':' + dt_month + ':day-' + dt + '|' + dt + ']]\\\\\n')

    if 'urgency' in record:
        f.write ('**Urgency:** **' + str(record['urgency']) + '**\\\\\n')

    if 'project' in record:
        f.write ('**Project:** ' + record['project'] + '\\\\\n')

    if 'folder' in record:
        f.write ('**Folder:** ' + record['folder'] + '\\\\\n')

    task_tags = ''
    clickable_tags = ''
    if 'tags' in record:
        task_tags = get_tags(record['tags'])

        # Пример: {{tagpage>health}}
        clickable_tags = '{{tagpage>'
        for tag in task_tags:
            clickable_tags += tag
        clickable_tags += '}}'

        f.write ('**Tags:**' + clickable_tags + '\\\\\n')

    if 'status' in record:
        f.write ('**Status:** ' + record['status'] + '\\\\\n')

    if 'result' in record:
        f.write ('**Result:** ' + record['result'] + '\\\\\n')

    if 'type' in record:
        f.write ('**Type:** ' + record['type'] + '\\\\\n')

    if 'rtype' in record:
        f.write ('\\\\\n')
        f.write ('**rtype:** ' + record['rtype'] + '\\\\\n')

    if 'recur' in record:
        f.write ('**Recurrance:** ' + record['recur'] + '\\\\\n')

    if 'parent' in record:
        if task_api_uri == '':
          f.write ('**Parent:** ' + record['parent'] + '\\\\\n')
        else:
          f.write ('**Parent:** [[' + task_api_uri + '/task.py?uuid=' + record ['parent'] +'|' + record['parent'] + ']]\\\\\n')

    f.write ('\\\\\n')

    if 'entry' in record:
        f.write ('**Entry:** ' + str(convert_time(record['entry'])) + '\\\\\n')

    if 'modified' in record:
        f.write ('**Modified:** ' + str(convert_time(record['modified'])) + '\\\\\n')

    if 'annotations' in record:
        f.write ('**Annotations:** ' + '\n')

        for line in record['annotations']:
            f.write ('  - **' + str(convert_time(line['entry'])) + ' :** ' + line ['description'] + '\n')

    f.write ('\n')
    # Тег deeds нужен чтобы можно было делать выборки по тегам с исключением всех тасков.
    f.write ('{{tag>deeds' + task_tags + '}}\n')
    f.close ()

    print ('tmp: ',task_tmp_file)

    subprocess.Popen('sudo -u apache -s php ' + dw_bin_dir + '/dwpage.php ' + 'commit -m \'init\' ' + '\'' +
                     task_tmp_file + '\'' + ' ' + tasks_ns + ':$(date +%Y):$(date +%m):$(date +%d):' + ns_task_ident +
                     ' 2>/dev/null', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
