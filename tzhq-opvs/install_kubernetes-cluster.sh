#!/bin/sh

system_init(){
	platform=`uname -i`
	if [ $platform != "x86_64" ];then
	echo "this script is only for 64bit Operating System !"
	exit 1
	fi
	echo "the platform is ok"
	cat << EOF
+---------------------------------------+
|   your system is CentOS 8 x86_64      |
|      start optimizing.......          |
+---------------------------------------
EOF



	yum clean all
	yum makecache

	# update os or soft
	yum update -y

	# man chinese pages
	yum install man-pages-zh-CN.noarch  -y
	# Conventional tools
	yum install ntp wget curl git tcpdump net-tools -y
	yum install vim lrzsz zip unzip -y
	#install jdk-1.8.0-openjdk

	timedatectl set-timezone Asia/Shanghai
	/usr/sbin/ntpdate cn.pool.ntp.org
	echo "* 4 * * * /usr/sbin/ntpdate cn.pool.ntp.org > /dev/null 2>&1" >> /var/spool/cron/root
	systemctl enable crond.service
	systemctl restart crond.service

	#yum install java-1.8.0-openjdk* -y
	#wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
	yum install epel-release -y

	echo "ulimit -SHn 102400" >> /etc/rc.local
	cat >> /etc/security/limits.conf << EOF
*           soft   nofile       655350
*           hard   nofile       655350
EOF


	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
	setenforce 0
	# Ban ping
	#echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all

	# vim optimization
	echo 'alias vi=vim' >> /etc/profile
	#echo 'stty erase ^H' >> /etc/profile
	cat >> /root/.vimrc << EOF
set tabstop=4
set shiftwidth=4
set expandtab
set helplang=cn
set encoding=utf-8
set fileencodings=ucs-bomo,utf-8,chinese,gbk,latin-1
set ffs=unix,dos,mac
set backspace=indent,eol,start
set whichwrap=b,s,<,>,[,]
set number
EOF


# kernel optimization
	cat >> /etc/sysctl.conf << EOF
#CTCDN系统优化参数
#关闭ipv6
#net.ipv6.conf.all.disable_ipv6 = 1
#net.ipv6.conf.default.disable_ipv6 = 1
#决定检查过期多久邻居条目
net.ipv4.neigh.default.gc_stale_time=120
#使用arp_announce / arp_ignore解决ARP映射问题
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce=2
net.ipv4.conf.lo.arp_announce=2
# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1
# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1
#开启路由转发
net.ipv4.ip_forward = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
#开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
#处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
#关闭sysrq功能
kernel.sysrq = 0
#core文件名中添加pid作为扩展名
kernel.core_uses_pid = 1
# 开启SYN洪水攻击保护
net.ipv4.tcp_syncookies = 1
#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536
#设置最大内存共享段大小bytes
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
#timewait的数量，默认180000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
#每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
#net.core.netdev_max_backlog = 262144
#限制仅仅是为了防止简单的DoS 攻击
net.ipv4.tcp_max_orphans = 3276800
#未收到客户端确认信息的连接请求的最大值
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
#内核放弃建立连接之前发送SYNACK 包的数量
net.ipv4.tcp_synack_retries = 1
#内核放弃建立连接之前发送SYN 包的数量
net.ipv4.tcp_syn_retries = 1
#启用timewait 快速回收
net.ipv4.tcp_tw_recycle = 1
#开启重用。允许将TIME-WAIT sockets 重新用于新的TCP 连接
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
#当keepalive 起用的时候，TCP 发送keepalive 消息的频度。缺省是2 小时
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 15
#允许系统打开的端口范围
#net.ipv4.ip_local_port_range = 1024    65000
#修改防火墙表大小，默认65536
#net.netfilter.nf_conntrack_max=655350
#net.netfilter.nf_conntrack_tcp_timeout_established=1200
# 确保无人能修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
#优化redis启动警告
vm.overcommit_memory = 1
net.core.somaxconn=32768
EOF
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
	sysctl -p


	# After landing display information
	echo "The current container environment is the online production environment of Tiqi Technology Co., Ltd. (Jinke property group).\n
Please operate carefully." > /etc/motd

	# Ban Ctrl+Alt+Del

	mv /usr/lib/systemd/system/ctrl-alt-del.target /usr/lib/systemd/system/ctrl-alt-del.target.bakup
	init q
}

