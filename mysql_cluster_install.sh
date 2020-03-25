#wget https://dev.mysql.com/get/mysql80-community-release-el8-1.noarch.rpm
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.0/mysql-cluster-community-8.0.19-1.el8.x86_64.rpm-bundle.tar
tar xvf mysql-cluster-community-8.0.19-1.el8.x86_64.rpm-bundle.tar

if [ -f 'mysql80-community-release-el8-1.noarch.rpm' ];then
	if [ $HOSTNAME = "Mysql-Database-manager" ];then
		echo $HOSTNAME
		yum remove yum remove mariadb-connector-c-config -y
		yum install perl perl-DBI perl-Class-MethodMaker perl-JSON python2 -y
		rpm -Uvh mysql-cluster-community-client-8.0.19-1.el8.x86_64.rpm mysql-cluster-community-common-8.0.19-1.el8.x86_64.rpm mysql-cluster-community-libs-8.0.19-1.el8.x86_64.rpm \
		mysql-cluster-community-management-server-8.0.19-1.el8.x86_64.rpm mysql-cluster-community-ndbclient-8.0.19-1.el8.x86_64.rpm 
		mkdir /data/Mysql-Cluster-Data
		mkdir /data/Mysql-Cluster-Data/NDB-DATA-NODE1
		mkdir /data/Mysql-Cluster-Data/NDB-DATA-NODE2
		mkdir /data/Mysql-Cluster-Data/NDB-DATA-NODE3
		mkdir /data/Mysql-Cluster-Data/NDB-DATA-NODE4
		ndb_data_path=/data/Mysql-Cluster-Data/$HOSTNAME
		mkdir $ndb_data_path
		touch $ndb_data_path/config.ini
		cat > $ndb_data_path/config.ini <<EOF
[NDB_MGMD DEFAULT]
LogDestination=FILE:filename=mycluster.log,maxsize=500000,maxfiles=4
[ndbd default]
NoOfReplicas=4
DataMemory=38G
IndexMemory=19G 
DataDir=$ndb_data_path
BackupDataDir=$ndb_data_path/BACKUP
LockPagesInMainMemory=1

TimeBetweenLocalCheckpoints=20
TimeBetweenGlobalCheckpoints=1000
TimeBetweenEpochs=100
TimeBetweenWatchdogCheckInitial=60000

#StringMemory=20
MaxNoOfTables=1024
MaxNoOfOrderedIndexes=2048
MaxNoOfUniqueHashIndexes=512
MaxNoOfAttributes=20480
MaxNoOfTriggers=10240

FragmentLogFileSize=256M
NoOfFragmentLogFiles=16
RedoBuffer=64M

MaxNoOfConcurrentOperations=500000

TransactionInactiveTimeout=50000

MaxNoOfExecutionThreads=8

BatchSizePerLocalScan=512

### 磁盘存储
SharedGlobalMemory=20M
DiskPageBufferMemory=80M

#### Data Nodes
# Node group #1
[NDBD]
NodeId=1
DataDir=/data/Mysql-Cluster-Data/NDB-DATA-NODE1
HostName=172.24.41.50
[NDBD]
NodeId=2
HostName=172.24.41.55
DataDir=/data/Mysql-Cluster-Data/NDB-DATA-NODE2
[NDBD]
NodeId=3
HostName=172.24.41.51
DataDir=/data/Mysql-Cluster-Data/NDB-DATA-NODE3
[NDBD]
NodeId=4
HostName=172.24.41.56
DataDir=/data/Mysql-Cluster-Data/NDB-DATA-NODE4

[ndb_mgmd]
Hostname=172.24.41.54

[mysqld]
HostName=172.24.41.53
[mysqld]
HostName=172.24.41.52
[mysqld]
HostName=172.24.41.56
EOF
          
		ndb_mgmd -f $ndb_data_path/config.ini --initial
	fi

elif [ $`$HOSTNAME | grep "^Mysql-Database-NDB-"` = $HOSTNAME ];then
		echo $HOSTNAME
		rpm -Uvh mysql-cluster-community-data-node-8.0.19-1.el8.x86_64.rpm
		mkdir /data/Mysql-Cluster-Data/ 
		data_path=/data/Mysql-Cluster-Data/$HOSTNAME/
		mv /etc/my.cnf /etc/my.cnf.bak
		touch /etc/my.cnf
		cat > /etc/my.cnf << EOF
