#!/bin/sh

# Install base
apk update
apk upgrade

apk add openrc
rc-update add devfs boot
rc-update add procfs boot
rc-update add sysfs boot
rc-update add networking default
rc-update add local default

# Install TTY
apk add agetty

# Setting up shell
apk add shadow
apk add bash bash-completion
chsh -s /bin/bash
ln -s /run /var/run
echo -e "luckfox\nluckfox" | passwd
sed -i 's:/bin/ash:/bin/bash:' /etc/passwd
apk del -r shadow

# Install SSH
apk add openssh
rc-update add sshd default

# Extra stuff
apk add mtd-utils-ubi
apk add ca-certificates-bundle
apk add python3 
apk add py3-pip
apk add py3-smbus
apk add libgpiod
apk add alpine-conf
apk add git
apk add zabbix-agent
apk add zabbix-agent-openrc
apk add nano
apk add mc
#apk add tzdata && cp /usr/share/zoneinfo/Europe/Kyiv /etc/localtime && echo "Europe/Kyiv" > /etc/timezone && apk del tzdata


cat << EOF > /etc/init.d/ntpd
#!/sbin/openrc-run

name="busybox $SVCNAME"
command="/usr/sbin/$SVCNAME"
command_args="${NTPD_OPTS:--N -p pool.ntp.org}"
pidfile="/run/$SVCNAME.pid"

depend() {
    need net
    provide ntp-client
    use dns
}
EOF

chmod +x /etc/init.d/ntpd
setup-ntp busybox
setup-timezone -z Europe/Kyiv

# Clear apk cache
rm -rf /var/cache/apk/*

ls -l /extrootfs/
# Packaging rootfs
for d in bin etc lib sbin usr; do tar c "$d" | tar x -C /extrootfs; done
for dir in dev proc root run sys var; do mkdir /extrootfs/${dir}; done
