#!/usr/bin/python3
# _*_coding:utf8_*_

'''
 * Created with IntelliJ Pycharm.
 * Description: 
 * Author <a href="mailto:3245554@qq.com">罗卫</a>
 * User: devops
 * Date: 2019-04-11
 * Time: 下午6:25
'''

import pcap,time,dpkt,requests,re,threading,socket
from apscheduler.schedulers.blocking import BlockingScheduler

class myThread (threading.Thread):
    def __init__(self, threadID, name, func):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.func = func
    def run_seconds(self,args,seconds):
        jobs=BlockingScheduler()
        jobs.add_job(self.func, 'interval', seconds=seconds, args=args)
        jobs.start()

    def run_hours(self,hours):
        jobs=BlockingScheduler()
        jobs.add_job(self.func, 'interval', hours=hours)
        jobs.start()


def mac_addr(mac):
    return '%02x:%02x:%02x:%02x:%02x:%02x'%tuple(mac)

def ip_addr(ip):
    return '%d.%d.%d.%d'%tuple(ip)

def captcap():
    starttime=time.time()
    print(starttime)
    cap=pcap.pcap("enp2s0")
    cap.setfilter('tcp')
    if cap != None:
        for date,data in cap:
            date=time.strftime('%Y-%m-%d %H:%M:%s',time.localtime(date))
            _datas=(dpkt.ethernet.Ethernet(data))
            #网络层-Network,数据链路层-Data Link
            _dst_mac=mac_addr(_datas.dst)
            _src_mac=mac_addr(_datas.src)
            #传输层-Transport
            IP_data=_datas.ip
            _dst_ip=ip_addr(IP_data.dst)
            _src_ip=ip_addr(IP_data.src)
            _len=IP_data.len
            _protocol_version=IP_data.v
            #应用层-Application
            TCP_data=IP_data.data
            _dst_port=TCP_data.dport
            _src_port=TCP_data.sport
            _seq=TCP_data.seq
            _ack=TCP_data.ack
            _win=TCP_data.win
            _data=TCP_data.data
            result_data =_data.decode("utf8","ignore")
            noepacke = ("%s SRC_IP: %s<SRC_MAC:%s>:%s-->DST_IP: %s<DST_MAC:%s>:%s [seq:%s ack:%s win:%s] data:%s"%(date,_src_ip,_src_mac,_src_port,_dst_ip,_dst_mac,_dst_port,_seq,_ack,_win,result_data))
            print(noepacke)
            Total_package={"date":date,"src_ip":_src_ip,"src_port":_src_port,"dst_ip":_dst_ip,"dst_port":_dst_port}


    else:
        print("None")

def get_ip_by_ip138():
    response = requests.get("http://2017.ip138.com/ic.asp")
    ip = re.search(r"\[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\]",response.content.decode(errors='ignore')).group(0)
    return ip
def get_lan_ip():
    return socket.gethostbyname(socket.gethostname())

def Filter(kargs):
    myintnetip = get_ip_by_ip138()
    mylanip = get_lan_ip()
    packge = []
    for pack in kargs:
        if pack["src_ip"] != myintnetip and pack["src_ip"] !=mylanip:
            packge.append(pack)

    return packge

def cuntpack(packge):
    timeunit = 1
    unitpacke = 300
    prohibitionunit = 12

    maliciousip =

def firewallipprohibition():
    pass


def firewallipunprohibition():
    pass

def firewallunprohibitiontask():
    thread=myThread("thread-1", "firewall unprohibition", firewallipunprohibition)
    thread.run_12hours()

def Grabbagthread():
    captcap()





if __name__ == '__main__':
# 单ip每秒超过300包ip封禁12小时自动解
    captcap()
    firewallunprohibitiontask()