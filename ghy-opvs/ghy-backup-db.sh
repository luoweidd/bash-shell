#!/bin/bash

echo "
    Author:luowei
    E-mail:3245554@qq.com
    Company：Guang Heng Yi
    Datetime:2019-02-22 11:00
"
echo "----------------------------------------------------Start backup DBbases-----------------------------------------------------"
echo "------------------------Check whether the backup directory exists--------------------------"

backup_dir="/DB_backup/"
mysql_backup_dir=$backup_dir"Mysql_backup/"
mongo_backup_dir=$backup_dir"Mongo_backup/"
datetime_now=`date +"%y-%m-%d %H"`

if [ !-d $backup_dir  ];then
	echo "Creat"$backup_dir
	mkdir $backup_dir
	if [ !-d $mysql_backup_dir ];then
		echo "Creat"$mysql_backup_dir
		mkdir $mysql_backup_dir
	fi
	if [ !-d $mongo_backup_dir ];then
		echo "Creat"$mongo_backup_dir
		mkdir $mongo_backup_dir
	fi
fi
echo "------------Backup Mysql Databases------------"

docker exec -it my-mysql mysqldump -uroot -p"ksf385*$" --default-character-set=utf8 dwc-new-admin |zip -9 > $mysql_backup"dwc-new-admin_"$datetime_now".zip"

echo "------------Backup completed, check backup---------------"
ls -l $mysql_backup"dwc-new-admin_$datetime_now".zip
ls -l $mysql_backup"dwc-new-admin_$datetime_now".zip |awk '$5{print "File szie:"$5/1024/1024"MB"}'
echo "---------End backup Mysql Databases------------"
echo "


"
echo "------------Backup Mongo Databases------------"
docker_backup_dir="/mongodb_backup/"
flag=docker exec -it mongodb ls -l /mongodb_backup
if [ $flag == *No such file or directory* ];then
	docker exec -it mongodb mkdir $docker_backup_dir	
fi
docker exec -it mongodb mongodump -ulyh -pWERteol367765 -d game_server --archive=$docker_backup_dir"game-server_"$datetime_now".archive" --gzip
dcoker cp  mongodb:$docker_abckup_dir"game-server_"$datetime_now".archive" $mongo_backup_dir
dcoker exec -it mongodb rm -f $docker_backup_dir"*"
echo "------------Backup completed, check backup---------------"
ls -l $mongo_backup_dir"game-server_"$datetime_now".archive"
ls -l $mongo_backup_dir"game-server_"$datetime_now".archive" |awk '$5{print "File szie:"$5/1024/1024"MB"}'
echo "---------End backup Mysql Databases------------"
echo "


"
echo "----------------------------------------------------End backup DBbases-----------------------------------------------------"

