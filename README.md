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

[root@otus-task9 ~]# **cat /etc/sysconfig/spawn-fcgi**\
\# You must set some working options before the "spawn-fcgi" service will work.\
\# If SOCKET points to a file, then this file is cleaned up by the init script.\
\#\
\# See spawn-fcgi(1) for all possible options.\
\#\
\# Example :\
SOCKET=/var/run/php-fcgi.sock\
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"\
[root@otus-task9 system]# **cat /etc/systemd/system/spawn-fcgi.service**\
[Unit]\
Description=Spawn-fcgi startup service\
After=network.target

[Service]\
Type=simple\
PIDFile=/var/run/spawn-fcgi.pid\
EnvironmentFile=/etc/sysconfig/spawn-fcgi\
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS\
KillMode=process

[Install]\
WantedBy=multi-user.target

[root@otus-task9 system]# **systemctl start spawn-fcgi**\
[root@otus-task9 system]# **systemctl status spawn-fcgi**\
```● spawn-fcgi.service - Spawn-fcgi startup service\
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)\
   Active: active (running) since Thu 2023-12-21 08:54:18 UTC; 5s ago\
 Main PID: 1862 (php-cgi)\
    Tasks: 33 (limit: 11068)\
   Memory: 19.0M\
   CGroup: /system.slice/spawn-fcgi.service\
           ├─1862 /usr/bin/php-cgi\
           ├─1863 /usr/bin/php-cgi\
           ├─1864 /usr/bin/php-cgi\
           ├─1865 /usr/bin/php-cgi\
           ├─1866 /usr/bin/php-cgi\
           ├─1867 /usr/bin/php-cgi\
           ├─1868 /usr/bin/php-cgi\
           ├─1869 /usr/bin/php-cgi\
           ├─1870 /usr/bin/php-cgi\
           ├─1871 /usr/bin/php-cgi\
           ├─1872 /usr/bin/php-cgi\
           ├─1873 /usr/bin/php-cgi\
           ├─1874 /usr/bin/php-cgi\
           ├─1875 /usr/bin/php-cgi\
           ├─1876 /usr/bin/php-cgi\
           ├─1877 /usr/bin/php-cgi\
           ├─1878 /usr/bin/php-cgi\
           ├─1879 /usr/bin/php-cgi\
           ├─1880 /usr/bin/php-cgi\
           ├─1881 /usr/bin/php-cgi\
           ├─1882 /usr/bin/php-cgi\
           ├─1883 /usr/bin/php-cgi\
           ├─1884 /usr/bin/php-cgi\
           ├─1885 /usr/bin/php-cgi\
           ├─1886 /usr/bin/php-cgi\
           ├─1887 /usr/bin/php-cgi\
           ├─1888 /usr/bin/php-cgi\
           ├─1889 /usr/bin/php-cgi\
           ├─1890 /usr/bin/php-cgi\
           ├─1891 /usr/bin/php-cgi\
           ├─1892 /usr/bin/php-cgi\
           ├─1893 /usr/bin/php-cgi\
           └─1894 /usr/bin/php-cgi

Dec 21 08:54:18 otus-task9 systemd[1]: Started Spawn-fcgi startup service.
```

[root@otus-task9 conf]# **systemctl start httpd@first**\
[root@otus-task9 conf]# **systemctl start httpd@second**\
[root@otus-task9 conf]# **ss -tnulp | grep httpd**\
tcp   LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    users:(("httpd",pid=2355,fd=3),("httpd",pid=2354,fd=3),("httpd",pid=2353,fd=3),("httpd",pid=2352,fd=3),("httpd",pid=2350,fd=3))\
tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("httpd",pid=2132,fd=3),("httpd",pid=2131,fd=3),("httpd",pid=2130,fd=3),("httpd",pid=2129,fd=3),("httpd",pid=2127,fd=3))\
