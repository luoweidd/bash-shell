#!/bin/bash

packge_dir=`pwd`
#tomcat directory name
admin="admin_package"
chat="chat_package"
apk="apk_parser"

declare -A r_port_table_array
declare -A SID_table_array
#Define an r_port array table
r_port_table_array=( ["titi-admin"]=50035 ["three-duke"]=50034 ["leopard"]=50033 ["bull"]=50032 ["bearrob"]=50031 ["chat"]=50031 ["redpacket"]=50030 ["red-packet"]=50029 ["center"]=50001 ["db"]=50002 ["baccara"]=50003 ["quartz-job"]=50027 ["platform"]=50028 ["bullfight"]=50004 ["classicLandords"]=50005 ["cqeverycolor"]=50006 ["cqssc"]=50007 ["dragontiger"]=50008 ["fores"]=50009 ["fruit-machine"]=50010 ["gemstorm"]=50011 ["glodflower"]=50012 ["goodstart"]=50013 ["texas-poker"]=50014 ["gragontiles"]=50015 ["red-black"]=50016 ["robtaurus"]=50017 ["gate"]=50018 ["hall"]=50019 ["log"]=50020 ["login"]=50021 ["download"]=50022 ["ip"]=50023 ["pay"]=50024 ["promotion"]=50025 ["turntaurus"]=50026 )
#Define an SID array table
SID_table_array=( ["three-duke"]=2119 ["leopard"]=2109  ["bull"]=2102 ["bearrob"]=2107 ["redpacket"]=2100 ["fores"]=2106 ["bullfight"]=2105 ["quartz-job"]=13000 ["platform"]=12000 ["glodflower"]=2101 ["red-black"]=2102 ["robtaurus"]=2112 ["classicLandords"]=2100 ["baccara"]=2103 ["texas-poker"]=2104 ["gemstorm"]=2113 ["dragontiger"]=2108 ["turntaurus"]=2109 ["fruit-machine"]=2107 ["gragontiles"]=2111 ["goodstart"]=2110 ["cqssc"]=2114 ["cqeverycolor"]=2117 ["log"]=6100 ["db"]=8100 ["hall"]=3100 ["login"]=4100 ["center"]=9100 ["gate"]=1100 )


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
	if [[ "$1" =~ ^game-$rport$ ]] || [[ "$1" =~ ^$rport-server$ ]] || [[ "$1" =~ ^$rport-serve$ ]] || [[ "$1" =~ ^$rport-admin$ ]] || [[ "$1" == $rport ]];then
            echo ${r_port_table_array[$rport]}
        fi
    done
}

#Get soft SID value
Get_soft_array_table_sid(){
    #First parameter: directory path (absolute path stiffness) $soft_name=
    for SID in ${!SID_table_array[*]}
    do
	if [[ "$1" =~ ^game-$SID$ ]] || [[ "$1" =~ ^$SID-server$ ]] || [[ "$1" =~ ^$SID-serve$ ]];then
            echo $SID","${SID_table_array[$SID]}
        fi
    done
}

Run_game_java(){
        	`nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname=$1 \
                -Dcom.sun.management.jmxremote.port=$2 -Dcom.sun.management.jmxremote.authenticate=false \
                -Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \
                -XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=8 \
                -XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection \
                -XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking -XX:CMSInitiatingOccupancyFraction=70 \
                -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps \
                -XX:+PrintTenuringDistribution -Xloggc:log/gc.log -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m \
                -cp "/home/new_project/center-server/lib/*":$3/$4 \
		        $5 $6 ./ $7 -Dfile.encoding=UTF-8 >log.log 2>&1 &`
}

Run_server_java(){
        	`nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname=$1 \
                -Dcom.sun.management.jmxremote.port=$2 -Dcom.sun.management.jmxremote.authenticate=false \
                -Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \
                -XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=8 \
                -XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection \
                -XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking -XX:CMSInitiatingOccupancyFraction=70 \
                -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps \
                -XX:+PrintTenuringDistribution -Xloggc:log/gc.log -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m \
                -cp "/home/new_project/center-server/libs/*":$3/$4 \
		        $5 $6 ./ $7 -Dfile.encoding=UTF-8 >log.log 2>&1 &`
}


