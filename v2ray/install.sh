#!/bin/bash

#Origin source is located at github.com/Resol1024/Scripts/v2ray/install.sh
#This script is design for ubuntu 20.04 x86 in vultr to install v2ray

#arguments
V2RAY_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh"
V2RAY_CONFIG_FILE_URL="https://raw.githubusercontent.com/Resol1024/Scripts/master/v2ray/config.json"

exit_with_msg_if_last_comand_failed(){
  if [ $? -ne 0 ]; then
    echo $1
    exit 1
  fi
}

#install v2ray
wget -O v2ray_origin_install.sh $V2RAY_INSTALL_SCRIPT_URL
exit_with_msg_if_last_comand_failed "failed to download v2ray install script"
bash v2ray_origin_install.sh
exit_with_msg_if_last_comand_failed "failed to install v2ray"
rm v2ray_origin_install.sh

#config v2ray
wget -O config.json $V2RAY_CONFIG_FILE_URL
exit_with_msg_if_last_comand_failed "failed to download v2ray config"
cp -f config.json /etc/v2ray/config.json
rm config.json

#enable BBR
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

#start v2ray service
systemctl start v2ray

#automatic starting
touch /etc/init.d/start_v2ray.sh
echo "systemctl start v2ray" > /etc/init.d/start_v2ray.sh
chmod 755 /etc/init.d/start_v2ray.sh
cd /etc/init.d
update-rc.d start_v2ray.sh defaults 100
exit_with_msg_if_last_comand_failed "failed to set automatic starting"

echo "installing completed"
