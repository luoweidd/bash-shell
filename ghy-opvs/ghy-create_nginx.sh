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
#ps -aux|grep nginx|grep -v grep|cut -c 9-15|xargs kill -15

systemctl start nginx
mv -f /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
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
    log_format  main  \"\$remote_addr -- \$remote_user - [\$time_local] - \$request 
                      \$status - \$body_bytes_sent - \$http_referer
                      \$http_user_agent - \$http_x_forwarded_for\";

    access_log  /var/log/nginx/access.log  main;
    include     /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;
    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   0;
    types_hash_max_size 4096;
    server_tokens       off;
    client_header_timeout 20;
    client_body_timeout 120;
    reset_timedout_connection on;
    send_timeout 20;

    # gzip压缩功能设置  

    gzip  on;
    gzip_disable "msie6";
    gzip_proxied any;
    gzip_buffers 4 8k;
    gzip_min_length 1024;
    gzip_comp_level 9;
    gzip_vary on;
    gzip_types font/ttf font/otf image/svg+xml image/png image/x-icon image/jpeg image/gif text/html text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

    open_file_cache max=100000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;

    #http_proxy 设置

    client_max_body_size 35m;
    client_body_buffer_size 10m;
    proxy_connect_timeout 15;
    proxy_send_timeout 75;
    proxy_read_timeout 15;
    proxy_buffer_size 4096k;
    proxy_buffers 4 4096k;
    proxy_busy_buffers_size 4096k;
    proxy_temp_file_write_size 4096k;
    proxy_temp_path /var/lib/nginx/proxy 1 2;
    
}" > /etc/nginx/nginx.conf
echo "restart ngixn……"
ps -aux|grep nginx |grep -v grep |cut -c 9-15 |xargs kill -9
sleep 3
systemctl start nginx