#start
Start(){

    file_name=$(Get_jar_file_name $packge_dir)
    echo "------------------------------------Begin" "/opt/new_project/ server----------------------------------------"
   	if [ -f $packge_dir"/"$file_name ];then
		echo "This application [$file_name] remote monitoring IP address:["$r_host"]"
        	echo "Running application:["$file_name"]"
        	r_host=`curl ifconfig.me`
        	soft_name=`pwd|awk '{split($0,arr,"/");print arr[length(arr)]}'`
		echo "This application [$file_name] remote monitoring IP address:["$r_host"]"
        	r_port=$(Get_soft_array_table_rport $soft_name)
        	echo "Remote listening port of this application:["$r_port"]"
        	echo "soft_name=["$soft_name"]"
	    if [[ $soft_name == "titi-admin" ]] || [[ $soft_name == "red-packet-admin" ]] || [[ $soft_name == "game-ip" ]] || [[ $soft_name == "game-pay" ]] || [[ $soft_name  == "game-promotion" ]] ||  [[ $soft_name == "download-server" ]] || [[ $soft_name == "chat-admin" ]];then
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
         elif [[ $soft_name = "center-server" ]] || [[ $soft_name = "db-server" ]] || [[ $soft_name  = "log-server" ]]  || [[ $soft_name = "hall-server" ]] || [[ $soft_name = "platform-server" ]];then
                echo "now node: 1"
                SID_info=$(Get_soft_array_table_sid $soft_name)
                NAME=`echo $SID_info | awk '{split($0,arr,",");print arr[1]}'`
                echo Main class name:$NAME
                SID=`echo $SID_info | awk '{split($0,arr,",");print arr[2]}'`
                echo SID:$SID
                MAIN="com.lyh.game."$NAME".start.ServerStart"
                echo Main launch class:$MAIN
		    #Dependent_file_directory_s=$(Get_directory_down_folder $packge_dir)
		    #Dependent_file_directory=$(Get_Dependent_file_directory ${Dependent_file_directory_s[*]})
                #echo "Dependent_file_dom.lyh.game..starependent_file_directory
		 Run_server_java $r_host $r_port $packge_dir $file_name $MAIN ${SID} $soft_name
        elif [[ $soft_name = "game-red-black" ]];then
                echo "now node: 21"
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
                Run_server_java $r_host $r_port $packge_dir $file_name $MAIN ${SID} $soft_name
        elif [[ $soft_name = "gate-server" ]] || [[ $soft_name = "login-server" ]];then
                echo "now node: 3"
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
		 Run_server_java $r_host $r_port $packge_dir $file_name $MAIN ${SID} $soft_name
        elif [[ $soft_name = "game-fruit-machine" ]];then
                echo "now node: 4"
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
		 Run_game_java $r_host $r_port $packge_dir $file_name $MAIN ${SID} $soft_name
       elif [[ $soft_directory = "game-three-duke" ]];then
                echo "now node: 5"
                SID_info=$(Get_soft_array_table_sid $soft_directory)
                NAME=`echo $SID_info | awk '{split($0,arr,",");print arr[1]}'`
                echo Main class name:$NAME
                SID=`echo $SID_info | awk '{split($0,arr,",");print arr[2]}'`
                echo SID:$SID
                MAIN="com.lyh.game.threeduke.start.ServerStart"
                echo Main launch class:$MAIN
                Run_game_java $r_host $r_port $Release_soft_directory $file_name $MAIN ${SID} $soft_directory  $Release_directory
        elif [[ $soft_name = "game-classicLandords" ]];then
                echo "now node: 5"
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
		 Run_game_java $r_host $r_port $packge_dir $file_name $MAIN ${SID} $soft_name
        elif [[ $soft_name == $admin ]] || [[ $soft_name == $apk ]] || [[ $soft_name == $chat ]];then
                        echo "now node: 6"
                case $soft_name in
                        $admin)
                        echo "Run admin_package Tomcat"
                        cd $packge_dir$soft_name/bin/
                        sh startup.sh
                        ;;
                        $apk)
                        echo "Run apk.jar"
                        cd $packge_dir"apk_parser/dist/"
                        chmod 775 apk.sh
                        sh apk.sh
                        ;;
                        $chat)
                        echo "Run chat_package Tomcat"
                        cd $packge_dir$soft_name/bin/
                        sh startup.sh
                        ;;
                esac
        elif [[ $soft_name  = "quartz-job-server" ]];then
                echo "now node: 7"
                SID_info=$(Get_soft_array_table_sid $soft_name)
                NAME=`echo $SID_info | awk '{split($0,arr,",");print arr[1]}'`
                echo Main class name:$NAME
                SID=`echo $SID_info | awk '{split($0,arr,",");print arr[2]}'`
                echo SID:$SID
                MAIN="com.lyh.game.quartz.start.ServerStart"
                echo Main launch class:$MAIN
                #Dependent_file_directory_s=$(Get_directory_down_folder $packge_dir)
                #Dependent_file_directory=$(Get_Dependent_file_directory ${Dependent_file_directory_s[*]})
                #echo "Dependent_file_directory:" $Dependent_file_directory
		 Run_server_java $r_host $r_port $packge_dir $file_name $MAIN ${SID} $soft_name
        else
                echo "now node: 8"
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
		 Run_game_java $r_host $r_port $packge_dir $file_name $MAIN ${SID} $soft_name

	    fi
        fi
}

Start
