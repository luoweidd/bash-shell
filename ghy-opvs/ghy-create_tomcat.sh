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


yum install java -y


Total_directory="/opt/new_project"
echo "Create the new_object path and enter……"
if [ ! -e $Total_directory ];then
    mkdir $Total_directory
    echo Enter $Total_directory directory
    cd $Total_directory
fi

Extract_to_site(){
    ps -aux|grep admin-package |grep -v grep |cut -c 9-15 |xargs kill -9
    ps -aux|grep chat-package |grep -v grep |cut -c 9-15 |xargs kill -9
    echo "Extract to the admin package site"
    if [ ! -e apache-tomcat-8.5.37 ];then	
       tar -xvf apache-tomcat-8.5.37.tar.gz
    fi
    cp -arf apache-tomcat-8.5.37 admin-package
    rm -rf admin-package/webapps/*
    sed -i 's/8080/8086/' admin-package/conf/server.xml
    sh admin-package/bin/startup.sh
    rm -rf apache-tomcat-8.5.37 #清除多余目录
    echo "Extract to the chat package site"
    cp -arf admin-package chat-package
    sed -i 's/8086/8087/' chat-package/conf/server.xml
    sh chat-package/bin/startup.sh
    echo "Service startup result state"
    echo -e "\033[31m `ps -aux|grep admin-package`\033[0m"
    echo -e "\033[31m `ps -aux|grep chat-package`\033[0m"
}

echo " "
if [ ! -f apache-tomcat-8.5.37.tar.gz ];then
    echo "Start downloading tomcat, version 8.5.37……"
    wget http:\/\/mirrors.hust.edu.cn\/apache\/tomcat\/tomcat\-8\/v8.5.37\/bin\/apache-tomcat-8.5.37.tar.gz
    Extract_to_site
else
    Extract_to_site
fi
