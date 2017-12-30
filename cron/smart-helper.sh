#!/bin/sh

path="/var/cache/cacti"

if [ ! -f $path/usb.tmp ]; then
	touch $path/usb.tmp
fi

devices=`/opt/farm/ext/standby-monitor/utils/list-physical-drives.sh |grep -vxFf /etc/local/.config/standby.exceptions`

for device in $devices; do
	devname=`readlink -f $device`

	if ! grep -qxF $devname $path/usb.tmp || [ "$1" = "--force" ]; then
		base="`basename $device`"
		file="$path/$base.txt"

		/usr/sbin/smartctl -d sat -T permissive -a $device >$file.new
		mv -f $file.new $file 2>/dev/null

		/opt/farm/ext/monitoring-cacti/cron/send.sh $file
	fi
done
