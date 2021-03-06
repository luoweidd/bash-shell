#!/bin/bash
#author:luowei
#Email:3245554@qq.com/luowei.l.v@gmail.com/jeak_2003_@hotmail.com
#datatime:2019-1-23 09:49

# Release directory
Release_directory="/home/new_project/"
#backlist
backup_time=`date '+%Y-%m-%d_%H'`
#Backup master directory
folder="new_project_backup"
#Git local repository
git_local_repository=$Release_directory"download/git/"
#nginx static directory
yum_nginx_file_folder="/usr/share/nginx/html"
make_nginx_file_folder="/usr/local/nginx/html"

declare -A r_port_table_array
declare -A SID_table_array
#Define an r_port array table
r_port_table_array=( ["admin"]=50040 ["down"]=50039 ["generalize"]=50038 ["agentmanage"]=50037 ["api"]=50036 ["titi-admin"]=50035 ["three-duke"]=50034 ["leopard"]=50033 ["bull"]=50032 ["bearrob"]=50031 ["redpacket"]=50030 ["red-packet"]=50029 ["center"]=50001 ["db"]=50002 ["baccara"]=50003 ["quartz-job"]=50027 ["platform"]=50028 ["bullfight"]=50004 ["classicLandords"]=50005 ["cqeverycolor"]=50006 ["cqssc"]=50007 ["dragontiger"]=50008 ["fores"]=50009 ["fruit-machine"]=50010 ["gemstorm"]=50011 ["glodflower"]=50012 ["goodstart"]=50013 ["texas-poker"]=50014 ["gragontiles"]=50015 ["red-black"]=50016 ["robtaurus"]=50017 ["gate"]=50018 ["hall"]=50019 ["log"]=50020 ["login"]=50021 ["download"]=50022 ["ip"]=50023 ["pay"]=50024 ["promotion"]=50025 ["turntaurus"]=50026 )
#Define an SID array table
SID_table_array=( ["three-duke"]=2119 ["leopard"]=2109  ["bull"]=2102 ["bearrob"]=2107 ["redpacket"]=2100 ["fores"]=2106 ["bullfight"]=2105 ["quartz-job"]=13000 ["platform"]=12000 ["glodflower"]=2101 ["red-black"]=2102 ["robtaurus"]=2112 ["classicLandords"]=2100 ["baccara"]=2103 ["texas-poker"]=2104 ["gemstorm"]=2113 ["dragontiger"]=2108 ["turntaurus"]=2109 ["fruit-machine"]=2107 ["gragontiles"]=2111 ["goodstart"]=2110 ["cqssc"]=2114 ["cqeverycolor"]=2117 ["log"]=6100 ["db"]=8100 ["hall"]=3100 ["login"]=4100 ["center"]=9100 ["gate"]=1100)



