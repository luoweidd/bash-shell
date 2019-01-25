!/bin/bash
# java or php or DB Regular service application is installed
mysql="mysql"
javapro="javaweb"
phppro="phpweb"

while true
do
	echo "Are you going to run this machine as what business?"
    read type
	if [ $type == $mysql ];then
		rpm -ivh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
		yum install mysql-server -y
	elif [ $type == $javapro ];then
		touch /etc/yum.repos.d/nginx.repo
		echo "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo
		yum install java -y
		yum install nginx tomcat -y
	elif [ $type == $phppro ];then
		touch /etc/yum.repos.d/nginx.repo
        	echo "[nginx] 
name=nginx repo 
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo
		yum install nginx php php-fpm -y
    elif [ $type =="exit" ]; then
        break
	else
		conut=3
		for(( i = 0; i <= conut; i++ ))
		do
			echo "This program is not equipped with corresponding integration, or character input errors.To continue(y/n)"
			read judge
			if [ $judge == "n"  ] || [ $judge == "no" ]; then
				exit
			elif [ $judge == "y" ] || [ $judge == "yes" ]; then
				break
			else
				echo "Input error, also "$conut-$i" chance again."
			fi
		done
	fi
done
