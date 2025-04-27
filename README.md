# Fork репозиторий для ДЗ Docker №2
## Задача 0

Нет docker-compose. Стоит docker compose v 2.35.1

<img src="https://github.com/user-attachments/assets/91899c32-33cf-4453-bc6d-ffd5f46ebdb7" width="600">

## Задача 1

Напишем `Dockerfile.python` Через `docker compose` соберем 4 image и из них сервисы.
```bash
FROM python:3.9-slim

RUN apt-get update && apt-get install -y default-mysql-client
WORKDIR /app
COPY . .

RUN pip install --no-cache-dir -r requirements.txt
CMD [ "python", "main.py" ]
```
Получим:

> [!WARNING]
> Забежал немного дальше, поэтому 3 задание сразу в первое

<img src="https://github.com/user-attachments/assets/36bcb655-3a2b-4430-a848-d12ff27de014?raw=true" height="450">

Перейдем на внешний ip адрес сервера в YC на порт `8090`:

<img src="https://github.com/user-attachments/assets/ca66e15d-509d-49b5-8ada-f5d9f0ac7d05" width="600">

> [!TIP]
> Запустить через venv не получилось пока.

Чтобы имзенить параметр названия таблицы `request` на другой (в мое случае `table1` Изменим следующие файлы:
- в `env` добавить параметр `MYSQL_TABLE="table1"`
- `compose.yaml`
  - в environment `db` добавим `MYSQL_TABLE=${MYSQL_TABLE}`
  - в environment `web` добавим `DB_TABLE=${MYSQL_TABLE}`
- `main.py`
  - добавим `db_table=os.environ.get('DB_TABLE)`
  - в sql запрос изменим `EXISTS {db_database}.request... на ..EXISTS {db_database}.{db_table}`
  - и поправим `query = f"INSERT INTO {db_table} (request_date, request_ip) VALUES (%s, %s)"`

Получаем новое заданное название таблицы в базе virtd:

<img src="https://github.com/user-attachments/assets/34b76a77-0a74-49a0-941f-a288c8fca827" height="150">

> [!WARNING]
> Только после этого постоянно появляется ошибка ниже. Раз 6 и потом все ок. Можете подсказать почему?
> 
> `web-1 | mysql.connector.errors.DatabaseError: 2003 (HY000): Can't connect to MySQL server on 'db:3306' (111)`

Не сразу создается база и поэтому проблемы? Но в compose.yaml сделал `links: - db`
Это не значит, что контейнер будет работать после удачного запуска конейтнера с базой?

P.S Решил оставить ход мыслей. Скорее всего не значит. Это влияет на порядок построения image самого. Тогда как можно отсрочить подключение к базе только после успешного ее создания?

## Задача 2

По инструкции создадим container registry в YC. Выгрузим туда образ на основе `Dockerfile.python`:

<img src="https://github.com/user-attachments/assets/1523afd9-1337-42ef-b5e5-7998f90b9c60" height="400" width="600">
<img src="https://github.com/user-attachments/assets/6d8433f9-7cfc-4272-a08a-4a043769a389" height="400" width="600">

## Задача 3

Все сделал на этапе `ЗАДАЧА 1`. 
Вывод SQL запросов (уже поменял env названия таблицы с `request` на `table1`)

<span>
  <div><img src="https://github.com/user-attachments/assets/2c5b9e79-8cfe-461f-b0a5-cc5db0922f4c" height="200"> Все базы </div>
  <div><img src="https://github.com/user-attachments/assets/ae687cb1-1687-40b0-831b-472f49d5bf78" height="100"> Переключаемся на базу virtd </div> 
  <div><img src="https://github.com/user-attachments/assets/57502aa5-dd32-41a4-83c0-3ccb8ddb8e62" height="100"> Все таблицы в выбранной базе </div>
  <div><img src="https://github.com/user-attachments/assets/3dbd8ac4-fc19-414f-955a-b298ccb57d2a" height="200"> Все данные из таблицы </div>
</span>

## Задача 4

Создадим новую ВМ. Напишем скрипт `script.sh`. Запустим его. ПОи итогу все пройдет как надо. Перейдем на внешний ip и сделаем, что требует от нас задача:
<img src="https://github.com/user-attachments/assets/3034a697-7732-4f98-8b4f-e0b1eb99a857" width="650" height="370">

Скрипт:
```bash
#!/bin/bash

#Скрипт для запуска на новой машине 4 сервиса

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
#curl http://localhost:8090 #свой адрес для проверки

exit 0
```

Теперь настроим remote `ssh context`:
На своем пк (клиенте) добавим/ изменим `./ssh/config`:
```
Host testvmdoc
  Hostname 158.160.95.99 #на момент работы
  User lns
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```

На удаленном сервере (158.160.95.99) добавим наш ssh pub key в ~/.ssh/authorized_keys
Протестим работу:

<img src="https://github.com/user-attachments/assets/f11e73bf-f282-4c3d-9176-ce8855ec434f" width="650">

На клиенте запустим:
```bash
docker context create testvmdoc --docker "host=ssh://testvmdoc"
```

Проверим:

<img src="https://github.com/user-attachments/assets/cea8f103-133d-4364-9dc9-5496743a59e8" width="650">

Запустим с нашего клиента просмотр image на сервере:

<img src="https://github.com/user-attachments/assets/fc492412-802f-4ae9-85dd-31fcab50b12c" width="650">

## Задача 5

Добавим в файл `compose.yaml` два сервиса `cron` и `backup`:

```compose
cron:
    image: schnitzler/mysqldump
    networks:
      backend:
        ipv4_address: 172.20.0.15
    volumes:
      #- /opt/bin/crontab:/var/spool/cron/crontabs/root
      - ./backup:/usr/local/bin/backup
    volumes_from:
      - backup
    command: ["-l", "8", "-d", "8"]
    environment:
      - MYSQL_HOST=172.20.0.10
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
  backup:
    image: busybox
    networks:
      backend:
        ipv4_address: 172.20.0.20
    volumes:
      - ./backup:/backup
    restart: always
```

## License

This project is licensed under the MIT License (see the `LICENSE` file for details).
