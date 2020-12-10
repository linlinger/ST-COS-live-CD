#!/bin/bash
#author: linlinger
#date 2020 Dec 10th.

#validating user has root permission or not.

temp_dir = /home/archiso-tempfiles
if [ $(id -u) != "0" ];
then
	echo "Root permission is required to build archiso.Please re-run this script use sudo."
	exit 1
fi
#Creating archiso tempory directory
if [ ! -d $temp_dir ];
then
	mkdir $temp_dir
	#Granting permission
	chmod  -r 755 $temp_dir
else
	echo "Temp directory exists.Skipping......"

fi
echo "Before we start. Please make sure you have an active internet connection.Press any key to continue or Ctrl+C to abort"
read

#command used for making archiso -v means verbose -w specifing a working directory.For more usage please read mkarchiso help.
mkarchiso -v -w /home/archiso-tempfiles ./



