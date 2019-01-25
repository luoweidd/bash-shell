#!/bin/bash
#author:luowei
#Email:3245554@qq.com/luowei.l.v@gmail.com/jeak_2003_@hotmail.com
#datatime:2019-1-23 09:49

# Release directory
Release_directory=/opt/new_project/
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
yum_nginx_file_folder=/usr/share/nginx/html
make_nginx_file_folder=/usr/local/nginx/html

declare -A r_port_table_array
declare -A SID_table_array
#Define an r_port array table
r_port_table_array=([center]=50001 \
[db]=50002 \
[baccara]=50003 \
[bullfight]=50004 \
[classicLandords]=50005 \
[cqeverycolor]=50006 \
[cqssc]=50007 \
[dragontiger]=50008 \
[fores]=50009 \
[fruit-machine]=50010 \
[gemstorm]=50011 \
[glodflower]=50012 \
[goodstart]=50013 \
[texas-poker]=50014 \
[gragontiles]=50015 \
[red-black]=50016 \
[robtaurus]=50017 \
[gate]=50018 \
[hall]=50019 \
[log]=50020 \
[login]=50021 \
[download]=50022 \
[ip]=50023 \
[pay]=50024 \
[promotion]=50025 \
[turntaurus]=50026 )
#Define an SID array table
SID_table_array=([fores]=2106 \
[bullfight]=2105 \
[glodflower]=2101 \
[red-black]=2102 \
[robtaurus]=2112 \
[classicLandords]=2100 \
[baccara]=2103 \
[texas-poker]=2104 \
[gemstorm]=2113 \
[dragontiger]=2108 \
[turntaurus]=2109 \
[fruit-machine]=2107 \
[gragontiles]=2111 \
[goodstart]=2110 \
[cqssc]=2114 \
[cqeverycolor]=2117 \
[log]=6100 \
[db]=8100 \
[hall]=3100 \
[login]=4100 \
[center]=9100 \
[gate]=1100 )


