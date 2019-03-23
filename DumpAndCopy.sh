#!/bin/bash
# Ardavan Hashemzadeh

timestamp=`date -d "today" +"%Y%m%d%H%M%S"`

myvarcsv="id,user,host,/dumpfolder,--databases database1 database2
id2,user2,host2,/dumpfolder2,--databases database2"

while IFS=, read id user host dumpfolder databases ; do
        remotecommand="gotodmpfld() { cd $dumpfolder; } ; gotodmpfld; \
                /usr/local/mariadb10/bin/./mysql -e 'FLUSH TABLES WITH READ LOCK; \
                        SET GLOBAL read_only=ON;SELECT NOW(), @@read_only, @@gtid_current_pos, @@gtid_binlog_pos, @@gtid_slave_pos\G \
                        SELECT NOW();SHOW MASTER STATUS\G' &>> $id-replog; \
                /usr/local/mariadb10/bin/./mysqldump --max-allowed-packet=512m -u$user $databases \
                        > $id-$timestamp.sql 2>> $id-replog; \
                /usr/local/mariadb10/bin/./mysql -e 'SET GLOBAL read_only=OFF; UNLOCK TABLES; SELECT NOW(), @@read_only\G' &>> $id-replog; \
                tar -cvzf $id-$timestamp.tgz $id-replog $id-$timestamp.sql &>> $id-ziplog"
        screen -dmS $id bash -c $"ssh $user@$host \"$remotecommand\" && scp $user@$host:$dumpfolder/$id-$timestamp.tgz  ."
done << E
$myvarcsv
E
