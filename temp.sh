for d in a b c d e; do mysqldump --max_allowed_packet=512m $d | gzip -c > $d.gz ; done