#Get the git repository to get the latest update package
Git_Repository_Pull_Method(){
    echo "----------------------Get the git repository to get the latest update package---------------------"
    directory_context=Get_directory_down_folder $git_local_repository
    if [ ${#directory_context[@]} -gt 0 ];then
        for directory in ${directory_context[@]}
        do
            cd $Release_directory$directory
            echo "---Enter the "$Release_directory$directory" directory---"
            echo "---------------Begin pulling "$directory" repository data--------------"
            git pull
            echo $Release_directory$directory "--------------->> Pull complete, the top is the pull data result information."
        done
    else
        echo $git_local_repository "[error]：There are no folders in the directory！"
    fi

}

# Gets the names of all folders in the publish directory
Get_directory_down_folder(){
    #First parameter: directory path (absolute path stiffness)
    if [ ! -e $1 ];then
        echo "[error]:$1 -> Path does not exist"
    else
        return `ls -l $1 |awk '/^d/ {print $NF}'`
    fi
}

#Get jar pacakge file name
Get_jar_file_name(){
    #First parameter: directory path (absolute path stiffness)
    if [ ! -e $1 ];then
        echo "[error]:$1 -> Path does not exist"
    else
        return `ls -l $1 |awk '/^-/ {print $NF}|grep *.jar'`
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

#Get Release directory folder
Get_Release_directory_folder(){
    return Get_dirrectory_down_folder $Release_directory
}
#Get git directory folder
Get_local_git_repository_folder(){
    return Get_dirrectory_down_folder $git_local_repository
}

#Close all services
Close_all_services(){
    directory_context=Get_Release_directory_folder
    if [ ${#directory_context[@]} -gt 0 ];then
        for soft_keyword in ${directory_context[@]}
        do
            ps -aux|grep $soft_keyword |grep -v grep|cut -c 9-15|xargs kill -9
        done
    else
        echo $git_local_repository "[error]：There are no folders in the directory！"   
        Running_java_program
    fi
}

#Nginx static files are copies, not moves
backup_nginx_file(){
    if [ -e $yum_nginx_file_folder ];then
        if [ -e /opt/$folder ];then
            `mkdir $backup_time
            `cp -arf $yum_nginx_file_folder $folder/$backup_time/`
        else
            `mkdir /opt/$folder`
            `mkdir /opt/$folder/$backup_time`
            `cp -arf $yum_nginx_file_folder $folder/$backup_time/`
        fi
    elif [ -e $make_nginx_file_folder ];then
        if [ -e /opt/$folder ];then
            `cd /opt/$folder`
            `mkdir $backup_time
            `cp -arf $yum_nginx_file_folder $folder/$backup_time/`
        else
            `mkdir /opt/$folder`
            `mkdir /opt/$folder/$backup_time`
            `cp -arf $yum_nginx_file_folder $folder/$backup_time/`
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
        elif [ ! -e $folder/$backup_time ];then
                `mkdir $folder/$backup_time`
        fi
        backup_directory=/opt/$folder/$backup_time
        directory_context=Get_Release_directory_folder
        for soft_folder in ${directory_context[@]}
        do
            if [ $soft_folder != "download" ];then
                if [ $soft_folder = $admin ];then
                    `mv $Release_directory$soft_folder/webapps/* $backup_directory/`
                elif[ $soft_folder = $chat ];then
                    `mv $Release_directory$soft_folder/webapps/* $backup_directory/`
                else
                    `mv $Release_directory$soft_folder $backup_directory/`
            fi
        done
    fi
    backup_nginx_file
}

update_nginx_static_file(){
    echo "---Start the nginx update operation---"
    if [ -e $yum_nginx_file_folder ]
        cp -arf $1 $yum_nginx_file_folder/
        echo "${##/*} update completed, Update information:"
        ls -l $yum_nginx_file_folder
    elif [ -e $make_nginx_file_folder ]
        cp -arf $1 $make_nginx_file_folder
        echo "${##/*} update completed, Update information:"
        ls -l $yum_nginx_file_folder
    else
        echo "There is no nginx application service in this server"
    fi
}

#update all 
Update_all_files(){
    echo "------------------------------------Begin updating all files from your local git repository----------------------------------------"
    echo "---Start the backup operation---"
    backup_all_files
    echo "---The backup operation completes---"
    echo "---Copy new files to directory---"
    directory_context=Get_local_git_repository_folder
    if [ ${#directory_context[*]} -gt 0 ]
        for directory in ${directory_context[@]}
        do
            echo "local repository name:["$directory"]"
            #Local application repository directory
            local_soft_repository_directory=$Get_local_git_repository_folder$directory 
            local_repository_soft_folders=Get_directory_down_folder $local_repository_soft_directory
            for soft_directory in ${local_repository_soft_folders[@]}
            do
                if [ $soft_directory = $admin || $soft_directory = $chat ];then
                    cp -arf $local_soft_repository_directory/$soft_directory $Release_directory/$soft_directory/webapps/
                    echo "Tomcat application ["$soft_directory"] is even more complete"
                    echo "Update the result information:"
                    `ls -l $Release_directory/$soft_directory/webapps/`
                elif [ $soft_directory = "web" || $soft_directory = "agent" || $soft_directory = "agentWeb" ];then ]
                    update_nginx_static_file $local_soft_repository_directory/$soft_directory
                else
                    cp -arf $local_soft_repository_directory/$soft_directory $Release_directory
                fi
        done
        echo "---All application updates completed---"
    else
        echo "[error:]There is no content in the warehouse" 
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
    directory_context=Get_Release_directory_folder
    for soft_directory in ${directory_context[@]}
    do
        echo "----------------------------Run the jar package---------------------------"
        Release_soft_directory=$Release_directory$soft_directory
        file_name=Get_jar_file_name $Release_soft_directory 
        if [ -d $Release_soft_directory/$file_name ];then
            echo "---Enter Soft Release directory---"
            cd $Release_soft_directory
            echo "Running application:["$file_name"]"
            r_host=`curl ifconfig.me`
            echo "This application remote monitoring IP address:["$r_host"]"
            r_port=Get_soft_array_table_rport $soft_directory
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
                SID_info=Get_soft_array_table_sid $soft_directory
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
            Update_all_files
            Start_all
            ;;
            start) Start_all
            ;;
            shutdown) Close_all_services
            ;;
            update) Git_Repository_Pull_Method
            Update_all_files
            ;;
            *) echo "
            To run the script, you need to add the run parameter, example:./ (script file name. Sh) parameter
                Parameters are:
                oko                 One-click operation, including pulling git repository, closing service, 
                                    updating service file and running service.The run order is pull, close, update, start.
                Start               Start to run all services
                Shutdown            Shutdown shuts down all running services
                Update              Update all services (force update, overwrite original files directly, have separate backup: backup directory)
            "
            ;;
        esac
    fi
}

main $1
