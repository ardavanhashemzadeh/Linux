#! /bin/bash

# Ardavan Hashemzadeh
# Dump Databases then send off
# Feb 27 2019

TIME=`date -d "today" +"%Y%m%d%H%M%S"`
DUMPFILE=dump-$TIME

SCPSRC=$DUMPFILE.gz
SCPDST=USERNAME@HOST:/PATH/TO/PLACE/DUMP
SQLCON="-uUSERNAME -pPASSWORD -hHOST —-PORT 3333”
SQLOPTS="--master-data --gtid --single-transaction --compress --order-by-primary --max-a$
DBS="--databases SPACE DELIMITATED LIST OF DATABASES TO DUMP”

mysql $SQLCON -e "FLUSH TABLES WITH READ LOCK; SET GLOBAL read_only=1;" &>> log

mysqldump $SQLCON $SQLOPTS $DBS > $DUMPFILE &>> log

gzip -k $DUMPFILE &>> log

scp $SCPSRC $SCPDST &>> log

mysql $SQLCON -e "SET GLOBAL read_only=0; UNLOCK TABLES;" &>> log
