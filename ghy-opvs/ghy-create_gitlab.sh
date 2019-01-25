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

yum install -y curl policycoreutils-python openssh-server
systemctl enable sshd
systemctl start sshd
firewall-cmd --permanent --add-service=http
systemctl reload firewalld
yum install postfix -y
systemctl enable postfix
systemctl start postfix
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sh
EXTERNAL_URL="http://192.168.0.62" yum install -y gitlab-ee