[mysqld]
ndbcluster
ndb-connectstring=172.24.41.54:1186
[MYSQL_CLUSTER]
ndb-connectstring=172.24.41.54:1186     #管理节点
EOF
	ndbd --initial
elif [ `echo $HOSTNAME |grep "^Mysql-Database-sqlnode-"` = $HOSTNAME ];then
		echo $HOSTNAME
		yum remove yum remove mariadb-connector-c-config -y
		yum install perl perl-DBI perl-Class-MethodMaker perl-JSON python2 -y
		rpm -Uvh mysql-cluster-community-server-8.0.19-1.el8.x86_64.rpm mysql-cluster-community-client-8.0.19-1.el8.x86_64.rpm mysql-cluster-community-common-8.0.19-1.el8.x86_64.rpm mysql-cluster-community-libs-8.0.19-1.el8.x86_64.rpm
		mkdir /data/Mysql-Cluster-Data/ 
		data_path=/data/Mysql-Cluster-Data/$HOSTNAME/
		mkdir $data_path
		mv /etc/my.cnf /etc/my.cnf.bak
		cat > /etc/my.cnf << EOF
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/8.0/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove the leading "# " to disable binary logging
# Binary logging captures changes between backups and is enabled by
# default. It's default setting is log_bin=binlog
# disable_log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
#
# Remove leading # to revert to previous value for default_authentication_plugin,
# this will increase compatibility with older clients. For background, see:
# https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin
# default-authentication-plugin=mysql_native_password

datadir=$data_path
socket=/var/lib/mysql/mysql.sock

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
skip-external-locking
key_buffer_size = 16K
max_allowed_packet = 1024M
table_open_cache = 128
sort_buffer_size = 64K
read_buffer_size = 256K
read_rnd_buffer_size = 256K
net_buffer_length = 2K
thread_stack = 192K
# Query cache disabled
thread_cache_size = 8
max_connections = 16000
tmp_table_size = 128M
max_heap_table_size = 128M
lower_case_table_names=1
#lower_case_file_system=ON
log-error=/var/log/mysqld.log
pid-file=/var/lib/mysql/mysqld.pid

ndbcluster
ndb-connectstring=172.24.41.54:1186
[MYSQL_CLUSTER]
ndb-connectstring=172.24.41.54:1186     #管理节点
EOF
		mysqld --initialize
		
		yum -y install gcc gcc+ gcc-c++ popt-devel openssl openssl-devel libssl-dev libnl-devel
		yum -y install kernel kernel-devel
		#ln -s /usr/src/kerners/2.6....../ /usr/src/linux
		yum -y install keepalived ipvsadm popt-static

	   #虚拟的vip 根据自己的实际情况定义
	   SNS_VIP=172.24.33.60
#	   /etc/rc.d/init.d/functions
#       ifconfig lo:0 $SNS_VIP netmask 255.255.255.255 broadcast $SNS_VIP
#       /sbin/route add -host $SNS_VIP dev lo:0
#       echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
#       echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
#       echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
#       echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
#       sysctl -p >/dev/null 2>&1
#       echo "RealServer Start OK"
	   keepa_path=/etc/keepalived/keepalived.conf
       mv $keepa_path $keepa_path.bak
       touch $keepa_path
       cat > $keepa_path << EOF
! Configuration File for keepalived

global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   #smtp_server 192.168.200.1
   #smtp_connect_timeout 30
   router_id LVS_DEVEL
   vrrp_garp_interval 0
   vrrp_gna_interval 0
   vrrp_mcast_group4 244.0.0.0
}

vrrp_instance VI_1 {
    state MASTER
    interface ens33
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass ag3ds#fa-23
    }
    virtual_ipaddress {
        $SNS_VIP
    }
}
virtual_server $SNS_VIP 3306 {
    delay_loop 6
    lb_algo rr  
    lb_kind NAT 
    persistence_timeout 50
    protocol TCP 
}
EOF
		systemctl start keepalived
else
	echo ""
fi
