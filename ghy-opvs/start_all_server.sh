#!/bin/bash 
#author:luowei 
#Email:3245554@qq.com/luowei.l.v@gmail.com/jeak_2003_@hotmail.com 
#datatime:2019-1-23 09:49 
 
# Release directory 
Release_directory="/opt/new_project/"
#backlist 
backup_time=`date '+%Y-%m-%d_%H'` 
#Backup master directory 
folder="new_project_backup" 
#Git local repository 
git_local_repository=$Release_directory"download/git/" 
#tomcat directory name  
admin="admin_package" 
chat="chat_package" 
apk="apk_parser" 
#nginx static directory 
yum_nginx_file_folder="/usr/share/nginx/html"
make_nginx_file_folder="/usr/local/nginx/html"
 
declare -A r_port_table_array 
declare -A SID_table_array 
#Define an r_port array table 
r_port_table_array=( ["center"]=50001 ["db"]=50002 ["baccara"]=50003 ["bullfight"]=50004 ["classicLandords"]=50005 ["cqeverycolor"]=50006 ["cqssc"]=50007 ["dragontiger"]=50008 ["fores"]=50009 ["fruit-machine"]=50010 ["gemstorm"]=50011 ["glodflower"]=50012 ["goodstart"]=50013 ["texas-poker"]=50014 ["gragontiles"]=50015 ["red-black"]=50016 ["robtaurus"]=50017 ["gate"]=50018 ["hall"]=50019 ["log"]=50020 ["login"]=50021 ["download"]=50022 ["ip"]=50023 ["pay"]=50024 ["promotion"]=50025 ["turntaurus"]=50026 )
#Define an SID array table 
SID_table_array=( ["fores"]=2106 ["bullfight"]=2105 ["glodflower"]=2101 ["red-black"]=2102 ["robtaurus"]=2112 ["classicLandords"]=2100 ["baccara"]=2103 ["texas-poker"]=2104 ["gemstorm"]=2113 ["dragontiger"]=2108 ["turntaurus"]=2109 ["fruit-machine"]=2107 ["gragontiles"]=2111 ["goodstart"]=2110 ["cqssc"]=2114 ["cqeverycolor"]=2117 ["log"]=6100 ["db"]=8100 ["hall"]=3100 ["login"]=4100 ["center"]=9100 ["gate"]=1100 )
 
 
#Get the git repository to get the latest update package 
Git_Repository_Pull_Method(){ 
    echo "----------------------Get the git repository to get the latest update package---------------------" 
    directory_context=$(Get_directory_down_folder $git_local_repository) 
    echo "${directory_context[@]}" 
    if [ ${#directory_context[*]} -gt 0 ];then 
        for directory in ${directory_context[@]} 
        do
            cd $git_local_repository$directory 
            echo "---Enter the "$git_local_repository$directory" directory---" 
            echo "---------------Begin pulling "$directory" repository data--------------" 
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
        file_name=echo `ls -l $1 |awk '/^-/ {print $NF}|grep *.jar'`
	echo ${filename[*]}
    fi 
} 
 
terminator(){ 
    echo "----------------------------------------------------[terminator]----------------------------------------------------------" 
} 
 
Running_java_program(){ 
        echo "---The following are the running Java programs---" 
        ps -aux|grep java 
	conut=`ps -aux|grep java |wc -l` 
        terminator 
	echo "Total launch java pro:"$count"process" 
} 
 
#Close all services 
Close_all_services(){ 
    directory_context=$(Get_directory_down_folder $Release_directory)
    if [ ${#directory_context[@]} -gt 0 ];then 
        for soft_keyword in ${directory_context[@]} 
        do	
            run_pid=`ps -aux|grep "$soft_keyword" |grep -v grep|awk '{print $2}'`
	    if [ $run_pid ];then
		kill -9 $run_pid
		echo "$soft_keyword killed PID:$run_pid"
	    fi
        done 
    else 
        echo $git_local_repository "[error]：There are no folders in the directory！"    
        Running_java_program 
    fi 
} 
 
#Nginx static files are copies, not moves 
backup_nginx_file(){ 
    if [ -e $yum_nginx_file_folder ];then 
        if [ -e /opt/$folder/$1 ];then 
            `cp -arf $yum_nginx_file_folder $folder/$1/` 
        else 
            `mkdir /opt/$folder/$1` 
            `cp -arf $yum_nginx_file_folder $folder/$1/`
	echo "YUM vresion Backup information:"
	echo `ls -l $folder/$1`
        fi 
    elif [ -e $make_nginx_file_folder ];then 
        if [ -e /opt/$folder/$1 ];then 
            `cd /opt/$folder`  
            `cp -arf $make_nginx_file_folder $1/` 
        else  
            `mkdir /opt/$folder/$1` 
            `cp -arf $make_nginx_file_folder $1/`
	    echo "Make version Backup information:"
	    echo `ls -l $1`
        fi 
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
        fi 
        backup_directory="/opt/$folder/$backup_time"
        directory_context=$(Get_directory_down_folder $Release_directory)
        for soft_folder in ${directory_context[@]} 
        do 
            if [ $soft_folder != "download" ];then
                if [ $soft_folder = $admin ];then
                    mv -f $Release_directory$soft_folder/webapps/* $backup_directory/
		elif [ $soft_folder = $chat ]
		then
                    mv -f $Release_directory$soft_folder/webapps/* $backup_directory/
		else 
                    mv -f $Release_directory$soft_folder $backup_directory/
		fi 
            fi 
        done 
    fi 
    backup_nginx_file $backup_time
} 
 
update_nginx_static_file(){ 
    echo "---Start the nginx update operation---" 
    if [ -e $yum_nginx_file_folder ];then 
        cp -rf $1 "$yum_nginx_file_folder/"
        echo "$1 update completed" 
    elif [ -e $make_nginx_file_folder ];then
        cp -rf $1 "$make_nginx_file_folder/"
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
			#echo "The current app name："$app
                	if [ $app = $admin ] ||  [ $app = $chat ];then
				if [ -e $Release_directory$app ];then 
                    			`cp -rf $git_local_repository$directory/$app/* "$Release_directory$app/webapps/"`
                    			echo "Tomcat application ["$app"] is even more complete! Update the result information:"
					ls -l "$Release_directory$app/webapps/"
				else
					echo "[error]:There is no tomcat deployment in this path location"
				fi 
                	elif [ $app = "web" ]  || [ $app = "agent" ] || [ $app = "agentWeb" ];then 
                    		update_nginx_static_file "$git_local_repository$directory/$app"
                	else 
                    		cp -rf  "$git_local_repository$directory/$app" "$Release_directory"
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
	if [[ "$1" =~ *"-$rport" ]] || [[ "$1" =~ "$rport-"* ]];then 
            return ${r_port_table_array[$rport]} 
        fi 
    done 
} 
 
#Get soft SID value 
Get_soft_array_table_sid(){ 
    #First parameter: directory path (absolute path stiffness) 
    for SID in ${!SID_table_array[*]} 
    do 
	if [[ "$1" =~ *"-$SID" ]] || [[ "$1" =~ "$SID-"* ]];then 
            return $SID","${SID_table_array[$SID]} 
        fi 
    done 
} 
 
#start all 
Start_all(){ 
    echo "------------------------------------Begin run all server----------------------------------------" 
    directory_context=$(Get_directory_down_folder $Release_directory)
    for soft_directory in ${directory_context[@]} 
    do 
        echo "----------------------------Run the jar package---------------------------" 
        Release_soft_directory=$Release_directory$soft_directory 
        file_name=$(Get_jar_file_name $Release_soft_directory)
        if [ -d $Release_soft_directory/$file_name ];then 
            echo "---Enter Soft Release directory---" 
            cd $Release_soft_directory 
            echo "Running application:["$file_name"]" 
            r_host=`curl ifconfig.me` 
            echo "This application remote monitoring IP address:["$r_host"]" 
            r_port=$(Get_soft_array_table_rport $soft_directory)
            echo "Remote listening port of this application:["$r_port"]" 
            if [ $soft_directory = "game-ip" || $soft_directory = "game-pay" || \ 
            $soft_directory = "game-promotion" || $soft_directory = "download-server" ];then 
                `nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname="${r_host}" \ 
                -Dcom.sun.management.jmxremote.port="${r_port}" -Dcom.sun.management.jmxremote.authenticate=false \ 
                -Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \ 
                -XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC \ 
                -XX:ParallelCMSThreads=8 -XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled \ 
                -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking \ 
                -XX:CMSInitiatingOccupancyFraction=70 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram \ 
                -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintTenuringDistribution -Xloggc:log/gc.log \ 
                -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m -jar "$file_name" -Dfile.encoding=UTF-8 >log.log 2>&1 &` 
            else 
                SID_info=$(Get_soft_array_table_sid $soft_directory) 
	            NAME=`echo $SID_info | awk '{split($0,arr,",");print arr[1]}'` 
	            SID=`echo $SID_info | awk '{split($0,arr,",");print arr[2]}'` 
	            MAIN="com.lyh.game."$NAME".start.ServerStart" 
                `nohup java -server -Xms1024m -Xmx1024m -Xmn200m -Djava.rmi.server.hostname=${r_host} \ 
                -Dcom.sun.management.jmxremote.port=${r_port} -Dcom.sun.management.jmxremote.authenticate=false \ 
                -Dcom.sun.management.jmxremote.ssl=false -Xss256k -Xnoclassgc -XX:+ExplicitGCInvokesConcurrent \ 
                -XX:+AggressiveOpts -XX:+UseParNewGC -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=8 \ 
                -XX:+UseFastAccessorMethods -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection \ 
                -XX:CMSFullGCsBeforeCompaction=0 -XX:+UseBiasedLocking -XX:CMSInitiatingOccupancyFraction=70 \ 
                -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps \ 
                -XX:+PrintTenuringDistribution -Xloggc:log/gc.log -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m \ 
                -cp $Release_soft_directory/lib/*:$file_name $MAIN ${SID} $Release_soft_directory $Release_soft_directory \ 
                -Dfile.encoding=UTF-8 >log.log 2>&1 &` 
            fi 
        else 
            case $soft_directory in 
                $admin) 
                cd $Release_directory$soft_directory/bin/ 
                ./startup.sh 
                ;; 
                $apk) 
                cd $Release_directory"apk_parser/dist/"  
                ./apk.sh 
                ;; 
                $chat) 
                cd $Release_directory$soft_directory/bin/ 
                ./startup.sh 
                ;; 
            esac 
        fi  
    done 
    Running_java_program  
} 
 
 
 
main(){ 
    if [ ! -e $git_local_repository  -a  ! -e $Release_directory ];then 
        echo $git_local_repository "[error]: Path does not exist" 
    else 
        case ${1} in 
            oko) Git_Repository_Pull_Method 
            shutdown Close_all_services 
	    backup_all_files
            Update_all_files 
            Start_all 
            ;; 
            start) Start_all 
            ;; 
            shutdown) Close_all_services 
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
