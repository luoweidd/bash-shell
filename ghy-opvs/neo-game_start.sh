#!/bin/bash

packge_dir=$1

declare -A r_port_table_array 
declare -A SID_table_array 
#Define an r_port array table 
r_port_table_array=( ["center"]=50001 ["db"]=50002 ["baccara"]=50003 ["bullfight"]=50004 ["classicLandords"]=50005 ["cqeverycolor"]=50006 ["cqssc"]=50007 ["dragontiger"]=50008 ["fores"]=50009 ["fruit-machine"]=50010 ["gemstorm"]=50011 ["glodflower"]=50012 ["goodstart"]=50013 ["texas-poker"]=50014 ["gragontiles"]=50015 ["red-black"]=50016 ["robtaurus"]=50017 ["gate"]=50018 ["hall"]=50019 ["log"]=50020 ["login"]=50021 ["download"]=50022 ["ip"]=50023 ["pay"]=50024 ["promotion"]=50025 ["turntaurus"]=50026 )
#Define an SID array table 
SID_table_array=( ["fores"]=2106 ["bullfight"]=2105 ["glodflower"]=2101 ["red-black"]=2102 ["robtaurus"]=2112 ["classicLandords"]=2100 ["baccara"]=2103 ["texas-poker"]=2104 ["gemstorm"]=2113 ["dragontiger"]=2108 ["turntaurus"]=2109 ["fruit-machine"]=2107 ["gragontiles"]=2111 ["goodstart"]=2110 ["cqssc"]=2114 ["cqeverycolor"]=2117 ["log"]=6100 ["db"]=8100 ["hall"]=3100 ["login"]=4100 ["center"]=9100 ["gate"]=1100 )


#Get jar pacakge file name 
Get_jar_file_name(){ 
    #First parameter: directory path (absolute path stiffness) 
    if [ ! -e $1 ];then 
        echo "[error]:$1 -> Path does not exist" 
    else 
        filename=`ls -l $1 |awk '/^-/ {print $NF}'|grep .jar`
	echo $filename
    fi 
} 

#Get soft r_port value 
Get_soft_array_table_rport(){ 
    #First parameter: directory path (absolute path stiffness) 
    for rport in ${!r_port_table_array[*]} 
    do 
	if [[ "$1" =~ ^game-$rport$ ]] || [[ "$1" =~ ^$rport-server$ ]] || [[ "$1" =~ ^$rport-serve$ ]];then 
            echo ${r_port_table_array[$rport]} 
        fi 
    done 
} 

#Get soft SID value 
Get_soft_array_table_sid(){ 
    #First parameter: directory path (absolute path stiffness) 
    for SID in ${!SID_table_array[*]} 
    do 
	if [[ "$1" =~ ^game-$SID$ ]] || [[ "$1" =~ ^$SID-server$ ]] || [[ "$1" =~ ^$SID-serve$ ]];then 
            echo $SID","${SID_table_array[$SID]} 
        fi 
    done 
} 

