#!/bin/python _*_coding:utf8_*_

import sys

class LineCharacterContrast:
	def __init__(self,source_file_path,contrast_file_path):
		self.source_file_path=source_file_path
		self.contrast_file_path=contrast_file_path

	def readfile(self,path):
		readline=open(path,'rw')
		read_dict=readline.readlines()
		readline.close()
		return read_dict
	def contrast(self):
		source_file_data=self.readfile(self.source_file_path)
		contrast_file_data=self.readfile(self.contrast_file_path)
		for data in source_file_data:
			if data not in contrast_file_data:
				string=data.replace("\n","")
				print string
				#print "%s ——不在———%s 文件中"%(data,self.contrast_file_path)

if __name__ == "__main__":
	print "arg 1 :source file path" \
		  "arg 2 :contrast file path" \
		  "Verify that the row data in the parameter 1 file is in the parameter 2 file or printed out if it does not exist."
	source_file_path='/home/devops/rpm.txt'  #sys.argv[1]
	contrast_file_path='/home/devops/localhost_rpm.txt'  #sys.argv[2]
	old_data_object=LineCharacterContrast(source_file_path,contrast_file_path).contrast()

