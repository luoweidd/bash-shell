#!/bin/bash

#该版本为ceph集群15.2.17稳定版，如考虑源问题可更换为国内相对较低版本源进行更换。集群安装使用了官方
#ceph-deploy工具进行部署。
#预先配置好主机名，并完成主机免密ssh配置(推荐使用root账号，如使用其它账号记得在相关命令前加上sudo，
#且保证相关账号有sudo权限)。如不是用实例内命名方式请修改本叫本中多处主机名。

#实例：(/etc/hosts)
#192.168.207.128 ceph-02
#192.168.207.129 ceph-01
#192.168.207.130 ceph-03
#192.168.207.131 ceph-m


cluster_res=''
ERR_INF='RADOS object not found (error connecting to the cluster)'

#依赖安装
apt install gnupg -y

#添加release key
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -

#添加官方源
echo deb http://download.ceph.com/debian-15.2.17/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list

#该安装是因考虑国内源与官方源冲突部分单独安装
wget https://download.ceph.com/debian-15.2.7/pool/main/c/ceph/radosgw_15.2.7-1~bpo10%2B1_amd64.deb


apt-get update && apt install ceph -y
dpkg -i radosgw_15.2.7-1~bpo10+1_amd64.deb

#因使用了ceph-deploy部署工具，monitor节点、mgr节点、osd节点（默认3守护）、mds部署军在主节点主机是实施部署，
#具体管理和监控节点固定部署落地到主节点ceph-m主机，其osd节点服务则在所有节点主机安装，其mds节点则只在数据节点安装即可！

if [ $HOSTNAME == 'ceph-m' ];then

	#安装部署工具ceph-deploy
	apt-get update  && apt-get install ceph-deploy -y
	#创建集群
	mkdir ceph_cluster
	cd ceph_cluster
	ceph-deploy new ceph-m
	#添加主机节点
	ceph-deploy install ceph-m ceph-01 ceph-02 ceph-03
	#创建监控
	ceph-deploy mon create ceph-m
	#收集节点的keyring
	ceph-deploy  gatherkeys ceph-m
	$cluster_res = `ceph -s`
	if [ $cluster_res == ~$ERR_INF ];then
		chmod +r /etc/ceph/ceph.client.admin.keyring
	fi
	ceph -s
fi
cat << EOF 'ceph cluster service installation is completed. Please manually configure the specific configuration. 
Now OSD is left and MDS is not configured.'

The corresponding operations are as follows:
    OSD:
       1. Prepare the disk and format it as ext4. Do not use partition, unless it is not applicable to full disk,
          but partition or directory (not recommended, affecting disk IO).
       2. Create OSD. Example: ceph-deploy osd create {host name} -- data {disk path such as /dev/sdn or 
          directory path such as /root/data or partition path such as /dev/sdb1 or /dev/sda3}.
       3. Activate OSD: Example: ceph-deploy osd create { hostname: {disk path such as /dev/sdn or 
          directory path such as /root/data or partition path such as /dev/sdb1 or /dev/sda3} }.
       4. Check OSD: Example: ceph-deploy osd list { hostname }
    MDS:
	1. Create MDS: Example: ceph-deploy mds create { hostname }.
	2. Check MDS: Example: ceph mds stat

Check monitor status: Example: ceph mon stat
EOF
