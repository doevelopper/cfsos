#!/bin/sh

set -u
set -e

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
# systemd doesn't use /etc/inittab, enable getty.tty1.service instead
elif [ -d ${TARGET_DIR}/etc/systemd ]; then
    mkdir -p "${TARGET_DIR}/etc/systemd/system/getty.target.wants"
    ln -sf /lib/systemd/system/getty@.service \
       "${TARGET_DIR}/etc/systemd/system/getty.target.wants/getty@tty1.service"
fi

# sed -i "s|<YOUR_SSID>|$ssid|g" ${TARGET_DIR}/etc/wpa_supplicant.conf
# sed -i "s|<YOUR_PSK>|$psk|g" ${TARGET_DIR}/etc/wpa_supplicant.conf

# Change profile to print path
sed -i '/export PS1='"'"'\# '"'"'.*/c\
		export PS1="\\\`if \[\[ \\\$? = "0" ]]; then echo '"'"'\\e\[32m\\h\\e\[0m'"'"'; else echo '"'"'\\e\[31m\\h\\e\[0m'"'"' ; fi\\\`:\\\w\\\# "' ${TARGET_DIR}/etc/profile

sed -i '/export PS1='"'"'\$ '"'"'.*/c\
		export PS1="\\\`if \[\[ \\\$? = "0" ]]; then echo '"'"'\\e\[32m\\h\\e\[0m'"'"'; else echo '"'"'\\e\[31m\\h\\e\[0m'"'"' ; fi\\\`:\\\w\\\$ "' ${TARGET_DIR}/etc/profile

