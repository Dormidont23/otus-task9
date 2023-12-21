## Задание № 9. Systemd - создание unit-файла. ##
- Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
- Установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
- Дополнить unit-файл httpd возможностью запустить несколько экземпляров сервера с разными конфигурационными файлами.

Создаём файл с конфигурацией /etc/sysconfig/watchlog. Его содержимое:\
[root@otus-task9 ~]# **cat /etc/sysconfig/watchlog**\
WORD="error"\
LOG=/var/log/watchlog.log\
Напишем скрипт /opt/watchlog.sh:\
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
[root@otus-task9 ~]# **chmod +x /opt/watchlog.sh**\
Юнит для сервиса:\
[root@otus-task9 ~]# **cat /etc/systemd/system/watchlog.service**\
[Unit]\
Description=My watchlog service\

[Service]\
Type=oneshot\
EnvironmentFile=/etc/sysconfig/watchlog\
ExecStart=/opt/watchlog.sh $WORD $LOG

Юнит для таймера:\
[root@otus-task9 ~]# **cat /etc/systemd/system/watchlog.timer**\
[Unit]\
Description=Run watchlog script every 30 second\

[Timer]\
OnUnitActiveSec=30\
Unit=watchlog.service\

[Install]\
WantedBy=multi-user.target\
Старт таймера:\
[root@otus-task9 ~]# **systemctl start watchlog.timer**\
Убедиться, что успешно запустился:\
[root@otus-task9 ~]# **tail -f /var/log/messages**\
Dec 21 07:50:26 centos8s systemd[1]: Started system activity accounting tool.\
Dec 21 08:00:26 centos8s systemd[1]: Starting system activity accounting tool...\
Dec 21 08:00:26 centos8s systemd[1]: Started Update a database for mlocate.\
Dec 21 08:00:26 centos8s systemd[1]: sysstat-collect.service: Succeeded.\
Dec 21 08:00:26 centos8s systemd[1]: Started system activity accounting tool.\
Dec 21 08:00:26 centos8s systemd[1]: mlocate-updatedb.service: Succeeded.\
Dec 21 08:10:16 centos8s systemd[1]: Starting system activity accounting tool...\
Dec 21 08:10:16 centos8s systemd[1]: sysstat-collect.service: Succeeded.\
Dec 21 08:10:16 centos8s systemd[1]: Started system activity accounting tool.\
Dec 21 08:12:23 centos8s systemd[1]: Started Run watchlog script every 30 second.
