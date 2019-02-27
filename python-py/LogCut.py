#!/bin/python _*_coding:utf8_*_

import datetime

class LogCut:

    def __init__(self,logfile):
        self.logfile=logfile

    def getfilepath(self):
        if self.logfile:
            return self.logfile
        else:
            timenow=datetime.datetime.utcnow()
            print("%s ERROR:Don't file!" %timenow)

    def openfile(self):
        pass





if __name__=='__main__':

    logfile="/home/devops/Download/f-log.txt"
    obj=LogCut(logfile)