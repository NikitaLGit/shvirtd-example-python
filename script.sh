#!/bin/bash

# Проверка прав администратора
if [ "$(id -u)" != "0" ]; then
  echo "Этот скрипт должен выполняться от имени root"
  exit 1
fi

git --version
if [ "$?" != 0 ]; then
  apt update && \
  apt install -y git
fi

cd /opt

if [ ! -d "/opt/shvirtd-example-python" ]; then
  git clone https://github.com/NikitaLGit/shvirtd-example-python.git && \
  cd shvirtd-example-python
else
  cd shvirtd-example-python
fi

docker compose up -d

docker ps -a
curl http://localhost:8090

exit 0
