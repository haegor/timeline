#!/bin/bash
#
# Показать сообщение во всплывашке, висящей 30 секунд.
# Скрипт также позволяет настраивать то, на какой дисплей будет вестись вывод.
# Имеет встроенный режим отладки, активируемый по установке переменнной DEBUG в
# значение true.
#
# 2024 (c) haegor
#

DEBUG='false'

dotenv='.env'

[ -f "$dotenv" ] \
  && source "$dotenv" \
  || echo "Файл настроек не найден, действуем без него."

# Запрашивает данные по дисплеям или подсовывает тестовые
f_get_displays_data () {
  if [ "$DEBUG" == 'false' ]
  then
    local data=$(dm-tool list-seats)
  else
    local data=$(cat << EOF
Seat0
  CanSwitch=true
  HasGuestAccount=false
  Session0
    UserName='user'
  Session1
    UserName='user'
Seat1
  CanSwitch=true
  HasGuestAccount=false
  Session0
    UserName='user'
  Session1
    UserName='user'
EOF
)
  fi

  echo $data
  return 0
}

f_help_msg () {
  echo
  echo "Не указано сообщение для вывода."
  echo "В качестве обязательного параметра следует указать сообщение, выводимое во всплывашке."
  echo "Если оно указано, но всплывашка не появляется, то возможно следует переопределить активный"
  echo "дисплей пользователя."
  echo "Полный список всех доступных дисплеев можно получить вызвав скрипт с параметром find_displays"
  echo "Задать подходящий можно через указание переменной: set DISPLAY=:0.0"
  echo "Сохранить текущие настройки, прописав их в $dotenv, можно вызвав скрипт с аргументом save-display"
  echo
  return 0
}

# Смотрит список Мест и Cессий для определения значений для параметра DISPLAY
f_find_displays () {
  local dm_ss=$(f_get_displays_data)

  # for съедает первые два пробела от вывода. И через while тоже самое. Хрен поймёшь в чём дело.
  # TODO: понять
  for i in $dm_ss
  do
    [ "$DEBUG" == 'true' ] && {
      echo "active seat ${active_seat}"
      echo "active session ${active_session}"
      echo ">>> ${i}"
    }

    [[ "${i}" =~ ^Seat ]] && {
      local new_seat=$(echo $i | sed -n 's/^Seat//p')
      renew_seat=1
    }

    [[ "${i}" =~ ^Session ]] && {
      local new_session=$(echo $i | sed -n 's/^Session//p')
      renew_session=1
    }

    # Для быстроты и отладки
    ( [ $renew_seat != 1 ] && [ $renew_session != 1 ] ) \
      && { [ "$DEBUG" == 'true' ] && echo "skip"; continue; } \
      || { renew_seat=0; renew_session=0; }

    [ "$DEBUG" == 'true' ] && {
      echo "+ new seat ${new_seat}"
      echo "+ new session ${new_session}"
    }

    # TODO некрасиво. Но понятно. Надо что-то с этим сделать, но не ясно что.
    if [ "$active_seat" == "$new_seat" ]		# Пока текущее место достаточно ново
    then
      if [ "$active_session" != "$new_session" ]	# Пока текущая сессия достаточно нова
      then
        local active_session=$new_session
        # seats - глобальный массив. Для удобства.
        seats[${#seats[@]}]=":$active_seat.$new_session"
        [ "$DEBUG" == 'true' ] && echo "= new display! = :$active_seat.$new_session"
      fi
    else
      local active_seat=$new_seat
    fi
  done

  return 0
}

################################### MAIN #######################################

case $1 in
'find-displays')
  f_find_displays

  echo "Выберите и исполните одну из опций. Если после её установки скрипт начнёт"
  echo "нормально отрабатывать, то сохраните настройки командой: $0 save-display"
  echo "-------------------------------------------------------------------------"
  echo "Найденные дисплеи:"
  for i in ${seats[@]}
  do
    echo "export DISPLAY=$i"
  done
  exit 0
;;
'save-display')
# TODO не могу понять в чём подвох. Кажется что так одновременно и сложнее, и проще.
  [ -z "$DISPLAY" ] && {
    echo "Нечего сохранять, переменная DISPLAY не определена."
    echo "Возможно стоит запустить $0 find-displays"
    exit 0
  } || echo "Текущий дисплей пользователя: $DISPLAY"

  [ ! -f "$dotenv" ] && {
    echo "#!/bin/bash" >> "$dotenv"
    echo "DISPLAY='$DISPLAY'" >> "$dotenv"
    exit 0
  } || {
    isStringExists=$(grep -n '^DISPLAY\=' "$dotenv")
    [ -n "$isStringExists" ] \
      && sed --follow-symlinks -i "/^DISPLAY=/c DISPLAY=\'$DISPLAY\'" "$dotenv" \
      || { echo >> $dotenv; echo "DISPLAY='$DISPLAY'" >> "$dotenv"; }
  }
  exit 0
;;
'')
  f_help_msg
  exit 0
;;
esac

[ -z "$DISPLAY" ] && {
  echo "Дисплей не указан. Задайте его вручную."
  f_help_msg
  exit 0
}

# Всё, написанное выше, существует лишь ради того чтобы выполнить эту команду:
notify-send --urgency=critical --expire-time=30000 "$1"
