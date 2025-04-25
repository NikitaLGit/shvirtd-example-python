#!/bin/bash

now=$(date +"%H-%M-%S_%d%m%Y")
docker exec -ti shvirtd-example-python-cron-1 mysqldump --opt -h 172.20.0.10 -u ${MYSQL_USER} -p"${MYSQL_PASSWORD}" ${MYSQL_DATABASE} > "./backup/${now}_dump.sql"


# были проблемы с контейнером из compose.yaml

# if [ $? != 0 ]; then
# docker run \
# 	--network=shvirtd-example-python_backend \
# 	-v 'pwd'/backup=/backup \
# 	--name='cron_1' \
# 	schnitzler/mysqldump:latest
# else
#     exit 0
# fi
