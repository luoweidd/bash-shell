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

echo "install mysql5.7"

touch /etc/yum.repos.d/mysql-community.repo
echo "
# Enable to use MySQL 5.7
[mysql57-community] 
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/\$basearch/
enabled=1   
gpgcheck=0 
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
" > /etc/yum.repos.d/mysql-community.repo
yum install mysql-community-server -y
mkdir /DB-DATA/mysql
sed -i 's/datadir=\/var\/lib\/mysql/datadir=\/DB-DATA\/mysql/' /etc/my.cnf
systemctl enable mysqld

init_pwd=`cat /var/log/mysqld.log |grep "password is generated for root@localhost:"|awk '$11{print $11}'`
new_password="kifNt-fqHb6l"
echo $init_pwd
`mysql -uroot -p"${init_pwd}" --connect-expired-password  -e "ALTER user 'root'@'localhost' identified by 'kifNt-fqHb6l';"`
mysql -uroot -p"$new_password" <<EOF
CREATE DATABASE \`dwc-new-admin\`;
exit
EOF
echo "msyql isntall ok!"

echo "install redis 3.2.12"
yum install redis* -y 
#mv /etc/redis.conf /etc/redis.conf.bak
#mkdir /DB-DATA/redis

systemctl enable redis
systemctl start redis

echo "redis install ok!"

echo "mongodb-org-4.0"

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
systemctl enable mongod
systemctl start mongod
mongo <<EOF
use game_server
db.createUser({
    user:"root",
    pwd:"WERteol367765",
    roles:[{
        role:"dbAdmin",
        db:"game_server"
    },{
        role:"readWrite",
        db:"game_server"
    }]
})
EOF

echo "All data services deployed!............"
