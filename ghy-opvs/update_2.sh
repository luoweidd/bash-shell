#! /bin/bash

# Project_path
Project_path=/opt/new_project
# GIT_FILE=$(ls -t $Project_path/download/git/gitlab/newFramework | head -1| tail -1)

# git directory
Deploy_path=$Project_path/download/git_bak
# PACKAGE2=/opt/new_project/download/git/new

# 获取当前时间
TIME=$(date '+%Y-%m-%d_%H-%M-%S')

#服务目录名称
payserver=game-pay
downloadserver=download-serve
adminserver=admin_package
chatserver=chat_package

#服务组
Server_arrays=($payserver $downloadserver $adminserver $chatserver)

for server in ${Server_arrays[@]}
do
    if [ -e $Deploy_path/$server ]; then
        echo "Enter the game-pay backup directory!"
        cd $Project_path/$server/backup
        echo "Create a backup directory (time for directory name)!"
        mkdir $TIME
        cd $Project_path/$server
        echo "To start backup…………!"
        if [ [ $server -ne $adminserver ] && [ $server -ne $chatserver ] ];then
            mv -f $server-0.0.1-SNAPSHOT.jar backup/$TIME
            echo "-------------------Complete backup!-----------------"
            cd $Deploy_path/$server
            echo "Go to the application deployment path and copy the application package into the deployment path!"
            cp -R $server-0.0.1-SNAPSHOT.jar $Project_path/$server
            echo "File copy complete!"
            echo "displaying results:"`ls -l $Project_path/game-pay`
        else
            cd $Project_path/$server/webapps
            echo "Go to the application deployment path and copy the application package into the deployment path!"
            mv -rf ROOT/ ROOT.war manage-games/ $Project_path/$server/backup/$TIME
            echo "-------------------Complete backup!-----------------"
            cd $Deploy_path/$server
            cp -R ROOT/ manage-games/ $Project_path/$server/webapps
            echo "File copy complete!"
            echo "displaying results:" | ls -l $Project_path/$server/webapps
        fi
    fi
done
echo "Clean up warehouse files…………"
rm -rf $Deploy_path/*
echo "---------------------File update completed!---------------------"
