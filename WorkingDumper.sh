#!/bin/bash
# Ardavan Hashemzadeh
# March 8 2019
# MultiDump Tool
# Prior setup:
# 0. Ensure prerequisites are met (bash, screen, ssh, tar, gzip)
# 1. ssh username = sql username
# 2. setup passwordless authentication (ssh and sql)

# id,user,host,dumpfolder,databases
mylist="\
cr,root,192.168.1.2,/OpenDentImages/share,--databases mysql"

timestamp=`date -d "today" +"%Y%m%d%H%M%S"`

mkdir $timestamp; cd $timestamp
while IFS=, read id user host dumpfolder databases ; do
        remotecommand="cd /; cd $dumpfolder; \
                /usr/local/mariadb10/bin/./mysql -e 'FLUSH TABLES WITH READ LOCK; \
                        SET GLOBAL read_only=ON;SELECT NOW(), @@read_only, @@gtid_current_pos, @@gtid_bin$
                        SELECT NOW();SHOW MASTER STATUS\G' &>> $id-replog; \
                /usr/local/mariadb10/bin/./mysqldump --max-allowed-packet=512m -u$user $databases \
                        > $id-$timestamp.sql 2>> $id-replog; \
                /usr/local/mariadb10/bin/./mysql -e 'SET GLOBAL read_only=OFF; UNLOCK TABLES; SELECT NOW($
                tar -cvzf $id-$timestamp.tgz $id-replog $id-$timestamp.sql &>> $id-ziplog"
        screen -dm bash -c $"ssh $user@$host \"$remotecommand\" ;\
          ssh $user@$host cat $dumpfolder/$id-$timestamp.tgz > $id-$timestamp.tgz"
done << E
$mylist
E
