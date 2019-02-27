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

echo " install docker "
yum install docker -y
#Add docker service to boot...
systemctl enable docker
echo "Open docker service...!"
systemctl start docker
echo "Stop all running containers……"
docker stop $(docker ps -a -q)
echo "rm all containers……"
docker rm $(docker ps -a -q)
echo |docker ps -a -q
echo "--------------------Delete all existing images----------------------"
docker rmi $(docker images -a -q)
echo |docker images -a
echo "-------------------------Image clear--------------------------------"
echo "docker hub Pull the mirror"
docker pull mongo:4.0
docker pull redis
docker pull mysql:5.7
echo "
|
|
"
echo "-------------------------Image pull is done-------------------------"
echo "
|
|
"
echo " Run MySQL mirror to container and rename."
docker run -dit --name mysql_5 -e MYSQL_ROOT_PASSWORD="#F!89aPc#d5+7u" -p 0.0.0.0:3306:3306  mysql:5.7
touch /etc/yum.repos.d/mysql-community.repo
echo "
# Enable to use MySQL 5.7
[mysql57-community] 
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/\$basearch/
enabled=0   
gpgcheck=1 
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
" > /etc/yum.repos.d/mysql-community.repo
yum install mysql-community-client -y
echo "MySQL installation and startup complete!......"
echo "
"
echo "____________________________________________________________________________________________________________"
echo "                                                #mongodb "
echo "____________________________________________________________________________________________________________"

mkdir /mongodb_backup
echo "run mongodb"
docker run -dit --name=mongo -e MONGO_INITDB_ROOT_USERNAME=root -e MONGO_INITDB_ROOT_PASSWORD="9aP)(cd5+" -p0.0.0.0:27017:27017 -v /mongodb_backup:/root mongo:4.0
#download mongodb client
touch /etc/yum.repos.d/mongodb-org-4.0.repo
echo "
[mongodb-org-4.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc
" > /etc/yum.repos.d/mongodb-org-4.0.repo
yum install mongodb-org-shell mongodb-org-tools -y
echo "Mongodb installation and startup complete!......"

#____________________________________________________________________________________________________________
#The self-built redis image is mainly to add redis configuration file. The configuration file is modified to 
#bind the IP address to 0.0.0.0 and add connection authentication.
#_____________________________________________________________________________________________________________

cd ~/

echo " Create new dockerfile "
touch redis_dockerfile
#Create a new redis configuration file
echo "Create dockerfile context"
echo "
FROM redis
COPY redis.conf /usr/local/etc/redis/redis.conf
CMD [ \"redis-server\", \"/usr/local/etc/redis/redis.conf\" ]
" > redis_dockerfile

touch redis.conf
#Insert configuration content into the configuration file
echo "
bind 0.0.0.0
protected-mode yes
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize no
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile redis.log
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /data/
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
replica-priority 100
#Connection authentication password
requirepass  \"9aP)(cd5+\"
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
appendonly yes
appendfilename 'appendonly.aof'
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
" > redis.conf
#redis 警告优化
sysctl -w net.core.somaxconn=32768
sysctl -w vm.overcommit_memory=1
sysctl -p
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo "System kernel optimization complete!......"

echo "Compile the mirror"
docker build -f redis_dockerfile -t redis_addconf:1.0 .
echo "Reids image compilation complete!......"
echo | docker images
docker run -dit --name redis -p 0.0.0.0:6379:6379  redis_addconf:1.0
 echo "Reids startup complete!......"
# install epel repository, download redis-cli
yum install epel-release -y
# Linux does not have a separate redis-cli installation package, 
#so directly install the full version, the subsequent direct 
#deletion of redis-server files, when the client use alone
yum install redis -y
#Installation default installation location: /usr/bin/redis-server
 rm -f /usr/bin/redis-server
echo "running container"
echo |docker ps
echo "--------------------------------------------------------------"
echo |docker ps -a
 echo "All data services deployed!............"