swapif(){
        swap=`grep swap /etc/fstab`
        if [[ ${swap:0:1} = "#" ]];then
                echo "swap offed"
        else
                swap_value=`grep swap /etc/fstab`
                sed -i '/swap/s/^/#&/' /etc/fstab
				system_init
                reboot
        fi
	
	yum install yum-utils device-mapper-persistent-data lvm2 -y

	#yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo centos 7
	dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo #centos 8
	yum-config-manager --enable docker-ce-nightly
	yum install docker-ce docker-ce-cli containerd.io --nobest -y
	systemctl enable docker
	systemctl start docker
	cat >> /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://registry.tiqiyun.com/"],
  "exec-opts": ["native.cgroupdriver=cgroupfs"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },  
  "storage-driver": "overlay2",
  "graph": "/data/docker",
  "live-restore": true,
  "default-shm-size": "128M",
  "bridge": "none",
  "max-concurrent-downloads": 10, 
  "oom-score-adjust": -1000,
  "debug": false
}
EOF
	systemctl daemon-reload
	systemctl restart docker

	touch /etc/sysctl.d/k8s.conf
	cat >> /etc/sysctl.d/k8s.conf <<EOF 
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF

	sysctl --system

	
	cat >> /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF
	yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
	systemctl enable kubelet
	#systemctl restart kubelet
	cat >>  /etc/sysctl.d/kube.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
	sysctl --system
	docker pull bluersw/metrics-server-amd64:v0.3.6
	docker tag bluersw/metrics-server-amd64:v0.3.6 k8s.gcr.io/metrics-server-amd64:v0.3.6
}

