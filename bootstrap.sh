#!/bin/sh

mkdir /tmp
mount -t tmpfs -o mode=1777 tmpfs /tmp

# Install base
apk update
apk upgrade

apk add openrc
rc-update add devfs boot
rc-update add procfs boot
rc-update add sysfs boot
rc-update add networking default
rc-update add local default
ln -s /run /var/run

# Install TTY
apk add agetty
apk add bash

# Setting up shell
apk add shadow
chsh -s /bin/bash

echo -e "luckfox\nluckfox" | passwd
sed -i 's:/bin/ash:/bin/bash:' /etc/passwd
apk del -r shadow

# Install SSH
apk add openssh
rc-update add sshd default

# Extra stuff
apk add mtd-utils-ubi
apk add util-linux
apk add iperf3
apk add ca-certificates-bundle
apk add python3 
apk add py3-pip
apk add py3-smbus
apk add libgpiod
apk add alpine-conf
apk add chrony
apk add zabbix-agent
apk add zabbix-agent-openrc
rc-update add zabbix-agentd default
apk add nano
apk add mc


setup-ntp chrony
setup-timezone -z Europe/Kyiv

# Clear apk cache
rm -rf /var/cache/apk/*

ls -l /extrootfs/
# Packaging rootfs
for d in bin etc lib sbin usr opt var; do tar c "$d" | tar x -C /extrootfs; done
for dir in dev proc root run sys tmp; do mkdir /extrootfs/${dir}; done
