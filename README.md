# **Unicrow Backup**
**For Django**

```
git clone https://github.com/unicrow/unicrowbackup.git
cd unicrowbackup
```

## **App Directory**
```
Test
|
|-------backup
|       |
|       |-------backup.sh
|       |-------compressed/
|       |-------uncompressed/
|
|-------web
        |
        |-------env/      (virtualenv=Python, Django ...)
        |-------source/   (Source Code)
                |
                |-------manage.py   
                |-------media/      (Media Directory)
                |-------...
                |-------...
```

## **PostgreSQL**

#### Set Database Information
```
touch ~/.pgpass
chmod 0600 ~/.pgpass
echo "server:port:database:username:password" >> .pgpass
(server=localhost, port=5432, database=testdb, username=testuser, password=testtest)
```

#### Change Configuration
```
# Configuration #
DBNAME=testdb
USERNAME=testuser
HOST=localhost
SQL_FILENAME=db_backup.sql
JSON_FILENAME=db_backup.json
APP_DIR=/var/www/vhost/test.unicrow.com  # Do not use slash at the end
#################
```

#### Run Backup
```
bash psql.sh
```

## **MySQL**

#### Change Configuration
```
# Configuration #
DBNAME=testdb
USERNAME=testuser
PASSWORD=testtest
SQL_FILENAME=db_backup.sql
JSON_FILENAME=db_backup.json
APP_DIR=/var/www/vhost/test.unicrow.com  # Do not use slash at the end
#################
```

#### Run Backup
```
bash mysql.sh
```

## **Cronjob**
#### Every Saturday
```
00 1 * * 6 /bin/bash /var/www/vhost/test.unicrow.com/backup/backup.sh > /dev/null 2>&1
```