#start
Start(){ 
    
    file_name=$(Get_jar_file_name $packge_dir)
    echo "------------------------------------Begin" $packge_dir" server----------------------------------------"    
   	if [ -f $packge_dir"/"$file_name ];then
		echo "This application [$file_name] remote monitoring IP address:["$r_host"]" 
        	echo "Running application:["$file_name"]" 
        	r_host=`curl ifconfig.me` 
        	soft_name=`pwd|awk '{split($0,arr,"/");print arr[length(arr)]}'`
		echo "This application [$file_name] remote monitoring IP address:["$r_host"]" 
        	r_port=$(Get_soft_array_table_rport $soft_name)
        	echo "Remote listening port of this application:["$r_port"]" 
        	echo "soft_name=["$soft_name"]"
		if [[ $soft_name = "game-ip" ]] || [[ $soft_name = "game-pay" ]] || [[ $soft_name = "game-promotion" ]] ||  [[ $soft_name = "download-serve" ]];then      
			echo "----------------------------Run the manage jar package---------------------------" 
			`nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname=$r_host \
			-Dcom.sun.management.jmxremote.port="$r_port" -Dcom.sun.management.jmxremote.authenticate=false \
			-Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \
			-XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC  \
			-XX:ParallelCMSThreads=8 -XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled \
			-XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking \
			-XX:CMSInitiatingOccupancyFraction=70 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram  \
			-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintTenuringDistribution -Xloggc:log/gc.log \
			-XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m -jar "$file_name" $soft_name -Dfile.encoding=UTF-8 >log.log 2>&1 &`
		elif [[ $soft_name = "center-server" ]] || [[ $soft_name = "db-server" ]];then
			SID_info=$(Get_soft_array_table_sid $soft_name) 
			NAME=`echo $SID_info | awk '{split($0,arr,",");print arr[1]}'`
			echo Main class name:$NAME
			SID=`echo $SID_info | awk '{split($0,arr,",");print arr[2]}'` 
			echo SID:$SID
			MAIN="com.lyh.game."$NAME".start.ServerStart" 
			echo Main launch class:$MAIN
			    #Dependent_file_directory_s=$(Get_directory_down_folder $packge_dir)
			    #Dependent_file_directory=$(Get_Dependent_file_directory ${Dependent_file_directory_s[*]})
			#echo "Dependent_file_directory:" $Dependent_file_directory
			    `nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname=${r_host} \
			-Dcom.sun.management.jmxremote.port=${r_port} -Dcom.sun.management.jmxremote.authenticate=false \
			-Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \
			-XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=8 \
			-XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection \
			-XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking -XX:CMSInitiatingOccupancyFraction=70 \
			-XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps \
			-XX:+PrintTenuringDistribution -Xloggc:log/gc.log -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m \
			-cp $packge_dir"center-server/libs/*":$packge_dir$file_name \
				$MAIN ${SID} ./ $soft_name -Dfile.encoding=UTF-8 >log.log 2>&1 &`
		elif [[ $soft_name = "hall-server" ]];then
			SID_info=$(Get_soft_array_table_sid $soft_name)
			NAME=`echo $SID_info | awk '{split($0,arr,",");print arr[1]}'`
			echo Main class name:$NAME
			SID=`echo $SID_info | awk '{split($0,arr,",");print arr[2]}'`
			echo SID:$SID
			MAIN="com.lyh.game.world.start.ServerStart"
			echo Main launch class:$MAIN
			#Dependent_file_directory_s=$(Get_directory_down_folder $packge_dir)
			#Dependent_file_directory=$(Get_Dependent_file_directory ${Dependent_file_directory_s[*]})
			#echo "Dependent_file_directory:" $Dependent_file_directory
			`nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname=${r_host} \
			-Dcom.sun.management.jmxremote.port=${r_port} -Dcom.sun.management.jmxremote.authenticate=false \
			-Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \
			-XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=8 \
			-XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection \
			-XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking -XX:CMSInitiatingOccupancyFraction=70 \
			-XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps \
			-XX:+PrintTenuringDistribution -Xloggc:log/gc.log -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m \
			-cp $packge_dir"center-server/libs/*":$packge_dir$file_name \
			$MAIN ${SID} ./ $soft_name -Dfile.encoding=UTF-8 >log.log 2>&1 &`
		elif [[ $soft_name = "game-red-black" ]];then
			SID_info=$(Get_soft_array_table_sid $soft_name)
			NAME=`echo $SID_info | awk '{split($0,arr,",");print arr[1]}'`
			echo Main class name:$NAME
			SID=`echo $SID_info | awk '{split($0,arr,",");print arr[2]}'`
			echo SID:$SID
			MAIN="com.lyh.game.redblack.start.ServerStart"
			echo Main launch class:$MAIN
			#Dependent_file_directory_s=$(Get_directory_down_folder $packge_dir)
			#Dependent_file_directory=$(Get_Dependent_file_directory ${Dependent_file_directory_s[*]})
			#echo "Dependent_file_directory:" $Dependent_file_directory
			`nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname=${r_host} \
			-Dcom.sun.management.jmxremote.port=${r_port} -Dcom.sun.management.jmxremote.authenticate=false \
			-Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \
			-XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=8 \
			-XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection \
			-XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking -XX:CMSInitiatingOccupancyFraction=70 \
			-XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps \
			-XX:+PrintTenuringDistribution -Xloggc:log/gc.log -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m \
			-cp $packge_dir"center-server/lib/*":$packge_dir$file_name \
			$MAIN ${SID} ./ $soft_name -Dfile.encoding=UTF-8 >log.log 2>&1 &`
		elif [[ $soft_name = "gate-server" ]] || [[ $soft_name = "login-server" ]];then
			SID_info=$(Get_soft_array_table_sid $soft_name)
			NAME=`echo $SID_info | awk '{split($0,arr,",");print arr[1]}'`
			echo Main class name:$NAME
			SID=`echo $SID_info | awk '{split($0,arr,",");print arr[2]}'`
			echo SID:$SID
			MAIN="com.lyh.game."$NAME".start.ServerStart"
			echo Main launch class:$MAIN
			#Dependent_file_directory_s=$(Get_directory_down_folder $packge_dir)
			#Dependent_file_directory=$(Get_Dependent_file_directory ${Dependent_file_directory_s[*]})
			#echo "Dependent_file_directory:" $Dependent_file_directory
			`nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname=${r_host} \
			-Dcom.sun.management.jmxremote.port=${r_port} -Dcom.sun.management.jmxremote.authenticate=false \
			-Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \
			-XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=8 \
			-XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection \
			-XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking -XX:CMSInitiatingOccupancyFraction=70 \
			-XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps \
			-XX:+PrintTenuringDistribution -Xloggc:log/gc.log -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m \
			-cp $packge_dir"libs/*":$packge_dir$file_name \
			$MAIN ${SID} ./ $soft_name -Dfile.encoding=UTF-8 >log.log 2>&1 &`
		elif [[ $soft_name = "game-fruit-machine" ]];then
			SID_info=$(Get_soft_array_table_sid $soft_name)
			NAME=`echo $SID_info | awk '{split($0,arr,",");print arr[1]}'`
			echo Main class name:$NAME
			SID=`echo $SID_info | awk '{split($0,arr,",");print arr[2]}'`
			echo SID:$SID
			MAIN="com.lyh.game.fruitmachine.start.ServerStart"
			echo Main launch class:$MAIN
			#Dependent_file_directory_s=$(Get_directory_down_folder $packge_dir)
			#Dependent_file_directory=$(Get_Dependent_file_directory ${Dependent_file_directory_s[*]})
			#echo "Dependent_file_directory:" $Dependent_file_directory
			`nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname=${r_host} \
			-Dcom.sun.management.jmxremote.port=${r_port} -Dcom.sun.management.jmxremote.authenticate=false \
			-Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \
			-XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=8 \
			-XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection \
			-XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking -XX:CMSInitiatingOccupancyFraction=70 \
			-XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps \
			-XX:+PrintTenuringDistribution -Xloggc:log/gc.log -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m \
			-cp $packge_dir"center-server/lib/*":$packge_dir$file_name \
			$MAIN ${SID} ./ $soft_name -Dfile.encoding=UTF-8 >log.log 2>&1 &`
		elif [[ $soft_name = "game-classicLandords" ]];then
			SID_info=$(Get_soft_array_table_sid $soft_name)
			NAME=`echo $SID_info | awk '{split($0,arr,",");print arr[1]}'`
			echo Main class name:$NAME
			SID=`echo $SID_info | awk '{split($0,arr,",");print arr[2]}'`
			echo SID:$SID
			MAIN="com.lyh.game.classicLandlords.start.ServerStart"
			echo Main launch class:$MAIN
			#Dependent_file_directory_s=$(Get_directory_down_folder $packge_dir)
			#Dependent_file_directory=$(Get_Dependent_file_directory ${Dependent_file_directory_s[*]})
			#echo "Dependent_file_directory:" $Dependent_file_directory
			`nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname=${r_host} \
			-Dcom.sun.management.jmxremote.port=${r_port} -Dcom.sun.management.jmxremote.authenticate=false \
			-Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \
			-XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=8 \
			-XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection \
			-XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking -XX:CMSInitiatingOccupancyFraction=70 \
			-XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps \
			-XX:+PrintTenuringDistribution -Xloggc:log/gc.log -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m \
			-cp $packge_dir"center-server/lib/*":$packge_dir$file_name \
			$MAIN ${SID} ./ $soft_name -Dfile.encoding=UTF-8 >log.log 2>&1 &`
		else
			SID_info=$(Get_soft_array_table_sid $soft_name) 
			NAME=`echo $SID_info | awk '{split($0,arr,",");print arr[1]}'`
			echo Main class name:$NAME
			SID=`echo $SID_info | awk '{split($0,arr,",");print arr[2]}'` 
			echo SID:$SID
			MAIN="com.lyh.game."$NAME".start.ServerStart" 
			echo Main launch class:$MAIN
			    #Dependent_file_directory_s=$(Get_directory_down_folder $packge_dir)
			    #Dependent_file_directory=$(Get_Dependent_file_directory ${Dependent_file_directory_s[*]})
			#echo "Dependent_file_directory:" $Dependent_file_directory
			    `nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname=${r_host} \
			-Dcom.sun.management.jmxremote.port=${r_port} -Dcom.sun.management.jmxremote.authenticate=false \
			-Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \
			-XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=8 \
			-XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection \
			-XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking -XX:CMSInitiatingOccupancyFraction=70 \
			-XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps \
			-XX:+PrintTenuringDistribution -Xloggc:log/gc.log -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m \
			-cp $packge_dir"center-server/lib/*":$packge_dir$file_name \
			    $MAIN ${SID} ./ $soft_name -Dfile.encoding=UTF-8 >log.log 2>&1 &`
	       fi
	fi
}
Start