#Get the git repository to get the latest update package
Git_Repository_Pull_Method(){
    echo "----------------------Get the git repository to get the latest update package---------------------"
    directory_context=$(Get_directory_down_folder $git_local_repository)
    echo "${directory_context[@]}"
    if [ ${#directory_context[*]} -gt 0 ];then
        for directory in ${directory_context[@]}
        do
            cd $git_local_repository$directory
            echo "---Enterchat-adminrectory" directory---"
            echo "--------chat-adminry" repository data--------------"
	      git fetch --all chat-admin
		git reset --hard origin/master
        git branch --set-upstream-to origin/master
		git pull
            echo $git_local_repository$directory "--------------->> Pull complete, the top is the pull data result information."
        done
    else
        echo $git_local_repository "[error]：There are no folders in the directory！"
    fi

}

# Gets the names of all folders in the publish directory
Get_directory_down_folder(){
    #First parameter: directory path (absolute path stiffness)
    if [ -e $1 ];then
	FOLDER_S=`ls -l $1 |awk '/^d/ {print $NF}'`
	echo ${FOLDER_S[*]}
    else
	echo "[error]:$1 -> Path does not exist"
    fi
}

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

terminator(){
    echo "----------------------------------------------------[terminator]----------------------------------------------------------"
}

Running_java_program(){
        echo "---The following are the running Java programs---"
        ps -aux|grep java|awk '$42{print $44}'
	  echo "Total："`ps -aux|grep java|awk '$42{print $44}'|wc -l`
        terminator
	echo "Total launch java pro: << "`ps -aux|grep "java" |wc -l`" >> process"
}

#Close all services
Close_all_services(){
    directory_context=$(Get_directory_down_folder $Release_directory)
    if [ ${#directory_context[@]} -gt 0 ];then
        for soft_keyword in ${directory_context[@]}
        do
            run_pid=`ps -aux|grep "$soft_keyword" |grep -v grep|awk '{print $2}'`
	    for pid in ${run_pid[@]}
	    do
		if [ ! -z $pid ];then
			kill -9 $pid
			echo "$soft_keyword killed PID:$pid"
	    	fi
	    done
        done
    else
        echo $git_local_repository "[error]：There are no folders in the directory！"
        Running_java_program
    fi
}

#Nginx static files are copies, not moves
backup_nginx_file(){
    if [ -e $yum_nginx_file_folder ];then
	if [ -e $1 ];then
            `\cp -arf $yum_nginx_file_folder $1`
        else
            mkdir $1
            `\cp -arf $yum_nginx_file_folder $1`
        fi
	echo "YUM vresion Backup information:"
	echo "The current path:"$1
	ls -l $1
    elif [ -e $make_nginx_file_folder ];then
        if [ -e $1 ];then
            `\cp -arf $make_nginx_file_folder $1`
        else
            mkdir $1
            `\cp -arf $make_nginx_file_folder $1`
        fi
	echo "Make version Backup information:"
	echo "The current path:"$1
	ls -l $1
    fi
}

#backup all files
backup_all_files(){
    if [ -e $Release_directory ];then
        cd $Release_directory
        cd ../
        if [ ! -e $folder ];then
            `mkdir $folder`
        elif [ ! -e "$folder/$backup_time" ];then
		cd $folder
                `mkdir $backup_time`
		echo "Create file directory:"$folder/$backup_time
        fi
        backup_directory="/opt/$folder/$backup_time/"
        directory_context=$(Get_directory_down_folder $Release_directory)
        for soft_folder in ${directory_context[@]}
        do
            if [[ $soft_folder != "download" ]] || [[ $soft_folder != "apk_parser" ]];then
		        echo "backup java soft file"
                `\cp -arf $Release_directory$soft_folder $backup_directory`
		    #rm -rf $Release_directory$soft_folder
		    fi
        done
    fi
    echo "------------backup nginx-----------"
    backup_nginx_file $backup_directory
}

update_nginx_static_file(){
    echo "---Start the nginx update operation---"
    if [ -e $yum_nginx_file_folder ];then
        `\cp -arf $1 "$yum_nginx_file_folder/"`
        echo "$1 update completed"
    elif [ -e $make_nginx_file_folder ];then
        `\cp -arf $1 "$make_nginx_file_folder/"`
        echo "$1 update completed"
    else
        echo "[error]: There is no nginx application service in this server"
    fi
}

#update all
Update_all_files(){
    echo "------------------------------------Begin updating all files from your local git repository----------------------------------------"
    #echo "---Start the backup operation---"
    #backup_all_files
    #echo "---The backup operation completes---"
    echo "---Copy new files to directory---"
    #git repository directory context
    git_repository_directory_context=$(Get_directory_down_folder $git_local_repository)
    #echo ${git_repository_directory_context[*]}
    if [ ${#git_repository_directory_context[*]} -gt 0 ];then
        for directory in ${git_repository_directory_context[@]}
        do
	        echo "The current repository name："$directory
	        #repository osft directory context
	        repository_soft_directory_context=$(Get_directory_down_folder $git_local_repository$directory)
	        for app in ${repository_soft_directory_context[@]}
		    do
	        	if [ $app = "web" ]  || [ $app = "agent" ] || [ $app = "agentWeb" ];then
                    	update_nginx_static_file "$git_local_repository$directory/$app"
                else
                    	`\cp -arf  "$git_local_repository$directory/$app" "$Release_directory"`
                fi
	    	done
	echo "[$app]: --->> updates completed"
        done
        echo "---All application updates completed---"
	echo "
	Static file update information:"
	if [ -e $yum_nginx_file_folder ];then
            ls -l $yum_nginx_file_folder
	elif [ -e $make_nginx_file_folder ];then
	    ls -l $make_nginx_file_folder
	else
	    echo "Non-deployed nginx service on this machine"
	fi
	echo "
	Dynamic file update information:"
	ls -l $Release_directory
    else
        echo "[error:]There is no content in the warehouse"
   fi
    echo "----------------------------------------------------Update completed----------------------------------------------------------------"
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

Get_Dependent_file_directory(){
	logic_lib_path="$Release_directory"center-server/libs/""
	independent_lib_path="$Release_soft_directory"/libs/""
	local args=$1
	for i in ${args[@]}
	do
		if [ $i = "libs" ];then
			echo "$independent_lib_path"
		else
			echo "$logic_lib_path"
		fi
	done
}



#start all
Start_all(){
    echo "------------------------------------Begin run all server----------------------------------------"
    directory_context=$(Get_directory_down_folder $Release_directory)
    for soft_directory in ${directory_context[@]}
    do
        Release_soft_directory=$Release_directory$soft_directory
          echo "Enter"$Release_soft_directory
        file_name=$(Get_jar_file_name $Release_soft_directory)
        r_host=`curl ifconfig.me`
	  if [ -f "$Release_soft_directory/$file_name" ];then
            echo "---Enter $soft_directory Release directory---"
            cd $Release_soft_directory
            echo "Running application:["$file_name"]"
            #r_host=`curl ifconfig.me`
            echo "This application [$soft_directory] remote monitoring IP address:["$r_host"]"
            r_port=$(Get_soft_array_table_rport $soft_directory)
            echo "Remote listening port of this application:["$r_port"]"
            echo "soft_directory=[$soft_directory]"
            echo "----------------------------Run the manage jar package---------------------------"
            class_name=`echo $soft_directory | awk '{print toupper(substr($0,0,1))tolower(substr($0,2))}'`
            #echo $class_name
            MAIN="com.lyh.app.video."$soft_directory"."$class_name"Application"
            echo "Main class:"$MAIN
            `nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname=$r_host \
                -Dcom.sun.management.jmxremote.port="$r_port" -Dcom.sun.management.jmxremote.authenticate=false \
                -Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \
                -XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC  \
                -XX:ParallelCMSThreads=8 -XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled \
                -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking \
                -XX:CMSInitiatingOccupancyFraction=70 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram  \
                -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintTenuringDistribution -Xloggc:log/gc.log \
                -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m -cp $Release_soft_directory"/lib/*":$Release_soft_directory"/"$file_name \
                 $MAIN $soft_directory -Dfile.encoding=UTF-8 >log.log 2>&1 &`
        fi
        sleep 3
    done
    terminator
    Running_java_program
}



main(){
    if [ ! -e $git_local_repository  -a  ! -e $Release_directory ];then
        echo $git_local_repository "[error]: Path does not exist"
    else
        case ${1} in
            oko) Git_Repository_Pull_Method
            Close_all_services
	    backup_all_files
            Update_all_files
            Start_all
            ;;
            start) Start_all
            ;;
            close) Close_all_services
            ;;
            update) Update_all_files
            ;;
	      backup) backup_all_files
	    ;;
	      gitpull) Git_Repository_Pull_Method
            ;;
	    *) echo "
To run the script, you need to add the run parameter, example:./ (script file name. Sh) parameter
	Parameters are:
        oko        One-click operation, including pulling git repository, closing service,
                   updating service file and running service.The run order is pull, close, update, start.
        Start      Start to run all services
        Shutdown   Shutdown shuts down all running services
	 backup     Backup all server soft file
	 gitpull    Git Repository Pull
        Update     Update all services"
            ;;
        esac
    fi
}

main $1
