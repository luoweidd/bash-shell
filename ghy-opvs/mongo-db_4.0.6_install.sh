#!/bin/bash

#system_type=$(cat /etc/redhat-release)
#if [[ $system_type ]];then 
#	if [[ $system_type == *CentOS* ];then
#		rpm -ivh https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-server-4.0.6-1.el7.x86_64.rpm https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-mongos-4.0.6-1.el7.x86_64.rpm https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-tools-4.0.6-1.el7.x86_64.rpm https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-shell-4.0.6-1.el7.x86_64.rpm
#	else
#		echo "This version only applies to Centos 7 or RedHat 7. If you need to add other system versions, Please add your own subsequent code."
#	fi
#fi

touch /etc/yum.repos.d/mongodb-org-4.0.repo
echo "
[mongodb-org-4.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc
" > /etc/yum.repos.d/mongodb-org-4.0.repo

yum install -y mongodb-org*
