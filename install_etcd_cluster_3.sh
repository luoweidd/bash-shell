gen_ca(){
if [ `echo $HOSTNAME` = "Kubernetes-Master001" ];then
	if [ ! -f /bin/cfssl ];then
		wget -O /bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
	fi
	if [ ! -f /bin/cfssl ];then
		wget -O /bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
	fi
	if [ ! -f /bin/cfssl ];then
		wget -O /bin/cfssl-certinfo  https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
	fi
	for cfssl in `ls /bin/cfssl*`;do chmod +x $cfssl;done;
	mkdir -pv $HOME/ssl && cd $HOME/ssl

	cat > ca-config.json << EOF
{
	"signing": {
		"default": {
			"expiry": "87600h"
		},
		"profiles": {
			"kubernetes": {
				"usages": [
					"signing",
					"key encipherment",
					"server auth",
					"client auth"
				],
			"expiry": "87600h"
			}
		}
	}
}
EOF


	cat > etcd-ca-csr.json << EOF
{
	"CN": "etcd",
	"key": {
		"algo": "rsa",
		"size": 2048
	},
	"names": [
		{
		"C": "CN",
		"ST": "Chengdu",
		"L": "Chendu",
		"O": "etcd",
		"OU": "Etcd Security"
		}
	]
}
EOF


	cat > etcd-csr.json << EOF
{
	"CN": "etcd",
	"hosts": [
		"127.0.0.1",
		"172.24.41.61",
		"172.24.41.57",
		"172.24.41.68"
	],
	"key": {
		"algo": "rsa",
		"size": 2048
	},
	"names": [
		{
			"C": "CN",
			"ST": "Shenzhen",
			"L": "Shenzhen",
			"O": "etcd",
			"OU": "Etcd Security"
		}
	]
}
EOF

#生成证书并复制证书至其他etcd节点

	cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare etcd-ca
	cfssl gencert -ca=etcd-ca.pem -ca-key=etcd-ca-key.pem -config=ca-config.json -profile=kubernetes etcd-csr.json | cfssljson -bare etcd

	mkdir -pv /etc/etcd/ssl
	mkdir -pv /etc/kubernetes/pki/etcd
	cp etcd*.pem /etc/etcd/ssl
	cp etcd*.pem /etc/kubernetes/pki/etcd

#	scp -r /etc/etcd 188.188.188.182:/etc/		
	scp -r /etc/etcd 172.24.41.57:/etc/
	scp -r /etc/etcd 172.24.41.61:/etc/
fi
}

