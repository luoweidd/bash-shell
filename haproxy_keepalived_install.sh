#!/bin/bash
yum install -y keepalived
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
touch /etc/keepalived/keepalived.conf
cat >> /etc/keepalived/keepalived.conf<<EOF
! Configuration File for keepalived
    global_defs {
        notification_email {
            root@localhost      #发送邮箱
        }
        notification_email_from keepalived@localhost    #邮箱地址   
        smtp_server 127.0.0.1   #邮件服务器地址
        smtp_connect_timeout 30 
        router_id kubernetes-Master         #主机名，每个节点不同即可
        vrrp_mcast_group4 224.0.0.0    #组播地址
    }       
        
vrrp_instance VI_1 {
    state MASTER        #在另一个节点上为BACKUP
    interface ens33      #IP地址漂移到的网卡
    virtual_router_id 6 #多个节点必须相同
    priority 100        #优先级，备用节点的值必须低于主节点的值
    advert_int 1        #通告间隔1秒
    authentication {
        auth_type PASS      #预共享密钥认证
        auth_pass 571f97b2  #密钥
    }
    virtual_ipaddress {
        188.188.188.254/24    #VIP地址
    }
}	
EOF

if [ $HOSTNAME = "kubernetes-Manange1" ];then
	sed -i 's/router_id kubernetes-Master/router_id kubernetes-Master1/g' /etc/keepalived/keepalived.conf
	sed -i 's/state MASTER/state BACKUP/g' /etc/keepalived/keepalived.conf
fi
if [ $HOSTNAME = "kubernetes-Manange2" ];then
	sed -i 's/router_id kubernetes-Master/router_id kubernetes-Master1/g' /etc/keepalived/keepalived.conf
	sed -i 's/state MASTER/state BACKUP/g' /etc/keepalived/keepalived.conf
	sed -i 's/priority 100/priority 80/g' /etc/keepalived/keepalived.conf
else
	sed -i 's/router_id kubernetes-Master/router_id kubernetes-Master1/g' /etc/keepalived/keepalived.conf
	sed -i 's/state MASTER/state BACKUP/g' /etc/keepalived/keepalived.conf
	sed -i 's/priority 100/priority 60/g' /etc/keepalived/keepalived.conf
fi

systemctl enable keepalived
systemctl start keepalived 