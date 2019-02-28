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
mysqldb_packge_name="dwc-new-admin_"$datetime_now".zip"
docker exec -it my-mysql mysqldump -uroot -p"ksf385*$" --default-character-set=utf8 dwc-new-admin |zip -9 > $mysql_backup$mysqldb_packge_name

echo "------------Backup completed, check backup---------------"
ls -l $mysql_backup$mysqldb_packge_name
ls -l $mysql_backup$mysqldb_packge_name |awk '$5{print "File szie:"$5/1024/1024"MB"}'
echo "---------End backup Mysql Databases------------"
#scp -P11078 $mysqldb_packge_name root@172.16.170.47:/DB-backup/mysql/
echo "


"
echo "------------Backup Mongo Databases------------"
docker_backup_dir="/mongodb_backup/"
flag=docker exec -it mongodb ls -l /mongodb_backup
if [ $flag == *No such file or directory* ];then
	docker exec -it mongodb mkdir $docker_backup_dir	
fi
mongodb_packge_name="game-server_"$datetime_now".archive"
docker exec -it mongodb mongodump -ulyh -pWERteol367765 -d game_server --archive=$docker_backup_dir$mongodb_packge_name --gzip
dcoker cp  mongodb:$docker_backup_dir$mongodb_packge_name $mongo_backup_dir
dcoker exec -it mongodb rm -f $docker_backup_dir"*"
echo "------------Backup completed, check backup---------------"
ls -l $mongo_backup_dir$mongodb_packge_name
ls -l $mongo_backup_dir$mongodb_packge_name |awk '$5{print "File szie:"$5/1024/1024"MB"}'
echo "---------End backup Mongo Databases------------"
#scp -P $mongodb_packge_name root@172.16.170.47:/DB-backup/mongo/
echo "


"
echo "----------------------------------------------------End backup DBbases-----------------------------------------------------"
