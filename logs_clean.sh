#########SCRIPT DE CONTROLE DE LOGS#######
CRONTAB: (0 4 * * * /root/logs_control.sh)

#!/bin/bash

DIRNAME='/logs'

PURGEDAYS='+15'

ZIPDAYS='+1'

find ${DIRNAME} -type f -mtime ${ZIPDAYS} -name "*.log*" -a ! -name "*.gz" -exec gzip -f {} \;

find ${DIRNAME} -type f -mtime ${ZIPDAYS} -name "*.out*" -a ! -name "*.gz" -exec gzip -f {} \;

find ${DIRNAME} -type f -mtime ${PURGEDAYS} -name "*.gz" -exec rm -f {} \;

