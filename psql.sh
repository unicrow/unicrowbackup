#!/bin/bash

# For PostgreSQL

# Configuration #
DBNAME=testdb
USERNAME=testuser
HOST=localhost
SQL_FILENAME=db_backup.sql
JSON_FILENAME=db_backup.json
APP_DIR=/var/www/vhost/test.unicrow.com  # Do not use slash at the end
#################


# FIRST STEP #

echo -e -n """\033[0;96m
||    ||  ||    ||  ||  ||||||||  ||||||    ||||||   ||    ||    ||
||    ||  ||||  ||  ||  ||        ||   ||  ||    ||   ||  ||||  ||
||    ||  ||  ||||  ||  ||        |||||    ||    ||    ||||  ||||
||||||||  ||    ||  ||  ||||||||  ||   ||   ||||||      ||    ||
\033[0;97m"""

echo -en "\nControl File"
BACKUP_ERROR=false
BACKUP_NAME=$(date +"%d.%m.%Y")
BACKUP_LOGFILE=$APP_DIR/backup/uncompressed/$BACKUP_NAME/backup.log

{
  cd $APP_DIR >/dev/null 2>&1
} || {
  echo -en "\n* \033[0;31m$APP_DIR not found!\033[0;97m"
  BACKUP_ERROR=true
}

if [ $BACKUP_ERROR == false ]; then
  {
    mkdir backup >/dev/null 2>&1 && echo -en "\n* Create: \033[0;32m`pwd`/backup\033[0;97m"
  } || {
    echo -en "\n* Already exist: \033[0;32m`pwd`/backup\033[0;97m"
  }

  cd backup
  {
    mkdir compressed >/dev/null 2>&1 && echo -en "\n* Create: \033[0;32m`pwd`/compressed\033[0;97m"
  } || {
    echo -en "\n* Already exist: \033[0;32m`pwd`/compressed\033[0;97m"
  }
  {
    mkdir uncompressed >/dev/null 2>&1 && echo -en "\n* Create: \033[0;32m`pwd`/uncompressed\033[0;97m"
  } || {
    echo -en "\n* Already exist: \033[0;32m`pwd`/uncompressed\033[0;97m"
  }

  cd uncompressed
  rm -r $BACKUP_NAME >/dev/null 2>&1
  mkdir $BACKUP_NAME
  cd $BACKUP_NAME
  touch $BACKUP_LOGFILE
fi
##############


#   BACKUP   #
if [ $BACKUP_ERROR == false ]; then
  echo -en "\n\nBackup"
fi

# SQL
if [ $BACKUP_ERROR == false ]; then
  {
    export LC_ALL="en_US.UTF-8"
    pg_dump -U $USERNAME -w -h $HOST -d $DBNAME -f $SQL_FILENAME >> $BACKUP_LOGFILE && echo -en "\n* \033[0;32msql\033[0;97m"
  } || {
    echo -en "\n* \033[0;31msql\033[0;97m"
    BACKUP_ERROR=true
  }
fi

# JSON
if [ $BACKUP_ERROR == false ]; then
  {
    source $APP_DIR/web/env/bin/activate >> $BACKUP_LOGFILE &&
    $APP_DIR/web/source/manage.py dumpdata -e contenttypes > $JSON_FILENAME &&
    deactivate >> $BACKUP_LOGFILE && echo -en "\n* \033[0;32mjson\033[0;97m"
  } || {
    echo -en "\n* \033[0;31mjson\033[0;97m"
    BACKUP_ERROR=true
  }
fi

# MEDIA
if [ $BACKUP_ERROR == false ]; then
  {
    cp -R $APP_DIR/web/source/media/ . >> $BACKUP_LOGFILE && echo -en "\n* \033[0;32mmedia\033[0;97m"
  } || {
    echo -en "\n* \033[0;31mmedia\033[0;97m"
    BACKUP_ERROR=true
  }
fi
##############


#  COMPRESS  #
if [ $BACKUP_ERROR == false ]; then
  echo -en "\n\nCompress"
  {
    cd $APP_DIR/backup/uncompressed/ >> $BACKUP_LOGFILE &&
    zip -r ../compressed/$BACKUP_NAME.zip $BACKUP_NAME/ >> $BACKUP_LOGFILE &&
    echo -en "\n* \033[0;32mcompleted\033[0;97m"
  } || {
    echo -en "\n* \033[0;32merror\033[0;97m"
    BACKUP_ERROR=true
  }
fi
##############


if [ $BACKUP_ERROR == false ]; then
  echo -en "\n\n\033[0;32mEnd of Backup\033[0;97m\n\n"
else
  echo -en "\n\n\033[0;31mBackup Error!\033[0;97m"
  echo -en "\n\033[0;33mNote: Check Configuration\033[0;97m\n\n"
  cd $APP_DIR/backup >/dev/null 2>&1
  rm -r uncompressed/$BACKUP_NAME >/dev/null 2>&1
  rm -r compressed/$BACKUP_NAME.zip >/dev/null 2>&1
fi
