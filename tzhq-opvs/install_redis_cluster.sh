#!/bin/bash

function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(date +%s%N)
    echo $(($num%$max+$min))
}

function node_star() {
	config_file="nodes-"$1".conf"
	cluster_config_file="cluster_nodes-"$1".conf"
	DIR_DATA_PATH=/data/Redis-Data/$HOSTNAME
	mkdir $DIR_DATA_PATH
	new_reids_conf_file=$DIR_DATA_PATH/$config_file
	cp /etc/redis.conf $new_reids_conf_file

	yum install epel-release -y
	rpm -ivh http://rpms.remirepo.net/enterprise/8/remi/x86_64/remi-release-8.1-1.el8.remi.noarch.rpm
	yum --enablerepo=remi install redis -y
	
	sed -i 's/port 6379/port '$1'/g' $new_reids_conf_file
	sed -i 's/pidfile \/var\/run\/redis_6379.pid/pidfile \/var\/run\/redis_'$1'.pid/g' $new_reids_conf_file 
	sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' $new_reids_conf_file
	sed -i 's/# requirepass foobared/requirepass J-k.Service~/g' $new_reids_conf_file
	sed -i 's/daemonize no/daemonize yes/g' $new_reids_conf_file
	sed -i 's/databases 16/databases 60/g' $new_reids_conf_file
	sed -i 's/appendonly no/appendonly yes/g' $new_reids_conf_file
	sed -i 's/# cluster-enabled yes/cluster-enabled yes/g' $new_reids_conf_file
	sed -i 's/# masterauth <master-password>/masterauth J-k.Service~/g' $new_reids_conf_file
	sed -i 's/dir \/var\/lib\/redis/# dir \/var\/lib\/redis/g' $new_reids_conf_file
	sed  '264 adir '$DIR_DATA_PATH -i $new_reids_conf_file
	sed -i 's/# cluster-config-file nodes-6379.conf/cluster-config-file '$cluster_config_file'/g' $new_reids_conf_file
	#redis-server $new_reids_conf_file
}

for((i=1;i<3;i++));  
do   
	if [ i = 1 ];then
	    node_star 6379
    else
	    node_star 6380
	fi
done  

#if [ $HOSTNAME="middleware-cluster-node001" ];then
#	redis-cli --cluster create 192.168.163.132:6379 192.168.163.132:6380 192.168.163.132:6381 192.168.163.132:6382 192.168.163.132:6383 192.168.163.132:6384 --cluster-replicas 1 #主从一起配
#	redis-cli --cluster create 172.24.41.67:6379  172.24.41.60:6379  172.24.41.58:6379  --cluster-replicas 1 -a J-k.Service~ #创建集群主节点
#	主从节点交叉配置避免主备己点同时阵亡，造成宕机，程序中配置可以使用redis两套服务端IP连接池（“172.24.41.67:6379  172.24.41.60:6379  172.24.41.58:6380”，“172.24.41.67:6380  172.24.41.60:6380  172.24.41.58:6380”）机器充裕可配置6台主机6379端口
#	redis-cli --cluster add-node 172.24.41.60:6380 172.24.41.67:6379 --cluster-slave --cluster-master-id xxxxxxxxxxxxxxxxxxx  #添加集群指定主节点的 从节点 add-node 后的第一个参数为要添加的节点，第二参数为已经存在的主节点 cluster-naster-id的参数为第二参数节点生成的集群id（主集群创建成功后登入redis使用cluster nodes指令查询）
#	redis-cli --cluster add-node 172.24.41.58:6380 172.24.41.60:6379	
#	redis-cli --cluster add-node 172.24.41.67:6380 172.24.41.58:6379
#else
#    echo "没找到redis-cluster-1主机，未执行集群初始化，请手工执行：redis-cli create --replicas 1 10.15.208.128:6379 10.15.208.128:6380 10.15.208.129:6379 10.15.208.129:6380 10.15.208.130:6379 10.15.208.130:6380 --cluster-replicas 1 -a J-k.Service~ "
#fi

