#!/usr/bin/python3
# _*_coding:utf8_*_

import urllib3,time,pygame


while True:
    req=urllib3.PoolManager()
    time.sleep(3)
    try:
        os_obj=req.request('GET',"http://www.hzqp777.com",timeout=10.0)
        data=os_obj._body.decode()
        if "https://js.users.51.la/19834087.js" in data:
            file="/home/devops/data/bash-shell/python-py/5051.wav"
            pygame.mixer.init()
            track = pygame.mixer.music.load(file)
            pygame.mixer.music.play()
            time.sleep(3)
            pygame.mixer.music.stop()
            print ("被攻击了")
        else:
            print("0")
    except Exception as e:
        errorfile="/home/devops/data/bash-shell/python-py/5051.wav"
        pygame.mixer.init()
        trackf = pygame.mixer.music.load(errorfile)
        pygame.mixer.music.play()
        time.sleep(1)
        pygame.mixer.music.stop()
        print("程序出错了%s"%e)