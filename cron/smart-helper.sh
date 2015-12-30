#!/bin/sh

path="/var/cache/cacti"


if [ "$1" != "--force" ]; then
	disks=`ls /dev/disk/by-id/ata-* |grep -v -- -part |grep -v VBOX_HARDDISK |grep -v CF_CARD |grep -v DVD |grep -vxFf /opt/sf-standby-monitor/config/devices.conf`
else
	disks=`ls /dev/disk/by-id/ata-* |grep -v -- -part |grep -v VBOX_HARDDISK |grep -v CF_CARD |grep -v DVD`
fi

for disk in $disks; do
	device="`basename $disk`"
	file="$path/$device.txt"

	/usr/sbin/smartctl -d sat -T permissive -a $disk >$file.new
	mv -f $file.new $file 2>/dev/null

	/opt/sf-monitoring-cacti/cron/send.sh $file
done
