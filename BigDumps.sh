#!/bin/bash
# Ardavan Hashemzadeh
# March 8 2019
# Script the dumping of several dbs

timestamp=`date -d "today" +"%Y%m%d%H%M%S"`

# id,user,host,dumpfolder,databases
mylist="\
id,user,host,dumpfolder,--databases database1 database2 database3"

while IFS=, read id user host dumpfolder databases; do
	screen -dmS `date -d "today" +"%Y%m%d%H%M%S"` \
	ssh $user@$host bash -c "cd $dumpfolder;  \
    /usr/local/mariadb10/bin/./mysql -e '\
      FLUSH TABLES WITH READ LOCK; SET GLOBAL read_only=ON; \
      SELECT NOW(), @@read_only, @@gtid_current_pos, @@gtid_binlog_pos, @@gtid_slave_pos\G \
      SHOW MASTER STATUS\G' >> $id-replog ; \
    /usr/local/mariadb10/bin/./mysqldump --max-allowed-packet=512m -uroot $databases > $id-$timestamp.sql ; \
    tar -cvzf $id-$timestamp.tgz $id-replog $id-$timestamp.sql ; \
    /usr/local/mariadb10/bin/./mysql -e 'set global read_only=OFF; UNLOCK TABLES;'"
done << E
$mylist
E