etcd_install(){
	yum install -y etcd 
	mv /etc/etcd/etcd.conf /etc/etcd/etcd.conf.bak
	touch /etc/etcd/etcd.conf
	cat >>/etc/etcd/etcd.conf<<EOF
#[Member]
#ETCD_CORS=""
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
#ETCD_WAL_DIR=""
ETCD_LISTEN_PEER_URLS="https://172.24.41.68:2380"
ETCD_LISTEN_CLIENT_URLS="https://127.0.0.1:2379,https://172.24.41.68:2379"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
ETCD_NAME="etcd1"
#ETCD_SNAPSHOT_COUNT="100000"
#ETCD_HEARTBEAT_INTERVAL="100"
#ETCD_ELECTION_TIMEOUT="1000"
#ETCD_QUOTA_BACKEND_BYTES="0"
#ETCD_MAX_REQUEST_BYTES="1572864"
#ETCD_GRPC_KEEPALIVE_MIN_TIME="5s"
#ETCD_GRPC_KEEPALIVE_INTERVAL="2h0m0s"
#ETCD_GRPC_KEEPALIVE_TIMEOUT="20s"
#
#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://172.24.41.68:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://127.0.0.1:2379,https://172.24.41.68:2379"
#ETCD_DISCOVERY=""
#ETCD_DISCOVERY_FALLBACK="proxy"
#ETCD_DISCOVERY_PROXY=""
#ETCD_DISCOVERY_SRV=""
ETCD_INITIAL_CLUSTER="etcd1=https://172.24.41.68:2380,etcd2=https://172.24.41.57:2380,etcd3=https://172.24.41.61:2380"
ETCD_INITIAL_CLUSTER_TOKEN="BigBoss"
#ETCD_INITIAL_CLUSTER_STATE="new"
#ETCD_STRICT_RECONFIG_CHECK="true"
#ETCD_ENABLE_V2="true"
#
#[Proxy]
#ETCD_PROXY="off"
#ETCD_PROXY_FAILURE_WAIT="5000"
#ETCD_PROXY_REFRESH_INTERVAL="30000"
#ETCD_PROXY_DIAL_TIMEOUT="1000"
#ETCD_PROXY_WRITE_TIMEOUT="5000"
#ETCD_PROXY_READ_TIMEOUT="0"
#
#[Security]
ETCD_CERT_FILE="/etc/etcd/ssl/etcd.pem"
ETCD_KEY_FILE="/etc/etcd/ssl/etcd-key.pem"
#ETCD_CLIENT_CERT_AUTH="false"
ETCD_TRUSTED_CA_FILE="/etc/etcd/ssl/etcd-ca.pem"
#ETCD_AUTO_TLS="false"
ETCD_PEER_CERT_FILE="/etc/etcd/ssl/etcd.pem"
ETCD_PEER_KEY_FILE="/etc/etcd/ssl/etcd-key.pem"
#ETCD_PEER_CLIENT_CERT_AUTH="false"
ETCD_PEER_TRUSTED_CA_FILE="/etc/etcd/ssl/etcd-ca.pem"
#ETCD_PEER_AUTO_TLS="false"
#
#[Logging]
#ETCD_DEBUG="false"
#ETCD_LOG_PACKAGE_LEVELS=""
#ETCD_LOG_OUTPUT="default"
#
#[Unsafe]
#ETCD_FORCE_NEW_CLUSTER="false"
#
#[Version]
#ETCD_VERSION="false"
#ETCD_AUTO_COMPACTION_RETENTION="0"
#
#[Profiling]
#ETCD_ENABLE_PPROF="false"
#ETCD_METRICS="basic"
#
#[Auth]
#ETCD_AUTH_TOKEN="simple"
EOF

	ip_addr=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | awk -F"/" '{print $1}'`
	#echo $ip_addr	
	sed -i 's/ETCD_LISTEN_PEER_URLS="https:\/\/172.24.41.68:2380"/ETCD_LISTEN_PEER_URLS="https:\/\/'$ip_addr':2380"/g' /etc/etcd/etcd.conf
	sed -i 's/ETCD_LISTEN_CLIENT_URLS="https:\/\/127.0.0.1:2379,https:\/\/172.24.41.68:2379"/ETCD_LISTEN_CLIENT_URLS="https:\/\/127.0.0.1:2379,https:\/\/'$ip_addr':2379"/g' /etc/etcd/etcd.conf
	sed -i 's/ETCD_INITIAL_ADVERTISE_PEER_URLS="https:\/\/172.24.41.68:2380"/ETCD_INITIAL_ADVERTISE_PEER_URLS="https:\/\/'$ip_addr':2380"/g' /etc/etcd/etcd.conf
	sed -i 's/ETCD_ADVERTISE_CLIENT_URLS="https:\/\/127.0.0.1:2379,https:\/\/172.24.41.68:2379"/ETCD_ADVERTISE_CLIENT_URLS="https:\/\/127.0.0.1:2379,https:\/\/'$ip_addr':2379"/g' /etc/etcd/etcd.conf
	chown -R etcd.etcd /etc/etcd
	if [ $HOSTNAME = "kubernetes-Manange1" ];then
		echo " "
	elif [ $HOSTNAME = "kubernetes-Manange2" ];then
		sed -i 's/ETCD_NAME="etcd1"/ETCD_NAME="etcd2"/g' /etc/etcd/etcd.conf
	else
		sed -i 's/ETCD_NAME="etcd1"/ETCD_NAME="etcd3"/g' /etc/etcd/etcd.conf
	fi
	systemctl enable etcd
	systemctl start etcd
}

main(){
	if [[ $HOSTNAME =~ ^Kubernetes-Master00* ]];then
		gen_ca
		if [ $HOSTNAME = "Kubernetes-Master002" ]||[ $HOSTNAME = "Kubernetes-Master003" ];then
			while :
			do
				if [ -f /etc/etcd/ssl/etcd-ca-key.pem ]||[ -f /etc/etcd/ssl/etcd-ca.pem ];then
					etcd_install
					break
				fi
			done
		else
			etcd_install
		fi
	echo "ETCDCTL_ENDPOINT=https://127.0.0.1:2379" >> /etc/profile
	source /etc/profile
	etcdctl --endpoints "https://172.24.41.61:2379,https://172.24.41.57:2379,https://172.24.41.68:2379" --ca-file=/etc/etcd/ssl/etcd-ca.pem --cert-file=/etc/etcd/ssl/etcd.pem   --key-file=/etc/etcd/ssl/etcd-key.pem   cluster-health
	else
		echo ""
	fi
}
main