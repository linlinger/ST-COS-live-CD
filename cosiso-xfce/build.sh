#!/bin/bash
#author: linlinger
#date 2020 Dec 14th.
#Create a COSiso file

#Checking root status
temp_dir="/home/archiso-tempfiles/xfce"
checkrootstatus(){
if [ $(id -u) != "0" ];
then
	echo "Root permission is required to build archiso.Please re-run this script use sudo."
	exit 1
fi
}
#Empty work directory before proceed
cleanup() {
[[ -d ./work ]] && rm -r ./work
[[ -d ./out ]] && rm -r ./out
sleep 2
}
#add calamares (The installer) to the system repo and copy files
addezrepo () {
cp /etc/pacman.conf /etc/pacman.conf.prev
echo "# Temporarily add installer repo.
[repo]
SigLevel = Optional TrustAll
Server = file:///opt/ezrepo" >> /etc/pacman.conf
pacman -Sy
}
cpezrepo () {
cp -r ./opt/ezrepo /opt/
}
#when installation done. Remove the repo
rmezrepo () {
rm -r /opt/ezRepo
}
# Restore original pacman.conf
mvpacmanconf () {
mv /etc/pacman.conf.prev /etc/pacman.conf
}

# Remove systemd-networkd
rmnetworkd () {
[[ -d ./airootfs/etc/systemd/network ]] && rm -r ./airootfs/etc/systemd/network
[[ -d ./airootfs/etc/systemd/system/systemd-networkd-wait-online.service.d ]] && rm -r ./airootfs/etc/systemd/system/systemd-networkd-wait-online.service.d
[[ -f ./airootfs/etc/systemd/system/dbus-org.freedesktop.network1.service ]] && rm ./airootfs/etc/systemd/system/dbus-org.freedesktop.network1.service
[[ -f ./airootfs/etc/systemd/system/multi-user.target.wants/systemd-networkd.service ]] && rm ./airootfs/etc/systemd/system/multi-user.target.wants/systemd-networkd.service
[[ -f ./airootfs/etc/systemd/system/multi-user.target.wants/iwd.service ]] && rm ./airootfs/etc/systemd/system/multi-user.target.wants/iwd.service
[[ -f ./airootfs/etc/systemd/system/sockets.target.wants/systemd-networkd.socket ]] && rm ./airootfs/etc/systemd/system/sockets.target.wants/systemd-networkd.socket
[[ -f ./airootfs/etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service ]] && rm ./airootfs/etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service
}

# Add NetworkManager, localegen, lightdm, & haveged systemd links
addnmlinks () {
[[ ! -d ./airootfs/etc/systemd/system/sysinit.target.wants ]] && mkdir -p ./airootfs/etc/systemd/system/sysinit.target.wants
[[ ! -d ./airootfs/etc/systemd/system/network-online.target.wants ]] && mkdir -p ./airootfs/etc/systemd/system/network-online.target.wants
[[ ! -d ./airootfs/etc/systemd/system/multi-user.target.wants ]] && mkdir -p ./airootfs/etc/systemd/system/multi-user.target.wants
ln -sf /usr/lib/systemd/system/NetworkManager-wait-online.service ./airootfs/etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service
ln -sf /usr/lib/systemd/system/NetworkManager.service ./airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service
ln -sf /usr/lib/systemd/system/NetworkManager-dispatcher.service ./airootfs/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
ln -sf /usr/lib/systemd/system/localegen.service ./airootfs/etc/systemd/system/multi-user.target.wants/localegen.service
ln -sf /usr/lib/systemd/system/lightdm.service ./airootfs/etc/systemd/system/display-manager.service
ln -sf /usr/lib/systemd/system/haveged.service ./airootfs/etc/systemd/system/sysinit.target.wants/haveged.service
}

# Delete customize_airootfs.sh, it's not needed anymore.
rmcustairoot () {
[[ -f ./airootfs/root/customize_airootfs.sh ]] && rm ./airootfs/root/customize_airootfs.sh
}

# Set hostname
sethostname () {
echo "cos" > ./airootfs/etc/hostname
}

# Set username, user password and root password
setpasswd () {
usr_name="cos"
usr_pass="cos"
root_pass="root"
}

# Create passwd file
crtpasswd () {
echo "root:x:0:0:root:/root:/usr/bin/bash
${usr_name}:x:1010:1010::/home/${usr_name}:/bin/bash" > ./airootfs/etc/passwd
}

# Create group file
crtgroup () {
echo "root:x:0:root
sys:x:3:${usr_name}
adm:x:4:${usr_name}
wheel:x:10:${usr_name}
log:x:19:${usr_name}
network:x:90:${usr_name}
floppy:x:94:${usr_name}
scanner:x:96:${usr_name}
power:x:98:${usr_name}
rfkill:x:850:${usr_name}
users:x:985:${usr_name}
video:x:860:${usr_name}
storage:x:870:${usr_name}
optical:x:880:${usr_name}
lp:x:840:${usr_name}
audio:x:890:${usr_name}
${usr_name}:x:1010:" > ./airootfs/etc/group
}

# Create shadow file
crtshadow () {
usr_hash=$(openssl passwd -6 "${usr_pass}")
root_hash=$(openssl passwd -6 "${root_pass}")
echo "root:${root_hash}:14871::::::
${usr_name}:${usr_hash}:14871::::::" > ./airootfs/etc/shadow
}

# create gshadow file
crtgshadow () {
echo "root:!!::root
${usr_name}:!!::" > ./airootfs/etc/gshadow
}

# Set the keyboard layout
setkeylayout () {
echo "KEYMAP=us" > ./airootfs/etc/vconsole.conf
}

# Create 00-keyboard.conf file
crtkeyboard () {
mkdir -p ./airootfs/etc/X11/xorg.conf.d
echo "Section \"InputClass\"
        Identifier \"system-keyboard\"
        MatchIsKeyboard \"on\"
        Option \"XkbLayout\" \"us\"
        Option \"XkbModel\" \"pc105\"
EndSection" > ./airootfs/etc/X11/xorg.conf.d/00-keyboard.conf
}

# Create locale.conf file
crtlocalec () {
echo "LANG=en_US.UTF-8" > ./airootfs/etc/locale.conf
}

# Generate mirrorlist
mkmirrorlist () {
echo "Generating mirrorlist, please be patient..."
mkdir -p ./airootfs/etc/pacman.d
reflector --age 3 --protocol https --save ./airootfs/etc/pacman.d/mirrorlist
sleep 2
}
mkiso(){
mkarchiso -v -w ./work -o ./out ./
}

checkrootstatus
cleanup
addnmlinks
cpezrepo
addezrepo
rmnetworkd
rmcustairoot
sethostname
setpasswd
crtpasswd
crtgroup
crtshadow
crtgshadow
setkeylayout
crtkeyboard
crtlocalec
mkmirrorlist
runmkarchiso
sleep 3
rmezrepo
mvpacmanconf
