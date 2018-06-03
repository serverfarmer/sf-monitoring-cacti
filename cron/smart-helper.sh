#!/bin/sh

path="/var/cache/cacti"
devices=`/opt/farm/ext/standby-monitor/utils/list-physical-drives.sh |grep -vxFf /etc/local/.config/skip-smart.devices`

for device in $devices; do
	base="`basename $device`"
	file="$path/$base.txt"

	/usr/sbin/smartctl -d sat -T permissive -a $device >$file.new
	mv -f $file.new $file 2>/dev/null

	/opt/farm/ext/monitoring-cacti/cron/send.sh $file
done
