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

`.dockerignore` файл на момент выполнения задания:

<img src="https://github.com/user-attachments/assets/8f5e57ff-371e-4cd1-b85b-61f43cfadc56" width="300">

В `/app` контейнера перенослось только:

<img src="https://github.com/user-attachments/assets/9d29390f-7ef6-49fa-acc7-8218c12aadc2" width="450">

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
      - ./bin/crontab:/var/spool/cron/crontabs/root #не работает. пишет, что хочу поставить файл вместо директории
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

В папке проекта создаем: 
- `bin/`
  - `backup`
    ```bash
    #!/bin/sh
    now=$(date +"%s_%Y-%m-%d")
    /usr/bin/mysqldump --opt -h 172.20.0.10 -u ${MYSQL_USER} -p"${MYSQL_PASSWORD}" ${MYSQL_DATABASE} > "./backup/${now}_dump.sql"
    ```
  - `crontab`
    ```bash
    #minute hour    day     month   week    command
    0       0       *       *       *       /usr/local/bin/backup
    ```
- `backup/`
  - тут будут храниться файлы дампов.

Документация по образу не совсем мне понятна. По итогу в локальной папке `backup/` должны появляться дамп файлы базы. Ничего не происходит. Пока не решил, почему так.

Напишем скрипт для ручного запроса `cron_single.sh`:
#По факту повтор скрипта из документации к образу `schnitzler/mysqldump`, только выполняем команду к контейнеру `shvirtd-example-python-cron-1` собраному из `compose.yaml` - `cron`:
```bash
#!/bin/bash

now=$(date +"%H-%M-%S_%d%m%Y")
docker exec -ti shvirtd-example-python-cron-1 mysqldump --opt -h 172.20.0.10 -u ${MYSQL_USER} -p"${MYSQL_PASSWORD}" ${MYSQL_DATABASE} > "./backup/${now}_dump.sql"
```

Чтобы не светить пароли и логины нашел скрипт `runenv.sh` который считывает на ввод файл `.env` и передает его в скрипт `cron_single.sh`.

`runenv.sh`:
```bash
#!/bin/bash

ENV_FILE="$1"
CMD=${@:2}

set -o allexport
source $ENV_FILE
set +o allexport

$CMD
```

Запустим скрипт из папки проекта в таком виде ...
```bash
./runenv.sh .env bash cron_single.sh
```
... и получим файл (для примера) `./backup/16-50-29_25042025_dump.sql` (один файл положил в репозиторий).

Внесем в `crontab` запись для выполнения каждую минуту:

<img src="https://github.com/user-attachments/assets/a64fad6d-f621-4fa2-9699-c2bc7276608a" width="550">

> [!WARNING]
> ТОЛЬКО ОН НЕ ХОЧЕТ ВЫПОЛНЯТЬСЯ НИ В КАКУЮ

## Задача 6

> ### Раздел для тех, кто, возможно, столкнется с таким же при выполнении
>
>  После установки `sudo snap install dive` и того, как запушил весь репозиторий на github теперь у меня не поднимается `docker compose`. На `localhost:8080` появился процесс `docker-pr`
>  
>  <img src="https://github.com/user-attachments/assets/4f348d5e-af8f-40b4-901f-9f6a97de5fa0" width="550">
 
  > [!TIP]
  > Нельзя запускать устанвоку через `snap` если `docker` стоит через `apt-get`
  > 
  > Решение на https://github.com/wagoodman/dive/issues/546

> Полезная команда, если после этого не выключаются конейнеры: `sudo killall containerd-shim`

Скачали образ:

<img src="https://github.com/user-attachments/assets/337e68fe-aa46-4284-b821-6b3c4098b874" width="550">

С 5 попытки устанавливаем верный `dive` (https://lindevs.com/install-dive-on-ubuntu) и запускаем его на наш image и ищем в нем слой с установка `terraform`:

<img src="https://github.com/user-attachments/assets/60c86d7b-ec16-4370-8cf0-8da409b85cfa" width="750">

Для того, чтобы вытащить `/bin/terraform` делаем:

```bash
docker save hashicorp/terraform:latest -o our/path/terraform.tar
```

Получаем:

<img src="https://github.com/user-attachments/assets/8d4e79b9-9b73-40d7-958d-0412305dab48" width="300">

В `dive` на уровне слоя видим его хеш глубины:

<img src="https://github.com/user-attachments/assets/1595a01f-b6a6-4c88-9917-fdd1452fa7b9" width="650">

```bash
tar -xf terraform.tar
```

После того как разархивировали tar файл переходим в папку `./blobs/sha256` и выдим хеши уровней образа:

<img src="https://github.com/user-attachments/assets/c20ccc8c-a542-4b8a-8630-af8e839db8cd" width="650">

```bash
tar -xf e35d097
```

<img src="https://github.com/user-attachments/assets/ffb71125-3ea8-4c5c-9b8a-4290f82890a1" width="650">

Перейдем в папку `bin/` и проверим версию `terraform`:

<img src="https://github.com/user-attachments/assets/61a3ca66-bc14-4040-847a-00ef99e003b3" width="400">

## Задача 6.1

Поднимем контейнер:

<img src="https://github.com/user-attachments/assets/3d03757c-56b6-470f-a42c-6fa4e7d72135" width="650">
<img src="https://github.com/user-attachments/assets/3867a6fc-39fa-4689-9e6e-b8e2f16bb4f0" width="650">

С помощью `docker cp` обратимся к файлу в конейнере и получим файл (terracopy) у себя на клиенте:

<img src="https://github.com/user-attachments/assets/25815161-98b4-43fe-b505-9fe76f512201" width="650">
<img src="https://github.com/user-attachments/assets/52c7bf05-976f-4746-97eb-32255f313ac5" width="450">

## Задача 6.2

> [!WARNING]
> Задачу 6.2 пока не понял как выполнить. 7 не успеваю. Позже добавить возможно и отправить на проверку верности именно этих доп заданий?

## Задача 7

Тут может быть Ваша реклама.

## License

This project is licensed under the MIT License (see the `LICENSE` file for details).
