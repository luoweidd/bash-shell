#!/usr/bin/python3
# _*_coding:utf8_*_

import urllib3,time,pygame,_thread

def reques_url(number):
    while True:
        try:
            number = urllib3.PoolManager()
            print("run start%s"%number)
            os_obj=number.request('GET',"https://66660162.kutoucf.com/",timeout=10.0)
            #data=os_obj._body.decode()
            #print(data)
            # if "https://js.users.51.la/19834087.js" in data:
            #     file="/home/devops/data/bash-shell/python-py/5051.wav"
            #     pygame.mixer.init()
            #     track = pygame.mixer.music.load(file)
            #     pygame.mixer.music.play()
            #     time.sleep(3)
            #     pygame.mixer.music.stop()
            #     print ("被攻击了")
            # else:
            #     print("0")
        except Exception as e:
            # errorfile="/home/devops/data/bash-shell/python-py/5051.wav"
            # pygame.mixer.init()
            # trackf = pygame.mixer.music.load(errorfile)
            # pygame.mixer.music.play()
            # time.sleep(1)
            # pygame.mixer.music.stop()
            print("程序出错了%s"%e)

if __name__ == "__main__":
    number=100000000
    for i in range(number):
        thread=_thread.start_new_thread(reques_url,('thread%d'%i,))
