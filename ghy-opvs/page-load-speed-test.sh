#!/bin/bash

#address=$1
address="http://groom.62pdq.cn/"

for ((i = 1;i <= 3;i++))
do
	echo "test "$i
	echo "test address:"$address
	curl -o /dev/null -s -w " DNS:"%{time_namelookup}"s;\n TCP-connection:"%{time_connect}"s;\n connction-respons:"%{time_starttransfer}"s;\n send-data:"%{time_total}"s;\n download-speed:"%{speed_download}"b/s;\n"%{http_code}";\n" $address
	echo ""
done