kuber_init(){
	cd /etc/kubernetes/pki/
	rm -fr apiserver.crt apiserver.key
	if [ `echo $HOSTNAME` = "Kubernetes-Master001" ];then
		mkdir -pv /etc/kubernetes/pki/etcd/
		\cp -arf /etc/etcd/ssl/* /etc/kubernetes/pki/etcd/
	fi
	cd $HOME
#kubeadm config print init-defaults > kubernetet-init.yaml
	cat << EOF > /root/kubeadm-init.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.17.0
controlPlaneEndpoint: 172.24.41.63:6443   #VIP地址
apiServer:
  certSANs:
  - Kubernetes-Master001
  - Kubernetes-Master002
  - Kubernetes-Master003
  - Kubernetes-Node001
  - Kubernetes-Node002
  - Kubernetes-Node003
  - proxy-node001           	#此处填所有的masterip和lbip和其它你可能需要通过它访问apiserver的地址和域名或者主机名等
  - 172.24.41.68
  - 172.24.41.57
  - 172.24.41.61
  - 172.24.41.65
  - 172.24.41.66
  - 172.24.41.59
  - 172.24.41.63
certificatesDir: /etc/kubernetes/pki
controllerManager: {}
etcd:    #ETCD的地址
  external:
    endpoints:
    - "https://172.24.41.68:2379"
    - "https://172.24.41.57:2379"
    - "https://172.24.41.61:2379"
    caFile: /etc/kubernetes/pki/etcd/etcd-ca.pem
    certFile: /etc/kubernetes/pki/etcd/etcd.pem
    keyFile: /etc/kubernetes/pki/etcd/etcd-key.pem
networking:
  serviceSubnet: 10.96.0.0/12
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers  # image的仓库源
EOF


	systemctl enable kubelet
	kubeadm config images pull --config kubeadm-init.yaml
	docker tag  registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1  k8s.gcr.io/pause:3.1
	kubeadm init --config /root/kubeadm-init.yaml

	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config
	echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/profile
	source /etc/profile
#	cat << EOF > /etc/profile.d/kubernetes.sh
#`source <(kubectl completion bash)`
#EOF
#	source /etc/profile.d/kubernetes.sh 
	if [ `echo $HOSTNAME` = "Kubernetes-Master001" ];then
		scp -r /etc/kubernetes/pki 172.24.41.57:/etc/kubernetes/
		scp -r /etc/kubernetes/pki 172.24.41.61:/etc/kubernetes/
	fi
}

calico_net(){
	wget https://docs.projectcalico.org/v3.8/manifests/calico.yaml
	sed -i 's/192.168.0.0\/16/10.96.0.0\/12/g' calico.yaml
	kubectl apply -f calico.yaml
}

dashbord(){
	touch recommended.yaml
	cat >> recommended.yaml <<EOF
# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

apiVersion: v1
kind: Namespace
metadata:
  name: kubernetes-dashboard

---

apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard

---

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30000
  selector:
    k8s-app: kubernetes-dashboard

---

#apiVersion: v1
#kind: Secret
#metadata:
#  labels:
#    k8s-app: kubernetes-dashboard
#  name: kubernetes-dashboard-certs
#  namespace: kubernetes-dashboard
#type: Opaque

---

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-csrf
  namespace: kubernetes-dashboard
type: Opaque
data:
  csrf: ""

---

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-key-holder
  namespace: kubernetes-dashboard
type: Opaque

---

kind: ConfigMap
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-settings
  namespace: kubernetes-dashboard

---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
rules:
  # Allow Dashboard to get, update and delete Dashboard exclusive secrets.
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs", "kubernetes-dashboard-csrf"]
    verbs: ["get", "update", "delete"]
    # Allow Dashboard to get and update 'kubernetes-dashboard-settings' config map.
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["kubernetes-dashboard-settings"]
    verbs: ["get", "update"]
    # Allow Dashboard to get metrics.
  - apiGroups: [""]
    resources: ["services"]
    resourceNames: ["heapster", "dashboard-metrics-scraper"]
    verbs: ["proxy"]
  - apiGroups: [""]
    resources: ["services/proxy"]
    resourceNames: ["heapster", "http:heapster:", "https:heapster:", "dashboard-metrics-scraper", "http:dashboard-metrics-scraper"]
    verbs: ["get"]

---

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
rules:
  # Allow Metrics Scraper to get metrics from the Metrics server
  - apiGroups: ["metrics.k8s.io"]
    resources: ["pods", "nodes"]
    verbs: ["get", "list", "watch"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kubernetes-dashboard
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kubernetes-dashboard
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard

---

kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: kubernetes-dashboard
  template:
    metadata:
      labels:
        k8s-app: kubernetes-dashboard
    spec:
      containers:
        - name: kubernetes-dashboard
          image: kubernetesui/dashboard:v2.0.0-beta8
          imagePullPolicy: Always
          ports:
            - containerPort: 8443
              protocol: TCP
          args:
            - --auto-generate-certificates
            - --namespace=kubernetes-dashboard
            # Uncomment the following line to manually specify Kubernetes API server Host
            # If not specified, Dashboard will attempt to auto discover the API server and connect
            # to it. Uncomment only if the default does not work.
            # - --apiserver-host=http://my-address:port
          volumeMounts:
            - name: kubernetes-dashboard-certs
              mountPath: /certs
              # Create on-disk volume to store exec logs
            - mountPath: /tmp
              name: tmp-volume
          livenessProbe:
            httpGet:
              scheme: HTTPS
              path: /
              port: 8443
            initialDelaySeconds: 30
            timeoutSeconds: 30
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            runAsUser: 1001
            runAsGroup: 2001
      volumes:
        - name: kubernetes-dashboard-certs
          secret:
            secretName: kubernetes-dashboard-certs
        - name: tmp-volume
          emptyDir: {}
      serviceAccountName: kubernetes-dashboard
      nodeSelector:
        "beta.kubernetes.io/os": linux
      # Comment the following tolerations if Dashboard must not be deployed on master
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule

---

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: dashboard-metrics-scraper
  name: dashboard-metrics-scraper
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 8000
      targetPort: 8000
  selector:
    k8s-app: dashboard-metrics-scraper

---

kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    k8s-app: dashboard-metrics-scraper
  name: dashboard-metrics-scraper
  namespace: kubernetes-dashboard
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: dashboard-metrics-scraper
  template:
    metadata:
      labels:
        k8s-app: dashboard-metrics-scraper
      annotations:
        seccomp.security.alpha.kubernetes.io/pod: 'runtime/default'
    spec:
      containers:
        - name: dashboard-metrics-scraper
          image: kubernetesui/metrics-scraper:v1.0.1
          ports:
            - containerPort: 8000
              protocol: TCP
          livenessProbe:
            httpGet:
              scheme: HTTP
              path: /
              port: 8000
            initialDelaySeconds: 30
            timeoutSeconds: 30
          volumeMounts:
          - mountPath: /tmp
            name: tmp-volume
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            runAsUser: 1001
            runAsGroup: 2001
      serviceAccountName: kubernetes-dashboard
      nodeSelector:
        "beta.kubernetes.io/os": linux
      # Comment the following tolerations if Dashboard must not be deployed on master
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule
      volumes:
        - name: tmp-volume
          emptyDir: {}
EOF
	kubectl create namespace kubernetes-dashboard
	openssl genrsa -out dashboard.key 2048
	openssl req -days 36000   -new -out dashboard.csr    -key dashboard.key   -subj '/CN=**172.24.41.68**'
	openssl x509 -req -in dashboard.csr -signkey dashboard.key -out dashboard.crt
	kubectl create secret generic kubernetes-dashboard-certs --from-file=dashboard.key --from-file=dashboard.crt -n kubernetes-dashboard
	docker pull kubernetesui/dashboard:v2.0.0-beta8
	mkdir /certs
	kubectl apply -f recommended.yaml
	kubectl get pods --all-namespaces
	kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep dashboard-admin | awk '{print $1}')
}

metrics_server(){
	if [ ! -f /root/metrics-server ];then
		yum install git -y
		git clone https://github.com/kubernetes-sigs/metrics-server.git
	fi
	mv metrics-server/deploy/kubernetes/metrics-server-deployment.yaml metrics-server/deploy/kubernetes/metrics-server-deployment.yaml.bak
	touch metrics-server/deploy/kubernetes/metrics-server-deployment.yaml
	cat >> metrics-server/deploy/kubernetes/metrics-server-deployment.yaml <<EOF
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-server
  namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    k8s-app: metrics-server
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  template:
    metadata:
      name: metrics-server
      labels:
        k8s-app: metrics-server
    spec:
      serviceAccountName: metrics-server
      volumes:
      # mount in tmp so we can safely use from-scratch images and/or read-only containers
      - name: tmp-dir
        emptyDir: {}
      containers:
      - name: metrics-server
        image: k8s.gcr.io/metrics-server-amd64:v0.3.6
        args:
          - --cert-dir=/tmp
          - --secure-port=4443
        ports:
        - name: main-port
          containerPort: 4443
          protocol: TCP 
        securityContext:
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        imagePullPolicy: IfNotPresent
        command:
          - /metrics-server
          - --kubelet-preferred-address-types=InternalIP
          - --kubelet-insecure-tls
        volumeMounts:
        - name: tmp-dir
          mountPath: /tmp
      nodeSelector:
        beta.kubernetes.io/os: linux
EOF
		kubectl create -f metrics-server/deploy/kubernetes/
}

haproxy(){
	yum install  -y haproxy
	mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
	touch /etc/haproxy/haproxy.cfg
	cat << EOF > /etc/haproxy/haproxy.cfg
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

defaults
    mode                    tcp
    log                     global
    retries                 3
    timeout connect         10s
    timeout client          1m
    timeout server          1m

frontend kubernetes
    bind *:6443
    mode tcp
    default_backend kubernetes-master

backend kubernetes-master
    balance roundrobin
    server master  172.24.41.68:6443 check maxconn 2000
    server master2 172.24.41.57:6443 check maxconn 2000
    server master3 172.24.41.61:6443 check maxconn 2000
EOF

	systemctl enable haproxy
	systemctl start haproxy
}

get_join_key(){
	join_key=`kubeadm token create --print-join-command`
	echo $join_key
}

main(){
	if [[ $HOSTNAME =~ ^Kubernetes-Master00* ]];then
		if [ $HOSTNAME = "Kubernetes-Master001" ];then
			kuber_init
			calico_net
			dashbord
			metrics_server
			get_join_key
		else
			while :
			do
				if [ -f /etc/kubernetes/pki/apiserver.key ]||[ -f /etc/kubernetes/pki/apiserver-kubelet-client.key ];then
				    sleep 30
					scp 172.24.41.68:/etc/kubernetes/admin.conf /etc/kubernetes/
					echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/profile
					source /etc/profile
					echo "to Manange1 exec ”kubeadm token create --print-join-command“ get join key，if master， the jion key back add ”--control-plane“  "
					break
				fi
			done
		fi
	elif [ $HOSTNAME = "kubernetes-node-2" ];then
		haproxy
	else
		echo ""
	fi
}
main