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
    cd /opt/new_project
fi

echo " "
echo "Start downloading tomcat, version 8.5.37……"
wget http:\/\/mirrors.hust.edu.cn\/apache\/tomcat\/tomcat\-8\/v8.5.37\/bin\/apache-tomcat-8.5.37.tar.gz
echo " "
if [ -f apache-tomcat-8.5.37.tar.gz ];then
    tar -xvf apache-tomcat-8.5.37.tar.gz
    echo "Extract to the admin package site"
    mv -f apache-tomcat-8.5.37 admin-package
    sh admin-package/bin/startup.sh
    echo "Extract to the chat package site"
    cp -arf admin-package chat_package
    sed -i 's/8080/8087/' admin-package/conf/server.xml
    sh chat_package/bin/startup.sh
else
    echo "The tomcat package download failed and the associated package files were not found"
fi
