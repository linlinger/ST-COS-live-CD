#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="COS"
iso_label="ARCH_$(date +%Y%m)"
iso_publisher="COS Linux <https://www.stp.net.cn>"
iso_application="COS Linux Live/Rescue CD"
iso_version="$(date +%Y.%m.%d)"
install_dir="COS-xfce"
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  #user-added packages
  ["/etc/shadow"]="0:0:0400"
  ["/etc/gshadow"]="0:0:0400"
  #Sample to add files
  #[""]=""
  ["/etc/skel"]="0:0:755"
  ["/etc/skel/.zprofile"]="0:0:644"
)
