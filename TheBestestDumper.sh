#!/bin/bash
# Ardavan Hashemzadeh
# March 10 2019
# MultiDump and Backup Tool
# Prior setup:
# 0. Ensure prerequisites are met (bash, screen, ssh, tar, gzip)
# 1. ssh username = sql username
# 2. setup passwordless authentication (ssh and sql)

# id,user,host,dumpfolder,databases
mylist="\
a1,root,10.1.5.2,/Share,--databases dba1
a2,root,10.8.6.2,/Share,--databases dba2
a3,root,10.8.10.2,/share,--databases dba3
b1,root,10.6.31.2,/Share,--databases dbb1
b2,root,ec2.amazon.com,/Share,--databases dbb2
c1,root,192.168.34.2,/share,--databases dbc1"

timestamp=`date -d "today" +"%Y%m%d%H%M%S"`

while IFS=, read id user host dumpfolder databases ; do
        remotecommand="gotodmpfld() { cd $dumpfolder; } ; gotodmpfld; \
                /usr/local/mariadb10/bin/./mysql -e 'FLUSH TABLES WITH READ LOCK; \
                        SET GLOBAL read_only=ON;SELECT NOW(), @@read_only, @@gtid_current_pos, @@gtid_binlog_pos, @@gtid_slave_pos\G \
                        SELECT NOW();SHOW MASTER STATUS\G' &>> $id-replog; \
                /usr/local/mariadb10/bin/./mysqldump --max-allowed-packet=512m $databases \
                        > $id-$timestamp.sql 2>> $id-replog; \
                /usr/local/mariadb10/bin/./mysql -e 'SET GLOBAL read_only=OFF; UNLOCK TABLES; SELECT NOW(), @@read_only\G' &>> $id-replog; \
                tar -cvzf $id-$timestamp.tgz $id-replog $id-$timestamp.sql &>> $id-ziplog"
        screen -dm bash -c $"ssh $user@$host \"$remotecommand\" && scp $user@$host:$dumpfolder/$id-$timestamp.tgz  ."
done << E
$mylist
E
