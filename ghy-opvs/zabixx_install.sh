#!/bin/bash
install_server(){
        rpm -Uvh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm --nosignature
        sed -i 's/gpgcheck=1/gpgcheck=0/g'
	yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-agent
}
install_agent(){
        rpm -Uvh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm --nosignature
        sed -i 's/gpgcheck=1/gpgcheck=0/g'
	yum -y install zabbix-agent
}
main(){
        case ${1} in
                server) install_server
                ;;
                agent) install_agent
                ;;
                *) echo ' \
        install server run shell parameter,example: ./xxx.sh parameter. this version zabixx 4.0 centos 7\
        Parameters are:\
                        server          install server\
                        agent           install agent'
		;;
	esac
}
main $1
