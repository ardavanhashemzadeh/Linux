#!/bin/bash
# Ardavan Hashemzadeh
# August 28 2018
# Database Backup Routine

thisbox=`hostname`
case "$thisbox" in
    srv1)
        mysqlhost='hostname'
        mysqldb='database'
        dumpdest='/volume1/sharedfolder'
        ;;
    srv2)
        mysqlhost='10.11.12.13'
        mysqldb='database'
        dumpdest='/volume1/sharedfolder'
        ;;
# ....
esac

/usr/local/mariadb10/bin/./mysqldump --max_allowed_packet=512m -uroot -h$mysqlhost $mysqldb > $dumpdest/$thisbox`date '+%Y_%m_%d__%H_%M_%S'`.sql
