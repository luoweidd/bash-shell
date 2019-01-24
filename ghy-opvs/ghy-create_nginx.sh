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


touch /etc/yum.repos.d/nginx.repo
echo "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo
yum install nginx -y
systemctl start nginx
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
echo "nginx conf file bak ok!!!"

touch /etc/nginx/nginx.conf
echo "
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 65535;
    multi_accept on;
    use epoll;
}

http {
    log_format  main  '\$remote_addr -- \$remote_user - [\$time_local] - \$request 
                      \$status - \$body_bytes_sent - \$http_referer
                      \$http_user_agent - \$http_x_forwarded_for';

    access_log  /var/log/nginx/access.log  main;
    include     /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;
    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;
    
}" > /etc/nginx/nginx.conf

systemctl restart nginx