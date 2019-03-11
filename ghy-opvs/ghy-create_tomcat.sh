#!/bin/bash

platform=`uname -i`
if [ $platform != "x86_64" ];then 
echo "this script is only for 64bit Operating System !"
exit 1
fi
echo "the platform is ok"
cat << EOF
+---------------------------------------+
|   your system is CentOS 7 x86_64      |
|      start optimizing.......          |
+---------------------------------------
EOF


yum install java* -y


Extract_to_site(){
    ps -aux|grep admin_package |grep -v grep |cut -c 9-15 |xargs kill -9
    ps -aux|grep chat_package |grep -v grep |cut -c 9-15 |xargs kill -9
    echo "Extract to the admin package site"
    if [ ! -e apache-tomcat-8.5.37 ];then	
       tar -xvf apache-tomcat-8.5.37.tar.gz
    fi
    cp -arf apache-tomcat-8.5.37 admin_package
    rm -rf admin_package/webapps/*
    sed -i 's/8080/8086/' admin_package/conf/server.xml
    sh admin_package/bin/startup.sh
    rm -rf apache-tomcat-8.5.37 #清除多余目录
    echo "Extract to the chat package site"
    cp -arf admin_package chat_package
    sed -i 's/8086/8087/' chat_package/conf/server.xml
    sed -i 's/8005/8007/' chat_package/conf/server.xml
    sed -i 's/8009/8010/' chat_package/conf/server.xml
    sh chat_package/bin/startup.sh
    echo "Service startup result state"
    echo -e "\033[31m `ps -aux|grep admin-package`\033[0m"
    echo -e "\033[31m `ps -aux|grep chat-package`\033[0m"
}

Install_admin_chat_tomcat(){
    if [ ! -f apache-tomcat-8.5.37.tar.gz ];then
       echo "Start downloading tomcat, version 8.5.37……"
       wget http:\/\/mirrors.hust.edu.cn\/apache\/tomcat\/tomcat\-8\/v8.5.37\/bin\/apache-tomcat-8.5.37.tar.gz
       Extract_to_site
    else
       Extract_to_site
    fi
}

Total_directory="/opt/new_project"
echo "Create the new_object path and enter……"
if [ ! -e $Total_directory ];then
    mkdir $Total_directory
    echo Enter $Total_directory directory
    cd $Total_directory
    Install_admin_chat_tomcat
else
    cd $Total_directory
    Install_admin_chat_tomcat
fi


