#!/usr/bin/bash

xkeysnail="/etc/systemd/system/xkeysnail.service"
[ -f "$xkeysnail" ] || cp /home/my_usr/python/site-packages/xkeysnail/xkeysnail.service "$xkeysnail" && systemctl enable xkeysnail.service

if [ "$(systemctl is-enabled systemd-timesyncd.service)" == "disabled" ]; then
    systemctl enable systemd-timesyncd.service
    # timedatectl set-ntp true 
    # timedatectl status
fi

