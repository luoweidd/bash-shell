#!/bin/sh

filepath=$1

for ip in `cat $filepath`
do
	set timeout 15
	scp /home/devops/.ssh/authorized_keys root@$ip:/root/.ssh/
EOF
done
