#!/usr/bin/python3
# _*_coding:utf8_*_

'''
 * Created with IntelliJ Pycharm.
 * Description: 
 * Author <a href="mailto:3245554@qq.com">罗卫</a>
 * User: devops
 * Date: 2019-05-05
 * Time: 下午7:24
'''

import os,json

cmd=os.popen("""netstat -atnlp|grep LISTEN|awk '{print $4}'""")
cmdresutl=cmd.readlines()
port_list=[]
for i in cmdresutl:
    n_port=i.replace("\n","").split(":")
    if n_port[1] is not "":
        port_list.append(n_port[1])
    elif n_port[3] is not "":
        port_list.append(n_port[3])
    else:
        print "not port"
port_list2=sorted(set(port_list),key=port_list.index)
port_list=[]
for port in port_list2:
    port_list.append({"#TCP_PORT":int(port)})
port_dict={"date":port_list}
port_dict=json.dumps(port_dict)
print port_dict