# Creating ArchISO   

##Before reading this . It's recommended to download this and view using an text editor
## Steps

1) Installing archiso by sudo pacman -S archiso   
2) when installation is done,create a directory to store archiso configuration files. I will use a directory called /home/archiso to store archiso  configuration files . use cp -r /usr/share/archiso/configs/releng/* /home/archiso   
When copying is completed. please type ls to make sure the following directory or file exists   
	1. airootfs. The root directory of the archiso Contains some directories including etc root and usr.    
	2. efiboot. used for bootloader. No modification required at this moment.   
	3. packages.x86_64 Packages will be installed in archiso.   
	4. pacman.conf configuration file for pacman    
	5. profilrdef.sh info of the archiso and file and directory permissions   
	6. syslinux files used for boot up.   
3) Editing packages.x86_64   
Use a text editor to open the file.   
It‘s strongly recommanded to comment a package named dhcpcd. If you're using wifi this will cause errors   
Go to the bottom of the file.You can add packages you like.Here I will use plasma + sddm for display manager and desktop.   
Bottom of the file
......   
......   
 #User added packages
 

 #networking packages
dhclient #used for dhcp   
networkmanager   
 #display drivers
xf86-video-mesa 	#generic video driver   
xf86-video-intel 	#intel IGPU video driver   
xf86-video-amdgpu 	#video driver for amd graphics   
xf86-video-ati 		#video driver for ati graphics   
xf86-video-vmware 	# video driver for vmware virtual GPU   
 #Desktop enverioment   
xorg 				#X-server provider   
plasa 				#desktop based on kde   
sddm 				#simple display manager   
 #utilities   
kate 				#text editor   
vim 				#text editor in commandline   
vlc 				#media player   
dolphin 			#file manager   
ark  				#archive utility   
firefox 			#a web browser   
 #terminals   
konsole 			#a terminal in kde   
yakuake 			#a drop-down terminal   
 #fonts   
wqy-zenhei 			#a font supports Chinese.    
 #Add more packages as you want

when you finish editing the file. Save your changes.
4) Add A user


Quote archiso  from arch wiki   

3) Users and passwords

Creating a live session user is always recommended
To create a user which will be available in the live environment, you must manually edit archlive/airootfs/etc/passwd, archlive/airootfs/etc/shadow, archlive/airootfs/etc/group and archlive/airootfs/etc/gshadow.
Note: If these files exist, they must contain the root user and group.

For example, to add a user archie. Add them to archlive/airootfs/etc/passwd following the passwd(5) syntax:

archlive/airootfs/etc/passwd   
root:x:0:0:root:/root:/usr/bin/zsh      
archie:x:1000:1000::/home/archie:/usr/bin/zsh       

Generate a password hash with openssl passwd -6 and add it to archlive/airootfs/etc/shadow following the syntax of shadow(5). For example:

archlive/airootfs/etc/shadow   
root::14871::::::   
archie:$6$archiesalt$1yystReWRMUYWmt7fTR/BjcRWrmF//984HxCL6QxCMeDes0pEBRG3v1Jyqp1I1/x46kmU7KyjDfTXikqtq3YY.:14871::::::   

Add the user's group and the groups which they will part of to archlive/airootfs/etc/group according to group. For example:

archlive/airootfs/etc/group   
root:x:0:root   
adm:x:4:archie   
wheel:x:10:archie   
uucp:x:14:archie   
archie:x:1000:   

Create the appropriate archlive/airootfs/etc/gshadow according to gshadow:

archlive/airootfs/etc/gshadow

root:!*::root   
archie:!*::   

Make sure /etc/shadow and /etc/gshadow have the correct permissions:   
archlive/profiledef.sh   

...
file_permissions=(
  ...
  ["/etc/shadow"]="0:0:0400"
  ["/etc/gshadow"]="0:0:0400"
)

After package installation, mkarchiso will create all specified home directories for users listed in archlive/airootfs/etc/passwd and copy work_directory/x86_64/airootfs/etc/skel/* to them. The copied files will have proper user and group ownership.


##Changing automatic login

The configuration for getty's automatic login is located under airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf.

You can modify this file to change the auto login user:

[Service]   
ExecStart=   
ExecStart=-/sbin/agetty --autologin username --noclear %I 38400 linux   

Or remove it altogether to disable auto login.    

4)Burning the iso    
type sudo mkarchiso -v -w /path/to/work_dir -o /path/to/out_dir /path/to/profile/



Huge Thanks to Arch Linux and Arch Wiki
