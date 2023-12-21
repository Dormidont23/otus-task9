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
Убедиться, что успешно запустился и работает:\
[root@otus-task9 ~]# **tail -f /var/log/messages**\
Dec 21 08:36:43 otus-task9 systemd[1004]: Startup finished in 53ms.\
Dec 21 08:36:43 otus-task9 systemd[1]: Started User Manager for UID 1000.\
Dec 21 08:36:43 otus-task9 systemd[1]: Started Session 1 of user vagrant.\
Dec 21 08:36:45 otus-task9 systemd[1]: systemd-hostnamed.service: Succeeded.\
Dec 21 08:37:13 otus-task9 systemd[1]: Started Run watchlog script every 30 second.\
Dec 21 08:37:27 otus-task9 chronyd[739]: Selected source 91.209.94.10 (2.centos.pool.ntp.org)\
Dec 21 08:38:31 otus-task9 systemd[1]: Starting My watchlog service...\
Dec 21 08:38:31 otus-task9 root[1095]: Thu Dec 21 08:38:31 UTC 2023: слово 'error' найдено.\
Dec 21 08:38:31 otus-task9 systemd[1]: watchlog.service: Succeeded.

