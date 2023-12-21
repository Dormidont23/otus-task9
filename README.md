## Задание № 9. Systemd - создание unit-файла. ##
- Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
- Установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
- Дополнить unit-файл httpd возможностью запустить несколько экземпляров сервера с разными конфигурационными файлами.

Создаём файл с конфигурацией /etc/sysconfig/watchlog. Его содержимое:\
[root@otus-task9 ~]# **cat /etc/sysconfig/watchlog**\
WORD="error"\
LOG=/var/log/watchlog.log\
Напишем скрипт /opt/watchlog.sh:
[root@otus-task9 ~]# **cat /opt/watchlog.sh**\
#!/bin/bash

WORD=$1\
LOG=$2\
DATE=`date`

if grep $WORD $LOG &> /dev/null\
then\
logger "$DATE: слово '$WORD' найдено."\
else\
exit 0\
fi

Добавим права на выполнение:\
[root@otus-task9 ~]# **chmod +x /opt/watchlog.sh**
