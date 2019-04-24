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

import pcap,time,dpkt,requests,re,threading,socket,subprocess,logging,redis
from apscheduler.schedulers.blocking import BlockingScheduler

log=logging
log.basicConfig(
    level="DEBUG",
    format="%(asctime)s - %(levelname)s - %(pathname)s -> %(funcName)s [line:%(lineno)d]  - %(message)s",
    #datafmt="%Y-%d-%m %H:%M:%S",
    filename="ddos_defense.log",
    filemode='a'
)

redis_pool=redis.ConnectionPool(host="127.0.0.1",max_connections=1024, password="qwe123e", port=6379, db=10)
redis_cur=redis.Redis(connection_pool=redis_pool)

class myThread (threading.Thread):
    def __init__(self, threadID, name, func):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.func = func
    def run_seconds(self,args,time):
        jobs=BlockingScheduler()
        jobs.add_job(self.func, 'interval', args=args, seconds=time)
        print(jobs)
        jobs.start()

    def run_hours(self,time):
        jobs=BlockingScheduler()
        jobs.add_job(self.func, 'interval', hours=time)
        jobs.start()

class ipSunetRoute(object):

    ##将IP地址转为二进制
    def ipToBinary(self, ip):
        '''ip address transformat into binary
        Argv:
            ip: ip address
        Return:
            binary
        '''
        ip_num = ip.split('.')
        x = 0

        ##IP地址是点分十进制，例如：192.168.1.33，共32bit
        ##第1节（192）向前移24位，第2节（168）向前移16位
        ##第3节（1）向迁移8位，第4节（33）不动
        ##然后进行或运算，得出数据
        for i in range(len(ip_num)):
            num = int(ip_num[i]) << (24 - i * 8)
            x = x | num

        brnary = str(bin(x).replace('0b', ''))
        return brnary

    ##将子网掩码转为二进制
    def maskToBinary(self, mask):
        '''netmask change, example: 24 or 255.255.255.0 change binary
        Argv:
            mask: netmask, example:24 or 255.255.255.0
        Return:
            binary
        '''
        mask_list = str(mask).split('.')

        ##子网掩码有两种表现形式，例如：/24或255.255.255.0
        if len(mask_list) == 1:
            ##生成一个32个元素均是0的列表
            binary32 = []
            for i in range(32):
                binary32.append('0')

            ##多少位子网掩码就是连续多少个1
            for i in range(int(mask)):
                binary32[i] = '1'

            binary = ''.join(binary32)

        ##输入的子网掩码是255.255.255.0这种点分十进制格式
        elif len(mask_list) == 4:
            binary = self.ipToBinary(mask)

        return binary

    ##判断IP地址是否属于这个网段
    def ipInSubnet(self, ip, subnet):
        '''
        Argv:
            ip: ip address,example:1.1.1.1
            subnet: subnet,example:1.1.1.0/24,or 1.1.1.0/255.255.255.0
        Return:
            False or True
        '''
        subnet_list = subnet.split('/')
        networt_add = subnet_list[0]
        network_mask = subnet_list[1]

        ##原来的得出的二进制数据类型是str，转换数据类型
        ip_num = int(self.ipToBinary(ip), 2)
        subnet_num = int(self.ipToBinary(networt_add), 2)
        mask_bin = int(self.maskToBinary(network_mask), 2)

        ##IP和掩码与运算后比较
        if (ip_num & mask_bin) == (subnet_num & mask_bin):
            return True
        else:
            return False

ipsub=ipSunetRoute()
def mac_addr(mac):
    return '%02x:%02x:%02x:%02x:%02x:%02x'%tuple(mac)

def ip_addr(ip):
    return '%d.%d.%d.%d'%tuple(ip)

def transformattime(tim):
    date = time.strftime('%Y-%m-%d %H:%M:%S', tim)
    return date
def transformattim(tim):
    date =time.strftime('%Y-%m-%d %H:%M:%s', tim)
    return date

def captcap():
    starttime=time.time()
    pack=[]
    cap=pcap.pcap("enp2s0")
    cap.setfilter('tcp')
    if cap != None:
        for date,data in cap:
            date=transformattime(time.localtime(date))
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
            log.info(noepacke)
            if str(_src_ip) != str(get_lan_ip()) and ipsub.ipInSubnet(_src_ip,"%s:255.255.255.0"%get_lan_ip()):
                redis_cur.set(str(date), str(_src_ip),ex=10)
    else:
        log.error("not packt ,now None")

def get_ip_by_ifconfig():
    response = requests.get("http://ifconfig.me")
    return response.text
def get_lan_ip():
    return socket.gethostbyname(socket.gethostname())


def FilterIp(iplist):
    packge = []
    for ip in iplist:
        if ip != get_ip_by_ifconfig() and ip !=get_lan_ip() and ipsub.ipInSubnet(ip,get_lan_ip()):
            packge.append(ip)
    return packge

def conut(args):
    conut=args.count()
    return conut


def firewallipprohibition(threshold):
    tim=transformattime(time.time())
    iplist=redis_cur.mget()
    ips=FilterIp(iplist)
    ips=conut(ips)
    for ip in ips:
        cmd="firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=%s reject'"%ip
        cmdresult=subprocess.getoutput(cmd)
        log.warning(cmdresult)

def firewallipprohibitionlist(args):
    log.info("get malicious ip ")
    cmdresult=subprocess.getoutput("firewall-cmd --list-all")
    log.info(cmdresult)
    tmp=cmdresult.split("\n")
    temp = []
    tmp_list = []
    tow_tmp_list = []
    for i in tmp:
        if re.match(r'^  ',i):
            tmp_list.append(i.lstrip(" "))
        elif re.match(r'^\t',i):
            tow_tmp_list.append(i.replace("\t",""))
        else:
           temp.append("{%s}"%i)
    print(temp)
    print(args)

def firewallipunprohibition():
    pass

def firewalldstatuschcek():
    return subprocess.getoutput("firewall-cmd --state")

def firewalldstart():
    return subprocess.getoutput("systemctl start firewalld")

def firewalldreload():
    return subprocess.getoutput("firewall-cmd --reload")

def lookregion():
    return subprocess.getoutput("firewall-cmd --get-active-zones")



if __name__ == '__main__':
# 单ip每秒超过300包ip封禁12小时自动解
    Forbidden_threshold = 300
    thread1=myThread(1,"cappack",captcap)
    thread1.run_seconds("",0)
    thread2 = myThread(2, "firewall-add", firewallipprohibition)
    thread2.run_seconds(2, Forbidden_threshold, 0)
#   thread3=myThread(3,"firewall-remove",firewallipunprohibition)
#   thread3.run_hours(12)
    thread1.start()
    thread1.join()
    thread2.start()
    thread2.join()
#   thread3.start()