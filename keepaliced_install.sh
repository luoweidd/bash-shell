yum -y install gcc gcc+ gcc-c++
yum -y install popt-devel openssl openssl-devel libssl-dev libnl-devel popt-devel
yum -y install kernel kernel-devel
#ln -s /usr/src/kerners/2.6....../ /usr/src/linux
yum -y install keepalived
yum -y install ipvsadm
yum install popt-static -y

#虚拟的vip 根据自己的实际情况定义
SNS_VIP=10.15.208.88
/etc/rc.d/init.d/functions
ifconfig lo:0 $SNS_VIP netmask 255.255.255.255 broadcast $SNS_VIP
/sbin/route add -host $SNS_VIP dev lo:0
echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
sysctl -p >/dev/null 2>&1
echo "RealServer Start OK"

keepa_path=/etc/keepalived/keepalived.conf
mv $keepa_path $keepa_path.bak
touch $keepa_path
cat >> $keepa_path << EOF
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
   vrrp_skip_check_adv_addr
   #vrrp_strict
   vrrp_garp_interval 0
   vrrp_gna_interval 0
}

vrrp_script chk_mysql_port {
    script "</dev/tcp/127.0.0.1/3306"
    interval 1
    weight -2
}

vrrp_instance VI_1 {
    state MASTER
    interface ens37
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        \$SNS_VIP
    }
    track_script {
        chk_mysql_port
    }
}
virtual_server \$SNS_VIP 3306 {
    delay_loop 6
    lb_algo rr  
    lb_kind NAT 
    persistence_timeout 50
    protocol TCP 

    #sorry_server 10.15.208.88 80

    real_server 10.15.208.85 3306 {
        weight 1
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
			connect_port 3306
        }   
    }   

    real_server 10.15.208.34 3306 {
        weight 1
        TCP_CHECK {  
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
			connect_port 3306
        }   
    }   
    real_server 10.15.208.37 3306 {
        weight 1
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
			connect_port 3306
        }   
    }   
}
EOF
systemctl start keepalived